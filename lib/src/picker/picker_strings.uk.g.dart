// GENERATED — do not edit.
//
// Source: design/locale_strings.json (uk)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftUk(int count) => 'Залишилося $count';

String _moreCountUk(int count) => '+$count ще';

String _fromPriceUk(String money) => 'Від $money';

String _ticketCountUk(int count) =>
    count == 1 ? '$count квиток' : '$count квитка';

String _findBestSeatsUk(int count) => count == 1
    ? 'Знайти $count найкраще місце'
    : 'Знайти $count найкращого місця';

String _continueWithTotalUk(String money) => 'Продовжити \u00b7 $money';

/// The `uk` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsUk = SeatLayerPickerStrings(
  close: 'Закрити',
  overview: 'Майданчик',
  backToVenue: 'Назад до майданчика',
  cancel: 'Скасувати',
  select: 'Обрати',
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
  fitVenue: 'Вписати в екран',
  loading: 'Завантажуємо схему місць…',
  errorMessage: 'Схема місць не завантажилася',
  retry: 'Спробувати ще раз',
  hideLimitedView: 'Сховати місця з обмеженим оглядом',
  colorblindSafe: 'Кольори для дальтоніків',
  seatsLeft: _seatsLeftUk,
  moreCount: _moreCountUk,
  fromPrice: _fromPriceUk,
  ticketCount: _ticketCountUk,
  findBestSeats: _findBestSeatsUk,
  continueWithTotal: _continueWithTotalUk,
);
