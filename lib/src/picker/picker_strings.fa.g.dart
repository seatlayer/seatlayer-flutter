// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fa)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftFa(int count) => '$count باقی مانده';

String _moreCountFa(int count) => '+$count بیشتر';

String _fromPriceFa(String money) => 'از $money';

String _ticketCountFa(int count) => count == 1 ? '$count بلیت' : '$count بلیت';

String _findBestSeatsFa(int count) => count == 1
    ? 'پیدا کردن $count بهترین صندلی'
    : 'پیدا کردن $count صندلی برتر';

String _continueWithTotalFa(String money) => 'ادامه \u00b7 $money';

/// The `fa` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsFa = SeatLayerPickerStrings(
  close: 'بستن',
  overview: 'مکان',
  backToVenue: 'بازگشت به سالن',
  cancel: 'لغو',
  select: 'انتخاب',
  viewFromHere: 'دید از اینجا',
  openVenue360: 'باز کردن سالن در ۳۶۰ درجه',
  recentre: 'بازگرداندن مرکز به صحنه',
  viewFromYourSeat: 'نمای از صندلی شما',
  emptyTrayHint:
      'روی صندلی‌ای در نقشه بزنید، یا بگذارید بهترین صندلی‌های موجود را برایتان انتخاب کنیم.',
  anyTicketType: 'هر نوع بلیت',
  anyVenueZone: 'هر منطقهٔ سالن',
  bestSeats: 'بهترین صندلی‌ها',
  showLess: 'نمایش کمتر',
  undo: 'واگرد',
  holdAndCheckout: 'نگه‌داشتن صندلی‌ها و پرداخت',
  poweredBy: 'قدرت‌گرفته از SeatLayer',
  testMode: 'حالت آزمایشی',
  accessibility: 'گزینه‌های دسترس‌پذیری و رنگ',
  accessibilityTitle: 'گزینه‌های دسترس‌پذیری و رنگ',
  fitVenue: 'جا دادن در صفحه',
  loading: 'در حال بارگذاری نقشهٔ صندلی‌ها…',
  errorMessage: 'نقشهٔ صندلی‌ها بارگذاری نشد',
  retry: 'دوباره تلاش کنید',
  hideLimitedView: 'پنهان کردن صندلی‌های با دید محدود',
  colorblindSafe: 'رنگ‌های مناسب کوررنگی',
  seatsLeft: _seatsLeftFa,
  moreCount: _moreCountFa,
  fromPrice: _fromPriceFa,
  ticketCount: _ticketCountFa,
  findBestSeats: _findBestSeatsFa,
  continueWithTotal: _continueWithTotalFa,
);
