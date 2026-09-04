// GENERATED — do not edit.
//
// Source: design/locale_strings.json (hr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftHr(int count) => 'Preostalo $count';

String _moreCountHr(int count) => '+$count više';

String _addMinutesHr(int minutes) => '+$minutes min';

String _fromPriceHr(String money) => 'Od $money';

String _sightlineHr(String metres) => '≈ $metres m do pozornice';

String _ticketCountHr(int count) =>
    count == 1 ? '$count ulaznica' : '$count ulaznica';

String _findBestSeatsHr(int count) => count == 1
    ? 'Pronađi $count najbolje mjesto'
    : 'Pronađi $count najboljih mjesta';

String _reselectSeatsHr(int count) =>
    count == 1 ? 'Ponovno ga odaberite' : 'Ponovno ih odaberite';

String _continueWithTotalHr(String money) => 'Nastavi \u00b7 $money';

/// The `hr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHr = SeatLayerPickerStrings(
  close: 'Zatvori',
  overview: 'Prostor',
  backToVenue: 'Natrag na prostor',
  cancel: 'Odustani',
  select: 'Odaberi',
  viewFromHere: 'Pogled odavde',
  openVenue360: 'Otvori prostor u 360°',
  recentre: 'Ponovno centriraj na pozornicu',
  viewFromYourSeat: 'pogled s vašeg mjesta',
  emptyTrayHint:
      'Dodirnite mjesto na planu ili prepustite nama da odaberemo najbolja dostupna.',
  anyTicketType: 'Bilo koja vrsta ulaznice',
  anyVenueZone: 'Bilo koja zona prostora',
  bestSeats: 'Najbolja mjesta',
  showLess: 'Prikaži manje',
  undo: 'Poništi',
  holdAndCheckout: 'Rezerviraj mjesta i plati',
  poweredBy: 'Pokreće SeatLayer',
  testMode: 'TESTNI NAČIN',
  accessibility: 'Pristupačnost i boje',
  accessibilityTitle: 'Pristupačnost i boje',
  fitVenue: 'Prilagodi zaslonu',
  loading: 'Učitavanje plana mjesta…',
  errorMessage: 'Plan mjesta se nije učitao',
  retry: 'Pokušaj ponovno',
  hideLimitedView: 'Sakrij mjesta s ograničenim pogledom',
  colorblindSafe: 'Boje prilagođene daltonizmu',
  continueWord: 'Nastavi',
  seatsLeft: _seatsLeftHr,
  moreCount: _moreCountHr,
  addMinutes: _addMinutesHr,
  fromPrice: _fromPriceHr,
  sightline: _sightlineHr,
  ticketCount: _ticketCountHr,
  findBestSeats: _findBestSeatsHr,
  reselectSeats: _reselectSeatsHr,
  continueWithTotal: _continueWithTotalHr,
);
