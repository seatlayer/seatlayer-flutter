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

String _ticketCountRu(int count) =>
    count == 1 ? '$count билет' : '$count билета';

String _findBestSeatsRu(int count) =>
    count == 1 ? 'Найти $count лучшее место' : 'Найти $count лучших места';

String _reselectSeatsRu(int count) =>
    count == 1 ? 'Выбрать его снова' : 'Выбрать их снова';

String _continueWithTotalRu(String money) => 'Продолжить \u00b7 $money';

/// The `ru` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsRu = SeatLayerPickerStrings(
  close: 'Закрыть',
  overview: 'Площадка',
  backToVenue: 'Назад к площадке',
  cancel: 'Отмена',
  select: 'Выбрать',
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
  fitVenue: 'Вписать в экран',
  loading: 'Загружаем схему мест…',
  errorMessage: 'Схема мест не загрузилась',
  retry: 'Попробовать снова',
  hideLimitedView: 'Скрыть места с ограниченным обзором',
  colorblindSafe: 'Цвета для дальтоников',
  seatsLeft: _seatsLeftRu,
  moreCount: _moreCountRu,
  addMinutes: _addMinutesRu,
  fromPrice: _fromPriceRu,
  sightline: _sightlineRu,
  ticketCount: _ticketCountRu,
  findBestSeats: _findBestSeatsRu,
  reselectSeats: _reselectSeatsRu,
  continueWithTotal: _continueWithTotalRu,
);
