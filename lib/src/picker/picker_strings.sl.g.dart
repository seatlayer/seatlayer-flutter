// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftSl(int count) => 'Ostalo $count';

String _moreCountSl(int count) => '+$count več';

String _fromPriceSl(String money) => 'Od $money';

String _ticketCountSl(int count) =>
    count == 1 ? '$count vstopnica' : '$count vstopnic';

String _findBestSeatsSl(int count) => count == 1
    ? 'Poišči $count najboljši sedež'
    : 'Poišči $count najboljših sedežev';

String _continueWithTotalSl(String money) => 'Nadaljuj \u00b7 $money';

/// The `sl` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSl = SeatLayerPickerStrings(
  close: 'Zapri',
  overview: 'Prizorišče',
  backToVenue: 'Nazaj na prizorišče',
  cancel: 'Prekliči',
  select: 'Izberi',
  viewFromHere: 'Pogled od tu',
  openVenue360: 'Odpri prizorišče v 360°',
  recentre: 'Znova centriraj na oder',
  viewFromYourSeat: 'pogled z vašega sedeža',
  emptyTrayHint:
      'Tapnite sedež na načrtu ali pustite, da izberemo najboljše proste za vas.',
  anyTicketType: 'Katera koli vrsta vstopnice',
  anyVenueZone: 'Katero koli območje',
  bestSeats: 'Najboljši sedeži',
  showLess: 'Prikaži manj',
  undo: 'Razveljavi',
  holdAndCheckout: 'Rezerviraj sedeže in plačaj',
  poweredBy: 'Poganja SeatLayer',
  testMode: 'TESTNI NAČIN',
  accessibility: 'Dostopnost in barve',
  accessibilityTitle: 'Dostopnost in barve',
  fitVenue: 'Prilagodi zaslonu',
  loading: 'Nalagamo načrt sedežev…',
  errorMessage: 'Načrt sedežev se ni naložil',
  retry: 'Poskusi znova',
  hideLimitedView: 'Skrij sedeže z omejenim pogledom',
  colorblindSafe: 'Barve, prijazne barvni slepoti',
  seatsLeft: _seatsLeftSl,
  moreCount: _moreCountSl,
  fromPrice: _fromPriceSl,
  ticketCount: _ticketCountSl,
  findBestSeats: _findBestSeatsSl,
  continueWithTotal: _continueWithTotalSl,
);
