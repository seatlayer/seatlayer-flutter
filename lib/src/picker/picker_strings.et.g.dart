// GENERATED — do not edit.
//
// Source: design/locale_strings.json (et)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftEt(int count) => 'Jäänud $count';

String _moreCountEt(int count) => '+$count veel';

String _addMinutesEt(int minutes) => '+$minutes min';

String _fromPriceEt(String money) => 'Alates $money';

String _sightlineEt(String metres) => '≈ $metres m laval';

String _ticketCountEt(int count) =>
    count == 1 ? '$count pilet' : '$count piletit';

String _findBestSeatsEt(int count) =>
    count == 1 ? 'Leia $count parim koht' : 'Leia $count parimat kohta';

String _reselectSeatsEt(int count) =>
    count == 1 ? 'Vali see uuesti' : 'Vali need uuesti';

String _continueWithTotalEt(String money) => 'Jätka \u00b7 $money';

/// The `et` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsEt = SeatLayerPickerStrings(
  close: 'Sulge',
  overview: 'Toimumiskoht',
  backToVenue: 'Tagasi kohta',
  cancel: 'Tühista',
  select: 'Vali',
  viewFromHere: 'Vaade siit',
  openVenue360: 'Ava koht 360° vaates',
  recentre: 'Keskenda uuesti lavale',
  viewFromYourSeat: 'vaade sinu kohalt',
  emptyTrayHint:
      'Puuduta plaanil kohta või lase meil valida sulle parimad vabad kohad.',
  anyTicketType: 'Ükskõik milline piletitüüp',
  anyVenueZone: 'Ükskõik milline tsoon',
  bestSeats: 'Parimad kohad',
  showLess: 'Näita vähem',
  undo: 'Võta tagasi',
  holdAndCheckout: 'Broneeri kohad ja maksa',
  poweredBy: 'Töötab SeatLayeri baasil',
  testMode: 'TESTREŽIIM',
  accessibility: 'Ligipääsetavuse ja värvide valikud',
  accessibilityTitle: 'Ligipääsetavuse ja värvide valikud',
  fitVenue: 'Sobita ekraanile',
  loading: 'Laadime istekohtade plaani…',
  errorMessage: 'Istekohtade plaan ei laadinud',
  retry: 'Proovi uuesti',
  hideLimitedView: 'Peida piiratud vaatega kohad',
  colorblindSafe: 'Värvipimedasõbralikud värvid',
  seatsLeft: _seatsLeftEt,
  moreCount: _moreCountEt,
  addMinutes: _addMinutesEt,
  fromPrice: _fromPriceEt,
  sightline: _sightlineEt,
  ticketCount: _ticketCountEt,
  findBestSeats: _findBestSeatsEt,
  reselectSeats: _reselectSeatsEt,
  continueWithTotal: _continueWithTotalEt,
);
