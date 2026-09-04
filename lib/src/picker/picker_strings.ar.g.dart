// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ar)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftAr(int count) => 'بقي $count';

String _moreCountAr(int count) => '+$count أخرى';

String _addMinutesAr(int minutes) => '+$minutes دقيقة';

String _fromPriceAr(String money) => 'ابتداءً من $money';

String _sightlineAr(String metres) => '‏≈ $metres م إلى المسرح';

String _ticketCountAr(int count) =>
    count == 1 ? '$count تذكرة' : '$count تذكرة';

String _findBestSeatsAr(int count) =>
    count == 1 ? 'ابحث عن $count أفضل مقعد' : 'ابحث عن أفضل $count مقعد';

String _reselectSeatsAr(int count) =>
    count == 1 ? 'اختره مرة أخرى' : 'اخترها مرة أخرى';

String _continueWithTotalAr(String money) => 'متابعة \u00b7 $money';

/// The `ar` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsAr = SeatLayerPickerStrings(
  close: 'إغلاق',
  overview: 'المكان',
  backToVenue: 'العودة إلى المكان',
  cancel: 'إلغاء',
  select: 'اختيار',
  viewFromHere: 'المشهد من هنا',
  openVenue360: 'افتح المكان بزاوية 360°',
  recentre: 'إعادة التمركز على المسرح',
  viewFromYourSeat: 'المنظر من مقعدك',
  emptyTrayHint:
      'انقر على مقعد في الخريطة، أو دعنا نختار لك أفضل المقاعد المتاحة.',
  anyTicketType: 'أي نوع تذكرة',
  anyVenueZone: 'أي منطقة في المكان',
  bestSeats: 'أفضل المقاعد',
  showLess: 'عرض أقل',
  undo: 'تراجع',
  holdAndCheckout: 'احجز المقاعد وانتقل للدفع',
  poweredBy: 'مدعوم من SeatLayer',
  testMode: 'وضع الاختبار',
  accessibility: 'خيارات إمكانية الوصول والألوان',
  accessibilityTitle: 'خيارات إمكانية الوصول والألوان',
  fitVenue: 'ملاءمة الشاشة',
  loading: 'جارٍ تحميل خريطة المقاعد…',
  errorMessage: 'لم تُحمَّل خريطة المقاعد',
  retry: 'حاول مرة أخرى',
  hideLimitedView: 'إخفاء المقاعد ذات الرؤية المحدودة',
  colorblindSafe: 'ألوان ملائمة لعمى الألوان',
  seatsLeft: _seatsLeftAr,
  moreCount: _moreCountAr,
  addMinutes: _addMinutesAr,
  fromPrice: _fromPriceAr,
  sightline: _sightlineAr,
  ticketCount: _ticketCountAr,
  findBestSeats: _findBestSeatsAr,
  reselectSeats: _reselectSeatsAr,
  continueWithTotal: _continueWithTotalAr,
);
