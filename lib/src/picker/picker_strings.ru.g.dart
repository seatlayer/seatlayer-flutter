// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ru)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftRu(int count) => 'Осталось $count';

String _moreCountRu(int count) => '+$count ещё';

String _addMinutesRu(int minutes) => '+$minutes мин';

String _fromPriceRu(String money) => 'От $money';

String _sightlineRu(String metres) => '≈ $metres м до сцены';

String _secureMoreAndCheckoutRu(int count) => 'Закрепить ещё $count и оплатить';

String _accessFreeCountRu(int count) => 'Свободно: $count';

String _seatJustTakenByAnotherRu(String label) =>
    'Место $label только что занял другой покупатель.';

String _peekSecuredRu(int count, String total) =>
    '✓ $count закреплено · $total. Списания пока не будет';

String _ticketCountRu(int count) =>
    count == 1 ? '$count билет' : '$count билета';

String _findBestSeatsRu(int count) =>
    count == 1 ? 'Найти $count лучшее место' : 'Найти $count лучших места';

String _reselectSeatsRu(int count) =>
    count == 1 ? 'Выбрать его снова' : 'Выбрать их снова';

String _seatsFreeRu(int count) => count == 1 ? '$count место' : '$count места';

String _seatsLeftInSectionRu(int count) =>
    count == 1 ? 'Осталось $count место' : 'Осталось $count места';

String _holdLapsedStillFreeRu(int count) => count == 1
    ? 'Ваша бронь истекла, пока вас не было. Это место всё ещё свободно.'
    : 'Ваша бронь истекла, пока вас не было. Эти места всё ещё свободны.';

String _holdLapsedSomeTakenRu(int count) => count == 1
    ? 'Ваша бронь истекла, пока вас не было, и $count из этих мест уже занято. Остальные всё ещё свободны.'
    : 'Ваша бронь истекла, пока вас не было, и $count из этих мест уже занято. Остальные всё ещё свободны.';

String _holdLapsedAllTakenRu(int count) => count == 1
    ? 'Ваша бронь истекла, пока вас не было, и это место уже занято.'
    : 'Ваша бронь истекла, пока вас не было, и эти места уже заняты.';

String _continueWithTotalRu(String money) => 'Продолжить \u00b7 $money';

/// The `ru` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsRu = SeatLayerPickerStrings(
  close: 'Закрыть',
  overview: 'Площадка',
  backToVenue: 'Назад к площадке',
  cancel: 'Отмена',
  select: 'Выбрать',
  removeSeat: 'Удалить место',
  viewFromHere: 'Вид отсюда',
  openVenue360: 'Открыть площадку в 360°',
  recentre: 'Снова навести на сцену',
  viewFromYourSeat: 'вид с вашего места',
  emptyTrayHint:
      'Нажмите на место на схеме или доверьте нам выбрать лучшие доступные.',
  anyTicketType: 'Любой тип билета',
  anyVenueZone: 'Любая зона площадки',
  bestSeats: 'Лучшие места',
  showLess: 'Показать меньше',
  undo: 'Отменить',
  holdAndCheckout: 'Забронировать места и оплатить',
  poweredBy: 'Работает на SeatLayer',
  testMode: 'ТЕСТОВЫЙ РЕЖИМ',
  accessibility: 'Доступность и цвета',
  accessibilityTitle: 'Доступность и цвета',
  fitVenue: 'Показать всю площадку',
  fitWholeVenue: 'Показать всю площадку',
  loading: 'Загружаем схему мест…',
  errorMessage: 'Схема мест не загрузилась',
  retry: 'Попробовать снова',
  accessRefresh: 'Обновить',
  noSeatsSelected: 'Места не выбраны',
  findBestSeatsCta: 'Найти лучшие места',
  organizerNote: 'Заметка организатора',
  accessiblePhysicalSeat: 'Доступное физическое место',
  emptyWheelchairSpace: 'Свободное место для коляски',
  findSeatsTogether: 'Найти места рядом',
  aboutBestSeats: 'О поиске мест рядом',
  closestGroupChosenInstantly: 'Ближайшая доступная группа, выбрана мгновенно.',
  hideLimitedView: 'Скрыть места с ограниченным обзором',
  colorblindSafe: 'Цвета для дальтоников',
  notAvailable: 'Недоступно',
  restrictedView: 'Ограниченный обзор',
  obstructedView: 'Обзор перекрыт',
  premiumSeat: 'Премиальное место',
  continueWord: 'Продолжить',
  allFloors: 'Все этажи',
  previousSection: 'Предыдущий сектор',
  nextSection: 'Следующий сектор',
  addSeat: 'Добавить место',
  added: 'Добавлено',
  sectionWord: 'Сектор',
  rowWord: 'Ряд',
  seatWord: 'Место',
  seeItIn3D: 'Посмотреть в 3D',
  viewFromThisSeat: 'Вид с этого места',
  allPrices: 'Все цены',
  ticketType: 'Тип билета',
  tierCompanionGuidance: 'Требуется соседнее место для коляски',
  findingBestSeats: 'Ищем лучшие места…',
  findSeats: 'Найти места',
  expandCart: 'Открыть панель билетов',
  collapseCart: 'Свернуть панель билетов',
  continueToCheckout: 'Перейти к оплате',
  secureMore: 'Закрепить ещё',
  selectSeats: 'Выбрать места',
  pickYourSeats: 'Выберите свои места',
  salesClosedPill: 'Продажи закрыты',
  salesClosedCta: 'Продажи закрыты',
  confirmOrCancelSeat: 'Подтвердите или отмените это место',
  securingSeats: 'Закрепляем ваши места…',
  openingCheckout: 'Открываем защищённую оплату…',
  testModeExplained:
      'Бронирования здесь ненастоящие, списания с карты не будет',
  displayOptions: 'Параметры отображения',
  companionSeatsNote: 'Соседние места для сопровождающего остаются доступными',
  zoomIn: 'Приблизить',
  zoomOut: 'Отдалить',
  rotateVenue: 'Перетащите, чтобы повернуть площадку',
  moveVenue: 'Перетащите, чтобы переместить площадку',
  mapView: 'Схема',
  flat2dMap: 'Плоская схема 2D',
  interactive3dVenueView: 'Интерактивный 3D-вид площадки',
  venueView: 'Вид площадки',
  holdLapsedTitle: 'Ваши места освобождены',
  salesClosed: 'Продажи закрыты',
  salesClosedCopy: 'Продажа билетов на это мероприятие завершена.',
  salesClosedToast: 'Продажи на это мероприятие закрыты.',
  soldOutEyebrow: 'Это мероприятие',
  soldOutTitle: 'Всё продано',
  soldOutCopy: 'Сейчас на это мероприятие нет свободных нумерованных мест.',
  holdExpired: 'Срок брони истёк. Места освобождены. Выберите заново.',
  addingEllipsis: 'Добавляем…',
  moreTimeAdded: 'Время продлено. Ваши места по-прежнему забронированы.',
  couldNotAddMoreTime: 'Не удалось продлить время. Перейдите к оплате сейчас.',
  seatsJustTaken: 'Одно или несколько мест только что заняли. Выберите заново.',
  allSetTitle: 'Всё готово',
  confirmedAndOnWay: 'подтверждено. Подтверждение уже в пути.',
  backToMap: 'Назад к схеме',
  mapDidNotLoad: 'Схема мест не загрузилась',
  checkConnection: 'Проверьте соединение и попробуйте снова.',
  accessPausedTitle: 'Эти места сейчас заблокированы',
  accessPausedCopy:
      'Организатор приостановил этот выбор. Попробуйте через несколько минут.',
  accessRevokedTitle: 'Эта ссылка доступа больше не действует',
  accessRevokedCopy:
      'Попросите новую ссылку у того, кто прислал вам эту, чтобы продолжить бронировать эти места.',
  accessUnverifiedTitle: 'Не удалось подтвердить ваш доступ',
  accessUnverifiedCopy:
      'Вы по-прежнему можете купить всё, что показано как доступное. За доступом к остальному обратитесь к тому, кто прислал вам ссылку.',
  generalAdmission: 'Свободная рассадка',
  numberOfGuests: 'Количество гостей',
  chooseGuestsCopy:
      'Выберите, сколько гостей сядет вместе. Этот стол бронируется только для вашей компании.',
  fewerGuests: 'Меньше гостей',
  moreGuests: 'Больше гостей',
  selectTable: 'Выбрать стол',
  updateTable: 'Обновить стол',
  removeWord: 'Убрать',
  floorWord: 'Этаж',
  totalWord: 'Итого',
  accessNeeds: <String, String>{
    'wheelchair': 'Место для коляски',
    'companion': 'Место сопровождающего',
    'semi-ambulatory': 'Ограниченная подвижность',
    'designated-aisle': 'Проход / пересадка',
    'step-free': 'Без ступеней',
    'hearing': 'Поддержка слуха',
    'cart': 'Субтитры в реальном времени',
    'sign-language': 'Жестовый язык',
    'low-vision': 'Слабое зрение',
    'sensory-friendly': 'Сенсорно комфортное',
    'plus-size': 'Расширенное место',
    'lift-armrest': 'Поднимающийся подлокотник',
  },
  seatsLeft: _seatsLeftRu,
  moreCount: _moreCountRu,
  addMinutes: _addMinutesRu,
  fromPrice: _fromPriceRu,
  sightline: _sightlineRu,
  secureMoreAndCheckout: _secureMoreAndCheckoutRu,
  accessFreeCount: _accessFreeCountRu,
  seatJustTakenByAnother: _seatJustTakenByAnotherRu,
  peekSecured: _peekSecuredRu,
  ticketCount: _ticketCountRu,
  findBestSeats: _findBestSeatsRu,
  reselectSeats: _reselectSeatsRu,
  seatsFree: _seatsFreeRu,
  seatsLeftInSection: _seatsLeftInSectionRu,
  holdLapsedStillFree: _holdLapsedStillFreeRu,
  holdLapsedSomeTaken: _holdLapsedSomeTakenRu,
  holdLapsedAllTaken: _holdLapsedAllTakenRu,
  continueWithTotal: _continueWithTotalRu,
);
