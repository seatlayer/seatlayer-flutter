// GENERATED — do not edit.
//
// Source: design/locale_strings.json (uk)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftUk(int count) => 'Залишилося $count';

String _moreCountUk(int count) => '+$count ще';

String _addMinutesUk(int minutes) => '+$minutes хв';

String _fromPriceUk(String money) => 'Від $money';

String _sightlineUk(String metres) => '≈ $metres м до сцени';

String _secureMoreAndCheckoutUk(int count) => 'Закріпити ще $count та оплатити';

String _accessFreeCountUk(int count) => 'Вільно: $count';

String _seatJustTakenByAnotherUk(String label) =>
    'Місце $label щойно зайняв інший покупець.';

String _labelNoLongerAvailableUk(String label) =>
    '$label більше недоступне. Оберіть інше місце.';

String _labelsNoLongerAvailableUk(String labels) =>
    '$labels більше недоступні. Оберіть іншу групу.';

String _couldNotFindSeatsTogetherUk(int count) =>
    'Не знайшли $count місць поруч. Спробуйте менше місць або інший тип квитка.';

String _couldNotRemoveLabelUk(String label) =>
    'Не вдалося прибрати $label. Бронь залишилася без змін.';

String _peekSecuredUk(int count, String total) =>
    '✓ $count закріплено · $total. Списання поки не буде';

String _venueMapUk(String venue) => '$venue: схема місць';

String _accessibleStepUk(int index, int total) => '$index з $total';

String _chooseMinMaxGuestsUk(int min, int max) =>
    'Оберіть від $min до $max гостей.';

String _chooseMoreUk(int count) => 'Оберіть ще $count';

String _seatsHeldForNeedMoreTimeUk(String time) =>
    'Ваші місця утримуються ще $time. Потрібно більше часу?';

String _accessNeedWithCountUk(String need, int count) => '$need · $count';

String _ticketCountUk(int count) => switch (pickerPluralCategory('uk', count)) {
  PickerPluralCategory.one => '$count квиток',
  PickerPluralCategory.few => '$count квитки',
  PickerPluralCategory.many => '$count квитків',
  _ => '$count квитка',
};

String _findBestSeatsUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Знайти $count найкраще місце',
      PickerPluralCategory.few => 'Знайти $count найкращі місця',
      PickerPluralCategory.many => 'Знайти $count найкращих місць',
      _ => 'Знайти $count найкращого місця',
    };

String _reselectSeatsUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Вибрати його знову',
      PickerPluralCategory.few => 'Вибрати їх знову',
      PickerPluralCategory.many => 'Вибрати їх знову',
      _ => 'Вибрати їх знову',
    };

String _seatsFreeUk(int count) => switch (pickerPluralCategory('uk', count)) {
  PickerPluralCategory.one => '$count місце',
  PickerPluralCategory.few => '$count місця',
  PickerPluralCategory.many => '$count місць',
  _ => '$count місця',
};

String _seatsLeftInSectionUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Залишилося $count місце',
      PickerPluralCategory.few => 'Залишилося $count місця',
      PickerPluralCategory.many => 'Залишилося $count місць',
      _ => 'Залишилося $count місця',
    };

String _holdLapsedStillFreeUk(int count) => switch (pickerPluralCategory(
  'uk',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваше бронювання завершилося, поки вас не було. Це місце досі вільне.',
  PickerPluralCategory.few =>
    'Ваше бронювання завершилося, поки вас не було. Ці місця досі вільні.',
  PickerPluralCategory.many =>
    'Ваше бронювання завершилося, поки вас не було. Ці місця досі вільні.',
  _ => 'Ваше бронювання завершилося, поки вас не було. Ці місця досі вільні.',
};

String _holdLapsedSomeTakenUk(int count) => switch (pickerPluralCategory(
  'uk',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваше бронювання завершилося, поки вас не було, і $count із цих місць уже зайнято. Решта досі вільні.',
  PickerPluralCategory.few =>
    'Ваше бронювання завершилося, поки вас не було, і $count із цих місць уже зайняті. Решта досі вільні.',
  PickerPluralCategory.many =>
    'Ваше бронювання завершилося, поки вас не було, і $count із цих місць уже зайнято. Решта досі вільні.',
  _ =>
    'Ваше бронювання завершилося, поки вас не було, і $count із цих місць уже зайнято. Решта досі вільні.',
};

String _holdLapsedAllTakenUk(int count) => switch (pickerPluralCategory(
  'uk',
  count,
)) {
  PickerPluralCategory.one =>
    'Ваше бронювання завершилося, поки вас не було, і це місце вже зайнято.',
  PickerPluralCategory.few =>
    'Ваше бронювання завершилося, поки вас не було, і ці місця вже зайнято.',
  PickerPluralCategory.many =>
    'Ваше бронювання завершилося, поки вас не було, і ці місця вже зайнято.',
  _ => 'Ваше бронювання завершилося, поки вас не було, і ці місця вже зайнято.',
};

String _accessibleSectionsUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => '$count сектор',
      PickerPluralCategory.few => '$count сектори',
      PickerPluralCategory.many => '$count секторів',
      _ => '$count сектора',
    };

String _placesAvailableUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Зараз доступно $count місце',
      PickerPluralCategory.few => 'Зараз доступно $count місця',
      PickerPluralCategory.many => 'Зараз доступно $count місць',
      _ => 'Зараз доступно $count місця',
    };

String _removeTicketsUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Видалити $count квиток',
      PickerPluralCategory.few => 'Видалити $count квитки',
      PickerPluralCategory.many => 'Видалити $count квитків',
      _ => 'Видалити $count квитка',
    };

String _holdMinutesLeftUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Залишилася $count хвилина',
      PickerPluralCategory.few => 'Залишилося $count хвилини',
      PickerPluralCategory.many => 'Залишилося $count хвилин',
      _ => 'Залишилося $count хвилини',
    };

String _holdSecondsLeftUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Залишилася $count секунда',
      PickerPluralCategory.few => 'Залишилося $count секунди',
      PickerPluralCategory.many => 'Залишилося $count секунд',
      _ => 'Залишилося $count секунди',
    };

String _holdLapsedBodyUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Їх утримували $count хвилину.',
      PickerPluralCategory.few => 'Їх утримували $count хвилини.',
      PickerPluralCategory.many => 'Їх утримували $count хвилин.',
      _ => 'Їх утримували $count хвилини.',
    };

String _seatsNotRecoveredUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => '$count місце не вдалося повернути',
      PickerPluralCategory.few => '$count місця не вдалося повернути',
      PickerPluralCategory.many => '$count місць не вдалося повернути',
      _ => '$count місця не вдалося повернути',
    };

String _activeFiltersUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => '$count фільтр',
      PickerPluralCategory.few => '$count фільтри',
      PickerPluralCategory.many => '$count фільтрів',
      _ => '$count фільтра',
    };

String _accessibilityFiltersActiveUk(int count) =>
    switch (pickerPluralCategory('uk', count)) {
      PickerPluralCategory.one => 'Увімкнено $count фільтр доступності',
      PickerPluralCategory.few => 'Увімкнено $count фільтри доступності',
      PickerPluralCategory.many => 'Увімкнено $count фільтрів доступності',
      _ => 'Увімкнено $count фільтра доступності',
    };

String _onlyLeftUk(int count) => switch (pickerPluralCategory('uk', count)) {
  PickerPluralCategory.one => 'Залишилося $count місце',
  PickerPluralCategory.few => 'Залишилося $count місця',
  PickerPluralCategory.many => 'Залишилося $count місць',
  _ => 'Залишилося $count місця',
};

String _maintenancePausedUk(int count) => switch (pickerPluralCategory(
  'uk',
  count,
)) {
  PickerPluralCategory.one =>
    'Бронювання призупинено на час технічних робіт. Спробуйте ще раз приблизно через $count хвилину.',
  PickerPluralCategory.few =>
    'Бронювання призупинено на час технічних робіт. Спробуйте ще раз приблизно через $count хвилини.',
  PickerPluralCategory.many =>
    'Бронювання призупинено на час технічних робіт. Спробуйте ще раз приблизно через $count хвилин.',
  _ =>
    'Бронювання призупинено на час технічних робіт. Спробуйте ще раз приблизно через $count хвилини.',
};

String _continueWithTotalUk(String money) => 'Продовжити \u00b7 $money';

/// The `uk` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsUk = SeatLayerPickerStrings(
  close: 'Закрити',
  overview: 'Майданчик',
  backToVenue: 'Назад до майданчика',
  cancel: 'Скасувати',
  select: 'Обрати',
  removeSeat: 'Видалити місце',
  viewFromHere: 'Вид звідси',
  openVenue360: 'Відкрити майданчик у 360°',
  recentre: 'Знову навести на сцену',
  viewFromYourSeat: 'вигляд з вашого місця',
  emptyTrayHint:
      'Торкніться місця на схемі або довірте нам обрати найкращі доступні.',
  anyTicketType: 'Будь-який тип квитка',
  anyVenueZone: 'Будь-яка зона майданчика',
  bestSeats: 'Найкращі місця',
  showLess: 'Показати менше',
  undo: 'Скасувати',
  holdAndCheckout: 'Забронювати місця та оплатити',
  poweredBy: 'Працює на SeatLayer',
  testMode: 'Тестовий режим',
  accessibility: 'Доступність і кольори',
  accessibilityTitle: 'Доступність і кольори',
  fitVenue: 'Показати весь майданчик',
  fitWholeVenue: 'Показати весь майданчик',
  loading: 'Завантажуємо схему місць…',
  errorMessage: 'Схема місць не завантажилася',
  retry: 'Спробувати ще раз',
  accessRefresh: 'Оновити',
  noSeatsSelected: 'Місця не обрано',
  findBestSeatsCta: 'Знайти найкращі місця',
  organizerNote: 'Примітка організатора',
  accessiblePhysicalSeat: 'Доступне фізичне місце',
  emptyWheelchairSpace: 'Вільне місце для візка',
  findSeatsTogether: 'Знайти місця поруч',
  aboutBestSeats: 'Про пошук місць поруч',
  closestGroupChosenInstantly: 'Найближча доступна група, обрана миттєво.',
  hideLimitedView: 'Сховати місця з обмеженим оглядом',
  colorblindSafe: 'Кольори для дальтоніків',
  notAvailable: 'Недоступно',
  viewGroupTitle: 'ВИД',
  restrictedView: 'Обмежений огляд',
  obstructedView: 'Огляд перекрито',
  premiumSeat: 'Преміальне місце',
  continueWord: 'Продовжити',
  allFloors: 'Усі поверхи',
  previousSection: 'Попередній сектор',
  nextSection: 'Наступний сектор',
  addSeat: 'Додати місце',
  added: 'Додано',
  sectionWord: 'Сектор',
  rowWord: 'Ряд',
  seatWord: 'Місце',
  seeItIn3D: 'Подивитися в 3D',
  viewFromThisSeat: 'Вид з цього місця',
  allPrices: 'Усі ціни',
  ticketPrices: 'Ціни квитків',
  yourSeats: 'Ваші місця',
  ticketType: 'Тип квитка',
  tierCompanionGuidance: 'Потрібне сусіднє місце для візка',
  findingBestSeats: 'Шукаємо найкращі місця…',
  findSeats: 'Знайти місця',
  expandCart: 'Відкрити панель квитків',
  collapseCart: 'Згорнути панель квитків',
  continueToCheckout: 'Перейти до оплати',
  secureMore: 'Закріпити ще',
  selectSeats: 'Обрати місця',
  pickYourSeats: 'Оберіть свої місця',
  salesClosedPill: 'Продаж закрито',
  salesClosedCta: 'Продаж закрито',
  confirmOrCancelSeat: 'Підтвердьте або скасуйте це місце',
  securingSeats: 'Закріплюємо ваші місця…',
  openingCheckout: 'Відкриваємо захищену оплату…',
  testModeExplained: 'Бронювання тут несправжні, і жодна картка не списується',
  displayOptions: 'Параметри відображення',
  companionSeatsNote: 'Сусідні місця для супроводу залишаються доступними',
  zoomIn: 'Наблизити',
  zoomOut: 'Віддалити',
  rotateVenue: 'Перетягніть, щоб обернути майданчик',
  moveVenue: 'Перетягніть, щоб перемістити майданчик',
  mapView: 'Схема',
  flat2dMap: 'Пласка схема 2D',
  interactive3dVenueView: 'Інтерактивний 3D-вид майданчика',
  venueView: 'Вид майданчика',
  holdLapsedTitle: 'Ваші місця звільнено',
  salesClosed: 'Продаж закрито',
  salesClosedCopy: 'Продаж квитків на цю подію завершено.',
  salesClosedToast: 'Продаж на цю подію закрито.',
  soldOutEyebrow: 'Ця подія',
  soldOutTitle: 'Розпродано',
  soldOutCopy: 'Зараз на цю подію немає вільних нумерованих місць.',
  holdExpired: 'Термін броні минув. Місця звільнено. Оберіть знову.',
  addingEllipsis: 'Додаємо…',
  moreTimeAdded: 'Час продовжено. Ваші місця й далі заброньовані.',
  couldNotAddMoreTime: 'Не вдалося продовжити час. Перейдіть до оплати зараз.',
  seatsJustTaken: 'Одне або кілька місць щойно зайняли. Оберіть знову.',
  ticketTypeSoldOut: 'Цей тип квитка розпродано. Спробуйте інший тип.',
  seatsNoLongerAvailableTryAnother:
      'Ці місця більше недоступні. Спробуйте іншу кількість або тип квитка.',
  companionPairRequired:
      'До кожного квитка супроводу оберіть сусіднє місце для візка.',
  ticketOptionNotApplicable:
      'Цей варіант квитка недоступний для вибраного місця.',
  maintenancePausedShortly:
      'Бронювання призупинено на кілька хвилин через технічні роботи. Спробуйте ще раз трохи пізніше.',
  guestsOnly: 'Ця подія для запрошених гостей.',
  guestChoiceClosed: 'Вибір місць зараз недоступний.',
  tooManyAttempts: 'Забагато спроб. Зачекайте трохи й спробуйте ще раз.',
  seatHeldForRenewal:
      'Одне з цих місць закріплено за власником абонемента, який ще може його продовжити. Оберіть інше місце.',
  seatUnavailable: 'Це місце недоступне.',
  eventUnavailable: 'Зараз тут не можна забронювати квитки.',
  savedSeatsNotRestored:
      'Не вдалося відновити ваші попередні місця. Будь ласка, виберіть знову.',
  allSetTitle: 'Усе готово',
  confirmedAndOnWay: 'підтверджено. Підтвердження вже в дорозі.',
  backToMap: 'Назад до схеми',
  mapDidNotLoad: 'Схема місць не завантажилася',
  checkConnection: 'Перевірте з\'єднання та спробуйте знову.',
  accessPausedTitle: 'Ці місця зараз заблоковані',
  accessPausedCopy:
      'Організатор призупинив цей вибір. Спробуйте за кілька хвилин.',
  accessRevokedTitle: 'Це посилання доступу більше не діє',
  accessRevokedCopy:
      'Попросіть нове посилання в того, хто надіслав вам це, щоб продовжити бронювати ці місця.',
  accessUnverifiedTitle: 'Не вдалося підтвердити ваш доступ',
  accessUnverifiedCopy:
      'Ви й далі можете купити все, що показано як доступне. За доступом до решти зверніться до того, хто надіслав вам посилання.',
  generalAdmission: 'Вільна розсадка',
  numberOfGuests: 'Кількість гостей',
  chooseGuestsCopy:
      'Оберіть, скільки гостей сяде разом. Цей стіл бронюється лише для вашої компанії.',
  fewerGuests: 'Менше гостей',
  moreGuests: 'Більше гостей',
  selectTable: 'Обрати стіл',
  updateTable: 'Оновити стіл',
  removeWord: 'Прибрати',
  floorWord: 'Поверх',
  totalWord: 'Разом',
  adjustSelection: 'Змінити вибір місць',
  backToSeatMap: 'Назад до схеми місць',
  chooseSeats: 'Оберіть свої місця',
  chooseTickets: 'Оберіть квитки',
  placeWord: 'МІСЦЕ',
  ticketWord: 'Квиток',
  passport: 'Картка місця',
  venue3D: '3D',
  venueZone: 'Зона майданчика',
  venueMapHint:
      'Місця обирають за допомогою елементів керування навколо схеми: смуга цін над нею, керування секторами під нею і панель квитків унизу.',
  previousSeat: 'Попереднє місце',
  nextSeat: 'Наступне місце',
  orbitMode: 'Обернути майданчик',
  panMode: 'Перемістити майданчик',
  openInteractive3dVenue: 'Відкрити інтерактивний 3D-вид майданчика',
  showSeatsFor: 'ПОКАЗАТИ МІСЦЯ:',
  accessJumpFirstSection: 'Перейти до першого сектора',
  accessJumpNextSection: 'Перейти до наступного сектора',
  fewerTickets: 'Менше квитків',
  moreTickets: 'Більше квитків',
  addTickets: 'Додати квитки',
  noSelectableSeats: 'Зараз немає місць, доступних для вибору.',
  confirmYourTickets: 'Підтвердьте свої квитки',
  seatsSecuredOpeningCheckout: 'Місця закріплено. Відкриваємо оплату…',
  holdInCheckoutTitle: 'Ваші місця вже в процесі оплати',
  holdInCheckoutBody:
      'Завершіть оплату, щоб зберегти їх. Щоб обрати інші місця, спершу звільніть ці — вони повернуться в продаж.',
  releaseAndChangeSeats: 'Звільнити й змінити місця',
  holdAlreadyHeldTitle: 'Ваші місця вже утримуються за вами',
  holdAlreadyHeldBody: 'Перейдіть до оплати, щоб зберегти їх.',
  accessExpiredTitle: 'Ваш сеанс вибору місць завершився',
  accessExpiredCopy:
      'Оновіть схему місць, щоб продовжити. Місця, які вже в кошику, залишаються за вами, доки не скінчиться таймер.',
  dismissError: 'Закрити повідомлення про помилку',
  testModeLong: 'Тестовий режим · нічого не бронюється',
  seatRemoved: 'Квиток прибрано',
  reloadSeatMap: 'Оновити схему місць',
  accessNeeds: <String, String>{
    'wheelchair': 'Місце для візка',
    'companion': 'Місце для супроводу',
    'semi-ambulatory': 'Обмежена рухливість',
    'designated-aisle': 'Прохід / пересадка',
    'step-free': 'Без сходинок',
    'hearing': 'Підтримка слуху',
    'cart': 'Субтитри в реальному часі',
    'sign-language': 'Жестова мова',
    'low-vision': 'Слабкий зір',
    'sensory-friendly': 'Сенсорно комфортне',
    'plus-size': 'Розширене місце',
    'lift-armrest': 'Підйомний підлокітник',
  },
  seatsLeft: _seatsLeftUk,
  moreCount: _moreCountUk,
  addMinutes: _addMinutesUk,
  fromPrice: _fromPriceUk,
  sightline: _sightlineUk,
  secureMoreAndCheckout: _secureMoreAndCheckoutUk,
  accessFreeCount: _accessFreeCountUk,
  seatJustTakenByAnother: _seatJustTakenByAnotherUk,
  labelNoLongerAvailable: _labelNoLongerAvailableUk,
  labelsNoLongerAvailable: _labelsNoLongerAvailableUk,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherUk,
  couldNotRemoveLabel: _couldNotRemoveLabelUk,
  peekSecured: _peekSecuredUk,
  venueMap: _venueMapUk,
  accessibleStep: _accessibleStepUk,
  chooseMinMaxGuests: _chooseMinMaxGuestsUk,
  chooseMore: _chooseMoreUk,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeUk,
  accessNeedWithCount: _accessNeedWithCountUk,
  ticketCount: _ticketCountUk,
  findBestSeats: _findBestSeatsUk,
  reselectSeats: _reselectSeatsUk,
  seatsFree: _seatsFreeUk,
  seatsLeftInSection: _seatsLeftInSectionUk,
  holdLapsedStillFree: _holdLapsedStillFreeUk,
  holdLapsedSomeTaken: _holdLapsedSomeTakenUk,
  holdLapsedAllTaken: _holdLapsedAllTakenUk,
  accessibleSections: _accessibleSectionsUk,
  placesAvailable: _placesAvailableUk,
  removeTickets: _removeTicketsUk,
  holdMinutesLeft: _holdMinutesLeftUk,
  holdSecondsLeft: _holdSecondsLeftUk,
  holdLapsedBody: _holdLapsedBodyUk,
  seatsNotRecovered: _seatsNotRecoveredUk,
  activeFilters: _activeFiltersUk,
  accessibilityFiltersActive: _accessibilityFiltersActiveUk,
  onlyLeft: _onlyLeftUk,
  maintenancePaused: _maintenancePausedUk,
  continueWithTotal: _continueWithTotalUk,
);
