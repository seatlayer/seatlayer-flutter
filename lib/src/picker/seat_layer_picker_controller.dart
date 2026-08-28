import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../bridge/bridge_client.dart';
import '../json.dart';
import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_controller.dart';
import '../seat_layer_error.dart';
import 'picker_chart_load.dart';
import 'picker_haptics.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'seat_layer_picker_theme.dart';

/// Advertised by a runtime that speaks the native-chrome contract, including
/// `picker.setThemeMode`'s optional map ground.
const String _nativeChromeContractCapability = 'native-chrome-contract-v1';

/// Advertised by a runtime that frames against host-reported viewport insets.
const String _viewportInsetsCapability = 'viewport-insets-v1';

/// Advertised by a runtime that hands its own chart-load beacon to the host.
const String _chartLoadTraceCapability = 'chart-load-trace-v1';


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
    _readySubscription = this.mapController.onReady.listen((info) {
      // T0 is the mount, not the handshake: the buyer's wait started when the
      // picker appeared. Frozen here rather than read when the trace arrives,
      // because the trace can land a frame or two later and that frame is not
      // part of what the buyer waited for.
      _readyInfo = info;
      _tapToReadyMs = _mountClock.elapsedMilliseconds;
      _callbacks.onReady?.call(info);
    });
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
      if (_options.haptics) {
        try {
          playHaptic(PickerHapticCue.holdExpired);
        } catch (_) {
          // A cue is a nicety; there is nothing a host could do about it.
        }
      }
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

  final StreamController<SeatLayerChartLoad> _chartLoads =
      StreamController<SeatLayerChartLoad>.broadcast();

  /// Started when the picker mounts; the clock `tapToReadyMs` is read off.
  final Stopwatch _mountClock = Stopwatch();
  int? _tapToReadyMs;
  ReadyInfo? _readyInfo;
  SeatLayerSeatView? _seatView;

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
  SeatLayerViewportInsets? _pendingViewportInsets;
  bool _cartSheetExpanded = false;
  bool _cartSheetInitialized = false;
  final Set<String> _confirmedLabels = <String>{};
  SelectedSeat? _confirmCardSeat;
  bool _hasPendingViewportInsets = false;
  SeatLayerViewportInsets? _sentViewportInsets;
  bool _hasSentViewportInsets = false;
  bool _viewportInsetsFlushScheduled = false;
  final Map<int, List<Completer<void>>> _revisionWaiters =
      <int, List<Completer<void>>>{};

  SeatLayerPickerState get state => value;
  SeatLayerPickerOptions get options => _options;
  /// Whether the buyer may hand this cart to checkout.
  ///
  /// False while a confirm card is open: the seat under it is already in the
  /// runtime's selection, so without this the buyer could check out a seat
  /// they were still being asked about, by pressing a button behind the scrim.
  bool get canCheckout =>
      value.canCheckout && !_options.readOnly && seatAwaitingConfirmation == null;

  /// The seat a confirm card is standing over, unanswered.
  ///
  /// The runtime has no notion of an unconfirmed selection: a tapped seat is
  /// in `selection` — and therefore in the cart, the ticket count and the
  /// total — from the moment it is tapped. The confirm card is native chrome
  /// drawn over that, so without this the buyer sees `1 ticket · €40` and a
  /// live Continue behind a card that is still asking whether they want the
  /// seat at all.
  ///
  /// Reported by whichever chrome is actually asking, so it is null in a
  /// composed layout that shows no card — a seat nobody is asking about is
  /// simply in the cart.
  SelectedSeat? get seatAwaitingConfirmation => _confirmCardSeat;

  /// The seat the picker would ask about next, if it asks at all.
  ///
  /// Null for a read-only session, for `confirmSelection: false`, once a hold
  /// exists, and when every selected seat has been answered for.
  @internal
  SelectedSeat? get unansweredSeat {
    if (_options.readOnly || !_options.confirmSelection) return null;
    if (value.hold != null) return null;
    for (final seat in value.selection.reversed) {
      if (!_confirmedLabels.contains(seat.label)) return seat;
    }
    return null;
  }

  /// Tell the controller which seat the open confirm card is showing.
  ///
  /// Called from the chrome's build, so it deliberately does not notify: the
  /// widgets that read it are built after it in the same pass, and every one
  /// of them rebuilds with the layout that reports it.
  @internal
  void setConfirmCardSeat(SelectedSeat? seat) => _confirmCardSeat = seat;

  /// Record that the buyer answered for [label], and take its card down.
  @internal
  void markSeatAnswered(String label) {
    if (_disposed || !_confirmedLabels.add(label)) return;
    if (_confirmCardSeat?.label == label) _confirmCardSeat = null;
    notifyListeners();
  }

  /// The cart the buyer has actually agreed to.
  ///
  /// [SeatLayerPickerState.cartLines] less the seat whose card is still open,
  /// matched on the runtime's own seat id where it gave one and on the
  /// inventory label otherwise. Use it — and [confirmedTicketCount] and
  /// [confirmedCartTotal] — for anything the buyer reads as a commitment.
  List<SeatLayerCheckoutLineItem> get confirmedCartLines {
    final pending = seatAwaitingConfirmation;
    if (pending == null) return value.cartLines;
    return List<SeatLayerCheckoutLineItem>.unmodifiable(
      value.cartLines.where(
        (line) => line.seatId == null
            ? line.label != pending.label
            : line.seatId != pending.id,
      ),
    );
  }

  /// How many tickets the buyer has agreed to.
  int get confirmedTicketCount => seatAwaitingConfirmation == null
      ? (value.snapshot?.ticketCount ?? value.cartLines.length)
      : confirmedCartLines.fold<int>(0, (sum, line) => sum + line.quantity);

  /// What the buyer has agreed to, in the cart's currency.
  double get confirmedCartTotal => seatAwaitingConfirmation == null
      ? (value.snapshot?.cartTotal ??
          value.cartLines.fold<double>(0, (sum, line) => sum + line.total))
      : confirmedCartLines.fold<double>(0, (sum, line) => sum + line.total);

  /// Whether the buyer has the cart sheet open.
  ///
  /// Deliberately here and not in the chrome's own widget state. A theme flip,
  /// a host rebuilding its route, a snapshot arriving — any of them can give
  /// the layout a fresh [State], and an expanded sheet that snaps shut takes
  /// the buyer's place in their own cart with it. The controller outlives all
  /// of that, and a composed layout reads the same value the drop-in does.
  bool get cartSheetExpanded => _cartSheetExpanded;

  /// Open or collapse the cart sheet.
  ///
  /// Notifies listeners without touching [value]: the sheet is chrome, not
  /// picker state, and nothing about it belongs in a snapshot.
  void setCartSheetExpanded(bool expanded) {
    if (_disposed || _cartSheetExpanded == expanded) return;
    _cartSheetExpanded = expanded;
    _cartSheetInitialized = true;
    notifyListeners();
  }

  @internal
  int get reloadGeneration => _reloadGeneration;

  /// Recreate the embedded runtime after a load or compatibility failure.
  ///
  /// Selection and hold recovery remain runtime/server-authoritative; the SDK
  /// does not pretend stale local state survived a failed transport.
  /// Decides which haptic each snapshot has earned. Pure and stateful — the
  /// judgement is the interesting part, and it is only testable apart from the
  /// platform channel.
  final PickerHapticsPolicy _haptics = PickerHapticsPolicy();

  /// The seam the haptics tests replace. A platform channel cannot be asserted
  /// against in a widget test, and a policy that fired through one directly
  /// would be testable only by not testing it.
  @visibleForTesting
  void Function(PickerHapticCue cue) playHaptic = playPickerHaptic;

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
      _haptics.reset();
      _forgetViewportInsets();
      _seatView = null;
      // A retry is a second open, and its own wait starts here.
      _tapToReadyMs = null;
      _readyInfo = null;
      _mountClock
        ..reset()
        ..start();
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
    // T0 for `tapToReadyMs`. Only the first mount starts it: a controller
    // handed to a second scope is a re-parent, not a second open, and
    // restarting here would report the re-parent as the buyer's wait.
    if (!_mountClock.isRunning && _tapToReadyMs == null) _mountClock.start();
    if (!_cartSheetInitialized) {
      _cartSheetInitialized = true;
      _cartSheetExpanded = !options.panelInitiallyCollapsed;
    }
    _closing = false;
    if (value.phase == SeatLayerPickerPhase.closed ||
        value.phase == SeatLayerPickerPhase.failed) {
      _haptics.reset();
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
    if (event.name == 'telemetry.chartLoad') {
      _onChartLoadTrace(event.payload);
      return;
    }
    if (event.name == 'seatView.changed') {
      _onSeatViewChanged(event.payload);
      return;
    }
    if (event.name != 'picker.snapshot' && event.name != 'sys.ready') return;
    final raw = jGet(event.payload, 'snapshot') ??
        (event.name == 'picker.snapshot' ? event.payload : null);
    final snapshot = SeatLayerPickerSnapshot.fromJson(raw);
    if (snapshot != null) _applySnapshot(snapshot);
  }

  /// One chart load, as the runtime measured it and as this SDK did.
  ///
  /// Broadcast, so several listeners can watch it, and it emits nothing at all
  /// on a runtime that does not advertise `chart-load-trace-v1` — the SDK never
  /// synthesises a trace it was not given. Fires once per render attempt,
  /// success or failure.
  ///
  /// A late listener misses the load it was late for; the drop-in's
  /// [SeatLayerPickerCallbacks.onChartLoad] is bound before the runtime mounts
  /// and is the surface most hosts want.
  Stream<SeatLayerChartLoad> get onChartLoad => _chartLoads.stream;

  /// What the 2D "View from here" panorama is showing, or null when it is shut.
  ///
  /// Populated only on a runtime advertising `native-seat-view-chrome-v1`,
  /// which is also the runtime whose own header, caption and badge this SDK
  /// asks to be suppressed — so the words are drawn once, natively, and never
  /// twice. Notifies listeners, so chrome bound to the controller repaints.
  SeatLayerSeatView? get seatView =>
      supportsNativeSeatViewChrome ? _seatView : null;

  /// Whether the mounted runtime hands over the panorama's own words.
  bool get supportsNativeSeatViewChrome {
    final bundle = mapController.bundleInfo;
    return bundle != null &&
        bundle.supportsCapability(seatLayerSeatViewChromeCapability);
  }

  void _onSeatViewChanged(Object? payload) {
    if (_disposed || !supportsNativeSeatViewChrome) return;
    final next = SeatLayerSeatView.fromJson(jGet(payload, 'seatView'));
    if (_seatView == next) return;
    _seatView = next;
    notifyListeners();
  }

  void _onChartLoadTrace(Object? payload) {
    if (_disposed) return;
    final bundle = mapController.bundleInfo;
    // Capability-gated consumption: a runtime that has not said it speaks this
    // is not read for it, whatever happens to be on the wire.
    if (bundle == null ||
        !bundle.supportsCapability(_chartLoadTraceCapability)) {
      return;
    }
    final trace = SeatLayerChartLoadTrace.fromJson(jGet(payload, 'trace'));
    if (trace == null) return;
    final load = SeatLayerChartLoad(
      trace: trace,
      tapToReadyMs: _tapToReadyMs,
      ready: _readyInfo,
    );
    _callbacks.onChartLoad?.call(load);
    if (_chartLoads.hasListener) _chartLoads.add(load);
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
    // A seat that left the selection takes its answer with it, so re-picking
    // it asks again rather than joining the cart silently.
    final live = snapshot.selection.map((seat) => seat.label).toSet();
    _confirmedLabels.removeWhere((label) => !live.contains(label));
    if (_confirmCardSeat != null && !live.contains(_confirmCardSeat!.label)) {
      _confirmCardSeat = null;
    }

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

    // Every cue comes from here, and only from here: the snapshot is the one
    // place selection, focus and hold are known to agree. Firing from the
    // per-event signals as well would buzz twice for one seat.
    if (_options.haptics) {
      for (final cue in _haptics.onSnapshot(snapshot)) {
        // A cue is a nicety; adopting the snapshot is not. Haptics reach a
        // platform channel, and a channel is not always there — a headless
        // test binding, a platform with no motor, an embedder that has torn
        // its messenger down. None of that is a reason to drop a snapshot the
        // buyer's seats depend on.
        try {
          playHaptic(cue);
        } catch (_) {
          // Silent by design: there is nothing a host could do about it.
        }
      }
    } else {
      // Keep the policy's memory current so turning haptics back on mid-session
      // does not replay everything that happened while it was off.
      _haptics.onSnapshot(snapshot);
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

  /// Draw only the floor [floorId].
  Future<void> setFloor(String floorId) => _mutation(
        'picker.setFloor',
        <String, Object?>{'floorId': floorId},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Draw every floor of the venue at once.
  ///
  /// The same command as [setFloor] with the runtime's own sentinel, so a
  /// host never has to know that `'all'` is a floor id the chart does not
  /// contain. Runtimes that do not report `floorMode` ignore it.
  Future<void> showAllFloors() => setFloor(seatLayerAllFloors);

  Future<void> setColorblindSafe(bool enabled) => _mutation(
        'picker.setColorblindSafe',
        <String, Object?>{'on': enabled},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Repaint the drawn map for [mode] without reloading the runtime.
  ///
  /// Pass null to hand the colours back to the chart. Runtimes that predate the
  /// command are left unchanged rather than failing the action, so a theme flip
  /// can never break an otherwise working session.
  ///
  /// [mapTheme] moves the map's own ground with the mode. It is needed because
  /// an explicit ground outranks a mode inside the runtime: a host that named
  /// map colours at boot — which this SDK does, frozen, so the venue matches
  /// the chrome it booted under — has pinned the canvas, and no number of mode
  /// changes can flip it afterwards. Sending the newly resolved colours with
  /// the mode re-inks the venue in place, keeping the selection, the focused
  /// section and the camera. It travels only to a runtime that advertises the
  /// contract; older ones receive the mode alone, which is what they have
  /// always received.
  Future<void> setThemeMode(
    SeatLayerThemeMode? mode, {
    SeatLayerMapThemeData? mapTheme,
  }) {
    final bundle = mapController.bundleInfo;
    if (bundle != null && !bundle.supportsCommand('picker.setThemeMode')) {
      return Future<void>.value();
    }
    final carriesGround = mapTheme != null &&
        bundle != null &&
        bundle.supportsCapability(_nativeChromeContractCapability);
    // Deliberately NOT a _mutation. Repainting changes no inventory and moves
    // no geometry, so parking the picker on `changingView` only greys the
    // chrome the buyer is looking at — and folding the reply's snapshot in
    // mid-flip is how a colours-only command came to move the rung, which
    // hides the dock, changes the insets the layout reports and re-frames the
    // camera off the buyer's seat. Whatever the repaint really changed still
    // arrives on the snapshot event stream, exactly as it does for
    // `picker.setViewportInsets`.
    return _serialize(() async {
      await mapController.runBridgeCommand(
        'picker.setThemeMode',
        <String, Object?>{
          'mode': mode?.raw,
          if (carriesGround) 'mapTheme': mapTheme.toBridgeConfig(),
        },
      );
    });
  }

  /// Tell the runtime how much of the map surface native chrome is covering.
  ///
  /// Persistent: the last value applies to every later fit and glide, so send
  /// a new one whenever the chrome moves — the dock arriving with a focused
  /// section, a sheet peeking, the rail hiding. Pass null to clear it and
  /// frame against the whole surface again.
  ///
  /// Nothing is sent to a runtime that does not advertise `viewport-insets-v1`
  /// and the command, which frames against the whole surface as it always has.
  /// Repeated identical values are dropped, and several calls inside one frame
  /// coalesce into the last, so a host may call this from every layout pass.
  ///
  /// This reports where furniture is; it changes no inventory and produces no
  /// busy state, because a buyer resizing a sheet must not see the picker go
  /// busy underneath them.
  Future<void> setViewportInsets(SeatLayerViewportInsets? insets) {
    if (!supportsViewportInsets) return Future<void>.value();
    final wanted = insets;
    _pendingViewportInsets = wanted;
    _hasPendingViewportInsets = true;
    if (_viewportInsetsFlushScheduled) return Future<void>.value();
    _viewportInsetsFlushScheduled = true;
    final completer = Completer<void>();
    // One send per frame. Native chrome settles over several layout passes —
    // the dock animating in while the sheet re-measures — and each pass would
    // otherwise mint its own command and its own map revision.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportInsetsFlushScheduled = false;
      if (!completer.isCompleted) {
        completer.complete(_flushViewportInsets());
      }
    });
    return completer.future;
  }

  /// Forget what was reported to a runtime that is going away.
  ///
  /// A fresh runtime frames against its whole surface until it is told
  /// otherwise, so the next report has to be sent even when the numbers have
  /// not moved.
  void _forgetViewportInsets() {
    _sentViewportInsets = null;
    _hasSentViewportInsets = false;
  }

  /// Whether the mounted runtime accepts [setViewportInsets].
  bool get supportsViewportInsets {
    final bundle = mapController.bundleInfo;
    return bundle != null &&
        bundle.supportsCapability(_viewportInsetsCapability) &&
        bundle.supportsCommand('picker.setViewportInsets');
  }

  Future<void> _flushViewportInsets() {
    if (_disposed || !_hasPendingViewportInsets) return Future<void>.value();
    final wanted = _pendingViewportInsets;
    _hasPendingViewportInsets = false;
    if (_hasSentViewportInsets && _sentViewportInsets == wanted) {
      return Future<void>.value();
    }
    _sentViewportInsets = wanted;
    _hasSentViewportInsets = true;
    return _serialize(() async {
      await mapController.runBridgeCommand(
        'picker.setViewportInsets',
        wanted == null
            ? <String, Object?>{'insets': null}
            : wanted.toBridgePayload(),
      );
    });
  }

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

  /// Enable or suppress pointer and keyboard interaction inside the map.
  ///
  /// The turnkey adaptive layout calls this automatically whenever native
  /// confirmation, quantity, loading, or error chrome owns the chart area.
  /// Custom layouts should do the same around any native overlay that covers a
  /// [SeatLayerPickerMap]. A visual [IgnorePointer] is not sufficient for an
  /// iOS platform view: WKWebView can otherwise receive the same physical tap
  /// beneath the Flutter overlay.
  ///
  /// Older compatible runtimes that do not advertise the command are left
  /// unchanged, preserving source compatibility while the Flutter hit-test
  /// guard remains in place as a best-effort fallback.
  Future<void> setMapInteractionEnabled(bool enabled) {
    final bundle = mapController.bundleInfo;
    if (bundle != null &&
        !bundle.supportsCommand('picker.setInteractionEnabled')) {
      return Future<void>.value();
    }
    return _serialize(() async {
      await mapController.runBridgeCommand(
        'picker.setInteractionEnabled',
        <String, Object?>{'enabled': enabled},
      );
    });
  }

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
    unawaited(_chartLoads.close());
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
