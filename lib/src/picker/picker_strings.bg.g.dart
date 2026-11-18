// GENERATED — do not edit.
//
// Source: design/locale_strings.json (bg)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

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

String _peekSecuredBg(int count, String total) =>
    '✓ $count запазени · $total. Още няма да ви таксуваме';

String _ticketCountBg(int count) =>
    count == 1 ? '$count билет' : '$count билета';

String _findBestSeatsBg(int count) => count == 1
    ? 'Намери $count най-добро място'
    : 'Намери $count най-добри места';

String _reselectSeatsBg(int count) =>
    count == 1 ? 'Изберете го отново' : 'Изберете ги отново';

String _seatsFreeBg(int count) => count == 1 ? '$count място' : '$count места';

String _seatsLeftInSectionBg(int count) =>
    count == 1 ? 'Остава $count място' : 'Остават $count места';

String _holdLapsedStillFreeBg(int count) => count == 1
    ? 'Резервацията ви изтече, докато ви нямаше. Това място все още е свободно.'
    : 'Резервацията ви изтече, докато ви нямаше. Тези места все още са свободни.';

String _holdLapsedSomeTakenBg(int count) => count == 1
    ? 'Резервацията ви изтече, докато ви нямаше, и $count от тези места вече е заето. Останалите все още са свободни.'
    : 'Резервацията ви изтече, докато ви нямаше, и $count от тези места вече са заети. Останалите все още са свободни.';

String _holdLapsedAllTakenBg(int count) => count == 1
    ? 'Резервацията ви изтече, докато ви нямаше, и това място вече е заето.'
    : 'Резервацията ви изтече, докато ви нямаше, и тези места вече са заети.';

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
  testMode: 'ТЕСТОВ РЕЖИМ',
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
  peekSecured: _peekSecuredBg,
  ticketCount: _ticketCountBg,
  findBestSeats: _findBestSeatsBg,
  reselectSeats: _reselectSeatsBg,
  seatsFree: _seatsFreeBg,
  seatsLeftInSection: _seatsLeftInSectionBg,
  holdLapsedStillFree: _holdLapsedStillFreeBg,
  holdLapsedSomeTaken: _holdLapsedSomeTakenBg,
  holdLapsedAllTaken: _holdLapsedAllTakenBg,
  continueWithTotal: _continueWithTotalBg,
);
