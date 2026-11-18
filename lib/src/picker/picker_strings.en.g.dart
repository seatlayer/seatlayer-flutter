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

String _secureMoreAndCheckoutEn(int count) => 'Secure $count more & checkout';

String _accessFreeCountEn(int count) => '$count free';

String _seatJustTakenByAnotherEn(String label) =>
    'Seat $label was just taken by another buyer.';

String _peekSecuredEn(int count, String total) =>
    '✓ $count secured · $total. You won’t be charged yet';

String _ticketCountEn(int count) =>
    count == 1 ? '$count ticket' : '$count tickets';

String _findBestSeatsEn(int count) =>
    count == 1 ? 'Find $count best seat' : 'Find $count best seats';

String _reselectSeatsEn(int count) =>
    count == 1 ? 'Select it again' : 'Select them again';

String _seatsFreeEn(int count) => count == 1 ? '$count seat' : '$count seats';

String _seatsLeftInSectionEn(int count) =>
    count == 1 ? '$count seat left' : '$count seats left';

String _holdLapsedStillFreeEn(int count) => count == 1
    ? 'Your hold ended while you were away. That seat is still free.'
    : 'Your hold ended while you were away. Those seats are still free.';

String _holdLapsedSomeTakenEn(int count) => count == 1
    ? 'Your hold ended while you were away, and $count of those seats has been taken. The rest are still free.'
    : 'Your hold ended while you were away, and $count of those seats have been taken. The rest are still free.';

String _holdLapsedAllTakenEn(int count) => count == 1
    ? 'Your hold ended while you were away, and that seat has been taken.'
    : 'Your hold ended while you were away, and those seats have been taken.';

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
  allFloors: 'All floors',
  previousSection: 'Previous section',
  nextSection: 'Next section',
  addSeat: 'Add seat',
  added: 'Added',
  sectionWord: 'Section',
  rowWord: 'Row',
  seatWord: 'Seat',
  seeItIn3D: 'See it in 3D',
  viewFromThisSeat: 'View from this seat',
  allPrices: 'All prices',
  ticketType: 'Ticket type',
  tierCompanionGuidance: 'Requires the adjacent wheelchair place',
  findingBestSeats: 'Finding the best seats…',
  findSeats: 'Find seats',
  expandCart: 'Open ticket panel',
  collapseCart: 'Collapse ticket panel',
  continueToCheckout: 'Continue to checkout',
  secureMore: 'Secure more',
  selectSeats: 'Select seats',
  pickYourSeats: 'Pick your seats',
  salesClosedPill: 'Sales are closed',
  salesClosedCta: 'Sales closed',
  confirmOrCancelSeat: 'Confirm or cancel this seat',
  securingSeats: 'Securing your seats…',
  openingCheckout: 'Opening secure checkout…',
  testModeExplained: 'Bookings here are not real and no card is charged',
  displayOptions: 'Display options',
  companionSeatsNote: 'Companion places beside them stay selectable',
  zoomIn: 'Zoom in',
  zoomOut: 'Zoom out',
  rotateVenue: 'Drag to rotate the venue',
  moveVenue: 'Drag to move the venue',
  mapView: 'Map',
  flat2dMap: 'Flat 2D map',
  interactive3dVenueView: 'Interactive 3D venue view',
  venueView: 'Venue view',
  holdLapsedTitle: 'Your seats were released',
  salesClosed: 'Sales are closed',
  salesClosedCopy: 'Ticket sales for this event have ended.',
  salesClosedToast: 'Sales are closed for this event.',
  soldOutEyebrow: 'This event',
  soldOutTitle: 'Sold out',
  soldOutCopy: 'No reserved seats are currently available for this event.',
  holdExpired: 'Your hold expired and the seats were released. Pick again.',
  addingEllipsis: 'Adding…',
  moreTimeAdded: 'More time added. Your seats are still held.',
  couldNotAddMoreTime: 'Couldn’t add more time. Please head to checkout now.',
  seatsJustTaken: 'One or more seats were just taken. Please pick again.',
  allSetTitle: 'You’re all set',
  confirmedAndOnWay: 'confirmed. A confirmation is on its way.',
  backToMap: 'Back to map',
  mapDidNotLoad: 'The seat map didn’t load',
  checkConnection: 'Check your connection and try again.',
  accessPausedTitle: 'These seats are on hold right now',
  accessPausedCopy:
      'The organizer has paused this selection. Try again in a few minutes.',
  accessRevokedTitle: 'This access link is no longer active',
  accessRevokedCopy:
      'Ask whoever sent you here for a new link to keep booking these seats.',
  accessUnverifiedTitle: 'We couldn’t verify your access',
  accessUnverifiedCopy:
      'You can still book anything shown as available. Contact whoever sent you here for access to the rest.',
  generalAdmission: 'General admission',
  numberOfGuests: 'Number of guests',
  chooseGuestsCopy:
      'Choose how many guests will sit together. This table is held exclusively for your party.',
  fewerGuests: 'Fewer guests',
  moreGuests: 'More guests',
  selectTable: 'Select table',
  updateTable: 'Update table',
  removeWord: 'Remove',
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
  secureMoreAndCheckout: _secureMoreAndCheckoutEn,
  accessFreeCount: _accessFreeCountEn,
  seatJustTakenByAnother: _seatJustTakenByAnotherEn,
  peekSecured: _peekSecuredEn,
  ticketCount: _ticketCountEn,
  findBestSeats: _findBestSeatsEn,
  reselectSeats: _reselectSeatsEn,
  seatsFree: _seatsFreeEn,
  seatsLeftInSection: _seatsLeftInSectionEn,
  holdLapsedStillFree: _holdLapsedStillFreeEn,
  holdLapsedSomeTaken: _holdLapsedSomeTakenEn,
  holdLapsedAllTaken: _holdLapsedAllTakenEn,
  continueWithTotal: _continueWithTotalEn,
);
