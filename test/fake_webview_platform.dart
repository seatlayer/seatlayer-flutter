// A `webview_flutter` platform that records instead of rendering.
//
// The picker's reload behaviour is only observable through the real
// [SeatLayerView], which builds a [WebViewController] in `initState`. Without a
// platform implementation that constructor asserts, so a widget test cannot see
// the one thing that matters here: whether a rebuild reused the WebView or made
// a new one.
//
// [FakeWebViewPlatform.controllersCreated] counts platform controllers, which
// is exactly one per WebView the tree actually built.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Installs the fake for one test and restores whatever was there before.
FakeWebViewPlatform useFakeWebViewPlatform() {
  final previous = WebViewPlatform.instance;
  final fake = FakeWebViewPlatform();
  WebViewPlatform.instance = fake;
  addTearDown(() {
    if (previous != null) WebViewPlatform.instance = previous;
  });
  return fake;
}

/// A `WebViewPlatform` whose objects do nothing and remember everything.
class FakeWebViewPlatform extends WebViewPlatform with MockPlatformInterfaceMixin {
  /// How many platform controllers have been created since installation.
  int controllersCreated = 0;

  /// Every document the tree asked a WebView to load, in order.
  final List<String> loads = <String>[];

  /// The JavaScript channels installed on each controller, in creation order.
  ///
  /// Recorded so a test can play the page's part: a prewarmed runtime posts
  /// its bridge `hello` before any view exists, and nothing else can produce
  /// that message.
  final List<Map<String, JavaScriptChannelParams>> channels =
      <Map<String, JavaScriptChannelParams>>[];

  /// Deliver [message] from the page running on controller [controller].
  void postFromPage(String message, {int controller = 0}) {
    final params = channels[controller]['SeatLayer'];
    if (params == null) {
      throw StateError('controller $controller has no SeatLayer channel');
    }
    params.onMessageReceived(JavaScriptMessage(message: message));
  }

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    controllersCreated += 1;
    channels.add(<String, JavaScriptChannelParams>{});
    return _FakeController(params, this, channels.length - 1);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) =>
      _FakeNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) =>
      _FakeWidget(params);
}

class _FakeController extends PlatformWebViewController
    with MockPlatformInterfaceMixin {
  _FakeController(super.params, this._platform, this._index)
      : super.implementation();

  final FakeWebViewPlatform _platform;
  final int _index;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> setOverScrollMode(WebViewOverScrollMode mode) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    _platform.channels[_index][javaScriptChannelParams.name] =
        javaScriptChannelParams;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    _platform.loads.add(params.uri.toString());
  }

  @override
  Future<void> loadFlutterAsset(String key) async {
    _platform.loads.add(key);
  }

  @override
  Future<void> runJavaScript(String javaScript) async {}

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async => '';
}

class _FakeNavigationDelegate extends PlatformNavigationDelegate
    with MockPlatformInterfaceMixin {
  _FakeNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {}
}

class _FakeWidget extends PlatformWebViewWidget with MockPlatformInterfaceMixin {
  _FakeWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
