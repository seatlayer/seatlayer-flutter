/// Standing an unanswered seat card down before another surface takes over.
///
/// Lives beside the controller rather than in it: the controller file is at
/// the package's line cap, and this is one small policy on top of members it
/// already publishes.
library;

import 'picker_haptics.dart';
import 'seat_layer_picker_controller.dart';

/// Clearing the picker's one pending decision.
extension SeatLayerPendingSeatCancel on SeatLayerPickerController {
  /// Take down an open seat confirm card, as an outside tap would.
  ///
  /// A confirm card is a question, and a question left standing behind a sheet
  /// is one the buyer cannot answer and cannot see. Only one decision surface
  /// may hold the screen at a time — the web picker clears them all before
  /// another goes up (`SeatPicker.clearDecisionSurfaces`) — so a surface that
  /// is about to cover the map calls this first.
  ///
  /// The seat goes back the way `Cancel` gives it back: out of the runtime's
  /// selection, and marked answered so the card does not come straight back.
  /// A no-op when nothing is pending.
  Future<void> cancelPendingSeat() async {
    final seat = seatAwaitingConfirmation;
    if (seat == null) return;
    // A tick, not an impact — the same cue the card's own Cancel emits.
    emitHaptic(PickerHapticCue.cardCancelled);
    try {
      await removeObject(seat.label);
    } finally {
      markSeatAnswered(seat.label);
    }
  }
}
