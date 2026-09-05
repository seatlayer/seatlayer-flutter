// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftSr(int count) => 'Преостало $count';

String _moreCountSr(int count) => '+$count више';

String _addMinutesSr(int minutes) => '+$minutes мин';

String _fromPriceSr(String money) => 'Од $money';

String _sightlineSr(String metres) => '≈ $metres m до бине';

String _ticketCountSr(int count) =>
    count == 1 ? '$count улазница' : '$count улазница';

String _findBestSeatsSr(int count) => count == 1
    ? 'Пронађи $count најбоље место'
    : 'Пронађи $count најбољих места';

String _reselectSeatsSr(int count) =>
    count == 1 ? 'Изаберите га поново' : 'Изаберите их поново';

String _continueWithTotalSr(String money) => 'Настави \u00b7 $money';

/// The `sr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSr = SeatLayerPickerStrings(
  close: 'Затвори',
  overview: 'Локација',
  backToVenue: 'Назад на објекат',
  cancel: 'Откажи',
  select: 'Изабери',
  removeSeat: 'Уклони место',
  viewFromHere: 'Поглед одавде',
  openVenue360: 'Отвори објекат у 360°',
  recentre: 'Поново центрирај на бину',
  viewFromYourSeat: 'поглед са вашег места',
  emptyTrayHint:
      'Додирните место на плану или препустите нама да изаберемо најбоља доступна.',
  anyTicketType: 'Било која врста улазнице',
  anyVenueZone: 'Било која зона објекта',
  bestSeats: 'Најбоља места',
  showLess: 'Прикажи мање',
  undo: 'Опозови',
  holdAndCheckout: 'Резервиши места и плати',
  poweredBy: 'Покреће SeatLayer',
  testMode: 'ТЕСТ РЕЖИМ',
  accessibility: 'Приступачност и боје',
  accessibilityTitle: 'Приступачност и боје',
  fitVenue: 'Прилагоди екрану',
  loading: 'Учитавање плана места…',
  errorMessage: 'План места се није учитао',
  retry: 'Покушај поново',
  accessRefresh: 'Освежи',
  hideLimitedView: 'Сакриј места са ограниченим погледом',
  colorblindSafe: 'Боје прилагођене далтонизму',
  continueWord: 'Настави',
  seatsLeft: _seatsLeftSr,
  moreCount: _moreCountSr,
  addMinutes: _addMinutesSr,
  fromPrice: _fromPriceSr,
  sightline: _sightlineSr,
  ticketCount: _ticketCountSr,
  findBestSeats: _findBestSeatsSr,
  reselectSeats: _reselectSeatsSr,
  continueWithTotal: _continueWithTotalSr,
);
