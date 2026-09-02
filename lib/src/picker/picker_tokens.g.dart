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

  /// `56`
  static const double peekHeight = 56;

  /// `0.6`
  static const double sheetMaxHeightFraction = 0.6;

  /// `190`
  static const double emptyTrayMaxHeight = 190;

  /// `44`
  static const double denseLineHeight = 44;

  /// `5`
  static const int denseVisibleLines = 5;

  /// `16`
  static const double confirmCardGutter = 16;

  /// `360`
  static const double confirmCardMaxWidth = 360;

  /// `56`
  static const double confirmIdentityHeight = 56;

  /// `34`
  static const double confirmBandHeight = 34;

  /// `64`
  static const double confirmPhotoHeight = 64;

  /// `44`
  static const double confirmActionHeight = 44;

  /// `44`
  static const double selectorHeight = 44;

  /// `44`
  static const double accessibilityControlSize = 44;

  /// `36`
  static const double mapControlSize = 36;

  /// `18`
  static const double attributionHeight = 18;

  /// `11`
  static const double legendChipFontSize = 11;

  /// `44`
  static const double minimumHitTarget = 44;
}

/// Corner radii.
abstract final class SeatLayerRadiusTokens {
  /// `14`
  static const double base = 14;

  /// `18`
  static const double card = 18;

  /// `14`
  static const double sheet = 14;

  /// `8`
  static const double button = 8;

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

  /// `200` ms
  static const int toast = 200;

  /// `300` ms
  static const int immersive = 300;

  /// `300` ms
  static const int pressSweep = 300;

  /// `4000` ms — deliberately outside the budget.
  static const int undoWindow = 4000;

  /// `700` ms — deliberately outside the budget.
  static const int inviteSweep = 700;

  /// `1600` ms — deliberately outside the budget.
  static const int inviteBreathe = 1600;
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

  /// Venue zone
  static const String venueZone = 'Venue zone';

  /// Fewer tickets
  static const String fewerTickets = 'Fewer tickets';

  /// More tickets
  static const String moreTickets = 'More tickets';

  /// Best seats
  static const String bestSeats = 'Best seats';

  /// Find seats
  static const String findSeats = 'Find seats';

  /// Show less
  static const String showLess = 'Show less';

  /// Undo
  static const String undo = 'Undo';

  /// Hold seats & checkout
  static const String holdAndCheckout = 'Hold seats & checkout';

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

  /// Expand cart
  static const String expandCart = 'Expand cart';

  /// Collapse cart
  static const String collapseCart = 'Collapse cart';

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

  /// Find {count} seats together
  static const String findBestSeats = 'Find {count} seats together';

  /// Find {count} seat
  static const String findBestSeatsOne = 'Find {count} seat';

  /// Find {count} seats together
  static const String findBestSeatsOther = 'Find {count} seats together';

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
}
