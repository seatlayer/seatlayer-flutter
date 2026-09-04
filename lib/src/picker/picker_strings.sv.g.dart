// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sv)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftSv(int count) => '$count kvar';

String _moreCountSv(int count) => '+$count fler';

String _addMinutesSv(int minutes) => '+$minutes min';

String _fromPriceSv(String money) => 'Från $money';

String _sightlineSv(String metres) => '≈ $metres m till scenen';

String _ticketCountSv(int count) =>
    count == 1 ? '$count biljett' : '$count biljetter';

String _findBestSeatsSv(int count) =>
    count == 1 ? 'Hitta $count bästa plats' : 'Hitta $count bästa platser';

String _reselectSeatsSv(int count) =>
    count == 1 ? 'Välj den igen' : 'Välj dem igen';

String _continueWithTotalSv(String money) => 'Fortsätt \u00b7 $money';

/// The `sv` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSv = SeatLayerPickerStrings(
  close: 'Stäng',
  overview: 'Spelplats',
  backToVenue: 'Tillbaka till arenan',
  cancel: 'Avbryt',
  select: 'Välj',
  viewFromHere: 'Utsikt härifrån',
  openVenue360: 'Öppna arenan i 360°',
  recentre: 'Centrera på scenen igen',
  viewFromYourSeat: 'vy från din plats',
  emptyTrayHint:
      'Tryck på en plats på kartan, eller låt oss välja de bästa lediga åt dig.',
  anyTicketType: 'Vilken biljettyp som helst',
  anyVenueZone: 'Vilken zon som helst',
  bestSeats: 'Bästa platserna',
  showLess: 'Visa färre',
  undo: 'Ångra',
  holdAndCheckout: 'Reservera platser och betala',
  poweredBy: 'Drivs av SeatLayer',
  testMode: 'TESTLÄGE',
  accessibility: 'Tillgänglighet och färger',
  accessibilityTitle: 'Tillgänglighet och färger',
  fitVenue: 'Anpassa till skärmen',
  loading: 'Läser in platskartan…',
  errorMessage: 'Platskartan laddades inte',
  retry: 'Försök igen',
  hideLimitedView: 'Dölj platser med begränsad sikt',
  colorblindSafe: 'Färgblindvänliga färger',
  seatsLeft: _seatsLeftSv,
  moreCount: _moreCountSv,
  addMinutes: _addMinutesSv,
  fromPrice: _fromPriceSv,
  sightline: _sightlineSv,
  ticketCount: _ticketCountSv,
  findBestSeats: _findBestSeatsSv,
  reselectSeats: _reselectSeatsSv,
  continueWithTotal: _continueWithTotalSv,
);
