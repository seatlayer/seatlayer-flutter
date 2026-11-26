/// When a handed-off hold has become a booking.
///
/// Only when the page says so. The hold leaves the snapshot for many reasons: it
/// ran out, the host let it go, the page was loaded again and starts without
/// it, or its seats were lost to another buyer. None of them is a sale, and a
/// buyer who reads "You're all set" over one has no tickets.
library;

import 'package:flutter/foundation.dart';

import 'picker_models.dart';

/// Tracks each checkout handoff from hand-off to booking.
class PickerBookedTracker {
  SeatLayerCheckoutHandoff? _booked;
  final Set<String> _told = <String>{};

  /// The handoff the page said is booked, or null.
  SeatLayerCheckoutHandoff? get booked => _booked;

  /// The page said the hold [holdId] is booked; null is the hold handed off.
  ///
  /// Once per hold, and only where it is about [handoff], the picker is drawn
  /// again and the app is told.
  void said(
    SeatLayerCheckoutHandoff? handoff,
    String? holdId,
    VoidCallback redraw,
    ValueChanged<SeatLayerCheckoutHandoff>? tell,
  ) {
    if (handoff == null) return;
    if (holdId != null && holdId != handoff.holdId) return;
    if (!_told.add(handoff.holdId)) return;
    _booked = handoff;
    redraw();
    tell?.call(handoff);
  }

  /// The booking is over: a live hold starts a new story. It stays told, so a
  /// second word of it does not come over the second cart.
  void reset() => _booked = null;
}
