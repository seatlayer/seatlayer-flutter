// GENERATED — do not edit.
//
// Source: design/locale_strings.json (pt)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _venueMapPt(String venue) => 'Mapa de lugares de $venue';

String _accessibleStepPt(int index, int total) => '$index de $total';

String _chooseMinMaxGuestsPt(int min, int max) =>
    'Escolhe entre $min e $max convidados.';

String _chooseMorePt(int count) => 'Escolhe mais $count';

String _seatsHeldForNeedMoreTimePt(String time) =>
    'Os teus lugares estão reservados durante $time. Precisas de mais tempo?';

String _ticketCountPt(int count) => switch (pickerPluralCategory('pt', count)) {
  PickerPluralCategory.one => '$count bilhete',
  PickerPluralCategory.many => '$count bilhetes',
  _ => '$count bilhetes',
};

String _findBestSeatsPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Encontrar $count melhor lugar',
      PickerPluralCategory.many => 'Encontrar os $count melhores lugares',
      _ => 'Encontrar os $count melhores lugares',
    };

String _reselectSeatsPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Selecioná-lo novamente',
      PickerPluralCategory.many => 'Selecioná-los novamente',
      _ => 'Selecioná-los novamente',
    };

String _seatsFreePt(int count) => switch (pickerPluralCategory('pt', count)) {
  PickerPluralCategory.one => '$count lugar',
  PickerPluralCategory.many => '$count lugares',
  _ => '$count lugares',
};

String _seatsLeftInSectionPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Resta $count lugar',
      PickerPluralCategory.many => 'Restam $count lugares',
      _ => 'Restam $count lugares',
    };

String _holdLapsedStillFreePt(int count) => switch (pickerPluralCategory(
  'pt',
  count,
)) {
  PickerPluralCategory.one =>
    'A sua reserva expirou enquanto esteve ausente. Esse lugar continua livre.',
  PickerPluralCategory.many =>
    'A sua reserva expirou enquanto esteve ausente. Esses lugares continuam livres.',
  _ =>
    'A sua reserva expirou enquanto esteve ausente. Esses lugares continuam livres.',
};

String _holdLapsedSomeTakenPt(int count) => switch (pickerPluralCategory(
  'pt',
  count,
)) {
  PickerPluralCategory.one =>
    'A sua reserva expirou enquanto esteve ausente e $count desses lugares já foi ocupado. Os restantes continuam livres.',
  PickerPluralCategory.many =>
    'A sua reserva expirou enquanto esteve ausente e $count desses lugares já foram ocupados. Os restantes continuam livres.',
  _ =>
    'A sua reserva expirou enquanto esteve ausente e $count desses lugares já foram ocupados. Os restantes continuam livres.',
};

String _holdLapsedAllTakenPt(int count) => switch (pickerPluralCategory(
  'pt',
  count,
)) {
  PickerPluralCategory.one =>
    'A sua reserva expirou enquanto esteve ausente e esse lugar já foi ocupado.',
  PickerPluralCategory.many =>
    'A sua reserva expirou enquanto esteve ausente e esses lugares já foram ocupados.',
  _ =>
    'A sua reserva expirou enquanto esteve ausente e esses lugares já foram ocupados.',
};

String _accessibleSectionsPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => '$count setor',
      PickerPluralCategory.many => '$count de setores',
      _ => '$count setores',
    };

String _placesAvailablePt(int count) => switch (pickerPluralCategory(
  'pt',
  count,
)) {
  PickerPluralCategory.one => '$count lugar disponível neste momento',
  PickerPluralCategory.many => '$count de lugares disponíveis neste momento',
  _ => '$count lugares disponíveis neste momento',
};

String _removeTicketsPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Remover $count bilhete',
      PickerPluralCategory.many => 'Remover $count de bilhetes',
      _ => 'Remover $count bilhetes',
    };

String _holdMinutesLeftPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Falta $count minuto',
      PickerPluralCategory.many => 'Faltam $count de minutos',
      _ => 'Faltam $count minutos',
    };

String _holdSecondsLeftPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Falta $count segundo',
      PickerPluralCategory.many => 'Faltam $count de segundos',
      _ => 'Faltam $count segundos',
    };

String _holdLapsedBodyPt(int count) =>
    switch (pickerPluralCategory('pt', count)) {
      PickerPluralCategory.one => 'Estiveram reservados durante $count minuto.',
      PickerPluralCategory.many =>
        'Estiveram reservados durante $count de minutos.',
      _ => 'Estiveram reservados durante $count minutos.',
    };

String _seatsNotRecoveredPt(int count) => switch (pickerPluralCategory(
  'pt',
  count,
)) {
  PickerPluralCategory.one => '$count lugar não pôde ser recuperado',
  PickerPluralCategory.many => '$count de lugares não puderam ser recuperados',
  _ => '$count lugares não puderam ser recuperados',
};

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
  testMode: 'Modo de teste',
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
  viewGroupTitle: 'VISTA',
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
  floorWord: 'Piso',
  totalWord: 'Total',
  chooseSeats: 'Escolhe os teus lugares',
  chooseTickets: 'Escolhe bilhetes',
  placeWord: 'LUGAR',
  ticketWord: 'Bilhete',
  passport: 'Ficha do lugar',
  venue3D: '3D',
  venueZone: 'Zona do recinto',
  venueMapHint:
      'Os lugares escolhem-se com os controlos à volta do mapa: a barra de preços por cima, os controlos de setor por baixo e o painel de bilhetes no fundo.',
  previousSeat: 'Lugar anterior',
  nextSeat: 'Lugar seguinte',
  orbitMode: 'Rodar recinto',
  panMode: 'Mover recinto',
  openInteractive3dVenue: 'Abrir o recinto 3D interativo',
  showSeatsFor: 'MOSTRAR LUGARES PARA',
  accessJumpFirstSection: 'Ir para o primeiro setor',
  accessJumpNextSection: 'Ir para o setor seguinte',
  fewerTickets: 'Menos bilhetes',
  moreTickets: 'Mais bilhetes',
  addTickets: 'Adicionar bilhetes',
  noSelectableSeats: 'De momento, não há lugares selecionáveis disponíveis.',
  confirmYourTickets: 'Confirma os teus bilhetes',
  seatsSecuredOpeningCheckout: 'Lugares garantidos. A abrir o pagamento…',
  holdInCheckoutTitle: 'Os teus lugares já estão no pagamento',
  holdInCheckoutBody:
      'Conclui o pagamento para os manter. Para escolher outros lugares, liberta primeiro estes — voltam à venda.',
  releaseAndChangeSeats: 'Libertar e mudar de lugares',
  holdAlreadyHeldTitle: 'Os teus lugares já estão reservados',
  holdAlreadyHeldBody: 'Continua para o pagamento para os manter.',
  accessExpiredTitle: 'A tua sessão de lugares expirou',
  accessExpiredCopy:
      'Recarrega o mapa de lugares para continuar. Os lugares que já estão no teu carrinho continuam reservados até o temporizador terminar.',
  dismissError: 'Fechar o erro',
  testModeLong: 'Modo de teste · não reserva nada',
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
  venueMap: _venueMapPt,
  accessibleStep: _accessibleStepPt,
  chooseMinMaxGuests: _chooseMinMaxGuestsPt,
  chooseMore: _chooseMorePt,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimePt,
  ticketCount: _ticketCountPt,
  findBestSeats: _findBestSeatsPt,
  reselectSeats: _reselectSeatsPt,
  seatsFree: _seatsFreePt,
  seatsLeftInSection: _seatsLeftInSectionPt,
  holdLapsedStillFree: _holdLapsedStillFreePt,
  holdLapsedSomeTaken: _holdLapsedSomeTakenPt,
  holdLapsedAllTaken: _holdLapsedAllTakenPt,
  accessibleSections: _accessibleSectionsPt,
  placesAvailable: _placesAvailablePt,
  removeTickets: _removeTicketsPt,
  holdMinutesLeft: _holdMinutesLeftPt,
  holdSecondsLeft: _holdSecondsLeftPt,
  holdLapsedBody: _holdLapsedBodyPt,
  seatsNotRecovered: _seatsNotRecoveredPt,
  continueWithTotal: _continueWithTotalPt,
);
