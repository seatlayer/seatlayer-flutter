// GENERATED — do not edit.
//
// Source: design/locale_strings.json (de)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftDe(int count) => '$count frei';

String _moreCountDe(int count) => '+$count weitere';

String _addMinutesDe(int minutes) => '+$minutes Min.';

String _fromPriceDe(String money) => 'Ab $money';

String _sightlineDe(String metres) => '≈ $metres m zur Bühne';

String _ticketCountDe(int count) =>
    count == 1 ? '$count Ticket' : '$count Tickets';

String _findBestSeatsDe(int count) =>
    count == 1 ? '$count besten Platz finden' : '$count beste Plätze finden';

String _reselectSeatsDe(int count) =>
    count == 1 ? 'Erneut auswählen' : 'Erneut auswählen';

String _continueWithTotalDe(String money) => 'Weiter \u00b7 $money';

/// The `de` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsDe = SeatLayerPickerStrings(
  close: 'Schließen',
  overview: 'Spielstätte',
  backToVenue: 'Zurück zur Übersicht',
  cancel: 'Abbrechen',
  select: 'Auswählen',
  viewFromHere: 'Ansicht von hier',
  openVenue360: '360°-Ansicht des Veranstaltungsorts öffnen',
  recentre: 'Wieder auf die Bühne zentrieren',
  viewFromYourSeat: 'Blick von Ihrem Platz',
  emptyTrayHint:
      'Tippen Sie auf einen Platz in der Karte, oder lassen Sie uns die besten verfügbaren für Sie wählen.',
  anyTicketType: 'Beliebige Ticketart',
  anyVenueZone: 'Beliebiger Bereich',
  bestSeats: 'Beste Plätze',
  showLess: 'Weniger anzeigen',
  undo: 'Rückgängig',
  holdAndCheckout: 'Plätze reservieren & zum Checkout',
  poweredBy: 'Bereitgestellt von SeatLayer',
  testMode: 'TESTMODUS',
  accessibility: 'Barrierefreiheit und Farben',
  accessibilityTitle: 'Barrierefreiheit und Farben',
  fitVenue: 'An Bildschirm anpassen',
  loading: 'Sitzplan wird geladen…',
  errorMessage: 'Der Sitzplan konnte nicht geladen werden',
  retry: 'Erneut versuchen',
  accessRefresh: 'Neu laden',
  hideLimitedView: 'Plätze mit eingeschränkter Sicht ausblenden',
  colorblindSafe: 'Farbenblindenfreundliche Farben',
  continueWord: 'Weiter',
  seatsLeft: _seatsLeftDe,
  moreCount: _moreCountDe,
  addMinutes: _addMinutesDe,
  fromPrice: _fromPriceDe,
  sightline: _sightlineDe,
  ticketCount: _ticketCountDe,
  findBestSeats: _findBestSeatsDe,
  reselectSeats: _reselectSeatsDe,
  continueWithTotal: _continueWithTotalDe,
);
