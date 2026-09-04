// GENERATED — do not edit.
//
// Source: design/locale_strings.json (no)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftNo(int count) => '$count igjen';

String _moreCountNo(int count) => '+$count flere';

String _addMinutesNo(int minutes) => '+$minutes min';

String _fromPriceNo(String money) => 'Fra $money';

String _sightlineNo(String metres) => '≈ $metres m til scenen';

String _ticketCountNo(int count) =>
    count == 1 ? '$count billett' : '$count billetter';

String _findBestSeatsNo(int count) =>
    count == 1 ? 'Finn $count beste plass' : 'Finn $count beste plasser';

String _reselectSeatsNo(int count) =>
    count == 1 ? 'Velg den på nytt' : 'Velg dem på nytt';

String _continueWithTotalNo(String money) => 'Fortsett \u00b7 $money';

/// The `no` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsNo = SeatLayerPickerStrings(
  close: 'Lukk',
  overview: 'Spillested',
  backToVenue: 'Tilbake til arenaen',
  cancel: 'Avbryt',
  select: 'Velg',
  viewFromHere: 'Utsikt herfra',
  openVenue360: 'Åpne arenaen i 360°',
  recentre: 'Sentrer på scenen igjen',
  viewFromYourSeat: 'utsikt fra plassen din',
  emptyTrayHint:
      'Trykk på en plass på kartet, eller la oss velge de beste ledige for deg.',
  anyTicketType: 'Hvilken som helst billettype',
  anyVenueZone: 'Hvilken som helst sone',
  bestSeats: 'Beste plassene',
  showLess: 'Vis mindre',
  undo: 'Angre',
  holdAndCheckout: 'Reserver plasser og betal',
  poweredBy: 'Drevet av SeatLayer',
  testMode: 'TESTMODUS',
  accessibility: 'Tilgjengelighet og farger',
  accessibilityTitle: 'Tilgjengelighet og farger',
  fitVenue: 'Tilpass til skjermen',
  loading: 'Laster setekartet…',
  errorMessage: 'Setekartet ble ikke lastet',
  retry: 'Prøv igjen',
  hideLimitedView: 'Skjul plasser med begrenset sikt',
  colorblindSafe: 'Fargeblindvennlige farger',
  seatsLeft: _seatsLeftNo,
  moreCount: _moreCountNo,
  addMinutes: _addMinutesNo,
  fromPrice: _fromPriceNo,
  sightline: _sightlineNo,
  ticketCount: _ticketCountNo,
  findBestSeats: _findBestSeatsNo,
  reselectSeats: _reselectSeatsNo,
  continueWithTotal: _continueWithTotalNo,
);
