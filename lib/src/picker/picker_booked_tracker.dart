/// When a handed-off hold has become a booking.
///
/// Only when the page says so. The hold leaves the snapshot for many reasons: it
/// ran out, the host let it go, the page was loaded again and starts without
/// it, or its seats were lost to another buyer. None of them is a sale, and a
/// buyer who reads "You're all set" over one has no tickets.
library;

import 'picker_models.dart';

/// Tracks each checkout handoff from hand-off to booking.
class PickerBookedTracker {
  SeatLayerCheckoutHandoff? _booked;
  final Set<String> _told = <String>{};

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
    if (!_told.add(handoff.holdId)) return null;
    return _booked = handoff;
  }

  /// The booking is over: a live hold starts a new story. It stays told, so a
  /// second word of it does not come over the second cart.
  void reset() => _booked = null;
}
