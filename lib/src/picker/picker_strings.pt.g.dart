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

String _ticketCountPt(int count) =>
    count == 1 ? '$count bilhete' : '$count bilhetes';

String _findBestSeatsPt(int count) => count == 1
    ? 'Encontrar $count melhor lugar'
    : 'Encontrar os $count melhores lugares';

String _reselectSeatsPt(int count) =>
    count == 1 ? 'Selecioná-lo novamente' : 'Selecioná-los novamente';

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
  fitVenue: 'Ajustar ao ecrã',
  loading: 'A carregar o mapa de lugares…',
  errorMessage: 'O mapa de lugares não carregou',
  retry: 'Tentar de novo',
  accessRefresh: 'Recarregar',
  hideLimitedView: 'Ocultar lugares com vista limitada',
  colorblindSafe: 'Cores adaptadas a daltonismo',
  continueWord: 'Continuar',
  seatsLeft: _seatsLeftPt,
  moreCount: _moreCountPt,
  addMinutes: _addMinutesPt,
  fromPrice: _fromPricePt,
  sightline: _sightlinePt,
  ticketCount: _ticketCountPt,
  findBestSeats: _findBestSeatsPt,
  reselectSeats: _reselectSeatsPt,
  continueWithTotal: _continueWithTotalPt,
);
