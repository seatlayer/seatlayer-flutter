// GENERATED — do not edit.
//
// Source: design/locale_strings.json (it)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftIt(int count) => 'Ne restano $count';

String _moreCountIt(int count) => '+$count altri';

String _addMinutesIt(int minutes) => '+$minutes min';

String _fromPriceIt(String money) => 'Da $money';

String _sightlineIt(String metres) => '≈ $metres m dal palco';

String _secureMoreAndCheckoutIt(int count) => 'Blocca altri $count e paga';

String _accessFreeCountIt(int count) => '$count liberi';

String _seatJustTakenByAnotherIt(String label) =>
    'Il posto $label è stato appena preso da un altro acquirente.';

String _peekSecuredIt(int count, String total) =>
    '✓ $count bloccati · $total. Non ti addebiteremo ancora nulla';

String _ticketCountIt(int count) => switch (pickerPluralCategory('it', count)) {
  PickerPluralCategory.one => '$count biglietto',
  PickerPluralCategory.many => '$count biglietti',
  _ => '$count biglietti',
};

String _findBestSeatsIt(int count) =>
    switch (pickerPluralCategory('it', count)) {
      PickerPluralCategory.one => 'Trova $count posto migliore',
      PickerPluralCategory.many => 'Trova i $count posti migliori',
      _ => 'Trova i $count posti migliori',
    };

String _reselectSeatsIt(int count) =>
    switch (pickerPluralCategory('it', count)) {
      PickerPluralCategory.one => 'Selezionalo di nuovo',
      PickerPluralCategory.many => 'Selezionali di nuovo',
      _ => 'Selezionali di nuovo',
    };

String _seatsFreeIt(int count) => switch (pickerPluralCategory('it', count)) {
  PickerPluralCategory.one => '$count posto',
  PickerPluralCategory.many => '$count posti',
  _ => '$count posti',
};

String _seatsLeftInSectionIt(int count) =>
    switch (pickerPluralCategory('it', count)) {
      PickerPluralCategory.one => 'Resta $count posto',
      PickerPluralCategory.many => 'Restano $count posti',
      _ => 'Restano $count posti',
    };

String _holdLapsedStillFreeIt(int count) => switch (pickerPluralCategory(
  'it',
  count,
)) {
  PickerPluralCategory.one =>
    'La tua prenotazione è scaduta mentre eri via. Quel posto è ancora libero.',
  PickerPluralCategory.many =>
    'La tua prenotazione è scaduta mentre eri via. Quei posti sono ancora liberi.',
  _ =>
    'La tua prenotazione è scaduta mentre eri via. Quei posti sono ancora liberi.',
};

String _holdLapsedSomeTakenIt(int count) => switch (pickerPluralCategory(
  'it',
  count,
)) {
  PickerPluralCategory.one =>
    'La tua prenotazione è scaduta mentre eri via e $count di quei posti è stato occupato. Gli altri sono ancora liberi.',
  PickerPluralCategory.many =>
    'La tua prenotazione è scaduta mentre eri via e $count di quei posti sono stati occupati. Gli altri sono ancora liberi.',
  _ =>
    'La tua prenotazione è scaduta mentre eri via e $count di quei posti sono stati occupati. Gli altri sono ancora liberi.',
};

String _holdLapsedAllTakenIt(int count) => switch (pickerPluralCategory(
  'it',
  count,
)) {
  PickerPluralCategory.one =>
    'La tua prenotazione è scaduta mentre eri via e quel posto è stato occupato.',
  PickerPluralCategory.many =>
    'La tua prenotazione è scaduta mentre eri via e quei posti sono stati occupati.',
  _ =>
    'La tua prenotazione è scaduta mentre eri via e quei posti sono stati occupati.',
};

String _continueWithTotalIt(String money) => 'Continua \u00b7 $money';

/// The `it` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsIt = SeatLayerPickerStrings(
  close: 'Chiudi',
  overview: 'Sede',
  backToVenue: 'Torna all\'impianto',
  cancel: 'Annulla',
  select: 'Seleziona',
  removeSeat: 'Rimuovi posto',
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
  fitVenue: 'Mostra tutta la sede',
  fitWholeVenue: 'Mostra tutta la sede',
  loading: 'Caricamento della mappa dei posti…',
  errorMessage: 'La mappa dei posti non si è caricata',
  retry: 'Riprova',
  accessRefresh: 'Ricarica',
  noSeatsSelected: 'Nessun posto selezionato',
  findBestSeatsCta: 'Trova i posti migliori',
  organizerNote: 'Nota dell’organizzatore',
  accessiblePhysicalSeat: 'Posto fisico accessibile',
  emptyWheelchairSpace: 'Spazio per sedia a rotelle libero',
  findSeatsTogether: 'Trova posti vicini',
  aboutBestSeats: 'Informazioni sulla ricerca di posti vicini',
  closestGroupChosenInstantly:
      'Il gruppo disponibile più vicino, scelto all\'istante.',
  hideLimitedView: 'Nascondi i posti con visuale limitata',
  colorblindSafe: 'Colori adatti al daltonismo',
  notAvailable: 'Non disponibile',
  restrictedView: 'Visuale limitata',
  obstructedView: 'Visuale ostruita',
  premiumSeat: 'Posto premium',
  continueWord: 'Continua',
  allFloors: 'Tutti i piani',
  previousSection: 'Settore precedente',
  nextSection: 'Settore successivo',
  addSeat: 'Aggiungi posto',
  added: 'Aggiunto',
  sectionWord: 'Settore',
  rowWord: 'Fila',
  seatWord: 'Posto',
  seeItIn3D: 'Guardalo in 3D',
  viewFromThisSeat: 'Visuale da questo posto',
  allPrices: 'Tutti i prezzi',
  ticketType: 'Tipo di biglietto',
  tierCompanionGuidance: 'Richiede il posto per sedia a rotelle adiacente',
  findingBestSeats: 'Ricerca dei posti migliori…',
  findSeats: 'Trova posti',
  expandCart: 'Apri il pannello biglietti',
  collapseCart: 'Comprimi il pannello biglietti',
  continueToCheckout: 'Vai al pagamento',
  secureMore: 'Bloccane altri',
  selectSeats: 'Seleziona i posti',
  pickYourSeats: 'Scegli i tuoi posti',
  salesClosedPill: 'Vendite chiuse',
  salesClosedCta: 'Vendite chiuse',
  confirmOrCancelSeat: 'Conferma o annulla questo posto',
  securingSeats: 'Stiamo bloccando i tuoi posti…',
  openingCheckout: 'Apertura del pagamento sicuro…',
  testModeExplained:
      'Le prenotazioni qui non sono reali e non addebitiamo alcuna carta',
  displayOptions: 'Opzioni di visualizzazione',
  companionSeatsNote:
      'I posti per accompagnatore accanto restano selezionabili',
  zoomIn: 'Ingrandisci',
  zoomOut: 'Riduci',
  rotateVenue: 'Trascina per ruotare la sede',
  moveVenue: 'Trascina per spostare la sede',
  mapView: 'Mappa',
  flat2dMap: 'Mappa 2D piatta',
  interactive3dVenueView: 'Vista 3D interattiva dell\'impianto',
  venueView: 'Vista dell\'impianto',
  holdLapsedTitle: 'I tuoi posti sono stati rilasciati',
  salesClosed: 'Vendite chiuse',
  salesClosedCopy: 'La vendita dei biglietti per questo evento è terminata.',
  salesClosedToast: 'Le vendite per questo evento sono chiuse.',
  soldOutEyebrow: 'Questo evento',
  soldOutTitle: 'Esaurito',
  soldOutCopy:
      'Al momento non ci sono posti numerati disponibili per questo evento.',
  holdExpired:
      'La tua prenotazione è scaduta. I posti sono stati liberati. Scegli di nuovo.',
  addingEllipsis: 'Aggiunta…',
  moreTimeAdded: 'Tempo aggiuntivo aggiunto. I tuoi posti restano bloccati.',
  couldNotAddMoreTime:
      'Non è stato possibile aggiungere altro tempo. Vai subito al pagamento.',
  seatsJustTaken: 'Uno o più posti sono stati appena presi. Scegli di nuovo.',
  allSetTitle: 'È tutto pronto',
  confirmedAndOnWay: 'confermato. La conferma è in arrivo.',
  backToMap: 'Torna alla mappa',
  mapDidNotLoad: 'La mappa dei posti non si è caricata',
  checkConnection: 'Controlla la connessione e riprova.',
  accessPausedTitle: 'Questi posti sono bloccati in questo momento',
  accessPausedCopy:
      'L\'organizzatore ha messo in pausa questa selezione. Riprova tra qualche minuto.',
  accessRevokedTitle: 'Questo link di accesso non è più attivo',
  accessRevokedCopy:
      'Chiedi a chi ti ha mandato qui un nuovo link per continuare a prenotare questi posti.',
  accessUnverifiedTitle: 'Non siamo riusciti a verificare il tuo accesso',
  accessUnverifiedCopy:
      'Puoi comunque prenotare tutto ciò che risulta disponibile. Contatta chi ti ha mandato qui per accedere al resto.',
  generalAdmission: 'Ingresso libero',
  numberOfGuests: 'Numero di ospiti',
  chooseGuestsCopy:
      'Scegli quanti ospiti siederanno insieme. Questo tavolo è riservato in esclusiva al tuo gruppo.',
  fewerGuests: 'Meno ospiti',
  moreGuests: 'Più ospiti',
  selectTable: 'Seleziona il tavolo',
  updateTable: 'Aggiorna il tavolo',
  removeWord: 'Rimuovi',
  floorWord: 'Piano',
  totalWord: 'Totale',
  accessNeeds: <String, String>{
    'wheelchair': 'Spazio per sedia a rotelle',
    'companion': 'Posto per accompagnatore',
    'semi-ambulatory': 'Mobilità ridotta',
    'designated-aisle': 'Corridoio / trasferimento',
    'step-free': 'Senza gradini',
    'hearing': 'Ausilio all’ascolto',
    'cart': 'Sottotitoli in diretta',
    'sign-language': 'Lingua dei segni',
    'low-vision': 'Ipovedenti',
    'sensory-friendly': 'Sensorialmente accessibile',
    'plus-size': 'Taglia grande',
    'lift-armrest': 'Bracciolo sollevabile',
  },
  seatsLeft: _seatsLeftIt,
  moreCount: _moreCountIt,
  addMinutes: _addMinutesIt,
  fromPrice: _fromPriceIt,
  sightline: _sightlineIt,
  secureMoreAndCheckout: _secureMoreAndCheckoutIt,
  accessFreeCount: _accessFreeCountIt,
  seatJustTakenByAnother: _seatJustTakenByAnotherIt,
  peekSecured: _peekSecuredIt,
  ticketCount: _ticketCountIt,
  findBestSeats: _findBestSeatsIt,
  reselectSeats: _reselectSeatsIt,
  seatsFree: _seatsFreeIt,
  seatsLeftInSection: _seatsLeftInSectionIt,
  holdLapsedStillFree: _holdLapsedStillFreeIt,
  holdLapsedSomeTaken: _holdLapsedSomeTakenIt,
  holdLapsedAllTaken: _holdLapsedAllTakenIt,
  continueWithTotal: _continueWithTotalIt,
);
