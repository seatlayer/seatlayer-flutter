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

String _addMinutesDa(int minutes) => '+$minutes min';

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
  removeSeat: 'Fjern plads',
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
  fitVenue: 'Vis hele stedet',
  fitWholeVenue: 'Vis hele stedet',
  loading: 'Indlæser pladsoversigten…',
  errorMessage: 'Pladsoversigten blev ikke indlæst',
  retry: 'Prøv igen',
  accessRefresh: 'Genindlæs',
  noSeatsSelected: 'Ingen pladser valgt',
  findBestSeatsCta: 'Find de bedste pladser',
  organizerNote: 'Note fra arrangøren',
  accessiblePhysicalSeat: 'Tilgængelig fysisk plads',
  emptyWheelchairSpace: 'Ledig kørestolsplads',
  findSeatsTogether: 'Find pladser ved siden af hinanden',
  aboutBestSeats: 'Om at finde pladser sammen',
  closestGroupChosenInstantly:
      'Den nærmeste ledige gruppe, valgt med det samme.',
  hideLimitedView: 'Skjul pladser med begrænset udsyn',
  colorblindSafe: 'Farveblindvenlige farver',
  notAvailable: 'Ikke tilgængelig',
  restrictedView: 'Begrænset udsyn',
  obstructedView: 'Blokeret udsyn',
  premiumSeat: 'Premiumplads',
  continueWord: 'Fortsæt',
  accessNeeds: <String, String>{
    'wheelchair': 'Kørestolsplads',
    'companion': 'Ledsagerplads',
    'semi-ambulatory': 'Nedsat gangfunktion',
    'designated-aisle': 'Gang / overflytning',
    'step-free': 'Trinfri',
    'hearing': 'Teleslynge',
    'cart': 'Live-tekstning',
    'sign-language': 'Tegnsprog',
    'low-vision': 'Svagsynet',
    'sensory-friendly': 'Sansevenlig',
    'plus-size': 'Ekstra bred',
    'lift-armrest': 'Opklappeligt armlæn',
  },
  seatsLeft: _seatsLeftDa,
  moreCount: _moreCountDa,
  addMinutes: _addMinutesDa,
  fromPrice: _fromPriceDa,
  sightline: _sightlineDa,
  ticketCount: _ticketCountDa,
  findBestSeats: _findBestSeatsDa,
  reselectSeats: _reselectSeatsDa,
  continueWithTotal: _continueWithTotalDa,
);
