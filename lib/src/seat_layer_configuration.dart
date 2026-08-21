import 'bridge/bridge_client.dart';
import 'bridge/bridge_protocol.dart';
import 'open_enums.dart';
import 'payloads.dart';

/// This SDK's version.
const String seatLayerSdkVersion = '0.2.0';

/// The immutable hosted web runtime used by production views.
const String seatLayerHostedWebVersion = '0.66.0';

/// Runtime retained only for explicit offline demo/test fixtures.
const String seatLayerLegacyFixtureWebVersion = '0.59.0';

@Deprecated(
    'Use seatLayerHostedWebVersion; production no longer uses a bundled runtime.')
const String seatLayerBundledWebVersion = seatLayerHostedWebVersion;
const String seatLayerMobileOrigin = 'https://cdn.seatlayer.io';
const String seatLayerMobilePageUrl =
    '$seatLayerMobileOrigin/seatlayer-js@$seatLayerHostedWebVersion/mobile.html';

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
    this.initialView,
    this.showsWebSeatTooltip = false,
    this.buyerAccessToken,
    this.buyerAccessTokenProvider,
    this.selectedObjects,
    this.selectableObjects,
    this.numberOfPlacesToSelect,
    this.selectionValidators,
    this.commandTimeout = BridgeClient.defaultTimeout,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.hostInfo = const {},
    this.assetPath = defaultAssetPath,
  }) {
    if (event.trim().isEmpty) throw ArgumentError.value(event, 'event');
    if (maxSelection != null && maxSelection! < 1) {
      throw ArgumentError.value(maxSelection, 'maxSelection');
    }
    if (numberOfPlacesToSelect != null && numberOfPlacesToSelect! < 1) {
      throw ArgumentError.value(
        numberOfPlacesToSelect,
        'numberOfPlacesToSelect',
      );
    }
    if (buyerAccessToken != null &&
        (buyerAccessToken!.token.trim().isEmpty ||
            buyerAccessToken!.expiresAt?.isFinite == false)) {
      throw ArgumentError.value(buyerAccessToken, 'buyerAccessToken');
    }
    for (final validator
        in selectionValidators ?? const <SelectionValidator>[]) {
      if (validator is MinimumSelectedPlaces && validator.minimum < 1) {
        throw ArgumentError.value(validator.minimum, 'selectionValidators');
      }
    }
  }

  /// Production uses the immutable hosted page. Override only for a bundled,
  /// self-contained demo or test fixture.
  static const String defaultAssetPath = seatLayerMobilePageUrl;

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

  final SeatLayerViewMode? initialView;

  /// Whether the WEB side draws its in-canvas seat tooltip. Leave `false` when
  /// the app presents its own seat sheet — the default, because a hover tooltip
  /// is a pointer affordance that does not belong on touch.
  final bool showsWebSeatTooltip;

  /// One-shot private buyer bearer. Prefer [buyerAccessTokenProvider].
  final BuyerAccessToken? buyerAccessToken;

  /// Renews private buyer access in memory without rebuilding the view.
  final BuyerAccessTokenProvider? buyerAccessTokenProvider;

  final List<String>? selectedObjects;
  final List<String>? selectableObjects;
  final int? numberOfPlacesToSelect;
  final List<SelectionValidator>? selectionValidators;

  /// Native-side deadline for a single command before it fails `sl_timeout`.
  final Duration commandTimeout;

  /// How long to wait for `sys.ready` before failing the load.
  final Duration handshakeTimeout;

  /// Free-form host identification sent in `init.host`, for server-side and
  /// bundle-side diagnostics.
  final Map<String, String> hostInfo;

  /// Hosted production URL, or a Flutter asset key for an explicit fixture.
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
    if (initialView != null) config['initialView'] = initialView!.raw;
    if (messages != null) config['messages'] = messages;
    if (buyerAccessToken != null) {
      config['buyerAccessToken'] = buyerAccessToken!.toJson();
    }
    if (buyerAccessTokenProvider != null) config['nativeAccessProvider'] = true;
    if (selectedObjects != null) config['selectedObjects'] = selectedObjects;
    if (selectableObjects != null) {
      config['selectableObjects'] = selectableObjects;
    }
    if (numberOfPlacesToSelect != null) {
      config['numberOfPlacesToSelect'] = numberOfPlacesToSelect;
    }
    if (selectionValidators != null) {
      config['selectionValidators'] =
          selectionValidators!.map((validator) => validator.toJson()).toList();
    }

    return {
      'protocol': protocolRange.toJson(),
      'host': host,
      'chrome': {'seatTooltip': showsWebSeatTooltip},
      'config': config,
    };
  }

  bool get usesPrivateAccess =>
      buyerAccessToken != null || buyerAccessTokenProvider != null;

  bool get usesSelectionPolicy =>
      selectedObjects != null ||
      selectableObjects != null ||
      numberOfPlacesToSelect != null ||
      selectionValidators != null;
}
