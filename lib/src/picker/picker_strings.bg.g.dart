// GENERATED — do not edit.
//
// Source: design/locale_strings.json (bg)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftBg(int count) => 'Остават $count';

String _moreCountBg(int count) => '+$count още';

String _addMinutesBg(int minutes) => '+$minutes мин';

String _fromPriceBg(String money) => 'От $money';

String _sightlineBg(String metres) => '≈ $metres м до сцената';

String _secureMoreAndCheckoutBg(int count) => 'Запази още $count и плати';

String _accessFreeCountBg(int count) => 'Свободни: $count';

String _seatJustTakenByAnotherBg(String label) =>
    'Място $label току-що беше заето от друг купувач.';

String _labelNoLongerAvailableBg(String label) =>
    '$label вече не е налично. Изберете друго място.';

String _labelsNoLongerAvailableBg(String labels) =>
    '$labels вече не са налични. Изберете друга група.';

String _couldNotFindSeatsTogetherBg(int count) =>
    'Не намерихме $count места едно до друго. Опитайте с по-малко места или друг вид билет.';

String _couldNotRemoveLabelBg(String label) =>
    'Не можахме да премахнем $label. Резервацията ви остава непроменена.';

String _peekSecuredBg(int count, String total) =>
    '✓ $count запазени · $total. Още няма да ви таксуваме';

String _venueMapBg(String venue) => 'План на местата – $venue';

String _accessibleStepBg(int index, int total) => '$index от $total';

String _chooseMinMaxGuestsBg(int min, int max) =>
    'Изберете между $min и $max гости.';

String _chooseMoreBg(int count) => 'Избери още $count';

String _seatsHeldForNeedMoreTimeBg(String time) =>
    'Местата ви са запазени за още $time. Нужно ли ви е повече време?';

String _accessNeedWithCountBg(String need, int count) => '$need · $count';

String _ticketCountBg(int count) => switch (pickerPluralCategory('bg', count)) {
  PickerPluralCategory.one => '$count билет',
  _ => '$count билета',
};

String _findBestSeatsBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Намери $count най-добро място',
      _ => 'Намери $count най-добри места',
    };

String _reselectSeatsBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Изберете го отново',
      _ => 'Изберете ги отново',
    };

String _seatsFreeBg(int count) => switch (pickerPluralCategory('bg', count)) {
  PickerPluralCategory.one => '$count място',
  _ => '$count места',
};

String _seatsLeftInSectionBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Остава $count място',
      _ => 'Остават $count места',
    };

String _holdLapsedStillFreeBg(int count) => switch (pickerPluralCategory(
  'bg',
  count,
)) {
  PickerPluralCategory.one =>
    'Резервацията ви изтече, докато ви нямаше. Това място все още е свободно.',
  _ =>
    'Резервацията ви изтече, докато ви нямаше. Тези места все още са свободни.',
};

String _holdLapsedSomeTakenBg(int count) => switch (pickerPluralCategory(
  'bg',
  count,
)) {
  PickerPluralCategory.one =>
    'Резервацията ви изтече, докато ви нямаше, и $count от тези места вече е заето. Останалите все още са свободни.',
  _ =>
    'Резервацията ви изтече, докато ви нямаше, и $count от тези места вече са заети. Останалите все още са свободни.',
};

String _holdLapsedAllTakenBg(int count) => switch (pickerPluralCategory(
  'bg',
  count,
)) {
  PickerPluralCategory.one =>
    'Резервацията ви изтече, докато ви нямаше, и това място вече е заето.',
  _ => 'Резервацията ви изтече, докато ви нямаше, и тези места вече са заети.',
};

String _accessibleSectionsBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => '$count сектор',
      _ => '$count сектора',
    };

String _placesAvailableBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'В момента е налично $count място',
      _ => 'В момента са налични $count места',
    };

String _removeTicketsBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Премахни $count билет',
      _ => 'Премахни $count билета',
    };

String _holdMinutesLeftBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Остава $count минута',
      _ => 'Остават $count минути',
    };

String _holdSecondsLeftBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Остава $count секунда',
      _ => 'Остават $count секунди',
    };

String _holdLapsedBodyBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => 'Бяха запазени за $count минута.',
      _ => 'Бяха запазени за $count минути.',
    };

String _seatsNotRecoveredBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => '$count място не можа да бъде възстановено',
      _ => '$count места не можаха да бъдат възстановени',
    };

String _activeFiltersBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => '$count филтър',
      _ => '$count филтъра',
    };

String _accessibilityFiltersActiveBg(int count) =>
    switch (pickerPluralCategory('bg', count)) {
      PickerPluralCategory.one => '$count филтър за достъпност е активен',
      _ => '$count филтъра за достъпност са активни',
    };

String _onlyLeftBg(int count) => switch (pickerPluralCategory('bg', count)) {
  PickerPluralCategory.one => 'Остава $count място',
  _ => 'Остават $count места',
};

String _maintenancePausedBg(int count) => switch (pickerPluralCategory(
  'bg',
  count,
)) {
  PickerPluralCategory.one =>
    'Резервациите са временно спрени за поддръжка. Опитайте отново след около $count минута.',
  _ =>
    'Резервациите са временно спрени за поддръжка. Опитайте отново след около $count минути.',
};

String _continueWithTotalBg(String money) => 'Продължи \u00b7 $money';

/// The `bg` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsBg = SeatLayerPickerStrings(
  close: 'Затвори',
  overview: 'Зала',
  backToVenue: 'Назад към обекта',
  cancel: 'Отказ',
  select: 'Избери',
  removeSeat: 'Премахни място',
  viewFromHere: 'Гледка оттук',
  openVenue360: 'Отвори обекта в 360°',
  recentre: 'Центрирай отново върху сцената',
  viewFromYourSeat: 'изглед от вашето място',
  emptyTrayHint:
      'Докоснете място в плана или ни оставете да изберем най-добрите свободни за вас.',
  anyTicketType: 'Всякакъв вид билет',
  anyVenueZone: 'Всякаква зона на обекта',
  bestSeats: 'Най-добрите места',
  showLess: 'Покажи по-малко',
  undo: 'Отмени',
  holdAndCheckout: 'Запази местата и плати',
  poweredBy: 'С технологията на SeatLayer',
  testMode: 'Тестов режим',
  accessibility: 'Достъпност и цветове',
  accessibilityTitle: 'Достъпност и цветове',
  fitVenue: 'Покажи цялото място',
  fitWholeVenue: 'Покажи цялото място',
  loading: 'Зареждане на плана на местата…',
  errorMessage: 'Планът на местата не се зареди',
  retry: 'Опитай отново',
  accessRefresh: 'Презареди',
  noSeatsSelected: 'Няма избрани места',
  findBestSeatsCta: 'Намери най-добрите места',
  organizerNote: 'Бележка от организатора',
  accessiblePhysicalSeat: 'Достъпно физическо място',
  emptyWheelchairSpace: 'Свободно място за инвалидна количка',
  findSeatsTogether: 'Намери места едно до друго',
  aboutBestSeats: 'За намирането на места едно до друго',
  closestGroupChosenInstantly: 'Най-близката свободна група, избрана веднага.',
  hideLimitedView: 'Скрий местата с ограничена видимост',
  colorblindSafe: 'Цветове за далтонисти',
  notAvailable: 'Не е налично',
  viewGroupTitle: 'ИЗГЛЕД',
  restrictedView: 'Ограничена видимост',
  obstructedView: 'Закрита видимост',
  premiumSeat: 'Премиум място',
  continueWord: 'Продължи',
  allFloors: 'Всички етажи',
  previousSection: 'Предишен сектор',
  nextSection: 'Следващ сектор',
  addSeat: 'Добави място',
  added: 'Добавено',
  sectionWord: 'Сектор',
  rowWord: 'Ред',
  seatWord: 'Място',
  seeItIn3D: 'Виж в 3D',
  viewFromThisSeat: 'Гледка от това място',
  allPrices: 'Всички цени',
  ticketPrices: 'Цени на билетите',
  yourSeats: 'Вашите места',
  ticketType: 'Вид билет',
  tierCompanionGuidance: 'Изисква съседното място за инвалидна количка',
  findingBestSeats: 'Търсим най-добрите места…',
  findSeats: 'Намери места',
  expandCart: 'Отвори панела с билети',
  collapseCart: 'Свий панела с билети',
  continueToCheckout: 'Продължи към плащане',
  secureMore: 'Запази още',
  selectSeats: 'Избери места',
  pickYourSeats: 'Изберете местата си',
  salesClosedPill: 'Продажбите са затворени',
  salesClosedCta: 'Продажбите са затворени',
  confirmOrCancelSeat: 'Потвърдете или откажете това място',
  securingSeats: 'Запазваме местата ви…',
  openingCheckout: 'Отваряме защитено плащане…',
  testModeExplained: 'Резервациите тук не са истински и не се таксува карта',
  displayOptions: 'Опции за показване',
  companionSeatsNote: 'Съседните места за придружител остават избираеми',
  zoomIn: 'Приближи',
  zoomOut: 'Отдалечи',
  rotateVenue: 'Плъзнете, за да завъртите мястото',
  moveVenue: 'Плъзнете, за да преместите мястото',
  mapView: 'План',
  flat2dMap: 'Плосък 2D план',
  interactive3dVenueView: 'Интерактивен 3D изглед на обекта',
  venueView: 'Изглед на обекта',
  holdLapsedTitle: 'Местата ви бяха освободени',
  salesClosed: 'Продажбите са затворени',
  salesClosedCopy: 'Продажбата на билети за това събитие приключи.',
  salesClosedToast: 'Продажбите за това събитие са затворени.',
  soldOutEyebrow: 'Това събитие',
  soldOutTitle: 'Изчерпано',
  soldOutCopy: 'В момента няма свободни номерирани места за това събитие.',
  holdExpired:
      'Резервацията ви изтече. Местата бяха освободени. Изберете отново.',
  addingEllipsis: 'Добавяне…',
  moreTimeAdded: 'Добавено е още време. Местата ви са все още резервирани.',
  couldNotAddMoreTime:
      'Не можахме да добавим време. Преминете към плащане сега.',
  seatsJustTaken: 'Едно или повече места току-що бяха заети. Изберете отново.',
  ticketTypeSoldOut: 'Този вид билет е изчерпан. Опитайте с друг вид.',
  seatsNoLongerAvailableTryAnother:
      'Тези места вече не са налични. Опитайте с друго количество или друг вид билет.',
  companionPairRequired:
      'Към всеки билет за придружител изберете съседното място за инвалидна количка.',
  ticketOptionNotApplicable:
      'Този вариант на билет не е наличен за избраното място.',
  maintenancePausedShortly:
      'Резервациите са спрени за няколко минути заради поддръжка. Опитайте отново след малко.',
  guestsOnly: 'Това събитие е за поканени гости.',
  guestChoiceClosed: 'Изборът на места не е отворен в момента.',
  tooManyAttempts: 'Твърде много опити. Изчакайте малко и опитайте отново.',
  seatHeldForRenewal:
      'Едно от тези места е запазено за притежател на абонамент, който все още може да го поднови. Изберете друго място.',
  seatUnavailable: 'Това място не е налично.',
  eventUnavailable: 'В момента тук не могат да се резервират билети.',
  savedSeatsNotRestored:
      'Предишните ви места не можаха да бъдат възстановени. Моля, изберете отново.',
  allSetTitle: 'Всичко е готово',
  confirmedAndOnWay: 'потвърдено. Потвърждението пътува към вас.',
  backToMap: 'Назад към плана',
  mapDidNotLoad: 'Планът на местата не се зареди',
  checkConnection: 'Проверете връзката си и опитайте отново.',
  accessPausedTitle: 'Тези места са блокирани в момента',
  accessPausedCopy:
      'Организаторът е поставил този избор на пауза. Опитайте отново след няколко минути.',
  accessRevokedTitle: 'Тази връзка за достъп вече не е активна',
  accessRevokedCopy:
      'Поискайте нова връзка от този, който ви я изпрати, за да продължите да резервирате тези места.',
  accessUnverifiedTitle: 'Не успяхме да потвърдим достъпа ви',
  accessUnverifiedCopy:
      'Все още можете да купите всичко, показано като налично. За достъп до останалото се свържете с този, който ви изпрати връзката.',
  generalAdmission: 'Свободен вход',
  numberOfGuests: 'Брой гости',
  chooseGuestsCopy:
      'Изберете колко гости ще седят заедно. Тази маса се запазва само за вашата компания.',
  fewerGuests: 'По-малко гости',
  moreGuests: 'Повече гости',
  selectTable: 'Избери маса',
  updateTable: 'Обнови масата',
  removeWord: 'Премахни',
  floorWord: 'Етаж',
  totalWord: 'Общо',
  adjustSelection: 'Промени избора на места',
  backToSeatMap: 'Назад към плана на местата',
  chooseSeats: 'Изберете местата си',
  chooseTickets: 'Изберете билети',
  placeWord: 'МЯСТО',
  ticketWord: 'Билет',
  passport: 'Профил на мястото',
  venue3D: '3D',
  venueZone: 'Зона на обекта',
  venueMapHint:
      'Местата се избират с контролите около плана: лентата с цени над него, контролите за секторите под него и панелът с билети най-долу.',
  previousSeat: 'Предишно място',
  nextSeat: 'Следващо място',
  orbitMode: 'Завърти залата',
  panMode: 'Премести залата',
  openInteractive3dVenue: 'Отвори интерактивния 3D изглед на обекта',
  showSeatsFor: 'ПОКАЖИ МЕСТА ЗА',
  accessJumpFirstSection: 'Към първия сектор',
  accessJumpNextSection: 'Към следващия сектор',
  fewerTickets: 'По-малко билети',
  moreTickets: 'Повече билети',
  addTickets: 'Добави билети',
  noSelectableSeats: 'В момента няма налични места за избор.',
  confirmYourTickets: 'Потвърди билетите си',
  seatsSecuredOpeningCheckout: 'Местата са запазени. Отваряме плащането…',
  holdInCheckoutTitle: 'Местата ви вече са в процес на плащане',
  holdInCheckoutBody:
      'Завършете плащането, за да ги запазите. За да изберете други места, първо освободете тези — те се връщат в продажба.',
  releaseAndChangeSeats: 'Освободи и смени местата',
  holdAlreadyHeldTitle: 'Местата ви вече са запазени',
  holdAlreadyHeldBody: 'Продължете към плащане, за да ги запазите.',
  accessExpiredTitle: 'Сесията ви за избор на места изтече',
  accessExpiredCopy:
      'Презаредете плана на местата, за да продължите. Местата, които вече са в количката ви, остават запазени, докато таймерът изтече.',
  dismissError: 'Затвори съобщението за грешка',
  testModeLong: 'Тестов режим · нищо не се резервира',
  seatRemoved: 'Билетът е премахнат',
  reloadSeatMap: 'Презареди плана на местата',
  accessNeeds: <String, String>{
    'wheelchair': 'Място за количка',
    'companion': 'Място за придружител',
    'semi-ambulatory': 'Ограничена подвижност',
    'designated-aisle': 'Пътека / прехвърляне',
    'step-free': 'Без стъпала',
    'hearing': 'Помощно слушане',
    'cart': 'Субтитри на живо',
    'sign-language': 'Жестов език',
    'low-vision': 'Слабо зрение',
    'sensory-friendly': 'Сензорно щадящи',
    'plus-size': 'По-широко място',
    'lift-armrest': 'Повдигаща се подлакътница',
  },
  seatsLeft: _seatsLeftBg,
  moreCount: _moreCountBg,
  addMinutes: _addMinutesBg,
  fromPrice: _fromPriceBg,
  sightline: _sightlineBg,
  secureMoreAndCheckout: _secureMoreAndCheckoutBg,
  accessFreeCount: _accessFreeCountBg,
  seatJustTakenByAnother: _seatJustTakenByAnotherBg,
  labelNoLongerAvailable: _labelNoLongerAvailableBg,
  labelsNoLongerAvailable: _labelsNoLongerAvailableBg,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherBg,
  couldNotRemoveLabel: _couldNotRemoveLabelBg,
  peekSecured: _peekSecuredBg,
  venueMap: _venueMapBg,
  accessibleStep: _accessibleStepBg,
  chooseMinMaxGuests: _chooseMinMaxGuestsBg,
  chooseMore: _chooseMoreBg,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeBg,
  accessNeedWithCount: _accessNeedWithCountBg,
  ticketCount: _ticketCountBg,
  findBestSeats: _findBestSeatsBg,
  reselectSeats: _reselectSeatsBg,
  seatsFree: _seatsFreeBg,
  seatsLeftInSection: _seatsLeftInSectionBg,
  holdLapsedStillFree: _holdLapsedStillFreeBg,
  holdLapsedSomeTaken: _holdLapsedSomeTakenBg,
  holdLapsedAllTaken: _holdLapsedAllTakenBg,
  accessibleSections: _accessibleSectionsBg,
  placesAvailable: _placesAvailableBg,
  removeTickets: _removeTicketsBg,
  holdMinutesLeft: _holdMinutesLeftBg,
  holdSecondsLeft: _holdSecondsLeftBg,
  holdLapsedBody: _holdLapsedBodyBg,
  seatsNotRecovered: _seatsNotRecoveredBg,
  activeFilters: _activeFiltersBg,
  accessibilityFiltersActive: _accessibilityFiltersActiveBg,
  onlyLeft: _onlyLeftBg,
  maintenancePaused: _maintenancePausedBg,
  continueWithTotal: _continueWithTotalBg,
);
