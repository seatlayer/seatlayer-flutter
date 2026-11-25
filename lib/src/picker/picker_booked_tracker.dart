/// When a handed-off hold has become a booking.
///
/// Only when the page says so. The hold leaves the snapshot for many reasons: it
/// ran out, the host let it go, the page was loaded again and starts without
/// it, or its seats were lost to another buyer. None of them is a sale, and a
/// buyer who reads "You're all set" over one has no tickets.
library;

import 'picker_models.dart';

/// Tracks one checkout handoff from hand-off to booking.
class PickerBookedTracker {
  SeatLayerCheckoutHandoff? _booked;

  /// The handoff the page said is booked, or null.
  SeatLayerCheckoutHandoff? get booked => _booked;

  /// The page said the hold [holdId] is booked; null is the hold handed off.
  ///
  /// Returns [handoff] the first time it is told, or null when it is not about
  /// [handoff] or was told before.
  SeatLayerCheckoutHandoff? said({
    required SeatLayerCheckoutHandoff? handoff,
    required String? holdId,
  }) {
    if (handoff == null) return null;
    if (holdId != null && holdId != handoff.holdId) return null;
    if (_booked?.holdId == handoff.holdId) return null;
    return _booked = handoff;
  }

  /// Forget the booking: a live hold starts a new story, so a buyer who starts
  /// a second cart is not congratulated twice.
  void reset() => _booked = null;
}
