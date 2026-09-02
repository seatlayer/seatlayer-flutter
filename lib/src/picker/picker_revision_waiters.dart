import 'dart:async';

import '../seat_layer_error.dart';

/// Everyone waiting for the picker's state to catch up with a command.
///
/// A bridge command answers with the revision its change will appear in, and
/// the snapshot carrying that revision arrives separately. Between the two the
/// SDK has a promise it cannot yet keep, and this is where those promises are
/// parked: one list per revision, released the moment a snapshot reaches it.
///
/// Its own class because the waiting has three failure modes worth naming —
/// the snapshot arrives, the snapshot never arrives and the runtime is asked
/// again, or the controller is destroyed underneath everyone — and none of
/// them are about seats.
class PickerRevisionWaiters {
  /// [revisionNow] reads the revision already applied; [resync] asks the
  /// runtime for a fresh snapshot and applies it.
  PickerRevisionWaiters({required this.revisionNow, required this.resync});

  /// The revision the picker has already applied.
  final int Function() revisionNow;

  /// Ask the runtime for the current snapshot and apply it.
  final Future<void> Function() resync;

  /// How long a promised revision is waited for before the runtime is asked
  /// directly. Long enough to cover a slow frame, short enough that a buyer
  /// never watches a spinner over a snapshot that was simply dropped.
  static const Duration patience = Duration(seconds: 2);

  final Map<int, List<Completer<void>>> _waiters =
      <int, List<Completer<void>>>{};

  /// Resolve once the picker has applied [target].
  ///
  /// Falls back to asking the runtime outright, and only fails if even that
  /// does not carry the revision the command promised.
  Future<void> awaitRevision(int target) async {
    if (revisionNow() >= target) return;
    final waiter = Completer<void>();
    (_waiters[target] ??= <Completer<void>>[]).add(waiter);
    try {
      await waiter.future.timeout(patience);
    } on TimeoutException {
      await resync();
      if (revisionNow() < target) {
        throw SeatLayerError.decoding(
          'picker state stopped at revision ${revisionNow()}; '
          'expected $target',
        );
      }
    } finally {
      _waiters[target]?.remove(waiter);
      if (_waiters[target]?.isEmpty ?? false) _waiters.remove(target);
    }
  }

  /// Release everyone waiting for [revision] or anything before it.
  void releaseThrough(int revision) {
    final reached = _waiters.keys
        .where((target) => target <= revision)
        .toList(growable: false);
    for (final target in reached) {
      for (final waiter in _waiters.remove(target)!) {
        if (!waiter.isCompleted) waiter.complete();
      }
    }
  }

  /// Fail everyone still waiting — the controller is gone.
  void failAll([Object error = const SeatLayerError.destroyed()]) {
    for (final waiters in _waiters.values) {
      for (final waiter in waiters) {
        if (!waiter.isCompleted) waiter.completeError(error);
      }
    }
    _waiters.clear();
  }
}
