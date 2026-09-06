// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sk)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftSk(int count) => 'Zostáva $count';

String _moreCountSk(int count) => '+$count ďalších';

String _addMinutesSk(int minutes) => '+$minutes min';

String _fromPriceSk(String money) => 'Od $money';

String _sightlineSk(String metres) => '≈ $metres m k pódiu';

String _ticketCountSk(int count) =>
    count == 1 ? '$count vstupenka' : '$count vstupeniek';

String _findBestSeatsSk(int count) => count == 1
    ? 'Nájsť $count najlepšie miesto'
    : 'Nájsť $count najlepších miest';

String _reselectSeatsSk(int count) =>
    count == 1 ? 'Vybrať ho znova' : 'Vybrať ich znova';

String _continueWithTotalSk(String money) => 'Pokračovať \u00b7 $money';

/// The `sk` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSk = SeatLayerPickerStrings(
  close: 'Zavrieť',
  overview: 'Miesto konania',
  backToVenue: 'Späť do areálu',
  cancel: 'Zrušiť',
  select: 'Vybrať',
  removeSeat: 'Odobrať miesto',
  viewFromHere: 'Výhľad odtiaľto',
  openVenue360: 'Otvoriť areál v 360°',
  recentre: 'Znova vycentrovať na pódium',
  viewFromYourSeat: 'pohľad z vášho miesta',
  emptyTrayHint:
      'Ťuknite na miesto v pláne, alebo nechajte nás vybrať najlepšie dostupné za vás.',
  anyTicketType: 'Akýkoľvek typ vstupenky',
  anyVenueZone: 'Akákoľvek zóna areálu',
  bestSeats: 'Najlepšie miesta',
  showLess: 'Zobraziť menej',
  undo: 'Späť',
  holdAndCheckout: 'Rezervovať miesta a zaplatiť',
  poweredBy: 'Beží na SeatLayer',
  testMode: 'TESTOVACÍ REŽIM',
  accessibility: 'Prístupnosť a farby',
  accessibilityTitle: 'Prístupnosť a farby',
  fitVenue: 'Zobraziť celé miesto konania',
  fitWholeVenue: 'Zobraziť celé miesto konania',
  loading: 'Načítava sa plán miest…',
  errorMessage: 'Plán miest sa nenačítal',
  retry: 'Skúsiť znova',
  accessRefresh: 'Obnoviť',
  noSeatsSelected: 'Nevybrané žiadne miesta',
  findBestSeatsCta: 'Nájsť najlepšie miesta',
  organizerNote: 'Poznámka organizátora',
  accessiblePhysicalSeat: 'Bezbariérové fyzické miesto',
  emptyWheelchairSpace: 'Voľné miesto pre vozík',
  findSeatsTogether: 'Nájsť miesta vedľa seba',
  aboutBestSeats: 'O hľadaní miest vedľa seba',
  closestGroupChosenInstantly: 'Najbližšia dostupná skupina, vybraná okamžite.',
  hideLimitedView: 'Skryť miesta s obmedzeným výhľadom',
  colorblindSafe: 'Farby vhodné pre farboslepých',
  notAvailable: 'Nedostupné',
  restrictedView: 'Obmedzený výhľad',
  obstructedView: 'Zakrytý výhľad',
  premiumSeat: 'Prémiové miesto',
  continueWord: 'Pokračovať',
  accessNeeds: <String, String>{
    'wheelchair': 'Miesto pre vozík',
    'companion': 'Miesto pre sprievod',
    'semi-ambulatory': 'Obmedzená pohyblivosť',
    'designated-aisle': 'Ulička / presun',
    'step-free': 'Bez schodov',
    'hearing': 'Podpora počutia',
    'cart': 'Živé titulky',
    'sign-language': 'Posunkový jazyk',
    'low-vision': 'Slabozrakosť',
    'sensory-friendly': 'Zmyslovo šetrné',
    'plus-size': 'Rozšírené miesto',
    'lift-armrest': 'Sklopná lakťová opierka',
  },
  seatsLeft: _seatsLeftSk,
  moreCount: _moreCountSk,
  addMinutes: _addMinutesSk,
  fromPrice: _fromPriceSk,
  sightline: _sightlineSk,
  ticketCount: _ticketCountSk,
  findBestSeats: _findBestSeatsSk,
  reselectSeats: _reselectSeatsSk,
  continueWithTotal: _continueWithTotalSk,
);
