// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fa)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftFa(int count) => '$count باقی مانده';

String _moreCountFa(int count) => '+$count بیشتر';

String _addMinutesFa(int minutes) => '+$minutes دقیقه';

String _fromPriceFa(String money) => 'از $money';

String _sightlineFa(String metres) => '‏≈ $metres متر تا صحنه';

String _secureMoreAndCheckoutFa(int count) => '$count تای دیگر تثبیت و پرداخت';

String _accessFreeCountFa(int count) => '$count آزاد';

String _seatJustTakenByAnotherFa(String label) =>
    'صندلی $label هم‌اکنون توسط خریدار دیگری گرفته شد.';

String _labelNoLongerAvailableFa(String label) =>
    '$label دیگر در دسترس نیست. صندلی دیگری انتخاب کنید.';

String _labelsNoLongerAvailableFa(String labels) =>
    '$labels دیگر در دسترس نیستند. گروه دیگری انتخاب کنید.';

String _couldNotFindSeatsTogetherFa(int count) =>
    '$count صندلی کنار هم پیدا نشد. تعداد کمتر یا نوع بلیت دیگری را امتحان کنید.';

String _couldNotRemoveLabelFa(String label) =>
    '$label حذف نشد. نگه‌داشت شما تغییری نکرده است.';

String _peekSecuredFa(int count, String total) =>
    '✓ $count تثبیت شد · $total. هنوز مبلغی کسر نمی‌شود';

String _venueMapFa(String venue) => 'نقشهٔ صندلی‌های $venue';

String _accessibleStepFa(int index, int total) => '$index از $total';

String _chooseMinMaxGuestsFa(int min, int max) =>
    'بین $min تا $max مهمان انتخاب کنید.';

String _chooseMoreFa(int count) => '$count تای دیگر انتخاب کنید';

String _seatsHeldForNeedMoreTimeFa(String time) =>
    'صندلی‌های شما برای $time نگه داشته شده‌اند. زمان بیشتری لازم دارید؟';

String _accessNeedWithCountFa(String need, int count) => '$need · $count';

String _ticketCountFa(int count) => switch (pickerPluralCategory('fa', count)) {
  PickerPluralCategory.one => '$count بلیت',
  _ => '$count بلیت',
};

String _findBestSeatsFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => 'پیدا کردن $count بهترین صندلی',
      _ => 'پیدا کردن $count صندلی برتر',
    };

String _reselectSeatsFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => 'دوباره انتخابش کنید',
      _ => 'دوباره انتخابشان کنید',
    };

String _seatsFreeFa(int count) => switch (pickerPluralCategory('fa', count)) {
  PickerPluralCategory.one => '$count صندلی',
  _ => '$count صندلی',
};

String _seatsLeftInSectionFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count صندلی باقی مانده',
      _ => '$count صندلی باقی مانده',
    };

String _holdLapsedStillFreeFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one =>
        'رزرو شما در زمان نبودنتان منقضی شد. آن صندلی هنوز آزاد است.',
      _ => 'رزرو شما در زمان نبودنتان منقضی شد. آن صندلی‌ها هنوز آزاد هستند.',
    };

String _holdLapsedSomeTakenFa(int count) => switch (pickerPluralCategory(
  'fa',
  count,
)) {
  PickerPluralCategory.one =>
    'رزرو شما در زمان نبودنتان منقضی شد و $count صندلی از آن‌ها گرفته شده است. بقیه هنوز آزاد هستند.',
  _ =>
    'رزرو شما در زمان نبودنتان منقضی شد و $count صندلی از آن‌ها گرفته شده است. بقیه هنوز آزاد هستند.',
};

String _holdLapsedAllTakenFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one =>
        'رزرو شما در زمان نبودنتان منقضی شد و آن صندلی گرفته شده است.',
      _ => 'رزرو شما در زمان نبودنتان منقضی شد و آن صندلی‌ها گرفته شده‌اند.',
    };

String _accessibleSectionsFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count بخش',
      _ => '$count بخش',
    };

String _placesAvailableFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count جایگاه هم‌اکنون در دسترس است',
      _ => '$count جایگاه هم‌اکنون در دسترس است',
    };

String _removeTicketsFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => 'حذف $count بلیت',
      _ => 'حذف $count بلیت',
    };

String _holdMinutesLeftFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count دقیقه باقی مانده',
      _ => '$count دقیقه باقی مانده',
    };

String _holdSecondsLeftFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count ثانیه باقی مانده',
      _ => '$count ثانیه باقی مانده',
    };

String _holdLapsedBodyFa(int count) => switch (pickerPluralCategory(
  'fa',
  count,
)) {
  PickerPluralCategory.one => 'این صندلی‌ها $count دقیقه نگه داشته شده بودند.',
  _ => 'این صندلی‌ها $count دقیقه نگه داشته شده بودند.',
};

String _seatsNotRecoveredFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count صندلی بازیابی نشد',
      _ => '$count صندلی بازیابی نشد',
    };

String _activeFiltersFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count فیلتر',
      _ => '$count فیلتر',
    };

String _accessibilityFiltersActiveFa(int count) =>
    switch (pickerPluralCategory('fa', count)) {
      PickerPluralCategory.one => '$count فیلتر دسترس‌پذیری فعال است',
      _ => '$count فیلتر دسترس‌پذیری فعال است',
    };

String _onlyLeftFa(int count) => switch (pickerPluralCategory('fa', count)) {
  PickerPluralCategory.one => '$count صندلی باقی مانده',
  _ => '$count صندلی باقی مانده',
};

String _maintenancePausedFa(int count) => switch (pickerPluralCategory(
  'fa',
  count,
)) {
  PickerPluralCategory.one =>
    'رزرو به‌دلیل نگهداری موقتاً متوقف شده است. لطفاً حدود $count دقیقه دیگر دوباره تلاش کنید.',
  _ =>
    'رزرو به‌دلیل نگهداری موقتاً متوقف شده است. لطفاً حدود $count دقیقه دیگر دوباره تلاش کنید.',
};

String _continueWithTotalFa(String money) => 'ادامه \u00b7 $money';

/// The `fa` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsFa = SeatLayerPickerStrings(
  close: 'بستن',
  overview: 'مکان',
  backToVenue: 'بازگشت به سالن',
  cancel: 'لغو',
  select: 'انتخاب',
  removeSeat: 'حذف صندلی',
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
  fitVenue: 'نمایش کل مکان',
  fitWholeVenue: 'نمایش کل مکان',
  loading: 'در حال بارگذاری نقشهٔ صندلی‌ها…',
  errorMessage: 'نقشهٔ صندلی‌ها بارگذاری نشد',
  retry: 'دوباره تلاش کنید',
  accessRefresh: 'تازه‌سازی',
  noSeatsSelected: 'صندلی‌ای انتخاب نشده است',
  findBestSeatsCta: 'یافتن بهترین صندلی‌ها',
  organizerNote: 'یادداشت برگزارکننده',
  accessiblePhysicalSeat: 'صندلی فیزیکی مناسب کم‌توانان',
  emptyWheelchairSpace: 'جایگاه خالی ویلچر',
  findSeatsTogether: 'صندلی‌های کنار هم را پیدا کن',
  aboutBestSeats: 'درباره یافتن صندلی‌های کنار هم',
  closestGroupChosenInstantly: 'نزدیک‌ترین گروه موجود، بی‌درنگ انتخاب شد.',
  hideLimitedView: 'پنهان کردن صندلی‌های با دید محدود',
  colorblindSafe: 'رنگ‌های مناسب کوررنگی',
  notAvailable: 'در دسترس نیست',
  viewGroupTitle: 'نمایش',
  restrictedView: 'دید محدود',
  obstructedView: 'دید مسدود',
  premiumSeat: 'صندلی ویژه',
  continueWord: 'ادامه',
  allFloors: 'همهٔ طبقه‌ها',
  previousSection: 'بخش قبلی',
  nextSection: 'بخش بعدی',
  addSeat: 'افزودن صندلی',
  added: 'افزوده شد',
  sectionWord: 'بخش',
  rowWord: 'ردیف',
  seatWord: 'صندلی',
  seeItIn3D: 'دیدن به‌صورت سه‌بعدی',
  viewFromThisSeat: 'دید از این صندلی',
  allPrices: 'همهٔ قیمت‌ها',
  ticketPrices: 'قیمت بلیت‌ها',
  yourSeats: 'صندلی‌های شما',
  ticketType: 'نوع بلیت',
  tierCompanionGuidance: 'به جایگاه ویلچر مجاور نیاز دارد',
  findingBestSeats: 'در حال یافتن بهترین صندلی‌ها…',
  findSeats: 'یافتن صندلی',
  expandCart: 'باز کردن پنل بلیت',
  collapseCart: 'جمع کردن پنل بلیت',
  continueToCheckout: 'ادامه به پرداخت',
  secureMore: 'تثبیت بیشتر',
  selectSeats: 'انتخاب صندلی‌ها',
  pickYourSeats: 'صندلی‌های خود را انتخاب کنید',
  salesClosedPill: 'فروش بسته شد',
  salesClosedCta: 'فروش بسته شد',
  confirmOrCancelSeat: 'این صندلی را تأیید یا لغو کنید',
  securingSeats: 'در حال تثبیت صندلی‌های شما…',
  openingCheckout: 'در حال باز کردن پرداخت امن…',
  testModeExplained: 'رزروهای اینجا واقعی نیستند و هیچ کارتی شارژ نمی‌شود',
  displayOptions: 'گزینه‌های نمایش',
  companionSeatsNote: 'جایگاه‌های همراه در کنار آن‌ها همچنان قابل انتخاب است',
  zoomIn: 'بزرگ‌نمایی',
  zoomOut: 'کوچک‌نمایی',
  rotateVenue: 'برای چرخاندن مکان بکشید',
  moveVenue: 'برای جابه‌جایی مکان بکشید',
  mapView: 'نقشه',
  flat2dMap: 'نقشهٔ دوبعدی مسطح',
  interactive3dVenueView: 'نمای سه‌بعدی تعاملی سالن',
  venueView: 'نمای سالن',
  holdLapsedTitle: 'صندلی‌های شما آزاد شد',
  salesClosed: 'فروش بسته شد',
  salesClosedCopy: 'فروش بلیت این رویداد به پایان رسیده است.',
  salesClosedToast: 'فروش این رویداد بسته است.',
  soldOutEyebrow: 'این رویداد',
  soldOutTitle: 'تمام شد',
  soldOutCopy: 'در حال حاضر صندلی شماره‌داری برای این رویداد موجود نیست.',
  holdExpired:
      'مهلت نگه‌داشتن صندلی‌ها تمام شد و آزاد شدند. دوباره انتخاب کنید.',
  addingEllipsis: 'در حال افزودن…',
  moreTimeAdded:
      'زمان بیشتری افزوده شد. صندلی‌های شما همچنان نگه داشته شده‌اند.',
  couldNotAddMoreTime: 'زمان بیشتری افزوده نشد. همین حالا به پرداخت بروید.',
  seatsJustTaken: 'یک یا چند صندلی هم‌اکنون گرفته شد. دوباره انتخاب کنید.',
  ticketTypeSoldOut: 'این نوع بلیت تمام شده است. نوع دیگری را امتحان کنید.',
  seatsNoLongerAvailableTryAnother:
      'آن صندلی‌ها دیگر در دسترس نیستند. تعداد یا نوع بلیت دیگری را امتحان کنید.',
  companionPairRequired: 'با هر بلیت همراه، جایگاه ویلچر مجاور را انتخاب کنید.',
  ticketOptionNotApplicable:
      'این گزینهٔ بلیت برای صندلی انتخاب‌شده در دسترس نیست.',
  maintenancePausedShortly:
      'رزرو برای چند دقیقه به‌دلیل نگهداری متوقف شده است. لطفاً کمی بعد دوباره تلاش کنید.',
  guestsOnly: 'این رویداد برای مهمانان دعوت‌شده است.',
  guestChoiceClosed: 'انتخاب صندلی در حال حاضر باز نیست.',
  allSetTitle: 'همه‌چیز آماده است',
  confirmedAndOnWay: 'تأیید شد. تأییدیه در راه است.',
  backToMap: 'بازگشت به نقشه',
  mapDidNotLoad: 'نقشهٔ صندلی‌ها بارگذاری نشد',
  checkConnection: 'اتصال خود را بررسی کنید و دوباره تلاش کنید.',
  accessPausedTitle: 'این صندلی‌ها هم‌اکنون نگه داشته شده‌اند',
  accessPausedCopy:
      'برگزارکننده این انتخاب را موقتاً متوقف کرده است. چند دقیقهٔ دیگر دوباره تلاش کنید.',
  accessRevokedTitle: 'این پیوند دسترسی دیگر فعال نیست',
  accessRevokedCopy:
      'از فرستندهٔ پیوند، پیوند تازه‌ای بخواهید تا رزرو این صندلی‌ها را ادامه دهید.',
  accessUnverifiedTitle: 'نتوانستیم دسترسی شما را تأیید کنیم',
  accessUnverifiedCopy:
      'همچنان می‌توانید هر چیزی را که «موجود» نشان داده می‌شود رزرو کنید. برای دسترسی به بقیه با فرستندهٔ پیوند تماس بگیرید.',
  generalAdmission: 'ورود آزاد',
  numberOfGuests: 'تعداد مهمانان',
  chooseGuestsCopy:
      'انتخاب کنید چند مهمان کنار هم می‌نشینند. این میز فقط برای گروه شما نگه داشته می‌شود.',
  fewerGuests: 'مهمان کمتر',
  moreGuests: 'مهمان بیشتر',
  selectTable: 'انتخاب میز',
  updateTable: 'به‌روزرسانی میز',
  removeWord: 'حذف',
  floorWord: 'طبقه',
  totalWord: 'جمع کل',
  adjustSelection: 'تنظیم انتخاب صندلی‌ها',
  backToSeatMap: 'بازگشت به نقشهٔ صندلی‌ها',
  chooseSeats: 'صندلی‌های خود را انتخاب کنید',
  chooseTickets: 'بلیت‌ها را انتخاب کنید',
  placeWord: 'جایگاه',
  ticketWord: 'بلیت',
  passport: 'مشخصات صندلی',
  venue3D: '3D',
  venueZone: 'منطقهٔ سالن',
  venueMapHint:
      'صندلی‌ها با کنترل‌های اطراف نقشه انتخاب می‌شوند: نوار قیمت بالای آن، کنترل‌های بخش زیر آن، و پنل بلیت در پایین.',
  previousSeat: 'صندلی قبلی',
  nextSeat: 'صندلی بعدی',
  orbitMode: 'چرخاندن سالن',
  panMode: 'جابه‌جایی سالن',
  openInteractive3dVenue: 'باز کردن نمای سه‌بعدی تعاملی سالن',
  showSeatsFor: 'نمایش صندلی‌ها برای',
  accessJumpFirstSection: 'رفتن به بخش اول',
  accessJumpNextSection: 'رفتن به بخش بعدی',
  fewerTickets: 'بلیت کمتر',
  moreTickets: 'بلیت بیشتر',
  addTickets: 'افزودن بلیت',
  noSelectableSeats: 'در حال حاضر هیچ صندلی قابل انتخابی در دسترس نیست.',
  confirmYourTickets: 'بلیت‌های خود را تأیید کنید',
  seatsSecuredOpeningCheckout: 'صندلی‌ها تثبیت شدند. در حال باز کردن پرداخت…',
  holdInCheckoutTitle: 'صندلی‌های شما از قبل در مرحلهٔ پرداخت هستند',
  holdInCheckoutBody:
      'برای حفظ آن‌ها پرداخت را تمام کنید. برای انتخاب صندلی‌های دیگر، اول این‌ها را آزاد کنید — دوباره برای فروش گذاشته می‌شوند.',
  releaseAndChangeSeats: 'آزاد کردن و تغییر صندلی‌ها',
  holdAlreadyHeldTitle: 'صندلی‌های شما از قبل نگه داشته شده‌اند',
  holdAlreadyHeldBody: 'برای حفظ آن‌ها به پرداخت ادامه دهید.',
  accessExpiredTitle: 'نشست انتخاب صندلی شما منقضی شد',
  accessExpiredCopy:
      'برای ادامه، نقشهٔ صندلی‌ها را دوباره بارگذاری کنید. صندلی‌هایی که در سبد شما هستند تا پایان زمان‌سنج نگه داشته می‌شوند.',
  dismissError: 'بستن خطا',
  testModeLong: 'حالت آزمایشی · چیزی رزرو نمی‌شود',
  seatRemoved: 'بلیت حذف شد',
  reloadSeatMap: 'بارگذاری دوبارهٔ نقشهٔ صندلی‌ها',
  accessNeeds: <String, String>{
    'wheelchair': 'جایگاه ویلچر',
    'companion': 'صندلی همراه',
    'semi-ambulatory': 'تحرک محدود',
    'designated-aisle': 'راهرو / جابه‌جایی',
    'step-free': 'بدون پله',
    'hearing': 'کمک‌شنیداری',
    'cart': 'زیرنویس زنده',
    'sign-language': 'زبان اشاره',
    'low-vision': 'کم‌بینایی',
    'sensory-friendly': 'کم‌محرک',
    'plus-size': 'صندلی پهن‌تر',
    'lift-armrest': 'دسته تاشو',
  },
  seatsLeft: _seatsLeftFa,
  moreCount: _moreCountFa,
  addMinutes: _addMinutesFa,
  fromPrice: _fromPriceFa,
  sightline: _sightlineFa,
  secureMoreAndCheckout: _secureMoreAndCheckoutFa,
  accessFreeCount: _accessFreeCountFa,
  seatJustTakenByAnother: _seatJustTakenByAnotherFa,
  labelNoLongerAvailable: _labelNoLongerAvailableFa,
  labelsNoLongerAvailable: _labelsNoLongerAvailableFa,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherFa,
  couldNotRemoveLabel: _couldNotRemoveLabelFa,
  peekSecured: _peekSecuredFa,
  venueMap: _venueMapFa,
  accessibleStep: _accessibleStepFa,
  chooseMinMaxGuests: _chooseMinMaxGuestsFa,
  chooseMore: _chooseMoreFa,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeFa,
  accessNeedWithCount: _accessNeedWithCountFa,
  ticketCount: _ticketCountFa,
  findBestSeats: _findBestSeatsFa,
  reselectSeats: _reselectSeatsFa,
  seatsFree: _seatsFreeFa,
  seatsLeftInSection: _seatsLeftInSectionFa,
  holdLapsedStillFree: _holdLapsedStillFreeFa,
  holdLapsedSomeTaken: _holdLapsedSomeTakenFa,
  holdLapsedAllTaken: _holdLapsedAllTakenFa,
  accessibleSections: _accessibleSectionsFa,
  placesAvailable: _placesAvailableFa,
  removeTickets: _removeTicketsFa,
  holdMinutesLeft: _holdMinutesLeftFa,
  holdSecondsLeft: _holdSecondsLeftFa,
  holdLapsedBody: _holdLapsedBodyFa,
  seatsNotRecovered: _seatsNotRecoveredFa,
  activeFilters: _activeFiltersFa,
  accessibilityFiltersActive: _accessibilityFiltersActiveFa,
  onlyLeft: _onlyLeftFa,
  maintenancePaused: _maintenancePausedFa,
  continueWithTotal: _continueWithTotalFa,
);
