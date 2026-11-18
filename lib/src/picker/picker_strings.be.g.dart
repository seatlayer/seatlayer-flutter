// GENERATED — do not edit.
//
// Source: design/locale_strings.json (be)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

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

String _peekSecuredBe(int count, String total) =>
    '✓ $count замацавана · $total. Спісання пакуль не будзе';

String _ticketCountBe(int count) =>
    count == 1 ? '$count білет' : '$count білета';

String _findBestSeatsBe(int count) =>
    count == 1 ? 'Знайсці $count лепшае месца' : 'Знайсці $count лепшага месца';

String _reselectSeatsBe(int count) =>
    count == 1 ? 'Выбраць яго зноў' : 'Выбраць іх зноў';

String _seatsFreeBe(int count) => count == 1 ? '$count месца' : '$count месца';

String _seatsLeftInSectionBe(int count) =>
    count == 1 ? 'Засталося $count месца' : 'Засталося $count месца';

String _holdLapsedStillFreeBe(int count) => count == 1
    ? 'Ваша браніраванне скончылася, пакуль вас не было. Гэтае месца яшчэ вольнае.'
    : 'Ваша браніраванне скончылася, пакуль вас не было. Гэтыя месцы яшчэ вольныя.';

String _holdLapsedSomeTakenBe(int count) => count == 1
    ? 'Ваша браніраванне скончылася, пакуль вас не было, і $count з гэтых месцаў ужо занятае. Астатнія яшчэ вольныя.'
    : 'Ваша браніраванне скончылася, пакуль вас не было, і $count з гэтых месцаў ужо занятыя. Астатнія яшчэ вольныя.';

String _holdLapsedAllTakenBe(int count) => count == 1
    ? 'Ваша браніраванне скончылася, пакуль вас не было, і гэтае месца ўжо занятае.'
    : 'Ваша браніраванне скончылася, пакуль вас не было, і гэтыя месцы ўжо занятыя.';

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
  testMode: 'ТЭСТАВЫ РЭЖЫМ',
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
  peekSecured: _peekSecuredBe,
  ticketCount: _ticketCountBe,
  findBestSeats: _findBestSeatsBe,
  reselectSeats: _reselectSeatsBe,
  seatsFree: _seatsFreeBe,
  seatsLeftInSection: _seatsLeftInSectionBe,
  holdLapsedStillFree: _holdLapsedStillFreeBe,
  holdLapsedSomeTaken: _holdLapsedSomeTakenBe,
  holdLapsedAllTaken: _holdLapsedAllTakenBe,
  continueWithTotal: _continueWithTotalBe,
);
