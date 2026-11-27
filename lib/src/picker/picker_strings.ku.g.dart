// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ku)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftKu(int count) => '$count mayî';

String _moreCountKu(int count) => '+$count zêdetir';

String _addMinutesKu(int minutes) => '+$minutes deq';

String _fromPriceKu(String money) => 'Ji $money ve';

String _sightlineKu(String metres) => '≈ $metres m heta dikê';

String _secureMoreAndCheckoutKu(int count) =>
    '$count din piştrast bike û drav bide';

String _accessFreeCountKu(int count) => '$count vala';

String _seatJustTakenByAnotherKu(String label) =>
    'Cihê $label nû ji hêla kirrûbarekî din ve hat girtin.';

String _labelNoLongerAvailableKu(String label) =>
    '$label êdî berdest nîne. Cihekî din hilbijêre.';

String _labelsNoLongerAvailableKu(String labels) =>
    '$labels êdî berdest nînin. Komeke din hilbijêre.';

String _couldNotFindSeatsTogetherKu(int count) =>
    'Me $count cihên li kêleka hev nedîtin. Cihên kêmtir an cureyeke bilêtê ya din biceribîne.';

String _maxTicketsForOrderKu(int count) =>
    'Ji bo vê siparîşê tu dikarî herî zêde $count bilêtan hilbijêrî.';

String _couldNotRemoveLabelKu(String label) =>
    '$label nehat rakirin. Girtina te neguherî.';

String _peekSecuredKu(int count, String total) =>
    '✓ $count hatin piştrastkirin · $total. Hîn tu pere nayê girtin';

String _venueMapKu(String venue) => 'Nexşeya cihan a $venue';

String _accessibleStepKu(int index, int total) => '$index ji $total';

String _chooseMinMaxGuestsKu(int min, int max) =>
    'Di navbera $min û $max mêvanan de hilbijêre.';

String _chooseMoreKu(int count) => '$count din hilbijêre';

String _seatsHeldForNeedMoreTimeKu(String time) =>
    'Cihên te ji bo $time hatine girtin. Dema zêdetir lazim e?';

String _accessNeedWithCountKu(String need, int count) => '$need · $count';

String _ticketCountKu(int count) => switch (pickerPluralCategory('ku', count)) {
  PickerPluralCategory.one => '$count bilêt',
  _ => '$count bilêt',
};

String _findBestSeatsKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count cihê herî baş bibîne',
      _ => '$count cihên herî baş bibîne',
    };

String _reselectSeatsKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => 'Wî dîsa hilbijêre',
      _ => 'Wan dîsa hilbijêre',
    };

String _seatsFreeKu(int count) => switch (pickerPluralCategory('ku', count)) {
  PickerPluralCategory.one => '$count cih',
  _ => '$count cih',
};

String _seatsLeftInSectionKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count cih maye',
      _ => '$count cih mane',
    };

String _holdLapsedStillFreeKu(int count) => switch (pickerPluralCategory(
  'ku',
  count,
)) {
  PickerPluralCategory.one =>
    'Dema tu ne li vir bûyî rezervasyona te qediya. Ew cih hîn jî vala ye.',
  _ => 'Dema tu ne li vir bûyî rezervasyona te qediya. Ew cih hîn jî vala ne.',
};

String _holdLapsedSomeTakenKu(int count) => switch (pickerPluralCategory(
  'ku',
  count,
)) {
  PickerPluralCategory.one =>
    'Dema tu ne li vir bûyî rezervasyona te qediya û $count ji van cihan hatiye girtin. Yên mayî hîn jî vala ne.',
  _ =>
    'Dema tu ne li vir bûyî rezervasyona te qediya û $count ji van cihan hatine girtin. Yên mayî hîn jî vala ne.',
};

String _holdLapsedAllTakenKu(int count) => switch (pickerPluralCategory(
  'ku',
  count,
)) {
  PickerPluralCategory.one =>
    'Dema tu ne li vir bûyî rezervasyona te qediya û ew cih hatiye girtin.',
  _ => 'Dema tu ne li vir bûyî rezervasyona te qediya û ew cih hatine girtin.',
};

String _accessibleSectionsKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count beş',
      _ => '$count beş',
    };

String _placesAvailableKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => 'Niha $count cih berdest e',
      _ => 'Niha $count cih berdest in',
    };

String _removeTicketsKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count bilêt rake',
      _ => '$count bilêtan rake',
    };

String _holdMinutesLeftKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count deqe maye',
      _ => '$count deqe mane',
    };

String _holdSecondsLeftKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count çirke maye',
      _ => '$count çirke mane',
    };

String _holdLapsedBodyKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => 'Ew ji bo $count deqeyê hatin girtin.',
      _ => 'Ew ji bo $count deqeyan hatin girtin.',
    };

String _seatsNotRecoveredKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count cih nehat vegerandin',
      _ => '$count cih nehatin vegerandin',
    };

String _activeFiltersKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count fîltre',
      _ => '$count fîltre',
    };

String _accessibilityFiltersActiveKu(int count) =>
    switch (pickerPluralCategory('ku', count)) {
      PickerPluralCategory.one => '$count fîltreya gihîştbariyê çalak e',
      _ => '$count fîltreyên gihîştbariyê çalak in',
    };

String _onlyLeftKu(int count) => switch (pickerPluralCategory('ku', count)) {
  PickerPluralCategory.one => '$count cih maye',
  _ => '$count cih mane',
};

String _maintenancePausedKu(int count) => switch (pickerPluralCategory(
  'ku',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervasyon ji bo lênihêrînê hatiye rawestandin. Ji kerema xwe piştî nêzîkî $count deqeyê dîsa biceribîne.',
  _ =>
    'Rezervasyon ji bo lênihêrînê hatiye rawestandin. Ji kerema xwe piştî nêzîkî $count deqeyan dîsa biceribîne.',
};

String _continueWithTotalKu(String money) => 'Berdewam bike \u00b7 $money';

/// The `ku` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsKu = SeatLayerPickerStrings(
  close: 'Bigire',
  overview: 'Cih',
  backToVenue: 'Vegere cihê',
  cancel: 'Betal bike',
  select: 'Hilbijêre',
  removeSeat: 'Cih rake',
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
  testMode: 'Moda ceribandinê',
  accessibility: 'Vebijêrkên gihîştbarî û rengan',
  accessibilityTitle: 'Vebijêrkên gihîştbarî û rengan',
  fitVenue: 'Hemû cih nîşan bide',
  fitWholeVenue: 'Hemû cih nîşan bide',
  loading: 'Nexşeya cihan tê barkirin…',
  errorMessage: 'Nexşeya cihan nehat barkirin',
  retry: 'Dîsa biceribîne',
  accessRefresh: 'Nû bike',
  noSeatsSelected: 'Tu cih nehat hilbijartin',
  findBestSeatsCta: 'Cihên herî baş bibîne',
  organizerNote: 'Nîşeya organîzator',
  accessiblePhysicalSeat: 'Cihê fizîkî yê gihîştbar',
  emptyWheelchairSpace: 'Cihê vala yê kursiya teker',
  findSeatsTogether: 'Cihên li kêleka hev bibîne',
  aboutBestSeats: 'Derbarê dîtina kursiyên li kêleka hev',
  closestGroupChosenInstantly:
      'Koma berdest a herî nêzîk, di cih de hat hilbijartin.',
  hideLimitedView: 'Cihên bi dîmena sînordar veşêre',
  colorblindSafe: 'Rengên guncav ji bo kortiya rengan',
  notAvailable: 'Ne berdest e',
  viewGroupTitle: 'XUYANG',
  restrictedView: 'Dîmena sînordar',
  obstructedView: 'Dîmena girtî',
  premiumSeat: 'Cihê premium',
  continueWord: 'Berdewam bike',
  allFloors: 'Hemû qat',
  previousSection: 'Beşa berê',
  nextSection: 'Beşa din',
  addSeat: 'Cih zêde bike',
  added: 'Zêde bû',
  sectionWord: 'Beş',
  rowWord: 'Rêz',
  seatWord: 'Cih',
  seeItIn3D: 'Bi 3D bibîne',
  viewFromThisSeat: 'Dîmen ji vî cihî',
  allPrices: 'Hemû biha',
  ticketPrices: 'Bihayên bilêtan',
  yourSeats: 'Cihên te',
  ticketType: 'Cureya bilêtê',
  tierCompanionGuidance: 'Cihê kursiya teker ya cîran hewce ye',
  findingBestSeats: 'Cihên herî baş têne lêgerîn…',
  findSeats: 'Cihan bibîne',
  expandCart: 'Panela bilêtan veke',
  collapseCart: 'Panela bilêtan bigire',
  continueToCheckout: 'Berdewam bike bo dravdanê',
  secureMore: 'Zêdetir piştrast bike',
  selectSeats: 'Cihan hilbijêre',
  pickYourSeats: 'Cihên xwe hilbijêre',
  salesClosedPill: 'Firotin girtî ye',
  salesClosedCta: 'Firotin girtî ye',
  confirmOrCancelSeat: 'Vî cihî piştrast bike an betal bike',
  securingSeats: 'Cihên te têne piştrastkirin…',
  openingCheckout: 'Dravdana ewle tê vekirin…',
  testModeExplained:
      'Rezervasyonên li vir ne rastîn in û tu kart nayê hesibandin',
  displayOptions: 'Vebijêrkên xuyangê',
  companionSeatsNote: 'Cihên hevaltiyê yên li kêleka wan hilbijartinî dimînin',
  zoomIn: 'Nêzîk bike',
  zoomOut: 'Dûr bike',
  rotateVenue: 'Ji bo zivirandina cihê kaş bike',
  moveVenue: 'Ji bo livandina cihê kaş bike',
  mapView: 'Nexşe',
  flat2dMap: 'Nexşeya 2D ya rast',
  interactive3dVenueView: 'Dîmena 3D ya înteraktîv a cihê',
  venueView: 'Dîmena cihê',
  holdLapsedTitle: 'Cihên we hatin berdan',
  salesClosed: 'Firotin girtî ye',
  salesClosedCopy: 'Firotina bilêtan ji bo vê çalakiyê qediya.',
  salesClosedToast: 'Firotin ji bo vê çalakiyê girtî ye.',
  soldOutEyebrow: 'Ev çalakî',
  soldOutTitle: 'Tev hatin firotin',
  soldOutCopy: 'Ji bo vê çalakiyê niha tu cihên hejmarkirî berdest nînin.',
  holdExpired: 'Girtina te qediya. Cih hatin berdan. Ji nû ve hilbijêre.',
  addingEllipsis: 'Tê zêdekirin…',
  moreTimeAdded: 'Dem hat zêdekirin. Cihên te hîn jî girtî ne.',
  couldNotAddMoreTime: 'Dem nehat zêdekirin. Niha here dravdanê.',
  seatsJustTaken:
      'Yek an zêdetir cih nû hatin girtin. Ji kerema xwe ji nû ve hilbijêre.',
  ticketTypeSoldOut:
      'Ew cureya bilêtê tev hatiye firotin. Cureyeke din biceribîne.',
  seatsNoLongerAvailableTryAnother:
      'Ew cih êdî berdest nînin. Hejmareke din an cureyeke bilêtê ya din biceribîne.',
  companionPairRequired:
      'Bi her bilêta hevrêtiyê re cihê kursiya teker ya cîran hilbijêre.',
  ticketOptionNotApplicable:
      'Ew vebijarka bilêtê ji bo cihê hilbijartî ne berdest e.',
  maintenancePausedShortly:
      'Rezervasyon ji bo lênihêrînê çend deqeyan hatiye rawestandin. Ji kerema xwe piştî demekê dîsa biceribîne.',
  guestsOnly: 'Ev çalakî ji bo mêvanên vexwendî ye.',
  guestChoiceClosed: 'Hilbijartina cihan niha ne vekirî ye.',
  maxOneTicketForOrder:
      'Ji bo vê siparîşê tu dikarî herî zêde 1 bilêtê hilbijêrî.',
  tooManyAttempts:
      'Gelek ceribandin hatin kirin. Hinekî bisekine û dîsa biceribîne.',
  seatHeldForRenewal:
      'Yek ji van cihan ji bo xwediyê bilêta demsalê tê girtin ku hîn dikare wê nû bike. Cihekî din hilbijêre.',
  seatUnavailable: 'Ev cih ne berdest e.',
  eventUnavailable: 'Niha li vir bilêt nayên rezervekirin.',
  savedSeatsNotRestored:
      'Kursiyên te yên berê nehatin vegerandin. Ji kerema xwe dîsa hilbijêre.',
  allSetTitle: 'Her tişt amade ye',
  confirmedAndOnWay: 'hat piştrastkirin. Piştrastkirin di rê de ye.',
  backToMap: 'Vegere nexşeyê',
  mapDidNotLoad: 'Nexşeya cihan nehat barkirin',
  checkConnection: 'Girêdana xwe kontrol bike û dîsa biceribîne.',
  accessPausedTitle: 'Ev cih niha hatine girtin',
  accessPausedCopy:
      'Organîzator ev hilbijartin rawestandiye. Piştî çend deqîqeyan dîsa biceribîne.',
  accessRevokedTitle: 'Ev girêdana gihîştinê êdî çalak nîne',
  accessRevokedCopy:
      'Ji kesê ku ev girêdan ji te re şand girêdanek nû bixwaze da ku tu van cihan berdewam bikirî.',
  accessUnverifiedTitle: 'Me nekarî gihîştina te piştrast bike',
  accessUnverifiedCopy:
      'Tu hîn jî dikarî her tiştê ku wek berdest xuya dike bikirî. Ji bo gihîştina yên din bi kesê ku ev girêdan ji te re şand re têkilî daynê.',
  generalAdmission: 'Ketina giştî',
  numberOfGuests: 'Hejmara mêvanan',
  chooseGuestsCopy:
      'Hilbijêre ka çend mêvan bi hev re rûdinin. Ev mase tenê ji bo koma te tê veqetandin.',
  fewerGuests: 'Mêvanên kêmtir',
  moreGuests: 'Mêvanên zêdetir',
  selectTable: 'Maseyê hilbijêre',
  updateTable: 'Maseyê nû bike',
  removeWord: 'Rake',
  floorWord: 'Qat',
  totalWord: 'Tevahî',
  adjustSelection: 'Hilbijartina cihan sererast bike',
  backToSeatMap: 'Vegere nexşeya cihan',
  chooseSeats: 'Cihên xwe hilbijêre',
  chooseTickets: 'Bilêtan hilbijêre',
  placeWord: 'CIH',
  guestsWord: 'Mêvan',
  tableWord: 'Mase',
  ticketWord: 'Bilêt',
  passport: 'Profîla cih',
  venue3D: '3D',
  venueZone: 'Herêma cihê',
  venueMapHint:
      'Cih bi kontrolên li dora nexşeyê têne hilbijartin: rêza bihayan li jorê wê, kontrolên beşan li jêrê wê, û panela bilêtan li binî.',
  previousSeat: 'Cihê berê',
  nextSeat: 'Cihê din',
  orbitMode: 'Zivirandina cihê',
  panMode: 'Livandina cihê',
  openInteractive3dVenue: 'Dîmena 3D ya înteraktîv a cihê veke',
  showSeatsFor: 'CIHAN NÎŞAN BIDE JI BO',
  accessJumpFirstSection: 'Here beşa yekem',
  accessJumpNextSection: 'Here beşa din',
  fewerTickets: 'Bilêtên kêmtir',
  moreTickets: 'Bilêtên zêdetir',
  addTickets: 'Bilêtan zêde bike',
  noSelectableSeats: 'Niha tu cihên hilbijêrbar berdest nînin.',
  confirmYourTickets: 'Bilêtên xwe piştrast bike',
  seatsSecuredOpeningCheckout: 'Cih hatin piştrastkirin. Dravdan tê vekirin…',
  holdInCheckoutTitle: 'Cihên te jixwe di dravdanê de ne',
  holdInCheckoutBody:
      'Ji bo ku wan biparêzî dravdanê temam bike. Ji bo hilbijartina cihên din, pêşî van berde — ew dîsa dikevin firotanê.',
  releaseAndChangeSeats: 'Berde û cihan biguherîne',
  holdAlreadyHeldTitle: 'Cihên te jixwe hatine girtin',
  holdAlreadyHeldBody: 'Ji bo ku wan biparêzî, bidomîne bo dravdanê.',
  accessExpiredTitle: 'Danişîna te ya cihan qediya',
  accessExpiredCopy:
      'Ji bo berdewamkirinê nexşeya cihan ji nû ve bar bike. Cihên ku jixwe di selika te de ne heta ku demjimêr biqede girtî dimînin.',
  dismissError: 'Çewtiyê bigire',
  testModeLong: 'Moda ceribandinê · tiştek nayê rezervekirin',
  seatRemoved: 'Bilêt hat rakirin',
  reloadSeatMap: 'Nexşeya cihan ji nû ve bar bike',
  accessNeeds: <String, String>{
    'wheelchair': 'Cihê kursiya teker',
    'companion': 'Cihê hevaltiyê',
    'semi-ambulatory': 'Tevgera sînordar',
    'designated-aisle': 'Rê / veguhastin',
    'step-free': 'Bêyî pêpelûk',
    'hearing': 'Alîkariya bihîstinê',
    'cart': 'Jêrnivîsa zindî',
    'sign-language': 'Zimanê îşaretan',
    'low-vision': 'Kêmdîtin',
    'sensory-friendly': 'Bêdeng û aram',
    'plus-size': 'Cihê fireh',
    'lift-armrest': 'Destgirê hilkêşbar',
  },
  seatsLeft: _seatsLeftKu,
  moreCount: _moreCountKu,
  addMinutes: _addMinutesKu,
  fromPrice: _fromPriceKu,
  sightline: _sightlineKu,
  secureMoreAndCheckout: _secureMoreAndCheckoutKu,
  accessFreeCount: _accessFreeCountKu,
  seatJustTakenByAnother: _seatJustTakenByAnotherKu,
  labelNoLongerAvailable: _labelNoLongerAvailableKu,
  labelsNoLongerAvailable: _labelsNoLongerAvailableKu,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherKu,
  maxTicketsForOrder: _maxTicketsForOrderKu,
  couldNotRemoveLabel: _couldNotRemoveLabelKu,
  peekSecured: _peekSecuredKu,
  venueMap: _venueMapKu,
  accessibleStep: _accessibleStepKu,
  chooseMinMaxGuests: _chooseMinMaxGuestsKu,
  chooseMore: _chooseMoreKu,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeKu,
  accessNeedWithCount: _accessNeedWithCountKu,
  ticketCount: _ticketCountKu,
  findBestSeats: _findBestSeatsKu,
  reselectSeats: _reselectSeatsKu,
  seatsFree: _seatsFreeKu,
  seatsLeftInSection: _seatsLeftInSectionKu,
  holdLapsedStillFree: _holdLapsedStillFreeKu,
  holdLapsedSomeTaken: _holdLapsedSomeTakenKu,
  holdLapsedAllTaken: _holdLapsedAllTakenKu,
  accessibleSections: _accessibleSectionsKu,
  placesAvailable: _placesAvailableKu,
  removeTickets: _removeTicketsKu,
  holdMinutesLeft: _holdMinutesLeftKu,
  holdSecondsLeft: _holdSecondsLeftKu,
  holdLapsedBody: _holdLapsedBodyKu,
  seatsNotRecovered: _seatsNotRecoveredKu,
  activeFilters: _activeFiltersKu,
  accessibilityFiltersActive: _accessibilityFiltersActiveKu,
  onlyLeft: _onlyLeftKu,
  maintenancePaused: _maintenancePausedKu,
  continueWithTotal: _continueWithTotalKu,
);
