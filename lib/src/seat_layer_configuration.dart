import 'bridge/bridge_client.dart';
import 'bridge/bridge_protocol.dart';

/// This SDK's version.
const String seatLayerSdkVersion = '0.1.2';

/// The web bundle version vendored into this package (`assets/seatlayer.js`).
const String seatLayerBundledWebVersion = '0.26.0';

/// Everything needed to boot a seat map.
///
/// Field names mirror the web `SeatingChart` options and the iOS
/// `SeatLayerConfiguration` so all three SDKs read as one product.
class SeatLayerConfiguration {
  SeatLayerConfiguration({
    required this.event,
    this.apiBase,
    this.publicKey,
    this.maxSelection,
    this.locale,
    this.messages,
    this.currency,
    this.colorblindSafe,
    this.showsWebSeatTooltip = false,
    this.commandTimeout = BridgeClient.defaultTimeout,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.hostInfo = const {},
    this.assetPath = defaultAssetPath,
  });

  /// The Flutter asset that hosts the vendored bundle. Loaded from the package,
  /// never the network — a seat map opens with zero network dependency at
  /// startup. Override to load a self-contained fixture page (the example app
  /// points this at its offline demo fixture).
  static const String defaultAssetPath = 'packages/seatlayer/assets/index.html';

  /// Event key, e.g. `ev_xxx`. Required.
  final String event;

  /// API origin. Defaults to `https://api.seatlayer.io` on the web side.
  final String? apiBase;

  /// Reserved for future authenticated rendering.
  final String? publicKey;

  /// Max seats selectable at once (web default 10).
  final int? maxSelection;

  /// BCP 47 language for the widget UI — `de`, `es-MX`, … Built-in: en, es, de,
  /// fr. Defaults to the device language on the web side.
  final String? locale;

  /// Per-key string overrides layered over the active locale.
  final Map<String, String>? messages;

  /// ISO 4217 currency for on-map prices (web default USD).
  final String? currency;

  /// Colorblind-safe rendering: category hues switch to an Okabe-Ito palette and
  /// booked seats render hollow, so state never relies on hue alone.
  final bool? colorblindSafe;

  /// Whether the WEB side draws its in-canvas seat tooltip. Leave `false` when
  /// the app presents its own seat sheet — the default, because a hover tooltip
  /// is a pointer affordance that does not belong on touch.
  final bool showsWebSeatTooltip;

  /// Native-side deadline for a single command before it fails `sl_timeout`.
  final Duration commandTimeout;

  /// How long to wait for `sys.ready` before failing the load.
  final Duration handshakeTimeout;

  /// Free-form host identification sent in `init.host`, for server-side and
  /// bundle-side diagnostics.
  final Map<String, String> hostInfo;

  /// The Flutter asset key the WebView loads.
  final String assetPath;

  /// The `init` payload: `{ protocol, host, chrome, config }`.
  Map<String, Object?> initPayload(
      {ProtocolRange protocolRange = ProtocolRange.native}) {
    final host = <String, Object?>{
      'platform': 'flutter',
      'sdk': seatLayerSdkVersion,
    };
    host.addAll(hostInfo);

    final config = <String, Object?>{'event': event};
    if (apiBase != null) config['apiBase'] = apiBase;
    if (publicKey != null) config['publicKey'] = publicKey;
    if (maxSelection != null) config['maxSelection'] = maxSelection;
    if (locale != null) config['locale'] = locale;
    if (currency != null) config['currency'] = currency;
    if (colorblindSafe != null) config['colorblindSafe'] = colorblindSafe;
    if (messages != null) config['messages'] = messages;

    return {
      'protocol': protocolRange.toJson(),
      'host': host,
      'chrome': {'seatTooltip': showsWebSeatTooltip},
      'config': config,
    };
  }
}
