// GENERATED — do not edit.
//
// Source: design/locale_strings.json (de)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableDe(String label) =>
    '$label ist nicht mehr verfügbar. Wählen Sie einen anderen Platz.';

String _labelsNoLongerAvailableDe(String labels) =>
    '$labels sind nicht mehr verfügbar. Wählen Sie eine andere Gruppe.';

String _couldNotFindSeatsTogetherDe(int count) =>
    'Wir konnten keine $count zusammenhängenden Plätze finden. Versuchen Sie es mit weniger Plätzen oder einer anderen Ticketart.';

String _maxTicketsForOrderDe(int count) =>
    'Sie können für diese Bestellung bis zu $count Tickets auswählen.';

String _couldNotRemoveLabelDe(String label) =>
    '$label konnte nicht entfernt werden. Ihre Reservierung bleibt unverändert.';

String _peekSecuredDe(int count, String total) =>
    '✓ $count gesichert · $total. Noch wird nichts abgebucht';

String _venueMapDe(String venue) => 'Sitzplan für $venue';

String _accessibleStepDe(int index, int total) => '$index von $total';

String _chooseMinMaxGuestsDe(int min, int max) =>
    'Wählen Sie zwischen $min und $max Gästen.';

String _chooseMoreDe(int count) => 'Noch $count wählen';

String _seatsHeldForNeedMoreTimeDe(String time) =>
    'Ihre Plätze sind für $time reserviert. Brauchen Sie mehr Zeit?';

String _accessNeedWithCountDe(String need, int count) => '$need · $count';

String _ticketCountDe(int count) => switch (pickerPluralCategory('de', count)) {
  PickerPluralCategory.one => '$count Ticket',
  _ => '$count Tickets',
};

String _findBestSeatsDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count besten Platz finden',
      _ => '$count beste Plätze finden',
    };

String _reselectSeatsDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => 'Erneut auswählen',
      _ => 'Erneut auswählen',
    };

String _seatsFreeDe(int count) => switch (pickerPluralCategory('de', count)) {
  PickerPluralCategory.one => '$count Platz',
  _ => '$count Plätze',
};

String _seatsLeftInSectionDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count Platz verfügbar',
      _ => '$count Plätze verfügbar',
    };

String _holdLapsedStillFreeDe(int count) => switch (pickerPluralCategory(
  'de',
  count,
)) {
  PickerPluralCategory.one =>
    'Ihre Reservierung ist abgelaufen, während Sie weg waren. Dieser Platz ist noch frei.',
  _ =>
    'Ihre Reservierung ist abgelaufen, während Sie weg waren. Diese Plätze sind noch frei.',
};

String _holdLapsedSomeTakenDe(int count) => switch (pickerPluralCategory(
  'de',
  count,
)) {
  PickerPluralCategory.one =>
    'Ihre Reservierung ist abgelaufen, während Sie weg waren, und $count dieser Plätze ist inzwischen vergeben. Die übrigen sind noch frei.',
  _ =>
    'Ihre Reservierung ist abgelaufen, während Sie weg waren, und $count dieser Plätze sind inzwischen vergeben. Die übrigen sind noch frei.',
};

String _holdLapsedAllTakenDe(int count) => switch (pickerPluralCategory(
  'de',
  count,
)) {
  PickerPluralCategory.one =>
    'Ihre Reservierung ist abgelaufen, während Sie weg waren, und dieser Platz ist inzwischen vergeben.',
  _ =>
    'Ihre Reservierung ist abgelaufen, während Sie weg waren, und diese Plätze sind inzwischen vergeben.',
};

String _accessibleSectionsDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count Bereich',
      _ => '$count Bereiche',
    };

String _placesAvailableDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count Platz derzeit verfügbar',
      _ => '$count Plätze derzeit verfügbar',
    };

String _removeTicketsDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count Ticket entfernen',
      _ => '$count Tickets entfernen',
    };

String _holdMinutesLeftDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => 'Noch $count Minute',
      _ => 'Noch $count Minuten',
    };

String _holdSecondsLeftDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => 'Noch $count Sekunde',
      _ => 'Noch $count Sekunden',
    };

String _holdLapsedBodyDe(int count) => switch (pickerPluralCategory(
  'de',
  count,
)) {
  PickerPluralCategory.one => 'Die Plätze waren $count Minute lang reserviert.',
  _ => 'Die Plätze waren $count Minuten lang reserviert.',
};

String _seatsNotRecoveredDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one =>
        '$count Platz konnte nicht wieder reserviert werden',
      _ => '$count Plätze konnten nicht wieder reserviert werden',
    };

String _activeFiltersDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count Filter',
      _ => '$count Filter',
    };

String _accessibilityFiltersActiveDe(int count) =>
    switch (pickerPluralCategory('de', count)) {
      PickerPluralCategory.one => '$count Barrierefreiheitsfilter aktiv',
      _ => '$count Barrierefreiheitsfilter aktiv',
    };

String _onlyLeftDe(int count) => switch (pickerPluralCategory('de', count)) {
  PickerPluralCategory.one => '$count Platz verfügbar',
  _ => '$count Plätze verfügbar',
};

String _maintenancePausedDe(int count) => switch (pickerPluralCategory(
  'de',
  count,
)) {
  PickerPluralCategory.one =>
    'Die Buchung ist wegen Wartungsarbeiten pausiert. Bitte versuchen Sie es in etwa $count Minute erneut.',
  _ =>
    'Die Buchung ist wegen Wartungsarbeiten pausiert. Bitte versuchen Sie es in etwa $count Minuten erneut.',
};

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
  testMode: 'Testmodus',
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
  viewGroupTitle: 'ANSICHT',
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
  ticketPrices: 'Ticketpreise',
  yourSeats: 'Ihre Plätze',
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
  ticketTypeSoldOut:
      'Diese Ticketart ist ausverkauft. Versuchen Sie eine andere Ticketart.',
  seatsNoLongerAvailableTryAnother:
      'Diese Plätze sind nicht mehr verfügbar. Versuchen Sie eine andere Anzahl oder Ticketart.',
  companionPairRequired:
      'Wählen Sie zu jedem Begleitticket den benachbarten Rollstuhlplatz aus.',
  ticketOptionNotApplicable:
      'Diese Ticketauswahl ist für den gewählten Platz nicht verfügbar.',
  maintenancePausedShortly:
      'Die Buchung ist wegen Wartungsarbeiten für einige Minuten pausiert. Bitte versuchen Sie es in Kürze erneut.',
  guestsOnly: 'Diese Veranstaltung ist für eingeladene Gäste.',
  guestChoiceClosed: 'Die Platzwahl ist gerade nicht geöffnet.',
  maxOneTicketForOrder:
      'Sie können für diese Bestellung bis zu 1 Ticket auswählen.',
  tooManyAttempts:
      'Zu viele Versuche. Warten Sie einen Moment und versuchen Sie es erneut.',
  seatHeldForRenewal:
      'Einer dieser Plätze ist für einen Saisonticket-Inhaber reserviert, der ihn noch verlängern kann. Wählen Sie einen anderen Platz.',
  seatUnavailable: 'Dieser Platz ist nicht verfügbar.',
  eventUnavailable: 'Tickets können hier gerade nicht gebucht werden.',
  savedSeatsNotRestored:
      'Ihre vorherigen Plätze konnten nicht wiederhergestellt werden. Bitte wählen Sie erneut.',
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
  floorWord: 'Etage',
  totalWord: 'Gesamt',
  adjustSelection: 'Sitzauswahl anpassen',
  backToSeatMap: 'Zurück zum Sitzplan',
  chooseSeats: 'Wählen Sie Ihre Plätze',
  chooseTickets: 'Tickets wählen',
  placeWord: 'PLATZ',
  guestsWord: 'Gäste',
  tableWord: 'Tisch',
  ticketWord: 'Ticket',
  passport: 'Platzprofil',
  venue3D: '3D',
  venueZone: 'Zone',
  venueMapHint:
      'Plätze wählen Sie mit den Bedienelementen rund um den Plan: der Preisleiste darüber, der Bereichsauswahl darunter und dem Ticketbereich unten.',
  previousSeat: 'Vorheriger Platz',
  nextSeat: 'Nächster Platz',
  orbitMode: 'Veranstaltungsort drehen',
  panMode: 'Veranstaltungsort verschieben',
  openInteractive3dVenue:
      'Interaktive 3D-Ansicht des Veranstaltungsorts öffnen',
  showSeatsFor: 'PLÄTZE ANZEIGEN FÜR',
  accessJumpFirstSection: 'Zum ersten Bereich springen',
  accessJumpNextSection: 'Zum nächsten Bereich springen',
  fewerTickets: 'Weniger Tickets',
  moreTickets: 'Mehr Tickets',
  addTickets: 'Tickets hinzufügen',
  noSelectableSeats: 'Derzeit sind keine auswählbaren Plätze verfügbar.',
  confirmYourTickets: 'Ihre Tickets bestätigen',
  seatsSecuredOpeningCheckout: 'Plätze gesichert. Checkout wird geöffnet…',
  holdInCheckoutTitle: 'Ihre Plätze sind bereits im Checkout',
  holdInCheckoutBody:
      'Schließen Sie den Checkout ab, um sie zu behalten. Wenn Sie andere Plätze wählen möchten, geben Sie diese zuerst frei — sie gehen dann wieder in den Verkauf.',
  releaseAndChangeSeats: 'Freigeben und Plätze ändern',
  holdAlreadyHeldTitle: 'Ihre Plätze sind bereits reserviert',
  holdAlreadyHeldBody: 'Gehen Sie weiter zum Checkout, um sie zu behalten.',
  accessExpiredTitle: 'Ihre Sitzung ist abgelaufen',
  accessExpiredCopy:
      'Laden Sie den Sitzplan neu, um fortzufahren. Plätze, die bereits in Ihrem Warenkorb sind, bleiben reserviert, bis der Timer abläuft.',
  dismissError: 'Fehlermeldung schließen',
  testModeLong: 'Testmodus · keine Buchung',
  seatRemoved: 'Ticket entfernt',
  reloadSeatMap: 'Sitzplan neu laden',
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
  labelNoLongerAvailable: _labelNoLongerAvailableDe,
  labelsNoLongerAvailable: _labelsNoLongerAvailableDe,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherDe,
  maxTicketsForOrder: _maxTicketsForOrderDe,
  couldNotRemoveLabel: _couldNotRemoveLabelDe,
  peekSecured: _peekSecuredDe,
  venueMap: _venueMapDe,
  accessibleStep: _accessibleStepDe,
  chooseMinMaxGuests: _chooseMinMaxGuestsDe,
  chooseMore: _chooseMoreDe,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeDe,
  accessNeedWithCount: _accessNeedWithCountDe,
  ticketCount: _ticketCountDe,
  findBestSeats: _findBestSeatsDe,
  reselectSeats: _reselectSeatsDe,
  seatsFree: _seatsFreeDe,
  seatsLeftInSection: _seatsLeftInSectionDe,
  holdLapsedStillFree: _holdLapsedStillFreeDe,
  holdLapsedSomeTaken: _holdLapsedSomeTakenDe,
  holdLapsedAllTaken: _holdLapsedAllTakenDe,
  accessibleSections: _accessibleSectionsDe,
  placesAvailable: _placesAvailableDe,
  removeTickets: _removeTicketsDe,
  holdMinutesLeft: _holdMinutesLeftDe,
  holdSecondsLeft: _holdSecondsLeftDe,
  holdLapsedBody: _holdLapsedBodyDe,
  seatsNotRecovered: _seatsNotRecoveredDe,
  activeFilters: _activeFiltersDe,
  accessibilityFiltersActive: _accessibilityFiltersActiveDe,
  onlyLeft: _onlyLeftDe,
  maintenancePaused: _maintenancePausedDe,
  continueWithTotal: _continueWithTotalDe,
);
