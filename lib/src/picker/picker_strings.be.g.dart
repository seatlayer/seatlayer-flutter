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

String _ticketCountBe(int count) =>
    count == 1 ? '$count білет' : '$count білета';

String _findBestSeatsBe(int count) =>
    count == 1 ? 'Знайсці $count лепшае месца' : 'Знайсці $count лепшага месца';

String _reselectSeatsBe(int count) =>
    count == 1 ? 'Выбраць яго зноў' : 'Выбраць іх зноў';

String _continueWithTotalBe(String money) => 'Працягнуць \u00b7 $money';

/// The `be` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsBe = SeatLayerPickerStrings(
  close: 'Закрыць',
  overview: 'Пляцоўка',
  backToVenue: 'Назад да пляцоўкі',
  cancel: 'Скасаваць',
  select: 'Выбраць',
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
  fitVenue: 'Упісаць у экран',
  loading: 'Загружаем схему месцаў…',
  errorMessage: 'Схема месцаў не загрузілася',
  retry: 'Паспрабаваць зноў',
  hideLimitedView: 'Схаваць месцы з абмежаваным аглядам',
  colorblindSafe: 'Колеры для дальтонікаў',
  continueWord: 'Працягнуць',
  seatsLeft: _seatsLeftBe,
  moreCount: _moreCountBe,
  addMinutes: _addMinutesBe,
  fromPrice: _fromPriceBe,
  sightline: _sightlineBe,
  ticketCount: _ticketCountBe,
  findBestSeats: _findBestSeatsBe,
  reselectSeats: _reselectSeatsBe,
  continueWithTotal: _continueWithTotalBe,
);
