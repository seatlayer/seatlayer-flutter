import 'dart:async';

import 'bridge/bridge_protocol.dart';
import 'bridge/bridge_session.dart';
import 'open_enums.dart';
import 'payloads.dart';
import 'seat_layer_configuration.dart';
import 'seat_layer_error.dart';

/// The public, `Future`- and `Stream`-based API for a seat map.
///
/// Semantically identical to the iOS `SeatLayerView`: the same command set with
/// idiomatic Dart shapes, and iOS's delegate callbacks re-expressed as broadcast
/// [Stream]s. Hold one of these, hand it to a [SeatLayerView], and drive the
/// chart through it.
///
/// A failed command completes its returned `Future` WITH a [SeatLayerError] (it
/// does not merely surface on [onError]) — the iOS SDK's key fix. A
/// [bestAvailable] conflict throws `sold_out` / `not_enough_together` from the
/// awaited call.
class SeatLayerController extends SeatLayerBridgeSession {
  SeatLayerController();

  final _onSelectionChanged = StreamController<List<SelectedSeat>>.broadcast();
  final _onSelectionValidityChanged =
      StreamController<SelectionValidity>.broadcast();
  final _onSelectionValid = StreamController<List<SelectedSeat>>.broadcast();
  final _onSelectionInvalid = StreamController<SelectionValidity>.broadcast();
  final _onSelectionLimit = StreamController<int>.broadcast();
  final _onBuyerAccessExpired =
      StreamController<BuyerAccessExpiredEvent>.broadcast();
  final _onBuyerAccessUnavailable =
      StreamController<BuyerAccessUnavailableEvent>.broadcast();
  final _onSelectedObjectsUnavailable =
      StreamController<SelectedObjectUnavailableEvent>.broadcast();
  final _onHold = StreamController<HoldResult>.broadcast();
  final _onHoldRestored = StreamController<HoldResult>.broadcast();
  final _onHoldExpired = StreamController<void>.broadcast();
  final _onCheckout = StreamController<Object?>.broadcast();
  final _onHint = StreamController<String?>.broadcast();
  final _onGAClick = StreamController<GAArea>.broadcast();
  final _onSeatHover = StreamController<SeatHoverDetails?>.broadcast();
  final _onDeckTap = StreamController<String>.broadcast();

  // MARK: - Event streams

  /// The buyer's selection changed. Carries the FULL current selection.
  Stream<List<SelectedSeat>> get onSelectionChanged =>
      _onSelectionChanged.stream;

  Stream<SelectionValidity> get onSelectionValidityChanged =>
      _onSelectionValidityChanged.stream;
  Stream<List<SelectedSeat>> get onSelectionValid => _onSelectionValid.stream;
  Stream<SelectionValidity> get onSelectionInvalid =>
      _onSelectionInvalid.stream;
  Stream<int> get onSelectionLimit => _onSelectionLimit.stream;
  Stream<BuyerAccessExpiredEvent> get onBuyerAccessExpired =>
      _onBuyerAccessExpired.stream;
  Stream<BuyerAccessUnavailableEvent> get onBuyerAccessUnavailable =>
      _onBuyerAccessUnavailable.stream;
  Stream<SelectedObjectUnavailableEvent> get onSelectedObjectsUnavailable =>
      _onSelectedObjectsUnavailable.stream;

  /// A hold was created or updated.
  Stream<HoldResult> get onHold => _onHold.stream;

  /// A previously open hold was restored (app relaunch, reconnect).
  Stream<HoldResult> get onHoldRestored => _onHoldRestored.stream;

  /// The open hold expired server-side. The seats are gone; return to selection.
  Stream<void> get onHoldExpired => _onHoldExpired.stream;

  /// A checkout signal from a future bundle. The current v1 mobile bridge does
  /// not advertise this event; drive checkout from your own UI after a hold.
  Stream<Object?> get onCheckout => _onCheckout.stream;

  /// A transient buyer-facing hint, or `null` to clear it.
  Stream<String?> get onHint => _onHint.stream;

  /// The buyer tapped a general-admission area — prompt for a quantity, then
  /// call [holdGA].
  Stream<GAArea> get onGAClick => _onGAClick.stream;

  /// The buyer hovered/long-pressed a seat, or `null` on hover-out. Only fires
  /// when the app draws its own seat popover.
  Stream<SeatHoverDetails?> get onSeatHover => _onSeatHover.stream;

  /// The buyer tapped a floor in a multi-floor deck.
  Stream<String> get onDeckTap => _onDeckTap.stream;

  // MARK: - Chart events

  @override
  void handleSurfaceEvent(String name, Object? payload) {
    switch (name) {
      case 'selection.changed':
        _onSelectionChanged.add(
          _decodeList(jGetLocal(payload, 'seats'), SelectedSeat.fromJson),
        );
      case 'selection.validity.changed':
        final validity = SelectionValidity.fromJson(
          jGetLocal(payload, 'validity'),
        );
        if (validity != null) _onSelectionValidityChanged.add(validity);
      case 'selection.valid':
        _onSelectionValid.add(
          _decodeList(jGetLocal(payload, 'seats'), SelectedSeat.fromJson),
        );
      case 'selection.invalid':
        final validity = SelectionValidity.fromJson(
          jGetLocal(payload, 'validity'),
        );
        if (validity != null) _onSelectionInvalid.add(validity);
      case 'selection.limit':
        final maximum = jIntLocal(jGetLocal(payload, 'maxSelection'));
        if (maximum != null) _onSelectionLimit.add(maximum);
      case 'access.expired':
        final event = BuyerAccessExpiredEvent.fromJson(payload);
        if (event != null) _onBuyerAccessExpired.add(event);
      case 'access.unavailable':
        final event = BuyerAccessUnavailableEvent.fromJson(payload);
        if (event != null) _onBuyerAccessUnavailable.add(event);
      case 'selection.unavailable':
        final event = SelectedObjectUnavailableEvent.fromJson(payload);
        if (event != null) _onSelectedObjectsUnavailable.add(event);
      case 'hold.changed':
        final hold = HoldResult.fromJson(jGetLocal(payload, 'hold'));
        if (hold != null) _onHold.add(hold);
      case 'hold.restored':
        final hold = HoldResult.fromJson(jGetLocal(payload, 'hold'));
        if (hold != null) _onHoldRestored.add(hold);
      case 'hold.expired':
        _onHoldExpired.add(null);
      case 'ga.click':
        final area = GAArea.fromJson(jGetLocal(payload, 'area'));
        if (area != null) _onGAClick.add(area);
      case 'hint':
        _onHint.add(jStrLocal(jGetLocal(payload, 'message')));
      case 'error':
        emitError(SeatLayerError.bridge(BridgeErrorPayload.fromJson(payload)));
      case 'seat.hover':
        final raw = jGetLocal(payload, 'details');
        _onSeatHover.add(raw == null ? null : SeatHoverDetails.fromJson(raw));
      case 'deck.tap':
        final floorId = jStrLocal(jGetLocal(payload, 'floorId'));
        if (floorId != null) _onDeckTap.add(floorId);
      case 'checkout':
        _onCheckout.add(payload);
      default:
        emitUnknownEvent(UnknownEvent(name: name, payload: payload));
    }
  }

  @override
  String? compatibilityProblem(
    SeatLayerConfiguration configuration,
    BundleInfo bundle,
  ) {
    if (configuration.usesPrivateAccess &&
        !bundle.supportsCapability('native-access-provider')) {
      return 'the bundle does not support private buyer access';
    }
    if (configuration.usesSelectionPolicy &&
        (!bundle.supportsCapability('selection-controls') ||
            !bundle.supportsCapability('selection-validity'))) {
      return 'the bundle does not support the configured selection policy';
    }
    return null;
  }

  // MARK: - Commands

  /// Hold the current selection.
  Future<HoldResult?> hold({int? ttlMs}) async {
    final result = await run('hold', _compact({'ttlMs': ttlMs}));
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Reattach to an open hold (app relaunch, checkout resume).
  Future<HoldResult?> resumeHold(String holdId) async {
    final result = await run('resumeHold', {'holdId': holdId});
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Push the hold's expiry out.
  Future<HoldResult?> extendHold({int? ttlMs}) async {
    final result = await run('extendHold', _compact({'ttlMs': ttlMs}));
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Release the whole hold.
  Future<void> release() => run('release');

  /// Release specific seats from the hold, keeping the rest.
  Future<bool> releaseLabels(List<String> labels) async {
    final result = await run('releaseLabels', {'labels': labels});
    return jBoolLocal(jGetLocal(result, 'released')) ?? false;
  }

  /// Ask the server for the best `qty` seats and hold them. A conflict throws
  /// `sold_out` / `not_enough_together` from this call.
  Future<BestAvailableResult?> bestAvailable(
    int qty, {
    String? categoryKey,
  }) async {
    final result = await run(
      'bestAvailable',
      _compact({'qty': qty, 'categoryKey': categoryKey}),
    );
    return BestAvailableResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Hold general-admission capacity.
  ///
  /// [setTier] mirrors the web/iOS "doubly-optional" tier: leave [setTier]
  /// `false` to not touch the tier; set it `true` with [tierId] `null` to send
  /// an explicit `null` (revert to the default tier), or with a value to select.
  Future<HoldResult?> holdGA(
    String areaId,
    int qty, {
    bool setTier = false,
    String? tierId,
    int? ttlMs,
  }) async {
    final payload = <String, Object?>{'areaId': areaId, 'qty': qty};
    if (setTier) payload['tierId'] = tierId;
    if (ttlMs != null) payload['ttlMs'] = ttlMs;
    final result = await run('holdGA', payload);
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Choose a ticket tier for one seat. `null` reverts to the default tier.
  Future<void> setSeatTier(String seatId, String? tierId) =>
      run('setSeatTier', {'seatId': seatId, 'tierId': tierId});

  /// The current selection.
  Future<List<SelectedSeat>> getSelection() async {
    final result = await run('getSelection');
    return _decodeList(jGetLocal(result, 'seats'), SelectedSeat.fromJson);
  }

  Future<List<SelectedSeat>> selectObjects(List<String> objects) async {
    final result = await run('selectObjects', {'objects': objects});
    return _decodeList(jGetLocal(result, 'seats'), SelectedSeat.fromJson);
  }

  Future<void> deselectObjects(List<String> objects) =>
      run('deselectObjects', {'objects': objects});

  Future<void> clearSelection() => run('clearSelection');

  Future<List<SelectedSeat>> selectCategories(List<String> categoryKeys) async {
    final result = await run('selectCategories', {
      'categoryKeys': categoryKeys,
    });
    return _decodeList(jGetLocal(result, 'seats'), SelectedSeat.fromJson);
  }

  Future<void> deselectCategories(List<String> categoryKeys) =>
      run('deselectCategories', {'categoryKeys': categoryKeys});

  Future<void> setSelectableObjects(List<String>? objects) =>
      run('setSelectableObjects', {'objects': objects});

  Future<void> setMaxSelection(int maximum) {
    if (maximum < 1) return Future.error(ArgumentError.value(maximum));
    return run('setMaxSelection', {'maxSelection': maximum});
  }

  Future<SelectionValidity?> getSelectionValidity() async {
    final result = await run('getSelectionValidity');
    return SelectionValidity.fromJson(jGetLocal(result, 'validity'));
  }

  Future<bool> refreshAccess() async {
    final result = await run('refreshAccess');
    return jBoolLocal(jGetLocal(result, 'refreshed')) ?? false;
  }

  /// The open hold, if any.
  Future<HoldResult?> getCurrentHold() async {
    final result = await run('getCurrentHold');
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// General-admission areas and their live availability.
  Future<List<GAArea>> getGAAreas() async {
    final result = await run('getGAAreas');
    return _decodeList(jGetLocal(result, 'areas'), GAArea.fromJson);
  }

  /// Floors of a multi-floor venue. Empty for a single-floor chart.
  Future<List<FloorInfo>> getFloors() async {
    final result = await run('getFloors');
    return _decodeList(jGetLocal(result, 'floors'), FloorInfo.fromJson);
  }

  Future<void> setFloor(String floorId) =>
      run('setFloor', {'floorId': floorId});

  Future<void> setColorblindSafe(bool on) =>
      run('setColorblindSafe', {'on': on});

  Future<void> setViewMode(SeatLayerViewMode mode) =>
      run('setViewMode', {'mode': mode.raw});

  Future<SeatLayerViewMode> getViewMode() async {
    final result = await run('getViewMode');
    return SeatLayerViewMode.fromRaw(
      jStrLocal(jGetLocal(result, 'mode')) ?? 'flat',
    );
  }

  Future<void> zoomIn() => run('zoomIn');
  Future<void> zoomOut() => run('zoomOut');
  Future<void> zoomToFit() => run('zoomToFit');

  /// Tear the chart down. Subsequent commands fail with `destroyed`.
  Future<void> destroy() async {
    try {
      await run('destroy');
    } catch (_) {
      // Best-effort: the chart may already be gone.
    }
    detachTransport();
  }

  /// Release all resources. Call from your `State.dispose`.
  @override
  void dispose() {
    if (isDisposed) return;
    super.dispose();
    _onSelectionChanged.close();
    _onSelectionValidityChanged.close();
    _onSelectionValid.close();
    _onSelectionInvalid.close();
    _onSelectionLimit.close();
    _onBuyerAccessExpired.close();
    _onBuyerAccessUnavailable.close();
    _onSelectedObjectsUnavailable.close();
    _onHold.close();
    _onHoldRestored.close();
    _onHoldExpired.close();
    _onCheckout.close();
    _onHint.close();
    _onGAClick.close();
    _onSeatHover.close();
    _onDeckTap.close();
  }

  List<T> _decodeList<T>(Object? value, T? Function(Object?) decode) {
    if (value is! List) return <T>[];
    final out = <T>[];
    for (final item in value) {
      final decoded = decode(item);
      if (decoded != null) out.add(decoded);
    }
    return out;
  }

  /// Drop keys whose value is null, mirroring how the web side omits absent
  /// optionals rather than sending explicit `null`.
  Map<String, Object?> _compact(Map<String, Object?> pairs) {
    final out = <String, Object?>{};
    pairs.forEach((key, value) {
      if (value != null) out[key] = value;
    });
    return out;
  }
}

// Small local JSON reads, kept private so the controller does not leak the raw
// JSON helper surface into the public library.
Object? jGetLocal(Object? v, String key) =>
    v is Map ? (v.cast<String, Object?>())[key] : null;
String? jStrLocal(Object? v) => v is String ? v : null;
bool? jBoolLocal(Object? v) => v is bool ? v : null;
int? jIntLocal(Object? v) => v is int ? v : (v is num ? v.toInt() : null);
