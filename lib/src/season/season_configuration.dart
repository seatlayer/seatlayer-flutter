import '../bridge/bridge_client.dart';
import '../bridge/bridge_protocol.dart';
import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_surface_configuration.dart';

/// The Season page of the renderer this SDK release is pinned to.
const String seatLayerSeasonPageUrl =
    '$seatLayerMobileOrigin/seatlayer-js@$seatLayerHostedWebVersion/season.html';

/// Everything needed to open a Season: a fixed package of dates, sold as the
/// same seat for every date, with your app's own checkout.
///
/// Field names are the web `SeasonPicker` option names.
class SeatLayerSeasonConfiguration implements SeatLayerSurfaceConfiguration {
  SeatLayerSeasonConfiguration({
    required this.season,
    this.apiBase,
    this.publicKey,
    this.package,
    this.priceTypes,
    this.ticketsByEmail,
    this.maxSelection,
    this.buyerAccessToken,
    this.buyerAccessTokenProvider,
    this.initialOperationId,
    this.locale,
    this.colorblindSafe,
    this.enable3D,
    this.enable3DCrowd,
    this.touchNavigation3D,
    this.commandTimeout = BridgeClient.defaultTimeout,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.hostInfo = const {},
    this.assetPath = defaultAssetPath,
  }) {
    if (season.trim().isEmpty) throw ArgumentError.value(season, 'season');
    if (maxSelection != null && maxSelection! < 1) {
      throw ArgumentError.value(maxSelection, 'maxSelection');
    }
    if (buyerAccessToken != null &&
        (buyerAccessToken!.token.trim().isEmpty ||
            buyerAccessToken!.expiresAt?.isFinite == false)) {
      throw ArgumentError.value(buyerAccessToken, 'buyerAccessToken');
    }
  }

  /// The Season page this SDK release is pinned to. Override only for a
  /// pre-release renderer or a test fixture.
  static const String defaultAssetPath = seatLayerSeasonPageUrl;

  /// Season key, e.g. `sea_xxx`. Required.
  final String season;

  /// API origin. Defaults to `https://api.seatlayer.io` on the web side.
  final String? apiBase;

  /// Publishable `pk_` key for the public Season. For a members-only Season
  /// use [buyerAccessTokenProvider] instead.
  final String? publicKey;

  /// The package to open on, by its key. Without it, or for a key that is not
  /// on sale, the Season opens on its first package. Ignored with a buyer
  /// access token, which is bound to one package.
  final String? package;

  /// The price types the buyer may choose per seat (`adult`, `child`, …), for
  /// a package priced by type. Absent or `['adult']`: every seat is adult.
  final List<String>? priceTypes;

  /// Your checkout emails a ticket for every date, so the first step says so.
  /// Default off.
  final bool? ticketsByEmail;

  /// Max seats the buyer may hold at once.
  final int? maxSelection;

  /// One-shot private buyer bearer. Prefer [buyerAccessTokenProvider].
  final BuyerAccessToken? buyerAccessToken;

  /// Renews private buyer access in memory when the page asks.
  @override
  final BuyerAccessTokenProvider? buyerAccessTokenProvider;

  /// A hold your app already has, by its `sop_` operation id: the page opens
  /// on it instead of starting a new one.
  final String? initialOperationId;

  /// BCP 47 language for the page, e.g. `de` or `es-MX`.
  final String? locale;

  /// Colorblind-safe rendering, as on the event picker.
  final bool? colorblindSafe;

  /// Whether the 3D venue is offered. Null keeps the web default (on).
  final bool? enable3D;

  /// False hides the standing crowd in 3D. Null keeps the web default (shown).
  final bool? enable3DCrowd;

  /// How a finger moves the 3D venue. Null keeps the web default.
  final SeatLayer3DTouchNavigation? touchNavigation3D;

  @override
  final Duration commandTimeout;

  @override
  final Duration handshakeTimeout;

  /// Free-form host identification, for server-side diagnostics.
  final Map<String, String> hostInfo;

  @override
  final String assetPath;

  /// Whether a buyer access token or provider is configured.
  bool get usesPrivateAccess =>
      buyerAccessToken != null || buyerAccessTokenProvider != null;

  @override
  Map<String, Object?> initPayload({
    ProtocolRange protocolRange = const ProtocolRange(min: 2, max: 2),
  }) {
    final host = <String, Object?>{
      'platform': 'flutter',
      'sdk': seatLayerSdkVersion,
      ...hostInfo,
    };
    final config = <String, Object?>{
      'season': season,
      if (apiBase != null) 'apiBase': apiBase,
      if (publicKey != null) 'publicKey': publicKey,
      if (package != null) 'package': package,
      if (priceTypes != null) 'priceTypes': priceTypes,
      if (ticketsByEmail != null) 'ticketsByEmail': ticketsByEmail,
      if (maxSelection != null) 'maxSelection': maxSelection,
      if (buyerAccessToken != null)
        'buyerAccessToken': buyerAccessToken!.toJson(),
      if (buyerAccessTokenProvider != null) 'nativeAccessProvider': true,
      if (initialOperationId != null) 'initialOperationId': initialOperationId,
      if (locale != null) 'locale': locale,
      if (colorblindSafe != null) 'colorblindSafe': colorblindSafe,
      if (enable3D != null) 'enable3D': enable3D,
      if (enable3DCrowd != null) 'enable3DCrowd': enable3DCrowd,
      if (touchNavigation3D != null)
        'touchNavigation3D': touchNavigation3D!.raw,
      // The app's bar is the only one, with the name, the clock and the ✕. A
      // page without `season-app-shell-v2` ignores it and shows its own.
      'appBar': true,
    };
    return <String, Object?>{
      'protocol': protocolRange.toJson(),
      'host': host,
      'config': config,
    };
  }

  /// Whether [other] opens the same Season the same way, so a rebuilt widget
  /// keeps its page instead of reloading it.
  @override
  bool semanticallyEquals(SeatLayerSeasonConfiguration other) =>
      seatLayerSameValue(_identity, other._identity) &&
      // A function written inline in `build` is a new one each time. The page
      // asks through the session, which holds the newest.
      (buyerAccessTokenProvider == null) ==
          (other.buyerAccessTokenProvider == null);

  List<Object?> get _identity => <Object?>[
        season,
        apiBase,
        publicKey,
        package,
        priceTypes,
        ticketsByEmail,
        maxSelection,
        buyerAccessToken?.toJson(),
        initialOperationId,
        locale,
        colorblindSafe,
        enable3D,
        enable3DCrowd,
        touchNavigation3D?.raw,
        commandTimeout,
        handshakeTimeout,
        hostInfo,
        assetPath,
      ];
}
