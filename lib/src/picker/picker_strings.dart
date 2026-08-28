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
    this.viewFromHere = SeatLayerStringTokens.viewFromHere,
    this.venue3D = SeatLayerStringTokens.venue3D,
    this.openVenue360 = SeatLayerStringTokens.openVenue360,
    this.previousSeat = SeatLayerStringTokens.previousSeat,
    this.nextSeat = SeatLayerStringTokens.nextSeat,
    this.recentre = SeatLayerStringTokens.recentre,
    this.viewFromYourSeat = SeatLayerStringTokens.viewFromYourSeat,
    this.chooseTickets = SeatLayerStringTokens.chooseTickets,
    this.emptyTrayHint = SeatLayerStringTokens.emptyTrayHint,
    this.anyTicketType = SeatLayerStringTokens.anyTicketType,
    this.anyVenueZone = SeatLayerStringTokens.anyVenueZone,
    this.ticketType = SeatLayerStringTokens.ticketType,
    this.venueZone = SeatLayerStringTokens.venueZone,
    this.fewerTickets = SeatLayerStringTokens.fewerTickets,
    this.moreTickets = SeatLayerStringTokens.moreTickets,
    this.bestSeats = SeatLayerStringTokens.bestSeats,
    this.showLess = SeatLayerStringTokens.showLess,
    this.undo = SeatLayerStringTokens.undo,
    this.holdAndCheckout = SeatLayerStringTokens.holdAndCheckout,
    this.poweredBy = SeatLayerStringTokens.poweredBy,
    this.testMode = SeatLayerStringTokens.testMode,
    this.accessibility = SeatLayerStringTokens.accessibility,
    this.fitVenue = SeatLayerStringTokens.fitVenue,
    this.mapView = SeatLayerStringTokens.mapView,
    this.seatRemoved = SeatLayerStringTokens.seatRemoved,
    this.loading = SeatLayerStringTokens.loading,
    this.errorMessage = SeatLayerStringTokens.errorMessage,
    this.retry = SeatLayerStringTokens.retry,
    this.accessibilityTitle = SeatLayerStringTokens.accessibilityTitle,
    this.hideLimitedView = SeatLayerStringTokens.hideLimitedView,
    this.colorblindSafe = SeatLayerStringTokens.colorblindSafe,
    this.applyFilters = SeatLayerStringTokens.applyFilters,
    this.holdLapsedTitle = SeatLayerStringTokens.holdLapsedTitle,
    this.reselectSeats = SeatLayerStringTokens.reselectSeats,
    this.accessNeeds = defaultAccessNeeds,
    this.accessNeedWithCount = _defaultAccessNeedWithCount,
    this.holdLapsedBody = _defaultHoldLapsedBody,
    this.seatsNotRecovered = _defaultSeatsNotRecovered,
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

  /// The action that takes the lapsed seats back, where they are still free.
  final String reselectSeats;

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

  /// "2 could not be recovered", after a partial re-selection.
  final String Function(int count) seatsNotRecovered;

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

  /// The three sentences below take a value, so unlike every other default
  /// they cannot be one `SeatLayerStringTokens` constant used as-is. The
  /// wording still lives in `design/tokens.json` — the other SDK ports read
  /// the same sentence — and only the substitution happens here.
  static String _defaultAccessNeedWithCount(String need, int count) =>
      SeatLayerStringTokens.accessNeedWithCount
          .replaceAll('{need}', need)
          .replaceAll('{count}', '$count');

  static String _defaultHoldLapsedBody(int minutes) =>
      SeatLayerStringTokens.holdLapsedBody.replaceAll('{n}', '$minutes');

  static String _defaultSeatsNotRecovered(int count) =>
      SeatLayerStringTokens.seatsNotRecovered.replaceAll('{n}', '$count');

  static String _defaultTicketCount(int count) =>
      count == 1 ? '1 ticket' : '$count tickets';

  static String _defaultSeatsLeft(int count) => '$count left';

  static String _defaultSeatsFree(int count) =>
      count == 1 ? '1 seat' : '$count seats';

  static String _defaultFromPrice(String money) => 'From $money';

  static String _defaultContinueWithTotal(String money) => 'Continue · $money';

  static String _defaultFindBestSeats(int count) => 'Find $count best seats';

  static String _defaultMoreCount(int count) => '+$count more';

  static String _defaultHeldFor(String clock) => clock;

  static String _defaultSeatIdentity(List<String> parts) => parts.join(' · ');
}
