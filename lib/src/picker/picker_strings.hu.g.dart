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

String _addMinutesHu(int minutes) => '+$minutes perc';

String _fromPriceHu(String money) => '$money-tól';

String _sightlineHu(String metres) => '≈ $metres m a színpadig';

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
  removeSeat: 'Hely eltávolítása',
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
  fitWholeVenue: 'Teljes helyszín megjelenítése',
  loading: 'Ülésterv betöltése…',
  errorMessage: 'Az ülésterv nem töltődött be',
  retry: 'Újrapróbálom',
  accessRefresh: 'Frissítés',
  noSeatsSelected: 'Nincs kiválasztott hely',
  findBestSeatsCta: 'Legjobb helyek keresése',
  organizerNote: 'Szervezői megjegyzés',
  accessiblePhysicalSeat: 'Akadálymentes fizikai hely',
  emptyWheelchairSpace: 'Üres kerekesszékes hely',
  hideLimitedView: 'Korlátozott kilátású helyek elrejtése',
  colorblindSafe: 'Színvakbarát színek',
  notAvailable: 'Nem elérhető',
  restrictedView: 'Korlátozott kilátás',
  obstructedView: 'Takart kilátás',
  premiumSeat: 'Prémium hely',
  continueWord: 'Tovább',
  accessNeeds: <String, String>{
    'wheelchair': 'Kerekesszékes hely',
    'companion': 'Kísérőhely',
    'semi-ambulatory': 'Korlátozott mozgásképesség',
    'designated-aisle': 'Kijelölt sorszéli hely átüléshez',
    'step-free': 'Lépcsőmentes akadálymentes hely',
    'hearing': 'Hallássegítő rendszer',
    'cart': 'Élő feliratozás (CART)',
    'sign-language': 'Rálátás a jelnyelvi tolmácsra',
    'low-vision': 'Vak és gyengénlátó nézőknek',
    'sensory-friendly': 'Csendes, ingerszegény helyek',
    'plus-size': 'Szélesebb hely',
    'lift-armrest': 'Felhajtható kartámasz',
  },
  seatsLeft: _seatsLeftHu,
  moreCount: _moreCountHu,
  addMinutes: _addMinutesHu,
  fromPrice: _fromPriceHu,
  sightline: _sightlineHu,
  ticketCount: _ticketCountHu,
  findBestSeats: _findBestSeatsHu,
  reselectSeats: _reselectSeatsHu,
  continueWithTotal: _continueWithTotalHu,
);
