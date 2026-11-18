// GENERATED — do not edit.
//
// Source: design/locale_strings.json (no)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftNo(int count) => '$count igjen';

String _moreCountNo(int count) => '+$count flere';

String _addMinutesNo(int minutes) => '+$minutes min';

String _fromPriceNo(String money) => 'Fra $money';

String _sightlineNo(String metres) => '≈ $metres m til scenen';

String _secureMoreAndCheckoutNo(int count) => 'Sikre $count til og betal';

String _accessFreeCountNo(int count) => '$count ledige';

String _seatJustTakenByAnotherNo(String label) =>
    'Plass $label ble nettopp tatt av en annen kjøper.';

String _peekSecuredNo(int count, String total) =>
    '✓ $count sikret · $total. Du blir ikke belastet ennå';

String _venueMapNo(String venue) => 'Setekart for $venue';

String _accessibleStepNo(int index, int total) => '$index av $total';

String _chooseMinMaxGuestsNo(int min, int max) =>
    'Velg mellom $min og $max gjester.';

String _chooseMoreNo(int count) => 'Velg $count til';

String _seatsHeldForNeedMoreTimeNo(String time) =>
    'Plassene dine er reservert i $time. Trenger du mer tid?';

String _ticketCountNo(int count) => switch (pickerPluralCategory('no', count)) {
  PickerPluralCategory.one => '$count billett',
  _ => '$count billetter',
};

String _findBestSeatsNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => 'Finn $count beste plass',
      _ => 'Finn $count beste plasser',
    };

String _reselectSeatsNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => 'Velg den på nytt',
      _ => 'Velg dem på nytt',
    };

String _seatsFreeNo(int count) => switch (pickerPluralCategory('no', count)) {
  PickerPluralCategory.one => '$count plass',
  _ => '$count plasser',
};

String _seatsLeftInSectionNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => '$count plass igjen',
      _ => '$count plasser igjen',
    };

String _holdLapsedStillFreeNo(int count) => switch (pickerPluralCategory(
  'no',
  count,
)) {
  PickerPluralCategory.one =>
    'Reservasjonen din utløp mens du var borte. Plassen er fortsatt ledig.',
  _ =>
    'Reservasjonen din utløp mens du var borte. Plassene er fortsatt ledige.',
};

String _holdLapsedSomeTakenNo(int count) => switch (pickerPluralCategory(
  'no',
  count,
)) {
  PickerPluralCategory.one =>
    'Reservasjonen din utløp mens du var borte, og $count av plassene er blitt tatt. Resten er fortsatt ledige.',
  _ =>
    'Reservasjonen din utløp mens du var borte, og $count av plassene er blitt tatt. Resten er fortsatt ledige.',
};

String _holdLapsedAllTakenNo(int count) => switch (pickerPluralCategory(
  'no',
  count,
)) {
  PickerPluralCategory.one =>
    'Reservasjonen din utløp mens du var borte, og plassen er blitt tatt.',
  _ => 'Reservasjonen din utløp mens du var borte, og plassene er blitt tatt.',
};

String _accessibleSectionsNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => '$count seksjon',
      _ => '$count seksjoner',
    };

String _placesAvailableNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => '$count plass ledig nå',
      _ => '$count plasser ledige nå',
    };

String _removeTicketsNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => 'Fjern $count billett',
      _ => 'Fjern $count billetter',
    };

String _holdMinutesLeftNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => '$count minutt igjen',
      _ => '$count minutter igjen',
    };

String _holdSecondsLeftNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => '$count sekund igjen',
      _ => '$count sekunder igjen',
    };

String _holdLapsedBodyNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => 'De var reservert i $count minutt.',
      _ => 'De var reservert i $count minutter.',
    };

String _seatsNotRecoveredNo(int count) =>
    switch (pickerPluralCategory('no', count)) {
      PickerPluralCategory.one => '$count plass kunne ikke reserveres igjen',
      _ => '$count plasser kunne ikke reserveres igjen',
    };

String _continueWithTotalNo(String money) => 'Fortsett \u00b7 $money';

/// The `no` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsNo = SeatLayerPickerStrings(
  close: 'Lukk',
  overview: 'Spillested',
  backToVenue: 'Tilbake til arenaen',
  cancel: 'Avbryt',
  select: 'Velg',
  removeSeat: 'Fjern plass',
  viewFromHere: 'Utsikt herfra',
  openVenue360: 'Åpne arenaen i 360°',
  recentre: 'Sentrer på scenen igjen',
  viewFromYourSeat: 'utsikt fra plassen din',
  emptyTrayHint:
      'Trykk på en plass på kartet, eller la oss velge de beste ledige for deg.',
  anyTicketType: 'Hvilken som helst billettype',
  anyVenueZone: 'Hvilken som helst sone',
  bestSeats: 'Beste plassene',
  showLess: 'Vis mindre',
  undo: 'Angre',
  holdAndCheckout: 'Reserver plasser og betal',
  poweredBy: 'Drevet av SeatLayer',
  testMode: 'Testmodus',
  accessibility: 'Tilgjengelighet og farger',
  accessibilityTitle: 'Tilgjengelighet og farger',
  fitVenue: 'Vis hele stedet',
  fitWholeVenue: 'Vis hele stedet',
  loading: 'Laster setekartet…',
  errorMessage: 'Setekartet ble ikke lastet',
  retry: 'Prøv igjen',
  accessRefresh: 'Last på nytt',
  noSeatsSelected: 'Ingen plasser valgt',
  findBestSeatsCta: 'Finn de beste plassene',
  organizerNote: 'Melding fra arrangøren',
  accessiblePhysicalSeat: 'Tilgjengelig fysisk plass',
  emptyWheelchairSpace: 'Ledig rullestolplass',
  findSeatsTogether: 'Finn plasser ved siden av hverandre',
  aboutBestSeats: 'Om å finne plasser sammen',
  closestGroupChosenInstantly: 'Nærmeste ledige gruppe, valgt med én gang.',
  hideLimitedView: 'Skjul plasser med begrenset sikt',
  colorblindSafe: 'Fargeblindvennlige farger',
  notAvailable: 'Ikke tilgjengelig',
  viewGroupTitle: 'VISNING',
  restrictedView: 'Begrenset sikt',
  obstructedView: 'Blokkert sikt',
  premiumSeat: 'Premiumplass',
  continueWord: 'Fortsett',
  allFloors: 'Alle etasjer',
  previousSection: 'Forrige seksjon',
  nextSection: 'Neste seksjon',
  addSeat: 'Legg til plass',
  added: 'Lagt til',
  sectionWord: 'Seksjon',
  rowWord: 'Rad',
  seatWord: 'Plass',
  seeItIn3D: 'Se den i 3D',
  viewFromThisSeat: 'Utsikt fra denne plassen',
  allPrices: 'Alle priser',
  ticketType: 'Billettype',
  tierCompanionGuidance: 'Krever den tilstøtende rullestolplassen',
  findingBestSeats: 'Finner de beste plassene…',
  findSeats: 'Finn plasser',
  expandCart: 'Åpne billettpanelet',
  collapseCart: 'Slå sammen billettpanelet',
  continueToCheckout: 'Fortsett til betaling',
  secureMore: 'Sikre flere',
  selectSeats: 'Velg plasser',
  pickYourSeats: 'Velg plassene dine',
  salesClosedPill: 'Salget er stengt',
  salesClosedCta: 'Salget er stengt',
  confirmOrCancelSeat: 'Bekreft eller avbryt denne plassen',
  securingSeats: 'Sikrer plassene dine…',
  openingCheckout: 'Åpner sikker betaling…',
  testModeExplained:
      'Bestillinger her er ikke ekte, og ingen kort blir belastet',
  displayOptions: 'Visningsalternativer',
  companionSeatsNote: 'Ledsagerplassene ved siden av kan fortsatt velges',
  zoomIn: 'Zoom inn',
  zoomOut: 'Zoom ut',
  rotateVenue: 'Dra for å rotere stedet',
  moveVenue: 'Dra for å flytte stedet',
  mapView: 'Kart',
  flat2dMap: 'Flatt 2D-kart',
  interactive3dVenueView: 'Interaktiv 3D-visning av arenaen',
  venueView: 'Arenavisning',
  holdLapsedTitle: 'Plassene dine ble frigitt',
  salesClosed: 'Salget er stengt',
  salesClosedCopy: 'Billettsalget til dette arrangementet er avsluttet.',
  salesClosedToast: 'Salget til dette arrangementet er stengt.',
  soldOutEyebrow: 'Dette arrangementet',
  soldOutTitle: 'Utsolgt',
  soldOutCopy:
      'Det er ingen nummererte plasser ledige til dette arrangementet akkurat nå.',
  holdExpired:
      'Reservasjonen din har utløpt. Plassene ble frigitt. Velg på nytt.',
  addingEllipsis: 'Legger til…',
  moreTimeAdded: 'Mer tid lagt til. Plassene dine er fortsatt reservert.',
  couldNotAddMoreTime: 'Kunne ikke legge til mer tid. Gå til betaling nå.',
  seatsJustTaken: 'Én eller flere plasser ble nettopp tatt. Velg på nytt.',
  allSetTitle: 'Da er alt klart',
  confirmedAndOnWay: 'bekreftet. En bekreftelse er på vei.',
  backToMap: 'Tilbake til kartet',
  mapDidNotLoad: 'Setekartet ble ikke lastet',
  checkConnection: 'Sjekk tilkoblingen og prøv igjen.',
  accessPausedTitle: 'Disse plassene er sperret akkurat nå',
  accessPausedCopy:
      'Arrangøren har satt dette utvalget på pause. Prøv igjen om noen minutter.',
  accessRevokedTitle: 'Denne tilgangslenken er ikke lenger aktiv',
  accessRevokedCopy:
      'Be den som sendte deg hit om en ny lenke for å fortsette å bestille disse plassene.',
  accessUnverifiedTitle: 'Vi klarte ikke å bekrefte tilgangen din',
  accessUnverifiedCopy:
      'Du kan fortsatt bestille alt som vises som ledig. Kontakt den som sendte deg hit for tilgang til resten.',
  generalAdmission: 'Fri plassering',
  numberOfGuests: 'Antall gjester',
  chooseGuestsCopy:
      'Velg hvor mange gjester som skal sitte sammen. Bordet reserveres utelukkende for selskapet ditt.',
  fewerGuests: 'Færre gjester',
  moreGuests: 'Flere gjester',
  selectTable: 'Velg bord',
  updateTable: 'Oppdater bordet',
  removeWord: 'Fjern',
  floorWord: 'Etasje',
  totalWord: 'Totalt',
  chooseSeats: 'Velg plassene dine',
  chooseTickets: 'Velg billetter',
  placeWord: 'PLASS',
  ticketWord: 'Billett',
  passport: 'Plassprofil',
  venue3D: '3D',
  venueZone: 'Sone',
  venueMapHint:
      'Plasser velges med kontrollene rundt kartet: prislinjen over det, seksjonskontrollene under det og billettpanelet nederst.',
  previousSeat: 'Forrige plass',
  nextSeat: 'Neste plass',
  orbitMode: 'Roter arenaen',
  panMode: 'Flytt arenaen',
  openInteractive3dVenue: 'Åpne interaktiv 3D-visning av arenaen',
  showSeatsFor: 'VIS PLASSER FOR',
  accessJumpFirstSection: 'Gå til den første seksjonen',
  accessJumpNextSection: 'Gå til neste seksjon',
  fewerTickets: 'Færre billetter',
  moreTickets: 'Flere billetter',
  addTickets: 'Legg til billetter',
  noSelectableSeats: 'Ingen plasser kan velges akkurat nå.',
  confirmYourTickets: 'Bekreft billettene dine',
  seatsSecuredOpeningCheckout: 'Plassene er sikret. Åpner betaling…',
  holdInCheckoutTitle: 'Plassene dine er allerede i betalingen',
  holdInCheckoutBody:
      'Fullfør betalingen for å beholde dem. Vil du velge andre plasser, må du frigi disse først — de legges ut for salg igjen.',
  releaseAndChangeSeats: 'Frigi og bytt plasser',
  holdAlreadyHeldTitle: 'Plassene dine er allerede reservert',
  holdAlreadyHeldBody: 'Fortsett til betaling for å beholde dem.',
  accessExpiredTitle: 'Økten din er utløpt',
  accessExpiredCopy:
      'Last inn setekartet på nytt for å fortsette. Plasser som allerede ligger i handlekurven din, forblir reservert til tiden er ute.',
  dismissError: 'Lukk feilmelding',
  testModeLong: 'Testmodus · ingenting bestilles',
  accessNeeds: <String, String>{
    'wheelchair': 'Rullestolplass',
    'companion': 'Ledsagerplass',
    'semi-ambulatory': 'Nedsatt bevegelighet',
    'designated-aisle': 'Gang / overflytting',
    'step-free': 'Trinnfri',
    'hearing': 'Teleslynge',
    'cart': 'Direkteteksting',
    'sign-language': 'Tegnspråk',
    'low-vision': 'Svaksynt',
    'sensory-friendly': 'Sansevennlig',
    'plus-size': 'Ekstra bred',
    'lift-armrest': 'Oppfellbart armlene',
  },
  seatsLeft: _seatsLeftNo,
  moreCount: _moreCountNo,
  addMinutes: _addMinutesNo,
  fromPrice: _fromPriceNo,
  sightline: _sightlineNo,
  secureMoreAndCheckout: _secureMoreAndCheckoutNo,
  accessFreeCount: _accessFreeCountNo,
  seatJustTakenByAnother: _seatJustTakenByAnotherNo,
  peekSecured: _peekSecuredNo,
  venueMap: _venueMapNo,
  accessibleStep: _accessibleStepNo,
  chooseMinMaxGuests: _chooseMinMaxGuestsNo,
  chooseMore: _chooseMoreNo,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeNo,
  ticketCount: _ticketCountNo,
  findBestSeats: _findBestSeatsNo,
  reselectSeats: _reselectSeatsNo,
  seatsFree: _seatsFreeNo,
  seatsLeftInSection: _seatsLeftInSectionNo,
  holdLapsedStillFree: _holdLapsedStillFreeNo,
  holdLapsedSomeTaken: _holdLapsedSomeTakenNo,
  holdLapsedAllTaken: _holdLapsedAllTakenNo,
  accessibleSections: _accessibleSectionsNo,
  placesAvailable: _placesAvailableNo,
  removeTickets: _removeTicketsNo,
  holdMinutesLeft: _holdMinutesLeftNo,
  holdSecondsLeft: _holdSecondsLeftNo,
  holdLapsedBody: _holdLapsedBodyNo,
  seatsNotRecovered: _seatsNotRecoveredNo,
  continueWithTotal: _continueWithTotalNo,
);
