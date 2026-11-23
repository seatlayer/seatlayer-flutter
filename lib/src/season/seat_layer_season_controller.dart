import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../bridge/bridge_protocol.dart';
import '../bridge/bridge_session.dart';
import '../json.dart';
import '../payloads.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import 'season_configuration.dart';
import 'season_models.dart';

/// Drives one Season page: its events as streams, its commands as methods.
///
/// The web `SeasonPicker`'s callbacks and methods, over the bridge. Create one
/// per screen and [dispose] it with the screen.
class SeatLayerSeasonController
    extends SeatLayerBridgeSession<SeatLayerSeasonConfiguration> {
  SeatLayerSeasonController();

  SeatLayerSeasonStatus? _status;
  SeatLayerSeasonHandoff? _hold;
  final Set<String> _continued = <String>{};
  final Map<String, SeatLayerSeasonHandoff> _handoffs =
      <String, SeatLayerSeasonHandoff>{};
  final Set<String> _booked = <String>{};

  final _onStatus = StreamController<SeatLayerSeasonStatus>.broadcast();
  final _onHold = StreamController<SeatLayerSeasonHandoff?>.broadcast();
  final _onHoldExpired = StreamController<void>.broadcast();
  final _onContinue = StreamController<SeatLayerSeasonHandoff>.broadcast();
  final _onBooked = StreamController<SeatLayerSeasonHandoff>.broadcast();
  final _onAccessExpired =
      StreamController<BuyerAccessExpiredEvent>.broadcast();
  final _onAccessUnavailable =
      StreamController<BuyerAccessUnavailableEvent>.broadcast();

  // MARK: - State

  /// The page's last status line.
  SeatLayerSeasonStatus? get status => _status;

  /// The hold the page has now, or null.
  SeatLayerSeasonHandoff? get hold => _hold;

  // MARK: - Events

  /// Every status line: loading, ready (with the dates), held, booked, …
  Stream<SeatLayerSeasonStatus> get onStatus => _onStatus.stream;

  /// The hold changed: made, changed or let go (null).
  Stream<SeatLayerSeasonHandoff?> get onHold => _onHold.stream;

  /// The hold ran out or the server let it go.
  Stream<void> get onHoldExpired => _onHoldExpired.stream;

  /// The buyer pressed Continue: book this hold on your server, charge at your
  /// prices, then call [markBooked]. Each hold arrives once here, whatever the
  /// page repeats.
  Stream<SeatLayerSeasonHandoff> get onContinue => _onContinue.stream;

  /// A hold this page made or restored is booked: the page shows it booked.
  /// Each hold arrives once.
  Stream<SeatLayerSeasonHandoff> get onBooked => _onBooked.stream;

  /// Private buyer access ran out or was refused.
  Stream<BuyerAccessExpiredEvent> get onAccessExpired =>
      _onAccessExpired.stream;

  /// Private buyer access is not available.
  Stream<BuyerAccessUnavailableEvent> get onAccessUnavailable =>
      _onAccessUnavailable.stream;

  @override
  @protected
  void handleSurfaceEvent(String name, Object? payload) {
    if (isDisposed) return;
    switch (name) {
      case 'season.status':
        final status = SeatLayerSeasonStatus.fromJson(payload);
        if (status == null) return;
        _status = status;
        _onStatus.add(status);
        final booked = _handoffs[status.operationId];
        if (status.kind == SeatLayerSeasonStatusKind.booked &&
            booked != null &&
            _booked.add(booked.operationId)) {
          _onBooked.add(booked);
        }
      case 'season.hold' || 'season.holdChanged':
        final handoff =
            SeatLayerSeasonHandoff.fromJson(jGet(payload, 'handoff'));
        if (handoff == null && name == 'season.hold') return;
        if (handoff != null) _handoffs[handoff.operationId] = handoff;
        _hold = handoff;
        _onHold.add(handoff);
      case 'season.holdExpired':
        _hold = null;
        _onHold.add(null);
        _onHoldExpired.add(null);
      case 'season.continue':
        final handoff =
            SeatLayerSeasonHandoff.fromJson(jGet(payload, 'handoff'));
        if (handoff == null || !_continued.add(handoff.operationId)) return;
        _handoffs[handoff.operationId] = handoff;
        _onContinue.add(handoff);
      case 'season.accessExpired':
        final event = BuyerAccessExpiredEvent.fromJson(payload);
        if (event != null) _onAccessExpired.add(event);
      case 'season.accessUnavailable':
        final event = BuyerAccessUnavailableEvent.fromJson(payload);
        if (event != null) _onAccessUnavailable.add(event);
      case 'season.error':
        emitError(SeatLayerError.bridge(BridgeErrorPayload.fromJson(payload)));
      default:
        super.handleSurfaceEvent(name, payload);
    }
  }

  // MARK: - Commands

  /// A fresh caller-stable id for a hold. Keep it to retry the same hold.
  static String newOperationId() => 'sop_${_randomId()}';

  /// A fresh caller-stable id for a release.
  static String newReleaseActionId() => 'sra_${_randomId()}';

  /// Hold the seats named by [labels] for every date of the package.
  ///
  /// [priceTypes] maps a seat label to its price type (`child`, …) on a
  /// package priced by type.
  Future<SeatLayerSeasonHandoff> holdSameSeat(
    List<String> labels, {
    String? operationId,
    Map<String, String>? priceTypes,
  }) async =>
      _handoff(await run('season.holdSameSeat', <String, Object?>{
        'labels': labels,
        'operationId': operationId ?? newOperationId(),
        if (priceTypes != null) 'priceTypes': priceTypes,
      }));

  /// Hold the best [quantity] seats the page finds.
  Future<SeatLayerSeasonHandoff> holdBestAvailable(
    int quantity, {
    String? operationId,
    String? categoryKey,
    String? zoneId,
    List<String>? accessibility,
    bool? requireContiguous,
  }) async =>
      _handoff(await run('season.holdBestAvailable', <String, Object?>{
        'qty': quantity,
        'operationId': operationId ?? newOperationId(),
        if (categoryKey != null) 'categoryKey': categoryKey,
        if (zoneId != null) 'zoneId': zoneId,
        if (accessibility != null) 'accessibility': accessibility,
        if (requireContiguous != null) 'requireContiguous': requireContiguous,
      }));

  /// Open on a hold your app already has. Null when it is no longer held.
  Future<SeatLayerSeasonHandoff?> restoreOperation(String operationId) async =>
      SeatLayerSeasonHandoff.fromJson(jGet(
        await run('season.restoreOperation', <String, Object?>{
          'operationId': operationId,
        }),
        'handoff',
      ));

  /// Back to choosing seats.
  Future<void> chooseSeats() async {
    await run('season.chooseSeats', const <String, Object?>{});
  }

  /// Switch to the package [planActivationId].
  Future<void> choosePackage(String planActivationId) async {
    await run('season.choosePackage', <String, Object?>{
      'planActivationId': planActivationId,
    });
  }

  /// Your server booked [operationId]: the page shows it booked and never
  /// releases it. Call it only after your server has booked.
  Future<SeatLayerSeasonBookedStatus> markBooked({String? operationId}) async {
    final result = await run('season.markBooked', <String, Object?>{
      if (operationId != null) 'operationId': operationId,
    });
    return SeatLayerSeasonBookedStatus(
      jStr(jGet(result, 'status')) ?? SeatLayerSeasonBookedStatus.pending.raw,
    );
  }

  /// Let the held seats go. True only when the hold was released; a booked
  /// hold is never released.
  Future<bool> release({String? releaseActionId}) async =>
      jBool(jGet(
        await run('season.release', <String, Object?>{
          'releaseActionId': releaseActionId ?? newReleaseActionId(),
        }),
        'released',
      )) ==
      true;

  /// The held order as the page prices it, or null with nothing held.
  Future<SeatLayerSeasonHeldOrder?> getHeldOrder() async =>
      SeatLayerSeasonHeldOrder.fromJson(
        jGet(await run('season.getHeldOrder', const <String, Object?>{}),
            'heldOrder'),
      );

  /// The buyer pressed close or Back. With seats held the page asks whether to
  /// release or keep them; the outcome says what to do with the screen, and
  /// [operationId] names the hold it was about (kept: reopen on it with
  /// `initialOperationId`).
  Future<({SeatLayerSeasonCloseOutcome outcome, String? operationId})>
      requestClose() async {
    // The page may put a question to the buyer: no deadline.
    final result = await runAwaitingBuyer(
      'season.requestClose',
      const <String, Object?>{},
    );
    return (
      outcome: SeatLayerSeasonCloseOutcome(
        jStr(jGet(result, 'outcome')) ?? SeatLayerSeasonCloseOutcome.stayed.raw,
      ),
      operationId: jStr(jGet(result, 'operationId')),
    );
  }

  /// Tell the page the app went to the background or came back. Coming back,
  /// the page re-reads the hold; the answer says whether it is still held.
  Future<bool?> setForeground(bool foreground) async => jBool(jGet(
        await run('season.lifecycle', <String, Object?>{
          'state': foreground ? 'foreground' : 'background',
        }),
        'held',
      ));

  /// Paint the page light or dark in place, without a reload.
  Future<void> setThemeMode(SeatLayerThemeMode? mode) async {
    await run('season.setThemeMode', <String, Object?>{'mode': mode?.raw});
  }

  /// The room the app's own bars take around the page, in logical pixels.
  /// Null clears it.
  Future<void> setViewportInsets(EdgeInsets? insets) async {
    await run(
      'season.setViewportInsets',
      insets == null
          ? const <String, Object?>{'insets': null}
          : <String, Object?>{
              'top': insets.top,
              'right': insets.right,
              'bottom': insets.bottom,
              'left': insets.left,
            },
    );
  }

  /// A page that goes away takes its status and its hold with it; the next
  /// page reports its own.
  @override
  void detachTransport() {
    super.detachTransport();
    _status = null;
    _hold = null;
  }

  /// Tear the page down. A plain, unfinished hold is released first; a hold
  /// that was continued, restored, booked or kept never is.
  Future<void> destroy() async {
    try {
      await run('season.destroy', const <String, Object?>{});
    } catch (_) {
      // Best effort: the page may already be gone.
    }
    detachTransport();
  }

  SeatLayerSeasonHandoff _handoff(Object? result) {
    final handoff = SeatLayerSeasonHandoff.fromJson(jGet(result, 'handoff'));
    if (handoff == null) {
      throw const SeatLayerError.decoding('the page answered without a hold');
    }
    _handoffs[handoff.operationId] = handoff;
    return handoff;
  }

  @override
  void dispose() {
    if (isDisposed) return;
    super.dispose();
    _onStatus.close();
    _onHold.close();
    _onHoldExpired.close();
    _onContinue.close();
    _onBooked.close();
    _onAccessExpired.close();
    _onAccessUnavailable.close();
  }
}

final Random _random = Random.secure();

String _randomId() {
  const alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
  return String.fromCharCodes(List<int>.generate(
    20,
    (_) => alphabet.codeUnitAt(_random.nextInt(alphabet.length)),
  ));
}
