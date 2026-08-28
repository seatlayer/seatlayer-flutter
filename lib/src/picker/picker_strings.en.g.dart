// GENERATED — do not edit.
//
// Source: design/locale_strings.json (en)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftEn(int count) => '$count left';

String _moreCountEn(int count) => '+$count more';

String _fromPriceEn(String money) => 'From $money';

String _ticketCountEn(int count) =>
    count == 1 ? '$count ticket' : '$count tickets';

String _findBestSeatsEn(int count) =>
    count == 1 ? 'Find $count best seat' : 'Find $count best seats';

String _reselectSeatsEn(int count) =>
    count == 1 ? 'Select it again' : 'Select them again';

String _continueWithTotalEn(String money) => 'Continue \u00b7 $money';

/// The `en` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsEn = SeatLayerPickerStrings(
  close: 'Close',
  overview: 'Venue',
  backToVenue: 'Back to venue',
  cancel: 'Cancel',
  select: 'Select',
  viewFromHere: 'View from here',
  openVenue360: 'Open venue 360°',
  recentre: 'Recentre on the stage',
  viewFromYourSeat: 'view from your seat',
  emptyTrayHint:
      'Tap a seat on the map, or let us pick the best available for you.',
  anyTicketType: 'Any ticket type',
  anyVenueZone: 'Any venue zone',
  bestSeats: 'Best seats',
  showLess: 'Show less',
  undo: 'Undo',
  holdAndCheckout: 'Hold seats & checkout',
  poweredBy: 'Powered by SeatLayer',
  testMode: 'TEST MODE',
  accessibility: 'Accessibility and colour options',
  accessibilityTitle: 'Accessibility and colour options',
  fitVenue: 'Fit to screen',
  loading: 'Loading seat map…',
  errorMessage: 'The seat map didn’t load',
  retry: 'Try again',
  hideLimitedView: 'Hide limited-view seats',
  colorblindSafe: 'Colourblind-friendly colours',
  seatsLeft: _seatsLeftEn,
  moreCount: _moreCountEn,
  fromPrice: _fromPriceEn,
  ticketCount: _ticketCountEn,
  findBestSeats: _findBestSeatsEn,
  reselectSeats: _reselectSeatsEn,
  continueWithTotal: _continueWithTotalEn,
);
