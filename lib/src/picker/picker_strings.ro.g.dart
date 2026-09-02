// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ro)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftRo(int count) => 'Au rămas $count';

String _moreCountRo(int count) => '+$count în plus';

String _fromPriceRo(String money) => 'De la $money';

String _sightlineRo(String metres) => '≈ $metres m până la scenă';

String _ticketCountRo(int count) =>
    count == 1 ? '$count bilet' : '$count de bilete';

String _findBestSeatsRo(int count) => count == 1
    ? 'Găsește $count cel mai bun loc'
    : 'Găsește cele mai bune $count de locuri';

String _reselectSeatsRo(int count) =>
    count == 1 ? 'Selectează-l din nou' : 'Selectează-le din nou';

String _continueWithTotalRo(String money) => 'Continuă \u00b7 $money';

/// The `ro` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsRo = SeatLayerPickerStrings(
  close: 'Închide',
  overview: 'Locație',
  backToVenue: 'Înapoi la locație',
  cancel: 'Anulează',
  select: 'Selectează',
  viewFromHere: 'Priveliștea de aici',
  openVenue360: 'Deschide locația în 360°',
  recentre: 'Recentrează pe scenă',
  viewFromYourSeat: 'priveliștea de la locul dvs.',
  emptyTrayHint:
      'Atinge un loc pe hartă sau lasă-ne să alegem cele mai bune locuri disponibile pentru tine.',
  anyTicketType: 'Orice tip de bilet',
  anyVenueZone: 'Orice zonă a locației',
  bestSeats: 'Cele mai bune locuri',
  showLess: 'Afișează mai puțin',
  undo: 'Anulează',
  holdAndCheckout: 'Rezervă locurile și plătește',
  poweredBy: 'Susținut de SeatLayer',
  testMode: 'MOD DE TESTARE',
  accessibility: 'Opțiuni de accesibilitate și culoare',
  accessibilityTitle: 'Opțiuni de accesibilitate și culoare',
  fitVenue: 'Potrivește pe ecran',
  loading: 'Se încarcă harta locurilor…',
  errorMessage: 'Harta locurilor nu s-a încărcat',
  retry: 'Încearcă din nou',
  hideLimitedView: 'Ascunde locurile cu vizibilitate limitată',
  colorblindSafe: 'Culori potrivite pentru daltonism',
  seatsLeft: _seatsLeftRo,
  moreCount: _moreCountRo,
  fromPrice: _fromPriceRo,
  sightline: _sightlineRo,
  ticketCount: _ticketCountRo,
  findBestSeats: _findBestSeatsRo,
  reselectSeats: _reselectSeatsRo,
  continueWithTotal: _continueWithTotalRo,
);
