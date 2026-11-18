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

String _secureMoreAndCheckoutCy(int count) => 'Sicrhau $count arall a thalu';

String _accessFreeCountCy(int count) => '$count ar gael';

String _seatJustTakenByAnotherCy(String label) =>
    'Cymerwyd sedd $label newydd gan brynwr arall.';

String _peekSecuredCy(int count, String total) =>
    '✓ $count wedi\'u sicrhau · $total. Ni chodir tâl arnat eto';

String _ticketCountCy(int count) =>
    count == 1 ? '$count tocyn' : '$count o docynnau';

String _findBestSeatsCy(int count) => count == 1
    ? 'Dod o hyd i\'r $count sedd orau'
    : 'Dod o hyd i\'r $count o seddi gorau';

String _reselectSeatsCy(int count) =>
    count == 1 ? 'Dewisa hi eto' : 'Dewisa nhw eto';

String _seatsFreeCy(int count) => count == 1 ? '$count sedd' : '$count o seddi';

String _seatsLeftInSectionCy(int count) =>
    count == 1 ? '$count sedd ar ôl' : '$count o seddi ar ôl';

String _holdLapsedStillFreeCy(int count) => count == 1
    ? 'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r sedd honno’n dal ar gael.'
    : 'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r seddi hynny’n dal ar gael.';

String _holdLapsedSomeTakenCy(int count) => count == 1
    ? 'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count sedd o’r rheini wedi’i chymryd. Mae’r gweddill yn dal ar gael.'
    : 'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count o’r seddi hynny wedi’u cymryd. Mae’r gweddill yn dal ar gael.';

String _holdLapsedAllTakenCy(int count) => count == 1
    ? 'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r sedd honno wedi’i chymryd.'
    : 'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r seddi hynny wedi’u cymryd.';

String _continueWithTotalCy(String money) => 'Parhau \u00b7 $money';

/// The `cy` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsCy = SeatLayerPickerStrings(
  close: 'Cau',
  overview: 'Lleoliad',
  backToVenue: 'Yn ôl i\'r lleoliad',
  cancel: 'Canslo',
  select: 'Dewis',
  removeSeat: 'Tynnu sedd',
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
  fitVenue: 'Dangos y lleoliad cyfan',
  fitWholeVenue: 'Dangos y lleoliad cyfan',
  loading: 'Yn llwytho\'r map seddi…',
  errorMessage: 'Ni lwythodd y map seddi',
  retry: 'Rho gynnig arall arni',
  accessRefresh: 'Ail-lwytho',
  noSeatsSelected: 'Dim seddi wedi\'u dewis',
  findBestSeatsCta: 'Dod o hyd i\'r seddi gorau',
  organizerNote: 'Nodyn y trefnydd',
  accessiblePhysicalSeat: 'Sedd ffisegol hygyrch',
  emptyWheelchairSpace: 'Lle cadair olwyn gwag',
  findSeatsTogether: 'Dod o hyd i seddi gyda\'i gilydd',
  aboutBestSeats: 'Am ddod o hyd i seddi gyda’i gilydd',
  closestGroupChosenInstantly:
      'Y grŵp agosaf sydd ar gael, wedi\'i ddewis ar unwaith.',
  hideLimitedView: 'Cuddio seddi â golygfa gyfyngedig',
  colorblindSafe: 'Lliwiau sy\'n gyfeillgar i ddallineb lliw',
  notAvailable: 'Ddim ar gael',
  restrictedView: 'Golygfa gyfyngedig',
  obstructedView: 'Golygfa wedi\'i rhwystro',
  premiumSeat: 'Sedd premiwm',
  continueWord: 'Parhau',
  allFloors: 'Pob llawr',
  previousSection: 'Adran flaenorol',
  nextSection: 'Adran nesaf',
  addSeat: 'Ychwanegu sedd',
  added: 'Wedi\'i ychwanegu',
  sectionWord: 'Adran',
  rowWord: 'Rhes',
  seatWord: 'Sedd',
  seeItIn3D: 'Ei weld mewn 3D',
  viewFromThisSeat: 'Golygfa o\'r sedd hon',
  allPrices: 'Pob pris',
  ticketType: 'Math o docyn',
  tierCompanionGuidance: 'Mae angen y lle cadair olwyn cyfagos',
  findingBestSeats: 'Yn chwilio am y seddi gorau…',
  findSeats: 'Chwilio am seddi',
  expandCart: 'Agor y panel tocynnau',
  collapseCart: 'Cwympo\'r panel tocynnau',
  continueToCheckout: 'Parhau i\'r taliad',
  secureMore: 'Sicrhau mwy',
  selectSeats: 'Dewis seddi',
  pickYourSeats: 'Dewisa dy seddi',
  salesClosedPill: 'Gwerthiant ar gau',
  salesClosedCta: 'Gwerthiant ar gau',
  confirmOrCancelSeat: 'Cadarnha neu canslo\'r sedd hon',
  securingSeats: 'Yn sicrhau dy seddi…',
  openingCheckout: 'Yn agor y taliad diogel…',
  testModeExplained:
      'Nid yw\'r archebion yma\'n real ac ni chodir tâl ar unrhyw gerdyn',
  displayOptions: 'Opsiynau arddangos',
  companionSeatsNote:
      'Mae\'r lleoedd cydymaith wrth eu hymyl yn aros yn ddewisadwy',
  zoomIn: 'Chwyddo i mewn',
  zoomOut: 'Chwyddo allan',
  rotateVenue: 'Llusgwch i gylchdroi’r lleoliad',
  moveVenue: 'Llusgwch i symud y lleoliad',
  mapView: 'Map',
  flat2dMap: 'Map 2D gwastad',
  interactive3dVenueView: 'Golwg 3D rhyngweithiol o\'r lleoliad',
  venueView: 'Golwg o\'r lleoliad',
  holdLapsedTitle: 'Mae eich seddi wedi’u rhyddhau',
  salesClosed: 'Gwerthiant ar gau',
  salesClosedCopy:
      'Mae\'r gwerthu tocynnau ar gyfer y digwyddiad hwn wedi dod i ben.',
  salesClosedToast: 'Mae\'r gwerthiant ar gyfer y digwyddiad hwn ar gau.',
  soldOutEyebrow: 'Y digwyddiad hwn',
  soldOutTitle: 'Wedi gwerthu allan',
  soldOutCopy:
      'Nid oes seddi rhifedig ar gael ar gyfer y digwyddiad hwn ar hyn o bryd.',
  holdExpired:
      'Mae dy gadw dros dro wedi dod i ben. Rhyddhawyd y seddi. Dewisa eto.',
  addingEllipsis: 'Yn ychwanegu…',
  moreTimeAdded: 'Ychwanegwyd mwy o amser. Mae dy seddi\'n dal i gael eu cadw.',
  couldNotAddMoreTime:
      'Nid oedd modd ychwanegu mwy o amser. Dos i\'r taliad nawr.',
  seatsJustTaken: 'Cymerwyd un sedd neu fwy newydd. Dewisa eto.',
  allSetTitle: 'Rwyt ti\'n barod',
  confirmedAndOnWay: 'wedi\'i gadarnhau. Mae cadarnhad ar y ffordd.',
  backToMap: 'Yn ôl i\'r map',
  mapDidNotLoad: 'Ni lwythodd y map seddi',
  checkConnection: 'Gwiria dy gysylltiad a rho gynnig arall arni.',
  accessPausedTitle: 'Mae\'r seddi hyn wedi\'u cadw ar hyn o bryd',
  accessPausedCopy:
      'Mae\'r trefnydd wedi oedi\'r dewis hwn. Rho gynnig arall arni ymhen ychydig funudau.',
  accessRevokedTitle: 'Nid yw\'r ddolen fynediad hon yn weithredol mwyach',
  accessRevokedCopy:
      'Gofynna am ddolen newydd gan y sawl a\'i hanfonodd atat er mwyn parhau i archebu\'r seddi hyn.',
  accessUnverifiedTitle: 'Nid oeddem yn gallu gwirio dy fynediad',
  accessUnverifiedCopy:
      'Gelli barhau i archebu unrhyw beth sy\'n ymddangos ar gael. Cysyllta â\'r sawl a anfonodd di yma i gael mynediad at y gweddill.',
  generalAdmission: 'Mynediad cyffredinol',
  numberOfGuests: 'Nifer y gwesteion',
  chooseGuestsCopy:
      'Dewisa faint o westeion fydd yn eistedd gyda\'i gilydd. Cedwir y bwrdd hwn yn unswydd i dy griw di.',
  fewerGuests: 'Llai o westeion',
  moreGuests: 'Mwy o westeion',
  selectTable: 'Dewis bwrdd',
  updateTable: 'Diweddaru\'r bwrdd',
  removeWord: 'Tynnu',
  floorWord: 'Llawr',
  totalWord: 'Cyfanswm',
  accessNeeds: <String, String>{
    'wheelchair': 'Lle cadair olwyn',
    'companion': 'Sedd cydymaith',
    'semi-ambulatory': 'Symudedd cyfyngedig',
    'designated-aisle': 'Eil / trosglwyddo',
    'step-free': 'Heb risiau',
    'hearing': 'Gwrando cynorthwyol',
    'cart': 'Capsiynau byw',
    'sign-language': 'Iaith arwyddion',
    'low-vision': 'Golwg gwan',
    'sensory-friendly': 'Cyfeillgar i\'r synhwyrau',
    'plus-size': 'Maint mwy',
    'lift-armrest': 'Braich sedd godadwy',
  },
  seatsLeft: _seatsLeftCy,
  moreCount: _moreCountCy,
  addMinutes: _addMinutesCy,
  fromPrice: _fromPriceCy,
  sightline: _sightlineCy,
  secureMoreAndCheckout: _secureMoreAndCheckoutCy,
  accessFreeCount: _accessFreeCountCy,
  seatJustTakenByAnother: _seatJustTakenByAnotherCy,
  peekSecured: _peekSecuredCy,
  ticketCount: _ticketCountCy,
  findBestSeats: _findBestSeatsCy,
  reselectSeats: _reselectSeatsCy,
  seatsFree: _seatsFreeCy,
  seatsLeftInSection: _seatsLeftInSectionCy,
  holdLapsedStillFree: _holdLapsedStillFreeCy,
  holdLapsedSomeTaken: _holdLapsedSomeTakenCy,
  holdLapsedAllTaken: _holdLapsedAllTakenCy,
  continueWithTotal: _continueWithTotalCy,
);
