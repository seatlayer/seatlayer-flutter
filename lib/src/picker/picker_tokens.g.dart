// GENERATED — do not edit.
//
// Source: design/tokens.json
// Regenerate: dart run tool/gen_tokens.dart
//
// This file is the one place the picker's spec numbers enter
// Dart. Change the JSON, not this file.
import 'dart:ui' show Color;

/// The design-token version this file was generated from.
const int seatLayerTokensVersion = 1;

/// The light palette.
abstract final class SeatLayerLightTokens {
  /// `#F6F7FB`
  static const Color background = Color(0xFFF6F7FB);

  /// `#FFFFFF`
  static const Color surface = Color(0xFFFFFFFF);

  /// `#172033`
  static const Color text = Color(0xFF172033);

  /// `#667085`
  static const Color mutedText = Color(0xFF667085);

  /// `#29172033`
  static const Color divider = Color(0x29172033);

  /// `#B42318`
  static const Color error = Color(0xFFB42318);

  /// `#F4B740`
  static const Color warning = Color(0xFFF4B740);

  /// `#5B4B8A`
  static const Color accent = Color(0xFF5B4B8A);

  /// `#FFFFFF`
  static const Color onAccent = Color(0xFFFFFFFF);

  /// `#E9EDF4`
  static const Color mapBackground = Color(0xFFE9EDF4);

  /// `#334155`
  static const Color mapRowLabel = Color(0xFF334155);

  /// `#172033`
  static const Color mapText = Color(0xFF172033);

  /// `#5B4B8A`
  static const Color mapSelection = Color(0xFF5B4B8A);
}

/// The dark palette.
abstract final class SeatLayerDarkTokens {
  /// `#0F1522`
  static const Color background = Color(0xFF0F1522);

  /// `#1A2234`
  static const Color surface = Color(0xFF1A2234);

  /// `#EEF1F8`
  static const Color text = Color(0xFFEEF1F8);

  /// `#A5AEC2`
  static const Color mutedText = Color(0xFFA5AEC2);

  /// `#3DA5AEC2`
  static const Color divider = Color(0x3DA5AEC2);

  /// `#FF6B6B`
  static const Color error = Color(0xFFFF6B6B);

  /// `#F4B740`
  static const Color warning = Color(0xFFF4B740);

  /// `#9B8AFB`
  static const Color accent = Color(0xFF9B8AFB);

  /// `#110D20`
  static const Color onAccent = Color(0xFF110D20);

  /// `#0F1522`
  static const Color mapBackground = Color(0xFF0F1522);

  /// `#D7DEEA`
  static const Color mapRowLabel = Color(0xFFD7DEEA);

  /// `#F4F7FB`
  static const Color mapText = Color(0xFFF4F7FB);

  /// `#9B8AFB`
  static const Color mapSelection = Color(0xFF9B8AFB);
}

/// The measured sizes the phone chrome is built from.
abstract final class SeatLayerSizeTokens {
  /// `640`
  static const double phoneBreakpoint = 640;

  /// `840`
  static const double wideBreakpoint = 840;

  /// `56`
  static const double headerHeight = 56;

  /// `28`
  static const double headerLogoSize = 28;

  /// `44`
  static const double topRailHeight = 44;

  /// `52`
  static const double dockBarHeight = 52;

  /// `50`
  static const double peekHeight = 50;

  /// `36`
  static const double sheetOpenHeadHeight = 36;

  /// `35`
  static const double sheetGrabberWidth = 35;

  /// `4`
  static const double sheetGrabberHeight = 4;

  /// `4`
  static const double sheetGrabberInset = 4;

  /// `44`
  static const double sheetToggleSize = 44;

  /// `28`
  static const double sheetToggleOpenSize = 28;

  /// `0.72`
  static const double sheetMaxHeightFraction = 0.72;

  /// `480`
  static const double sheetMaxHeight = 480;

  /// `0.64`
  static const double emptyTrayMaxHeightFraction = 0.64;

  /// `380`
  static const double emptyTrayMaxHeight = 380;

  /// `36`
  static const double findPillHeight = 36;

  /// `44`
  static const double denseLineHeight = 44;

  /// `4`
  static const int denseVisibleLines = 4;

  /// `6`
  static const int denseCollapseFrom = 6;

  /// `32`
  static const double denseRemoveSize = 32;

  /// `24`
  static const double denseRunToggleWidth = 24;

  /// `40`
  static const double denseMoreRowHeight = 40;

  /// `44`
  static const double checkoutButtonHeight = 44;

  /// `12`
  static const double confirmCardGutter = 12;

  /// `310`
  static const double confirmCardMaxWidth = 310;

  /// `14`
  static const double confirmCardRestInset = 14;

  /// `12`
  static const double confirmCardSeatGap = 12;

  /// `12`
  static const double confirmCardTopInset = 12;

  /// `18`
  static const double confirmCardClearance = 18;

  /// `42`
  static const double confirmIdentityHeight = 42;

  /// `30`
  static const double confirmBandHeight = 30;

  /// `64`
  static const double confirmPhotoHeight = 64;

  /// `44`
  static const double confirmRailHeight = 44;

  /// `28`
  static const double confirmPillHeight = 28;

  /// `38`
  static const double confirmTierHeight = 38;

  /// `44`
  static const double confirmActionHeight = 44;

  /// `44`
  static const double selectorHeight = 44;

  /// `34`
  static const double bestSeatsSelectHeight = 34;

  /// `112`
  static const double bestSeatsStepperWidth = 112;

  /// `44`
  static const double accessibilityControlSize = 44;

  /// `36`
  static const double mapControlSize = 36;

  /// `18`
  static const double attributionHeight = 18;

  /// `11`
  static const double legendChipFontSize = 11;

  /// `232`
  static const double toastCardLift = 232;

  /// `44`
  static const double minimumHitTarget = 44;
}

/// Corner radii.
abstract final class SeatLayerRadiusTokens {
  /// `14`
  static const double base = 14;

  /// `0.55`
  static const double smallRatio = 0.55;

  /// `18`
  static const double card = 18;

  /// `14`
  static const double sheet = 14;

  /// `9`
  static const double button = 9;

  /// `9`
  static const double control = 9;

  /// `15`
  static const double confirmCard = 15;

  /// `999`
  static const double chip = 999;

  /// `999`
  static const double pill = 999;
}

/// Material elevations.
abstract final class SeatLayerElevationTokens {
  /// `0`
  static const double header = 0;

  /// `8`
  static const double dockBar = 8;

  /// `12`
  static const double sheet = 12;

  /// `18`
  static const double confirmCard = 18;

  /// `0`
  static const double pill = 0;
}

/// Motion durations, in milliseconds.
abstract final class SeatLayerMotionTokens {
  /// Nothing in [durations] may exceed this.
  static const int budgetMs = 420;

  /// `260` ms
  static const int enter = 260;

  /// `180` ms
  static const int exit = 180;

  /// `240` ms
  static const int dock = 240;

  /// `300` ms
  static const int sheet = 300;

  /// `420` ms
  static const int fly = 420;

  /// `180` ms
  static const int pop = 180;

  /// `60` ms
  static const int stagger = 60;

  /// `120` ms
  static const int crossfade = 120;

  /// `240` ms
  static const int bump = 240;

  /// `240` ms
  static const int chevron = 240;

  /// `200` ms
  static const int toast = 200;

  /// `300` ms
  static const int immersive = 300;

  /// `360` ms
  static const int pressSweep = 360;

  /// `240` ms
  static const int cardEnter = 240;

  /// `4000` ms — deliberately outside the budget.
  static const int undoWindow = 4000;

  /// `300` ms — deliberately outside the budget.
  static const int inviteDelay = 300;

  /// `700` ms — deliberately outside the budget.
  static const int inviteSweep = 700;

  /// `1000` ms — deliberately outside the budget.
  static const int inviteBreatheDelay = 1000;

  /// `2400` ms — deliberately outside the budget.
  static const int inviteBreathe = 2400;

  /// `500` ms — deliberately outside the budget.
  static const int confirmFlight = 500;

  /// `4200` ms — deliberately outside the budget.
  static const int toastDwell = 4200;

  /// `900` ms — deliberately outside the budget.
  static const int revealDelay = 900;

  /// `650` ms — deliberately outside the budget.
  static const int shellSweep = 650;
}

/// Which platform haptic each cue fires.
abstract final class SeatLayerHapticTokens {
  /// `selection`
  static const String selectionAdded = 'selection';

  /// `light`
  static const String sectionFocused = 'light';

  /// `medium`
  static const String holdCreated = 'medium';

  /// `heavy`
  static const String holdExpired = 'heavy';

  /// `light`
  static const String cardArrived = 'light';

  /// `medium`
  static const String seatConfirmed = 'medium';

  /// `selection`
  static const String cardCancelled = 'selection';
}

/// The English default for every buyer-facing chrome string.
abstract final class SeatLayerStringTokens {
  /// Close seat selection
  static const String close = 'Close seat selection';

  /// Choose your seats
  static const String chooseSeats = 'Choose your seats';

  /// Venue
  static const String overview = 'Venue';

  /// All floors
  static const String allFloors = 'All floors';

  /// Previous section
  static const String previousSection = 'Previous section';

  /// Next section
  static const String nextSection = 'Next section';

  /// Back to venue
  static const String backToVenue = 'Back to venue';

  /// Cancel
  static const String cancel = 'Cancel';

  /// Select
  static const String select = 'Select';

  /// Add seat
  static const String addSeat = 'Add seat';

  /// Added
  static const String added = 'Added';

  /// Section
  static const String sectionWord = 'Section';

  /// Row
  static const String rowWord = 'Row';

  /// Seat
  static const String seatWord = 'Seat';

  /// Place
  static const String placeWord = 'Place';

  /// View from here
  static const String viewFromHere = 'View from here';

  /// 3D
  static const String venue3D = '3D';

  /// See it in 3D
  static const String seeItIn3D = 'See it in 3D';

  /// Open venue 360°
  static const String openVenue360 = 'Open venue 360°';

  /// Previous seat
  static const String previousSeat = 'Previous seat';

  /// Next seat
  static const String nextSeat = 'Next seat';

  /// Recentre the view
  static const String recentre = 'Recentre the view';

  /// view from your seat
  static const String viewFromYourSeat = 'view from your seat';

  /// Choose tickets
  static const String chooseTickets = 'Choose tickets';

  /// Tap a seat on the map, or let us pick the best available for you.
  static const String emptyTrayHint =
      'Tap a seat on the map, or let us pick the best available for you.';

  /// Any ticket type
  static const String anyTicketType = 'Any ticket type';

  /// Any venue zone
  static const String anyVenueZone = 'Any venue zone';

  /// All prices
  static const String allPrices = 'All prices';

  /// Ticket type
  static const String ticketType = 'Ticket type';

  /// Premium seat
  static const String premiumSeat = 'Premium seat';

  /// Restricted view
  static const String restrictedView = 'Restricted view';

  /// Obstructed view
  static const String obstructedView = 'Obstructed view';

  /// Venue zone
  static const String venueZone = 'Venue zone';

  /// Fewer tickets
  static const String fewerTickets = 'Fewer tickets';

  /// More tickets
  static const String moreTickets = 'More tickets';

  /// Best seats
  static const String bestSeats = 'Best seats';

  /// Finding the best seats…
  static const String findingBestSeats = 'Finding the best seats…';

  /// Find seats
  static const String findSeats = 'Find seats';

  /// Show less
  static const String showLess = 'Show less';

  /// Undo
  static const String undo = 'Undo';

  /// Hold seats & checkout
  static const String holdAndCheckout = 'Hold seats & checkout';

  /// Continue to checkout
  static const String continueToCheckout = 'Continue to checkout';

  /// Secure {count} more & checkout
  static const String secureMoreAndCheckout = 'Secure {count} more & checkout';

  /// Secure more
  static const String secureMore = 'Secure more';

  /// Select seats
  static const String selectSeats = 'Select seats';

  /// Pick your seats
  static const String pickYourSeats = 'Pick your seats';

  /// Sales are closed
  static const String salesClosedPill = 'Sales are closed';

  /// ✓ {count} secured · {total} — you won't be charged yet
  static const String peekSecured =
      '✓ {count} secured · {total} — you won\'t be charged yet';

  /// Seats secured. Opening checkout…
  static const String seatsSecuredOpeningCheckout =
      'Seats secured. Opening checkout…';

  /// Sales closed
  static const String salesClosedCta = 'Sales closed';

  /// Confirm or cancel this seat
  static const String confirmOrCancelSeat = 'Confirm or cancel this seat';

  /// Confirm your tickets
  static const String confirmYourTickets = 'Confirm your tickets';

  /// Securing your seats…
  static const String securingSeats = 'Securing your seats…';

  /// Opening secure checkout…
  static const String openingCheckout = 'Opening secure checkout…';

  /// Adjust your selection
  static const String adjustSelection = 'Adjust your selection';

  /// Powered by SeatLayer
  static const String poweredBy = 'Powered by SeatLayer';

  /// Test mode
  static const String testMode = 'Test mode';

  /// Test mode · books nothing
  static const String testModeLong = 'Test mode · books nothing';

  /// Accessibility and view filters
  static const String accessibility = 'Accessibility and view filters';

  /// Fit venue
  static const String fitVenue = 'Fit venue';

  /// Seat map
  static const String mapView = 'Seat map';

  /// Ticket removed
  static const String seatRemoved = 'Ticket removed';

  /// Loading seat map…
  static const String loading = 'Loading seat map…';

  /// The seat map could not be loaded.
  static const String errorMessage = 'The seat map could not be loaded.';

  /// Try again
  static const String retry = 'Try again';

  /// Accessibility and view
  static const String accessibilityTitle = 'Accessibility and view';

  /// Hide limited-view seats
  static const String hideLimitedView = 'Hide limited-view seats';

  /// Colourblind-friendly colours
  static const String colorblindSafe = 'Colourblind-friendly colours';

  /// Apply filters
  static const String applyFilters = 'Apply filters';

  /// Wheelchair
  static const String accessWheelchair = 'Wheelchair';

  /// Companion
  static const String accessCompanion = 'Companion';

  /// Semi-ambulatory
  static const String accessSemiAmbulatory = 'Semi-ambulatory';

  /// Aisle seat
  static const String accessDesignatedAisle = 'Aisle seat';

  /// Step-free
  static const String accessStepFree = 'Step-free';

  /// Hearing support
  static const String accessHearing = 'Hearing support';

  /// Mobility cart
  static const String accessCart = 'Mobility cart';

  /// Sign language view
  static const String accessSignLanguage = 'Sign language view';

  /// Low vision
  static const String accessLowVision = 'Low vision';

  /// Sensory-friendly
  static const String accessSensoryFriendly = 'Sensory-friendly';

  /// Plus-size seat
  static const String accessPlusSize = 'Plus-size seat';

  /// Lift armrest
  static const String accessLiftArmrest = 'Lift armrest';

  /// {need} · {count}
  static const String accessNeedWithCount = '{need} · {count}';

  /// Your seats were released.
  static const String holdLapsedTitle = 'Your seats were released.';

  /// They were held for {n} minutes.
  static const String holdLapsedBody = 'They were held for {n} minutes.';

  /// Select it again
  static const String reselectSeatsOne = 'Select it again';

  /// Select them again
  static const String reselectSeatsOther = 'Select them again';

  /// {n} could not be recovered
  static const String seatsNotRecovered = '{n} could not be recovered';

  /// Remove ticket
  static const String removeSeat = 'Remove ticket';

  /// Open ticket panel
  static const String expandCart = 'Open ticket panel';

  /// Collapse ticket panel
  static const String collapseCart = 'Collapse ticket panel';

  /// Rotate venue
  static const String orbitMode = 'Rotate venue';

  /// Move venue
  static const String panMode = 'Move venue';

  /// General admission
  static const String generalAdmission = 'General admission';

  /// Choose the number of guests for this table
  static const String chooseTableGuests =
      'Choose the number of guests for this table';

  /// Confirm table
  static const String confirmTable = 'Confirm table';

  /// Add tickets
  static const String addTickets = 'Add tickets';

  /// Select a ticket type
  static const String selectTicketTier = 'Select a ticket type';

  /// Requires the adjacent wheelchair place.
  static const String tierCompanionGuidance =
      'Requires the adjacent wheelchair place.';

  /// {count} places currently available
  static const String placesAvailable = '{count} places currently available';

  /// Continue · {money}
  static const String continueWithTotal = 'Continue · {money}';

  /// Continue
  static const String continueWord = 'Continue';

  /// From {price}
  static const String fromPrice = 'From {price}';

  /// Find {count} best seats
  static const String findBestSeats = 'Find {count} best seats';

  /// Find {count} best seat
  static const String findBestSeatsOne = 'Find {count} best seat';

  /// Find {count} best seats
  static const String findBestSeatsOther = 'Find {count} best seats';

  /// {clock}
  static const String heldFor = '{clock}';

  /// +{count} more
  static const String moreCount = '+{count} more';

  /// Drag to move venue
  static const String moveVenue = 'Drag to move venue';

  /// Place {place}
  static const String placeNumberIdentity = 'Place {place}';

  /// Select them again
  static const String reselectSeats = 'Select them again';

  /// {parts}
  static const String seatIdentity = '{parts}';

  /// {count} seats
  static const String seatsFree = '{count} seats';

  /// {count} seat
  static const String seatsFreeOne = '{count} seat';

  /// {count} seats
  static const String seatsFreeOther = '{count} seats';

  /// {count} left
  static const String seatsLeft = '{count} left';

  /// Only {count} left
  static const String onlyLeft = 'Only {count} left';

  /// Choose {count} more
  static const String chooseMore = 'Choose {count} more';

  /// Remove {count} tickets
  static const String removeTickets = 'Remove {count} tickets';

  /// Remove {count} ticket
  static const String removeTicketsOne = 'Remove {count} ticket';

  /// Remove {count} tickets
  static const String removeTicketsOther = 'Remove {count} tickets';

  /// {count} tickets
  static const String ticketCount = '{count} tickets';

  /// {count} ticket
  static const String ticketCountOne = '{count} ticket';

  /// {count} tickets
  static const String ticketCountOther = '{count} tickets';

  /// Row {row}
  static const String rowIdentity = 'Row {row}';

  /// Drag to rotate venue
  static const String rotateVenue = 'Drag to rotate venue';

  /// Seat {seat}
  static const String seatNumberIdentity = 'Seat {seat}';

  /// Sales are closed
  static const String salesClosed = 'Sales are closed';

  /// Ticket sales for this event have ended.
  static const String salesClosedCopy =
      'Ticket sales for this event have ended.';

  /// Sales are closed for this event.
  static const String salesClosedToast = 'Sales are closed for this event.';

  /// This event
  static const String soldOutEyebrow = 'This event';

  /// Sold out
  static const String soldOutTitle = 'Sold out';

  /// No reserved seats are currently available for this event.
  static const String soldOutCopy =
      'No reserved seats are currently available for this event.';

  /// Your hold expired — the seats were released. Pick again.
  static const String holdExpired =
      'Your hold expired — the seats were released. Pick again.';

  /// Your hold ended while you were away. That seat is still free.
  static const String holdLapsedStillFreeOne =
      'Your hold ended while you were away. That seat is still free.';

  /// Your hold ended while you were away. Those seats are still free.
  static const String holdLapsedStillFreeOther =
      'Your hold ended while you were away. Those seats are still free.';

  /// Your hold ended while you were away, and {count} of those seats has been taken. The rest are still free.
  static const String holdLapsedSomeTakenOne =
      'Your hold ended while you were away, and {count} of those seats has been taken. The rest are still free.';

  /// Your hold ended while you were away, and {count} of those seats have been taken. The rest are still free.
  static const String holdLapsedSomeTakenOther =
      'Your hold ended while you were away, and {count} of those seats have been taken. The rest are still free.';

  /// Your hold ended while you were away, and that seat has been taken.
  static const String holdLapsedAllTakenOne =
      'Your hold ended while you were away, and that seat has been taken.';

  /// Your hold ended while you were away, and those seats have been taken.
  static const String holdLapsedAllTakenOther =
      'Your hold ended while you were away, and those seats have been taken.';

  /// Your seats are held for {time}. Need more time?
  static const String seatsHeldForNeedMoreTime =
      'Your seats are held for {time}. Need more time?';

  /// Add time
  static const String addTime = 'Add time';

  /// Adding…
  static const String addingEllipsis = 'Adding…';

  /// More time added — your seats are still held.
  static const String moreTimeAdded =
      'More time added — your seats are still held.';

  /// Couldn't add more time — please head to checkout now.
  static const String couldNotAddMoreTime =
      'Couldn\'t add more time — please head to checkout now.';

  /// Seat {label} was just taken by another buyer.
  static const String seatJustTakenByAnother =
      'Seat {label} was just taken by another buyer.';

  /// One or more seats were just taken. Please pick again.
  static const String seatsJustTaken =
      'One or more seats were just taken. Please pick again.';

  /// You're all set
  static const String allSetTitle = 'You\'re all set';

  /// confirmed. A confirmation is on its way.
  static const String confirmedAndOnWay =
      'confirmed. A confirmation is on its way.';

  /// Back to map
  static const String backToMap = 'Back to map';

  /// The seat map didn't load
  static const String mapDidNotLoad = 'The seat map didn\'t load';

  /// Check your connection and try again.
  static const String checkConnection = 'Check your connection and try again.';

  /// These seats are on hold right now
  static const String accessPausedTitle = 'These seats are on hold right now';

  /// The organizer has paused this selection. Try again in a few minutes.
  static const String accessPausedCopy =
      'The organizer has paused this selection. Try again in a few minutes.';

  /// This access link is no longer active
  static const String accessRevokedTitle =
      'This access link is no longer active';

  /// Ask whoever sent you here for a new link to keep booking these seats.
  static const String accessRevokedCopy =
      'Ask whoever sent you here for a new link to keep booking these seats.';

  /// Your seat session has expired
  static const String accessExpiredTitle = 'Your seat session has expired';

  /// Reload the seat map to continue. Seats already in your cart stay held until the timer ends.
  static const String accessExpiredCopy =
      'Reload the seat map to continue. Seats already in your cart stay held until the timer ends.';

  /// We couldn't verify your access
  static const String accessUnverifiedTitle = 'We couldn\'t verify your access';

  /// You can still book anything shown as available. Contact whoever sent you here for access to the rest.
  static const String accessUnverifiedCopy =
      'You can still book anything shown as available. Contact whoever sent you here for access to the rest.';

  /// Reload seat map
  static const String reloadSeatMap = 'Reload seat map';

  /// No selectable seats are currently available.
  static const String noSelectableSeats =
      'No selectable seats are currently available.';

  /// Number of guests
  static const String numberOfGuests = 'Number of guests';

  /// Choose how many guests will sit together. This table is held exclusively for your party.
  static const String chooseGuestsCopy =
      'Choose how many guests will sit together. This table is held exclusively for your party.';

  /// Fewer guests
  static const String fewerGuests = 'Fewer guests';

  /// More guests
  static const String moreGuests = 'More guests';

  /// Choose between {min} and {max} guests.
  static const String chooseMinMaxGuests =
      'Choose between {min} and {max} guests.';

  /// Select table
  static const String selectTable = 'Select table';

  /// Update table
  static const String updateTable = 'Update table';

  /// Remove
  static const String removeWord = 'Remove';
}
