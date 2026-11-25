import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:meta/meta.dart';

import '../json.dart';
import '../payloads.dart';
import '../seat_layer_error.dart';
import '../seat_layer_surface_configuration.dart';
import 'bridge_client.dart';
import 'bridge_profile.dart';
import 'bridge_protocol.dart';
import 'bridge_unloaded_map.dart';
import 'envelope.dart';

/// What every SeatLayer page needs from the app, whatever it shows: the
/// handshake, private buyer access and the correlated command runner.
///
/// A surface controller extends this for its own configuration [C], and adds
/// its events and commands through [handleSurfaceEvent] and
/// [compatibilityProblem].
abstract class SeatLayerBridgeSession<
    C extends SeatLayerSurfaceConfiguration> {
  SeatLayerBridgeSession();

  BridgeClient? _client;
  C? _configuration;
  SeatLayerBridgeProfile _profile = SeatLayerBridgeProfile.chart;

  ReadyInfo? _readyInfo;
  BundleInfo? _bundleInfo;
  int? _protocolRevision;

  Completer<ReadyInfo>? _readyCompleter;

  /// What the page reported while it was still loading.
  SeatLayerError? _loadError;
  Timer? _handshakeTimer;

  /// Runs from the view arming the handshake to `sys.ready`, which is the only
  /// place the WHOLE cold start is visible: the web side cannot see the map host
  /// being created and the app cannot see the chart finish rendering.
  Stopwatch? _handshakeClock;
  int? _timeToHelloMs;
  bool _hasFinished = false;
  bool _disposed = false;

  final _onReady = StreamController<ReadyInfo>.broadcast();
  final _onError = StreamController<SeatLayerError>.broadcast();
  final _onUnknownEvent = StreamController<UnknownEvent>.broadcast();
  final _onBridgeEvent = StreamController<EventSignal>.broadcast();
  final _onPageLost = StreamController<void>.broadcast();

  // MARK: - State

  /// What `sys.ready` reported. Non-null once the chart exists.
  ReadyInfo? get readyInfo => _readyInfo;

  /// What the bundle advertised in `hello`. Populated before [readyInfo].
  BundleInfo? get bundleInfo => _bundleInfo;

  /// The negotiated protocol revision, or `null` before a successful handshake.
  int? get protocolRevision => _protocolRevision;

  bool get isReady => _readyInfo != null;

  // MARK: - Event streams

  /// The handshake completed and the chart rendered. Check `mode` —
  /// [EventMode.test] books no real inventory and must be badged.
  Stream<ReadyInfo> get onReady => _onReady.stream;

  /// Something failed out of band. A failed COMMAND does not appear here — it
  /// throws from its `Future` instead.
  Stream<SeatLayerError> get onError => _onError.stream;

  /// An event this build does not model — a bundle newer than the app.
  Stream<UnknownEvent> get onUnknownEvent => _onUnknownEvent.stream;

  /// Every accepted bridge event, before raw-chart routing.
  ///
  /// Used by the high-level picker adapter so protocol-v2 events do not have to
  /// masquerade as unknown raw-chart events.
  @internal
  Stream<EventSignal> get onBridgeEvent => _onBridgeEvent.stream;

  // MARK: - Surface hooks

  /// Routes one event the session itself does not handle. The default treats
  /// it as unknown.
  @protected
  void handleSurfaceEvent(String name, Object? payload) =>
      emitUnknownEvent(UnknownEvent(name: name, payload: payload));

  /// Why [bundle] cannot drive [configuration], or null when it can. Asked
  /// after the protocol and the profile's required capabilities agree.
  @protected
  String? compatibilityProblem(
    C configuration,
    BundleInfo bundle,
  ) =>
      null;

  /// Reports an out-of-band failure on [onError].
  @protected
  void emitError(SeatLayerError error) {
    if (_readyCompleter != null) _loadError = error;
    _onError.add(error);
  }

  /// Reports an event this build does not model on [onUnknownEvent].
  @protected
  void emitUnknownEvent(UnknownEvent event) => _onUnknownEvent.add(event);

  // MARK: - Handshake orchestration (driven by SeatLayerView)

  /// Attach a channel, arm the handshake, and complete when `sys.ready` arrives.
  /// Called by [SeatLayerView]; not part of the app-facing API.
  @internal
  Future<ReadyInfo> beginHandshake(
    BridgeChannel channel,
    C configuration, {
    SeatLayerBridgeProfile profile = SeatLayerBridgeProfile.chart,
  }) {
    if (_disposed) {
      return Future<ReadyInfo>.error(const SeatLayerError.destroyed());
    }
    _configuration = configuration;
    _profile = profile;
    _handshakeClock = Stopwatch()..start();
    _timeToHelloMs = null;
    _hasFinished = false;
    _loadError = null;
    _readyInfo = null;
    _bundleInfo = null;
    _protocolRevision = null;

    // A fresh client so a reload never inherits stale correlations or event
    // sequence watermarks from a previous chart.
    _client?.close();
    final client = BridgeClient(
      channel: channel,
      timeout: configuration.commandTimeout,
    );
    client.onSignal(_handleSignal);
    _client = client;

    final completer = Completer<ReadyInfo>();
    _readyCompleter = completer;

    _handshakeTimer?.cancel();
    _handshakeTimer = Timer(configuration.handshakeTimeout, () {
      _finishHandshake(
        SeatLayerError.handshakeTimeout(configuration.handshakeTimeout),
      );
    });

    return completer.future;
  }

  /// The page the session talks to, by identity. A page that another one has
  /// already replaced must not detach it.
  @internal
  Object? get transport => _client;

  /// Feed one raw web→native frame (the `JavaScriptChannel` string) to the
  /// client. Called by [SeatLayerView].
  @internal
  void ingestRaw(Object? message) {
    final envelope = Envelope.decode(message);
    if (envelope == null) return; // not ours, or malformed — dropped.
    _client?.ingest(envelope);
  }

  /// Report a page-load / navigation failure as a transport error. Called by
  /// [SeatLayerView].
  @internal
  void failWithTransport(String detail) {
    _finishHandshake(SeatLayerError.transport(detail));
  }

  /// The system ended the page (iPhone, low memory). A picker that listens puts
  /// a new page in its place; a bare view reports it on [onError].
  @internal
  Stream<void> get onPageLost => _onPageLost.stream;

  /// Whether somebody answers [onPageLost].
  @internal
  bool get answersPageLost => _onPageLost.hasListener;

  /// The page is gone, and everything waiting on it is refused. Called by
  /// [SeatLayerView].
  @internal
  void pageLost() {
    if (_disposed) return;
    const error = SeatLayerError.transport(
      'The system closed the SeatLayer page.',
    );
    final answered = answersPageLost;
    if (!answered) _finishHandshake(error);
    _dropPage(error);
    if (answered) _onPageLost.add(null);
  }

  void _handleSignal(BridgeSignal signal) {
    switch (signal) {
      case HelloSignal(:final payload):
        _handleHello(payload);
      case EventSignal(:final name, :final payload):
        if (name == 'sys.ready' &&
            _profile.isPicker &&
            seatLayerPickerMapDidNotLoad(jGet(payload, 'snapshot'))) {
          final error = _loadError ??
              const SeatLayerError.transport('The seat map did not load.');
          _finishHandshake(error);
          _client?.close(error);
          _client = null;
          return;
        }
        _onBridgeEvent.add(signal);
        _handleEvent(name, payload);
      case UnhandledSignal(:final envelope):
        _onUnknownEvent.add(
          UnknownEvent(name: envelope.type, payload: envelope.payload),
        );
    }
  }

  void _handleHello(Object? payload) {
    _timeToHelloMs ??= _handshakeClock?.elapsedMilliseconds;
    final info = BundleInfo.fromJson(payload);
    _bundleInfo = info;

    // Negotiate natively BEFORE replying. The web side checks too, but failing
    // here means the app never asks for a chart it could not drive, and the
    // caller gets a typed error instead of a blank view.
    final profile = _profile;
    final result = negotiate(
      native: profile.protocolRange,
      web: info.protocolRange,
    );
    switch (result) {
      case NegotiationIncompatible(:final reason):
        _finishHandshake(
          SeatLayerError.incompatible(
            native: profile.protocolRange,
            web: info.protocolRange,
            reason: reason,
          ),
        );
      case NegotiationAgreed():
        final config = _configuration;
        if (config != null) {
          final missing = profile.requiredCapabilities
              .where((capability) => !info.supportsCapability(capability))
              .toList(growable: false);
          if (missing.isNotEmpty) {
            _finishHandshake(
              SeatLayerError.incompatible(
                native: profile.protocolRange,
                web: info.protocolRange,
                reason:
                    'the bundle is missing required ${profile.surface} capabilities: ${missing.join(', ')}',
              ),
            );
            return;
          }
          final problem = compatibilityProblem(config, info);
          if (problem != null) {
            _finishHandshake(
              SeatLayerError.incompatible(
                native: profile.protocolRange,
                web: info.protocolRange,
                reason: problem,
              ),
            );
            return;
          }
          unawaited(
            _client?.sendInit(profile.initPayload(config, bundle: info)) ??
                Future.value(),
          );
        }
    }
  }

  void _handleEvent(String name, Object? payload) {
    switch (name) {
      case 'sys.ready':
        _finishHandshake(
          ReadyInfo.fromJson(
            payload,
            timeToHelloMs: _timeToHelloMs,
            timeToReadyMs: _handshakeClock?.elapsedMilliseconds,
          ),
        );
      case 'sys.incompatible':
        final web =
            ProtocolRange.from(jGet(payload, 'web')) ?? ProtocolRange.native;
        final reason = jStr(jGet(payload, 'message')) ??
            jStr(jGet(payload, 'code')) ??
            "the seat map bundle rejected this app's protocol range";
        _finishHandshake(
          SeatLayerError.incompatible(
            native: _profile.protocolRange,
            web: web,
            reason: reason,
          ),
        );
      case 'sys.error':
        _finishHandshake(
          SeatLayerError.bridge(BridgeErrorPayload.fromJson(payload)),
        );
      case 'access.token.request':
        unawaited(_provideBuyerAccessToken(payload));
      default:
        handleSurfaceEvent(name, payload);
    }
  }

  Future<void> _provideBuyerAccessToken(Object? payload) async {
    final requestId = jStr(jGet(payload, 'requestId'));
    if (requestId == null) return;
    final client = _client;
    if (client == null) return;
    final rawReason = jStr(jGet(payload, 'reason')) ?? 'initial';
    final provider = _configuration?.buyerAccessTokenProvider;

    if (provider == null) {
      try {
        await client.command(
          'access.token.unavailable',
          payload: {'requestId': requestId},
        );
      } catch (_) {}
      return;
    }

    BuyerAccessToken token;
    try {
      token = await provider(
        BuyerAccessRequestContext(
          reason: BuyerAccessRefreshReason.fromRaw(rawReason),
        ),
      );
      if (token.token.trim().isEmpty || token.expiresAt?.isFinite == false) {
        throw StateError('invalid buyer access token');
      }
    } catch (_) {
      // Provider failures are sanitized; errors and bearers never become events.
      try {
        await client.command(
          'access.token.unavailable',
          payload: {'requestId': requestId},
        );
      } catch (_) {}
      return;
    }

    try {
      await client.command(
        'access.token.provide',
        payload: {
          'requestId': requestId,
          'token': token.token,
          if (token.expiresAt != null) 'expiresAt': token.expiresAt,
        },
      );
    } catch (_) {
      // The request may have timed out or the view may have reloaded.
    }
  }

  void _finishHandshake(Object outcome) {
    if (_disposed) return;
    if (_hasFinished) {
      // A failure AFTER ready (a late sys.error / error) is a stream event, not
      // a load result.
      if (outcome is SeatLayerError) _onError.add(outcome);
      return;
    }
    _hasFinished = true;
    _handshakeTimer?.cancel();
    _handshakeTimer = null;
    _handshakeClock?.stop();

    final completer = _readyCompleter;
    _readyCompleter = null;

    if (outcome is ReadyInfo) {
      _readyInfo = outcome;
      _protocolRevision = outcome.protocolRevision;
      _onReady.add(outcome);
      completer?.complete(outcome);
    } else if (outcome is SeatLayerError) {
      if (!identical(outcome, _loadError)) _onError.add(outcome);
      completer?.completeError(outcome);
    }
  }

  // MARK: - Commands

  /// Send one correlated command to the page.
  @protected
  @internal
  Future<Object?> run(String command, [Object? payload]) {
    final client = _client;
    if (client == null) {
      return Future.error(const SeatLayerError.transport('no chart loaded'));
    }
    return client.command(command, payload: payload);
  }

  /// [run] for a command that waits for the buyer, such as a question the
  /// page puts to them: no deadline, since the buyer takes the time they take.
  /// The page answers every command once, and a detached page fails it.
  @protected
  @internal
  Future<Object?> runAwaitingBuyer(String command, [Object? payload]) {
    final client = _client;
    if (client == null) {
      return Future.error(const SeatLayerError.transport('no chart loaded'));
    }
    return client.command(command, payload: payload, untimed: true);
  }

  /// Send a correlated semantic bridge command for the high-level picker.
  @internal
  Future<Object?> runBridgeCommand(String command, [Object? payload]) =>
      run(command, payload);

  /// Detach the current page/transport without disposing this caller-owned
  /// controller. A subsequent page load may attach a fresh bridge.
  @internal
  void detachTransport() => _dropPage(const SeatLayerError.destroyed());

  void _dropPage(SeatLayerError error) {
    _handshakeTimer?.cancel();
    _handshakeTimer = null;
    final pending = _readyCompleter;
    _readyCompleter = null;
    if (pending != null && !pending.isCompleted) pending.completeError(error);
    _client?.close(error);
    _client = null;
    _readyInfo = null;
    _bundleInfo = null;
    _protocolRevision = null;
    _hasFinished = false;
  }

  /// Whether [dispose] has run.
  @protected
  bool get isDisposed => _disposed;

  /// Release all resources. Call from your `State.dispose`.
  @mustCallSuper
  void dispose() {
    if (_disposed) return;
    detachTransport();
    _disposed = true;
    _onReady.close();
    _onError.close();
    _onUnknownEvent.close();
    _onBridgeEvent.close();
    _onPageLost.close();
  }
}
