// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fi)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftFi(int count) => '$count jäljellä';

String _moreCountFi(int count) => '+$count lisää';

String _fromPriceFi(String money) => 'Alkaen $money';

String _ticketCountFi(int count) =>
    count == 1 ? '$count lippu' : '$count lippua';

String _findBestSeatsFi(int count) =>
    count == 1 ? 'Etsi $count paras paikka' : 'Etsi $count parasta paikkaa';

String _reselectSeatsFi(int count) =>
    count == 1 ? 'Valitse se uudelleen' : 'Valitse ne uudelleen';

String _continueWithTotalFi(String money) => 'Jatka \u00b7 $money';

/// The `fi` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsFi = SeatLayerPickerStrings(
  close: 'Sulje',
  overview: 'Paikka',
  backToVenue: 'Takaisin tapahtumapaikkaan',
  cancel: 'Peruuta',
  select: 'Valitse',
  viewFromHere: 'Näkymä täältä',
  openVenue360: 'Avaa tapahtumapaikka 360°:na',
  recentre: 'Keskitä takaisin lavaan',
  viewFromYourSeat: 'näkymä paikaltasi',
  emptyTrayHint:
      'Napauta paikkaa kartalla tai anna meidän valita parhaat vapaat puolestasi.',
  anyTicketType: 'Mikä tahansa lipputyyppi',
  anyVenueZone: 'Mikä tahansa alue',
  bestSeats: 'Parhaat paikat',
  showLess: 'Näytä vähemmän',
  undo: 'Kumoa',
  holdAndCheckout: 'Varaa paikat ja siirry kassalle',
  poweredBy: 'Palvelun tarjoaa SeatLayer',
  testMode: 'TESTITILA',
  accessibility: 'Esteettömyys- ja väriasetukset',
  accessibilityTitle: 'Esteettömyys- ja väriasetukset',
  fitVenue: 'Sovita näytölle',
  loading: 'Ladataan paikkakarttaa…',
  errorMessage: 'Paikkakartta ei latautunut',
  retry: 'Yritä uudelleen',
  hideLimitedView: 'Piilota paikat, joissa on rajoitettu näkyvyys',
  colorblindSafe: 'Värisokeusystävälliset värit',
  seatsLeft: _seatsLeftFi,
  moreCount: _moreCountFi,
  fromPrice: _fromPriceFi,
  ticketCount: _ticketCountFi,
  findBestSeats: _findBestSeatsFi,
  reselectSeats: _reselectSeatsFi,
  continueWithTotal: _continueWithTotalFi,
);
