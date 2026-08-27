import 'package:flutter/foundation.dart';

/// Every buyer-facing string the native picker chrome renders.
///
/// The map itself is localized by the runtime through
/// [SeatLayerPickerOptions.languages]; this covers the Flutter-side chrome the
/// runtime never sees. Each entry is a function so a host can interpolate its
/// own translation, and every one of them has an English default, so a host
/// that overrides nothing still gets a complete interface.
@immutable
class SeatLayerPickerStrings {
  /// Creates a string table; every field defaults to the English wording.
  const SeatLayerPickerStrings({
    this.close = 'Close seat selection',
    this.chooseSeats = 'Choose your seats',
    this.overview = 'Overview',
    this.previousSection = 'Previous section',
    this.nextSection = 'Next section',
    this.backToVenue = 'Back to venue',
    this.cancel = 'Cancel',
    this.select = 'Select',
    this.viewFromHere = 'View from here',
    this.venue3D = '3D',
    this.openVenue360 = 'Open venue 360°',
    this.previousSeat = 'Previous seat',
    this.nextSeat = 'Next seat',
    this.recentre = 'Recentre the view',
    this.viewFromYourSeat = 'view from your seat',
    this.chooseTickets = 'Choose tickets',
    this.emptyTrayHint =
        'Tap a seat on the map, or let us pick the best available for you.',
    this.anyTicketType = 'Any ticket type',
    this.anyVenueZone = 'Any venue zone',
    this.ticketType = 'Ticket type',
    this.venueZone = 'Venue zone',
    this.fewerTickets = 'Fewer tickets',
    this.moreTickets = 'More tickets',
    this.bestSeats = 'Best seats',
    this.showLess = 'Show less',
    this.undo = 'Undo',
    this.holdAndCheckout = 'Hold seats & checkout',
    this.poweredBy = 'Powered by SeatLayer',
    this.testMode = 'TEST MODE',
    this.accessibility = 'Accessibility and view filters',
    this.fitVenue = 'Fit venue',
    this.mapView = 'Seat map',
    this.seatRemoved = 'Ticket removed',
    this.ticketCount = _defaultTicketCount,
    this.seatsLeft = _defaultSeatsLeft,
    this.seatsFree = _defaultSeatsFree,
    this.fromPrice = _defaultFromPrice,
    this.continueWithTotal = _defaultContinueWithTotal,
    this.findBestSeats = _defaultFindBestSeats,
    this.moreCount = _defaultMoreCount,
    this.heldFor = _defaultHeldFor,
    this.seatIdentity = _defaultSeatIdentity,
  });

  /// Tooltip on the header's dismiss control.
  final String close;

  /// Header fallback when the event has no name yet.
  final String chooseSeats;

  /// Dock-bar action returning the map to the venue overview.
  final String overview;

  /// Tooltip on the dock bar's previous-section step.
  final String previousSection;

  /// Tooltip on the dock bar's next-section step.
  final String nextSection;

  /// 3D chrome action returning to the seat map.
  final String backToVenue;

  /// Confirm-card dismissal.
  final String cancel;

  /// Confirm-card acceptance.
  final String select;

  /// Confirm-card pill opening the seat-view photo.
  final String viewFromHere;

  /// Confirm-card pill opening the venue 3D scene.
  final String venue3D;

  /// 3D chrome action opening the full venue panorama.
  final String openVenue360;

  /// Tooltip on the 3D chrome's previous-seat step.
  final String previousSeat;

  /// Tooltip on the 3D chrome's next-seat step.
  final String nextSeat;

  /// Tooltip on the 3D chrome's recentre control.
  final String recentre;

  /// Trailing clause of the 3D caption chip.
  final String viewFromYourSeat;

  /// Peek label while the cart is empty and no price is known.
  final String chooseTickets;

  /// Screen-reader hint describing how to fill an empty cart.
  final String emptyTrayHint;

  /// Best-seats category selector placeholder.
  final String anyTicketType;

  /// Best-seats zone selector placeholder.
  final String anyVenueZone;

  /// Best-seats category selector name.
  final String ticketType;

  /// Best-seats zone selector name.
  final String venueZone;

  /// Tooltip on the quantity stepper's decrement.
  final String fewerTickets;

  /// Tooltip on the quantity stepper's increment.
  final String moreTickets;

  /// Name of the best-seats feature.
  final String bestSeats;

  /// Collapses an expanded dense ticket list.
  final String showLess;

  /// Action reversing a ticket removal.
  final String undo;

  /// Cart-sheet footer call to action.
  final String holdAndCheckout;

  /// Required SeatLayer attribution.
  final String poweredBy;

  /// Badge shown on a test event.
  final String testMode;

  /// Tooltip on the accessibility map control.
  final String accessibility;

  /// Tooltip on the fit-to-screen map control.
  final String fitVenue;

  /// Label of the map half of the Map/3D control.
  final String mapView;

  /// Message announced after a ticket is removed.
  final String seatRemoved;

  /// "1 ticket" / "6 tickets".
  final String Function(int count) ticketCount;

  /// "74 left" — a section with some seats already sold.
  final String Function(int count) seatsLeft;

  /// "74 seats" — a section with nothing sold yet.
  final String Function(int count) seatsFree;

  /// "From $45".
  final String Function(String money) fromPrice;

  /// "Continue · $320".
  final String Function(String money) continueWithTotal;

  /// "Find 2 best seats".
  final String Function(int count) findBestSeats;

  /// "+6 more".
  final String Function(int count) moreCount;

  /// "14:59", read out as a remaining hold time.
  final String Function(String clock) heldFor;

  /// "Stalls D · Row D · Seat 1", assembled from the parts that exist.
  final String Function(List<String> parts) seatIdentity;

  static String _defaultTicketCount(int count) =>
      count == 1 ? '1 ticket' : '$count tickets';

  static String _defaultSeatsLeft(int count) => '$count left';

  static String _defaultSeatsFree(int count) =>
      count == 1 ? '1 seat' : '$count seats';

  static String _defaultFromPrice(String money) => 'From $money';

  static String _defaultContinueWithTotal(String money) =>
      'Continue · $money';

  static String _defaultFindBestSeats(int count) => 'Find $count best seats';

  static String _defaultMoreCount(int count) => '+$count more';

  static String _defaultHeldFor(String clock) => clock;

  static String _defaultSeatIdentity(List<String> parts) => parts.join(' · ');
}
