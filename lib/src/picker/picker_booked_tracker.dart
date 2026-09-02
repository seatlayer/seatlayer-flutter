/// When a handed-off hold has become a booking.
///
/// The runtime clears the buyer's hold the moment every held seat reads
/// `booked`, and it clears the same hold when the hold runs out — the snapshot
/// cannot tell the two apart. The runtime announces an expiry on its own
/// channel before the snapshot that shows the hold gone, so a hold that
/// vanished with no expiry announced, while a checkout handoff is still open,
/// is a sale. The web picker decides the same way.
library;

import 'picker_models.dart';

/// Tracks one checkout handoff from hand-off to booking.
class PickerBookedTracker {
  SeatLayerCheckoutHandoff? _booked;

  /// The handoff whose seats settled to booked, or null.
  SeatLayerCheckoutHandoff? get booked => _booked;

  /// Feed one snapshot transition; returns the handoff that just settled to
  /// booked, or null when nothing did.
  ///
  /// A live hold ends the previous booking's story, so a buyer who starts a
  /// second cart is not congratulated twice.
  SeatLayerCheckoutHandoff? observe({
    required SeatLayerCheckoutHandoff? handoff,
    required SeatLayerPickerHold? previous,
    required SeatLayerPickerHold? next,
    required bool expiryReported,
  }) {
    if (next != null) {
      _booked = null;
      return null;
    }
    if (handoff == null || previous == null || expiryReported) return null;
    if (_booked?.holdId == handoff.holdId) return null;
    _booked = handoff;
    return handoff;
  }

  /// Forget the booking, as when the host refuses the handoff.
  void reset() => _booked = null;
}
