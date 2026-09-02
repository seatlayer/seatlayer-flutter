// GENERATED — do not edit.
//
// Source: design/locale_strings.json (cs)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftCs(int count) => 'Zbývá $count';

String _moreCountCs(int count) => '+$count dalších';

String _fromPriceCs(String money) => 'Od $money';

String _sightlineCs(String metres) => '≈ $metres m k pódiu';

String _ticketCountCs(int count) =>
    count == 1 ? '$count vstupenka' : '$count vstupenek';

String _findBestSeatsCs(int count) =>
    count == 1 ? 'Najít $count nejlepší místo' : 'Najít $count nejlepších míst';

String _reselectSeatsCs(int count) =>
    count == 1 ? 'Vybrat ho znovu' : 'Vybrat je znovu';

String _continueWithTotalCs(String money) => 'Pokračovat \u00b7 $money';

/// The `cs` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsCs = SeatLayerPickerStrings(
  close: 'Zavřít',
  overview: 'Místo konání',
  backToVenue: 'Zpět do areálu',
  cancel: 'Zrušit',
  select: 'Vybrat',
  viewFromHere: 'Výhled odsud',
  openVenue360: 'Otevřít areál ve 360°',
  recentre: 'Vycentrovat zpět na pódium',
  viewFromYourSeat: 'pohled z vašeho místa',
  emptyTrayHint:
      'Klepněte na místo v plánu, nebo nechte nás vybrat nejlepší dostupná za vás.',
  anyTicketType: 'Jakýkoli typ vstupenky',
  anyVenueZone: 'Jakákoli zóna areálu',
  bestSeats: 'Nejlepší místa',
  showLess: 'Zobrazit méně',
  undo: 'Zpět',
  holdAndCheckout: 'Rezervovat místa a zaplatit',
  poweredBy: 'Běží na SeatLayer',
  testMode: 'TESTOVACÍ REŽIM',
  accessibility: 'Přístupnost a barvy',
  accessibilityTitle: 'Přístupnost a barvy',
  fitVenue: 'Přizpůsobit obrazovce',
  loading: 'Načítání plánu míst…',
  errorMessage: 'Plán míst se nenačetl',
  retry: 'Zkusit znovu',
  hideLimitedView: 'Skrýt místa s omezeným výhledem',
  colorblindSafe: 'Barvy vhodné pro barvoslepé',
  seatsLeft: _seatsLeftCs,
  moreCount: _moreCountCs,
  fromPrice: _fromPriceCs,
  sightline: _sightlineCs,
  ticketCount: _ticketCountCs,
  findBestSeats: _findBestSeatsCs,
  reselectSeats: _reselectSeatsCs,
  continueWithTotal: _continueWithTotalCs,
);
