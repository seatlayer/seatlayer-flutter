// GENERATED — do not edit.
//
// Source: design/locale_strings.json (pt)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftPt(int count) => 'Restam $count';

String _moreCountPt(int count) => '+$count mais';

String _addMinutesPt(int minutes) => '+$minutes min';

String _fromPricePt(String money) => 'Desde $money';

String _sightlinePt(String metres) => '≈ $metres m até ao palco';

String _secureMoreAndCheckoutPt(int count) => 'Garantir mais $count e pagar';

String _accessFreeCountPt(int count) => '$count livres';

String _seatJustTakenByAnotherPt(String label) =>
    'O lugar $label acabou de ser ocupado por outro comprador.';

String _peekSecuredPt(int count, String total) =>
    '✓ $count garantidos · $total. Ainda não vais ser cobrado';

String _ticketCountPt(int count) =>
    count == 1 ? '$count bilhete' : '$count bilhetes';

String _findBestSeatsPt(int count) => count == 1
    ? 'Encontrar $count melhor lugar'
    : 'Encontrar os $count melhores lugares';

String _reselectSeatsPt(int count) =>
    count == 1 ? 'Selecioná-lo novamente' : 'Selecioná-los novamente';

String _seatsFreePt(int count) =>
    count == 1 ? '$count lugar' : '$count lugares';

String _seatsLeftInSectionPt(int count) =>
    count == 1 ? 'Resta $count lugar' : 'Restam $count lugares';

String _holdLapsedStillFreePt(int count) => count == 1
    ? 'A sua reserva expirou enquanto esteve ausente. Esse lugar continua livre.'
    : 'A sua reserva expirou enquanto esteve ausente. Esses lugares continuam livres.';

String _holdLapsedSomeTakenPt(int count) => count == 1
    ? 'A sua reserva expirou enquanto esteve ausente e $count desses lugares já foi ocupado. Os restantes continuam livres.'
    : 'A sua reserva expirou enquanto esteve ausente e $count desses lugares já foram ocupados. Os restantes continuam livres.';

String _holdLapsedAllTakenPt(int count) => count == 1
    ? 'A sua reserva expirou enquanto esteve ausente e esse lugar já foi ocupado.'
    : 'A sua reserva expirou enquanto esteve ausente e esses lugares já foram ocupados.';

String _continueWithTotalPt(String money) => 'Continuar \u00b7 $money';

/// The `pt` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsPt = SeatLayerPickerStrings(
  close: 'Fechar',
  overview: 'Recinto',
  backToVenue: 'Voltar ao recinto',
  cancel: 'Cancelar',
  select: 'Selecionar',
  removeSeat: 'Remover lugar',
  viewFromHere: 'Vista daqui',
  openVenue360: 'Abrir o recinto em 360°',
  recentre: 'Voltar a centrar no palco',
  viewFromYourSeat: 'vista do seu lugar',
  emptyTrayHint:
      'Toca num lugar no mapa, ou deixa-nos escolher os melhores disponíveis para ti.',
  anyTicketType: 'Qualquer tipo de bilhete',
  anyVenueZone: 'Qualquer zona do recinto',
  bestSeats: 'Melhores lugares',
  showLess: 'Mostrar menos',
  undo: 'Anular',
  holdAndCheckout: 'Reservar lugares e pagar',
  poweredBy: 'Com tecnologia SeatLayer',
  testMode: 'MODO DE TESTE',
  accessibility: 'Opções de acessibilidade e cor',
  accessibilityTitle: 'Opções de acessibilidade e cor',
  fitVenue: 'Mostrar todo o recinto',
  fitWholeVenue: 'Mostrar todo o recinto',
  loading: 'A carregar o mapa de lugares…',
  errorMessage: 'O mapa de lugares não carregou',
  retry: 'Tentar de novo',
  accessRefresh: 'Recarregar',
  noSeatsSelected: 'Nenhum lugar selecionado',
  findBestSeatsCta: 'Encontrar os melhores lugares',
  organizerNote: 'Nota do organizador',
  accessiblePhysicalSeat: 'Lugar físico acessível',
  emptyWheelchairSpace: 'Espaço para cadeira de rodas vazio',
  findSeatsTogether: 'Procurar lugares juntos',
  aboutBestSeats: 'Sobre encontrar lugares juntos',
  closestGroupChosenInstantly:
      'O grupo disponível mais próximo, escolhido num instante.',
  hideLimitedView: 'Ocultar lugares com vista limitada',
  colorblindSafe: 'Cores adaptadas a daltonismo',
  notAvailable: 'Indisponível',
  restrictedView: 'Vista limitada',
  obstructedView: 'Vista obstruída',
  premiumSeat: 'Lugar premium',
  continueWord: 'Continuar',
  allFloors: 'Todos os pisos',
  previousSection: 'Setor anterior',
  nextSection: 'Setor seguinte',
  addSeat: 'Adicionar lugar',
  added: 'Adicionado',
  sectionWord: 'Setor',
  rowWord: 'Fila',
  seatWord: 'Lugar',
  seeItIn3D: 'Ver em 3D',
  viewFromThisSeat: 'Vista deste lugar',
  allPrices: 'Todos os preços',
  ticketType: 'Tipo de bilhete',
  tierCompanionGuidance: 'Requer o lugar adjacente para cadeira de rodas',
  findingBestSeats: 'A procurar os melhores lugares…',
  findSeats: 'Procurar lugares',
  expandCart: 'Abrir o painel de bilhetes',
  collapseCart: 'Recolher o painel de bilhetes',
  continueToCheckout: 'Continuar para o pagamento',
  secureMore: 'Garantir mais',
  selectSeats: 'Selecionar lugares',
  pickYourSeats: 'Escolhe os teus lugares',
  salesClosedPill: 'Vendas encerradas',
  salesClosedCta: 'Vendas encerradas',
  confirmOrCancelSeat: 'Confirmar ou cancelar este lugar',
  securingSeats: 'A garantir os teus lugares…',
  openingCheckout: 'A abrir o pagamento seguro…',
  testModeExplained: 'As reservas aqui não são reais e nenhum cartão é cobrado',
  displayOptions: 'Opções de visualização',
  companionSeatsNote:
      'Os lugares de acompanhante ao lado continuam selecionáveis',
  zoomIn: 'Ampliar',
  zoomOut: 'Reduzir',
  rotateVenue: 'Arraste para rodar o recinto',
  moveVenue: 'Arraste para mover o recinto',
  mapView: 'Mapa',
  flat2dMap: 'Mapa 2D plano',
  interactive3dVenueView: 'Vista 3D interativa do recinto',
  venueView: 'Vista do recinto',
  holdLapsedTitle: 'Os seus lugares foram libertados',
  salesClosed: 'Vendas encerradas',
  salesClosedCopy: 'A venda de bilhetes para este evento terminou.',
  salesClosedToast: 'As vendas para este evento estão encerradas.',
  soldOutEyebrow: 'Este evento',
  soldOutTitle: 'Esgotado',
  soldOutCopy:
      'Não há lugares marcados disponíveis para este evento neste momento.',
  holdExpired:
      'A tua reserva expirou. Os lugares foram libertados. Escolhe de novo.',
  addingEllipsis: 'A adicionar…',
  moreTimeAdded: 'Mais tempo adicionado. Os teus lugares continuam reservados.',
  couldNotAddMoreTime:
      'Não foi possível adicionar mais tempo. Segue já para o pagamento.',
  seatsJustTaken:
      'Um ou mais lugares acabaram de ser ocupados. Escolhe de novo.',
  allSetTitle: 'Está tudo pronto',
  confirmedAndOnWay: 'confirmado. A confirmação vai a caminho.',
  backToMap: 'Voltar ao mapa',
  mapDidNotLoad: 'O mapa de lugares não carregou',
  checkConnection: 'Verifica a tua ligação e tenta de novo.',
  accessPausedTitle: 'Estes lugares estão retidos neste momento',
  accessPausedCopy:
      'O organizador pausou esta seleção. Tenta de novo dentro de alguns minutos.',
  accessRevokedTitle: 'Esta ligação de acesso já não está ativa',
  accessRevokedCopy:
      'Pede a quem te enviou para aqui uma nova ligação para continuares a reservar estes lugares.',
  accessUnverifiedTitle: 'Não conseguimos verificar o teu acesso',
  accessUnverifiedCopy:
      'Podes na mesma reservar tudo o que aparece como disponível. Contacta quem te enviou para aqui para teres acesso ao resto.',
  generalAdmission: 'Entrada geral',
  numberOfGuests: 'Número de convidados',
  chooseGuestsCopy:
      'Escolhe quantos convidados se sentam juntos. Esta mesa fica reservada em exclusivo para o teu grupo.',
  fewerGuests: 'Menos convidados',
  moreGuests: 'Mais convidados',
  selectTable: 'Selecionar mesa',
  updateTable: 'Atualizar mesa',
  removeWord: 'Remover',
  accessNeeds: <String, String>{
    'wheelchair': 'Espaço para cadeira de rodas',
    'companion': 'Lugar de acompanhante',
    'semi-ambulatory': 'Mobilidade reduzida',
    'designated-aisle': 'Corredor / transferência',
    'step-free': 'Sem degraus',
    'hearing': 'Apoio à audição',
    'cart': 'Legendagem em direto',
    'sign-language': 'Língua gestual',
    'low-vision': 'Baixa visão',
    'sensory-friendly': 'Sensorialmente adaptado',
    'plus-size': 'Tamanho grande',
    'lift-armrest': 'Apoio de braço rebatível',
  },
  seatsLeft: _seatsLeftPt,
  moreCount: _moreCountPt,
  addMinutes: _addMinutesPt,
  fromPrice: _fromPricePt,
  sightline: _sightlinePt,
  secureMoreAndCheckout: _secureMoreAndCheckoutPt,
  accessFreeCount: _accessFreeCountPt,
  seatJustTakenByAnother: _seatJustTakenByAnotherPt,
  peekSecured: _peekSecuredPt,
  ticketCount: _ticketCountPt,
  findBestSeats: _findBestSeatsPt,
  reselectSeats: _reselectSeatsPt,
  seatsFree: _seatsFreePt,
  seatsLeftInSection: _seatsLeftInSectionPt,
  holdLapsedStillFree: _holdLapsedStillFreePt,
  holdLapsedSomeTaken: _holdLapsedSomeTakenPt,
  holdLapsedAllTaken: _holdLapsedAllTakenPt,
  continueWithTotal: _continueWithTotalPt,
);
