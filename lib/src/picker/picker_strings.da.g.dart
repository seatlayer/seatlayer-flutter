// GENERATED — do not edit.
//
// Source: design/locale_strings.json (da)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftDa(int count) => '$count tilbage';

String _moreCountDa(int count) => '+$count flere';

String _addMinutesDa(int minutes) => '+$minutes min';

String _fromPriceDa(String money) => 'Fra $money';

String _sightlineDa(String metres) => '≈ $metres m til scenen';

String _secureMoreAndCheckoutDa(int count) => 'Sikr $count mere og betal';

String _accessFreeCountDa(int count) => '$count ledige';

String _seatJustTakenByAnotherDa(String label) =>
    'Plads $label blev lige taget af en anden køber.';

String _labelNoLongerAvailableDa(String label) =>
    '$label er ikke længere ledig. Vælg en anden plads.';

String _labelsNoLongerAvailableDa(String labels) =>
    '$labels er ikke længere ledige. Vælg en anden gruppe.';

String _couldNotFindSeatsTogetherDa(int count) =>
    'Vi kunne ikke finde $count pladser ved siden af hinanden. Prøv færre pladser eller en anden billettype.';

String _couldNotRemoveLabelDa(String label) =>
    'Kunne ikke fjerne $label. Din reservation er uændret.';

String _peekSecuredDa(int count, String total) =>
    '✓ $count sikret · $total. Du bliver ikke trukket endnu';

String _venueMapDa(String venue) => 'Pladsoversigt for $venue';

String _accessibleStepDa(int index, int total) => '$index af $total';

String _chooseMinMaxGuestsDa(int min, int max) =>
    'Vælg mellem $min og $max gæster.';

String _chooseMoreDa(int count) => 'Vælg $count til';

String _seatsHeldForNeedMoreTimeDa(String time) =>
    'Dine pladser er reserveret i $time. Brug for mere tid?';

String _accessNeedWithCountDa(String need, int count) => '$need · $count';

String _ticketCountDa(int count) => switch (pickerPluralCategory('da', count)) {
  PickerPluralCategory.one => '$count billet',
  _ => '$count billetter',
};

String _findBestSeatsDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => 'Find $count bedste plads',
      _ => 'Find $count bedste pladser',
    };

String _reselectSeatsDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => 'Vælg den igen',
      _ => 'Vælg dem igen',
    };

String _seatsFreeDa(int count) => switch (pickerPluralCategory('da', count)) {
  PickerPluralCategory.one => '$count plads',
  _ => '$count pladser',
};

String _seatsLeftInSectionDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count plads tilbage',
      _ => '$count pladser tilbage',
    };

String _holdLapsedStillFreeDa(int count) => switch (pickerPluralCategory(
  'da',
  count,
)) {
  PickerPluralCategory.one =>
    'Din reservation udløb, mens du var væk. Den plads er stadig ledig.',
  _ => 'Din reservation udløb, mens du var væk. De pladser er stadig ledige.',
};

String _holdLapsedSomeTakenDa(int count) => switch (pickerPluralCategory(
  'da',
  count,
)) {
  PickerPluralCategory.one =>
    'Din reservation udløb, mens du var væk, og $count af de pladser er blevet taget. Resten er stadig ledige.',
  _ =>
    'Din reservation udløb, mens du var væk, og $count af de pladser er blevet taget. Resten er stadig ledige.',
};

String _holdLapsedAllTakenDa(int count) => switch (pickerPluralCategory(
  'da',
  count,
)) {
  PickerPluralCategory.one =>
    'Din reservation udløb, mens du var væk, og den plads er blevet taget.',
  _ => 'Din reservation udløb, mens du var væk, og de pladser er blevet taget.',
};

String _accessibleSectionsDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count sektion',
      _ => '$count sektioner',
    };

String _placesAvailableDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count plads ledig lige nu',
      _ => '$count pladser ledige lige nu',
    };

String _removeTicketsDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => 'Fjern $count billet',
      _ => 'Fjern $count billetter',
    };

String _holdMinutesLeftDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count minut tilbage',
      _ => '$count minutter tilbage',
    };

String _holdSecondsLeftDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count sekund tilbage',
      _ => '$count sekunder tilbage',
    };

String _holdLapsedBodyDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => 'De var reserveret i $count minut.',
      _ => 'De var reserveret i $count minutter.',
    };

String _seatsNotRecoveredDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count plads kunne ikke reserveres igen',
      _ => '$count pladser kunne ikke reserveres igen',
    };

String _activeFiltersDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count filter',
      _ => '$count filtre',
    };

String _accessibilityFiltersActiveDa(int count) =>
    switch (pickerPluralCategory('da', count)) {
      PickerPluralCategory.one => '$count tilgængelighedsfilter er aktivt',
      _ => '$count tilgængelighedsfiltre er aktive',
    };

String _onlyLeftDa(int count) => switch (pickerPluralCategory('da', count)) {
  PickerPluralCategory.one => '$count plads tilbage',
  _ => '$count pladser tilbage',
};

String _maintenancePausedDa(int count) => switch (pickerPluralCategory(
  'da',
  count,
)) {
  PickerPluralCategory.one =>
    'Booking er sat på pause på grund af vedligeholdelse. Prøv igen om cirka $count minut.',
  _ =>
    'Booking er sat på pause på grund af vedligeholdelse. Prøv igen om cirka $count minutter.',
};

String _continueWithTotalDa(String money) => 'Fortsæt \u00b7 $money';

/// The `da` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsDa = SeatLayerPickerStrings(
  close: 'Luk',
  overview: 'Spillested',
  backToVenue: 'Tilbage til stedet',
  cancel: 'Annuller',
  select: 'Vælg',
  removeSeat: 'Fjern plads',
  viewFromHere: 'Udsigt herfra',
  openVenue360: 'Åbn stedet i 360°',
  recentre: 'Centrér på scenen igen',
  viewFromYourSeat: 'udsigt fra din plads',
  emptyTrayHint:
      'Tryk på en plads på oversigten, eller lad os vælge de bedste ledige til dig.',
  anyTicketType: 'Enhver billettype',
  anyVenueZone: 'Enhver zone på stedet',
  bestSeats: 'Bedste pladser',
  showLess: 'Vis mindre',
  undo: 'Fortryd',
  holdAndCheckout: 'Reservér pladser og betal',
  poweredBy: 'Drevet af SeatLayer',
  testMode: 'Testtilstand',
  accessibility: 'Tilgængelighed og farver',
  accessibilityTitle: 'Tilgængelighed og farver',
  fitVenue: 'Vis hele stedet',
  fitWholeVenue: 'Vis hele stedet',
  loading: 'Indlæser pladsoversigten…',
  errorMessage: 'Pladsoversigten blev ikke indlæst',
  retry: 'Prøv igen',
  accessRefresh: 'Genindlæs',
  noSeatsSelected: 'Ingen pladser valgt',
  findBestSeatsCta: 'Find de bedste pladser',
  organizerNote: 'Note fra arrangøren',
  accessiblePhysicalSeat: 'Tilgængelig fysisk plads',
  emptyWheelchairSpace: 'Ledig kørestolsplads',
  findSeatsTogether: 'Find pladser ved siden af hinanden',
  aboutBestSeats: 'Om at finde pladser sammen',
  closestGroupChosenInstantly:
      'Den nærmeste ledige gruppe, valgt med det samme.',
  hideLimitedView: 'Skjul pladser med begrænset udsyn',
  colorblindSafe: 'Farveblindvenlige farver',
  notAvailable: 'Ikke tilgængelig',
  viewGroupTitle: 'VISNING',
  restrictedView: 'Begrænset udsyn',
  obstructedView: 'Blokeret udsyn',
  premiumSeat: 'Premiumplads',
  continueWord: 'Fortsæt',
  allFloors: 'Alle etager',
  previousSection: 'Forrige sektion',
  nextSection: 'Næste sektion',
  addSeat: 'Tilføj plads',
  added: 'Tilføjet',
  sectionWord: 'Sektion',
  rowWord: 'Række',
  seatWord: 'Plads',
  seeItIn3D: 'Se den i 3D',
  viewFromThisSeat: 'Udsigt fra denne plads',
  allPrices: 'Alle priser',
  ticketPrices: 'Billetpriser',
  yourSeats: 'Dine pladser',
  ticketType: 'Billettype',
  tierCompanionGuidance: 'Kræver den tilstødende kørestolsplads',
  findingBestSeats: 'Finder de bedste pladser…',
  findSeats: 'Find pladser',
  expandCart: 'Åbn billetpanelet',
  collapseCart: 'Fold billetpanelet sammen',
  continueToCheckout: 'Fortsæt til betaling',
  secureMore: 'Sikr flere',
  selectSeats: 'Vælg pladser',
  pickYourSeats: 'Vælg dine pladser',
  salesClosedPill: 'Salget er lukket',
  salesClosedCta: 'Salget er lukket',
  confirmOrCancelSeat: 'Bekræft eller annuller denne plads',
  securingSeats: 'Sikrer dine pladser…',
  openingCheckout: 'Åbner sikker betaling…',
  testModeExplained:
      'Bookinger her er ikke rigtige, og der trækkes ikke fra noget kort',
  displayOptions: 'Visningsindstillinger',
  companionSeatsNote: 'Ledsagerpladserne ved siden af kan stadig vælges',
  zoomIn: 'Zoom ind',
  zoomOut: 'Zoom ud',
  rotateVenue: 'Træk for at rotere stedet',
  moveVenue: 'Træk for at flytte stedet',
  mapView: 'Oversigt',
  flat2dMap: 'Flad 2D-oversigt',
  interactive3dVenueView: 'Interaktiv 3D-visning af stedet',
  venueView: 'Visning af stedet',
  holdLapsedTitle: 'Dine pladser blev frigivet',
  salesClosed: 'Salget er lukket',
  salesClosedCopy: 'Billetsalget til dette arrangement er slut.',
  salesClosedToast: 'Salget til dette arrangement er lukket.',
  soldOutEyebrow: 'Dette arrangement',
  soldOutTitle: 'Udsolgt',
  soldOutCopy:
      'Der er i øjeblikket ingen nummererede pladser ledige til dette arrangement.',
  holdExpired:
      'Din reservation er udløbet. Pladserne blev frigivet. Vælg igen.',
  addingEllipsis: 'Tilføjer…',
  moreTimeAdded: 'Mere tid tilføjet. Dine pladser er stadig reserveret.',
  couldNotAddMoreTime: 'Kunne ikke tilføje mere tid. Gå til betaling nu.',
  seatsJustTaken: 'En eller flere pladser blev lige taget. Vælg igen.',
  ticketTypeSoldOut: 'Den billettype er udsolgt. Prøv en anden billettype.',
  seatsNoLongerAvailableTryAnother:
      'De pladser er ikke længere ledige. Prøv et andet antal eller en anden billettype.',
  companionPairRequired:
      'Vælg den tilstødende kørestolsplads til hver ledsagerbillet.',
  ticketOptionNotApplicable:
      'Det billetvalg er ikke tilgængeligt for den valgte plads.',
  maintenancePausedShortly:
      'Booking er sat på pause i et par minutter på grund af vedligeholdelse. Prøv igen om lidt.',
  guestsOnly: 'Dette arrangement er for inviterede gæster.',
  guestChoiceClosed: 'Valg af pladser er ikke åbent lige nu.',
  allSetTitle: 'Så er alt klar',
  confirmedAndOnWay: 'bekræftet. En bekræftelse er på vej.',
  backToMap: 'Tilbage til oversigten',
  mapDidNotLoad: 'Pladsoversigten blev ikke indlæst',
  checkConnection: 'Tjek din forbindelse, og prøv igen.',
  accessPausedTitle: 'Disse pladser er spærret lige nu',
  accessPausedCopy:
      'Arrangøren har sat dette udvalg på pause. Prøv igen om et par minutter.',
  accessRevokedTitle: 'Dette adgangslink er ikke længere aktivt',
  accessRevokedCopy:
      'Bed den, der sendte dig hertil, om et nyt link, så du kan blive ved med at booke disse pladser.',
  accessUnverifiedTitle: 'Vi kunne ikke bekræfte din adgang',
  accessUnverifiedCopy:
      'Du kan stadig booke alt, der vises som ledigt. Kontakt den, der sendte dig hertil, for adgang til resten.',
  generalAdmission: 'Fri placering',
  numberOfGuests: 'Antal gæster',
  chooseGuestsCopy:
      'Vælg, hvor mange gæster der skal sidde sammen. Bordet reserveres udelukkende til jeres selskab.',
  fewerGuests: 'Færre gæster',
  moreGuests: 'Flere gæster',
  selectTable: 'Vælg bord',
  updateTable: 'Opdater bordet',
  removeWord: 'Fjern',
  floorWord: 'Etage',
  totalWord: 'I alt',
  adjustSelection: 'Justér pladsvalget',
  backToSeatMap: 'Tilbage til pladsoversigten',
  chooseSeats: 'Vælg dine pladser',
  chooseTickets: 'Vælg billetter',
  placeWord: 'PLADS',
  ticketWord: 'Billet',
  passport: 'Pladsprofil',
  venue3D: '3D',
  venueZone: 'Zone på stedet',
  venueMapHint:
      'Pladser vælges med knapperne omkring oversigten: prisbjælken over den, sektionsknapperne under den og billetpanelet nederst.',
  previousSeat: 'Forrige plads',
  nextSeat: 'Næste plads',
  orbitMode: 'Rotér stedet',
  panMode: 'Flyt stedet',
  openInteractive3dVenue: 'Åbn interaktiv 3D-visning af stedet',
  showSeatsFor: 'VIS PLADSER TIL',
  accessJumpFirstSection: 'Gå til den første sektion',
  accessJumpNextSection: 'Gå til den næste sektion',
  fewerTickets: 'Færre billetter',
  moreTickets: 'Flere billetter',
  addTickets: 'Tilføj billetter',
  noSelectableSeats: 'Der er ingen pladser at vælge lige nu.',
  confirmYourTickets: 'Bekræft dine billetter',
  seatsSecuredOpeningCheckout: 'Pladserne er sikret. Åbner betaling…',
  holdInCheckoutTitle: 'Dine pladser er allerede i betalingen',
  holdInCheckoutBody:
      'Gennemfør betalingen for at beholde dem. Vil du vælge andre pladser, skal du først frigive disse — de kommer til salg igen.',
  releaseAndChangeSeats: 'Frigiv og skift pladser',
  holdAlreadyHeldTitle: 'Dine pladser er allerede reserveret',
  holdAlreadyHeldBody: 'Fortsæt til betaling for at beholde dem.',
  accessExpiredTitle: 'Din session er udløbet',
  accessExpiredCopy:
      'Genindlæs pladsoversigten for at fortsætte. Pladser, der allerede er i din kurv, forbliver reserveret, til tiden løber ud.',
  dismissError: 'Luk fejlmeddelelse',
  testModeLong: 'Testtilstand · intet bookes',
  seatRemoved: 'Billet fjernet',
  reloadSeatMap: 'Genindlæs pladsoversigten',
  accessNeeds: <String, String>{
    'wheelchair': 'Kørestolsplads',
    'companion': 'Ledsagerplads',
    'semi-ambulatory': 'Nedsat gangfunktion',
    'designated-aisle': 'Gang / overflytning',
    'step-free': 'Trinfri',
    'hearing': 'Teleslynge',
    'cart': 'Live-tekstning',
    'sign-language': 'Tegnsprog',
    'low-vision': 'Svagsynet',
    'sensory-friendly': 'Sansevenlig',
    'plus-size': 'Ekstra bred',
    'lift-armrest': 'Opklappeligt armlæn',
  },
  seatsLeft: _seatsLeftDa,
  moreCount: _moreCountDa,
  addMinutes: _addMinutesDa,
  fromPrice: _fromPriceDa,
  sightline: _sightlineDa,
  secureMoreAndCheckout: _secureMoreAndCheckoutDa,
  accessFreeCount: _accessFreeCountDa,
  seatJustTakenByAnother: _seatJustTakenByAnotherDa,
  labelNoLongerAvailable: _labelNoLongerAvailableDa,
  labelsNoLongerAvailable: _labelsNoLongerAvailableDa,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherDa,
  couldNotRemoveLabel: _couldNotRemoveLabelDa,
  peekSecured: _peekSecuredDa,
  venueMap: _venueMapDa,
  accessibleStep: _accessibleStepDa,
  chooseMinMaxGuests: _chooseMinMaxGuestsDa,
  chooseMore: _chooseMoreDa,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeDa,
  accessNeedWithCount: _accessNeedWithCountDa,
  ticketCount: _ticketCountDa,
  findBestSeats: _findBestSeatsDa,
  reselectSeats: _reselectSeatsDa,
  seatsFree: _seatsFreeDa,
  seatsLeftInSection: _seatsLeftInSectionDa,
  holdLapsedStillFree: _holdLapsedStillFreeDa,
  holdLapsedSomeTaken: _holdLapsedSomeTakenDa,
  holdLapsedAllTaken: _holdLapsedAllTakenDa,
  accessibleSections: _accessibleSectionsDa,
  placesAvailable: _placesAvailableDa,
  removeTickets: _removeTicketsDa,
  holdMinutesLeft: _holdMinutesLeftDa,
  holdSecondsLeft: _holdSecondsLeftDa,
  holdLapsedBody: _holdLapsedBodyDa,
  seatsNotRecovered: _seatsNotRecoveredDa,
  activeFilters: _activeFiltersDa,
  accessibilityFiltersActive: _accessibilityFiltersActiveDa,
  onlyLeft: _onlyLeftDa,
  maintenancePaused: _maintenancePausedDa,
  continueWithTotal: _continueWithTotalDa,
);
