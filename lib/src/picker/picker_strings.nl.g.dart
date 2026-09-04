// GENERATED — do not edit.
//
// Source: design/locale_strings.json (nl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftNl(int count) => 'Nog $count';

String _moreCountNl(int count) => '+$count meer';

String _addMinutesNl(int minutes) => '+$minutes min';

String _fromPriceNl(String money) => 'Vanaf $money';

String _sightlineNl(String metres) => '≈ $metres m tot het podium';

String _ticketCountNl(int count) =>
    count == 1 ? '$count ticket' : '$count tickets';

String _findBestSeatsNl(int count) =>
    count == 1 ? 'Zoek $count beste plaats' : 'Zoek $count beste plaatsen';

String _reselectSeatsNl(int count) =>
    count == 1 ? 'Opnieuw selecteren' : 'Opnieuw selecteren';

String _continueWithTotalNl(String money) => 'Doorgaan \u00b7 $money';

/// The `nl` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsNl = SeatLayerPickerStrings(
  close: 'Sluiten',
  overview: 'Locatie',
  backToVenue: 'Terug naar de zaal',
  cancel: 'Annuleren',
  select: 'Selecteren',
  viewFromHere: 'Uitzicht vanaf hier',
  openVenue360: 'Zaal in 360° openen',
  recentre: 'Opnieuw op het podium centreren',
  viewFromYourSeat: 'zicht vanaf jouw plaats',
  emptyTrayHint:
      'Tik op een plaats op de plattegrond, of laat ons de beste beschikbare voor je kiezen.',
  anyTicketType: 'Elk tickettype',
  anyVenueZone: 'Elke zone in de zaal',
  bestSeats: 'Beste plaatsen',
  showLess: 'Minder tonen',
  undo: 'Ongedaan maken',
  holdAndCheckout: 'Plaatsen vastleggen & afrekenen',
  poweredBy: 'Mogelijk gemaakt door SeatLayer',
  testMode: 'TESTMODUS',
  accessibility: 'Toegankelijkheid en kleuren',
  accessibilityTitle: 'Toegankelijkheid en kleuren',
  fitVenue: 'Passend maken',
  loading: 'Zaalplattegrond laden…',
  errorMessage: 'De zaalplattegrond is niet geladen',
  retry: 'Opnieuw proberen',
  hideLimitedView: 'Plaatsen met beperkt zicht verbergen',
  colorblindSafe: 'Kleurenblindvriendelijke kleuren',
  seatsLeft: _seatsLeftNl,
  moreCount: _moreCountNl,
  addMinutes: _addMinutesNl,
  fromPrice: _fromPriceNl,
  sightline: _sightlineNl,
  ticketCount: _ticketCountNl,
  findBestSeats: _findBestSeatsNl,
  reselectSeats: _reselectSeatsNl,
  continueWithTotal: _continueWithTotalNl,
);
