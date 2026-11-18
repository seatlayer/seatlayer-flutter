// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ca)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

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

String _peekSecuredCa(int count, String total) =>
    '✓ $count assegurats · $total. Encara no et cobrarem';

String _ticketCountCa(int count) =>
    count == 1 ? '$count entrada' : '$count entrades';

String _findBestSeatsCa(int count) => count == 1
    ? 'Busca $count millor seient'
    : 'Busca els $count millors seients';

String _reselectSeatsCa(int count) =>
    count == 1 ? 'Tornar-la a seleccionar' : 'Tornar-les a seleccionar';

String _seatsFreeCa(int count) =>
    count == 1 ? '$count seient' : '$count seients';

String _seatsLeftInSectionCa(int count) =>
    count == 1 ? 'Queda $count seient' : 'Queden $count seients';

String _holdLapsedStillFreeCa(int count) => count == 1
    ? 'La teva reserva ha caducat mentre eres fora. Aquesta plaça encara és lliure.'
    : 'La teva reserva ha caducat mentre eres fora. Aquestes places encara són lliures.';

String _holdLapsedSomeTakenCa(int count) => count == 1
    ? 'La teva reserva ha caducat mentre eres fora i $count d’aquestes places ja està ocupada. La resta encara són lliures.'
    : 'La teva reserva ha caducat mentre eres fora i $count d’aquestes places ja estan ocupades. La resta encara són lliures.';

String _holdLapsedAllTakenCa(int count) => count == 1
    ? 'La teva reserva ha caducat mentre eres fora i aquesta plaça ja està ocupada.'
    : 'La teva reserva ha caducat mentre eres fora i aquestes places ja estan ocupades.';

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
  testMode: 'MODE DE PROVA',
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
  peekSecured: _peekSecuredCa,
  ticketCount: _ticketCountCa,
  findBestSeats: _findBestSeatsCa,
  reselectSeats: _reselectSeatsCa,
  seatsFree: _seatsFreeCa,
  seatsLeftInSection: _seatsLeftInSectionCa,
  holdLapsedStillFree: _holdLapsedStillFreeCa,
  holdLapsedSomeTaken: _holdLapsedSomeTakenCa,
  holdLapsedAllTaken: _holdLapsedAllTakenCa,
  continueWithTotal: _continueWithTotalCa,
);
