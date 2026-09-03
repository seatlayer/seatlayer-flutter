import 'bridge/bridge_client.dart';
import 'bridge/bridge_protocol.dart';
import 'open_enums.dart';
import 'payloads.dart';

/// This SDK's version.
const String seatLayerSdkVersion = '0.6.1';

/// The SeatLayer renderer version this SDK release is pinned to.
const String seatLayerHostedWebVersion = '0.77.0';

/// Renderer version retained only for the example app's offline fixture.
///
/// The fixture itself lives in `example/assets/`, outside the published
/// package.
const String seatLayerLegacyFixtureWebVersion = '0.68.0';

/// Source commit the example's offline fixture was built from.
const String seatLayerBundledRuntimeSourceCommit =
    'd71db683520bf6c7034208e10806d59ddd7c5c0d';

/// SHA-256 of the example's offline fixture, built from
/// [seatLayerBundledRuntimeSourceCommit].
const String seatLayerBundledRuntimeSha256 =
    'cadcfaea8ebda2dbef175be4462673c64ba6fe79e5e856c9b466941088a5056b';

/// Byte length of the example's offline fixture.
const int seatLayerBundledRuntimeByteLength = 1181605;

/// The origin the SDK loads the SeatLayer renderer from.
///
/// Register it on the publishable key you use.
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

  /// The renderer this SDK release is pinned to. Override only for a bundled,
  /// self-contained demo or test fixture.
  static const String defaultAssetPath = seatLayerMobilePageUrl;

  /// Event key, e.g. `ev_xxx`. Required.
  final String event;

  /// API origin. Defaults to `https://api.seatlayer.io` on the web side.
  final String? apiBase;

  /// Publishable `pk_` key for the public Platform bootstrap.
  ///
  /// Register [seatLayerMobileOrigin] on the matching key. For private,
  /// login-gated, presale, partner, or channel inventory use
  /// [buyerAccessTokenProvider] instead. An explicit
  /// [buyerAccessTokenProvider] or [buyerAccessToken] takes precedence.
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

  /// Free-form host identification, for server-side diagnostics.
  final Map<String, String> hostInfo;

  /// Where the view loads the SeatLayer renderer from.
  ///
  /// Leave it alone in production: the default is the renderer version this
  /// SDK release is pinned to, which is what makes a shipped app's behaviour
  /// reproducible. Point it elsewhere to validate a pre-release renderer, or
  /// at a Flutter asset key for a self-contained offline fixture.
  ///
  /// The publishable key's registered origins govern what the API will
  /// answer, so any origin you point this at has to be registered too.
  final String assetPath;

  /// The initialisation payload sent to the renderer.
  Map<String, Object?> initPayload({
    ProtocolRange protocolRange = ProtocolRange.native,
  }) {
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

  /// Whether rebuilding a [SeatLayerConfiguration] produced the same runtime
  /// semantics. This intentionally does not use object identity: Flutter apps
  /// commonly construct configuration inline in `build`, and that must not
  /// reload the venue map or erase a buyer's place in the map.
  bool semanticallyEquals(SeatLayerConfiguration other) =>
      event == other.event &&
      apiBase == other.apiBase &&
      publicKey == other.publicKey &&
      maxSelection == other.maxSelection &&
      locale == other.locale &&
      _deepEquals(messages, other.messages) &&
      currency == other.currency &&
      colorblindSafe == other.colorblindSafe &&
      initialView == other.initialView &&
      showsWebSeatTooltip == other.showsWebSeatTooltip &&
      _deepEquals(
        buyerAccessToken?.toJson(),
        other.buyerAccessToken?.toJson(),
      ) &&
      identical(buyerAccessTokenProvider, other.buyerAccessTokenProvider) &&
      _deepEquals(selectedObjects, other.selectedObjects) &&
      _deepEquals(selectableObjects, other.selectableObjects) &&
      numberOfPlacesToSelect == other.numberOfPlacesToSelect &&
      _deepEquals(
        selectionValidators
            ?.map((validator) => validator.toJson())
            .toList(growable: false),
        other.selectionValidators
            ?.map((validator) => validator.toJson())
            .toList(growable: false),
      ) &&
      commandTimeout == other.commandTimeout &&
      handshakeTimeout == other.handshakeTimeout &&
      _deepEquals(hostInfo, other.hostInfo) &&
      assetPath == other.assetPath;
}

bool _deepEquals(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (!_deepEquals(left[i], right[i])) return false;
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final key in left.keys) {
      if (!right.containsKey(key) || !_deepEquals(left[key], right[key])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}
