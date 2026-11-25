// GENERATED — do not edit.
//
// Source: design/locale_strings.json (cy)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableCy(String label) =>
    'Nid yw $label ar gael mwyach. Dewisa sedd arall.';

String _labelsNoLongerAvailableCy(String labels) =>
    'Nid yw $labels ar gael mwyach. Dewisa grŵp arall.';

String _couldNotFindSeatsTogetherCy(int count) =>
    'Ni ddaethom o hyd i $count sedd gyda\'i gilydd. Rho gynnig ar lai o seddi neu fath arall o docyn.';

String _maxTicketsForOrderCy(int count) =>
    'Gelli ddewis hyd at $count tocyn ar gyfer yr archeb hon.';

String _couldNotRemoveLabelCy(String label) =>
    'Nid oedd modd tynnu $label. Nid yw dy gadw wedi newid.';

String _peekSecuredCy(int count, String total) =>
    '✓ $count wedi\'u sicrhau · $total. Ni chodir tâl arnat eto';

String _venueMapCy(String venue) => 'Map seddi $venue';

String _accessibleStepCy(int index, int total) => '$index o $total';

String _chooseMinMaxGuestsCy(int min, int max) =>
    'Dewisa rhwng $min a $max o westeion.';

String _chooseMoreCy(int count) => 'Dewisa $count arall';

String _seatsHeldForNeedMoreTimeCy(String time) =>
    'Mae dy seddi wedi’u cadw am $time. Angen mwy o amser?';

String _accessNeedWithCountCy(String need, int count) => '$need · $count';

String _ticketCountCy(int count) => switch (pickerPluralCategory('cy', count)) {
  PickerPluralCategory.zero => '$count tocyn',
  PickerPluralCategory.one => '$count tocyn',
  PickerPluralCategory.two => '$count docyn',
  PickerPluralCategory.few => '$count tocyn',
  PickerPluralCategory.many => '$count thocyn',
  _ => '$count o docynnau',
};

String _findBestSeatsCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => 'Dod o hyd i\'r $count sedd orau',
      PickerPluralCategory.one => 'Dod o hyd i\'r $count sedd orau',
      PickerPluralCategory.two => 'Dod o hyd i\'r $count sedd orau',
      PickerPluralCategory.few => 'Dod o hyd i\'r $count sedd orau',
      PickerPluralCategory.many => 'Dod o hyd i\'r $count sedd orau',
      _ => 'Dod o hyd i\'r $count o seddi gorau',
    };

String _reselectSeatsCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => 'Dewisa nhw eto',
      PickerPluralCategory.one => 'Dewisa hi eto',
      PickerPluralCategory.two => 'Dewisa nhw eto',
      PickerPluralCategory.few => 'Dewisa nhw eto',
      PickerPluralCategory.many => 'Dewisa nhw eto',
      _ => 'Dewisa nhw eto',
    };

String _seatsFreeCy(int count) => switch (pickerPluralCategory('cy', count)) {
  PickerPluralCategory.zero => '$count sedd',
  PickerPluralCategory.one => '$count sedd',
  PickerPluralCategory.two => '$count sedd',
  PickerPluralCategory.few => '$count sedd',
  PickerPluralCategory.many => '$count sedd',
  _ => '$count o seddi',
};

String _seatsLeftInSectionCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count sedd ar ôl',
      PickerPluralCategory.one => '$count sedd ar ôl',
      PickerPluralCategory.two => '$count sedd ar ôl',
      PickerPluralCategory.few => '$count sedd ar ôl',
      PickerPluralCategory.many => '$count sedd ar ôl',
      _ => '$count o seddi ar ôl',
    };

String _holdLapsedStillFreeCy(int count) => switch (pickerPluralCategory(
  'cy',
  count,
)) {
  PickerPluralCategory.zero =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r seddi hynny’n dal ar gael.',
  PickerPluralCategory.one =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r sedd honno’n dal ar gael.',
  PickerPluralCategory.two =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r seddi hynny’n dal ar gael.',
  PickerPluralCategory.few =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r seddi hynny’n dal ar gael.',
  PickerPluralCategory.many =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r seddi hynny’n dal ar gael.',
  _ =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd. Mae’r seddi hynny’n dal ar gael.',
};

String _holdLapsedSomeTakenCy(int count) => switch (pickerPluralCategory(
  'cy',
  count,
)) {
  PickerPluralCategory.zero =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count sedd o’r rheini wedi’u cymryd. Mae’r gweddill yn dal ar gael.',
  PickerPluralCategory.one =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count sedd o’r rheini wedi’i chymryd. Mae’r gweddill yn dal ar gael.',
  PickerPluralCategory.two =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count sedd o’r rheini wedi’u cymryd. Mae’r gweddill yn dal ar gael.',
  PickerPluralCategory.few =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count sedd o’r rheini wedi’u cymryd. Mae’r gweddill yn dal ar gael.',
  PickerPluralCategory.many =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count sedd o’r rheini wedi’u cymryd. Mae’r gweddill yn dal ar gael.',
  _ =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae $count o’r seddi hynny wedi’u cymryd. Mae’r gweddill yn dal ar gael.',
};

String _holdLapsedAllTakenCy(int count) => switch (pickerPluralCategory(
  'cy',
  count,
)) {
  PickerPluralCategory.zero =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r seddi hynny wedi’u cymryd.',
  PickerPluralCategory.one =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r sedd honno wedi’i chymryd.',
  PickerPluralCategory.two =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r seddi hynny wedi’u cymryd.',
  PickerPluralCategory.few =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r seddi hynny wedi’u cymryd.',
  PickerPluralCategory.many =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r seddi hynny wedi’u cymryd.',
  _ =>
    'Daeth dy gadw dros dro i ben tra oeddet ti i ffwrdd, ac mae’r seddi hynny wedi’u cymryd.',
};

String _accessibleSectionsCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count adran',
      PickerPluralCategory.one => '$count adran',
      PickerPluralCategory.two => '$count adran',
      PickerPluralCategory.few => '$count adran',
      PickerPluralCategory.many => '$count adran',
      _ => '$count o adrannau',
    };

String _placesAvailableCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count lle ar gael ar hyn o bryd',
      PickerPluralCategory.one => '$count lle ar gael ar hyn o bryd',
      PickerPluralCategory.two => '$count le ar gael ar hyn o bryd',
      PickerPluralCategory.few => '$count lle ar gael ar hyn o bryd',
      PickerPluralCategory.many => '$count lle ar gael ar hyn o bryd',
      _ => '$count o leoedd ar gael ar hyn o bryd',
    };

String _removeTicketsCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => 'Tynnu $count tocyn',
      PickerPluralCategory.one => 'Tynnu $count tocyn',
      PickerPluralCategory.two => 'Tynnu $count docyn',
      PickerPluralCategory.few => 'Tynnu $count thocyn',
      PickerPluralCategory.many => 'Tynnu $count thocyn',
      _ => 'Tynnu $count o docynnau',
    };

String _holdMinutesLeftCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count munud ar ôl',
      PickerPluralCategory.one => '$count funud ar ôl',
      PickerPluralCategory.two => '$count funud ar ôl',
      PickerPluralCategory.few => '$count munud ar ôl',
      PickerPluralCategory.many => '$count munud ar ôl',
      _ => '$count munud ar ôl',
    };

String _holdSecondsLeftCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count eiliad ar ôl',
      PickerPluralCategory.one => '$count eiliad ar ôl',
      PickerPluralCategory.two => '$count eiliad ar ôl',
      PickerPluralCategory.few => '$count eiliad ar ôl',
      PickerPluralCategory.many => '$count eiliad ar ôl',
      _ => '$count eiliad ar ôl',
    };

String _holdLapsedBodyCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => 'Roedden nhw wedi’u cadw am $count munud.',
      PickerPluralCategory.one => 'Roedden nhw wedi’u cadw am $count funud.',
      PickerPluralCategory.two => 'Roedden nhw wedi’u cadw am $count funud.',
      PickerPluralCategory.few => 'Roedden nhw wedi’u cadw am $count munud.',
      PickerPluralCategory.many => 'Roedden nhw wedi’u cadw am $count munud.',
      _ => 'Roedden nhw wedi’u cadw am $count munud.',
    };

String _seatsNotRecoveredCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => 'Nid oedd modd adfer $count sedd',
      PickerPluralCategory.one => 'Nid oedd modd adfer $count sedd',
      PickerPluralCategory.two => 'Nid oedd modd adfer $count sedd',
      PickerPluralCategory.few => 'Nid oedd modd adfer $count sedd',
      PickerPluralCategory.many => 'Nid oedd modd adfer $count sedd',
      _ => 'Nid oedd modd adfer $count o seddi',
    };

String _activeFiltersCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count hidlydd',
      PickerPluralCategory.one => '$count hidlydd',
      PickerPluralCategory.two => '$count hidlydd',
      PickerPluralCategory.few => '$count hidlydd',
      PickerPluralCategory.many => '$count hidlydd',
      _ => '$count o hidlyddion',
    };

String _accessibilityFiltersActiveCy(int count) =>
    switch (pickerPluralCategory('cy', count)) {
      PickerPluralCategory.zero => '$count hidlydd hygyrchedd ar waith',
      PickerPluralCategory.one => '$count hidlydd hygyrchedd ar waith',
      PickerPluralCategory.two => '$count hidlydd hygyrchedd ar waith',
      PickerPluralCategory.few => '$count hidlydd hygyrchedd ar waith',
      PickerPluralCategory.many => '$count hidlydd hygyrchedd ar waith',
      _ => '$count o hidlyddion hygyrchedd ar waith',
    };

String _onlyLeftCy(int count) => switch (pickerPluralCategory('cy', count)) {
  PickerPluralCategory.zero => '$count sedd ar ôl',
  PickerPluralCategory.one => '$count sedd ar ôl',
  PickerPluralCategory.two => '$count sedd ar ôl',
  PickerPluralCategory.few => '$count sedd ar ôl',
  PickerPluralCategory.many => '$count sedd ar ôl',
  _ => '$count o seddi ar ôl',
};

String _maintenancePausedCy(int count) => switch (pickerPluralCategory(
  'cy',
  count,
)) {
  PickerPluralCategory.zero =>
    'Mae archebu wedi’i oedi ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni ymhen tua $count munud.',
  PickerPluralCategory.one =>
    'Mae archebu wedi’i oedi ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni ymhen tua $count funud.',
  PickerPluralCategory.two =>
    'Mae archebu wedi’i oedi ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni ymhen tua $count funud.',
  PickerPluralCategory.few =>
    'Mae archebu wedi’i oedi ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni ymhen tua $count munud.',
  PickerPluralCategory.many =>
    'Mae archebu wedi’i oedi ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni ymhen tua $count munud.',
  _ =>
    'Mae archebu wedi’i oedi ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni ymhen tua $count munud.',
};

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
  testMode: 'Modd profi',
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
  viewGroupTitle: 'GOLWG',
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
  ticketPrices: 'Prisiau tocynnau',
  yourSeats: 'Dy seddi',
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
  ticketTypeSoldOut:
      'Mae\'r math hwnnw o docyn wedi gwerthu allan. Rho gynnig ar fath arall.',
  seatsNoLongerAvailableTryAnother:
      'Nid yw\'r seddi hynny ar gael mwyach. Rho gynnig ar nifer arall neu fath arall o docyn.',
  companionPairRequired:
      'Dewisa\'r lle cadair olwyn cyfagos gyda phob tocyn cydymaith.',
  ticketOptionNotApplicable:
      'Dyw’r dewis tocyn hwnnw ddim ar gael ar gyfer y sedd a ddewiswyd.',
  maintenancePausedShortly:
      'Mae archebu wedi’i oedi am ychydig funudau ar gyfer gwaith cynnal a chadw. Rhowch gynnig arall arni cyn bo hir.',
  guestsOnly: 'Mae\'r digwyddiad hwn ar gyfer gwesteion gwahoddedig.',
  guestChoiceClosed: 'Dyw dewis seddi ddim ar agor ar hyn o bryd.',
  maxOneTicketForOrder: 'Gelli ddewis hyd at 1 tocyn ar gyfer yr archeb hon.',
  tooManyAttempts:
      'Gormod o gynigion. Arhoswch eiliad a rhowch gynnig arall arni.',
  seatHeldForRenewal:
      'Mae un o\'r seddi hyn yn cael ei chadw i ddeiliad tocyn tymor sy\'n dal i allu ei hadnewyddu. Dewisa sedd arall.',
  seatUnavailable: 'Nid yw\'r sedd hon ar gael.',
  eventUnavailable: 'Nid oes modd archebu tocynnau yma ar hyn o bryd.',
  savedSeatsNotRestored:
      'Doedd dim modd adfer eich seddi blaenorol. Dewiswch eto.',
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
  adjustSelection: 'Addasu\'r dewis seddi',
  backToSeatMap: 'Yn ôl i\'r map seddi',
  chooseSeats: 'Dewisa dy seddi',
  chooseTickets: 'Dewisa docynnau',
  placeWord: 'LLE',
  ticketWord: 'Tocyn',
  passport: 'Proffil y sedd',
  venue3D: '3D',
  venueZone: 'Parth y lleoliad',
  venueMapHint:
      'Mae seddi’n cael eu dewis gyda’r rheolyddion o amgylch y map: y rheilen brisiau uwch ei ben, rheolyddion yr adrannau oddi tano, a’r panel tocynnau ar y gwaelod.',
  previousSeat: 'Sedd flaenorol',
  nextSeat: 'Sedd nesaf',
  orbitMode: 'Cylchdroi’r lleoliad',
  panMode: 'Symud y lleoliad',
  openInteractive3dVenue: 'Agor golwg 3D rhyngweithiol o’r lleoliad',
  showSeatsFor: 'DANGOS SEDDI AR GYFER',
  accessJumpFirstSection: 'Neidio i’r adran gyntaf',
  accessJumpNextSection: 'Neidio i’r adran nesaf',
  fewerTickets: 'Llai o docynnau',
  moreTickets: 'Mwy o docynnau',
  addTickets: 'Ychwanegu tocynnau',
  noSelectableSeats: 'Does dim seddi y gellir eu dewis ar gael ar hyn o bryd.',
  confirmYourTickets: 'Cadarnha dy docynnau',
  seatsSecuredOpeningCheckout: 'Seddi wedi’u sicrhau. Yn agor y taliad…',
  holdInCheckoutTitle: 'Mae dy seddi eisoes yn y taliad',
  holdInCheckoutBody:
      'Gorffen talu i’w cadw. I ddewis seddi gwahanol, rhyddha’r rhain yn gyntaf — byddan nhw’n mynd yn ôl ar werth.',
  releaseAndChangeSeats: 'Rhyddhau a newid seddi',
  holdAlreadyHeldTitle: 'Mae dy seddi eisoes wedi’u cadw',
  holdAlreadyHeldBody: 'Dos ymlaen i’r taliad i’w cadw.',
  accessExpiredTitle: 'Mae dy sesiwn seddi wedi dod i ben',
  accessExpiredCopy:
      'Ail-lwytha’r map seddi i barhau. Mae seddi sydd eisoes yn dy fasged yn aros wedi’u cadw nes i’r amserydd ddod i ben.',
  dismissError: 'Cau’r gwall',
  testModeLong: 'Modd profi · dim byd yn cael ei archebu',
  seatRemoved: 'Tynnwyd y tocyn',
  reloadSeatMap: 'Ail-lwytho’r map seddi',
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
  labelNoLongerAvailable: _labelNoLongerAvailableCy,
  labelsNoLongerAvailable: _labelsNoLongerAvailableCy,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherCy,
  maxTicketsForOrder: _maxTicketsForOrderCy,
  couldNotRemoveLabel: _couldNotRemoveLabelCy,
  peekSecured: _peekSecuredCy,
  venueMap: _venueMapCy,
  accessibleStep: _accessibleStepCy,
  chooseMinMaxGuests: _chooseMinMaxGuestsCy,
  chooseMore: _chooseMoreCy,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeCy,
  accessNeedWithCount: _accessNeedWithCountCy,
  ticketCount: _ticketCountCy,
  findBestSeats: _findBestSeatsCy,
  reselectSeats: _reselectSeatsCy,
  seatsFree: _seatsFreeCy,
  seatsLeftInSection: _seatsLeftInSectionCy,
  holdLapsedStillFree: _holdLapsedStillFreeCy,
  holdLapsedSomeTaken: _holdLapsedSomeTakenCy,
  holdLapsedAllTaken: _holdLapsedAllTakenCy,
  accessibleSections: _accessibleSectionsCy,
  placesAvailable: _placesAvailableCy,
  removeTickets: _removeTicketsCy,
  holdMinutesLeft: _holdMinutesLeftCy,
  holdSecondsLeft: _holdSecondsLeftCy,
  holdLapsedBody: _holdLapsedBodyCy,
  seatsNotRecovered: _seatsNotRecoveredCy,
  activeFilters: _activeFiltersCy,
  accessibilityFiltersActive: _accessibilityFiltersActiveCy,
  onlyLeft: _onlyLeftCy,
  maintenancePaused: _maintenancePausedCy,
  continueWithTotal: _continueWithTotalCy,
);
