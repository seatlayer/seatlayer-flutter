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
  /// `#FFFFFF`
  static const Color background = Color(0xFFFFFFFF);

  /// `#F6F7FB`
  static const Color surface = Color(0xFFF6F7FB);

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

  /// `#FFFFFF`
  static const Color chrome = Color(0xFFFFFFFF);

  /// `#8C172033`
  static const Color chromeLine = Color(0x8C172033);
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

  /// `#9E0A0E14`
  static const Color immersiveGlass = Color(0x9E0A0E14);

  /// `#38FFFFFF`
  static const Color immersiveGlassBorder = Color(0x38FFFFFF);

  /// `#E6EDF3`
  static const Color immersiveGlassInk = Color(0xFFE6EDF3);

  /// `#D10A0E16`
  static const Color immersiveCaption = Color(0xD10A0E16);

  /// `#33FFFFFF`
  static const Color immersiveCaptionBorder = Color(0x33FFFFFF);

  /// `#EEF3FB`
  static const Color immersiveCaptionInk = Color(0xFFEEF3FB);

  /// `#556278`
  static const Color chrome = Color(0xFF556278);

  /// `#8CE9EEF7`
  static const Color chromeLine = Color(0x8CE9EEF7);
}

/// The measured sizes the phone chrome is built from.
abstract final class SeatLayerSizeTokens {
  /// `640`
  static const double phoneBreakpoint = 640;

  /// `840`
  static const double wideBreakpoint = 840;

  /// `38`
  static const double headerHeight = 38;

  /// `22`
  static const double headerLogoSize = 22;

  /// `26`
  static const double headerCloseSize = 26;

  /// `12.5`
  static const double headerNameFontSize = 12.5;

  /// `44`
  static const double topRailHeight = 44;

  /// `52`
  static const double dockBarHeight = 52;

  /// `58`
  static const double peekHeight = 58;

  /// `8`
  static const double peekClockLift = 8;

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

  /// `0.92`
  static const double sheetFullHeightFraction = 0.92;

  /// `48`
  static const double findPillHeight = 48;

  /// `48`
  static const double peekButtonHeight = 48;

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

  /// `9`
  static const double confirmIdentityKeyFontSize = 9;

  /// `18`
  static const double confirmIdentityValueFontSize = 18;

  /// `12.5`
  static const double confirmIdentityLongSectionFontSize = 12.5;

  /// `6`
  static const int confirmSectionShortMax = 6;

  /// `30`
  static const double confirmBandHeight = 30;

  /// `15`
  static const double confirmBandNameFontSize = 15;

  /// `18`
  static const double confirmBandPriceFontSize = 18;

  /// `11`
  static const double confirmBandPadTop = 11;

  /// `11`
  static const double confirmBandPadBottom = 11;

  /// `14`
  static const double confirmBandPadLeading = 14;

  /// `16`
  static const double confirmBandPadTrailing = 16;

  /// `64`
  static const double confirmPhotoHeight = 64;

  /// `44`
  static const double confirmRailHeight = 44;

  /// `28`
  static const double confirmPillHeight = 28;

  /// `10`
  static const double confirmSightFont = 10;

  /// `8`
  static const double confirmSightPadX = 8;

  /// `3`
  static const double confirmSightPadY = 3;

  /// `38`
  static const double confirmTierHeight = 38;

  /// `44`
  static const double confirmActionHeight = 44;

  /// `9.5`
  static const double confirm3dSquareFontSize = 9.5;

  /// `40`
  static const double confirmInspectChipHeight = 40;

  /// `11.5`
  static const double confirmInspectChipFontSize = 11.5;

  /// `342`
  static const double confirmCardImmersiveMaxWidth = 342;

  /// `10`
  static const double confirmCardImmersiveRestInset = 10;

  /// `8`
  static const double confirmImmersiveCellTop = 8;

  /// `9`
  static const double confirmImmersiveCellSide = 9;

  /// `7`
  static const double confirmImmersiveCellBottom = 7;

  /// `17`
  static const double confirmImmersiveValueFontSize = 17;

  /// `7`
  static const double confirmImmersiveBandPadY = 7;

  /// `10`
  static const double confirmImmersiveBandPadX = 10;

  /// `17`
  static const double confirmImmersiveBandPriceFontSize = 17;

  /// `12`
  static const double confirmImmersiveSectionFontSize = 12;

  /// `8`
  static const double confirmImmersiveBodyTop = 8;

  /// `9`
  static const double confirmImmersiveBodyBottom = 9;

  /// `9`
  static const double confirmImmersiveInspectGap = 9;

  /// `7`
  static const double confirmImmersiveActionGap = 7;

  /// `44`
  static const double confidenceTeaserMinHeight = 44;

  /// `8`
  static const double confidenceTeaserTop = 8;

  /// `10`
  static const double confidenceTeaserPadX = 10;

  /// `8`
  static const double confidenceTeaserPadY = 8;

  /// `9`
  static const double confidenceTeaserRadius = 9;

  /// `11`
  static const double confidenceTeaserHeadFont = 11;

  /// `9.5`
  static const double confidenceTeaserDetailFont = 9.5;

  /// `11`
  static const double confidenceTeaserBadgeFont = 11;

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

  /// `24`
  static const double legendChipHeight = 24;

  /// `7`
  static const double legendChipDotSize = 7;

  /// `18`
  static const double legendRailEdgeFade = 18;

  /// `36`
  static const double viewModeControlHeight = 36;

  /// `38`
  static const double viewModeButtonMinWidth = 38;

  /// `28`
  static const double viewModeButtonHeight = 28;

  /// `9.5`
  static const double viewModeLabelFontSize = 9.5;

  /// `26`
  static const double testChipHeight = 26;

  /// `7`
  static const double testChipDotSize = 7;

  /// `11`
  static const double testChipFontSize = 11;

  /// `12`
  static const double mapAnchorInset = 12;

  /// `12`
  static const double mapAnchorGap = 12;

  /// `6`
  static const double zoomColumnGap = 6;

  /// `3`
  static const double floorRailPadding = 3;

  /// `1`
  static const double floorRailGap = 1;

  /// `28`
  static const double floorChipHeight = 28;

  /// `10`
  static const double floorChipPaddingX = 10;

  /// `10.5`
  static const double floorChipFontSize = 10.5;

  /// `26`
  static const double floorInfoSize = 26;

  /// `10`
  static const double dockDotSize = 10;

  /// `14`
  static const double dockLeadingInset = 14;

  /// `8`
  static const double dockTrailingInset = 8;

  /// `12.5`
  static const double dockNameFontSize = 12.5;

  /// `12.5`
  static const double dockCountFontSize = 12.5;

  /// `34`
  static const double dockNavWidth = 34;

  /// `36`
  static const double dockNavHeight = 36;

  /// `2`
  static const double dockNavGap = 2;

  /// `18`
  static const double dockNavIconSize = 18;

  /// `36`
  static const double dockBackHeight = 36;

  /// `12.5`
  static const double dockBackFontSize = 12.5;

  /// `18`
  static const double dockBackChevronSize = 18;

  /// `44`
  static const double immersiveBackPillHeight = 44;

  /// `11`
  static const double immersiveBackFontSize = 11;

  /// `15`
  static const double immersiveBackIconSize = 15;

  /// `32`
  static const double immersiveNavChipHeight = 32;

  /// `12`
  static const double immersiveNavChipPaddingX = 12;

  /// `12.5`
  static const double immersiveNavChipFontSize = 12.5;

  /// `32`
  static const double immersiveNavCloseSize = 32;

  /// `11.5`
  static const double immersiveCaptionFontSize = 11.5;

  /// `6`
  static const double immersiveGlassBlur = 6;

  /// `8`
  static const double immersiveCaptionBlur = 8;

  /// `20`
  static const double accessRowIconCell = 20;

  /// `10`
  static const double accessRowGap = 10;

  /// `8`
  static const double accessRowPaddingX = 8;

  /// `6`
  static const double accessRowPaddingY = 6;

  /// `12.5`
  static const double accessRowLabelFontSize = 12.5;

  /// `10.5`
  static const double accessRowNoteFontSize = 10.5;

  /// `34`
  static const double accessSwitchWidth = 34;

  /// `20`
  static const double accessSwitchHeight = 20;

  /// `16`
  static const double accessSwitchKnob = 16;

  /// `30`
  static const double accessStepHeight = 30;

  /// `9`
  static const double accessStepPaddingX = 9;

  /// `5`
  static const double accessStepGap = 5;

  /// `11`
  static const double accessStepFontSize = 11;

  /// `232`
  static const double toastCardLift = 232;

  /// `56`
  static const double confirmScrimClearRadius = 56;

  /// `88`
  static const double confirmScrimFeatherRadius = 88;

  /// `4`
  static const double confirmScrimBlur = 4;

  /// `44`
  static const double minimumHitTarget = 44;
}

/// How far each surface lets the platform grow its type.
///
/// A clamp is a promise about a layout, not a preference: past
/// it the surface would clip or overflow rather than read
/// larger. Surfaces that own the screen are absent on purpose.
abstract final class SeatLayerTypeScaleTokens {
  /// `1.3`
  static const double rail = 1.3;

  /// `1.3`
  static const double dock = 1.3;

  /// `1.3`
  static const double peek = 1.3;

  /// `1.3`
  static const double card = 1.3;

  /// `1.6`
  static const double sheet = 1.6;

  /// `1.6`
  static const double state = 1.6;
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

  /// `12`
  static const double peekButton = 12;

  /// `999`
  static const double chip = 999;

  /// `6`
  static const double headerLogo = 6;

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

/// Opacities that carry a meaning of their own.
///
/// Not decoration: each one is a state the buyer is being
/// told about, and it is the same number on every platform.
abstract final class SeatLayerOpacityTokens {
  /// `0.45`
  static const double removing = 0.45;

  /// `0.18`
  static const double warnPillWash = 0.18;

  /// `0.38`
  static const double confirmScrim = 0.38;

  /// `0.5`
  static const double confirmScrimFlat = 0.5;
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

  /// `160` ms
  static const int thumbOut = 160;

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

/// What a finger on glass is answered with.
///
/// Native-only: the web picker has no simulation to feed.
abstract final class SeatLayerPhysicsTokens {
  /// `1`
  static const double sheetSpringMass = 1;

  /// `420`
  static const double sheetSpringStiffness = 420;

  /// `34`
  static const double sheetSpringDamping = 34;

  /// `320`
  static const double sheetFlingVelocity = 320;

  /// `0.35`
  static const double rubberBand = 0.35;

  /// `0.4`
  static const double swipeCommitFraction = 0.4;

  /// `700`
  static const double swipeFlingVelocity = 700;
}

/// Which platform haptic each cue fires.
abstract final class SeatLayerHapticTokens {
  /// `selection`
  static const String selectionAdded = 'selection';

  /// `selection`
  static const String sectionFocused = 'selection';

  /// `light`
  static const String ticketRemoved = 'light';

  /// `warning`
  static const String holdEnding = 'warning';

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

  /// ≈ {m} m to stage
  static const String sightline = '≈ {m} m to stage';

  /// Passport
  static const String passport = 'Passport';

  /// 3D
  static const String venue3D = '3D';

  /// See it in 3D
  static const String seeItIn3D = 'See it in 3D';

  /// View from this seat
  static const String viewFromThisSeat = 'View from this seat';

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

  /// Bookings here are not real and no card is charged
  static const String testModeExplained =
      'Bookings here are not real and no card is charged';

  /// Accessibility and view filters
  static const String accessibility = 'Accessibility and view filters';

  /// Display options
  static const String displayOptions = 'Display options';

  /// {count} free
  static const String accessFreeCount = '{count} free';

  /// None left
  static const String accessNoneLeft = 'None left';

  /// {index} of {total}
  static const String accessibleStep = '{index} of {total}';

  /// {count} sections
  static const String accessibleSections = '{count} sections';

  /// Jump to the first section
  static const String accessJumpFirstSection = 'Jump to the first section';

  /// Jump to the next section
  static const String accessJumpNextSection = 'Jump to the next section';

  /// Companion places beside them stay selectable
  static const String companionSeatsNote =
      'Companion places beside them stay selectable';

  /// Fit venue
  static const String fitVenue = 'Fit venue';

  /// Zoom in
  static const String zoomIn = 'Zoom in';

  /// Zoom out
  static const String zoomOut = 'Zoom out';

  /// Map
  static const String mapView = 'Map';

  /// Flat 2D map
  static const String flat2dMap = 'Flat 2D map';

  /// Interactive 3D venue view
  static const String interactive3dVenueView = 'Interactive 3D venue view';

  /// Venue view
  static const String venueView = 'Venue view';

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

  /// +{count} min
  static const String addMinutes = '+{count} min';

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

  /// {count} seat left
  static const String seatsLeftInSectionOne = '{count} seat left';

  /// {count} seats left
  static const String seatsLeftInSectionOther = '{count} seats left';

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

  /// {venue} seat map
  static const String venueMap = '{venue} seat map';

  /// Seats are picked with the controls around the map: the price rail above it, the section controls below it, and the ticket panel at the foot.
  static const String venueMapHint =
      'Seats are picked with the controls around the map: the price rail above it, the section controls below it, and the ticket panel at the foot.';

  /// {count} minute left
  static const String holdMinutesLeftOne = '{count} minute left';

  /// {count} minutes left
  static const String holdMinutesLeftOther = '{count} minutes left';

  /// {count} second left
  static const String holdSecondsLeftOne = '{count} second left';

  /// {count} seconds left
  static const String holdSecondsLeftOther = '{count} seconds left';
}
