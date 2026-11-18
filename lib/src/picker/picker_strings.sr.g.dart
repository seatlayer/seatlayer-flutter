// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftSr(int count) => 'Преостало $count';

String _moreCountSr(int count) => '+$count више';

String _addMinutesSr(int minutes) => '+$minutes мин';

String _fromPriceSr(String money) => 'Од $money';

String _sightlineSr(String metres) => '≈ $metres m до бине';

String _secureMoreAndCheckoutSr(int count) => 'Обезбеди још $count и плати';

String _accessFreeCountSr(int count) => 'Слободних: $count';

String _seatJustTakenByAnotherSr(String label) =>
    'Место $label управо је заузео други купац.';

String _peekSecuredSr(int count, String total) =>
    '✓ $count обезбеђено · $total. Још вас нећемо теретити';

String _venueMapSr(String venue) => 'План места – $venue';

String _accessibleStepSr(int index, int total) => '$index од $total';

String _chooseMinMaxGuestsSr(int min, int max) =>
    'Изаберите између $min и $max гостију.';

String _chooseMoreSr(int count) => 'Изабери још $count';

String _seatsHeldForNeedMoreTimeSr(String time) =>
    'Ваша места су резервисана још $time. Треба вам више времена?';

String _accessNeedWithCountSr(String need, int count) => '$need · $count';

String _ticketCountSr(int count) => switch (pickerPluralCategory('sr', count)) {
  PickerPluralCategory.one => '$count улазница',
  PickerPluralCategory.few => '$count улазнице',
  _ => '$count улазница',
};

String _findBestSeatsSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Пронађи $count најбоље место',
      PickerPluralCategory.few => 'Пронађи $count најбоља места',
      _ => 'Пронађи $count најбољих места',
    };

String _reselectSeatsSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Изаберите га поново',
      PickerPluralCategory.few => 'Изаберите их поново',
      _ => 'Изаберите их поново',
    };

String _seatsFreeSr(int count) => switch (pickerPluralCategory('sr', count)) {
  PickerPluralCategory.one => '$count место',
  PickerPluralCategory.few => '$count места',
  _ => '$count места',
};

String _seatsLeftInSectionSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Преостало $count место',
      PickerPluralCategory.few => 'Преостала $count места',
      _ => 'Преостало $count места',
    };

String _holdLapsedStillFreeSr(int count) => switch (pickerPluralCategory(
  'sr',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша резервација је истекла док вас није било. То место је и даље слободно.',
  PickerPluralCategory.few =>
    'Ваша резервација је истекла док вас није било. Та места су и даље слободна.',
  _ =>
    'Ваша резервација је истекла док вас није било. Та места су и даље слободна.',
};

String _holdLapsedSomeTakenSr(int count) => switch (pickerPluralCategory(
  'sr',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша резервација је истекла док вас није било, а $count тих места је већ заузето. Остала су и даље слободна.',
  PickerPluralCategory.few =>
    'Ваша резервација је истекла док вас није било, а $count тих места су већ заузета. Остала су и даље слободна.',
  _ =>
    'Ваша резервација је истекла док вас није било, а $count тих места је већ заузето. Остала су и даље слободна.',
};

String _holdLapsedAllTakenSr(int count) => switch (pickerPluralCategory(
  'sr',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша резервација је истекла док вас није било, а то место је већ заузето.',
  PickerPluralCategory.few =>
    'Ваша резервација је истекла док вас није било, а та места су већ заузета.',
  _ =>
    'Ваша резервација је истекла док вас није било, а та места су већ заузета.',
};

String _accessibleSectionsSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => '$count сектор',
      PickerPluralCategory.few => '$count сектора',
      _ => '$count сектора',
    };

String _placesAvailableSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Тренутно је доступно $count место',
      PickerPluralCategory.few => 'Тренутно су доступна $count места',
      _ => 'Тренутно је доступно $count места',
    };

String _removeTicketsSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Уклони $count улазницу',
      PickerPluralCategory.few => 'Уклони $count улазнице',
      _ => 'Уклони $count улазница',
    };

String _holdMinutesLeftSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Преостао је $count минут',
      PickerPluralCategory.few => 'Преостала су $count минута',
      _ => 'Преостало је $count минута',
    };

String _holdSecondsLeftSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Преостала је $count секунда',
      PickerPluralCategory.few => 'Преостале су $count секунде',
      _ => 'Преостало је $count секунди',
    };

String _holdLapsedBodySr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => 'Била су резервисана $count минут.',
      PickerPluralCategory.few => 'Била су резервисана $count минута.',
      _ => 'Била су резервисана $count минута.',
    };

String _seatsNotRecoveredSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => '$count место није могло да се врати',
      PickerPluralCategory.few => '$count места нису могла да се врате',
      _ => '$count места није могло да се врати',
    };

String _activeFiltersSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => '$count филтер',
      PickerPluralCategory.few => '$count филтера',
      _ => '$count филтера',
    };

String _accessibilityFiltersActiveSr(int count) =>
    switch (pickerPluralCategory('sr', count)) {
      PickerPluralCategory.one => '$count активан филтер приступачности',
      PickerPluralCategory.few => '$count активна филтера приступачности',
      _ => '$count активних филтера приступачности',
    };

String _onlyLeftSr(int count) => switch (pickerPluralCategory('sr', count)) {
  PickerPluralCategory.one => 'Преостало $count место',
  PickerPluralCategory.few => 'Преостала $count места',
  _ => 'Преостало $count места',
};

String _continueWithTotalSr(String money) => 'Настави \u00b7 $money';

/// The `sr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSr = SeatLayerPickerStrings(
  close: 'Затвори',
  overview: 'Локација',
  backToVenue: 'Назад на објекат',
  cancel: 'Откажи',
  select: 'Изабери',
  removeSeat: 'Уклони место',
  viewFromHere: 'Поглед одавде',
  openVenue360: 'Отвори објекат у 360°',
  recentre: 'Поново центрирај на бину',
  viewFromYourSeat: 'поглед са вашег места',
  emptyTrayHint:
      'Додирните место на плану или препустите нама да изаберемо најбоља доступна.',
  anyTicketType: 'Било која врста улазнице',
  anyVenueZone: 'Било која зона објекта',
  bestSeats: 'Најбоља места',
  showLess: 'Прикажи мање',
  undo: 'Опозови',
  holdAndCheckout: 'Резервиши места и плати',
  poweredBy: 'Покреће SeatLayer',
  testMode: 'Тест режим',
  accessibility: 'Приступачност и боје',
  accessibilityTitle: 'Приступачност и боје',
  fitVenue: 'Прикажи цело место одржавања',
  fitWholeVenue: 'Прикажи цело место одржавања',
  loading: 'Учитавање плана места…',
  errorMessage: 'План места се није учитао',
  retry: 'Покушај поново',
  accessRefresh: 'Освежи',
  noSeatsSelected: 'Нема изабраних места',
  findBestSeatsCta: 'Пронађи најбоља места',
  organizerNote: 'Напомена организатора',
  accessiblePhysicalSeat: 'Приступачно физичко место',
  emptyWheelchairSpace: 'Слободно место за инвалидска колица',
  findSeatsTogether: 'Пронађи места једно уз друго',
  aboutBestSeats: 'О проналажењу седишта једно уз друго',
  closestGroupChosenInstantly: 'Најближа доступна група, изабрана одмах.',
  hideLimitedView: 'Сакриј места са ограниченим погледом',
  colorblindSafe: 'Боје прилагођене далтонизму',
  notAvailable: 'Није доступно',
  viewGroupTitle: 'ПРИКАЗ',
  restrictedView: 'Ограничен поглед',
  obstructedView: 'Заклоњен поглед',
  premiumSeat: 'Премијум место',
  continueWord: 'Настави',
  allFloors: 'Сви спратови',
  previousSection: 'Претходни сектор',
  nextSection: 'Следећи сектор',
  addSeat: 'Додај место',
  added: 'Додато',
  sectionWord: 'Сектор',
  rowWord: 'Ред',
  seatWord: 'Место',
  seeItIn3D: 'Погледај у 3D-у',
  viewFromThisSeat: 'Поглед са овог места',
  allPrices: 'Све цене',
  ticketPrices: 'Цене улазница',
  yourSeats: 'Ваша места',
  ticketType: 'Врста улазнице',
  tierCompanionGuidance: 'Захтева суседно место за инвалидска колица',
  findingBestSeats: 'Тражимо најбоља места…',
  findSeats: 'Пронађи места',
  expandCart: 'Отвори панел улазница',
  collapseCart: 'Скупи панел улазница',
  continueToCheckout: 'Настави на плаћање',
  secureMore: 'Обезбеди још',
  selectSeats: 'Изабери места',
  pickYourSeats: 'Изаберите своја места',
  salesClosedPill: 'Продаја је затворена',
  salesClosedCta: 'Продаја је затворена',
  confirmOrCancelSeat: 'Потврдите или откажите ово место',
  securingSeats: 'Обезбеђујемо ваша места…',
  openingCheckout: 'Отварамо безбедно плаћање…',
  testModeExplained: 'Резервације овде нису стварне и картица се не наплаћује',
  displayOptions: 'Опције приказа',
  companionSeatsNote: 'Суседна места за пратњу остају доступна за избор',
  zoomIn: 'Приближи',
  zoomOut: 'Удаљи',
  rotateVenue: 'Превуците да ротирате место одржавања',
  moveVenue: 'Превуците да померите место одржавања',
  mapView: 'План',
  flat2dMap: 'Равни 2D план',
  interactive3dVenueView: 'Интерактивни 3D приказ објекта',
  venueView: 'Приказ објекта',
  holdLapsedTitle: 'Ваша места су ослобођена',
  salesClosed: 'Продаја је затворена',
  salesClosedCopy: 'Продаја улазница за овај догађај је завршена.',
  salesClosedToast: 'Продаја за овај догађај је затворена.',
  soldOutEyebrow: 'Овај догађај',
  soldOutTitle: 'Распродато',
  soldOutCopy: 'Тренутно нема доступних нумерисаних места за овај догађај.',
  holdExpired:
      'Ваша резервација је истекла. Места су ослобођена. Изаберите поново.',
  addingEllipsis: 'Додавање…',
  moreTimeAdded: 'Додато је време. Ваша места су и даље резервисана.',
  couldNotAddMoreTime: 'Није било могуће додати време. Идите одмах на плаћање.',
  seatsJustTaken: 'Једно или више места је управо заузето. Изаберите поново.',
  allSetTitle: 'Све је спремно',
  confirmedAndOnWay: 'потврђено. Потврда је на путу.',
  backToMap: 'Назад на план',
  mapDidNotLoad: 'План места се није учитао',
  checkConnection: 'Проверите везу и покушајте поново.',
  accessPausedTitle: 'Ова места су тренутно блокирана',
  accessPausedCopy:
      'Организатор је паузирао овај избор. Покушајте поново за неколико минута.',
  accessRevokedTitle: 'Овај линк за приступ више није активан',
  accessRevokedCopy:
      'Затражите нови линк од особе која вам га је послала да наставите да резервишете ова места.',
  accessUnverifiedTitle: 'Нисмо могли да потврдимо ваш приступ',
  accessUnverifiedCopy:
      'И даље можете купити све што је приказано као доступно. За приступ осталом обратите се особи која вам је послала линк.',
  generalAdmission: 'Слободан улаз',
  numberOfGuests: 'Број гостију',
  chooseGuestsCopy:
      'Изаберите колико гостију седи заједно. Овај сто се резервише искључиво за ваше друштво.',
  fewerGuests: 'Мање гостију',
  moreGuests: 'Више гостију',
  selectTable: 'Изабери сто',
  updateTable: 'Ажурирај сто',
  removeWord: 'Уклони',
  floorWord: 'Спрат',
  totalWord: 'Укупно',
  adjustSelection: 'Прилагоди избор места',
  chooseSeats: 'Изаберите своја места',
  chooseTickets: 'Изаберите улазнице',
  placeWord: 'МЕСТО',
  ticketWord: 'Улазница',
  passport: 'Профил места',
  venue3D: '3D',
  venueZone: 'Зона објекта',
  venueMapHint:
      'Места се бирају контролама око плана: траком са ценама изнад њега, контролама сектора испод њега и панелом улазница на дну.',
  previousSeat: 'Претходно место',
  nextSeat: 'Следеће место',
  orbitMode: 'Ротирај објекат',
  panMode: 'Помери објекат',
  openInteractive3dVenue: 'Отвори интерактивни 3D приказ објекта',
  showSeatsFor: 'ПРИКАЖИ МЕСТА ЗА',
  accessJumpFirstSection: 'Иди на први сектор',
  accessJumpNextSection: 'Иди на следећи сектор',
  fewerTickets: 'Мање улазница',
  moreTickets: 'Више улазница',
  addTickets: 'Додај улазнице',
  noSelectableSeats: 'Тренутно нема доступних места за избор.',
  confirmYourTickets: 'Потврди улазнице',
  seatsSecuredOpeningCheckout: 'Места су обезбеђена. Отварамо плаћање…',
  holdInCheckoutTitle: 'Плаћање ваших места је већ у току',
  holdInCheckoutBody:
      'Завршите плаћање да бисте их задржали. Да бисте изабрали друга места, прво ослободите ова — враћају се у продају.',
  releaseAndChangeSeats: 'Ослободи и промени места',
  holdAlreadyHeldTitle: 'Ваша места су већ резервисана',
  holdAlreadyHeldBody: 'Наставите на плаћање да бисте их задржали.',
  accessExpiredTitle: 'Ваша сесија избора места је истекла',
  accessExpiredCopy:
      'Поново учитајте план места да бисте наставили. Места која су већ у вашој корпи остају резервисана док тајмер не истекне.',
  dismissError: 'Затвори обавештење о грешци',
  testModeLong: 'Тест режим · ништа се не резервише',
  seatRemoved: 'Улазница уклоњена',
  reloadSeatMap: 'Поново учитај план места',
  accessNeeds: <String, String>{
    'wheelchair': 'Место за колица',
    'companion': 'Место за пратњу',
    'semi-ambulatory': 'Ограничена покретљивост',
    'designated-aisle': 'Пролаз / преседање',
    'step-free': 'Без степеница',
    'hearing': 'Помоћ при слушању',
    'cart': 'Титлови уживо',
    'sign-language': 'Знаковни језик',
    'low-vision': 'Слабовидост',
    'sensory-friendly': 'Чулно прилагођено',
    'plus-size': 'Шире место',
    'lift-armrest': 'Наслон који се подиже',
  },
  seatsLeft: _seatsLeftSr,
  moreCount: _moreCountSr,
  addMinutes: _addMinutesSr,
  fromPrice: _fromPriceSr,
  sightline: _sightlineSr,
  secureMoreAndCheckout: _secureMoreAndCheckoutSr,
  accessFreeCount: _accessFreeCountSr,
  seatJustTakenByAnother: _seatJustTakenByAnotherSr,
  peekSecured: _peekSecuredSr,
  venueMap: _venueMapSr,
  accessibleStep: _accessibleStepSr,
  chooseMinMaxGuests: _chooseMinMaxGuestsSr,
  chooseMore: _chooseMoreSr,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeSr,
  accessNeedWithCount: _accessNeedWithCountSr,
  ticketCount: _ticketCountSr,
  findBestSeats: _findBestSeatsSr,
  reselectSeats: _reselectSeatsSr,
  seatsFree: _seatsFreeSr,
  seatsLeftInSection: _seatsLeftInSectionSr,
  holdLapsedStillFree: _holdLapsedStillFreeSr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenSr,
  holdLapsedAllTaken: _holdLapsedAllTakenSr,
  accessibleSections: _accessibleSectionsSr,
  placesAvailable: _placesAvailableSr,
  removeTickets: _removeTicketsSr,
  holdMinutesLeft: _holdMinutesLeftSr,
  holdSecondsLeft: _holdSecondsLeftSr,
  holdLapsedBody: _holdLapsedBodySr,
  seatsNotRecovered: _seatsNotRecoveredSr,
  activeFilters: _activeFiltersSr,
  accessibilityFiltersActive: _accessibilityFiltersActiveSr,
  onlyLeft: _onlyLeftSr,
  continueWithTotal: _continueWithTotalSr,
);
