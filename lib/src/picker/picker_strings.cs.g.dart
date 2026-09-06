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

String _addMinutesCs(int minutes) => '+$minutes min';

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
  removeSeat: 'Odebrat místo',
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
  fitWholeVenue: 'Zobrazit celé místo konání',
  loading: 'Načítání plánu míst…',
  errorMessage: 'Plán míst se nenačetl',
  retry: 'Zkusit znovu',
  accessRefresh: 'Obnovit',
  noSeatsSelected: 'Nevybrána žádná místa',
  findBestSeatsCta: 'Najít nejlepší místa',
  organizerNote: 'Poznámka pořadatele',
  accessiblePhysicalSeat: 'Bezbariérové fyzické místo',
  emptyWheelchairSpace: 'Volné místo pro vozík',
  hideLimitedView: 'Skrýt místa s omezeným výhledem',
  colorblindSafe: 'Barvy vhodné pro barvoslepé',
  notAvailable: 'Není k dispozici',
  restrictedView: 'Omezený výhled',
  obstructedView: 'Zakrytý výhled',
  premiumSeat: 'Prémiové místo',
  continueWord: 'Pokračovat',
  accessNeeds: <String, String>{
    'wheelchair': 'Místo pro vozík',
    'companion': 'Místo pro doprovod',
    'semi-ambulatory': 'Omezená pohyblivost',
    'designated-aisle': 'Vyhrazené místo u uličky pro přesun',
    'step-free': 'Bezbariérové místo bez schodů',
    'hearing': 'Podpora poslechu',
    'cart': 'Živé titulky (CART)',
    'sign-language': 'Výhled na znakový jazyk',
    'low-vision': 'Sledování pro nevidomé a slabozraké',
    'sensory-friendly': 'Klidná místa šetrná ke smyslům',
    'plus-size': 'Rozšířené místo',
    'lift-armrest': 'Sklopná područka',
  },
  seatsLeft: _seatsLeftCs,
  moreCount: _moreCountCs,
  addMinutes: _addMinutesCs,
  fromPrice: _fromPriceCs,
  sightline: _sightlineCs,
  ticketCount: _ticketCountCs,
  findBestSeats: _findBestSeatsCs,
  reselectSeats: _reselectSeatsCs,
  continueWithTotal: _continueWithTotalCs,
);
