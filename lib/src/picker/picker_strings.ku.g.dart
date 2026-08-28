// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ku)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftKu(int count) => '$count mayî';

String _moreCountKu(int count) => '+$count zêdetir';

String _fromPriceKu(String money) => 'Ji $money ve';

String _ticketCountKu(int count) =>
    count == 1 ? '$count bilêt' : '$count bilêt';

String _findBestSeatsKu(int count) =>
    count == 1 ? '$count cihê herî baş bibîne' : '$count cihên herî baş bibîne';

String _continueWithTotalKu(String money) => 'Berdewam bike \u00b7 $money';

/// The `ku` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsKu = SeatLayerPickerStrings(
  close: 'Bigire',
  overview: 'Cih',
  backToVenue: 'Vegere cihê',
  cancel: 'Betal bike',
  select: 'Hilbijêre',
  viewFromHere: 'Dîmen ji vir',
  openVenue360: 'Cihê bi 360° veke',
  recentre: 'Dîsa li ser dikê navend bike',
  viewFromYourSeat: 'dîmen ji cihê te',
  emptyTrayHint:
      'Li cihekî li ser nexşeyê bixe, an bihêle em cihên herî baş ên berdest ji bo te hilbijêrin.',
  anyTicketType: 'Her cureya bilêtê',
  anyVenueZone: 'Her herêma cihê',
  bestSeats: 'Cihên herî baş',
  showLess: 'Kêmtir nîşan bide',
  undo: 'Vegerîne',
  holdAndCheckout: 'Cihan bigire û drav bide',
  poweredBy: 'Bi SeatLayer tê xebitandin',
  testMode: 'MODA CERIBANDINÊ',
  accessibility: 'Vebijêrkên gihîştbarî û rengan',
  accessibilityTitle: 'Vebijêrkên gihîştbarî û rengan',
  fitVenue: 'Li ekranê bîne',
  loading: 'Nexşeya cihan tê barkirin…',
  errorMessage: 'Nexşeya cihan nehat barkirin',
  retry: 'Dîsa biceribîne',
  hideLimitedView: 'Cihên bi dîmena sînordar veşêre',
  colorblindSafe: 'Rengên guncav ji bo kortiya rengan',
  seatsLeft: _seatsLeftKu,
  moreCount: _moreCountKu,
  fromPrice: _fromPriceKu,
  ticketCount: _ticketCountKu,
  findBestSeats: _findBestSeatsKu,
  continueWithTotal: _continueWithTotalKu,
);
