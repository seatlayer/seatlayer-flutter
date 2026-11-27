// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ar)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableAr(String label) =>
    'لم يعد $label متاحًا. اختر مقعدًا آخر.';

String _labelsNoLongerAvailableAr(String labels) =>
    'لم تعد $labels متاحة. اختر مجموعة أخرى.';

String _couldNotFindSeatsTogetherAr(int count) =>
    'لم نجد $count مقاعد متجاورة. جرّب عددًا أقل أو نوع تذكرة آخر.';

String _maxTicketsForOrderAr(int count) =>
    'يمكنك اختيار $count تذكرة كحد أقصى لهذا الطلب.';

String _couldNotRemoveLabelAr(String label) =>
    'تعذّرت إزالة $label. حجزك المؤقت لم يتغير.';

String _peekSecuredAr(int count, String total) =>
    '✓ تم تأمين $count · $total. لن نخصم أي مبلغ بعد';

String _venueMapAr(String venue) => 'خريطة مقاعد $venue';

String _accessibleStepAr(int index, int total) => '$index من $total';

String _chooseMinMaxGuestsAr(int min, int max) =>
    'اختر عدد الضيوف بين $min و$max.';

String _chooseMoreAr(int count) => 'اختر $count إضافية';

String _seatsHeldForNeedMoreTimeAr(String time) =>
    'مقاعدك محجوزة مؤقتًا لمدة $time. هل تحتاج إلى مزيد من الوقت؟';

String _accessNeedWithCountAr(String need, int count) => '$need · $count';

String _ticketCountAr(int count) => switch (pickerPluralCategory('ar', count)) {
  PickerPluralCategory.zero => '$count تذكرة',
  PickerPluralCategory.one => '$count تذكرة',
  PickerPluralCategory.two => '$count تذكرتان',
  PickerPluralCategory.few => '$count تذاكر',
  PickerPluralCategory.many => '$count تذكرة',
  _ => '$count تذكرة',
};

String _findBestSeatsAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'ابحث عن $count أفضل مقعد',
      PickerPluralCategory.one => 'ابحث عن $count أفضل مقعد',
      PickerPluralCategory.two => 'ابحث عن أفضل $count مقعدين',
      PickerPluralCategory.few => 'ابحث عن أفضل $count مقاعد',
      PickerPluralCategory.many => 'ابحث عن أفضل $count مقعدًا',
      _ => 'ابحث عن أفضل $count مقعد',
    };

String _reselectSeatsAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'اخترها مرة أخرى',
      PickerPluralCategory.one => 'اختره مرة أخرى',
      PickerPluralCategory.two => 'اخترهما مرة أخرى',
      PickerPluralCategory.few => 'اخترها مرة أخرى',
      PickerPluralCategory.many => 'اخترها مرة أخرى',
      _ => 'اخترها مرة أخرى',
    };

String _seatsFreeAr(int count) => switch (pickerPluralCategory('ar', count)) {
  PickerPluralCategory.zero => '$count مقعد',
  PickerPluralCategory.one => '$count مقعد',
  PickerPluralCategory.two => '$count مقعدان',
  PickerPluralCategory.few => '$count مقاعد',
  PickerPluralCategory.many => '$count مقعدًا',
  _ => '$count مقعد',
};

String _seatsLeftInSectionAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'بقي $count مقعد',
      PickerPluralCategory.one => 'بقي $count مقعد',
      PickerPluralCategory.two => 'بقي $count مقعدان',
      PickerPluralCategory.few => 'بقيت $count مقاعد',
      PickerPluralCategory.many => 'بقي $count مقعدًا',
      _ => 'بقي $count مقعد',
    };

String _holdLapsedStillFreeAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero =>
        'انتهى حجزك أثناء غيابك. لا تزال تلك المقاعد متاحة.',
      PickerPluralCategory.one =>
        'انتهى حجزك أثناء غيابك. لا يزال ذلك المقعد متاحًا.',
      PickerPluralCategory.two =>
        'انتهى حجزك أثناء غيابك. لا يزال هذان المقعدان متاحين.',
      PickerPluralCategory.few =>
        'انتهى حجزك أثناء غيابك. لا تزال تلك المقاعد متاحة.',
      PickerPluralCategory.many =>
        'انتهى حجزك أثناء غيابك. لا تزال تلك المقاعد متاحة.',
      _ => 'انتهى حجزك أثناء غيابك. لا تزال تلك المقاعد متاحة.',
    };

String _holdLapsedSomeTakenAr(int count) => switch (pickerPluralCategory(
  'ar',
  count,
)) {
  PickerPluralCategory.zero =>
    'انتهى حجزك أثناء غيابك، وتم حجز $count مقعد من تلك المقاعد. الباقي لا يزال متاحًا.',
  PickerPluralCategory.one =>
    'انتهى حجزك أثناء غيابك، وتم حجز $count مقعد من تلك المقاعد. الباقي لا يزال متاحًا.',
  PickerPluralCategory.two =>
    'انتهى حجزك أثناء غيابك، وتم حجز $count مقعدين من تلك المقاعد. الباقي لا يزال متاحًا.',
  PickerPluralCategory.few =>
    'انتهى حجزك أثناء غيابك، وتم حجز $count مقاعد من تلك المقاعد. الباقي لا يزال متاحًا.',
  PickerPluralCategory.many =>
    'انتهى حجزك أثناء غيابك، وتم حجز $count مقعدًا من تلك المقاعد. الباقي لا يزال متاحًا.',
  _ =>
    'انتهى حجزك أثناء غيابك، وتم حجز $count مقعد من تلك المقاعد. الباقي لا يزال متاحًا.',
};

String _holdLapsedAllTakenAr(int count) => switch (pickerPluralCategory(
  'ar',
  count,
)) {
  PickerPluralCategory.zero => 'انتهى حجزك أثناء غيابك، وتم حجز تلك المقاعد.',
  PickerPluralCategory.one => 'انتهى حجزك أثناء غيابك، وتم حجز ذلك المقعد.',
  PickerPluralCategory.two => 'انتهى حجزك أثناء غيابك، وتم حجز هذين المقعدين.',
  PickerPluralCategory.few => 'انتهى حجزك أثناء غيابك، وتم حجز تلك المقاعد.',
  PickerPluralCategory.many => 'انتهى حجزك أثناء غيابك، وتم حجز تلك المقاعد.',
  _ => 'انتهى حجزك أثناء غيابك، وتم حجز تلك المقاعد.',
};

String _accessibleSectionsAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => '$count قطاع',
      PickerPluralCategory.one => '$count قطاع',
      PickerPluralCategory.two => '$count قطاعان',
      PickerPluralCategory.few => '$count قطاعات',
      PickerPluralCategory.many => '$count قطاعًا',
      _ => '$count قطاع',
    };

String _placesAvailableAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => '$count مكان متاح حاليًا',
      PickerPluralCategory.one => '$count مكان متاح حاليًا',
      PickerPluralCategory.two => '$count مكانان متاحان حاليًا',
      PickerPluralCategory.few => '$count أماكن متاحة حاليًا',
      PickerPluralCategory.many => '$count مكانًا متاحًا حاليًا',
      _ => '$count مكان متاح حاليًا',
    };

String _removeTicketsAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'إزالة $count تذكرة',
      PickerPluralCategory.one => 'إزالة $count تذكرة',
      PickerPluralCategory.two => 'إزالة $count تذكرتين',
      PickerPluralCategory.few => 'إزالة $count تذاكر',
      PickerPluralCategory.many => 'إزالة $count تذكرة',
      _ => 'إزالة $count تذكرة',
    };

String _holdMinutesLeftAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'بقيت $count دقيقة',
      PickerPluralCategory.one => 'بقيت $count دقيقة',
      PickerPluralCategory.two => 'بقيت $count دقيقتان',
      PickerPluralCategory.few => 'بقيت $count دقائق',
      PickerPluralCategory.many => 'بقيت $count دقيقة',
      _ => 'بقيت $count دقيقة',
    };

String _holdSecondsLeftAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'بقيت $count ثانية',
      PickerPluralCategory.one => 'بقيت $count ثانية',
      PickerPluralCategory.two => 'بقيت $count ثانيتان',
      PickerPluralCategory.few => 'بقيت $count ثوانٍ',
      PickerPluralCategory.many => 'بقيت $count ثانية',
      _ => 'بقيت $count ثانية',
    };

String _holdLapsedBodyAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'كانت محجوزة مؤقتًا لمدة $count دقيقة.',
      PickerPluralCategory.one => 'كانت محجوزة مؤقتًا لمدة $count دقيقة.',
      PickerPluralCategory.two => 'كانت محجوزة مؤقتًا لمدة $count دقيقتين.',
      PickerPluralCategory.few => 'كانت محجوزة مؤقتًا لمدة $count دقائق.',
      PickerPluralCategory.many => 'كانت محجوزة مؤقتًا لمدة $count دقيقة.',
      _ => 'كانت محجوزة مؤقتًا لمدة $count دقيقة.',
    };

String _seatsNotRecoveredAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => 'تعذّرت استعادة $count مقعد',
      PickerPluralCategory.one => 'تعذّرت استعادة $count مقعد',
      PickerPluralCategory.two => 'تعذّرت استعادة $count مقعدين',
      PickerPluralCategory.few => 'تعذّرت استعادة $count مقاعد',
      PickerPluralCategory.many => 'تعذّرت استعادة $count مقعدًا',
      _ => 'تعذّرت استعادة $count مقعد',
    };

String _activeFiltersAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => '$count عامل تصفية',
      PickerPluralCategory.one => '$count عامل تصفية',
      PickerPluralCategory.two => '$count عاملا تصفية',
      PickerPluralCategory.few => '$count عوامل تصفية',
      PickerPluralCategory.many => '$count عامل تصفية',
      _ => '$count عامل تصفية',
    };

String _accessibilityFiltersActiveAr(int count) =>
    switch (pickerPluralCategory('ar', count)) {
      PickerPluralCategory.zero => '$count عامل تصفية مفعّل لإمكانية الوصول',
      PickerPluralCategory.one => '$count عامل تصفية مفعّل لإمكانية الوصول',
      PickerPluralCategory.two => '$count عاملا تصفية مفعّلان لإمكانية الوصول',
      PickerPluralCategory.few => '$count عوامل تصفية مفعّلة لإمكانية الوصول',
      PickerPluralCategory.many => '$count عامل تصفية مفعّل لإمكانية الوصول',
      _ => '$count عامل تصفية مفعّل لإمكانية الوصول',
    };

String _onlyLeftAr(int count) => switch (pickerPluralCategory('ar', count)) {
  PickerPluralCategory.zero => 'بقي $count مقعد',
  PickerPluralCategory.one => 'بقي $count مقعد',
  PickerPluralCategory.two => 'بقي $count مقعدان',
  PickerPluralCategory.few => 'بقيت $count مقاعد',
  PickerPluralCategory.many => 'بقي $count مقعدًا',
  _ => 'بقي $count مقعد',
};

String _maintenancePausedAr(int count) => switch (pickerPluralCategory(
  'ar',
  count,
)) {
  PickerPluralCategory.zero =>
    'الحجز متوقف مؤقتًا للصيانة. يُرجى المحاولة مجددًا بعد $count دقيقة.',
  PickerPluralCategory.one =>
    'الحجز متوقف مؤقتًا للصيانة. يُرجى المحاولة مجددًا بعد نحو $count دقيقة.',
  PickerPluralCategory.two =>
    'الحجز متوقف مؤقتًا للصيانة. يُرجى المحاولة مجددًا بعد نحو $count دقيقتين.',
  PickerPluralCategory.few =>
    'الحجز متوقف مؤقتًا للصيانة. يُرجى المحاولة مجددًا بعد نحو $count دقائق.',
  PickerPluralCategory.many =>
    'الحجز متوقف مؤقتًا للصيانة. يُرجى المحاولة مجددًا بعد نحو $count دقيقة.',
  _ =>
    'الحجز متوقف مؤقتًا للصيانة. يُرجى المحاولة مجددًا بعد نحو $count دقيقة.',
};

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
  viewGroupTitle: 'العرض',
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
  ticketPrices: 'أسعار التذاكر',
  yourSeats: 'مقاعدك',
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
  ticketTypeSoldOut: 'نفد هذا النوع من التذاكر. جرّب نوعًا آخر.',
  seatsNoLongerAvailableTryAnother:
      'لم تعد تلك المقاعد متاحة. جرّب كمية أخرى أو نوع تذكرة آخر.',
  companionPairRequired: 'اختر مكان الكرسي المتحرك المجاور مع كل تذكرة مرافق.',
  ticketOptionNotApplicable: 'خيار التذكرة هذا غير متاح للمقعد المحدد.',
  maintenancePausedShortly:
      'الحجز متوقف مؤقتًا لبضع دقائق للصيانة. يُرجى المحاولة مجددًا بعد قليل.',
  guestsOnly: 'هذه الفعالية مخصصة للضيوف المدعوين.',
  guestChoiceClosed: 'اختيار المقاعد غير متاح الآن.',
  maxOneTicketForOrder: 'يمكنك اختيار تذكرة واحدة كحد أقصى لهذا الطلب.',
  tooManyAttempts: 'محاولات كثيرة جدًا. انتظر لحظة وأعد المحاولة.',
  seatHeldForRenewal:
      'أحد هذه المقاعد محجوز لحامل تذكرة موسمية لا يزال بإمكانه التجديد. اختر مقعدًا آخر.',
  seatUnavailable: 'هذا المقعد غير متاح.',
  eventUnavailable: 'لا يمكن حجز التذاكر هنا حاليًا.',
  savedSeatsNotRestored:
      'تعذّرت استعادة مقاعدك السابقة. يرجى الاختيار مرة أخرى.',
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
  adjustSelection: 'تعديل اختيار المقاعد',
  backToSeatMap: 'العودة إلى خريطة المقاعد',
  chooseSeats: 'اختر مقاعدك',
  chooseTickets: 'اختر التذاكر',
  placeWord: 'مكان',
  guestsWord: 'الضيوف',
  tableWord: 'طاولة',
  ticketWord: 'تذكرة',
  passport: 'بطاقة المقعد',
  venue3D: '3D',
  venueZone: 'منطقة في المكان',
  venueMapHint:
      'تُختار المقاعد بعناصر التحكم حول الخريطة: شريط الأسعار فوقها، وعناصر التحكم بالقطاعات تحتها، ولوحة التذاكر في أسفلها.',
  previousSeat: 'المقعد السابق',
  nextSeat: 'المقعد التالي',
  orbitMode: 'تدوير المكان',
  panMode: 'تحريك المكان',
  openInteractive3dVenue: 'فتح العرض التفاعلي ثلاثي الأبعاد للمكان',
  showSeatsFor: 'عرض المقاعد المناسبة لـ',
  accessJumpFirstSection: 'الانتقال إلى القطاع الأول',
  accessJumpNextSection: 'الانتقال إلى القطاع التالي',
  fewerTickets: 'تذاكر أقل',
  moreTickets: 'تذاكر أكثر',
  addTickets: 'إضافة تذاكر',
  noSelectableSeats: 'لا توجد حاليًا مقاعد متاحة للاختيار.',
  confirmYourTickets: 'أكّد تذاكرك',
  seatsSecuredOpeningCheckout: 'تم تأمين المقاعد. جارٍ فتح الدفع…',
  holdInCheckoutTitle: 'مقاعدك في الدفع بالفعل',
  holdInCheckoutBody:
      'أكمل الدفع للاحتفاظ بها. لاختيار مقاعد أخرى، حرّر هذه المقاعد أولًا — ستعود للبيع.',
  releaseAndChangeSeats: 'تحرير المقاعد وتغييرها',
  holdAlreadyHeldTitle: 'مقاعدك محجوزة مؤقتًا بالفعل',
  holdAlreadyHeldBody: 'تابع إلى الدفع للاحتفاظ بها.',
  accessExpiredTitle: 'انتهت جلسة اختيار المقاعد',
  accessExpiredCopy:
      'أعد تحميل خريطة المقاعد للمتابعة. المقاعد الموجودة في سلتك تبقى محجوزة حتى ينتهي المؤقت.',
  dismissError: 'إغلاق رسالة الخطأ',
  testModeLong: 'وضع الاختبار · لا يُحجز أي شيء',
  seatRemoved: 'تمت إزالة التذكرة',
  reloadSeatMap: 'إعادة تحميل خريطة المقاعد',
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
  labelNoLongerAvailable: _labelNoLongerAvailableAr,
  labelsNoLongerAvailable: _labelsNoLongerAvailableAr,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherAr,
  maxTicketsForOrder: _maxTicketsForOrderAr,
  couldNotRemoveLabel: _couldNotRemoveLabelAr,
  peekSecured: _peekSecuredAr,
  venueMap: _venueMapAr,
  accessibleStep: _accessibleStepAr,
  chooseMinMaxGuests: _chooseMinMaxGuestsAr,
  chooseMore: _chooseMoreAr,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeAr,
  accessNeedWithCount: _accessNeedWithCountAr,
  ticketCount: _ticketCountAr,
  findBestSeats: _findBestSeatsAr,
  reselectSeats: _reselectSeatsAr,
  seatsFree: _seatsFreeAr,
  seatsLeftInSection: _seatsLeftInSectionAr,
  holdLapsedStillFree: _holdLapsedStillFreeAr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenAr,
  holdLapsedAllTaken: _holdLapsedAllTakenAr,
  accessibleSections: _accessibleSectionsAr,
  placesAvailable: _placesAvailableAr,
  removeTickets: _removeTicketsAr,
  holdMinutesLeft: _holdMinutesLeftAr,
  holdSecondsLeft: _holdSecondsLeftAr,
  holdLapsedBody: _holdLapsedBodyAr,
  seatsNotRecovered: _seatsNotRecoveredAr,
  activeFilters: _activeFiltersAr,
  accessibilityFiltersActive: _accessibilityFiltersActiveAr,
  onlyLeft: _onlyLeftAr,
  maintenancePaused: _maintenancePausedAr,
  continueWithTotal: _continueWithTotalAr,
);
