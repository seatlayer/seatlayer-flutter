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

String _addMinutesEs(int minutes) => '+$minutes min';

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
  removeSeat: 'Quitar asiento',
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
  fitVenue: 'Mostrar todo el recinto',
  fitWholeVenue: 'Mostrar todo el recinto',
  loading: 'Cargando el mapa de asientos…',
  errorMessage: 'El mapa de asientos no se pudo cargar',
  retry: 'Intentar de nuevo',
  accessRefresh: 'Recargar',
  noSeatsSelected: 'Ningún asiento seleccionado',
  findBestSeatsCta: 'Buscar los mejores asientos',
  organizerNote: 'Nota del organizador',
  accessiblePhysicalSeat: 'Asiento físico accesible',
  emptyWheelchairSpace: 'Espacio vacío para silla de ruedas',
  findSeatsTogether: 'Buscar asientos juntos',
  hideLimitedView: 'Ocultar asientos con visibilidad limitada',
  colorblindSafe: 'Colores para daltónicos',
  notAvailable: 'No disponible',
  restrictedView: 'Visibilidad restringida',
  obstructedView: 'Visibilidad obstruida',
  premiumSeat: 'Asiento premium',
  continueWord: 'Continuar',
  accessNeeds: <String, String>{
    'wheelchair': 'Espacio para silla de ruedas',
    'companion': 'Asiento de acompañante',
    'semi-ambulatory': 'Movilidad reducida',
    'designated-aisle': 'Pasillo / transferencia',
    'step-free': 'Sin escalones',
    'hearing': 'Escucha asistida',
    'cart': 'Subtítulos en directo',
    'sign-language': 'Lengua de signos',
    'low-vision': 'Baja visión',
    'sensory-friendly': 'Sensorialmente amable',
    'plus-size': 'Talla grande',
    'lift-armrest': 'Reposabrazos abatible',
  },
  seatsLeft: _seatsLeftEs,
  moreCount: _moreCountEs,
  addMinutes: _addMinutesEs,
  fromPrice: _fromPriceEs,
  sightline: _sightlineEs,
  ticketCount: _ticketCountEs,
  findBestSeats: _findBestSeatsEs,
  reselectSeats: _reselectSeatsEs,
  continueWithTotal: _continueWithTotalEs,
);
