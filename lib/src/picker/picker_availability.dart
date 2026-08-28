/// What a re-read of live availability found, and what it cost the buyer.
///
/// The picker cannot trust local state across a background. A buyer who left
/// for a payment sheet, a call or a password manager comes back to a map that
/// was last true minutes ago: seats they had merely selected may have been sold
/// to somebody else, and their own hold may have lapsed while nothing on this
/// device was running to notice. `picker.refreshAvailability` asks the runtime
/// what is true now; these are the answers it can give.
library;

import 'package:meta/meta.dart';

import '../json.dart';

/// Advertised by a runtime that answers `picker.refreshAvailability`.
const String seatLayerAvailabilityRefreshCapability = 'availability-refresh-v1';

/// Advertised by a runtime that reports `snapshot.map.accessNeeds`.
const String seatLayerAccessNeedsCapability = 'access-needs-v1';

/// How much of a lapsed hold could be taken back.
enum SeatLayerRecovery {
  /// Every seat the hold covered is still free.
  all,

  /// Some of them are; the rest have gone to somebody else.
  partial,

  /// None of them are.
  none,
}

/// The result of one [SeatLayerPickerController.refreshAvailability] call.
///
/// A refresh never removes or alters the buyer's own tickets. Their held seats
/// read as `held` on the server precisely because they hold them, and the
/// runtime excludes them before answering — so a refresh that finds nothing
/// wrong leaves selection, hold countdown, cart total, camera and rung exactly
/// where the buyer left them.
@immutable
class SeatLayerAvailabilityRefresh {
  /// Creates a refresh result.
  const SeatLayerAvailabilityRefresh({
    required this.refreshed,
    this.lostLabels = const <String>[],
    this.holdLapsed = false,
    this.lapsedLabels = const <String>[],
    this.recoverableLabels = const <String>[],
    this.revision,
  });

  /// The answer from a runtime that cannot refresh, and from a refresh that
  /// was declined because the session is not live.
  ///
  /// Deliberately not an error: a host wiring the resume hook has no way to
  /// know which runtime the buyer's device fetched, and a hook that threw on
  /// half of them would simply not be wired.
  const SeatLayerAvailabilityRefresh.unsupported()
      : refreshed = false,
        lostLabels = const <String>[],
        holdLapsed = false,
        lapsedLabels = const <String>[],
        recoverableLabels = const <String>[],
        revision = null;

  /// Whether the runtime actually re-read availability.
  final bool refreshed;

  /// Labels the buyer had selected but never held, which somebody else took.
  ///
  /// The runtime has already deselected them; this is the list so the host can
  /// say so. They reach [SeatLayerPickerCallbacks.onSelectedObjectUnavailable]
  /// as well, which is the same path a seat lost while the app was in the
  /// foreground already travels.
  final List<String> lostLabels;

  /// Whether the buyer's own hold is gone server-side.
  ///
  /// Authoritative, and deliberately preferred over the local countdown: a
  /// timer in a suspended isolate may never have fired at all.
  final bool holdLapsed;

  /// The labels that lapsed hold covered. Empty unless [holdLapsed].
  final List<String> lapsedLabels;

  /// The subset of [lapsedLabels] that is still free — the exact seats a
  /// re-selection can take back.
  final List<String> recoverableLabels;

  /// The picker revision this refresh produced, when the runtime gave one.
  final int? revision;

  /// Whether the refresh found nothing the buyer needs to know about.
  bool get isQuiet => lostLabels.isEmpty && !holdLapsed;

  /// How much of a lapsed hold [recoverableLabels] can take back.
  ///
  /// [SeatLayerRecovery.none] both when nothing is free and when nothing
  /// lapsed, so a caller reads it only alongside [holdLapsed].
  SeatLayerRecovery get recovery {
    if (recoverableLabels.isEmpty) return SeatLayerRecovery.none;
    return recoverableLabels.length >= lapsedLabels.length
        ? SeatLayerRecovery.all
        : SeatLayerRecovery.partial;
  }

  /// Decode a `picker.refreshAvailability` result payload.
  ///
  /// Tolerant in the usual way: a runtime that answers with nothing useful
  /// reads as a quiet refresh rather than as a failure.
  static SeatLayerAvailabilityRefresh fromJson(Object? value) {
    final lapsed = List<String>.unmodifiable(
      jListOf(jGet(value, 'lapsedLabels'), (item) => jStr(item)),
    );
    final holdLapsed = jBool(jGet(value, 'holdLapsed')) ?? false;
    return SeatLayerAvailabilityRefresh(
      refreshed: jBool(jGet(value, 'refreshed')) ?? true,
      lostLabels: List<String>.unmodifiable(
        jListOf(jGet(value, 'lost'), (item) => jStr(item)),
      ),
      holdLapsed: holdLapsed,
      lapsedLabels: holdLapsed ? lapsed : const <String>[],
      // `recoverable` is documented as a subset of `lapsedLabels`; anything
      // outside it is dropped rather than offered, because re-selecting a seat
      // the buyer never held would put a stranger's seat in their cart.
      recoverableLabels: List<String>.unmodifiable(
        jListOf(jGet(value, 'recoverable'), (item) => jStr(item))
            .where(lapsed.contains),
      ),
      revision: jInt(jGet(value, 'revision')),
    );
  }

  @override
  String toString() => 'SeatLayerAvailabilityRefresh(refreshed: $refreshed, '
      'lost: $lostLabels, holdLapsed: $holdLapsed, lapsed: $lapsedLabels, '
      'recoverable: $recoverableLabels)';
}

/// One hold that ended without the buyer doing anything.
///
/// Held on the controller until the buyer has been told, so the message
/// survives a rebuild, a theme flip and a route coming back — the moment is
/// exactly the one a widget's own `State` is least able to keep.
@immutable
class SeatLayerHoldLapse {
  /// Creates a lapse record.
  const SeatLayerHoldLapse({
    required this.lapsedLabels,
    required this.recoverableLabels,
    this.heldFor,
  });

  /// The seats the hold covered.
  final List<String> lapsedLabels;

  /// Which of them are still free right now.
  final List<String> recoverableLabels;

  /// How long the hold was good for, when the session named a window.
  ///
  /// Null when it did not: the SDK reports the window it asked for rather than
  /// guessing at the server's default, and a sentence with an invented number
  /// in it is worse than no sentence.
  final Duration? heldFor;

  /// How much of this lapse can be taken back.
  SeatLayerRecovery get recovery => recoverableLabels.isEmpty
      ? SeatLayerRecovery.none
      : recoverableLabels.length >= lapsedLabels.length
          ? SeatLayerRecovery.all
          : SeatLayerRecovery.partial;

  /// How many of the lapsed seats are gone for good.
  int get unrecoveredCount => (lapsedLabels.length - recoverableLabels.length)
      .clamp(0, lapsedLabels.length);
}
