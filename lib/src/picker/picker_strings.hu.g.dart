// GENERATED — do not edit.
//
// Source: design/locale_strings.json (hu)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftHu(int count) => '$count maradt';

String _moreCountHu(int count) => '+$count további';

String _fromPriceHu(String money) => '$money-tól';

String _ticketCountHu(int count) => count == 1 ? '$count jegy' : '$count jegy';

String _findBestSeatsHu(int count) => count == 1
    ? '$count legjobb hely keresése'
    : '$count legjobb hely keresése';

String _reselectSeatsHu(int count) =>
    count == 1 ? 'Válassza ki újra' : 'Válassza ki őket újra';

String _continueWithTotalHu(String money) => 'Tovább \u00b7 $money';

/// The `hu` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHu = SeatLayerPickerStrings(
  close: 'Bezárás',
  overview: 'Helyszín',
  backToVenue: 'Vissza a helyszínhez',
  cancel: 'Mégse',
  select: 'Kiválasztás',
  viewFromHere: 'Kilátás innen',
  openVenue360: 'Helyszín megnyitása 360°-ban',
  recentre: 'Középre a színpadra',
  viewFromYourSeat: 'kilátás az Ön helyéről',
  emptyTrayHint:
      'Koppints egy helyre az üléstervben, vagy bízd ránk a legjobb szabad helyek kiválasztását.',
  anyTicketType: 'Bármelyik jegytípus',
  anyVenueZone: 'Bármelyik zóna',
  bestSeats: 'Legjobb helyek',
  showLess: 'Kevesebb megjelenítése',
  undo: 'Visszavonás',
  holdAndCheckout: 'Helyek foglalása és fizetés',
  poweredBy: 'SeatLayer technológiával',
  testMode: 'TESZTÜZEMMÓD',
  accessibility: 'Akadálymentesítési és színbeállítások',
  accessibilityTitle: 'Akadálymentesítési és színbeállítások',
  fitVenue: 'Képernyőre illesztés',
  loading: 'Ülésterv betöltése…',
  errorMessage: 'Az ülésterv nem töltődött be',
  retry: 'Újrapróbálom',
  hideLimitedView: 'Korlátozott kilátású helyek elrejtése',
  colorblindSafe: 'Színvakbarát színek',
  seatsLeft: _seatsLeftHu,
  moreCount: _moreCountHu,
  fromPrice: _fromPriceHu,
  ticketCount: _ticketCountHu,
  findBestSeats: _findBestSeatsHu,
  reselectSeats: _reselectSeatsHu,
  continueWithTotal: _continueWithTotalHu,
);
