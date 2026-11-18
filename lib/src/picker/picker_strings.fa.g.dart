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

String _addMinutesFa(int minutes) => '+$minutes دقیقه';

String _fromPriceFa(String money) => 'از $money';

String _sightlineFa(String metres) => '‏≈ $metres متر تا صحنه';

String _secureMoreAndCheckoutFa(int count) => '$count تای دیگر تثبیت و پرداخت';

String _accessFreeCountFa(int count) => '$count آزاد';

String _seatJustTakenByAnotherFa(String label) =>
    'صندلی $label هم‌اکنون توسط خریدار دیگری گرفته شد.';

String _peekSecuredFa(int count, String total) =>
    '✓ $count تثبیت شد · $total. هنوز مبلغی کسر نمی‌شود';

String _ticketCountFa(int count) => count == 1 ? '$count بلیت' : '$count بلیت';

String _findBestSeatsFa(int count) => count == 1
    ? 'پیدا کردن $count بهترین صندلی'
    : 'پیدا کردن $count صندلی برتر';

String _reselectSeatsFa(int count) =>
    count == 1 ? 'دوباره انتخابش کنید' : 'دوباره انتخابشان کنید';

String _seatsFreeFa(int count) => count == 1 ? '$count صندلی' : '$count صندلی';

String _seatsLeftInSectionFa(int count) =>
    count == 1 ? '$count صندلی باقی مانده' : '$count صندلی باقی مانده';

String _holdLapsedStillFreeFa(int count) => count == 1
    ? 'رزرو شما در زمان نبودنتان منقضی شد. آن صندلی هنوز آزاد است.'
    : 'رزرو شما در زمان نبودنتان منقضی شد. آن صندلی‌ها هنوز آزاد هستند.';

String _holdLapsedSomeTakenFa(int count) => count == 1
    ? 'رزرو شما در زمان نبودنتان منقضی شد و $count صندلی از آن‌ها گرفته شده است. بقیه هنوز آزاد هستند.'
    : 'رزرو شما در زمان نبودنتان منقضی شد و $count صندلی از آن‌ها گرفته شده است. بقیه هنوز آزاد هستند.';

String _holdLapsedAllTakenFa(int count) => count == 1
    ? 'رزرو شما در زمان نبودنتان منقضی شد و آن صندلی گرفته شده است.'
    : 'رزرو شما در زمان نبودنتان منقضی شد و آن صندلی‌ها گرفته شده‌اند.';

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
  peekSecured: _peekSecuredFa,
  ticketCount: _ticketCountFa,
  findBestSeats: _findBestSeatsFa,
  reselectSeats: _reselectSeatsFa,
  seatsFree: _seatsFreeFa,
  seatsLeftInSection: _seatsLeftInSectionFa,
  holdLapsedStillFree: _holdLapsedStillFreeFa,
  holdLapsedSomeTaken: _holdLapsedSomeTakenFa,
  holdLapsedAllTaken: _holdLapsedAllTakenFa,
  continueWithTotal: _continueWithTotalFa,
);
