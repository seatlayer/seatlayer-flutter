import 'dart:math' as math;

import '../payloads.dart';
import 'picker_models.dart';

/// The amounts one standing area can be asked for.
typedef SeatLayerStandingAmounts = ({int minimum, int maximum});

/// The area as the last snapshot describes it, or [area] when it names none.
GAArea seatLayerLiveStandingArea(
  GAArea area,
  SeatLayerPickerSnapshot? snapshot,
) =>
    snapshot?.generalAdmissionAreas
        .where((live) => live.id == area.id)
        .firstOrNull ??
    area;

bool _isBox(GAArea area) =>
    area.bookingMode == 'whole' || area.bookingMode == 'variable';

/// How many places [area] itself still offers, before the order's own limit;
/// null when the page does not say.
///
/// With the wheelchair filter on, an area offers its free wheelchair places,
/// and a box is offered only if it has any.
int? seatLayerStandingPlacesFree(
  GAArea area,
  SeatLayerPickerSnapshot? snapshot,
) {
  final wheelchairOnly =
      snapshot?.map.accessibilityFilter.contains('wheelchair') ?? false;
  if (!wheelchairOnly) {
    return area.available == null ? null : math.max(0, area.available!);
  }
  final available = math.max(0, area.available ?? 0);
  return _isBox(area)
      ? ((area.wheelchairPlaces ?? 0) > 0 ? available : 0)
      : math.min(available, math.max(0, area.wheelchairAvailable ?? 0));
}

/// The amounts [area] can be asked for, by the page's own rule: the page
/// answers any other amount with no hold and no reason. Null when there is no
/// such amount.
///
/// Per person, any number that is free and left in the order. A box is sold to
/// one party: all its places, or a party inside its range.
SeatLayerStandingAmounts? seatLayerStandingAmounts(
  GAArea area,
  SeatLayerPickerSnapshot? snapshot,
) {
  final remaining =
      (snapshot?.maxSelection ?? 10) - (snapshot?.ticketCount ?? 0);
  final free = seatLayerStandingPlacesFree(area, snapshot);
  final room = free == null ? remaining : math.min(remaining, free);
  final int minimum;
  final int maximum;
  if (_isBox(area)) {
    final places = math.max(0, area.maxOccupancy ?? area.capacity ?? free ?? 0);
    minimum = area.bookingMode == 'whole'
        ? places
        : math.max(1, math.min(places, area.minOccupancy ?? 1));
    maximum = math.min(places, room);
  } else {
    minimum = 1;
    maximum = room;
  }
  return minimum < 1 || maximum < minimum
      ? null
      : (minimum: minimum, maximum: maximum);
}
