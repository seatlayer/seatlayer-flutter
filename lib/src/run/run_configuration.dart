import '../bridge/bridge_client.dart';
import '../bridge/bridge_protocol.dart';
import '../payloads.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_surface_configuration.dart';
import 'run_models.dart';

/// The run page of the renderer this SDK release is pinned to.
const String seatLayerRunPageUrl =
    '$seatLayerMobileOrigin/seatlayer-js@$seatLayerHostedWebVersion/group.html';

/// Everything needed to open a run: a few performances sold to one buyer as
/// one hold, with your app's own checkout.
///
/// Field names are the web `PerformanceGroupPicker` option names.
class SeatLayerRunConfiguration implements SeatLayerSurfaceConfiguration {
  SeatLayerRunConfiguration({
    required this.run,
    this.apiBase,
    this.selectionMode,
    this.allowSelectionModeSwitch,
    this.numberOfPlacesToSelect,
    this.maxSelection,
    this.buyerAccessToken,
    this.buyerAccessTokenProvider,
    this.initialHoldId,
    this.initialOperationId,
    this.locale,
    this.colorblindSafe,
    this.enable3D,
    this.commandTimeout = BridgeClient.defaultTimeout,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.hostInfo = const {},
    this.assetPath = defaultAssetPath,
  }) {
    if (run.trim().isEmpty) throw ArgumentError.value(run, 'run');
    if (maxSelection != null && maxSelection! < 1) {
      throw ArgumentError.value(maxSelection, 'maxSelection');
    }
    if (numberOfPlacesToSelect != null && numberOfPlacesToSelect! < 1) {
      throw ArgumentError.value(
          numberOfPlacesToSelect, 'numberOfPlacesToSelect');
    }
    // The page refuses both with bad_payload and mounts nothing.
    if ((selectionMode == SeatLayerRunSelectionMode.perPerformance ||
            allowSelectionModeSwitch == true) &&
        numberOfPlacesToSelect == null) {
      throw ArgumentError.value(null, 'numberOfPlacesToSelect',
          'is required with per-performance selection or the switch');
    }
    if ((initialHoldId == null) != (initialOperationId == null)) {
      throw ArgumentError(
          'initialHoldId and initialOperationId come both or neither');
    }
    if (buyerAccessToken != null &&
        (buyerAccessToken!.token.trim().isEmpty ||
            buyerAccessToken!.expiresAt?.isFinite == false)) {
      throw ArgumentError.value(buyerAccessToken, 'buyerAccessToken');
    }
  }

  /// The run page this SDK release is pinned to. Override only for a
  /// pre-release renderer or a test fixture.
  static const String defaultAssetPath = seatLayerRunPageUrl;

  /// Run key, e.g. `pg_xxx`. Required.
  final String run;

  /// API origin. Defaults to `https://api.seatlayer.io` on the web side.
  final String? apiBase;

  /// Same seat for every performance (the default) or a choice per
  /// performance.
  final SeatLayerRunSelectionMode? selectionMode;

  /// Shows the page's own switch between the two modes.
  final bool? allowSelectionModeSwitch;

  /// How many places the buyer picks. Required with per-performance selection
  /// or the switch.
  final int? numberOfPlacesToSelect;

  /// Max seats the buyer may hold at once.
  final int? maxSelection;

  /// One-shot private buyer bearer. Prefer [buyerAccessTokenProvider].
  /// Without either, the page opens a public-sale session itself.
  final BuyerAccessToken? buyerAccessToken;

  /// Renews private buyer access in memory when the page asks.
  @override
  final BuyerAccessTokenProvider? buyerAccessTokenProvider;

  /// A hold this buyer already has: both or neither.
  final String? initialHoldId;

  /// The `pghop_` operation id of [initialHoldId].
  final String? initialOperationId;

  /// BCP 47 language for the page, e.g. `de` or `es-MX`.
  final String? locale;

  /// Colorblind-safe rendering, as on the event picker.
  final bool? colorblindSafe;

  /// Whether the 3D venue is offered. Null keeps the web default.
  final bool? enable3D;

  @override
  final Duration commandTimeout;

  @override
  final Duration handshakeTimeout;

  /// Free-form host identification, for server-side diagnostics.
  final Map<String, String> hostInfo;

  @override
  final String assetPath;

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
      'performanceGroup': run,
      if (apiBase != null) 'apiBase': apiBase,
      if (selectionMode != null) 'selectionMode': selectionMode!.raw,
      if (allowSelectionModeSwitch != null)
        'allowSelectionModeSwitch': allowSelectionModeSwitch,
      if (numberOfPlacesToSelect != null)
        'numberOfPlacesToSelect': numberOfPlacesToSelect,
      if (maxSelection != null) 'maxSelection': maxSelection,
      if (buyerAccessToken != null)
        'buyerAccessToken': buyerAccessToken!.toJson(),
      if (buyerAccessTokenProvider != null) 'nativeAccessProvider': true,
      if (initialHoldId != null) 'initialHoldId': initialHoldId,
      if (initialOperationId != null) 'initialOperationId': initialOperationId,
      if (locale != null) 'locale': locale,
      if (colorblindSafe != null) 'colorblindSafe': colorblindSafe,
      if (enable3D != null) 'enable3D': enable3D,
      // The app's bar is the only one, and checkout is the app's.
      'header': false,
      'checkout': 'handoff',
    };
    return <String, Object?>{
      'protocol': protocolRange.toJson(),
      'host': host,
      'config': config,
    };
  }

  /// Whether [other] opens the same run the same way, so a rebuilt widget
  /// keeps its page instead of reloading it.
  @override
  bool semanticallyEquals(SeatLayerRunConfiguration other) =>
      seatLayerSameValue(_identity, other._identity) &&
      identical(buyerAccessTokenProvider, other.buyerAccessTokenProvider);

  List<Object?> get _identity => <Object?>[
        run,
        apiBase,
        selectionMode?.raw,
        allowSelectionModeSwitch,
        numberOfPlacesToSelect,
        maxSelection,
        buyerAccessToken?.toJson(),
        initialHoldId,
        initialOperationId,
        locale,
        colorblindSafe,
        enable3D,
        commandTimeout,
        handshakeTimeout,
        hostInfo,
        assetPath,
      ];
}
