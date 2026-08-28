/// Starting the runtime page before the buyer asks for it.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The JavaScript channel name the web bundle probes for. MUST match the one
/// [SeatLayerView] installs — a warmed page keeps the channel it was created
/// with, and a claimant re-points it rather than adding a second one.
const String seatLayerChannelName = 'SeatLayer';

/// How long an unclaimed warm page is kept before it is thrown away.
///
/// Long enough for a buyer to read an event page and decide; short enough that
/// a WebView nobody wanted is not still holding a web content process when
/// they are three screens away.
const Duration seatLayerPrewarmDefaultTtl = Duration(minutes: 5);

/// How long a warm page's own handshake is still worth adopting.
///
/// **Measured on the pilot, and the reason a prewarm is a warm WebView rather
/// than a warm session.** The runtime page starts its own clock the moment it
/// loads and gives up on the host after ten seconds
/// (`sys.error {code: 'host_timeout'}`, `bridge/host.ts`). A buyer who reads
/// an event page for a minute and then taps would have been handed a page that
/// had already given up, and the picker opened on an error.
///
/// So a page older than this window is re-loaded when it is claimed. That
/// costs the document again — which is a cache hit, measured at
/// `transferSize=0` and 2 ms — and keeps what actually made the difference:
/// the WebView process, which is 550-1,280 ms of cold `loadRequest` →
/// `onPageStarted` on this simulator alone.
///
/// Six seconds rather than ten, so a claim that lands at the edge of the
/// window still has time to send `init` before the page's own clock fires.
const Duration seatLayerPrewarmHandshakeWindow = Duration(seconds: 6);

/// A runtime page that was started before anything asked to look at it.
///
/// The page emits its bridge `hello` as soon as it boots, which is normally
/// answered by the [SeatLayerView] that armed the handshake before loading.
/// A prewarmed page has no view yet, so its channel writes into [_buffered]
/// instead and the claimant replays it. Nothing is dropped and no ordering
/// changes: the bridge sees exactly the messages the page sent, in order.
class SeatLayerWarmPage {
  SeatLayerWarmPage._(this.url, this.controller);

  /// The document this page is loading or has loaded.
  final String url;

  /// The controller a claiming view adopts.
  final WebViewController controller;

  final List<String> _buffered = <String>[];
  void Function(String message)? _sink;
  Timer? _expiry;
  DateTime? _loadedAt;
  bool _claimed = false;
  bool _discarded = false;

  /// Whether this page's own handshake is still worth adopting.
  ///
  /// False once the runtime's host timeout is close enough to matter; see
  /// [seatLayerPrewarmHandshakeWindow]. A claimant that reads false re-loads
  /// the document on the warm controller instead of replaying its greeting.
  bool get hasLiveHandshake {
    final loadedAt = _loadedAt;
    if (loadedAt == null || _failed) return false;
    return SeatLayerRuntimePrewarm.now().difference(loadedAt) <
        seatLayerPrewarmHandshakeWindow;
  }

  /// Whether this page failed to load and must not be handed to anyone.
  bool get isFailed => _failed;
  bool _failed = false;

  void _receive(String message) {
    final sink = _sink;
    if (sink == null) {
      _buffered.add(message);
      return;
    }
    sink(message);
  }

  /// Deliver this page's messages to [sink] from now on.
  ///
  /// With [replay] the greeting the page made into an empty room is handed
  /// over first, in the order it was said, so the bridge sees exactly what it
  /// would have seen live. Without it the buffer is dropped, which is what a
  /// claimant re-loading a stale page wants: that page's `hello` belongs to a
  /// document that is about to be replaced.
  void adopt(void Function(String message) sink, {required bool replay}) {
    _sink = sink;
    final pending = List<String>.of(_buffered);
    _buffered.clear();
    if (!replay) return;
    for (final message in pending) {
      sink(message);
    }
  }

  /// Stop delivering to whatever was attached, without discarding the page.
  void detach() => _sink = null;
}

/// Warm runtime pages, keyed by the document they are loading.
///
/// Static because a prewarm outlives the widget that asked for it — that is
/// the whole point: the buyer is still on the event screen and no picker
/// exists yet.
abstract final class SeatLayerRuntimePrewarm {
  static final Map<String, SeatLayerWarmPage> _pages =
      <String, SeatLayerWarmPage>{};
  static _MemoryWatch? _memoryWatch;

  /// The clock the handshake window is measured on.
  ///
  /// Real time, because the runtime page's own timeout is real time too — a
  /// faked scheduler would not move it. Replaceable so a test can stand a page
  /// past the window without waiting six seconds for it.
  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  /// Every warm page currently held, for tests and diagnostics.
  @visibleForTesting
  static Iterable<String> get warmUrls => _pages.keys;

  /// Start [url] now so a later view mounts onto a page that is already up.
  ///
  /// Idempotent: calling it again for a page that is already warm only
  /// refreshes how long it is kept. Non-http documents are ignored — a
  /// bundled fixture loads from disk and has nothing to gain.
  static void start(String url, {Duration ttl = seatLayerPrewarmDefaultTtl}) {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) return;

    final existing = _pages[url];
    if (existing != null && !existing.isFailed) {
      _arm(existing, ttl);
      return;
    }

    late final SeatLayerWarmPage page;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false)
      ..addJavaScriptChannel(
        seatLayerChannelName,
        onMessageReceived: (message) => page._receive(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          // The warm page is exactly one document and never navigates.
          onNavigationRequest: (request) => request.url == url
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              // A page that failed to load is worse than no warm page: it
              // would be adopted and never speak. Drop it and let the view
              // build its own, which reports the failure properly.
              page._failed = true;
              discard(url);
            }
          },
        ),
      );
    page = SeatLayerWarmPage._(url, controller);
    _pages[url] = page;
    _arm(page, ttl);
    unawaited(_load(page, uri));
    _watchMemory();
  }

  static Future<void> _load(SeatLayerWarmPage page, Uri uri) async {
    try {
      await page.controller.setOverScrollMode(WebViewOverScrollMode.never);
    } catch (_) {
      // Capability fallback, exactly as SeatLayerView does.
    }
    try {
      page._loadedAt = now();
      await page.controller.loadRequest(uri);
    } catch (_) {
      page._failed = true;
      discard(page.url);
    }
  }

  static void _arm(SeatLayerWarmPage page, Duration ttl) {
    page._expiry?.cancel();
    if (page._claimed) return;
    page._expiry = Timer(ttl, () => discard(page.url));
  }

  /// Take the warm page for [url], if one is up and healthy.
  ///
  /// A page is handed out once. The caller owns it from then on, including
  /// its teardown, and the registry stops counting it against memory.
  static SeatLayerWarmPage? claim(String url) {
    final page = _pages.remove(url);
    if (page == null) return null;
    page._expiry?.cancel();
    page._expiry = null;
    if (page.isFailed || page._discarded) return null;
    page._claimed = true;
    return page;
  }

  /// Throw away the warm page for [url] if nobody claimed it.
  static void discard(String url) {
    final page = _pages.remove(url);
    if (page == null) return;
    _release(page);
  }

  /// Throw away every unclaimed warm page.
  static void discardAll() {
    final pages = List<SeatLayerWarmPage>.of(_pages.values);
    _pages.clear();
    for (final page in pages) {
      _release(page);
    }
  }

  static void _release(SeatLayerWarmPage page) {
    page._expiry?.cancel();
    page._expiry = null;
    page._discarded = true;
    page._sink = null;
    page._buffered.clear();
    // `WebViewController` has no disposal of its own: the platform view is
    // released when the last reference goes. Navigating the page away first
    // is what actually frees the runtime's memory, and it has to be done with
    // the delegate that would otherwise refuse the navigation removed.
    unawaited(() async {
      try {
        await page.controller.setNavigationDelegate(NavigationDelegate());
        await page.controller.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        // Best effort. A page that cannot be blanked is still dereferenced.
      }
    }());
  }

  static void _watchMemory() {
    if (_memoryWatch != null) return;
    final binding = WidgetsBinding.instance;
    _memoryWatch = _MemoryWatch();
    binding.addObserver(_memoryWatch!);
  }

  /// Forget everything, for a test that must not inherit another's state.
  @visibleForTesting
  static void resetForTesting() {
    now = DateTime.now;
    discardAll();
    final watch = _memoryWatch;
    if (watch != null) {
      WidgetsBinding.instance.removeObserver(watch);
      _memoryWatch = null;
    }
  }
}

/// Drops warm pages the moment the platform says memory is short.
///
/// A prewarm is a convenience; a web content process the buyer never asked
/// for is not worth an out-of-memory kill on the host application.
class _MemoryWatch extends WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() => SeatLayerRuntimePrewarm.discardAll();
}
