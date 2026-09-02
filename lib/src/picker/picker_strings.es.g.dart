// GENERATED — do not edit.
//
// Source: design/locale_strings.json (es)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftEs(int count) => '$count libres';

String _moreCountEs(int count) => '+$count más';

String _fromPriceEs(String money) => 'Desde $money';

String _sightlineEs(String metres) => '≈ $metres m al escenario';

String _ticketCountEs(int count) =>
    count == 1 ? '$count entrada' : '$count entradas';

String _findBestSeatsEs(int count) => count == 1
    ? 'Buscar $count mejor asiento'
    : 'Buscar $count mejores asientos';

String _reselectSeatsEs(int count) =>
    count == 1 ? 'Seleccionarla de nuevo' : 'Seleccionarlas de nuevo';

String _continueWithTotalEs(String money) => 'Continuar \u00b7 $money';

/// The `es` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsEs = SeatLayerPickerStrings(
  close: 'Cerrar',
  overview: 'Recinto',
  backToVenue: 'Volver al recinto',
  cancel: 'Cancelar',
  select: 'Seleccionar',
  viewFromHere: 'Vista desde aquí',
  openVenue360: 'Abrir vista 360° del recinto',
  recentre: 'Volver a centrar en el escenario',
  viewFromYourSeat: 'vista desde tu asiento',
  emptyTrayHint:
      'Toca un asiento en el mapa, o deja que elijamos los mejores disponibles por ti.',
  anyTicketType: 'Cualquier tipo de entrada',
  anyVenueZone: 'Cualquier zona del recinto',
  bestSeats: 'Mejores asientos',
  showLess: 'Mostrar menos',
  undo: 'Deshacer',
  holdAndCheckout: 'Retener asientos y pagar',
  poweredBy: 'Con la tecnología de SeatLayer',
  testMode: 'MODO DE PRUEBA',
  accessibility: 'Opciones de accesibilidad y color',
  accessibilityTitle: 'Opciones de accesibilidad y color',
  fitVenue: 'Ajustar a la pantalla',
  loading: 'Cargando el mapa de asientos…',
  errorMessage: 'El mapa de asientos no se pudo cargar',
  retry: 'Intentar de nuevo',
  hideLimitedView: 'Ocultar asientos con visibilidad limitada',
  colorblindSafe: 'Colores para daltónicos',
  seatsLeft: _seatsLeftEs,
  moreCount: _moreCountEs,
  fromPrice: _fromPriceEs,
  sightline: _sightlineEs,
  ticketCount: _ticketCountEs,
  findBestSeats: _findBestSeatsEs,
  reselectSeats: _reselectSeatsEs,
  continueWithTotal: _continueWithTotalEs,
);
