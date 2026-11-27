// GENERATED — do not edit.
//
// Source: design/locale_strings.json (en)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableEn(String label) =>
    '$label is no longer available. Choose another seat.';

String _labelsNoLongerAvailableEn(String labels) =>
    '$labels are no longer available. Choose another group.';

String _couldNotFindSeatsTogetherEn(int count) =>
    'We couldn’t find $count seats together. Try fewer seats or another ticket type.';

String _maxTicketsForOrderEn(int count) =>
    'You can select up to $count tickets for this order.';

String _couldNotRemoveLabelEn(String label) =>
    'Couldn’t remove $label. Your hold is unchanged.';

String _peekSecuredEn(int count, String total) =>
    '✓ $count secured · $total. You won’t be charged yet';

String _venueMapEn(String venue) => '$venue seat map';

String _accessibleStepEn(int index, int total) => '$index of $total';

String _chooseMinMaxGuestsEn(int min, int max) =>
    'Choose between $min and $max guests.';

String _chooseMoreEn(int count) => 'Choose $count more';

String _seatsHeldForNeedMoreTimeEn(String time) =>
    'Your seats are held for $time. Need more time?';

String _accessNeedWithCountEn(String need, int count) => '$need · $count';

String _ticketCountEn(int count) => switch (pickerPluralCategory('en', count)) {
  PickerPluralCategory.one => '$count ticket',
  _ => '$count tickets',
};

String _findBestSeatsEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => 'Find $count best seat',
      _ => 'Find $count best seats',
    };

String _reselectSeatsEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => 'Select it again',
      _ => 'Select them again',
    };

String _seatsFreeEn(int count) => switch (pickerPluralCategory('en', count)) {
  PickerPluralCategory.one => '$count seat',
  _ => '$count seats',
};

String _seatsLeftInSectionEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count seat left',
      _ => '$count seats left',
    };

String _holdLapsedStillFreeEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one =>
        'Your hold ended while you were away. That seat is still free.',
      _ => 'Your hold ended while you were away. Those seats are still free.',
    };

String _holdLapsedSomeTakenEn(int count) => switch (pickerPluralCategory(
  'en',
  count,
)) {
  PickerPluralCategory.one =>
    'Your hold ended while you were away, and $count of those seats has been taken. The rest are still free.',
  _ =>
    'Your hold ended while you were away, and $count of those seats have been taken. The rest are still free.',
};

String _holdLapsedAllTakenEn(int count) => switch (pickerPluralCategory(
  'en',
  count,
)) {
  PickerPluralCategory.one =>
    'Your hold ended while you were away, and that seat has been taken.',
  _ => 'Your hold ended while you were away, and those seats have been taken.',
};

String _accessibleSectionsEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count section',
      _ => '$count sections',
    };

String _placesAvailableEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count place currently available',
      _ => '$count places currently available',
    };

String _removeTicketsEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => 'Remove $count ticket',
      _ => 'Remove $count tickets',
    };

String _holdMinutesLeftEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count minute left',
      _ => '$count minutes left',
    };

String _holdSecondsLeftEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count second left',
      _ => '$count seconds left',
    };

String _holdLapsedBodyEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => 'They were held for $count minute.',
      _ => 'They were held for $count minutes.',
    };

String _seatsNotRecoveredEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count could not be recovered',
      _ => '$count could not be recovered',
    };

String _activeFiltersEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count filter',
      _ => '$count filters',
    };

String _accessibilityFiltersActiveEn(int count) =>
    switch (pickerPluralCategory('en', count)) {
      PickerPluralCategory.one => '$count accessibility filter active',
      _ => '$count accessibility filters active',
    };

String _onlyLeftEn(int count) => switch (pickerPluralCategory('en', count)) {
  PickerPluralCategory.one => '$count seat left',
  _ => '$count seats left',
};

String _maintenancePausedEn(int count) => switch (pickerPluralCategory(
  'en',
  count,
)) {
  PickerPluralCategory.one =>
    'Booking is paused for maintenance. Please try again in about $count minute.',
  _ =>
    'Booking is paused for maintenance. Please try again in about $count minutes.',
};

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
  testMode: 'Test mode',
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
  viewGroupTitle: 'VIEW',
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
  ticketPrices: 'Ticket prices',
  yourSeats: 'Your seats',
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
  ticketTypeSoldOut: 'That ticket type is sold out. Try another ticket type.',
  seatsNoLongerAvailableTryAnother:
      'Those seats are no longer available. Try another quantity or ticket type.',
  companionPairRequired:
      'Select the adjacent wheelchair place with each companion ticket.',
  ticketOptionNotApplicable:
      'That ticket choice is not available for the selected seat.',
  maintenancePausedShortly:
      'Booking is paused for a few minutes for maintenance. Please try again shortly.',
  guestsOnly: 'This event is for invited guests.',
  guestChoiceClosed: 'Seat choice isn’t open right now.',
  maxOneTicketForOrder: 'You can select up to 1 ticket for this order.',
  tooManyAttempts: 'Too many attempts. Wait a moment and try again.',
  seatHeldForRenewal:
      'One of these seats is kept for a season ticket holder who can still renew it. Choose another seat.',
  seatUnavailable: 'This seat isn\'t available.',
  eventUnavailable: 'Tickets can’t be booked here right now.',
  savedSeatsNotRestored:
      'Your earlier seats could not be restored. Please choose again.',
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
  floorWord: 'Floor',
  totalWord: 'Total',
  adjustSelection: 'Adjust seat selection',
  backToSeatMap: 'Back to seat map',
  chooseSeats: 'Choose your seats',
  chooseTickets: 'Choose tickets',
  placeWord: 'PLACE',
  guestsWord: 'Guests',
  tableWord: 'Table',
  ticketWord: 'Ticket',
  passport: 'Passport',
  venue3D: '3D',
  venueZone: 'Venue zone',
  venueMapHint:
      'Seats are picked with the controls around the map: the price rail above it, the section controls below it, and the ticket panel at the foot.',
  previousSeat: 'Previous seat',
  nextSeat: 'Next seat',
  orbitMode: 'Rotate venue',
  panMode: 'Move venue',
  openInteractive3dVenue: 'Open interactive 3D venue',
  showSeatsFor: 'SHOW SEATS FOR',
  accessJumpFirstSection: 'Jump to the first section',
  accessJumpNextSection: 'Jump to the next section',
  fewerTickets: 'Fewer tickets',
  moreTickets: 'More tickets',
  addTickets: 'Add tickets',
  noSelectableSeats: 'No selectable seats are currently available.',
  confirmYourTickets: 'Confirm your tickets',
  seatsSecuredOpeningCheckout: 'Seats secured. Opening checkout…',
  holdInCheckoutTitle: 'Your seats are already in checkout',
  holdInCheckoutBody:
      'Finish checkout to keep them. To pick different seats, release these first — they go back on sale.',
  releaseAndChangeSeats: 'Release and change seats',
  holdAlreadyHeldTitle: 'Your seats are already held',
  holdAlreadyHeldBody: 'Continue to checkout to keep them.',
  accessExpiredTitle: 'Your seat session has expired',
  accessExpiredCopy:
      'Reload the seat map to continue. Seats already in your cart stay held until the timer ends.',
  dismissError: 'Dismiss error',
  testModeLong: 'Test mode · books nothing',
  seatRemoved: 'Ticket removed',
  reloadSeatMap: 'Reload seat map',
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
  labelNoLongerAvailable: _labelNoLongerAvailableEn,
  labelsNoLongerAvailable: _labelsNoLongerAvailableEn,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherEn,
  maxTicketsForOrder: _maxTicketsForOrderEn,
  couldNotRemoveLabel: _couldNotRemoveLabelEn,
  peekSecured: _peekSecuredEn,
  venueMap: _venueMapEn,
  accessibleStep: _accessibleStepEn,
  chooseMinMaxGuests: _chooseMinMaxGuestsEn,
  chooseMore: _chooseMoreEn,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeEn,
  accessNeedWithCount: _accessNeedWithCountEn,
  ticketCount: _ticketCountEn,
  findBestSeats: _findBestSeatsEn,
  reselectSeats: _reselectSeatsEn,
  seatsFree: _seatsFreeEn,
  seatsLeftInSection: _seatsLeftInSectionEn,
  holdLapsedStillFree: _holdLapsedStillFreeEn,
  holdLapsedSomeTaken: _holdLapsedSomeTakenEn,
  holdLapsedAllTaken: _holdLapsedAllTakenEn,
  accessibleSections: _accessibleSectionsEn,
  placesAvailable: _placesAvailableEn,
  removeTickets: _removeTicketsEn,
  holdMinutesLeft: _holdMinutesLeftEn,
  holdSecondsLeft: _holdSecondsLeftEn,
  holdLapsedBody: _holdLapsedBodyEn,
  seatsNotRecovered: _seatsNotRecoveredEn,
  activeFilters: _activeFiltersEn,
  accessibilityFiltersActive: _accessibilityFiltersActiveEn,
  onlyLeft: _onlyLeftEn,
  maintenancePaused: _maintenancePausedEn,
  continueWithTotal: _continueWithTotalEn,
);
