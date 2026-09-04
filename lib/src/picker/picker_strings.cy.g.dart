// GENERATED — do not edit.
//
// Source: design/locale_strings.json (cy)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftCy(int count) => '$count ar ôl';

String _moreCountCy(int count) => '+$count yn rhagor';

String _addMinutesCy(int minutes) => '+$minutes mun';

String _fromPriceCy(String money) => 'O $money';

String _sightlineCy(String metres) => '≈ $metres m at y llwyfan';

String _ticketCountCy(int count) =>
    count == 1 ? '$count tocyn' : '$count o docynnau';

String _findBestSeatsCy(int count) => count == 1
    ? 'Dod o hyd i\'r $count sedd orau'
    : 'Dod o hyd i\'r $count o seddi gorau';

String _reselectSeatsCy(int count) =>
    count == 1 ? 'Dewisa hi eto' : 'Dewisa nhw eto';

String _continueWithTotalCy(String money) => 'Parhau \u00b7 $money';

/// The `cy` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsCy = SeatLayerPickerStrings(
  close: 'Cau',
  overview: 'Lleoliad',
  backToVenue: 'Yn ôl i\'r lleoliad',
  cancel: 'Canslo',
  select: 'Dewis',
  viewFromHere: 'Golygfa o\'r fan hon',
  openVenue360: 'Agor y lleoliad mewn 360°',
  recentre: 'Ailganoli ar y llwyfan',
  viewFromYourSeat: 'golwg o\'ch sedd',
  emptyTrayHint:
      'Tapia sedd ar y map, neu gad i ni ddewis y rhai gorau sydd ar gael i ti.',
  anyTicketType: 'Unrhyw fath o docyn',
  anyVenueZone: 'Unrhyw barth yn y lleoliad',
  bestSeats: 'Y seddi gorau',
  showLess: 'Dangos llai',
  undo: 'Dadwneud',
  holdAndCheckout: 'Cadw seddi a thalu',
  poweredBy: 'Wedi\'i bweru gan SeatLayer',
  testMode: 'MODD PROFI',
  accessibility: 'Opsiynau hygyrchedd a lliw',
  accessibilityTitle: 'Opsiynau hygyrchedd a lliw',
  fitVenue: 'Ffitio i\'r sgrin',
  loading: 'Yn llwytho\'r map seddi…',
  errorMessage: 'Ni lwythodd y map seddi',
  retry: 'Rho gynnig arall arni',
  hideLimitedView: 'Cuddio seddi â golygfa gyfyngedig',
  colorblindSafe: 'Lliwiau sy\'n gyfeillgar i ddallineb lliw',
  continueWord: 'Parhau',
  seatsLeft: _seatsLeftCy,
  moreCount: _moreCountCy,
  addMinutes: _addMinutesCy,
  fromPrice: _fromPriceCy,
  sightline: _sightlineCy,
  ticketCount: _ticketCountCy,
  findBestSeats: _findBestSeatsCy,
  reselectSeats: _reselectSeatsCy,
  continueWithTotal: _continueWithTotalCy,
);
