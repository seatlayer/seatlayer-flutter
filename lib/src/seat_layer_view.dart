import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bridge/bridge_client.dart';
import 'bridge/bridge_profile.dart';
import 'bridge/envelope.dart';
import 'payloads.dart';
import 'seat_layer_configuration.dart';
import 'seat_layer_controller.dart';
import 'seat_layer_error.dart';
import 'seat_layer_prewarm.dart';

/// The JavaScript channel name the web bundle probes for
/// (`window.SeatLayer.postMessage`). MUST be exactly this string, and is
/// shared with the prewarm so an adopted page keeps the channel it was made
/// with rather than being given a second one under the same name.
const String _channelName = seatLayerChannelName;

/// A seat map.
///
/// Hosts a [WebViewWidget] running the immutable, version-pinned SeatLayer
/// mobile page, performs the
/// bridge handshake, and drives the chart through the supplied
/// [SeatLayerController].
///
/// ## Known constraint (v0.1)
///
/// The map must be a FIXED-HEIGHT or full-screen box. Do NOT place it inside a
/// scrolling container ([ListView], [SingleChildScrollView], …). The canvas
/// consumes pan and pinch to drive its own zoom, so an enclosing scroll view and
/// the map fight over every gesture and neither behaves. Give it a definite
/// size and let the map own the space it occupies. An [EagerGestureRecognizer]
/// is installed so the map — not Flutter — wins those gestures.
class SeatLayerView extends StatefulWidget {
  const SeatLayerView({
    super.key,
    required this.controller,
    required this.configuration,
    this.onReady,
    this.onLoadError,
    this.backgroundColor,
    this.bridgeProfile = SeatLayerBridgeProfile.chart,
  });

  /// The controller that exposes the chart's commands and event streams. Create
  /// it in your `State`, keep it, and `dispose()` it.
  final SeatLayerController controller;

  /// What chart to load and how.
  final SeatLayerConfiguration configuration;

  /// Called once `sys.ready` arrives. The same value is delivered on
  /// [SeatLayerController.onReady].
  final void Function(ReadyInfo info)? onReady;

  /// Called if the handshake fails (incompatible bundle, timeout, page load).
  final void Function(SeatLayerError error)? onLoadError;

  /// Fill color behind the (transparent) web content.
  final Color? backgroundColor;

  /// Internal surface contract. Ordinary integrations should leave this at the
  /// raw chart default; [SeatLayerPickerMap] supplies the picker-v2 profile.
  @internal
  final SeatLayerBridgeProfile bridgeProfile;

  @override
  State<SeatLayerView> createState() => _SeatLayerViewState();
}

class _SeatLayerViewState extends State<SeatLayerView> {
  late final WebViewController _web;
  int _generation = 0;

  /// The prewarmed page this view adopted, for as long as it is mounted.
  ///
  /// Held rather than dropped after boot so `dispose` can detach its channel:
  /// the page delivers into a controller this view is about to let go of.
  SeatLayerWarmPage? _warm;

  /// Whether the first boot still has a loaded page waiting for it.
  bool _adoptWarmPage = false;

  @override
  void initState() {
    super.initState();
    final warm =
        SeatLayerRuntimePrewarm.claim(widget.configuration.assetPath);
    if (warm != null) {
      // The page is already loading, its channel is already installed, and
      // whatever it has said so far is buffered. Adopt all three.
      _warm = warm;
      _adoptWarmPage = true;
      _web = warm.controller
        ..setNavigationDelegate(_navigationDelegate());
      _boot();
      return;
    }
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      // The map is a canvas, not a scrolling document — the bundle owns zoom.
      ..enableZoom(false)
      ..addJavaScriptChannel(
        _channelName,
        onMessageReceived: (message) {
          // web→native is always a STRING for the Flutter shim.
          widget.controller.ingestRaw(message.message);
        },
      )
      ..setNavigationDelegate(_navigationDelegate());

    // Suppress WKWebView bounce and Android edge glow when the installed
    // platform adapter supports it. Some host apps override a newer
    // webview_flutter facade with an older adapter; the pinned document's CSS
    // remains the fallback and that host mismatch must not fail picker boot.
    unawaited(_disablePlatformOverScroll());
    _boot();
  }

  NavigationDelegate _navigationDelegate() => NavigationDelegate(
        onNavigationRequest: (request) =>
            _allowsNavigation(widget.configuration.assetPath, request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent,
        onWebResourceError: (error) {
          // Only a hard failure of the main document should fail the load;
          // sub-resource noise must not abort a working chart.
          if (error.isForMainFrame ?? true) {
            if (!mounted) return;
            widget.controller.failWithTransport(
              'page load failed: ${error.description}',
            );
          }
        },
      );

  Future<void> _disablePlatformOverScroll() async {
    try {
      await _web.setOverScrollMode(WebViewOverScrollMode.never);
    } catch (_) {
      // Capability fallback for host-overridden legacy platform adapters.
    }
  }

  Future<void> _boot() async {
    final generation = ++_generation;
    final channel = _RunJavaScriptChannel(_web);

    // Arm the handshake BEFORE loading the page, so the `hello` the bundle emits
    // on startup is already routed and the `init` reply can go straight back.
    final ready = widget.controller.beginHandshake(
      channel,
      widget.configuration,
      profile: widget.bridgeProfile,
    );
    unawaited(
      ready.then(
        (info) {
          if (mounted && generation == _generation) {
            widget.onReady?.call(info);
          }
        },
        onError: (Object error, StackTrace _) {
          if (mounted && generation == _generation && error is SeatLayerError) {
            widget.onLoadError?.call(error);
          }
        },
      ),
    );

    // A prewarmed page brings its own channel, so route it here whether or
    // not its greeting is still worth having. Through `widget` rather than
    // bound to today's controller, so a later controller swap keeps receiving.
    var adopted = false;
    if (_adoptWarmPage) {
      _adoptWarmPage = false;
      adopted = _warm!.hasLiveHandshake;
      _warm!.adopt(
        (message) => widget.controller.ingestRaw(message),
        replay: adopted,
      );
    }
    // Its handshake is still live: the page is up and has already said hello,
    // so replaying that is the whole boot. Nothing to request.
    if (adopted) return;

    try {
      final location = widget.configuration.assetPath;
      final uri = Uri.tryParse(location);
      if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
        await _web.loadRequest(uri);
      } else {
        await _web.loadFlutterAsset(location);
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        widget.controller.failWithTransport('could not load asset: $e');
      }
    }
  }

  @override
  void didUpdateWidget(covariant SeatLayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controllerChanged = oldWidget.controller != widget.controller;
    final configurationChanged =
        !oldWidget.configuration.semanticallyEquals(widget.configuration);
    final profileChanged =
        !oldWidget.bridgeProfile.equivalentTo(widget.bridgeProfile);
    final runtimeChanged =
        controllerChanged || configurationChanged || profileChanged;
    if (!runtimeChanged) return;

    // Invalidate callbacks from the old page before closing its correlations.
    final generation = ++_generation;
    if (oldWidget.bridgeProfile.isPicker) {
      unawaited(
        _destroyPickerThenBoot(
          oldWidget.controller,
          oldWidget.bridgeProfile,
          generation,
        ),
      );
      return;
    }
    oldWidget.controller.detachTransport();
    unawaited(_boot());
  }

  Future<void> _destroyPickerThenBoot(
    SeatLayerController controller,
    SeatLayerBridgeProfile profile,
    int generation,
  ) async {
    await prepareSeatLayerRuntimeReload(
      oldController: controller,
      oldProfile: profile,
    );
    if (!mounted || generation != _generation) return;
    controller.detachTransport();
    await _boot();
  }

  @override
  void dispose() {
    _generation += 1;
    // Nothing more from this page: the controller it was delivering into is
    // being detached on the next line.
    _warm?.detach();
    widget.controller.detachTransport();
    super.dispose();
  }

  bool _allowsNavigation(String configuredLocation, String requestedLocation) {
    final configured = Uri.tryParse(configuredLocation);
    if (configured != null &&
        (configured.scheme == 'https' || configured.scheme == 'http')) {
      return requestedLocation == configuredLocation;
    }

    // `loadFlutterAsset` resolves a package key to a platform-specific file URL.
    // Only that explicit fixture document is allowed to become the main page.
    final requested = Uri.tryParse(requestedLocation);
    return requested?.scheme == 'file' &&
        Uri.decodeComponent(requested!.path).endsWith(configuredLocation);
  }

  @override
  Widget build(BuildContext context) {
    final view = RepaintBoundary(
      // Native picker chrome can rebuild after a semantic state change without
      // invalidating the platform-view layer that owns the active gesture.
      child: WebViewWidget(
        controller: _web,
        // Without an eager recognizer webview_flutter never receives the
        // pan/zoom gestures the canvas needs — it loses every drag to Flutter's
        // arena.
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
    final bg = widget.backgroundColor;
    return bg == null ? view : ColoredBox(color: bg, child: view);
  }
}

/// Best-effort acknowledged teardown shared by configuration and controller
/// replacement paths. Exposed only so the ordering can be tested without a
/// platform view.
@visibleForTesting
Future<void> prepareSeatLayerRuntimeReload({
  required SeatLayerController oldController,
  required SeatLayerBridgeProfile oldProfile,
}) async {
  if (!oldProfile.isPicker) return;
  try {
    // Give the old picker a chance to release only picker-owned inventory and
    // acknowledge teardown before its command correlations are closed.
    await oldController.runBridgeCommand('picker.destroy');
  } catch (_) {
    // Reload remains recoverable when an old or stalled runtime cannot ack.
  }
}

/// native→web over `WebViewController.runJavaScript`.
///
/// The envelope is JSON-encoded, then that JSON string is itself JSON-encoded to
/// produce a safely-quoted, fully-escaped JS string literal. The payload is
/// therefore passed to `recv` as DATA — it is never interpolated as code,
/// whatever it contains.
class _RunJavaScriptChannel implements BridgeChannel {
  _RunJavaScriptChannel(this._web);
  final WebViewController _web;

  @override
  Future<void> send(Envelope envelope) async {
    final wire = jsonEncode(envelope.toJson());
    final literal = jsonEncode(wire); // → a quoted, escaped JS string literal.
    try {
      await _web.runJavaScript(
        'window.__slBridge && window.__slBridge.recv($literal);',
      );
    } catch (_) {
      // A transport hiccup (page torn down mid-send) must never escape; the
      // command layer's timeout is the backstop.
    }
  }
}
