// GENERATED — do not edit.
//
// Source: design/locale_strings.json (be)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftBe(int count) => 'Засталося $count';

String _moreCountBe(int count) => '+$count яшчэ';

String _addMinutesBe(int minutes) => '+$minutes хв';

String _fromPriceBe(String money) => 'Ад $money';

String _sightlineBe(String metres) => '≈ $metres м да сцэны';

String _secureMoreAndCheckoutBe(int count) =>
    'Замацаваць яшчэ $count і аплаціць';

String _accessFreeCountBe(int count) => 'Вольна: $count';

String _seatJustTakenByAnotherBe(String label) =>
    'Месца $label толькі што заняў іншы пакупнік.';

String _labelNoLongerAvailableBe(String label) =>
    '$label больш недаступна. Выберыце іншае месца.';

String _labelsNoLongerAvailableBe(String labels) =>
    '$labels больш недаступныя. Выберыце іншую групу.';

String _couldNotFindSeatsTogetherBe(int count) =>
    'Мы не знайшлі $count месцаў побач. Паспрабуйце менш месцаў або іншы тып білета.';

String _maxTicketsForOrderBe(int count) =>
    'У гэтым заказе можна выбраць не больш за $count білетаў.';

String _couldNotRemoveLabelBe(String label) =>
    'Не ўдалося прыбраць $label. Броня засталася без змен.';

String _peekSecuredBe(int count, String total) =>
    '✓ $count замацавана · $total. Спісання пакуль не будзе';

String _venueMapBe(String venue) => '$venue: схема месцаў';

String _accessibleStepBe(int index, int total) => '$index з $total';

String _chooseMinMaxGuestsBe(int min, int max) =>
    'Выберыце ад $min да $max гасцей.';

String _chooseMoreBe(int count) => 'Выберыце яшчэ $count';

String _seatsHeldForNeedMoreTimeBe(String time) =>
    'Вашы месцы трымаюцца яшчэ $time. Патрэбна больш часу?';

String _accessNeedWithCountBe(String need, int count) => '$need · $count';

String _ticketCountBe(int count) => switch (pickerPluralCategory('be', count)) {
  PickerPluralCategory.one => '$count білет',
  PickerPluralCategory.few => '$count білеты',
  PickerPluralCategory.many => '$count білетаў',
  _ => '$count білета',
};

String _findBestSeatsBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Знайсці $count лепшае месца',
      PickerPluralCategory.few => 'Знайсці $count лепшыя месцы',
      PickerPluralCategory.many => 'Знайсці $count лепшых месцаў',
      _ => 'Знайсці $count лепшага месца',
    };

String _reselectSeatsBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Выбраць яго зноў',
      PickerPluralCategory.few => 'Выбраць іх зноў',
      PickerPluralCategory.many => 'Выбраць іх зноў',
      _ => 'Выбраць іх зноў',
    };

String _seatsFreeBe(int count) => switch (pickerPluralCategory('be', count)) {
  PickerPluralCategory.one => '$count месца',
  PickerPluralCategory.few => '$count месцы',
  PickerPluralCategory.many => '$count месцаў',
  _ => '$count месца',
};

String _seatsLeftInSectionBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Засталося $count месца',
      PickerPluralCategory.few => 'Засталося $count месцы',
      PickerPluralCategory.many => 'Засталося $count месцаў',
      _ => 'Засталося $count месца',
    };

String _holdLapsedStillFreeBe(int count) => switch (pickerPluralCategory(
  'be',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша браніраванне скончылася, пакуль вас не было. Гэтае месца яшчэ вольнае.',
  PickerPluralCategory.few =>
    'Ваша браніраванне скончылася, пакуль вас не было. Гэтыя месцы яшчэ вольныя.',
  PickerPluralCategory.many =>
    'Ваша браніраванне скончылася, пакуль вас не было. Гэтыя месцы яшчэ вольныя.',
  _ =>
    'Ваша браніраванне скончылася, пакуль вас не было. Гэтыя месцы яшчэ вольныя.',
};

String _holdLapsedSomeTakenBe(int count) => switch (pickerPluralCategory(
  'be',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша браніраванне скончылася, пакуль вас не было, і $count з гэтых месцаў ужо занятае. Астатнія яшчэ вольныя.',
  PickerPluralCategory.few =>
    'Ваша браніраванне скончылася, пакуль вас не было, і $count з гэтых месцаў ужо занятыя. Астатнія яшчэ вольныя.',
  PickerPluralCategory.many =>
    'Ваша браніраванне скончылася, пакуль вас не было, і $count з гэтых месцаў ужо занятыя. Астатнія яшчэ вольныя.',
  _ =>
    'Ваша браніраванне скончылася, пакуль вас не было, і $count з гэтых месцаў ужо занятыя. Астатнія яшчэ вольныя.',
};

String _holdLapsedAllTakenBe(int count) => switch (pickerPluralCategory(
  'be',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша браніраванне скончылася, пакуль вас не было, і гэтае месца ўжо занятае.',
  PickerPluralCategory.few =>
    'Ваша браніраванне скончылася, пакуль вас не было, і гэтыя месцы ўжо занятыя.',
  PickerPluralCategory.many =>
    'Ваша браніраванне скончылася, пакуль вас не было, і гэтыя месцы ўжо занятыя.',
  _ =>
    'Ваша браніраванне скончылася, пакуль вас не было, і гэтыя месцы ўжо занятыя.',
};

String _accessibleSectionsBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => '$count сектар',
      PickerPluralCategory.few => '$count сектары',
      PickerPluralCategory.many => '$count сектараў',
      _ => '$count сектара',
    };

String _placesAvailableBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Цяпер даступна $count месца',
      PickerPluralCategory.few => 'Цяпер даступна $count месцы',
      PickerPluralCategory.many => 'Цяпер даступна $count месцаў',
      _ => 'Цяпер даступна $count месца',
    };

String _removeTicketsBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Выдаліць $count білет',
      PickerPluralCategory.few => 'Выдаліць $count білеты',
      PickerPluralCategory.many => 'Выдаліць $count білетаў',
      _ => 'Выдаліць $count білета',
    };

String _holdMinutesLeftBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Засталася $count хвіліна',
      PickerPluralCategory.few => 'Засталося $count хвіліны',
      PickerPluralCategory.many => 'Засталося $count хвілін',
      _ => 'Засталося $count хвіліны',
    };

String _holdSecondsLeftBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Засталася $count секунда',
      PickerPluralCategory.few => 'Засталося $count секунды',
      PickerPluralCategory.many => 'Засталося $count секунд',
      _ => 'Засталося $count секунды',
    };

String _holdLapsedBodyBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Іх трымалі $count хвіліну.',
      PickerPluralCategory.few => 'Іх трымалі $count хвіліны.',
      PickerPluralCategory.many => 'Іх трымалі $count хвілін.',
      _ => 'Іх трымалі $count хвіліны.',
    };

String _seatsNotRecoveredBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => '$count месца не ўдалося вярнуць',
      PickerPluralCategory.few => '$count месцы не ўдалося вярнуць',
      PickerPluralCategory.many => '$count месцаў не ўдалося вярнуць',
      _ => '$count месца не ўдалося вярнуць',
    };

String _activeFiltersBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => '$count фільтр',
      PickerPluralCategory.few => '$count фільтры',
      PickerPluralCategory.many => '$count фільтраў',
      _ => '$count фільтра',
    };

String _accessibilityFiltersActiveBe(int count) =>
    switch (pickerPluralCategory('be', count)) {
      PickerPluralCategory.one => 'Уключаны $count фільтр даступнасці',
      PickerPluralCategory.few => 'Уключаныя $count фільтры даступнасці',
      PickerPluralCategory.many => 'Уключана $count фільтраў даступнасці',
      _ => 'Уключана $count фільтра даступнасці',
    };

String _onlyLeftBe(int count) => switch (pickerPluralCategory('be', count)) {
  PickerPluralCategory.one => 'Засталося $count месца',
  PickerPluralCategory.few => 'Засталося $count месцы',
  PickerPluralCategory.many => 'Засталося $count месцаў',
  _ => 'Засталося $count месца',
};

String _maintenancePausedBe(int count) => switch (pickerPluralCategory(
  'be',
  count,
)) {
  PickerPluralCategory.one =>
    'Браніраванне прыпынена на тэхнічнае абслугоўванне. Паспрабуйце зноў прыкладна праз $count хвіліну.',
  PickerPluralCategory.few =>
    'Браніраванне прыпынена на тэхнічнае абслугоўванне. Паспрабуйце зноў прыкладна праз $count хвіліны.',
  PickerPluralCategory.many =>
    'Браніраванне прыпынена на тэхнічнае абслугоўванне. Паспрабуйце зноў прыкладна праз $count хвілін.',
  _ =>
    'Браніраванне прыпынена на тэхнічнае абслугоўванне. Паспрабуйце зноў прыкладна праз $count хвіліны.',
};

String _continueWithTotalBe(String money) => 'Працягнуць \u00b7 $money';

/// The `be` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsBe = SeatLayerPickerStrings(
  close: 'Закрыць',
  overview: 'Пляцоўка',
  backToVenue: 'Назад да пляцоўкі',
  cancel: 'Скасаваць',
  select: 'Выбраць',
  removeSeat: 'Выдаліць месца',
  viewFromHere: 'Від адсюль',
  openVenue360: 'Адкрыць пляцоўку ў 360°',
  recentre: 'Зноў навесці на сцэну',
  viewFromYourSeat: 'выгляд з вашага месца',
  emptyTrayHint:
      'Націсніце на месца на схеме або даверце нам выбраць лепшыя даступныя.',
  anyTicketType: 'Любы тып білета',
  anyVenueZone: 'Любая зона пляцоўкі',
  bestSeats: 'Лепшыя месцы',
  showLess: 'Паказаць менш',
  undo: 'Адрабіць',
  holdAndCheckout: 'Забраніраваць месцы і аплаціць',
  poweredBy: 'Працуе на SeatLayer',
  testMode: 'Тэставы рэжым',
  accessibility: 'Даступнасць і колеры',
  accessibilityTitle: 'Даступнасць і колеры',
  fitVenue: 'Паказаць усю пляцоўку',
  fitWholeVenue: 'Паказаць усю пляцоўку',
  loading: 'Загружаем схему месцаў…',
  errorMessage: 'Схема месцаў не загрузілася',
  retry: 'Паспрабаваць зноў',
  accessRefresh: 'Абнавіць',
  noSeatsSelected: 'Месцы не выбраны',
  findBestSeatsCta: 'Знайсці лепшыя месцы',
  organizerNote: 'Нататка арганізатара',
  accessiblePhysicalSeat: 'Даступнае фізічнае месца',
  emptyWheelchairSpace: 'Вольнае месца для калянкі',
  findSeatsTogether: 'Знайсці месцы побач',
  aboutBestSeats: 'Пра пошук месцаў побач',
  closestGroupChosenInstantly:
      'Найбліжэйшая даступная група, выбрана імгненна.',
  hideLimitedView: 'Схаваць месцы з абмежаваным аглядам',
  colorblindSafe: 'Колеры для дальтонікаў',
  notAvailable: 'Недаступна',
  viewGroupTitle: 'ВЫГЛЯД',
  restrictedView: 'Абмежаваны агляд',
  obstructedView: 'Агляд перакрыты',
  premiumSeat: 'Прэміяльнае месца',
  continueWord: 'Працягнуць',
  allFloors: 'Усе паверхі',
  previousSection: 'Папярэдні сектар',
  nextSection: 'Наступны сектар',
  addSeat: 'Дадаць месца',
  added: 'Дададзена',
  sectionWord: 'Сектар',
  rowWord: 'Рад',
  seatWord: 'Месца',
  seeItIn3D: 'Паглядзець у 3D',
  viewFromThisSeat: 'Від з гэтага месца',
  allPrices: 'Усе цэны',
  ticketPrices: 'Цэны білетаў',
  yourSeats: 'Вашы месцы',
  ticketType: 'Тып білета',
  tierCompanionGuidance: 'Патрабуецца суседняе месца для калянкі',
  findingBestSeats: 'Шукаем лепшыя месцы…',
  findSeats: 'Знайсці месцы',
  expandCart: 'Адкрыць панэль білетаў',
  collapseCart: 'Згарнуць панэль білетаў',
  continueToCheckout: 'Перайсці да аплаты',
  secureMore: 'Замацаваць яшчэ',
  selectSeats: 'Выбраць месцы',
  pickYourSeats: 'Выберыце свае месцы',
  salesClosedPill: 'Продаж закрыты',
  salesClosedCta: 'Продаж закрыты',
  confirmOrCancelSeat: 'Пацвердзіце або скасуйце гэтае месца',
  securingSeats: 'Замацоўваем вашы месцы…',
  openingCheckout: 'Адкрываем абаронены плацёж…',
  testModeExplained: 'Браніраванні тут несапраўдныя, і карта не спісваецца',
  displayOptions: 'Параметры адлюстравання',
  companionSeatsNote: 'Суседнія месцы для суправаджэння застаюцца даступнымі',
  zoomIn: 'Наблізіць',
  zoomOut: 'Аддаліць',
  rotateVenue: 'Перацягніце, каб павярнуць пляцоўку',
  moveVenue: 'Перацягніце, каб перамясціць пляцоўку',
  mapView: 'Схема',
  flat2dMap: 'Плоская схема 2D',
  interactive3dVenueView: 'Інтэрактыўны 3D-выгляд пляцоўкі',
  venueView: 'Выгляд пляцоўкі',
  holdLapsedTitle: 'Вашы месцы вызвалены',
  salesClosed: 'Продаж закрыты',
  salesClosedCopy: 'Продаж білетаў на гэтую падзею завершаны.',
  salesClosedToast: 'Продаж на гэтую падзею закрыты.',
  soldOutEyebrow: 'Гэтая падзея',
  soldOutTitle: 'Усё прададзена',
  soldOutCopy: 'Зараз на гэтую падзею няма вольных нумараваных месцаў.',
  holdExpired:
      'Тэрмін вашай брані скончыўся. Месцы вызвалены. Выберыце нанова.',
  addingEllipsis: 'Дадаём…',
  moreTimeAdded: 'Час падоўжаны. Вашы месцы па-ранейшаму забраніраваны.',
  couldNotAddMoreTime: 'Не ўдалося падоўжыць час. Перайдзіце да аплаты зараз.',
  seatsJustTaken:
      'Адно або некалькі месцаў толькі што занялі. Выберыце нанова.',
  ticketTypeSoldOut: 'Гэты тып білета распрададзены. Паспрабуйце іншы тып.',
  seatsNoLongerAvailableTryAnother:
      'Гэтыя месцы больш недаступныя. Паспрабуйце іншую колькасць або тып білета.',
  companionPairRequired:
      'Да кожнага білета суправаджальніка выберыце суседняе месца для калянкі.',
  ticketOptionNotApplicable:
      'Гэты варыянт білета недаступны для выбранага месца.',
  maintenancePausedShortly:
      'Браніраванне прыпынена на некалькі хвілін для тэхнічнага абслугоўвання. Паспрабуйце зноў крыху пазней.',
  guestsOnly: 'Гэтая падзея для запрошаных гасцей.',
  guestChoiceClosed: 'Выбар месцаў зараз недаступны.',
  maxOneTicketForOrder: 'У гэтым заказе можна выбраць не больш за 1 білет.',
  tooManyAttempts: 'Занадта шмат спроб. Пачакайце крыху і паспрабуйце зноў.',
  seatHeldForRenewal:
      'Адно з гэтых месцаў замацавана за ўладальнікам абанемента, які яшчэ можа яго падоўжыць. Выберыце іншае месца.',
  seatUnavailable: 'Гэта месца недаступна.',
  eventUnavailable: 'Зараз тут нельга забраніраваць білеты.',
  savedSeatsNotRestored:
      'Не ўдалося аднавіць вашы папярэднія месцы. Калі ласка, выберыце зноў.',
  allSetTitle: 'Усё гатова',
  confirmedAndOnWay: 'пацверджана. Пацвярджэнне ўжо ў дарозе.',
  backToMap: 'Назад да схемы',
  mapDidNotLoad: 'Схема месцаў не загрузілася',
  checkConnection: 'Праверце злучэнне і паспрабуйце зноў.',
  accessPausedTitle: 'Гэтыя месцы зараз заблакаваны',
  accessPausedCopy:
      'Арганізатар прыпыніў гэты выбар. Паспрабуйце праз некалькі хвілін.',
  accessRevokedTitle: 'Гэтая спасылка доступу больш не дзейнічае',
  accessRevokedCopy:
      'Папрасіце новую спасылку ў таго, хто даслаў вам гэтую, каб працягнуць браніраваць гэтыя месцы.',
  accessUnverifiedTitle: 'Не ўдалося пацвердзіць ваш доступ',
  accessUnverifiedCopy:
      'Вы па-ранейшаму можаце купіць усё, што паказана як даступнае. Па доступ да астатняга звярніцеся да таго, хто даслаў вам спасылку.',
  generalAdmission: 'Вольная рассадка',
  numberOfGuests: 'Колькасць гасцей',
  chooseGuestsCopy:
      'Выберыце, колькі гасцей сядзе разам. Гэты стол браніруецца толькі для вашай кампаніі.',
  fewerGuests: 'Менш гасцей',
  moreGuests: 'Больш гасцей',
  selectTable: 'Выбраць стол',
  updateTable: 'Абнавіць стол',
  removeWord: 'Прыбраць',
  floorWord: 'Паверх',
  totalWord: 'Разам',
  adjustSelection: 'Змяніць выбар месцаў',
  backToSeatMap: 'Назад да схемы месцаў',
  chooseSeats: 'Выберыце свае месцы',
  chooseTickets: 'Выберыце білеты',
  placeWord: 'МЕСЦА',
  guestsWord: 'Госці',
  tableWord: 'Стол',
  ticketWord: 'Білет',
  passport: 'Картка месца',
  venue3D: '3D',
  venueZone: 'Зона пляцоўкі',
  venueMapHint:
      'Месцы выбіраюць з дапамогай элементаў кіравання вакол схемы: паласа цэн над ёй, кіраванне сектарамі пад ёй і панэль білетаў унізе.',
  previousSeat: 'Папярэдняе месца',
  nextSeat: 'Наступнае месца',
  orbitMode: 'Павярнуць пляцоўку',
  panMode: 'Перамясціць пляцоўку',
  openInteractive3dVenue: 'Адкрыць інтэрактыўны 3D-выгляд пляцоўкі',
  showSeatsFor: 'ПАКАЗАЦЬ МЕСЦЫ:',
  accessJumpFirstSection: 'Перайсці да першага сектара',
  accessJumpNextSection: 'Перайсці да наступнага сектара',
  fewerTickets: 'Менш білетаў',
  moreTickets: 'Больш білетаў',
  addTickets: 'Дадаць білеты',
  noSelectableSeats: 'Цяпер няма месцаў, даступных для выбару.',
  confirmYourTickets: 'Пацвердзіце свае білеты',
  seatsSecuredOpeningCheckout: 'Месцы замацаваны. Адкрываем аплату…',
  holdInCheckoutTitle: 'Вашы месцы ўжо ў працэсе аплаты',
  holdInCheckoutBody:
      'Завяршыце аплату, каб захаваць іх. Каб выбраць іншыя месцы, спачатку вызваліце гэтыя — яны вернуцца ў продаж.',
  releaseAndChangeSeats: 'Вызваліць і змяніць месцы',
  holdAlreadyHeldTitle: 'Вашы месцы ўжо трымаюцца за вамі',
  holdAlreadyHeldBody: 'Перайдзіце да аплаты, каб захаваць іх.',
  accessExpiredTitle: 'Ваш сеанс выбару месцаў завяршыўся',
  accessExpiredCopy:
      'Абнавіце схему месцаў, каб працягнуць. Месцы, якія ўжо ў кошыку, застаюцца за вамі, пакуль не скончыцца таймер.',
  dismissError: 'Закрыць паведамленне пра памылку',
  testModeLong: 'Тэставы рэжым · нічога не браніруецца',
  seatRemoved: 'Білет прыбраны',
  reloadSeatMap: 'Абнавіць схему месцаў',
  accessNeeds: <String, String>{
    'wheelchair': 'Месца для калянкі',
    'companion': 'Месца суправаджэння',
    'semi-ambulatory': 'Абмежаваная рухомасць',
    'designated-aisle': 'Праход / перасадка',
    'step-free': 'Без прыступак',
    'hearing': 'Падтрымка слыху',
    'cart': 'Жывыя субцітры',
    'sign-language': 'Жэставая мова',
    'low-vision': 'Слабы зрок',
    'sensory-friendly': 'Сенсорна камфортныя',
    'plus-size': 'Пашыранае месца',
    'lift-armrest': 'Падымальны падлакотнік',
  },
  seatsLeft: _seatsLeftBe,
  moreCount: _moreCountBe,
  addMinutes: _addMinutesBe,
  fromPrice: _fromPriceBe,
  sightline: _sightlineBe,
  secureMoreAndCheckout: _secureMoreAndCheckoutBe,
  accessFreeCount: _accessFreeCountBe,
  seatJustTakenByAnother: _seatJustTakenByAnotherBe,
  labelNoLongerAvailable: _labelNoLongerAvailableBe,
  labelsNoLongerAvailable: _labelsNoLongerAvailableBe,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherBe,
  maxTicketsForOrder: _maxTicketsForOrderBe,
  couldNotRemoveLabel: _couldNotRemoveLabelBe,
  peekSecured: _peekSecuredBe,
  venueMap: _venueMapBe,
  accessibleStep: _accessibleStepBe,
  chooseMinMaxGuests: _chooseMinMaxGuestsBe,
  chooseMore: _chooseMoreBe,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeBe,
  accessNeedWithCount: _accessNeedWithCountBe,
  ticketCount: _ticketCountBe,
  findBestSeats: _findBestSeatsBe,
  reselectSeats: _reselectSeatsBe,
  seatsFree: _seatsFreeBe,
  seatsLeftInSection: _seatsLeftInSectionBe,
  holdLapsedStillFree: _holdLapsedStillFreeBe,
  holdLapsedSomeTaken: _holdLapsedSomeTakenBe,
  holdLapsedAllTaken: _holdLapsedAllTakenBe,
  accessibleSections: _accessibleSectionsBe,
  placesAvailable: _placesAvailableBe,
  removeTickets: _removeTicketsBe,
  holdMinutesLeft: _holdMinutesLeftBe,
  holdSecondsLeft: _holdSecondsLeftBe,
  holdLapsedBody: _holdLapsedBodyBe,
  seatsNotRecovered: _seatsNotRecoveredBe,
  activeFilters: _activeFiltersBe,
  accessibilityFiltersActive: _accessibilityFiltersActiveBe,
  onlyLeft: _onlyLeftBe,
  maintenancePaused: _maintenancePausedBe,
  continueWithTotal: _continueWithTotalBe,
);
