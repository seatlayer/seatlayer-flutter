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

String _peekSecuredUk(int count, String total) =>
    '✓ $count закріплено · $total. Списання поки не буде';

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
  testMode: 'ТЕСТОВИЙ РЕЖИМ',
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
  peekSecured: _peekSecuredUk,
  ticketCount: _ticketCountUk,
  findBestSeats: _findBestSeatsUk,
  reselectSeats: _reselectSeatsUk,
  seatsFree: _seatsFreeUk,
  seatsLeftInSection: _seatsLeftInSectionUk,
  holdLapsedStillFree: _holdLapsedStillFreeUk,
  holdLapsedSomeTaken: _holdLapsedSomeTakenUk,
  holdLapsedAllTaken: _holdLapsedAllTakenUk,
  continueWithTotal: _continueWithTotalUk,
);
