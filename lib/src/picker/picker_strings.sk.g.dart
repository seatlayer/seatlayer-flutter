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

String _fromPriceSk(String money) => 'Od $money';

String _ticketCountSk(int count) =>
    count == 1 ? '$count vstupenka' : '$count vstupeniek';

String _findBestSeatsSk(int count) => count == 1
    ? 'Nájsť $count najlepšie miesto'
    : 'Nájsť $count najlepších miest';

String _continueWithTotalSk(String money) => 'Pokračovať \u00b7 $money';

/// The `sk` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSk = SeatLayerPickerStrings(
  close: 'Zavrieť',
  overview: 'Miesto konania',
  backToVenue: 'Späť do areálu',
  cancel: 'Zrušiť',
  select: 'Vybrať',
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
  fitVenue: 'Prispôsobiť obrazovke',
  loading: 'Načítava sa plán miest…',
  errorMessage: 'Plán miest sa nenačítal',
  retry: 'Skúsiť znova',
  hideLimitedView: 'Skryť miesta s obmedzeným výhľadom',
  colorblindSafe: 'Farby vhodné pre farboslepých',
  seatsLeft: _seatsLeftSk,
  moreCount: _moreCountSk,
  fromPrice: _fromPriceSk,
  ticketCount: _ticketCountSk,
  findBestSeats: _findBestSeatsSk,
  continueWithTotal: _continueWithTotalSk,
);
