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

String _addMinutesEn(int minutes) => '+$minutes min';

String _fromPriceEn(String money) => 'From $money';

String _sightlineEn(String metres) => '≈ $metres m to stage';

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
  removeSeat: 'Remove seat',
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
  fitVenue: 'Show whole venue',
  fitWholeVenue: 'Show whole venue',
  loading: 'Loading seat map…',
  errorMessage: 'The seat map didn’t load',
  retry: 'Try again',
  accessRefresh: 'Refresh',
  noSeatsSelected: 'No seats selected',
  findBestSeatsCta: 'Find best seats',
  organizerNote: 'Organizer note',
  accessiblePhysicalSeat: 'Accessible physical seat',
  emptyWheelchairSpace: 'Empty wheelchair space',
  findSeatsTogether: 'Find seats together',
  aboutBestSeats: 'About finding seats together',
  closestGroupChosenInstantly: 'Closest available group, chosen instantly.',
  hideLimitedView: 'Hide limited-view seats',
  colorblindSafe: 'Colourblind-friendly colours',
  notAvailable: 'Not available',
  restrictedView: 'Restricted view',
  obstructedView: 'Obstructed view',
  premiumSeat: 'Premium seat',
  continueWord: 'Continue',
  accessNeeds: <String, String>{
    'wheelchair': 'Wheelchair space',
    'companion': 'Companion seat',
    'semi-ambulatory': 'Limited mobility',
    'designated-aisle': 'Aisle / transfer',
    'step-free': 'Step-free',
    'hearing': 'Assistive listening',
    'cart': 'Live captions',
    'sign-language': 'Sign language',
    'low-vision': 'Low vision',
    'sensory-friendly': 'Sensory-friendly',
    'plus-size': 'Plus-size',
    'lift-armrest': 'Lift-up armrest',
  },
  seatsLeft: _seatsLeftEn,
  moreCount: _moreCountEn,
  addMinutes: _addMinutesEn,
  fromPrice: _fromPriceEn,
  sightline: _sightlineEn,
  ticketCount: _ticketCountEn,
  findBestSeats: _findBestSeatsEn,
  reselectSeats: _reselectSeatsEn,
  continueWithTotal: _continueWithTotalEn,
);
