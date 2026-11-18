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

String _secureMoreAndCheckoutAr(int count) => 'أمّن $count إضافية وانتقل للدفع';

String _accessFreeCountAr(int count) => '$count متاح';

String _seatJustTakenByAnotherAr(String label) =>
    'حجز مشترٍ آخر المقعد $label للتو.';

String _peekSecuredAr(int count, String total) =>
    '✓ تم تأمين $count · $total. لن نخصم أي مبلغ بعد';

String _ticketCountAr(int count) =>
    count == 1 ? '$count تذكرة' : '$count تذكرة';

String _findBestSeatsAr(int count) =>
    count == 1 ? 'ابحث عن $count أفضل مقعد' : 'ابحث عن أفضل $count مقعد';

String _reselectSeatsAr(int count) =>
    count == 1 ? 'اختره مرة أخرى' : 'اخترها مرة أخرى';

String _seatsFreeAr(int count) => count == 1 ? '$count مقعد' : '$count مقعد';

String _seatsLeftInSectionAr(int count) =>
    count == 1 ? 'بقي $count مقعد' : 'بقي $count مقعد';

String _holdLapsedStillFreeAr(int count) => count == 1
    ? 'انتهى حجزك أثناء غيابك. لا يزال ذلك المقعد متاحًا.'
    : 'انتهى حجزك أثناء غيابك. لا تزال تلك المقاعد متاحة.';

String _holdLapsedSomeTakenAr(int count) => count == 1
    ? 'انتهى حجزك أثناء غيابك، وتم حجز $count مقعد من تلك المقاعد. الباقي لا يزال متاحًا.'
    : 'انتهى حجزك أثناء غيابك، وتم حجز $count مقعد من تلك المقاعد. الباقي لا يزال متاحًا.';

String _holdLapsedAllTakenAr(int count) => count == 1
    ? 'انتهى حجزك أثناء غيابك، وتم حجز ذلك المقعد.'
    : 'انتهى حجزك أثناء غيابك، وتم حجز تلك المقاعد.';

String _continueWithTotalAr(String money) => 'متابعة \u00b7 $money';

/// The `ar` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsAr = SeatLayerPickerStrings(
  close: 'إغلاق',
  overview: 'المكان',
  backToVenue: 'العودة إلى المكان',
  cancel: 'إلغاء',
  select: 'اختيار',
  removeSeat: 'إزالة مقعد',
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
  fitVenue: 'عرض المكان بالكامل',
  fitWholeVenue: 'عرض المكان بالكامل',
  loading: 'جارٍ تحميل خريطة المقاعد…',
  errorMessage: 'لم تُحمَّل خريطة المقاعد',
  retry: 'حاول مرة أخرى',
  accessRefresh: 'تحديث',
  noSeatsSelected: 'لم تُحدَّد أي مقاعد',
  findBestSeatsCta: 'ابحث عن أفضل المقاعد',
  organizerNote: 'ملاحظة المنظّم',
  accessiblePhysicalSeat: 'مقعد فعلي مهيأ لذوي الإعاقة',
  emptyWheelchairSpace: 'مكان شاغر لكرسي متحرك',
  findSeatsTogether: 'ابحث عن مقاعد متجاورة',
  aboutBestSeats: 'حول العثور على مقاعد متجاورة',
  closestGroupChosenInstantly: 'أقرب مجموعة متاحة، اختيرت فورًا.',
  hideLimitedView: 'إخفاء المقاعد ذات الرؤية المحدودة',
  colorblindSafe: 'ألوان ملائمة لعمى الألوان',
  notAvailable: 'غير متاح',
  restrictedView: 'رؤية محدودة',
  obstructedView: 'رؤية محجوبة',
  premiumSeat: 'مقعد مميز',
  continueWord: 'متابعة',
  allFloors: 'جميع الطوابق',
  previousSection: 'القطاع السابق',
  nextSection: 'القطاع التالي',
  addSeat: 'إضافة مقعد',
  added: 'أُضيف',
  sectionWord: 'القطاع',
  rowWord: 'الصف',
  seatWord: 'مقعد',
  seeItIn3D: 'شاهده بثلاثة أبعاد',
  viewFromThisSeat: 'المشهد من هذا المقعد',
  allPrices: 'جميع الأسعار',
  ticketType: 'نوع التذكرة',
  tierCompanionGuidance: 'يتطلب مكان الكرسي المتحرك المجاور',
  findingBestSeats: 'جارٍ البحث عن أفضل المقاعد…',
  findSeats: 'ابحث عن مقاعد',
  expandCart: 'فتح لوحة التذاكر',
  collapseCart: 'طي لوحة التذاكر',
  continueToCheckout: 'المتابعة إلى الدفع',
  secureMore: 'أمّن المزيد',
  selectSeats: 'اختيار المقاعد',
  pickYourSeats: 'اختر مقاعدك',
  salesClosedPill: 'أُغلق البيع',
  salesClosedCta: 'أُغلق البيع',
  confirmOrCancelSeat: 'أكّد هذا المقعد أو ألغِه',
  securingSeats: 'جارٍ تأمين مقاعدك…',
  openingCheckout: 'جارٍ فتح الدفع الآمن…',
  testModeExplained: 'الحجوزات هنا ليست حقيقية ولن نخصم أي بطاقة',
  displayOptions: 'خيارات العرض',
  companionSeatsNote: 'أماكن المرافقين المجاورة تبقى قابلة للاختيار',
  zoomIn: 'تكبير',
  zoomOut: 'تصغير',
  rotateVenue: 'اسحب لتدوير المكان',
  moveVenue: 'اسحب لتحريك المكان',
  mapView: 'الخريطة',
  flat2dMap: 'خريطة ثنائية الأبعاد مسطحة',
  interactive3dVenueView: 'عرض تفاعلي ثلاثي الأبعاد للمكان',
  venueView: 'عرض المكان',
  holdLapsedTitle: 'تم تحرير مقاعدك',
  salesClosed: 'أُغلق البيع',
  salesClosedCopy: 'انتهى بيع تذاكر هذه الفعالية.',
  salesClosedToast: 'البيع مغلق لهذه الفعالية.',
  soldOutEyebrow: 'هذه الفعالية',
  soldOutTitle: 'نفدت التذاكر',
  soldOutCopy: 'لا توجد حاليًا مقاعد مرقّمة متاحة لهذه الفعالية.',
  holdExpired: 'انتهت مدة الحجز المؤقت. تم تحرير المقاعد. اختر من جديد.',
  addingEllipsis: 'جارٍ الإضافة…',
  moreTimeAdded: 'تمت إضافة وقت. مقاعدك ما زالت محجوزة.',
  couldNotAddMoreTime: 'تعذّرت إضافة مزيد من الوقت. انتقل إلى الدفع الآن.',
  seatsJustTaken: 'حُجز مقعد أو أكثر للتو. اختر من جديد.',
  allSetTitle: 'كل شيء جاهز',
  confirmedAndOnWay: 'تم التأكيد. رسالة التأكيد في طريقها إليك.',
  backToMap: 'العودة إلى الخريطة',
  mapDidNotLoad: 'لم تُحمَّل خريطة المقاعد',
  checkConnection: 'تحقق من اتصالك وحاول مرة أخرى.',
  accessPausedTitle: 'هذه المقاعد محجوزة مؤقتًا الآن',
  accessPausedCopy:
      'أوقف المنظّم هذا الاختيار مؤقتًا. حاول مرة أخرى بعد بضع دقائق.',
  accessRevokedTitle: 'لم يعد رابط الوصول هذا فعّالًا',
  accessRevokedCopy:
      'اطلب رابطًا جديدًا ممن أرسله إليك لمواصلة حجز هذه المقاعد.',
  accessUnverifiedTitle: 'تعذّر التحقق من صلاحية وصولك',
  accessUnverifiedCopy:
      'ما زال بإمكانك حجز كل ما يظهر كمتاح. تواصل مع من أرسل لك الرابط للوصول إلى البقية.',
  generalAdmission: 'دخول عام',
  numberOfGuests: 'عدد الضيوف',
  chooseGuestsCopy:
      'اختر عدد الضيوف الذين سيجلسون معًا. تُحجز هذه الطاولة حصريًا لمجموعتك.',
  fewerGuests: 'ضيوف أقل',
  moreGuests: 'ضيوف أكثر',
  selectTable: 'اختيار الطاولة',
  updateTable: 'تحديث الطاولة',
  removeWord: 'إزالة',
  floorWord: 'الطابق',
  totalWord: 'الإجمالي',
  accessNeeds: <String, String>{
    'wheelchair': 'مكان لكرسي متحرك',
    'companion': 'مقعد مرافق',
    'semi-ambulatory': 'حركة محدودة',
    'designated-aisle': 'ممر / انتقال',
    'step-free': 'بدون درجات',
    'hearing': 'مساعدة سمعية',
    'cart': 'ترجمة فورية',
    'sign-language': 'لغة الإشارة',
    'low-vision': 'ضعف البصر',
    'sensory-friendly': 'مراعٍ للحواس',
    'plus-size': 'مقعد واسع',
    'lift-armrest': 'مسند قابل للرفع',
  },
  seatsLeft: _seatsLeftAr,
  moreCount: _moreCountAr,
  addMinutes: _addMinutesAr,
  fromPrice: _fromPriceAr,
  sightline: _sightlineAr,
  secureMoreAndCheckout: _secureMoreAndCheckoutAr,
  accessFreeCount: _accessFreeCountAr,
  seatJustTakenByAnother: _seatJustTakenByAnotherAr,
  peekSecured: _peekSecuredAr,
  ticketCount: _ticketCountAr,
  findBestSeats: _findBestSeatsAr,
  reselectSeats: _reselectSeatsAr,
  seatsFree: _seatsFreeAr,
  seatsLeftInSection: _seatsLeftInSectionAr,
  holdLapsedStillFree: _holdLapsedStillFreeAr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenAr,
  holdLapsedAllTaken: _holdLapsedAllTakenAr,
  continueWithTotal: _continueWithTotalAr,
);
