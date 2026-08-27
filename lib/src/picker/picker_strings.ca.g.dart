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

String _fromPriceCa(String money) => 'Des de $money';

String _ticketCountCa(int count) =>
    count == 1 ? '$count entrada' : '$count entrades';

String _findBestSeatsCa(int count) => count == 1
    ? 'Busca $count millor seient'
    : 'Busca els $count millors seients';

String _continueWithTotalCa(String money) => 'Continua \u00b7 $money';

/// The `ca` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsCa = SeatLayerPickerStrings(
  close: 'Tanca',
  overview: 'Recinte',
  backToVenue: 'Torna al recinte',
  cancel: 'Cancel·la',
  select: 'Selecciona',
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
  fitVenue: 'Ajusta a la pantalla',
  loading: 'Carregant el mapa de seients…',
  errorMessage: 'El mapa de seients no s\'ha carregat',
  retry: 'Torna-ho a provar',
  hideLimitedView: 'Amaga els seients amb visibilitat limitada',
  colorblindSafe: 'Colors adaptats al daltonisme',
  seatsLeft: _seatsLeftCa,
  moreCount: _moreCountCa,
  fromPrice: _fromPriceCa,
  ticketCount: _ticketCountCa,
  findBestSeats: _findBestSeatsCa,
  continueWithTotal: _continueWithTotalCa,
);
