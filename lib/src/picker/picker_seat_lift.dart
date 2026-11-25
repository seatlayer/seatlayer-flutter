/// The map moves out from under the seat card, the way the web sheet does.
///
/// The phone seat card is a fixed bottom sheet (§3.8.2). The web picker keeps
/// the tapped seat and its card together by PANNING the map — x untouched,
/// zoom untouched, the seat landing at a constant fraction of the band left
/// clear above the sheet — and puts the map back when the card leaves, unless
/// the buyer has moved it themselves in between. Over the bridge that used to
/// be approximated with a viewport inset, which re-frames the whole section
/// and changes the zoom; `picker.frameSeat` is the pan itself.
library;

import 'dart:async';

import 'package:meta/meta.dart';

import '../bridge/bridge_protocol.dart';
import '../json.dart';
import '../seat_layer_error.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

/// The bridge command, named once so the gate and the send cannot drift.
@internal
const String seatLayerFrameSeatCommand = 'picker.frameSeat';

/// Where in the clear band the seat comes to rest. The web sheet's number.
const double seatLayerSheetSeatFraction = 0.48;

/// What the runtime answers a frame with.
@immutable
class SeatLayerSeatFrame {
  /// Creates a frame result.
  const SeatLayerSeatFrame({required this.dy, required this.gestures});

  /// The screen-space vertical pan the runtime asked of its map; 0 when it
  /// declined or the seat was already in place. A map at its edge moves less.
  final double dy;

  /// The runtime's count of the buyer's own camera moves, to hand back on a
  /// later frame so it can refuse once the buyer has taken the wheel.
  final int gestures;

  /// From the command's reply, or null for a reply that is not one.
  static SeatLayerSeatFrame? fromJson(Object? value) {
    final dy = jDouble(jGet(value, 'dy'));
    final gestures = jInt(jGet(value, 'gestures'));
    if (dy == null || gestures == null) return null;
    return SeatLayerSeatFrame(dy: dy, gestures: gestures);
  }
}

/// The one pan-only camera command.
extension SeatLayerPickerSeatFraming on SeatLayerPickerController {
  /// Whether the mounted runtime can pan a seat into place.
  ///
  /// Gated on the command being in the bundle's own `hello` table: it changes
  /// nothing a snapshot reports, so the command table is the whole contract.
  bool get supportsSeatFraming =>
      mapController.bundleInfo?.supportsCommand(seatLayerFrameSeatCommand) ==
      true;

  /// The page a pan is made on: null while none is up, and another one once it
  /// has been loaded again.
  @internal
  Object? get framingPage =>
      mapController.isReady ? value.snapshot?.sessionId : null;

  /// Pan — never zoom — so [seatId] rests at [fraction] of the band the
  /// reported viewport insets leave clear.
  ///
  /// Camera only: it selects nothing, holds nothing and carries no busy
  /// action. Pass the [gestures] a previous answer carried and the runtime
  /// refuses once the buyer has moved the map since. Answers null on a
  /// runtime that does not advertise the command, and on one that advertises
  /// it and still says `unsupported_command` — a phone that simply does not
  /// lift is not a failure the buyer has anything to do with.
  Future<SeatLayerSeatFrame?> frameSeat(
    String seatId, {
    double fraction = seatLayerSheetSeatFraction,
    bool animate = true,
    int? gestures,
  }) async {
    if (!supportsSeatFraming) return null;
    try {
      final result = await runPickerMutation(
        seatLayerFrameSeatCommand,
        <String, Object?>{
          'seatId': seatId,
          'fraction': fraction,
          'animate': animate,
          if (gestures != null) 'gestures': gestures,
        },
        SeatLayerPickerBusyAction.none,
      );
      return SeatLayerSeatFrame.fromJson(result);
    } on SeatLayerError catch (error) {
      if (error.code != BridgeErrorCode.unsupportedCommand) rethrow;
      if (identical(value.error, error)) value = value.withoutError();
      return null;
    }
  }
}

/// Where, within the band the runtime knows about, the seat has to rest so
/// that it sits at [at] of the band the SHEET leaves clear.
///
/// The runtime frames between `top` and `mapHeight − bottom` — the chrome
/// the layout reports as insets — and knows nothing of the sheet, which is
/// deliberately NOT reported (an inset re-frames and re-zooms the section).
/// So the sheet is folded into the fraction instead. Clamped to the band;
/// 0 when there is no band at all.
double seatLayerSheetLiftFraction({
  required double mapHeight,
  required double top,
  required double bottom,
  required double sheet,
  double at = seatLayerSheetSeatFraction,
}) {
  final band = mapHeight - top - bottom;
  final clear = mapHeight - top - sheet;
  if (!(band > 0) || !(clear > 0)) return 0;
  final target = clear * at;
  return (target / band).clamp(0.0, 1.0);
}

/// Where the seat rests once its card has gone: the middle of the band the
/// chrome leaves clear.
///
/// The web sheet undoes its own pans exactly. Over the bridge that sum is not
/// trustworthy: the map is a platform view that re-fits itself when it
/// changes size under a collapsing sheet, so a lift can be undone by a refit
/// this side never sees and asked for again — and undoing both then throws
/// the section off the screen (seen on device). A fixed resting place is
/// honest and predictable; the gesture guard still leaves a buyer who moved
/// the map where they put it.
const double seatLayerSheetRestoreFraction = 0.5;

/// The lift the layout makes for a seat card, and its undoing.
///
/// Driven from the layout's build, every frame, with what the card and the
/// chrome measure; it sends only when the question has changed. One lift per
/// card: a card replaced by another seat's card without a dismiss in between
/// keeps the first lift standing and the second ADDS to it, so the one
/// restore at the end puts the map back where the buyer had it rather than
/// half way — the web card's rule.
class PickerSeatLift {
  /// Creates a lift that pans through [frame].
  PickerSeatLift({
    required this.frame,
    this.page,
    this.onChanged,
    this.settle = defaultSettle,
  });

  /// The page the map is on; see [SeatLayerPickerSeatFraming.framingPage].
  ///
  /// A lift ends with its page: the next one opens where the venue fits, and
  /// undoing a pan it never made throws it off the middle.
  final Object? Function()? page;

  /// Called after a pan lands, so the chrome drawn against the seat's screen
  /// position can be laid out again.
  ///
  /// The pan carries no revision — it is camera only — so nothing else on
  /// this side hears about it, and the spotlight hole would keep the place
  /// the seat had before the map moved.
  final void Function()? onChanged;

  /// When the lift is asked again after it first lands.
  ///
  /// The runtime re-fits the section on its own when its surface changes
  /// size, and the web view finishes growing under a collapsing sheet a
  /// frame or two AFTER the layout has settled — so a lift that landed can be
  /// undone by a refit nobody on this side sees. Asking again, with the
  /// gesture count as the guard, costs one `dy: 0` reply when the seat is
  /// already in place and puts it back when it is not.
  static const List<Duration> defaultSettle = <Duration>[
    Duration(milliseconds: 350),
    Duration(milliseconds: 800),
  ];

  /// See [defaultSettle].
  final List<Duration> settle;

  final List<Timer> _settleTimers = <Timer>[];

  /// The runtime's pan; see [SeatLayerPickerSeatFraming.frameSeat].
  final Future<SeatLayerSeatFrame?> Function(
    String seatId, {
    required double fraction,
    int? gestures,
  }) frame;

  Object? _page;
  String? _seatId;
  double _fraction = 0;
  double _dy = 0;
  double _anchorDy = 0;

  /// How much is still missing of the way to where the seat was asked to
  /// rest, as far as the answers have said.
  double _short = 0;

  /// Whether the question that stands has been answered before, and whether
  /// the last answer found the seat in place.
  bool _answered = false;
  bool _arrived = false;

  /// How often the question that stands was asked again because an answer
  /// was news.
  int _news = 0;
  int? _gestures;
  int _revision = -1;
  int _generation = 0;
  double? _seenHeight;
  bool _pending = false;

  /// The seat the map is lifted for, or null.
  String? get seatId => _seatId;

  /// The total pan standing, in screen px.
  double get dy => _dy;

  /// The pan made since the snapshot the chrome is reading, in screen px.
  ///
  /// `selection[].screenPoint` is computed when the runtime BUILDS a snapshot,
  /// and `picker.frameSeat` publishes none — it is camera only, with no
  /// revision — so a seat's reported point is where it sat before this lift.
  /// Anything the shell draws against that point adds this, or it lands a
  /// whole lift band away from the seat (the spotlight hole did, on device).
  /// A newer snapshot already contains the pans made before it, so this is
  /// reset the moment one arrives rather than accumulated for the card's life.
  double get anchorDy => _anchorDy;

  /// Whether a lift is waiting for the map to hold still — the layout keeps
  /// rebuilding while this is true, so the next [sync] can see a settled
  /// height.
  bool get pending => _pending;

  /// Keep the map lifted for [seatId], or put it back for null.
  ///
  /// [sheet] is the band the card covers, measured from the map's foot; zero
  /// until the card has been laid out, in which case nothing is sent yet.
  /// [revision] re-asks after every snapshot the runtime publishes, so a
  /// glide that lands with the card up — the section settling — is followed;
  /// the runtime answers `dy: 0` when the seat is already in place, and
  /// declines outright once the buyer has moved the map.
  void sync({
    required String? seatId,
    required double mapHeight,
    required double top,
    required double bottom,
    required double sheet,
    required int revision,
  }) {
    final page = this.page?.call();
    if (_seatId != null && page != _page) forget();
    if (seatId == null) {
      release();
      return;
    }
    final band = mapHeight - top - bottom;
    if (!(band > 0) || !(sheet > 0)) return;
    // The map is a platform view that resizes as the cart sheet collapses
    // under an opening card, and the runtime pans against ITS height at the
    // moment the command lands. A fraction folded against a height caught
    // mid-animation put the seat under the card (seen on device). So a lift
    // is only sent once two consecutive syncs agree on the height.
    if (_seenHeight != mapHeight) {
      _seenHeight = mapHeight;
      _pending = true;
      return;
    }
    _pending = false;
    final fraction = seatLayerSheetLiftFraction(
      mapHeight: mapHeight,
      top: top,
      bottom: bottom,
      sheet: sheet,
    );
    if (seatId == _seatId && fraction == _fraction && revision == _revision) {
      return;
    }
    // A newer snapshot recomputed every screen point against the camera this
    // lift has already moved, so the pans folded into it are no longer the
    // shell's to add.
    if (revision != _revision) _anchorDy = 0;
    if (seatId != _seatId || fraction != _fraction) _short = 0;
    _answered = false;
    _arrived = false;
    _news = 0;
    _page = page;
    _seatId = seatId;
    _fraction = fraction;
    _revision = revision;
    _cancelSettle();
    final generation = ++_generation;
    // Off the build: the send publishes state, and a controller that notified
    // its listeners from inside a build would be rebuilding them mid-frame.
    scheduleMicrotask(() {
      if (generation != _generation) return;
      unawaited(_lift(seatId, fraction, generation));
    });
  }

  Future<void> _lift(String seatId, double fraction, int generation) async {
    if (page?.call() != _page) return;
    SeatLayerSeatFrame? answer;
    try {
      answer = await frame(seatId, fraction: fraction, gestures: _gestures);
    } catch (_) {
      // Surfaced on the picker's own error state by the controller; the map
      // simply does not lift.
      return;
    }
    if (answer == null || generation != _generation) return;
    // A refused lift (the buyer has moved the map) leaves the count where it
    // was, so the restore is refused for the same reason.
    if (_gestures != null && answer.gestures != _gestures) return;
    _gestures = answer.gestures;
    final again = _answered;
    final wasThere = _arrived;
    final moved = _movedBy(answer.dy);
    if (moved != 0) {
      _dy += moved;
      _anchorDy += moved;
      onChanged?.call();
    }
    void ask(Duration delay) => _settleTimers.add(
          Timer(delay, () {
            if (generation != _generation || _seatId != seatId) return;
            unawaited(_lift(seatId, fraction, generation));
          }),
        );
    if (_settleTimers.isEmpty) {
      settle.forEach(ask);
    } else if (again &&
        answer.dy != 0 &&
        (moved != 0 || wasThere) &&
        _news < settle.length) {
      _news += 1;
      ask(settle.first);
    }
  }

  /// How far the seat has moved, now that the runtime asks its map for [dy].
  ///
  /// [dy] is the way still left when the runtime was asked, and it answers so
  /// whether or not its map can go there. The first time the map is taken at
  /// its word. A map that is still short the next time stands at its edge, and
  /// the seat is where that answer says it is; one that had arrived was put
  /// back by a refit, and is brought back by this very pan.
  double _movedBy(double dy) {
    final double moved;
    if (!_answered) {
      // The same way short of the same place, on a newer snapshot.
      final stuck = dy != 0 && dy == _short;
      moved = stuck ? 0 : dy;
      if (!stuck) _short = 0;
    } else if (_arrived) {
      moved = 0;
    } else {
      moved = _short - dy;
      _short = dy;
    }
    _answered = true;
    _arrived = dy == 0;
    return moved;
  }

  void _cancelSettle() {
    for (final timer in _settleTimers) {
      timer.cancel();
    }
    _settleTimers.clear();
  }

  /// Put the seat at its resting place, unless the buyer has moved the map,
  /// and forget the lift.
  void release() {
    final seatId = _seatId;
    final gestures = _gestures;
    final dy = _dy;
    forget();
    if (seatId == null || gestures == null || dy == 0) return;
    unawaited(
      frame(seatId, fraction: seatLayerSheetRestoreFraction, gestures: gestures)
          .catchError((Object _) => null),
    );
  }

  /// Forget the lift without touching the map — the picker is going away.
  void forget() {
    _generation += 1;
    _cancelSettle();
    _seenHeight = null;
    _pending = false;
    _page = null;
    _seatId = null;
    _fraction = 0;
    _dy = 0;
    _anchorDy = 0;
    _short = 0;
    _answered = false;
    _arrived = false;
    _news = 0;
    _gestures = null;
    _revision = -1;
  }
}
