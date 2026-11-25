// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ca)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftCa(int count) => 'En queden $count';

String _moreCountCa(int count) => '+$count més';

String _addMinutesCa(int minutes) => '+$minutes min';

String _fromPriceCa(String money) => 'Des de $money';

String _sightlineCa(String metres) => '≈ $metres m fins a l\'escenari';

String _secureMoreAndCheckoutCa(int count) => 'Assegura\'n $count més i paga';

String _accessFreeCountCa(int count) => '$count lliures';

String _seatJustTakenByAnotherCa(String label) =>
    'Un altre comprador acaba d\'agafar el seient $label.';

String _labelNoLongerAvailableCa(String label) =>
    '$label ja no està disponible. Tria un altre seient.';

String _labelsNoLongerAvailableCa(String labels) =>
    '$labels ja no estan disponibles. Tria un altre grup.';

String _couldNotFindSeatsTogetherCa(int count) =>
    'No hem trobat $count seients junts. Prova amb menys seients o un altre tipus d\'entrada.';

String _maxTicketsForOrderCa(int count) =>
    'Pots seleccionar fins a $count entrades per a aquesta comanda.';

String _couldNotRemoveLabelCa(String label) =>
    'No hem pogut treure $label. La reserva no ha canviat.';

String _peekSecuredCa(int count, String total) =>
    '✓ $count assegurats · $total. Encara no et cobrarem';

String _venueMapCa(String venue) => 'Mapa de seients de $venue';

String _accessibleStepCa(int index, int total) => '$index de $total';

String _chooseMinMaxGuestsCa(int min, int max) =>
    'Tria entre $min i $max convidats.';

String _chooseMoreCa(int count) => 'Tria’n $count més';

String _seatsHeldForNeedMoreTimeCa(String time) =>
    'Els teus seients estan reservats durant $time. Necessites més temps?';

String _accessNeedWithCountCa(String need, int count) => '$need · $count';

String _ticketCountCa(int count) => switch (pickerPluralCategory('ca', count)) {
  PickerPluralCategory.one => '$count entrada',
  PickerPluralCategory.many => '$count entrades',
  _ => '$count entrades',
};

String _findBestSeatsCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => 'Busca $count millor seient',
      PickerPluralCategory.many => 'Busca els $count millors seients',
      _ => 'Busca els $count millors seients',
    };

String _reselectSeatsCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => 'Tornar-la a seleccionar',
      PickerPluralCategory.many => 'Tornar-les a seleccionar',
      _ => 'Tornar-les a seleccionar',
    };

String _seatsFreeCa(int count) => switch (pickerPluralCategory('ca', count)) {
  PickerPluralCategory.one => '$count seient',
  PickerPluralCategory.many => '$count seients',
  _ => '$count seients',
};

String _seatsLeftInSectionCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => 'Queda $count seient',
      PickerPluralCategory.many => 'Queden $count seients',
      _ => 'Queden $count seients',
    };

String _holdLapsedStillFreeCa(int count) => switch (pickerPluralCategory(
  'ca',
  count,
)) {
  PickerPluralCategory.one =>
    'La teva reserva ha caducat mentre eres fora. Aquesta plaça encara és lliure.',
  PickerPluralCategory.many =>
    'La teva reserva ha caducat mentre eres fora. Aquestes places encara són lliures.',
  _ =>
    'La teva reserva ha caducat mentre eres fora. Aquestes places encara són lliures.',
};

String _holdLapsedSomeTakenCa(int count) => switch (pickerPluralCategory(
  'ca',
  count,
)) {
  PickerPluralCategory.one =>
    'La teva reserva ha caducat mentre eres fora i $count d’aquestes places ja està ocupada. La resta encara són lliures.',
  PickerPluralCategory.many =>
    'La teva reserva ha caducat mentre eres fora i $count d’aquestes places ja estan ocupades. La resta encara són lliures.',
  _ =>
    'La teva reserva ha caducat mentre eres fora i $count d’aquestes places ja estan ocupades. La resta encara són lliures.',
};

String _holdLapsedAllTakenCa(int count) => switch (pickerPluralCategory(
  'ca',
  count,
)) {
  PickerPluralCategory.one =>
    'La teva reserva ha caducat mentre eres fora i aquesta plaça ja està ocupada.',
  PickerPluralCategory.many =>
    'La teva reserva ha caducat mentre eres fora i aquestes places ja estan ocupades.',
  _ =>
    'La teva reserva ha caducat mentre eres fora i aquestes places ja estan ocupades.',
};

String _accessibleSectionsCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => '$count sector',
      PickerPluralCategory.many => '$count de sectors',
      _ => '$count sectors',
    };

String _placesAvailableCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => '$count plaça disponible ara mateix',
      PickerPluralCategory.many => '$count de places disponibles ara mateix',
      _ => '$count places disponibles ara mateix',
    };

String _removeTicketsCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => 'Treu $count entrada',
      PickerPluralCategory.many => 'Treu $count d’entrades',
      _ => 'Treu $count entrades',
    };

String _holdMinutesLeftCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => 'Queda $count minut',
      PickerPluralCategory.many => 'Queden $count de minuts',
      _ => 'Queden $count minuts',
    };

String _holdSecondsLeftCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => 'Queda $count segon',
      PickerPluralCategory.many => 'Queden $count de segons',
      _ => 'Queden $count segons',
    };

String _holdLapsedBodyCa(int count) => switch (pickerPluralCategory(
  'ca',
  count,
)) {
  PickerPluralCategory.one => 'Van estar reservats durant $count minut.',
  PickerPluralCategory.many => 'Van estar reservats durant $count de minuts.',
  _ => 'Van estar reservats durant $count minuts.',
};

String _seatsNotRecoveredCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => '$count seient no s’ha pogut recuperar',
      PickerPluralCategory.many => '$count de seients no s’han pogut recuperar',
      _ => '$count seients no s’han pogut recuperar',
    };

String _activeFiltersCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => '$count filtre',
      PickerPluralCategory.many => '$count de filtres',
      _ => '$count filtres',
    };

String _accessibilityFiltersActiveCa(int count) =>
    switch (pickerPluralCategory('ca', count)) {
      PickerPluralCategory.one => '$count filtre d’accessibilitat actiu',
      PickerPluralCategory.many => '$count de filtres d’accessibilitat actius',
      _ => '$count filtres d’accessibilitat actius',
    };

String _onlyLeftCa(int count) => switch (pickerPluralCategory('ca', count)) {
  PickerPluralCategory.one => 'Queda $count seient',
  PickerPluralCategory.many => 'Queden $count seients',
  _ => 'Queden $count seients',
};

String _maintenancePausedCa(int count) => switch (pickerPluralCategory(
  'ca',
  count,
)) {
  PickerPluralCategory.one =>
    'La reserva està en pausa per manteniment. Torna-ho a provar d’aquí a $count minut aproximadament.',
  PickerPluralCategory.many =>
    'La reserva està en pausa per manteniment. Torna-ho a provar d’aquí a $count minuts aproximadament.',
  _ =>
    'La reserva està en pausa per manteniment. Torna-ho a provar d’aquí a $count minuts aproximadament.',
};

String _continueWithTotalCa(String money) => 'Continua \u00b7 $money';

/// The `ca` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsCa = SeatLayerPickerStrings(
  close: 'Tanca',
  overview: 'Recinte',
  backToVenue: 'Torna al recinte',
  cancel: 'Cancel·la',
  select: 'Selecciona',
  removeSeat: 'Elimina seient',
  viewFromHere: 'Vista des d\'aquí',
  openVenue360: 'Obre el recinte en 360°',
  recentre: 'Torna a centrar a l’escenari',
  viewFromYourSeat: 'vista des del teu seient',
  emptyTrayHint:
      'Toca un seient al mapa, o deixa que triem els millors disponibles per a tu.',
  anyTicketType: 'Qualsevol tipus d\'entrada',
  anyVenueZone: 'Qualsevol zona del recinte',
  bestSeats: 'Millors seients',
  showLess: 'Mostra menys',
  undo: 'Desfés',
  holdAndCheckout: 'Reserva els seients i paga',
  poweredBy: 'Amb la tecnologia de SeatLayer',
  testMode: 'Mode de prova',
  accessibility: 'Opcions d’accessibilitat i color',
  accessibilityTitle: 'Opcions d’accessibilitat i color',
  fitVenue: 'Mostra tot el recinte',
  fitWholeVenue: 'Mostra tot el recinte',
  loading: 'Carregant el mapa de seients…',
  errorMessage: 'El mapa de seients no s\'ha carregat',
  retry: 'Torna-ho a provar',
  accessRefresh: 'Actualitza',
  noSeatsSelected: 'Cap seient seleccionat',
  findBestSeatsCta: 'Busca els millors seients',
  organizerNote: 'Nota de l’organitzador',
  accessiblePhysicalSeat: 'Seient físic accessible',
  emptyWheelchairSpace: 'Espai lliure per a cadira de rodes',
  findSeatsTogether: 'Busca seients junts',
  aboutBestSeats: 'Sobre trobar seients junts',
  closestGroupChosenInstantly:
      'El grup disponible més proper, triat a l\'instant.',
  hideLimitedView: 'Amaga els seients amb visibilitat limitada',
  colorblindSafe: 'Colors adaptats al daltonisme',
  notAvailable: 'No disponible',
  viewGroupTitle: 'VISTA',
  restrictedView: 'Visibilitat limitada',
  obstructedView: 'Visibilitat obstruïda',
  premiumSeat: 'Seient prèmium',
  continueWord: 'Continua',
  allFloors: 'Totes les plantes',
  previousSection: 'Sector anterior',
  nextSection: 'Sector següent',
  addSeat: 'Afegeix seient',
  added: 'Afegit',
  sectionWord: 'Sector',
  rowWord: 'Fila',
  seatWord: 'Seient',
  seeItIn3D: 'Mira-ho en 3D',
  viewFromThisSeat: 'Vista des d\'aquest seient',
  allPrices: 'Tots els preus',
  ticketPrices: 'Preus de les entrades',
  yourSeats: 'Els teus seients',
  ticketType: 'Tipus d’entrada',
  tierCompanionGuidance: 'Requereix la plaça de cadira de rodes contigua',
  findingBestSeats: 'Buscant els millors seients…',
  findSeats: 'Busca seients',
  expandCart: 'Obre el tauler d\'entrades',
  collapseCart: 'Redueix el tauler d\'entrades',
  continueToCheckout: 'Continua cap al pagament',
  secureMore: 'Assegura\'n més',
  selectSeats: 'Selecciona seients',
  pickYourSeats: 'Tria els teus seients',
  salesClosedPill: 'Venda tancada',
  salesClosedCta: 'Venda tancada',
  confirmOrCancelSeat: 'Confirma o cancel·la aquest seient',
  securingSeats: 'Assegurant els teus seients…',
  openingCheckout: 'Obrint el pagament segur…',
  testModeExplained: 'Les reserves aquí no són reals i no es cobra cap targeta',
  displayOptions: 'Opcions de visualització',
  companionSeatsNote:
      'Les places d’acompanyant del costat continuen sent seleccionables',
  zoomIn: 'Amplia',
  zoomOut: 'Redueix',
  rotateVenue: 'Arrossega per girar el recinte',
  moveVenue: 'Arrossega per moure el recinte',
  mapView: 'Mapa',
  flat2dMap: 'Mapa 2D pla',
  interactive3dVenueView: 'Vista 3D interactiva del recinte',
  venueView: 'Vista del recinte',
  holdLapsedTitle: 'Els vostres seients s’han alliberat',
  salesClosed: 'Venda tancada',
  salesClosedCopy:
      'La venda d\'entrades per a aquest esdeveniment ha finalitzat.',
  salesClosedToast: 'La venda per a aquest esdeveniment està tancada.',
  soldOutEyebrow: 'Aquest esdeveniment',
  soldOutTitle: 'Esgotat',
  soldOutCopy:
      'Ara mateix no hi ha seients numerats disponibles per a aquest esdeveniment.',
  holdExpired:
      'La teva reserva ha caducat: els seients s\'han alliberat. Torna a triar.',
  addingEllipsis: 'Afegint…',
  moreTimeAdded:
      'S\'ha afegit més temps: els teus seients continuen reservats.',
  couldNotAddMoreTime: 'No s\'ha pogut afegir més temps: ves al pagament ara.',
  seatsJustTaken: 'Un o més seients s\'acaben d\'ocupar. Torna a triar.',
  ticketTypeSoldOut:
      'Aquest tipus d\'entrada està esgotat. Prova un altre tipus.',
  seatsNoLongerAvailableTryAnother:
      'Aquests seients ja no estan disponibles. Prova amb una altra quantitat o tipus d\'entrada.',
  companionPairRequired:
      'Selecciona la plaça de cadira de rodes contigua amb cada entrada d\'acompanyant.',
  ticketOptionNotApplicable:
      'Aquesta opció d’entrada no està disponible per al seient seleccionat.',
  maintenancePausedShortly:
      'La reserva està en pausa uns minuts per manteniment. Torna-ho a provar d’aquí a poc.',
  guestsOnly: 'Aquest esdeveniment és per a convidats.',
  guestChoiceClosed: 'Ara mateix no es poden triar seients.',
  maxOneTicketForOrder:
      'Pots seleccionar fins a 1 entrada per a aquesta comanda.',
  tooManyAttempts: 'Massa intents. Espera un moment i torna-ho a provar.',
  seatHeldForRenewal:
      'Un d\'aquests seients està reservat per a un abonat que encara el pot renovar. Tria un altre seient.',
  seatUnavailable: 'Aquest seient no està disponible.',
  eventUnavailable: 'Ara mateix no es poden reservar entrades aquí.',
  savedSeatsNotRestored:
      'No s’han pogut recuperar els seients que teníeu. Torneu-los a triar.',
  allSetTitle: 'Ja ho tens tot a punt',
  confirmedAndOnWay: 'confirmat. La confirmació ja està en camí.',
  backToMap: 'Torna al mapa',
  mapDidNotLoad: 'El mapa de seients no s\'ha carregat',
  checkConnection: 'Comprova la connexió i torna-ho a provar.',
  accessPausedTitle: 'Aquests seients estan bloquejats ara mateix',
  accessPausedCopy:
      'L\'organitzador ha pausat aquesta selecció. Torna-ho a provar d\'aquí a uns minuts.',
  accessRevokedTitle: 'Aquest enllaç d\'accés ja no és actiu',
  accessRevokedCopy:
      'Demana un enllaç nou a qui te\'l va enviar per continuar reservant aquests seients.',
  accessUnverifiedTitle: 'No hem pogut verificar el teu accés',
  accessUnverifiedCopy:
      'Encara pots comprar tot el que aparegui com a disponible. Contacta amb qui t\'ha enviat aquí per accedir a la resta.',
  generalAdmission: 'Entrada general',
  numberOfGuests: 'Nombre de convidats',
  chooseGuestsCopy:
      'Tria quants convidats seuran junts. Aquesta taula es reserva en exclusiva per al teu grup.',
  fewerGuests: 'Menys convidats',
  moreGuests: 'Més convidats',
  selectTable: 'Selecciona la taula',
  updateTable: 'Actualitza la taula',
  removeWord: 'Treu',
  floorWord: 'Planta',
  totalWord: 'Total',
  adjustSelection: 'Ajusta la selecció de seients',
  backToSeatMap: 'Torna al mapa de seients',
  chooseSeats: 'Tria els teus seients',
  chooseTickets: 'Tria entrades',
  placeWord: 'PLAÇA',
  ticketWord: 'Entrada',
  passport: 'Fitxa del seient',
  venue3D: '3D',
  venueZone: 'Zona del recinte',
  venueMapHint:
      'Els seients es trien amb els controls al voltant del mapa: la barra de preus a sobre, els controls de sector a sota i el tauler d’entrades al peu.',
  previousSeat: 'Seient anterior',
  nextSeat: 'Seient següent',
  orbitMode: 'Gira el recinte',
  panMode: 'Mou el recinte',
  openInteractive3dVenue: 'Obre el recinte 3D interactiu',
  showSeatsFor: 'MOSTRA SEIENTS PER A',
  accessJumpFirstSection: 'Ves al primer sector',
  accessJumpNextSection: 'Ves al sector següent',
  fewerTickets: 'Menys entrades',
  moreTickets: 'Més entrades',
  addTickets: 'Afegeix entrades',
  noSelectableSeats: 'Ara mateix no hi ha cap seient seleccionable disponible.',
  confirmYourTickets: 'Confirma les teves entrades',
  seatsSecuredOpeningCheckout: 'Seients assegurats. Obrint el pagament…',
  holdInCheckoutTitle: 'Els teus seients ja són al pagament',
  holdInCheckoutBody:
      'Acaba el pagament per conservar-los. Per triar altres seients, allibera primer aquests — tornen a la venda.',
  releaseAndChangeSeats: 'Allibera i canvia els seients',
  holdAlreadyHeldTitle: 'Els teus seients ja estan reservats',
  holdAlreadyHeldBody: 'Continua cap al pagament per conservar-los.',
  accessExpiredTitle: 'La teva sessió de seients ha caducat',
  accessExpiredCopy:
      'Torna a carregar el mapa de seients per continuar. Els seients que ja són a la teva cistella continuen reservats fins que s’acabi el temporitzador.',
  dismissError: 'Descarta l’error',
  testModeLong: 'Mode de prova · no reserva res',
  seatRemoved: 'S’ha tret l’entrada',
  reloadSeatMap: 'Torna a carregar el mapa de seients',
  accessNeeds: <String, String>{
    'wheelchair': 'Espai per a cadira de rodes',
    'companion': 'Seient d’acompanyant',
    'semi-ambulatory': 'Mobilitat reduïda',
    'designated-aisle': 'Passadís / transferència',
    'step-free': 'Sense escales',
    'hearing': 'Escolta assistida',
    'cart': 'Subtítols en directe',
    'sign-language': 'Llengua de signes',
    'low-vision': 'Baixa visió',
    'sensory-friendly': 'Sensorialment amable',
    'plus-size': 'Talla gran',
    'lift-armrest': 'Reposabraços abatible',
  },
  seatsLeft: _seatsLeftCa,
  moreCount: _moreCountCa,
  addMinutes: _addMinutesCa,
  fromPrice: _fromPriceCa,
  sightline: _sightlineCa,
  secureMoreAndCheckout: _secureMoreAndCheckoutCa,
  accessFreeCount: _accessFreeCountCa,
  seatJustTakenByAnother: _seatJustTakenByAnotherCa,
  labelNoLongerAvailable: _labelNoLongerAvailableCa,
  labelsNoLongerAvailable: _labelsNoLongerAvailableCa,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherCa,
  maxTicketsForOrder: _maxTicketsForOrderCa,
  couldNotRemoveLabel: _couldNotRemoveLabelCa,
  peekSecured: _peekSecuredCa,
  venueMap: _venueMapCa,
  accessibleStep: _accessibleStepCa,
  chooseMinMaxGuests: _chooseMinMaxGuestsCa,
  chooseMore: _chooseMoreCa,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeCa,
  accessNeedWithCount: _accessNeedWithCountCa,
  ticketCount: _ticketCountCa,
  findBestSeats: _findBestSeatsCa,
  reselectSeats: _reselectSeatsCa,
  seatsFree: _seatsFreeCa,
  seatsLeftInSection: _seatsLeftInSectionCa,
  holdLapsedStillFree: _holdLapsedStillFreeCa,
  holdLapsedSomeTaken: _holdLapsedSomeTakenCa,
  holdLapsedAllTaken: _holdLapsedAllTakenCa,
  accessibleSections: _accessibleSectionsCa,
  placesAvailable: _placesAvailableCa,
  removeTickets: _removeTicketsCa,
  holdMinutesLeft: _holdMinutesLeftCa,
  holdSecondsLeft: _holdSecondsLeftCa,
  holdLapsedBody: _holdLapsedBodyCa,
  seatsNotRecovered: _seatsNotRecoveredCa,
  activeFilters: _activeFiltersCa,
  accessibilityFiltersActive: _accessibilityFiltersActiveCa,
  onlyLeft: _onlyLeftCa,
  maintenancePaused: _maintenancePausedCa,
  continueWithTotal: _continueWithTotalCa,
);
