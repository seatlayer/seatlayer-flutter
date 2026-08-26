import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bridge/bridge_client.dart';
import '../json.dart';
import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_controller.dart';
import '../seat_layer_error.dart';
import 'picker_models.dart';
import 'picker_options.dart';

/// State and actions for one high-level picker session.
///
/// One controller binds to one event and one mounted runtime at a time. All
/// inventory-changing operations are serialized, and concurrent checkout calls
/// share one Future so a double tap cannot create two holds.
class SeatLayerPickerController extends ValueNotifier<SeatLayerPickerState> {
  SeatLayerPickerController({SeatLayerController? mapController})
      : mapController = mapController ?? SeatLayerController(),
        _ownsMapController = mapController == null,
        super(const SeatLayerPickerState.initializing()) {
    _bridgeSubscription = this.mapController.onBridgeEvent.listen(
          _onBridgeEvent,
        );
    _readySubscription = this.mapController.onReady.listen(
          (info) => _callbacks.onReady?.call(info),
        );
    _accessExpiredSubscription = this.mapController.onBuyerAccessExpired.listen(
          (event) => _callbacks.onAccessExpired?.call(event),
        );
    _accessUnavailableSubscription = this
        .mapController
        .onBuyerAccessUnavailable
        .listen((event) => _callbacks.onAccessUnavailable?.call(event));
    _selectionUnavailableSubscription = this
        .mapController
        .onSelectedObjectsUnavailable
        .listen((event) => _callbacks.onSelectedObjectUnavailable?.call(event));
    _holdExpiredSubscription = this.mapController.onHoldExpired.listen((_) {
      _callbacks.onHoldExpired?.call();
    });
    _generalAdmissionSubscription = this.mapController.onGAClick.listen((area) {
      if (!_options.readOnly) {
        value = value.withGeneralAdmissionCandidate(area);
      }
    });
    _errorSubscription = this.mapController.onError.listen((error) {
      _callbacks.onError?.call(error);
      if (value.phase == SeatLayerPickerPhase.initializing) {
        value = value.withError(error);
      } else {
        value = value.withActionError(error);
      }
    });
  }

  final SeatLayerController mapController;
  final bool _ownsMapController;

  late final StreamSubscription<EventSignal> _bridgeSubscription;
  late final StreamSubscription<ReadyInfo> _readySubscription;
  late final StreamSubscription<BuyerAccessExpiredEvent>
      _accessExpiredSubscription;
  late final StreamSubscription<BuyerAccessUnavailableEvent>
      _accessUnavailableSubscription;
  late final StreamSubscription<SelectedObjectUnavailableEvent>
      _selectionUnavailableSubscription;
  late final StreamSubscription<void> _holdExpiredSubscription;
  late final StreamSubscription<GAArea> _generalAdmissionSubscription;
  late final StreamSubscription<SeatLayerError> _errorSubscription;

  SeatLayerPickerOptions _options = const SeatLayerPickerOptions();
  SeatLayerPickerCallbacks _callbacks = const SeatLayerPickerCallbacks();
  String? _eventKey;
  bool _runtimeAttached = false;
  bool _disposed = false;
  bool _closing = false;
  Future<void> _actionTail = Future<void>.value();
  Future<SeatLayerCheckoutHandoff>? _checkoutInFlight;
  Future<void>? _closeInFlight;
  int _reloadGeneration = 0;
  final Map<int, List<Completer<void>>> _revisionWaiters =
      <int, List<Completer<void>>>{};

  SeatLayerPickerState get state => value;
  SeatLayerPickerOptions get options => _options;
  bool get canCheckout => value.canCheckout && !_options.readOnly;

  @internal
  int get reloadGeneration => _reloadGeneration;

  /// Recreate the embedded runtime after a load or compatibility failure.
  ///
  /// Selection and hold recovery remain runtime/server-authoritative; the SDK
  /// does not pretend stale local state survived a failed transport.
  Future<void> retry() {
    if (_disposed) return Future<void>.error(const SeatLayerError.destroyed());
    if (value.phase == SeatLayerPickerPhase.closed) {
      return Future<void>.error(const SeatLayerError.destroyed());
    }
    return _serialize(() async {
      // A failed handshake has no live picker to clean up. If the runtime did
      // reach Ready (for example access later became unavailable), acknowledge
      // destroy before the ValueKey swap removes its WebView so a picker-owned
      // hold is not left solely to TTL cleanup.
      if (mapController.isReady) {
        try {
          await mapController.runBridgeCommand('picker.destroy');
        } catch (_) {
          // Retry remains recoverable when the old runtime is already gone.
        }
      }
      _reloadGeneration += 1;
      value = const SeatLayerPickerState.initializing();
    });
  }

  @internal
  void attach({
    required SeatLayerConfiguration configuration,
    required SeatLayerPickerOptions options,
    SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
  }) {
    if (_disposed) throw StateError('SeatLayerPickerController is disposed');
    if (_runtimeAttached) {
      throw StateError(
        'A SeatLayerPickerController can drive only one mounted picker at a time',
      );
    }
    if (_eventKey != null && _eventKey != configuration.event) {
      throw StateError(
        'A SeatLayerPickerController is bound to event $_eventKey and cannot '
        'move to ${configuration.event}',
      );
    }
    _eventKey = configuration.event;
    _options = options;
    _callbacks = callbacks;
    _runtimeAttached = true;
    _closing = false;
    if (value.phase == SeatLayerPickerPhase.closed ||
        value.phase == SeatLayerPickerPhase.failed) {
      value = const SeatLayerPickerState.initializing();
    }
  }

  @internal
  void updateBinding({
    required SeatLayerPickerOptions options,
    required SeatLayerPickerCallbacks callbacks,
  }) {
    _options = options;
    _callbacks = callbacks;
    if (options.readOnly && value.generalAdmissionCandidate != null) {
      value = value.withGeneralAdmissionCandidate(null);
    }
  }

  @internal
  void detach() {
    _runtimeAttached = false;
  }

  void _onBridgeEvent(EventSignal event) {
    if (event.name != 'picker.snapshot' && event.name != 'sys.ready') return;
    final raw = jGet(event.payload, 'snapshot') ??
        (event.name == 'picker.snapshot' ? event.payload : null);
    final snapshot = SeatLayerPickerSnapshot.fromJson(raw);
    if (snapshot != null) _applySnapshot(snapshot);
  }

  void _applySnapshot(SeatLayerPickerSnapshot snapshot) {
    final current = value.snapshot;
    if (current != null &&
        current.sessionId == snapshot.sessionId &&
        snapshot.revision <= current.revision) {
      return;
    }

    final previousSelection = value.selection;
    final previousValidity = current?.selectionValidity;
    final previousHold = value.hold;
    value = value.applying(snapshot);

    if (!_sameSelection(previousSelection, snapshot.selection)) {
      _callbacks.onSelectionChanged?.call(snapshot.selection);
    }
    if (snapshot.selectionValidity != null &&
        !_sameValidity(previousValidity, snapshot.selectionValidity)) {
      _callbacks.onSelectionValidityChanged?.call(snapshot.selectionValidity!);
    }
    final nextHold = snapshot.hold.active ? snapshot.hold : null;
    if (previousHold?.active != nextHold?.active ||
        previousHold?.owner != nextHold?.owner ||
        previousHold?.expiresAt != nextHold?.expiresAt) {
      _callbacks.onHoldChanged?.call(nextHold, value.checkoutHandoff);
    }

    final completed = _revisionWaiters.keys
        .where((target) => target <= snapshot.revision)
        .toList(growable: false);
    for (final target in completed) {
      for (final waiter in _revisionWaiters.remove(target)!) {
        if (!waiter.isCompleted) waiter.complete();
      }
    }
  }

  Future<void> synchronize() => _serialize(() async {
        value = value.withBusy(SeatLayerPickerBusyAction.synchronizing);
        try {
          final result =
              await mapController.runBridgeCommand('picker.getSnapshot');
          _applySnapshotFromResult(result);
        } catch (error) {
          value = value.snapshot == null
              ? value.withError(error)
              : value.withActionError(error);
          rethrow;
        }
      });

  Future<void> clearSelection() => _inventoryMutation(
        'picker.clearSelection',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> removeObject(String objectId) {
    final line = value.cartLines
        .where(
          (candidate) =>
              candidate.objectId == objectId || candidate.label == objectId,
        )
        .firstOrNull;
    return _inventoryMutation(
        'picker.removeCartLine',
        <String, Object?>{
          'label': line?.label ?? objectId,
        },
        SeatLayerPickerBusyAction.updatingSelection);
  }

  Future<void> setSeatTier(String seatId, String? tierId) => _inventoryMutation(
        'picker.setSeatTier',
        <String, Object?>{'seatId': seatId, 'tierId': tierId},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Select objects by their stable labels through the picker-v2 runtime.
  Future<List<SelectedSeat>> selectObjects(List<String> objects) async {
    await _inventoryMutation(
      'picker.selectObjects',
      <String, Object?>{'objects': List<String>.of(objects)},
      SeatLayerPickerBusyAction.updatingSelection,
    );
    return value.selection;
  }

  /// Deselect objects by their stable labels.
  Future<void> deselectObjects(List<String> objects) => _inventoryMutation(
        'picker.deselectObjects',
        <String, Object?>{'objects': List<String>.of(objects)},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Select every eligible object in the supplied categories.
  Future<List<SelectedSeat>> selectCategories(
    List<String> categoryKeys,
  ) async {
    await _inventoryMutation(
      'picker.selectCategories',
      <String, Object?>{
        'categoryKeys': List<String>.of(categoryKeys),
      },
      SeatLayerPickerBusyAction.updatingSelection,
    );
    return value.selection;
  }

  /// Deselect every selected object in the supplied categories.
  Future<void> deselectCategories(List<String> categoryKeys) =>
      _inventoryMutation(
        'picker.deselectCategories',
        <String, Object?>{
          'categoryKeys': List<String>.of(categoryKeys),
        },
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Restrict canvas selection to [objects], or pass `null` to remove it.
  Future<void> setSelectableObjects(List<String>? objects) =>
      _inventoryMutation(
        'picker.setSelectableObjects',
        <String, Object?>{
          'objects': objects == null ? null : List<String>.of(objects),
        },
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Change the maximum number of tickets the buyer may select.
  Future<void> setMaxSelection(int maximum) {
    if (maximum < 1) {
      return Future<void>.error(ArgumentError.value(maximum, 'maximum'));
    }
    return _inventoryMutation(
      'picker.setMaxSelection',
      <String, Object?>{'maxSelection': maximum},
      SeatLayerPickerBusyAction.updatingSelection,
    );
  }

  /// Filter the visible categories; an empty set clears the filter.
  Future<void> setCategoryFilter(
    Set<String> categoryKeys, {
    bool focus = false,
  }) =>
      _mutation(
        'picker.setCategoryFilter',
        <String, Object?>{
          'categoryKeys': categoryKeys.isEmpty ? null : categoryKeys.toList(),
          if (focus) 'focus': true,
        },
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> setLimitedViewHidden(bool hidden) => _mutation(
        'picker.setLimitedViewFilter',
        <String, Object?>{'on': hidden},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> setAccessibilityFilter(Set<String> types) => _mutation(
        'picker.setAccessibilityFilter',
        <String, Object?>{'types': types.isEmpty ? null : types.toList()},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> focusSection(String sectionId) => _mutation(
        'picker.focusSection',
        <String, Object?>{'sectionId': sectionId},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> overview() => _mutation(
        'picker.overview',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> setRung(String rung) => _mutation(
        'picker.setRung',
        <String, Object?>{'rung': rung},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> setFloor(String floorId) => _mutation(
        'picker.setFloor',
        <String, Object?>{'floorId': floorId},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> setColorblindSafe(bool enabled) => _mutation(
        'picker.setColorblindSafe',
        <String, Object?>{'on': enabled},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> setViewMode(SeatLayerViewMode mode) => _mutation(
        'picker.setViewMode',
        <String, Object?>{'mode': mode.raw},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Switch between the flat map and SeatLayer's real interactive venue 3D.
  ///
  /// [flyToSeatId] enters 3D at a specific seat (or retargets the existing
  /// scene) without rebuilding it. This is distinct from [setViewMode], which
  /// controls only the legacy 2D canvas projection.
  Future<void> setBuyerView(
    SeatLayerBuyerView view, {
    String? flyToSeatId,
    bool resetView = false,
  }) =>
      _mutation(
        'picker.setBuyerView',
        <String, Object?>{
          'view': view.raw,
          if (flyToSeatId != null) 'flyToSeatId': flyToSeatId,
          if (resetView) 'resetView': true,
        },
        SeatLayerPickerBusyAction.changingView,
      );

  /// Enter the real venue scene and fly to [seat].
  Future<void> showSeatIn3D(SelectedSeat seat) => setBuyerView(
        SeatLayerBuyerView.venue3D,
        flyToSeatId: seat.id,
      );

  /// Open the authored or chart-derived 360° view-from-seat surface.
  Future<void> openSeatView(SelectedSeat seat) => _mutation(
        'picker.openSeatView',
        <String, Object?>{'seatId': seat.id},
        SeatLayerPickerBusyAction.changingView,
      );

  /// Choose whether a primary drag rotates or moves the real 3D venue.
  Future<void> set3DNavigationMode(SeatLayer3DNavigationMode mode) => _mutation(
        'picker.setVenue3DNavigationMode',
        <String, Object?>{'mode': mode.raw},
        SeatLayerPickerBusyAction.changingView,
      );

  Future<void> zoomIn() => _mutation(
        'picker.zoomIn',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> zoomOut() => _mutation(
        'picker.zoomOut',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> zoomToFit() => _mutation(
        'picker.zoomToFit',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  Future<void> bestAvailable({
    required int quantity,
    String? categoryKey,
    String? zoneId,
    bool preferPremium = false,
  }) {
    if (quantity < 1) return Future<void>.error(ArgumentError.value(quantity));
    return _inventoryMutation(
        'picker.bestAvailable',
        <String, Object?>{
          'qty': quantity,
          if (categoryKey != null) 'categoryKey': categoryKey,
          if (zoneId != null) 'zoneId': zoneId,
          'preferPremium': preferPremium,
          if (_options.holdTtl != null)
            'ttlMs': _options.holdTtl!.inMilliseconds,
        },
        SeatLayerPickerBusyAction.findingBestAvailable);
  }

  Future<void> setGeneralAdmissionQuantity({
    required String areaId,
    required Map<String?, int> quantitiesByTier,
  }) {
    final requested = quantitiesByTier.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);
    if (requested.isEmpty ||
        quantitiesByTier.values.any((quantity) => quantity < 0)) {
      return Future<void>.error(
        ArgumentError.value(quantitiesByTier, 'quantitiesByTier'),
      );
    }
    final rejected = _rejectReadOnly<void>('picker.holdGA');
    if (rejected != null) return rejected;
    return _serialize(() async {
      value = value.withBusy(SeatLayerPickerBusyAction.creatingHold);
      try {
        for (final entry in requested) {
          final result = await mapController.runBridgeCommand(
            'picker.holdGA',
            <String, Object?>{
              'areaId': areaId,
              'qty': entry.value,
              if (entry.key != null) 'tierId': entry.key,
              if (_options.holdTtl != null)
                'ttlMs': _options.holdTtl!.inMilliseconds,
            },
          );
          _applySnapshotFromResult(result);
          final revision = jInt(jGet(result, 'revision'));
          if (revision != null) await _awaitRevision(revision);
        }
        value = value.withGeneralAdmissionCandidate(null);
      } catch (error) {
        value = value.withActionError(error);
        rethrow;
      }
    });
  }

  void dismissGeneralAdmissionCandidate() {
    value = value.withGeneralAdmissionCandidate(null);
  }

  void dismissError() {
    if (value.error != null) value = value.withoutError();
  }

  Future<void> setTableQuantity({
    required String label,
    required int quantity,
  }) {
    if (quantity < 1) {
      return Future<void>.error(ArgumentError.value(quantity, 'quantity'));
    }
    return _inventoryMutation(
      'picker.setTableQuantity',
      <String, Object?>{
        'label': label,
        'quantity': quantity,
        if (_options.holdTtl != null) 'ttlMs': _options.holdTtl!.inMilliseconds,
      },
      SeatLayerPickerBusyAction.updatingSelection,
    );
  }

  /// Restore a caller-persisted hold as host-owned inventory.
  ///
  /// Prefer [SeatLayerPickerOptions.initialHoldId] for restoration during
  /// startup. This explicit action is available to custom component flows.
  Future<void> resumeHold(String holdId) {
    if (holdId.isEmpty) {
      return Future<void>.error(ArgumentError.value(holdId, 'holdId'));
    }
    return _inventoryMutation(
      'picker.resumeHold',
      <String, Object?>{'holdId': holdId},
      SeatLayerPickerBusyAction.creatingHold,
    );
  }

  Future<void> extendHold() => _inventoryMutation(
        'picker.extendHold',
        <String, Object?>{
          if (_options.holdTtl != null)
            'ttlMs': _options.holdTtl!.inMilliseconds,
        },
        SeatLayerPickerBusyAction.creatingHold,
      );

  Future<SeatLayerCheckoutHandoff> checkout() {
    final rejected =
        _rejectReadOnly<SeatLayerCheckoutHandoff>('picker.continue');
    if (rejected != null) return rejected;
    final current = _checkoutInFlight;
    if (current != null) return current;
    final future = _serialize(() async {
      value = value.withBusy(SeatLayerPickerBusyAction.creatingHold);
      try {
        final result = await mapController.runBridgeCommand(
          'picker.continue',
          <String, Object?>{
            if (_options.holdTtl != null)
              'ttlMs': _options.holdTtl!.inMilliseconds,
          },
        );
        _applySnapshotFromResult(result);
        final revision = jInt(jGet(result, 'revision'));
        if (revision != null) await _awaitRevision(revision);
        final handoff = SeatLayerCheckoutHandoff.fromJson(
          jGet(result, 'handoff'),
        );
        if (handoff == null) {
          throw const SeatLayerError.decoding(
            'picker.continue returned no checkout handoff',
          );
        }
        value = value.withHandoff(handoff);
        _callbacks.onHoldChanged?.call(value.hold, handoff);
        return handoff;
      } catch (error) {
        value = value.withActionError(error);
        rethrow;
      }
    });
    _checkoutInFlight = future;
    unawaited(
      future.then<void>(
        (_) => _clearCheckoutFlight(future),
        onError: (Object _, StackTrace __) => _clearCheckoutFlight(future),
      ),
    );
    return future;
  }

  /// Reject a checkout handoff that the host could not accept.
  ///
  /// The runtime releases inventory only when [handoff] identifies the exact
  /// hold handed off by this picker session. This safety action remains
  /// available in read-only mode.
  Future<void> rejectCheckoutHandoff(SeatLayerCheckoutHandoff handoff) async {
    await _mutation(
      'picker.rejectHandoff',
      <String, Object?>{'holdId': handoff.holdId},
      SeatLayerPickerBusyAction.releasingHold,
    );
    if (value.checkoutHandoff?.holdId == handoff.holdId) {
      value = value.withoutHandoff();
    }
  }

  Future<void> releasePickerOwnedHold() {
    if (!value.hasPickerOwnedHold) return Future<void>.value();
    return _mutation(
      'picker.abort',
      null,
      SeatLayerPickerBusyAction.releasingHold,
    );
  }

  Future<void> setLifecycle(String state) => _mutation(
        'picker.lifecycle',
        <String, Object?>{
          'state': state == 'resumed' || state == 'foreground'
              ? 'foreground'
              : 'background',
        },
        SeatLayerPickerBusyAction.synchronizing,
      );

  /// Tear down the picker runtime and await its acknowledgement.
  ///
  /// Use [close] for ordinary buyer dismissal. [destroy] exists for custom
  /// lifecycle owners that are replacing the embedded runtime.
  Future<void> destroy() => _serialize(() async {
        if (value.phase == SeatLayerPickerPhase.closed) return;
        value = value.withBusy(SeatLayerPickerBusyAction.releasingHold);
        try {
          await mapController.runBridgeCommand('picker.destroy');
          value = value.closed();
          _callbacks.onClosed?.call(SeatLayerPickerCloseReason.programmatic);
        } catch (error) {
          value = value.withActionError(error);
          rethrow;
        }
      });

  Future<void> close({
    SeatLayerPickerCloseReason reason = SeatLayerPickerCloseReason.programmatic,
  }) {
    final current = _closeInFlight;
    if (current != null) return current;
    final future = _serialize(() async {
      if (_closing || value.phase == SeatLayerPickerPhase.closed) return;
      _closing = true;
      try {
        if (value.hasPickerOwnedHold) {
          final result = await mapController.runBridgeCommand('picker.abort');
          _applySnapshotFromResult(result);
        }
        value = value.closed();
        _callbacks.onClosed?.call(reason);
      } finally {
        _closing = false;
      }
    });
    _closeInFlight = future;
    unawaited(
      future.then<void>(
        (_) => _clearCloseFlight(future),
        onError: (Object _, StackTrace __) => _clearCloseFlight(future),
      ),
    );
    return future;
  }

  void _clearCheckoutFlight(Future<SeatLayerCheckoutHandoff> future) {
    if (identical(_checkoutInFlight, future)) _checkoutInFlight = null;
  }

  void _clearCloseFlight(Future<void> future) {
    if (identical(_closeInFlight, future)) _closeInFlight = null;
  }

  Future<void> _mutation(
    String command,
    Object? payload,
    SeatLayerPickerBusyAction busy,
  ) =>
      _serialize(() async {
        value = value.withBusy(busy);
        try {
          final result = await mapController.runBridgeCommand(command, payload);
          _applySnapshotFromResult(result);
          final revision = jInt(jGet(result, 'revision'));
          if (revision != null) await _awaitRevision(revision);
          if (value.busyAction != SeatLayerPickerBusyAction.none) {
            final snapshot = value.snapshot;
            if (snapshot != null) value = value.applying(snapshot);
          }
        } catch (error) {
          value = value.withActionError(error);
          rethrow;
        }
      });

  Future<void> _inventoryMutation(
    String command,
    Object? payload,
    SeatLayerPickerBusyAction busy,
  ) {
    final rejected = _rejectReadOnly<void>(command);
    return rejected ?? _mutation(command, payload, busy);
  }

  Future<T>? _rejectReadOnly<T>(String command) {
    if (!_options.readOnly) return null;
    final error = SeatLayerError.readOnly(command);
    value = value.withActionError(error);
    _callbacks.onError?.call(error);
    return Future<T>.error(error);
  }

  /// Keep a host callback failure visible after best-effort handoff rejection.
  @internal
  void reportActionError(Object error) {
    if (_disposed) return;
    value = value.withActionError(error);
    if (error is SeatLayerError) _callbacks.onError?.call(error);
  }

  void _applySnapshotFromResult(Object? result) {
    final snapshot = SeatLayerPickerSnapshot.fromJson(
      jGet(result, 'snapshot') ??
          (jGet(result, 'sessionId') != null ? result : null),
    );
    if (snapshot != null) _applySnapshot(snapshot);
  }

  Future<void> _awaitRevision(int target) async {
    if (value.revision >= target) return;
    final waiter = Completer<void>();
    (_revisionWaiters[target] ??= <Completer<void>>[]).add(waiter);
    try {
      await waiter.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      final result = await mapController.runBridgeCommand('picker.getSnapshot');
      _applySnapshotFromResult(result);
      if (value.revision < target) {
        throw SeatLayerError.decoding(
          'picker state stopped at revision ${value.revision}; expected $target',
        );
      }
    } finally {
      _revisionWaiters[target]?.remove(waiter);
      if (_revisionWaiters[target]?.isEmpty ?? false) {
        _revisionWaiters.remove(target);
      }
    }
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    if (_disposed) return Future<T>.error(const SeatLayerError.destroyed());
    final completer = Completer<T>();
    _actionTail = _actionTail.then((_) async {
      if (_disposed) throw const SeatLayerError.destroyed();
      try {
        completer.complete(await action());
      } catch (error, stack) {
        if (!completer.isCompleted) completer.completeError(error, stack);
      }
    }).catchError((Object _) {
      // Keep the queue usable after an action fails; its own completer already
      // carries the error to the caller.
    });
    return completer.future;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final waiters in _revisionWaiters.values) {
      for (final waiter in waiters) {
        if (!waiter.isCompleted) {
          waiter.completeError(const SeatLayerError.destroyed());
        }
      }
    }
    _revisionWaiters.clear();
    unawaited(_bridgeSubscription.cancel());
    unawaited(_readySubscription.cancel());
    unawaited(_accessExpiredSubscription.cancel());
    unawaited(_accessUnavailableSubscription.cancel());
    unawaited(_selectionUnavailableSubscription.cancel());
    unawaited(_holdExpiredSubscription.cancel());
    unawaited(_generalAdmissionSubscription.cancel());
    unawaited(_errorSubscription.cancel());
    if (_ownsMapController) mapController.dispose();
    super.dispose();
  }
}

bool _sameSelection(List<SelectedSeat> left, List<SelectedSeat> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i].id != right[i].id || left[i].tierId != right[i].tierId) {
      return false;
    }
  }
  return true;
}

bool _sameValidity(SelectionValidity? left, SelectionValidity? right) =>
    left?.isValid == right?.isValid &&
    left?.count == right?.count &&
    left?.required == right?.required &&
    left?.remaining == right?.remaining;

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
