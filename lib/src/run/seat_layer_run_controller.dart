import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show internal;

import '../bridge/bridge_protocol.dart';
import '../bridge/bridge_session.dart';
import '../json.dart';
import '../payloads.dart';
import '../seat_layer_error.dart';
import 'run_configuration.dart';
import 'run_models.dart';

/// Drives one run page: its events as streams, its commands as methods.
///
/// The web `PerformanceGroupPicker`'s callbacks and methods, over the bridge.
/// Create one per screen and [dispose] it with the screen.
class SeatLayerRunController
    extends SeatLayerBridgeSession<SeatLayerRunConfiguration> {
  SeatLayerRunController();

  SeatLayerRunDescriptor? _descriptor;
  SeatLayerRunSelectionMode? _selectionMode;
  SeatLayerRunStatus? _status;
  SeatLayerRunHandoff? _hold;
  final Set<String> _continued = <String>{};
  final Set<String> _booked = <String>{};

  final _onRun = StreamController<SeatLayerRunDescriptor>.broadcast();
  final _onStatus = StreamController<SeatLayerRunStatus>.broadcast();
  final _onHold = StreamController<SeatLayerRunHandoff?>.broadcast();
  final _onHoldExpired = StreamController<void>.broadcast();
  final _onContinue = StreamController<SeatLayerRunHandoff>.broadcast();
  final _onBooked = StreamController<SeatLayerRunHandoff>.broadcast();
  final _onSelectionMode =
      StreamController<SeatLayerRunSelectionMode>.broadcast();
  final _onAccessExpired =
      StreamController<BuyerAccessExpiredEvent>.broadcast();
  final _onAccessUnavailable =
      StreamController<BuyerAccessUnavailableEvent>.broadcast();

  // MARK: - State

  /// The run the page shows, once it is ready.
  SeatLayerRunDescriptor? get descriptor => _descriptor;

  /// Same seat for every performance, or a choice per performance.
  SeatLayerRunSelectionMode? get selectionMode => _selectionMode;

  /// The page's last status line.
  SeatLayerRunStatus? get status => _status;

  /// The hold the page has now, or null.
  SeatLayerRunHandoff? get hold => _hold;

  // MARK: - Events

  /// The run the page opened: its name and performances. Once per page.
  Stream<SeatLayerRunDescriptor> get onRun => _onRun.stream;

  /// Every status line: pending, sales closed, a recovery that failed, …
  Stream<SeatLayerRunStatus> get onStatus => _onStatus.stream;

  /// The hold changed: made, changed or let go (null).
  Stream<SeatLayerRunHandoff?> get onHold => _onHold.stream;

  /// The hold ran out or the organizer let it go.
  Stream<void> get onHoldExpired => _onHoldExpired.stream;

  /// The buyer pressed Continue: price and book this hold on your server,
  /// then call [markBooked]. Each hold arrives once here, whatever the page
  /// repeats.
  Stream<SeatLayerRunHandoff> get onContinue => _onContinue.stream;

  /// A hold is booked: the page shows it booked. Each hold arrives once.
  Stream<SeatLayerRunHandoff> get onBooked => _onBooked.stream;

  /// The selection mode changed.
  Stream<SeatLayerRunSelectionMode> get onSelectionMode =>
      _onSelectionMode.stream;

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
      case 'group.ready':
        final descriptor =
            SeatLayerRunDescriptor.fromJson(jGet(payload, 'performanceGroup'));
        if (descriptor == null) return;
        _descriptor = descriptor;
        final mode = jStr(jGet(payload, 'selectionMode'));
        if (mode != null) _selectionMode = SeatLayerRunSelectionMode(mode);
        _onRun.add(descriptor);
      case 'group.status':
        final status = SeatLayerRunStatus.fromJson(payload);
        if (status == null) return;
        _status = status;
        _onStatus.add(status);
      case 'group.hold' || 'group.holdChanged':
        final handoff = SeatLayerRunHandoff.fromJson(jGet(payload, 'handoff'));
        if (handoff == null && name == 'group.hold') return;
        _hold = handoff;
        _onHold.add(handoff);
      case 'group.holdExpired':
        _hold = null;
        _onHold.add(null);
        _onHoldExpired.add(null);
      case 'group.checkout':
        final handoff = SeatLayerRunHandoff.fromJson(jGet(payload, 'handoff'));
        if (handoff == null || !_continued.add(handoff.operationId)) return;
        _onContinue.add(handoff);
      case 'group.booked':
        final handoff = SeatLayerRunHandoff.fromJson(jGet(payload, 'handoff'));
        if (handoff == null || !_booked.add(handoff.operationId)) return;
        _onBooked.add(handoff);
      case 'group.selectionMode.changed':
        final mode = jStr(jGet(payload, 'selectionMode'));
        if (mode == null) return;
        _selectionMode = SeatLayerRunSelectionMode(mode);
        _onSelectionMode.add(_selectionMode!);
      case 'group.access.expired':
        final event = BuyerAccessExpiredEvent.fromJson(payload);
        if (event != null) _onAccessExpired.add(event);
      case 'group.access.unavailable':
        final event = BuyerAccessUnavailableEvent.fromJson(payload);
        if (event != null) _onAccessUnavailable.add(event);
      case 'group.error':
        emitError(SeatLayerError.bridge(BridgeErrorPayload.fromJson(payload)));
      default:
        super.handleSurfaceEvent(name, payload);
    }
  }

  // MARK: - Commands

  /// Hand the held seats off, as the buyer's Continue does. A hold already
  /// handed off is answered as it is.
  Future<SeatLayerRunHandoff> continueToCheckout() async {
    final handoff = SeatLayerRunHandoff.fromJson(jGet(
      await run('group.continue', const <String, Object?>{}),
      'handoff',
    ));
    if (handoff == null) {
      throw const SeatLayerError.decoding('the page answered without a hold');
    }
    return handoff;
  }

  /// The hold the page has, or null.
  Future<SeatLayerRunHandoff?> getHeldOrder() async =>
      SeatLayerRunHandoff.fromJson(jGet(
        await run('group.getHeldOrder', const <String, Object?>{}),
        'heldOrder',
      ));

  /// Put the page's hold in [hold] when no event has named one: a hold the
  /// page resumed at boot. The app's bar reads its clock from it.
  @internal
  Future<void> readHeldOrder() async {
    if (_hold != null) return;
    final held = await getHeldOrder();
    if (held == null || _hold != null || isDisposed) return;
    _hold = held;
    _onHold.add(held);
  }

  /// Let the whole hold go. True only when it is gone; a booked hold is never
  /// released.
  Future<bool> release() async =>
      jBool(jGet(
        await run('group.release', const <String, Object?>{}),
        'released',
      )) ==
      true;

  /// Switch between the same seat for every performance and a choice per
  /// performance. The selection is cleared. True when the mode changed.
  Future<bool> setSelectionMode(SeatLayerRunSelectionMode mode) async =>
      jBool(jGet(
        await run('group.setSelectionMode', <String, Object?>{
          'mode': mode.raw,
        }),
        'changed',
      )) ==
      true;

  /// Your server booked [operationId]: the page shows it booked and never
  /// releases it. Call it only after your server has booked.
  Future<SeatLayerRunBookedStatus> markBooked({String? operationId}) async {
    final result = await run('group.markBooked', <String, Object?>{
      if (operationId != null) 'operationId': operationId,
    });
    return SeatLayerRunBookedStatus(
      jStr(jGet(result, 'status')) ?? SeatLayerRunBookedStatus.pending.raw,
    );
  }

  /// The room the system takes around the page, in logical pixels: the page
  /// keeps its cart clear of it. Null clears it. Only a page that lists
  /// `group.setViewportInsets` in its commands takes it; an older one answers
  /// `unsupported_command`.
  Future<void> setViewportInsets(EdgeInsets? insets) async {
    await run(
      'group.setViewportInsets',
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

  /// Tell the page the app went to the background or came back. Coming back,
  /// the page re-reads the hold; the answer says whether it is still held.
  Future<bool?> setForeground(bool foreground) async => jBool(jGet(
        await run('group.lifecycle', <String, Object?>{
          'state': foreground ? 'foreground' : 'background',
        }),
        'held',
      ));

  /// A page that goes away takes its run, status and hold with it; the next
  /// page reports its own.
  @override
  void detachTransport() {
    super.detachTransport();
    _descriptor = null;
    _selectionMode = null;
    _status = null;
    _hold = null;
  }

  /// Tear the page down. A hold not handed off or booked is released first;
  /// one that was is kept, for your server to book.
  Future<void> destroy() async {
    try {
      await run('group.destroy', const <String, Object?>{});
    } catch (_) {
      // Best effort: the page may already be gone.
    }
    detachTransport();
  }

  @override
  void dispose() {
    if (isDisposed) return;
    super.dispose();
    _onRun.close();
    _onStatus.close();
    _onHold.close();
    _onHoldExpired.close();
    _onContinue.close();
    _onBooked.close();
    _onSelectionMode.close();
    _onAccessExpired.close();
    _onAccessUnavailable.close();
  }
}
