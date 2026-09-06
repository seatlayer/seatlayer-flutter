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

String _ticketCountBg(int count) =>
    count == 1 ? '$count билет' : '$count билета';

String _findBestSeatsBg(int count) => count == 1
    ? 'Намери $count най-добро място'
    : 'Намери $count най-добри места';

String _reselectSeatsBg(int count) =>
    count == 1 ? 'Изберете го отново' : 'Изберете ги отново';

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
  hideLimitedView: 'Скрий местата с ограничена видимост',
  colorblindSafe: 'Цветове за далтонисти',
  notAvailable: 'Не е налично',
  restrictedView: 'Ограничена видимост',
  obstructedView: 'Закрита видимост',
  premiumSeat: 'Премиум място',
  continueWord: 'Продължи',
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
  ticketCount: _ticketCountBg,
  findBestSeats: _findBestSeatsBg,
  reselectSeats: _reselectSeatsBg,
  continueWithTotal: _continueWithTotalBg,
);
