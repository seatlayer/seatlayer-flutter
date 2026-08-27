// GENERATED — do not edit.
//
// Source: design/locale_strings.json (it)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftIt(int count) => 'Ne restano $count';

String _moreCountIt(int count) => '+$count altri';

String _fromPriceIt(String money) => 'Da $money';

String _ticketCountIt(int count) =>
    count == 1 ? '$count biglietto' : '$count biglietti';

String _findBestSeatsIt(int count) => count == 1
    ? 'Trova $count posto migliore'
    : 'Trova i $count posti migliori';

String _continueWithTotalIt(String money) => 'Continua \u00b7 $money';

/// The `it` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsIt = SeatLayerPickerStrings(
  close: 'Chiudi',
  overview: 'Sede',
  backToVenue: 'Torna all\'impianto',
  cancel: 'Annulla',
  select: 'Seleziona',
  viewFromHere: 'Visuale da qui',
  openVenue360: 'Apri l\'impianto in 360°',
  recentre: 'Ricentra sul palco',
  viewFromYourSeat: 'vista dal tuo posto',
  emptyTrayHint:
      'Tocca un posto sulla mappa, oppure lascia che scegliamo noi i migliori disponibili.',
  anyTicketType: 'Qualsiasi tipo di biglietto',
  anyVenueZone: 'Qualsiasi zona dell\'impianto',
  bestSeats: 'Posti migliori',
  showLess: 'Mostra meno',
  undo: 'Annulla',
  holdAndCheckout: 'Blocca i posti e paga',
  poweredBy: 'Powered by SeatLayer',
  testMode: 'MODALITÀ TEST',
  accessibility: 'Opzioni di accessibilità e colore',
  accessibilityTitle: 'Opzioni di accessibilità e colore',
  fitVenue: 'Adatta allo schermo',
  loading: 'Caricamento della mappa dei posti…',
  errorMessage: 'La mappa dei posti non si è caricata',
  retry: 'Riprova',
  hideLimitedView: 'Nascondi i posti con visuale limitata',
  colorblindSafe: 'Colori adatti al daltonismo',
  seatsLeft: _seatsLeftIt,
  moreCount: _moreCountIt,
  fromPrice: _fromPriceIt,
  ticketCount: _ticketCountIt,
  findBestSeats: _findBestSeatsIt,
  continueWithTotal: _continueWithTotalIt,
);
