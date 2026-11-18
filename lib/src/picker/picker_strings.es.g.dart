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

String _secureMoreAndCheckoutEs(int count) => 'Asegurar $count más y pagar';

String _accessFreeCountEs(int count) => '$count libres';

String _seatJustTakenByAnotherEs(String label) =>
    'El asiento $label acaba de ser tomado por otro comprador.';

String _peekSecuredEs(int count, String total) =>
    '✓ $count asegurados · $total. Aún no se te cobrará nada';

String _ticketCountEs(int count) =>
    count == 1 ? '$count entrada' : '$count entradas';

String _findBestSeatsEs(int count) => count == 1
    ? 'Buscar $count mejor asiento'
    : 'Buscar $count mejores asientos';

String _reselectSeatsEs(int count) =>
    count == 1 ? 'Seleccionarla de nuevo' : 'Seleccionarlas de nuevo';

String _seatsFreeEs(int count) =>
    count == 1 ? '$count asiento' : '$count asientos';

String _seatsLeftInSectionEs(int count) =>
    count == 1 ? '$count asiento disponible' : '$count asientos disponibles';

String _holdLapsedStillFreeEs(int count) => count == 1
    ? 'Tu reserva caducó mientras no estabas. Esa plaza sigue libre.'
    : 'Tu reserva caducó mientras no estabas. Esas plazas siguen libres.';

String _holdLapsedSomeTakenEs(int count) => count == 1
    ? 'Tu reserva caducó mientras no estabas y $count de esas plazas ya está ocupada. El resto siguen libres.'
    : 'Tu reserva caducó mientras no estabas y $count de esas plazas ya están ocupadas. El resto siguen libres.';

String _holdLapsedAllTakenEs(int count) => count == 1
    ? 'Tu reserva caducó mientras no estabas y esa plaza ya está ocupada.'
    : 'Tu reserva caducó mientras no estabas y esas plazas ya están ocupadas.';

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
  aboutBestSeats: 'Sobre encontrar asientos juntos',
  closestGroupChosenInstantly:
      'El grupo disponible más cercano, elegido al instante.',
  hideLimitedView: 'Ocultar asientos con visibilidad limitada',
  colorblindSafe: 'Colores para daltónicos',
  notAvailable: 'No disponible',
  restrictedView: 'Visibilidad restringida',
  obstructedView: 'Visibilidad obstruida',
  premiumSeat: 'Asiento premium',
  continueWord: 'Continuar',
  allFloors: 'Todos los pisos',
  previousSection: 'Sección anterior',
  nextSection: 'Sección siguiente',
  addSeat: 'Añadir asiento',
  added: 'Añadido',
  sectionWord: 'Sección',
  rowWord: 'Fila',
  seatWord: 'Asiento',
  seeItIn3D: 'Verlo en 3D',
  viewFromThisSeat: 'Vista desde este asiento',
  allPrices: 'Todos los precios',
  ticketType: 'Tipo de entrada',
  tierCompanionGuidance: 'Requiere la plaza accesible contigua',
  findingBestSeats: 'Buscando los mejores asientos…',
  findSeats: 'Buscar asientos',
  expandCart: 'Abrir el panel de entradas',
  collapseCart: 'Contraer el panel de entradas',
  continueToCheckout: 'Continuar al pago',
  secureMore: 'Asegurar más',
  selectSeats: 'Seleccionar asientos',
  pickYourSeats: 'Elige tus asientos',
  salesClosedPill: 'Las ventas están cerradas',
  salesClosedCta: 'Venta cerrada',
  confirmOrCancelSeat: 'Confirma o cancela este asiento',
  securingSeats: 'Asegurando tus asientos…',
  openingCheckout: 'Abriendo el pago seguro…',
  testModeExplained:
      'Las reservas aquí no son reales y no se cobra ninguna tarjeta',
  displayOptions: 'Opciones de visualización',
  companionSeatsNote:
      'Las plazas de acompañante contiguas siguen siendo seleccionables',
  zoomIn: 'Acercar',
  zoomOut: 'Alejar',
  rotateVenue: 'Arrastra para girar el recinto',
  moveVenue: 'Arrastra para mover el recinto',
  mapView: 'Mapa',
  flat2dMap: 'Mapa plano 2D',
  interactive3dVenueView: 'Vista 3D interactiva del recinto',
  venueView: 'Vista del recinto',
  holdLapsedTitle: 'Tus asientos se han liberado',
  salesClosed: 'Las ventas están cerradas',
  salesClosedCopy: 'La venta de entradas para este evento ha finalizado.',
  salesClosedToast: 'Las ventas de este evento están cerradas.',
  soldOutEyebrow: 'Este evento',
  soldOutTitle: 'Agotado',
  soldOutCopy:
      'No hay asientos reservados disponibles actualmente para este evento.',
  holdExpired:
      'Tu retención expiró. Los asientos fueron liberados. Elige de nuevo.',
  addingEllipsis: 'Añadiendo…',
  moreTimeAdded: 'Se añadió más tiempo. Tus asientos siguen retenidos.',
  couldNotAddMoreTime: 'No se pudo añadir más tiempo. Dirígete al pago ahora.',
  seatsJustTaken: 'Se acaban de ocupar uno o más asientos. Vuelve a elegir.',
  allSetTitle: 'Todo listo',
  confirmedAndOnWay: 'confirmados. Una confirmación está en camino.',
  backToMap: 'Volver al mapa',
  mapDidNotLoad: 'El mapa de asientos no se pudo cargar',
  checkConnection: 'Comprueba tu conexión e inténtalo de nuevo.',
  accessPausedTitle: 'Estos asientos están retenidos en este momento',
  accessPausedCopy:
      'El organizador ha pausado esta selección. Inténtalo de nuevo en unos minutos.',
  accessRevokedTitle: 'Este enlace de acceso ya no está activo',
  accessRevokedCopy:
      'Pide a quien te envió aquí un nuevo enlace para seguir reservando estos asientos.',
  accessUnverifiedTitle: 'No pudimos verificar tu acceso',
  accessUnverifiedCopy:
      'Aún puedes reservar todo lo que aparezca como disponible. Contacta a quien te envió este enlace para acceder al resto.',
  generalAdmission: 'Entrada general',
  numberOfGuests: 'Número de invitados',
  chooseGuestsCopy:
      'Elige cuántos invitados se sentarán juntos. Esta mesa está reservada en exclusiva para tu grupo.',
  fewerGuests: 'Menos invitados',
  moreGuests: 'Más invitados',
  selectTable: 'Seleccionar mesa',
  updateTable: 'Actualizar mesa',
  removeWord: 'Quitar',
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
  secureMoreAndCheckout: _secureMoreAndCheckoutEs,
  accessFreeCount: _accessFreeCountEs,
  seatJustTakenByAnother: _seatJustTakenByAnotherEs,
  peekSecured: _peekSecuredEs,
  ticketCount: _ticketCountEs,
  findBestSeats: _findBestSeatsEs,
  reselectSeats: _reselectSeatsEs,
  seatsFree: _seatsFreeEs,
  seatsLeftInSection: _seatsLeftInSectionEs,
  holdLapsedStillFree: _holdLapsedStillFreeEs,
  holdLapsedSomeTaken: _holdLapsedSomeTakenEs,
  holdLapsedAllTaken: _holdLapsedAllTakenEs,
  continueWithTotal: _continueWithTotalEs,
);
