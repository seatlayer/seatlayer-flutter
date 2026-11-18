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

String _secureMoreAndCheckoutDe(int count) =>
    '$count weitere sichern & zum Checkout';

String _accessFreeCountDe(int count) => '$count frei';

String _seatJustTakenByAnotherDe(String label) =>
    'Platz $label wurde gerade von einem anderen Käufer übernommen.';

String _peekSecuredDe(int count, String total) =>
    '✓ $count gesichert · $total. Noch wird nichts abgebucht';

String _ticketCountDe(int count) =>
    count == 1 ? '$count Ticket' : '$count Tickets';

String _findBestSeatsDe(int count) =>
    count == 1 ? '$count besten Platz finden' : '$count beste Plätze finden';

String _reselectSeatsDe(int count) =>
    count == 1 ? 'Erneut auswählen' : 'Erneut auswählen';

String _seatsFreeDe(int count) => count == 1 ? '$count Platz' : '$count Plätze';

String _seatsLeftInSectionDe(int count) =>
    count == 1 ? '$count Platz verfügbar' : '$count Plätze verfügbar';

String _holdLapsedStillFreeDe(int count) => count == 1
    ? 'Ihre Reservierung ist abgelaufen, während Sie weg waren. Dieser Platz ist noch frei.'
    : 'Ihre Reservierung ist abgelaufen, während Sie weg waren. Diese Plätze sind noch frei.';

String _holdLapsedSomeTakenDe(int count) => count == 1
    ? 'Ihre Reservierung ist abgelaufen, während Sie weg waren, und $count dieser Plätze ist inzwischen vergeben. Die übrigen sind noch frei.'
    : 'Ihre Reservierung ist abgelaufen, während Sie weg waren, und $count dieser Plätze sind inzwischen vergeben. Die übrigen sind noch frei.';

String _holdLapsedAllTakenDe(int count) => count == 1
    ? 'Ihre Reservierung ist abgelaufen, während Sie weg waren, und dieser Platz ist inzwischen vergeben.'
    : 'Ihre Reservierung ist abgelaufen, während Sie weg waren, und diese Plätze sind inzwischen vergeben.';

String _continueWithTotalDe(String money) => 'Weiter \u00b7 $money';

/// The `de` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsDe = SeatLayerPickerStrings(
  close: 'Schließen',
  overview: 'Spielstätte',
  backToVenue: 'Zurück zur Übersicht',
  cancel: 'Abbrechen',
  select: 'Auswählen',
  removeSeat: 'Platz entfernen',
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
  fitVenue: 'Gesamten Veranstaltungsort anzeigen',
  fitWholeVenue: 'Gesamten Veranstaltungsort anzeigen',
  loading: 'Sitzplan wird geladen…',
  errorMessage: 'Der Sitzplan konnte nicht geladen werden',
  retry: 'Erneut versuchen',
  accessRefresh: 'Neu laden',
  noSeatsSelected: 'Keine Plätze ausgewählt',
  findBestSeatsCta: 'Beste Plätze finden',
  organizerNote: 'Hinweis des Veranstalters',
  accessiblePhysicalSeat: 'Barrierefreier fester Sitzplatz',
  emptyWheelchairSpace: 'Leerer Rollstuhlplatz',
  findSeatsTogether: 'Plätze nebeneinander finden',
  aboutBestSeats: 'Über zusammenhängende Plätze',
  closestGroupChosenInstantly:
      'Nächstgelegene verfügbare Gruppe, sofort ausgewählt.',
  hideLimitedView: 'Plätze mit eingeschränkter Sicht ausblenden',
  colorblindSafe: 'Farbenblindenfreundliche Farben',
  notAvailable: 'Nicht verfügbar',
  restrictedView: 'Eingeschränkte Sicht',
  obstructedView: 'Sichtbehinderung',
  premiumSeat: 'Premium-Platz',
  continueWord: 'Weiter',
  allFloors: 'Alle Etagen',
  previousSection: 'Vorheriger Bereich',
  nextSection: 'Nächster Bereich',
  addSeat: 'Platz hinzufügen',
  added: 'Hinzugefügt',
  sectionWord: 'Bereich',
  rowWord: 'Reihe',
  seatWord: 'Platz',
  seeItIn3D: 'In 3D ansehen',
  viewFromThisSeat: 'Ansicht von diesem Platz',
  allPrices: 'Alle Preise',
  ticketType: 'Ticketart',
  tierCompanionGuidance: 'Benachbarter Rollstuhlplatz erforderlich',
  findingBestSeats: 'Beste Plätze werden gesucht…',
  findSeats: 'Plätze finden',
  expandCart: 'Ticketbereich öffnen',
  collapseCart: 'Ticketbereich einklappen',
  continueToCheckout: 'Weiter zum Checkout',
  secureMore: 'Mehr sichern',
  selectSeats: 'Plätze auswählen',
  pickYourSeats: 'Wählen Sie Ihre Plätze',
  salesClosedPill: 'Der Verkauf ist beendet',
  salesClosedCta: 'Verkauf beendet',
  confirmOrCancelSeat: 'Diesen Platz bestätigen oder abbrechen',
  securingSeats: 'Ihre Plätze werden gesichert…',
  openingCheckout: 'Sicherer Checkout wird geöffnet…',
  testModeExplained:
      'Buchungen hier sind nicht echt, es wird keine Karte abgebucht',
  displayOptions: 'Anzeigeoptionen',
  companionSeatsNote: 'Begleitplätze daneben bleiben wählbar',
  zoomIn: 'Vergrößern',
  zoomOut: 'Verkleinern',
  rotateVenue: 'Ziehen, um den Veranstaltungsort zu drehen',
  moveVenue: 'Ziehen, um den Veranstaltungsort zu verschieben',
  mapView: 'Karte',
  flat2dMap: 'Flache 2D-Karte',
  interactive3dVenueView: 'Interaktive 3D-Ansicht des Veranstaltungsorts',
  venueView: 'Ansicht des Veranstaltungsorts',
  holdLapsedTitle: 'Ihre Plätze wurden freigegeben',
  salesClosed: 'Der Verkauf ist beendet',
  salesClosedCopy: 'Der Ticketverkauf für diese Veranstaltung ist beendet.',
  salesClosedToast: 'Der Verkauf für diese Veranstaltung ist beendet.',
  soldOutEyebrow: 'Diese Veranstaltung',
  soldOutTitle: 'Ausverkauft',
  soldOutCopy:
      'Für diese Veranstaltung sind derzeit keine reservierten Plätze verfügbar.',
  holdExpired:
      'Ihre Reservierung ist abgelaufen. Die Plätze wurden freigegeben. Bitte erneut auswählen.',
  addingEllipsis: 'Wird hinzugefügt…',
  moreTimeAdded:
      'Zusätzliche Zeit hinzugefügt. Ihre Plätze sind weiterhin reserviert.',
  couldNotAddMoreTime:
      'Zusätzliche Zeit konnte nicht hinzugefügt werden. Bitte jetzt zum Checkout gehen.',
  seatsJustTaken:
      'Ein oder mehrere Plätze wurden gerade vergeben. Bitte wählen Sie erneut.',
  allSetTitle: 'Alles bereit',
  confirmedAndOnWay: 'bestätigt. Eine Bestätigung ist unterwegs.',
  backToMap: 'Zurück zur Karte',
  mapDidNotLoad: 'Der Sitzplan konnte nicht geladen werden',
  checkConnection:
      'Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
  accessPausedTitle: 'Diese Plätze sind gerade reserviert',
  accessPausedCopy:
      'Der Veranstalter hat diese Auswahl pausiert. Versuchen Sie es in ein paar Minuten erneut.',
  accessRevokedTitle: 'Dieser Zugangslink ist nicht mehr aktiv',
  accessRevokedCopy:
      'Bitten Sie die Person, die Ihnen diesen Link geschickt hat, um einen neuen, um weiter buchen zu können.',
  accessUnverifiedTitle: 'Ihr Zugang konnte nicht bestätigt werden',
  accessUnverifiedCopy:
      'Sie können weiterhin alles buchen, was als verfügbar angezeigt wird. Wenden Sie sich für Zugang zum Rest an die Person, die Ihnen den Link geschickt hat.',
  generalAdmission: 'Stehplatz',
  numberOfGuests: 'Anzahl der Gäste',
  chooseGuestsCopy:
      'Wählen Sie, wie viele Gäste zusammensitzen. Dieser Tisch ist exklusiv für Ihre Gruppe reserviert.',
  fewerGuests: 'Weniger Gäste',
  moreGuests: 'Mehr Gäste',
  selectTable: 'Tisch auswählen',
  updateTable: 'Tisch aktualisieren',
  removeWord: 'Entfernen',
  accessNeeds: <String, String>{
    'wheelchair': 'Rollstuhlplatz',
    'companion': 'Begleitplatz',
    'semi-ambulatory': 'Eingeschränkte Mobilität',
    'designated-aisle': 'Gang / Umsetzen',
    'step-free': 'Stufenlos',
    'hearing': 'Höranlage',
    'cart': 'Live-Untertitel',
    'sign-language': 'Gebärdensprache',
    'low-vision': 'Sehbehinderung',
    'sensory-friendly': 'Reizarm',
    'plus-size': 'Extrabreit',
    'lift-armrest': 'Hochklappbare Armlehne',
  },
  seatsLeft: _seatsLeftDe,
  moreCount: _moreCountDe,
  addMinutes: _addMinutesDe,
  fromPrice: _fromPriceDe,
  sightline: _sightlineDe,
  secureMoreAndCheckout: _secureMoreAndCheckoutDe,
  accessFreeCount: _accessFreeCountDe,
  seatJustTakenByAnother: _seatJustTakenByAnotherDe,
  peekSecured: _peekSecuredDe,
  ticketCount: _ticketCountDe,
  findBestSeats: _findBestSeatsDe,
  reselectSeats: _reselectSeatsDe,
  seatsFree: _seatsFreeDe,
  seatsLeftInSection: _seatsLeftInSectionDe,
  holdLapsedStillFree: _holdLapsedStillFreeDe,
  holdLapsedSomeTaken: _holdLapsedSomeTakenDe,
  holdLapsedAllTaken: _holdLapsedAllTakenDe,
  continueWithTotal: _continueWithTotalDe,
);
