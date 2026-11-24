// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ru)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableRu(String label) =>
    '$label больше недоступно. Выберите другое место.';

String _labelsNoLongerAvailableRu(String labels) =>
    '$labels больше недоступны. Выберите другую группу.';

String _couldNotFindSeatsTogetherRu(int count) =>
    'Не нашли $count мест рядом. Попробуйте меньше мест или другой тип билета.';

String _couldNotRemoveLabelRu(String label) =>
    'Не удалось убрать $label. Бронь осталась без изменений.';

String _peekSecuredRu(int count, String total) =>
    '✓ $count закреплено · $total. Списания пока не будет';

String _venueMapRu(String venue) => '$venue: схема мест';

String _accessibleStepRu(int index, int total) => '$index из $total';

String _chooseMinMaxGuestsRu(int min, int max) =>
    'Выберите от $min до $max гостей.';

String _chooseMoreRu(int count) => 'Выберите ещё $count';

String _seatsHeldForNeedMoreTimeRu(String time) =>
    'Ваши места удерживаются ещё $time. Нужно больше времени?';

String _accessNeedWithCountRu(String need, int count) => '$need · $count';

String _ticketCountRu(int count) => switch (pickerPluralCategory('ru', count)) {
  PickerPluralCategory.one => '$count билет',
  PickerPluralCategory.few => '$count билета',
  PickerPluralCategory.many => '$count билетов',
  _ => '$count билета',
};

String _findBestSeatsRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Найти $count лучшее место',
      PickerPluralCategory.few => 'Найти $count лучших места',
      PickerPluralCategory.many => 'Найти $count лучших мест',
      _ => 'Найти $count лучших места',
    };

String _reselectSeatsRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Выбрать его снова',
      PickerPluralCategory.few => 'Выбрать их снова',
      PickerPluralCategory.many => 'Выбрать их снова',
      _ => 'Выбрать их снова',
    };

String _seatsFreeRu(int count) => switch (pickerPluralCategory('ru', count)) {
  PickerPluralCategory.one => '$count место',
  PickerPluralCategory.few => '$count места',
  PickerPluralCategory.many => '$count мест',
  _ => '$count места',
};

String _seatsLeftInSectionRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Осталось $count место',
      PickerPluralCategory.few => 'Осталось $count места',
      PickerPluralCategory.many => 'Осталось $count мест',
      _ => 'Осталось $count места',
    };

String _holdLapsedStillFreeRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one =>
        'Ваша бронь истекла, пока вас не было. Это место всё ещё свободно.',
      PickerPluralCategory.few =>
        'Ваша бронь истекла, пока вас не было. Эти места всё ещё свободны.',
      PickerPluralCategory.many =>
        'Ваша бронь истекла, пока вас не было. Эти места всё ещё свободны.',
      _ => 'Ваша бронь истекла, пока вас не было. Эти места всё ещё свободны.',
    };

String _holdLapsedSomeTakenRu(int count) => switch (pickerPluralCategory(
  'ru',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваша бронь истекла, пока вас не было, и $count из этих мест уже занято. Остальные всё ещё свободны.',
  PickerPluralCategory.few =>
    'Ваша бронь истекла, пока вас не было, и $count из этих мест уже заняты. Остальные всё ещё свободны.',
  PickerPluralCategory.many =>
    'Ваша бронь истекла, пока вас не было, и $count из этих мест уже занято. Остальные всё ещё свободны.',
  _ =>
    'Ваша бронь истекла, пока вас не было, и $count из этих мест уже занято. Остальные всё ещё свободны.',
};

String _holdLapsedAllTakenRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one =>
        'Ваша бронь истекла, пока вас не было, и это место уже занято.',
      PickerPluralCategory.few =>
        'Ваша бронь истекла, пока вас не было, и эти места уже заняты.',
      PickerPluralCategory.many =>
        'Ваша бронь истекла, пока вас не было, и эти места уже заняты.',
      _ => 'Ваша бронь истекла, пока вас не было, и эти места уже заняты.',
    };

String _accessibleSectionsRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => '$count сектор',
      PickerPluralCategory.few => '$count сектора',
      PickerPluralCategory.many => '$count секторов',
      _ => '$count сектора',
    };

String _placesAvailableRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Сейчас доступно $count место',
      PickerPluralCategory.few => 'Сейчас доступно $count места',
      PickerPluralCategory.many => 'Сейчас доступно $count мест',
      _ => 'Сейчас доступно $count места',
    };

String _removeTicketsRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Удалить $count билет',
      PickerPluralCategory.few => 'Удалить $count билета',
      PickerPluralCategory.many => 'Удалить $count билетов',
      _ => 'Удалить $count билета',
    };

String _holdMinutesLeftRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Осталась $count минута',
      PickerPluralCategory.few => 'Осталось $count минуты',
      PickerPluralCategory.many => 'Осталось $count минут',
      _ => 'Осталось $count минуты',
    };

String _holdSecondsLeftRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Осталась $count секунда',
      PickerPluralCategory.few => 'Осталось $count секунды',
      PickerPluralCategory.many => 'Осталось $count секунд',
      _ => 'Осталось $count секунды',
    };

String _holdLapsedBodyRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Они удерживались $count минуту.',
      PickerPluralCategory.few => 'Они удерживались $count минуты.',
      PickerPluralCategory.many => 'Они удерживались $count минут.',
      _ => 'Они удерживались $count минуты.',
    };

String _seatsNotRecoveredRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => '$count место не удалось вернуть',
      PickerPluralCategory.few => '$count места не удалось вернуть',
      PickerPluralCategory.many => '$count мест не удалось вернуть',
      _ => '$count места не удалось вернуть',
    };

String _activeFiltersRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => '$count фильтр',
      PickerPluralCategory.few => '$count фильтра',
      PickerPluralCategory.many => '$count фильтров',
      _ => '$count фильтра',
    };

String _accessibilityFiltersActiveRu(int count) =>
    switch (pickerPluralCategory('ru', count)) {
      PickerPluralCategory.one => 'Включён $count фильтр доступности',
      PickerPluralCategory.few => 'Включено $count фильтра доступности',
      PickerPluralCategory.many => 'Включено $count фильтров доступности',
      _ => 'Включено $count фильтра доступности',
    };

String _onlyLeftRu(int count) => switch (pickerPluralCategory('ru', count)) {
  PickerPluralCategory.one => 'Осталось $count место',
  PickerPluralCategory.few => 'Осталось $count места',
  PickerPluralCategory.many => 'Осталось $count мест',
  _ => 'Осталось $count места',
};

String _maintenancePausedRu(int count) => switch (pickerPluralCategory(
  'ru',
  count,
)) {
  PickerPluralCategory.one =>
    'Бронирование приостановлено на время технических работ. Попробуйте снова примерно через $count минуту.',
  PickerPluralCategory.few =>
    'Бронирование приостановлено на время технических работ. Попробуйте снова примерно через $count минуты.',
  PickerPluralCategory.many =>
    'Бронирование приостановлено на время технических работ. Попробуйте снова примерно через $count минут.',
  _ =>
    'Бронирование приостановлено на время технических работ. Попробуйте снова примерно через $count минуты.',
};

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
  testMode: 'Тестовый режим',
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
  viewGroupTitle: 'ВИД',
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
  ticketPrices: 'Цены билетов',
  yourSeats: 'Ваши места',
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
  ticketTypeSoldOut: 'Этот тип билета распродан. Попробуйте другой тип.',
  seatsNoLongerAvailableTryAnother:
      'Эти места больше недоступны. Попробуйте другое количество или тип билета.',
  companionPairRequired:
      'К каждому билету сопровождающего выберите соседнее место для коляски.',
  ticketOptionNotApplicable:
      'Этот вариант билета недоступен для выбранного места.',
  maintenancePausedShortly:
      'Бронирование приостановлено на несколько минут из-за технических работ. Попробуйте снова чуть позже.',
  guestsOnly: 'Это мероприятие для приглашённых гостей.',
  guestChoiceClosed: 'Выбор мест сейчас недоступен.',
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
  adjustSelection: 'Изменить выбор мест',
  backToSeatMap: 'Назад к схеме мест',
  chooseSeats: 'Выберите свои места',
  chooseTickets: 'Выберите билеты',
  placeWord: 'МЕСТО',
  ticketWord: 'Билет',
  passport: 'Карточка места',
  venue3D: '3D',
  venueZone: 'Зона площадки',
  venueMapHint:
      'Места выбираются с помощью элементов управления вокруг схемы: полоса цен над ней, управление секторами под ней и панель билетов внизу.',
  previousSeat: 'Предыдущее место',
  nextSeat: 'Следующее место',
  orbitMode: 'Повернуть площадку',
  panMode: 'Переместить площадку',
  openInteractive3dVenue: 'Открыть интерактивный 3D-вид площадки',
  showSeatsFor: 'ПОКАЗАТЬ МЕСТА:',
  accessJumpFirstSection: 'Перейти к первому сектору',
  accessJumpNextSection: 'Перейти к следующему сектору',
  fewerTickets: 'Меньше билетов',
  moreTickets: 'Больше билетов',
  addTickets: 'Добавить билеты',
  noSelectableSeats: 'Сейчас нет мест, доступных для выбора.',
  confirmYourTickets: 'Подтвердите свои билеты',
  seatsSecuredOpeningCheckout: 'Места закреплены. Открываем оплату…',
  holdInCheckoutTitle: 'Ваши места уже в процессе оплаты',
  holdInCheckoutBody:
      'Завершите оплату, чтобы сохранить их. Чтобы выбрать другие места, сначала освободите эти — они вернутся в продажу.',
  releaseAndChangeSeats: 'Освободить и сменить места',
  holdAlreadyHeldTitle: 'Ваши места уже удерживаются',
  holdAlreadyHeldBody: 'Перейдите к оплате, чтобы сохранить их.',
  accessExpiredTitle: 'Ваш сеанс выбора мест истёк',
  accessExpiredCopy:
      'Обновите схему мест, чтобы продолжить. Места, которые уже в корзине, остаются за вами, пока не закончится таймер.',
  dismissError: 'Закрыть сообщение об ошибке',
  testModeLong: 'Тестовый режим · ничего не бронируется',
  seatRemoved: 'Билет убран',
  reloadSeatMap: 'Обновить схему мест',
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
  labelNoLongerAvailable: _labelNoLongerAvailableRu,
  labelsNoLongerAvailable: _labelsNoLongerAvailableRu,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherRu,
  couldNotRemoveLabel: _couldNotRemoveLabelRu,
  peekSecured: _peekSecuredRu,
  venueMap: _venueMapRu,
  accessibleStep: _accessibleStepRu,
  chooseMinMaxGuests: _chooseMinMaxGuestsRu,
  chooseMore: _chooseMoreRu,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeRu,
  accessNeedWithCount: _accessNeedWithCountRu,
  ticketCount: _ticketCountRu,
  findBestSeats: _findBestSeatsRu,
  reselectSeats: _reselectSeatsRu,
  seatsFree: _seatsFreeRu,
  seatsLeftInSection: _seatsLeftInSectionRu,
  holdLapsedStillFree: _holdLapsedStillFreeRu,
  holdLapsedSomeTaken: _holdLapsedSomeTakenRu,
  holdLapsedAllTaken: _holdLapsedAllTakenRu,
  accessibleSections: _accessibleSectionsRu,
  placesAvailable: _placesAvailableRu,
  removeTickets: _removeTicketsRu,
  holdMinutesLeft: _holdMinutesLeftRu,
  holdSecondsLeft: _holdSecondsLeftRu,
  holdLapsedBody: _holdLapsedBodyRu,
  seatsNotRecovered: _seatsNotRecoveredRu,
  activeFilters: _activeFiltersRu,
  accessibilityFiltersActive: _accessibilityFiltersActiveRu,
  onlyLeft: _onlyLeftRu,
  maintenancePaused: _maintenancePausedRu,
  continueWithTotal: _continueWithTotalRu,
);
