// GENERATED — do not edit.
//
// Source: design/locale_strings.json (da)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftDa(int count) => '$count tilbage';

String _moreCountDa(int count) => '+$count flere';

String _fromPriceDa(String money) => 'Fra $money';

String _sightlineDa(String metres) => '≈ $metres m til scenen';

String _ticketCountDa(int count) =>
    count == 1 ? '$count billet' : '$count billetter';

String _findBestSeatsDa(int count) =>
    count == 1 ? 'Find $count bedste plads' : 'Find $count bedste pladser';

String _reselectSeatsDa(int count) =>
    count == 1 ? 'Vælg den igen' : 'Vælg dem igen';

String _continueWithTotalDa(String money) => 'Fortsæt \u00b7 $money';

/// The `da` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsDa = SeatLayerPickerStrings(
  close: 'Luk',
  overview: 'Spillested',
  backToVenue: 'Tilbage til stedet',
  cancel: 'Annuller',
  select: 'Vælg',
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
  testMode: 'TESTTILSTAND',
  accessibility: 'Tilgængelighed og farver',
  accessibilityTitle: 'Tilgængelighed og farver',
  fitVenue: 'Tilpas til skærmen',
  loading: 'Indlæser pladsoversigten…',
  errorMessage: 'Pladsoversigten blev ikke indlæst',
  retry: 'Prøv igen',
  hideLimitedView: 'Skjul pladser med begrænset udsyn',
  colorblindSafe: 'Farveblindvenlige farver',
  seatsLeft: _seatsLeftDa,
  moreCount: _moreCountDa,
  fromPrice: _fromPriceDa,
  sightline: _sightlineDa,
  ticketCount: _ticketCountDa,
  findBestSeats: _findBestSeatsDa,
  reselectSeats: _reselectSeatsDa,
  continueWithTotal: _continueWithTotalDa,
);
