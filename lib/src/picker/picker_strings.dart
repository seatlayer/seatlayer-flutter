import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'picker_strings_locales.g.dart';
import 'picker_tokens.g.dart';

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
    this.close = SeatLayerStringTokens.close,
    this.chooseSeats = SeatLayerStringTokens.chooseSeats,
    this.overview = SeatLayerStringTokens.overview,
    this.allFloors = SeatLayerStringTokens.allFloors,
    this.previousSection = SeatLayerStringTokens.previousSection,
    this.nextSection = SeatLayerStringTokens.nextSection,
    this.backToVenue = SeatLayerStringTokens.backToVenue,
    this.cancel = SeatLayerStringTokens.cancel,
    this.select = SeatLayerStringTokens.select,
    this.addSeat = SeatLayerStringTokens.addSeat,
    this.added = SeatLayerStringTokens.added,
    this.sectionWord = SeatLayerStringTokens.sectionWord,
    this.rowWord = SeatLayerStringTokens.rowWord,
    this.seatWord = SeatLayerStringTokens.seatWord,
    this.placeWord = SeatLayerStringTokens.placeWord,
    this.viewFromHere = SeatLayerStringTokens.viewFromHere,
    this.venue3D = SeatLayerStringTokens.venue3D,
    this.seeItIn3D = SeatLayerStringTokens.seeItIn3D,
    this.openVenue360 = SeatLayerStringTokens.openVenue360,
    this.previousSeat = SeatLayerStringTokens.previousSeat,
    this.nextSeat = SeatLayerStringTokens.nextSeat,
    this.recentre = SeatLayerStringTokens.recentre,
    this.viewFromYourSeat = SeatLayerStringTokens.viewFromYourSeat,
    this.chooseTickets = SeatLayerStringTokens.chooseTickets,
    this.emptyTrayHint = SeatLayerStringTokens.emptyTrayHint,
    this.anyTicketType = SeatLayerStringTokens.anyTicketType,
    this.anyVenueZone = SeatLayerStringTokens.anyVenueZone,
    this.allPrices = SeatLayerStringTokens.allPrices,
    this.ticketType = SeatLayerStringTokens.ticketType,
    this.tierCompanionGuidance = SeatLayerStringTokens.tierCompanionGuidance,
    this.premiumSeat = SeatLayerStringTokens.premiumSeat,
    this.restrictedView = SeatLayerStringTokens.restrictedView,
    this.obstructedView = SeatLayerStringTokens.obstructedView,
    this.venueZone = SeatLayerStringTokens.venueZone,
    this.fewerTickets = SeatLayerStringTokens.fewerTickets,
    this.moreTickets = SeatLayerStringTokens.moreTickets,
    this.bestSeats = SeatLayerStringTokens.bestSeats,
    this.findingBestSeats = SeatLayerStringTokens.findingBestSeats,
    this.findSeats = SeatLayerStringTokens.findSeats,
    this.showLess = SeatLayerStringTokens.showLess,
    this.expandCart = SeatLayerStringTokens.expandCart,
    this.collapseCart = SeatLayerStringTokens.collapseCart,
    this.undo = SeatLayerStringTokens.undo,
    this.holdAndCheckout = SeatLayerStringTokens.holdAndCheckout,
    this.continueToCheckout = SeatLayerStringTokens.continueToCheckout,
    this.secureMore = SeatLayerStringTokens.secureMore,
    this.selectSeats = SeatLayerStringTokens.selectSeats,
    this.pickYourSeats = SeatLayerStringTokens.pickYourSeats,
    this.salesClosedPill = SeatLayerStringTokens.salesClosedPill,
    this.seatsSecuredOpeningCheckout =
        SeatLayerStringTokens.seatsSecuredOpeningCheckout,
    this.secureMoreAndCheckout = _defaultSecureMoreAndCheckout,
    this.peekSecured = _defaultPeekSecured,
    this.continueWord = SeatLayerStringTokens.continueWord,
    this.salesClosedCta = SeatLayerStringTokens.salesClosedCta,
    this.confirmOrCancelSeat = SeatLayerStringTokens.confirmOrCancelSeat,
    this.confirmYourTickets = SeatLayerStringTokens.confirmYourTickets,
    this.securingSeats = SeatLayerStringTokens.securingSeats,
    this.openingCheckout = SeatLayerStringTokens.openingCheckout,
    this.adjustSelection = SeatLayerStringTokens.adjustSelection,
    this.chooseMore = _defaultChooseMore,
    this.removeTickets = _defaultRemoveTickets,
    this.poweredBy = SeatLayerStringTokens.poweredBy,
    this.testMode = SeatLayerStringTokens.testMode,
    this.testModeLong = SeatLayerStringTokens.testModeLong,
    this.testModeExplained = SeatLayerStringTokens.testModeExplained,
    this.accessibility = SeatLayerStringTokens.accessibility,
    this.displayOptions = SeatLayerStringTokens.displayOptions,
    this.accessNoneLeft = SeatLayerStringTokens.accessNoneLeft,
    this.companionSeatsNote = SeatLayerStringTokens.companionSeatsNote,
    this.accessFreeCount = _defaultAccessFreeCount,
    this.fitVenue = SeatLayerStringTokens.fitVenue,
    this.zoomIn = SeatLayerStringTokens.zoomIn,
    this.zoomOut = SeatLayerStringTokens.zoomOut,
    this.rotateVenue = SeatLayerStringTokens.rotateVenue,
    this.moveVenue = SeatLayerStringTokens.moveVenue,
    this.mapView = SeatLayerStringTokens.mapView,
    this.flat2dMap = SeatLayerStringTokens.flat2dMap,
    this.interactive3dVenueView = SeatLayerStringTokens.interactive3dVenueView,
    this.venueView = SeatLayerStringTokens.venueView,
    this.seatRemoved = SeatLayerStringTokens.seatRemoved,
    this.loading = SeatLayerStringTokens.loading,
    this.errorMessage = SeatLayerStringTokens.errorMessage,
    this.retry = SeatLayerStringTokens.retry,
    this.accessibilityTitle = SeatLayerStringTokens.accessibilityTitle,
    this.hideLimitedView = SeatLayerStringTokens.hideLimitedView,
    this.colorblindSafe = SeatLayerStringTokens.colorblindSafe,
    this.applyFilters = SeatLayerStringTokens.applyFilters,
    this.holdLapsedTitle = SeatLayerStringTokens.holdLapsedTitle,
    this.accessNeeds = defaultAccessNeeds,
    this.accessNeedWithCount = _defaultAccessNeedWithCount,
    this.holdLapsedBody = _defaultHoldLapsedBody,
    this.reselectSeats = _defaultReselectSeats,
    this.seatsNotRecovered = _defaultSeatsNotRecovered,
    this.ticketCount = _defaultTicketCount,
    this.seatsLeft = _defaultSeatsLeft,
    this.seatsLeftInSection = _defaultSeatsLeftInSection,
    this.onlyLeft = _defaultOnlyLeft,
    this.seatsFree = _defaultSeatsFree,
    this.fromPrice = _defaultFromPrice,
    this.continueWithTotal = _defaultContinueWithTotal,
    this.findBestSeats = _defaultFindBestSeats,
    this.moreCount = _defaultMoreCount,
    this.heldFor = _defaultHeldFor,
    this.seatIdentity = _defaultSeatIdentity,
    this.salesClosed = SeatLayerStringTokens.salesClosed,
    this.salesClosedCopy = SeatLayerStringTokens.salesClosedCopy,
    this.salesClosedToast = SeatLayerStringTokens.salesClosedToast,
    this.soldOutEyebrow = SeatLayerStringTokens.soldOutEyebrow,
    this.soldOutTitle = SeatLayerStringTokens.soldOutTitle,
    this.soldOutCopy = SeatLayerStringTokens.soldOutCopy,
    this.holdExpired = SeatLayerStringTokens.holdExpired,
    this.addTime = SeatLayerStringTokens.addTime,
    this.addingEllipsis = SeatLayerStringTokens.addingEllipsis,
    this.moreTimeAdded = SeatLayerStringTokens.moreTimeAdded,
    this.couldNotAddMoreTime = SeatLayerStringTokens.couldNotAddMoreTime,
    this.seatsJustTaken = SeatLayerStringTokens.seatsJustTaken,
    this.allSetTitle = SeatLayerStringTokens.allSetTitle,
    this.confirmedAndOnWay = SeatLayerStringTokens.confirmedAndOnWay,
    this.backToMap = SeatLayerStringTokens.backToMap,
    this.mapDidNotLoad = SeatLayerStringTokens.mapDidNotLoad,
    this.checkConnection = SeatLayerStringTokens.checkConnection,
    this.accessPausedTitle = SeatLayerStringTokens.accessPausedTitle,
    this.accessPausedCopy = SeatLayerStringTokens.accessPausedCopy,
    this.accessRevokedTitle = SeatLayerStringTokens.accessRevokedTitle,
    this.accessRevokedCopy = SeatLayerStringTokens.accessRevokedCopy,
    this.accessExpiredTitle = SeatLayerStringTokens.accessExpiredTitle,
    this.accessExpiredCopy = SeatLayerStringTokens.accessExpiredCopy,
    this.accessUnverifiedTitle = SeatLayerStringTokens.accessUnverifiedTitle,
    this.accessUnverifiedCopy = SeatLayerStringTokens.accessUnverifiedCopy,
    this.reloadSeatMap = SeatLayerStringTokens.reloadSeatMap,
    this.noSelectableSeats = SeatLayerStringTokens.noSelectableSeats,
    this.numberOfGuests = SeatLayerStringTokens.numberOfGuests,
    this.chooseGuestsCopy = SeatLayerStringTokens.chooseGuestsCopy,
    this.fewerGuests = SeatLayerStringTokens.fewerGuests,
    this.moreGuests = SeatLayerStringTokens.moreGuests,
    this.selectTable = SeatLayerStringTokens.selectTable,
    this.updateTable = SeatLayerStringTokens.updateTable,
    this.removeWord = SeatLayerStringTokens.removeWord,
    this.generalAdmission = SeatLayerStringTokens.generalAdmission,
    this.addTickets = SeatLayerStringTokens.addTickets,
    this.holdLapsedStillFree = _defaultHoldLapsedStillFree,
    this.holdLapsedSomeTaken = _defaultHoldLapsedSomeTaken,
    this.holdLapsedAllTaken = _defaultHoldLapsedAllTaken,
    this.seatsHeldForNeedMoreTime = _defaultSeatsHeldForNeedMoreTime,
    this.seatJustTakenByAnother = _defaultSeatJustTakenByAnother,
    this.chooseMinMaxGuests = _defaultChooseMinMaxGuests,
    this.placesAvailable = _defaultPlacesAvailable,
  });

  /// The defaults for [locale], falling back to English.
  ///
  /// The wording comes from the SeatLayer runtime's own dictionaries, so the
  /// drawn map and the native chrome around it say the same things in the same
  /// words. Thirty-seven locales are translated; anything else, and any single
  /// string the runtime has no equivalent for, keeps the English default.
  ///
  /// This is a starting point, never a ceiling: the result is an ordinary
  /// [SeatLayerPickerStrings], so a host overrides any entry the usual way.
  ///
  /// ```dart
  /// options: SeatLayerPickerOptions(
  ///   strings: SeatLayerPickerStrings.forLocale(Localizations.localeOf(context)),
  /// )
  /// ```
  static SeatLayerPickerStrings forLocale(Locale locale) {
    for (final tag in _candidates(locale)) {
      final match = seatLayerPickerStringsByLocale[tag];
      if (match != null) return match;
    }
    return const SeatLayerPickerStrings();
  }

  /// The dictionary names [locale] could be, most specific first.
  static Iterable<String> _candidates(Locale locale) sync* {
    final language = locale.languageCode;
    final script = locale.scriptCode;
    if (script != null) yield '$language-$script';
    final country = locale.countryCode;
    if (country != null) yield '$language-$country';
    // Chinese is the one language the runtime splits by script rather than by
    // region, and a bare `zh` is Simplified far more often than not.
    if (script == null && language == 'zh') {
      yield country == 'TW' || country == 'HK' || country == 'MO'
          ? 'zh-Hant'
          : 'zh-Hans';
    }
    yield language;
  }

  /// Tooltip on the header's dismiss control.
  final String close;

  /// Header fallback when the event has no name yet.
  final String chooseSeats;

  /// Dock-bar action returning the map to the venue overview.
  final String overview;

  /// Floor-strip chip that puts every floor of the venue on screen at once.
  ///
  /// The one string here the SeatLayer runtime has no dictionary entry for, so
  /// it keeps its English wording in every locale until one exists. A host
  /// that ships a multi-floor venue outside English should override it.
  final String allFloors;

  /// Tooltip on the dock bar's previous-section step.
  final String previousSection;

  /// Tooltip on the dock bar's next-section step.
  final String nextSection;

  /// 3D chrome action returning to the seat map.
  final String backToVenue;

  /// Confirm-card dismissal.
  final String cancel;

  /// Confirm-card acceptance, for hosts that still render their own card.
  ///
  /// The SDK's card says [addSeat]: it names the thing the press does, where
  /// "Select" named the state the seat was already in when the card opened.
  final String select;

  /// Confirm-card acceptance: "Add seat".
  final String addSeat;

  /// What [addSeat] becomes for the moment after it is pressed.
  final String added;

  /// Eyebrow over the confirm card's section cell.
  ///
  /// The SeatLayer runtime has no dictionary entry for the four bare place
  /// words below, so they keep their English wording in every locale until one
  /// exists. A host shipping outside English should override them.
  final String sectionWord;

  /// Eyebrow over the confirm card's row cell, where the chart authored none.
  final String rowWord;

  /// Eyebrow over the confirm card's seat cell.
  final String seatWord;

  /// Eyebrow over the seat cell of a booth, whose seats are places.
  final String placeWord;

  /// Confirm-card pill opening the seat-view photo.
  final String viewFromHere;

  /// Short 3D label, on surfaces with no room for a sentence.
  final String venue3D;

  /// Confirm-card action opening the venue 3D scene.
  final String seeItIn3D;

  /// 3D chrome action opening the full venue panorama.
  final String openVenue360;

  /// What a companion ticket requires, where the tier does not say itself.
  final String tierCompanionGuidance;

  /// Confirm-card badge on a seat the organizer has marked as premium.
  final String premiumSeat;

  /// Confirm-card notice title for a seat sold with a restricted view.
  final String restrictedView;

  /// Confirm-card notice title for a seat with something in the way.
  ///
  /// Only ever shown when the seat is not already restricted: a seat that is
  /// both is described by the stronger of the two words, once.
  final String obstructedView;

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

  /// The price legend's way out of a category filter.
  ///
  /// Drawn as the rail's first chip while a filter is on, and gone again once
  /// it is off, because a phone-width rail has no room for a chip that says
  /// what is already true.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String allPrices;

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

  /// What the best-seats action says while it is searching.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String findingBestSeats;

  /// The collapsed cart's shortcut into the best-seats form.
  ///
  /// Two words, because it sits on a pill beside the cheapest price on a
  /// phone-width bar.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String findSeats;

  /// Collapses an expanded dense ticket list.
  final String showLess;

  /// The collapsed cart sheet's chevron, which opens it.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String expandCart;

  /// The same chevron once the sheet is open.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String collapseCart;

  /// Action reversing a ticket removal.
  final String undo;

  /// Cart-sheet footer call to action.
  final String holdAndCheckout;

  /// The same call to action once a hold already exists and nothing is
  /// pending: the seats are secured, so the button offers the till rather
  /// than offering to secure them again.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String continueToCheckout;

  /// The collapsed pill's wording while a hold exists and more seats are
  /// still waiting to join it.
  ///
  /// Two words, because it shares a 44 pt pill with the total.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String secureMore;

  /// The footer call to action with an empty cart: the one thing left to do.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String selectSeats;

  /// The empty peek line where the chart has no price to quote.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String pickYourSeats;

  /// The collapsed peek line on an event that has stopped selling.
  ///
  /// A sentence rather than the footer's two words, because the peek line is
  /// prose where the footer is a button.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String salesClosedPill;

  /// The collapsed peek line while checkout is opening and prices are hidden.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String seatsSecuredOpeningCheckout;

  /// The wide layout's call to action, beside a total it does not repeat.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String continueWord;

  /// The call to action on an event that is no longer selling.
  ///
  /// One of the six sentences the checkout call to action wears INSTEAD of its
  /// own label whenever it cannot be pressed. A grey button that says
  /// "Hold seats & checkout" states only that nothing will happen; these say
  /// why, so the buyer knows what to do about it.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String salesClosedCta;

  /// The call to action while a seat's confirm card is still unanswered.
  ///
  /// The seat is already in the runtime's selection, so the button would
  /// otherwise look live behind a card that is still asking about it.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String confirmOrCancelSeat;

  /// The same sentence for a table or general-admission quantity prompt, where
  /// the buyer is answering for tickets rather than for one named seat.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String confirmYourTickets;

  /// The call to action while the runtime is creating the hold.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String securingSeats;

  /// The call to action while the host is opening its checkout.
  ///
  /// The hold exists and has been handed over; the button stays down until the
  /// host's screen is up, because a second press would buy nothing and read as
  /// a failure.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String openingCheckout;

  /// The call to action on a selection the event's own rules reject, where
  /// nothing more specific can be said than that it has to change.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String adjustSelection;

  /// Required SeatLayer attribution.
  final String poweredBy;

  /// Badge shown on a test event.
  final String testMode;

  /// The same badge where there is room to say what test mode means.
  ///
  /// The SeatLayer runtime has no dictionary entry for the long form, so it
  /// keeps its English wording in every locale until one exists.
  final String testModeLong;

  /// What test mode means, offered as the badge's tooltip.
  final String testModeExplained;

  /// Tooltip on the accessibility map control.
  final String accessibility;

  /// The same control's name on a chart that authors no access provisions at
  /// all, where the only thing behind it is how the map is drawn.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String displayOptions;

  /// "None left" — a provision the venue has, and has sold out of.
  ///
  /// The row stays, dimmed: "this venue has no wheelchair spaces" and "its
  /// wheelchair spaces are taken" are different facts.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String accessNoneLeft;

  /// The note under a wheelchair row on a chart that also authors companion
  /// places, so a buyer knows the seat beside them is still theirs to take.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String companionSeatsNote;

  /// "12 free" — how many seats with this provision are still available.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String Function(int count) accessFreeCount;

  /// Tooltip on the fit-to-screen map control.
  final String fitVenue;

  /// Tooltip on the zoom-in map control, which a phone only draws when the
  /// host asks for the pair back: pinch is the gesture.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String zoomIn;

  /// Tooltip on the zoom-out map control, which a phone draws once the map is
  /// deep enough to have somewhere to come back from.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String zoomOut;

  /// Tooltip on the 3D navigation-mode control while one finger rotates the
  /// venue, which is what the control would change it to.
  final String rotateVenue;

  /// The same control's tooltip while one finger moves the venue instead.
  final String moveVenue;

  /// Label of the map half of the Map/3D control.
  final String mapView;

  /// Tooltip on the map half of the Map/3D control.
  final String flat2dMap;

  /// Tooltip on the 3D half of the Map/3D control.
  final String interactive3dVenueView;

  /// What the Map/3D control as a whole is called to a screen reader.
  final String venueView;

  /// Message announced after a ticket is removed.
  final String seatRemoved;

  /// Shown while the seat map is still loading.
  final String loading;

  /// Shown when the seat map could not be loaded.
  final String errorMessage;

  /// The action that tries a failed load again.
  final String retry;

  /// Title of the accessibility and view sheet.
  final String accessibilityTitle;

  /// The sheet's switch hiding seats with a limited view.
  final String hideLimitedView;

  /// The sheet's switch for a colourblind-safe palette.
  final String colorblindSafe;

  /// The sheet's action applying the chosen filters.
  final String applyFilters;

  /// Told to the buyer once, when their hold has lapsed server-side.
  ///
  /// Stated as a fact rather than an apology or a warning: the seats are gone,
  /// and the next line says what can be done about it.
  final String holdLapsedTitle;

  /// Names for the access needs the runtime can filter by, by wire key.
  ///
  /// A key the runtime reports and this map does not name is drawn under its
  /// own wire key rather than hidden, so a need added on the runtime side is
  /// still reachable before this table catches up.
  final Map<String, String> accessNeeds;

  /// The English name of every access need the runtime filters by.
  static const Map<String, String> defaultAccessNeeds = <String, String>{
    'wheelchair': SeatLayerStringTokens.accessWheelchair,
    'companion': SeatLayerStringTokens.accessCompanion,
    'semi-ambulatory': SeatLayerStringTokens.accessSemiAmbulatory,
    'designated-aisle': SeatLayerStringTokens.accessDesignatedAisle,
    'step-free': SeatLayerStringTokens.accessStepFree,
    'hearing': SeatLayerStringTokens.accessHearing,
    'cart': SeatLayerStringTokens.accessCart,
    'sign-language': SeatLayerStringTokens.accessSignLanguage,
    'low-vision': SeatLayerStringTokens.accessLowVision,
    'sensory-friendly': SeatLayerStringTokens.accessSensoryFriendly,
    'plus-size': SeatLayerStringTokens.accessPlusSize,
    'lift-armrest': SeatLayerStringTokens.accessLiftArmrest,
  };

  /// "Wheelchair · 12" — one access need and how many free seats offer it.
  ///
  /// Only used when the runtime reports counts; a need with none free is drawn
  /// under its bare name and disabled instead, because "Wheelchair · 0" reads
  /// as a filter worth trying.
  final String Function(String need, int count) accessNeedWithCount;

  /// "They were held for 15 minutes." — the window that has just closed.
  final String Function(int minutes) holdLapsedBody;

  /// The action that takes the lapsed seats back, where they are still free.
  ///
  /// "Select it again" / "Select them again", counted on the seats the action
  /// would RE-TAKE rather than on the seats that lapsed. Those differ: three
  /// seats lapse, one is still free, and the button offers back exactly one.
  final String Function(int count) reselectSeats;

  /// "2 could not be recovered", after a partial re-selection.
  final String Function(int count) seatsNotRecovered;

  /// "1 ticket" / "6 tickets".
  final String Function(int count) ticketCount;

  /// "Choose 2 more" — a selection the event's rules will accept once that
  /// many further places are picked.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String Function(int count) chooseMore;

  /// "Remove 1 ticket" / "Remove 3 tickets" — counted on the tickets the
  /// buyer has to give up, not on the ones they may keep.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String Function(int count) removeTickets;

  /// "74 left" — a section with some seats already sold.
  final String Function(int count) seatsLeft;

  /// "99 seats left" — the same count with the word it is counting, which is
  /// what the dock says while it has the width for it.
  ///
  /// The SeatLayer runtime's dictionary carries the short form only, so this
  /// one keeps its English wording in every locale until one exists.
  final String Function(int count) seatsLeftInSection;

  /// "Only 8 left" — the same count, once it is small enough to be a reason
  /// to decide now rather than a fact about the section.
  final String Function(int count) onlyLeft;

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

  /// "Secure 2 more & checkout" — a hold that is about to grow.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String Function(int count) secureMoreAndCheckout;

  /// "\u2713 3 secured \u00b7 \u20ac285 \u2014 you won't be charged yet".
  ///
  /// The collapsed line for the moment between the hold landing and the host's
  /// checkout appearing. It says the money is safe before the buyer has to
  /// trust a screen they have not seen yet.
  ///
  /// The SeatLayer runtime has no dictionary entry for this one, so it keeps
  /// its English wording in every locale until one exists.
  final String Function(int count, String total) peekSecured;

  /// "14:59", read out as a remaining hold time.
  final String Function(String clock) heldFor;

  /// "Stalls D · Row D · Seat 1", assembled from the parts that exist.
  final String Function(List<String> parts) seatIdentity;

  /// "Sales are closed" — the neutral header pill, and the tray statement's
  /// first line, once the event stops selling.
  ///
  /// Never accent-coloured anywhere it appears: this is a fact about the
  /// event, not a warning about the buyer's own booking.
  final String salesClosed;

  /// "Ticket sales for this event have ended." — the sentence under it.
  final String salesClosedCopy;

  /// "Sales are closed for this event." — the answer to a tap that would have
  /// changed the cart.
  final String salesClosedToast;

  /// "This event" — the sold-out overlay's eyebrow, when the chart names no
  /// brand or event of its own.
  final String soldOutEyebrow;

  /// "Sold out" — every seated category is at zero and the chart has no
  /// standing areas to fall back on.
  final String soldOutTitle;

  /// "No reserved seats are currently available for this event."
  ///
  /// Informational: the picker offers no waitlist, so the sentence does not
  /// promise one.
  final String soldOutCopy;

  /// "Your hold expired — the seats were released. Pick again."
  ///
  /// The plain telling, used when a refresh cannot explain the lapse in more
  /// detail; [holdLapsedStillFree] and its siblings replace it when it can.
  final String holdExpired;

  /// "Add time" — the button on the "Need more time?" prompt.
  final String addTime;

  /// "Adding…" — the same button while the extension is in flight.
  final String addingEllipsis;

  /// "More time added — your seats are still held."
  final String moreTimeAdded;

  /// "Couldn't add more time — please head to checkout now."
  final String couldNotAddMoreTime;

  /// "One or more seats were just taken. Please pick again." — a conflict the
  /// runtime could not attribute to one named seat.
  final String seatsJustTaken;

  /// "You're all set" — the booked overlay's title.
  final String allSetTitle;

  /// "confirmed. A confirmation is on its way." — the rest of the sentence
  /// that begins with the ticket count.
  final String confirmedAndOnWay;

  /// "Back to map" — the way out of the booked overlay.
  final String backToMap;

  /// "The seat map didn't load" — the failure card's title.
  final String mapDidNotLoad;

  /// "Check your connection and try again." — the line under it.
  final String checkConnection;

  /// "These seats are on hold right now" — access paused by the organizer.
  final String accessPausedTitle;

  /// The sentence under [accessPausedTitle].
  final String accessPausedCopy;

  /// "This access link is no longer active" — access revoked.
  final String accessRevokedTitle;

  /// The sentence under [accessRevokedTitle].
  final String accessRevokedCopy;

  /// "Your seat session has expired" — the buyer's token is gone or the
  /// provider could not answer for it.
  final String accessExpiredTitle;

  /// The sentence under [accessExpiredTitle].
  final String accessExpiredCopy;

  /// "We couldn't verify your access" — every other access failure.
  final String accessUnverifiedTitle;

  /// The sentence under [accessUnverifiedTitle].
  final String accessUnverifiedCopy;

  /// "Reload seat map" — the access panel's action where reloading is what
  /// would actually help.
  final String reloadSeatMap;

  /// "No selectable seats are currently available." — the empty view.
  final String noSelectableSeats;

  /// "Number of guests" — the table dialog's quantity label.
  final String numberOfGuests;

  /// The table dialog's explanation of what a party booking means.
  final String chooseGuestsCopy;

  /// Tooltip on the guest stepper's decrement.
  final String fewerGuests;

  /// Tooltip on the guest stepper's increment.
  final String moreGuests;

  /// "Select table" — taking a table that is not in the cart yet.
  final String selectTable;

  /// "Update table" — changing the party size of one already in it.
  final String updateTable;

  /// "Remove" — giving the table back.
  final String removeWord;

  /// "General admission" — a standing area the chart did not name.
  final String generalAdmission;

  /// "Add tickets" — confirming a standing quantity.
  final String addTickets;

  /// "Your hold ended while you were away. Those seats are still free."
  ///
  /// Counted on the seats the buyer can still take back, which is what the
  /// following action offers them.
  final String Function(int count) holdLapsedStillFree;

  /// "…and 2 of those seats have been taken. The rest are still free."
  ///
  /// Counted on the seats that are GONE — the number the sentence names is
  /// the loss, not the remainder.
  final String Function(int count) holdLapsedSomeTaken;

  /// "Your hold ended while you were away, and those seats have been taken."
  final String Function(int count) holdLapsedAllTaken;

  /// "Your seats are held for 0:48. Need more time?"
  final String Function(String time) seatsHeldForNeedMoreTime;

  /// "Seat D-14 was just taken by another buyer."
  final String Function(String label) seatJustTakenByAnother;

  /// "Choose between 2 and 8 guests."
  final String Function(int min, int max) chooseMinMaxGuests;

  /// "120 places currently available".
  final String Function(int count) placesAvailable;

  /// The four sentences below take a value, so unlike every other default
  /// they cannot be one `SeatLayerStringTokens` constant used as-is. Three
  /// substitute a number into one sentence; the fourth picks between two
  /// sentences on it. The wording still lives in `design/tokens.json` — the
  /// other SDK ports read the same sentences — and only the choosing happens
  /// here.
  static String _defaultAccessFreeCount(int count) =>
      SeatLayerStringTokens.accessFreeCount.replaceAll('{count}', '$count');

  static String _defaultAccessNeedWithCount(String need, int count) =>
      SeatLayerStringTokens.accessNeedWithCount
          .replaceAll('{need}', need)
          .replaceAll('{count}', '$count');

  static String _defaultHoldLapsedBody(int minutes) =>
      SeatLayerStringTokens.holdLapsedBody.replaceAll('{n}', '$minutes');

  static String _defaultSeatsNotRecovered(int count) =>
      SeatLayerStringTokens.seatsNotRecovered.replaceAll('{n}', '$count');

  static String _defaultReselectSeats(int count) => count == 1
      ? SeatLayerStringTokens.reselectSeatsOne
      : SeatLayerStringTokens.reselectSeatsOther;

  static String _defaultTicketCount(int count) =>
      count == 1 ? '1 ticket' : '$count tickets';

  static String _defaultChooseMore(int count) =>
      SeatLayerStringTokens.chooseMore.replaceAll('{count}', '$count');

  static String _defaultRemoveTickets(int count) => (count == 1
          ? SeatLayerStringTokens.removeTicketsOne
          : SeatLayerStringTokens.removeTicketsOther)
      .replaceAll('{count}', '$count');

  static String _defaultSeatsLeft(int count) => '$count left';

  static String _defaultSeatsLeftInSection(int count) => (count == 1
          ? SeatLayerStringTokens.seatsLeftInSectionOne
          : SeatLayerStringTokens.seatsLeftInSectionOther)
      .replaceAll('{count}', '$count');

  static String _defaultOnlyLeft(int count) =>
      SeatLayerStringTokens.onlyLeft.replaceAll('{count}', '$count');

  static String _defaultSeatsFree(int count) =>
      count == 1 ? '1 seat' : '$count seats';

  static String _defaultFromPrice(String money) => 'From $money';

  static String _defaultContinueWithTotal(String money) => 'Continue · $money';

  static String _defaultFindBestSeats(int count) => (count == 1
          ? SeatLayerStringTokens.findBestSeatsOne
          : SeatLayerStringTokens.findBestSeatsOther)
      .replaceAll('{count}', '$count');

  static String _defaultMoreCount(int count) => '+$count more';

  static String _defaultSecureMoreAndCheckout(int count) =>
      SeatLayerStringTokens.secureMoreAndCheckout
          .replaceAll('{count}', '$count');

  static String _defaultPeekSecured(int count, String total) =>
      SeatLayerStringTokens.peekSecured
          .replaceAll('{count}', '$count')
          .replaceAll('{total}', total);

  static String _defaultHeldFor(String clock) => clock;

  static String _defaultSeatIdentity(List<String> parts) => parts.join(' · ');

  static String _defaultHoldLapsedStillFree(int count) => count == 1
      ? SeatLayerStringTokens.holdLapsedStillFreeOne
      : SeatLayerStringTokens.holdLapsedStillFreeOther;

  static String _defaultHoldLapsedSomeTaken(int count) => (count == 1
          ? SeatLayerStringTokens.holdLapsedSomeTakenOne
          : SeatLayerStringTokens.holdLapsedSomeTakenOther)
      .replaceAll('{count}', '$count');

  static String _defaultHoldLapsedAllTaken(int count) => count == 1
      ? SeatLayerStringTokens.holdLapsedAllTakenOne
      : SeatLayerStringTokens.holdLapsedAllTakenOther;

  static String _defaultSeatsHeldForNeedMoreTime(String time) =>
      SeatLayerStringTokens.seatsHeldForNeedMoreTime.replaceAll('{time}', time);

  static String _defaultSeatJustTakenByAnother(String label) =>
      SeatLayerStringTokens.seatJustTakenByAnother.replaceAll('{label}', label);

  static String _defaultChooseMinMaxGuests(int min, int max) =>
      SeatLayerStringTokens.chooseMinMaxGuests
          .replaceAll('{min}', '$min')
          .replaceAll('{max}', '$max');

  static String _defaultPlacesAvailable(int count) =>
      SeatLayerStringTokens.placesAvailable.replaceAll('{count}', '$count');
}
