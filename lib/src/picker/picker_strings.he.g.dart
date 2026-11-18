// GENERATED — do not edit.
//
// Source: design/locale_strings.json (he)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftHe(int count) => 'נותרו $count';

String _moreCountHe(int count) => '+$count נוספים';

String _addMinutesHe(int minutes) => '+$minutes דק׳';

String _fromPriceHe(String money) => 'החל מ-$money';

String _sightlineHe(String metres) => '‏≈ $metres מ׳ מהבמה';

String _secureMoreAndCheckoutHe(int count) => 'הבטיחו עוד $count ועברו לתשלום';

String _accessFreeCountHe(int count) => '$count פנויים';

String _seatJustTakenByAnotherHe(String label) =>
    'מושב $label נתפס זה עתה על ידי קונה אחר.';

String _peekSecuredHe(int count, String total) =>
    '✓ $count הובטחו · $total. עדיין לא תחויבו';

String _venueMapHe(String venue) => 'מפת המושבים של $venue';

String _accessibleStepHe(int index, int total) => '$index מתוך $total';

String _chooseMinMaxGuestsHe(int min, int max) =>
    'בחרו בין $min ל-$max אורחים.';

String _chooseMoreHe(int count) => 'בחרו עוד $count';

String _seatsHeldForNeedMoreTimeHe(String time) =>
    'המושבים שלכם מוחזקים למשך $time. צריכים עוד זמן?';

String _ticketCountHe(int count) => switch (pickerPluralCategory('he', count)) {
  PickerPluralCategory.one => '$count כרטיס',
  PickerPluralCategory.two => '$count כרטיסים',
  _ => '$count כרטיסים',
};

String _findBestSeatsHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'מצאו $count מושב הכי טוב',
      PickerPluralCategory.two => 'מצאו $count מושבים הכי טובים',
      _ => 'מצאו $count מושבים הכי טובים',
    };

String _reselectSeatsHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'בחר אותו שוב',
      PickerPluralCategory.two => 'בחר אותם שוב',
      _ => 'בחר אותם שוב',
    };

String _seatsFreeHe(int count) => switch (pickerPluralCategory('he', count)) {
  PickerPluralCategory.one => '$count מושב',
  PickerPluralCategory.two => '$count מושבים',
  _ => '$count מושבים',
};

String _seatsLeftInSectionHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'נותר $count מושב',
      PickerPluralCategory.two => 'נותרו $count מושבים',
      _ => 'נותרו $count מושבים',
    };

String _holdLapsedStillFreeHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one =>
        'ההזמנה שלך פגה בזמן שלא היית. המושב הזה עדיין פנוי.',
      PickerPluralCategory.two =>
        'ההזמנה שלך פגה בזמן שלא היית. המושבים האלה עדיין פנויים.',
      _ => 'ההזמנה שלך פגה בזמן שלא היית. המושבים האלה עדיין פנויים.',
    };

String _holdLapsedSomeTakenHe(int count) => switch (pickerPluralCategory(
  'he',
  count,
)) {
  PickerPluralCategory.one =>
    'ההזמנה שלך פגה בזמן שלא היית, ו-$count מהמושבים האלה כבר נתפס. השאר עדיין פנויים.',
  PickerPluralCategory.two =>
    'ההזמנה שלך פגה בזמן שלא היית, ו-$count מהמושבים האלה כבר נתפסו. השאר עדיין פנויים.',
  _ =>
    'ההזמנה שלך פגה בזמן שלא היית, ו-$count מהמושבים האלה כבר נתפסו. השאר עדיין פנויים.',
};

String _holdLapsedAllTakenHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one =>
        'ההזמנה שלך פגה בזמן שלא היית, והמושב הזה כבר נתפס.',
      PickerPluralCategory.two =>
        'ההזמנה שלך פגה בזמן שלא היית, והמושבים האלה כבר נתפסו.',
      _ => 'ההזמנה שלך פגה בזמן שלא היית, והמושבים האלה כבר נתפסו.',
    };

String _accessibleSectionsHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => '$count גוש',
      PickerPluralCategory.two => '$count גושים',
      _ => '$count גושים',
    };

String _placesAvailableHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => '$count מקום זמין כרגע',
      PickerPluralCategory.two => '$count מקומות זמינים כרגע',
      _ => '$count מקומות זמינים כרגע',
    };

String _removeTicketsHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'הסרת $count כרטיס',
      PickerPluralCategory.two => 'הסרת $count כרטיסים',
      _ => 'הסרת $count כרטיסים',
    };

String _holdMinutesLeftHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'נותרה $count דקה',
      PickerPluralCategory.two => 'נותרו $count דקות',
      _ => 'נותרו $count דקות',
    };

String _holdSecondsLeftHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'נותרה $count שנייה',
      PickerPluralCategory.two => 'נותרו $count שניות',
      _ => 'נותרו $count שניות',
    };

String _holdLapsedBodyHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'הם הוחזקו למשך $count דקה.',
      PickerPluralCategory.two => 'הם הוחזקו למשך $count דקות.',
      _ => 'הם הוחזקו למשך $count דקות.',
    };

String _seatsNotRecoveredHe(int count) =>
    switch (pickerPluralCategory('he', count)) {
      PickerPluralCategory.one => 'לא ניתן היה לשחזר $count מושב',
      PickerPluralCategory.two => 'לא ניתן היה לשחזר $count מושבים',
      _ => 'לא ניתן היה לשחזר $count מושבים',
    };

String _continueWithTotalHe(String money) => 'המשך \u00b7 $money';

/// The `he` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHe = SeatLayerPickerStrings(
  close: 'סגירה',
  overview: 'מקום',
  backToVenue: 'חזרה למתחם',
  cancel: 'ביטול',
  select: 'בחירה',
  removeSeat: 'הסרת מושב',
  viewFromHere: 'הנוף מכאן',
  openVenue360: 'פתיחת המתחם ב־360°',
  recentre: 'מרכוז מחדש על הבמה',
  viewFromYourSeat: 'מבט מהמושב שלך',
  emptyTrayHint:
      'הקישו על מושב במפה, או תנו לנו לבחור עבורכם את הטובים ביותר מבין הפנויים.',
  anyTicketType: 'כל סוג כרטיס',
  anyVenueZone: 'כל אזור במתחם',
  bestSeats: 'המושבים הטובים ביותר',
  showLess: 'הצג פחות',
  undo: 'ביטול פעולה',
  holdAndCheckout: 'החזקת מושבים ומעבר לתשלום',
  poweredBy: 'מופעל על ידי SeatLayer',
  testMode: 'מצב בדיקה',
  accessibility: 'אפשרויות נגישות וצבע',
  accessibilityTitle: 'אפשרויות נגישות וצבע',
  fitVenue: 'הצג את כל המתחם',
  fitWholeVenue: 'הצג את כל המתחם',
  loading: 'טוענים את מפת המושבים…',
  errorMessage: 'מפת המושבים לא נטענה',
  retry: 'נסו שוב',
  accessRefresh: 'רענון',
  noSeatsSelected: 'לא נבחרו מושבים',
  findBestSeatsCta: 'מצאו את המושבים הטובים ביותר',
  organizerNote: 'הערת המארגן',
  accessiblePhysicalSeat: 'מושב פיזי נגיש',
  emptyWheelchairSpace: 'מקום פנוי לכיסא גלגלים',
  findSeatsTogether: 'מצאו מושבים צמודים',
  aboutBestSeats: 'על מציאת מקומות צמודים',
  closestGroupChosenInstantly: 'הקבוצה הפנויה הקרובה ביותר, נבחרה מיד.',
  hideLimitedView: 'הסתרת מושבים עם נוף מוגבל',
  colorblindSafe: 'צבעים ידידותיים לעיוורי צבעים',
  notAvailable: 'לא זמין',
  viewGroupTitle: 'תצוגה',
  restrictedView: 'נוף מוגבל',
  obstructedView: 'נוף חסום',
  premiumSeat: 'מושב פרימיום',
  continueWord: 'המשך',
  allFloors: 'כל הקומות',
  previousSection: 'הגוש הקודם',
  nextSection: 'הגוש הבא',
  addSeat: 'הוספת מושב',
  added: 'נוסף',
  sectionWord: 'גוש',
  rowWord: 'שורה',
  seatWord: 'מושב',
  seeItIn3D: 'לראות בתלת־ממד',
  viewFromThisSeat: 'הנוף מהמושב הזה',
  allPrices: 'כל המחירים',
  ticketPrices: 'מחירי כרטיסים',
  yourSeats: 'המושבים שלכם',
  ticketType: 'סוג כרטיס',
  tierCompanionGuidance: 'נדרש מקום הכיסא הגלגלים הסמוך',
  findingBestSeats: 'מחפשים את המושבים הטובים ביותר…',
  findSeats: 'חיפוש מושבים',
  expandCart: 'פתיחת לוח הכרטיסים',
  collapseCart: 'כיווץ לוח הכרטיסים',
  continueToCheckout: 'המשך לתשלום',
  secureMore: 'להבטיח עוד',
  selectSeats: 'בחירת מושבים',
  pickYourSeats: 'בחרו את המושבים שלכם',
  salesClosedPill: 'המכירה נסגרה',
  salesClosedCta: 'המכירה נסגרה',
  confirmOrCancelSeat: 'אשרו או בטלו את המושב הזה',
  securingSeats: 'מבטיחים את המושבים שלכם…',
  openingCheckout: 'פותחים תשלום מאובטח…',
  testModeExplained: 'ההזמנות כאן אינן אמיתיות ולא מתבצע חיוב בכרטיס',
  displayOptions: 'אפשרויות תצוגה',
  companionSeatsNote: 'מקומות המלווה שלצדם נשארים ניתנים לבחירה',
  zoomIn: 'התקרבות',
  zoomOut: 'התרחקות',
  rotateVenue: 'גררו כדי לסובב את המתחם',
  moveVenue: 'גררו כדי להזיז את המתחם',
  mapView: 'מפה',
  flat2dMap: 'מפת דו־ממד שטוחה',
  interactive3dVenueView: 'תצוגת תלת־ממד אינטראקטיבית של המתחם',
  venueView: 'תצוגת המתחם',
  holdLapsedTitle: 'המושבים שלך שוחררו',
  salesClosed: 'המכירה נסגרה',
  salesClosedCopy: 'מכירת הכרטיסים לאירוע הזה הסתיימה.',
  salesClosedToast: 'המכירה לאירוע הזה סגורה.',
  soldOutEyebrow: 'האירוע הזה',
  soldOutTitle: 'אזל',
  soldOutCopy: 'אין כרגע מושבים שמורים פנויים לאירוע הזה.',
  holdExpired: 'ההחזקה שלך פגה. המושבים שוחררו. בחרו שוב.',
  addingEllipsis: 'מוסיפים…',
  moreTimeAdded: 'נוסף זמן. המושבים שלכם עדיין מוחזקים.',
  couldNotAddMoreTime: 'לא הצלחנו להוסיף זמן. עברו לתשלום עכשיו.',
  seatsJustTaken: 'מושב אחד או יותר נתפסו זה עתה. בחרו שוב.',
  allSetTitle: 'הכול מוכן',
  confirmedAndOnWay: 'אושר. האישור בדרך אליכם.',
  backToMap: 'חזרה למפה',
  mapDidNotLoad: 'מפת המושבים לא נטענה',
  checkConnection: 'בדקו את החיבור ונסו שוב.',
  accessPausedTitle: 'המושבים האלה מוחזקים כרגע',
  accessPausedCopy: 'המפיק השהה את הבחירה הזו. נסו שוב בעוד כמה דקות.',
  accessRevokedTitle: 'קישור הגישה הזה כבר לא פעיל',
  accessRevokedCopy:
      'בקשו קישור חדש ממי ששלח אתכם לכאן כדי להמשיך להזמין את המושבים האלה.',
  accessUnverifiedTitle: 'לא הצלחנו לאמת את הגישה שלכם',
  accessUnverifiedCopy:
      'עדיין אפשר להזמין כל מה שמופיע כזמין. לגישה ליתר, פנו למי ששלח אתכם לכאן.',
  generalAdmission: 'כניסה חופשית',
  numberOfGuests: 'מספר האורחים',
  chooseGuestsCopy:
      'בחרו כמה אורחים יישבו יחד. השולחן הזה נשמר בלעדית לחבורה שלכם.',
  fewerGuests: 'פחות אורחים',
  moreGuests: 'יותר אורחים',
  selectTable: 'בחירת שולחן',
  updateTable: 'עדכון השולחן',
  removeWord: 'הסרה',
  floorWord: 'קומה',
  totalWord: 'סה״כ',
  chooseSeats: 'בחרו את המושבים שלכם',
  chooseTickets: 'בחרו כרטיסים',
  placeWord: 'מקום',
  ticketWord: 'כרטיס',
  passport: 'פרופיל המושב',
  venue3D: '3D',
  venueZone: 'אזור במתחם',
  venueMapHint:
      'בוחרים מושבים בעזרת הפקדים שסביב המפה: פס המחירים מעליה, פקדי הגושים מתחתיה וחלונית הכרטיסים בתחתית.',
  previousSeat: 'המושב הקודם',
  nextSeat: 'המושב הבא',
  orbitMode: 'סיבוב המתחם',
  panMode: 'הזזת המתחם',
  openInteractive3dVenue: 'פתיחת תצוגת תלת־ממד אינטראקטיבית של המתחם',
  showSeatsFor: 'הצגת מושבים עבור',
  accessJumpFirstSection: 'מעבר לגוש הראשון',
  accessJumpNextSection: 'מעבר לגוש הבא',
  fewerTickets: 'פחות כרטיסים',
  moreTickets: 'יותר כרטיסים',
  addTickets: 'הוספת כרטיסים',
  noSelectableSeats: 'אין כרגע מושבים זמינים לבחירה.',
  confirmYourTickets: 'אשרו את הכרטיסים שלכם',
  seatsSecuredOpeningCheckout: 'המושבים הובטחו. פותחים את התשלום…',
  holdInCheckoutTitle: 'המושבים שלכם כבר בתשלום',
  holdInCheckoutBody:
      'השלימו את התשלום כדי לשמור עליהם. כדי לבחור מושבים אחרים, שחררו קודם את אלה — הם יחזרו למכירה.',
  releaseAndChangeSeats: 'שחרור והחלפת מושבים',
  holdAlreadyHeldTitle: 'המושבים שלכם כבר מוחזקים',
  holdAlreadyHeldBody: 'המשיכו לתשלום כדי לשמור עליהם.',
  accessExpiredTitle: 'פג תוקף סשן המושבים שלכם',
  accessExpiredCopy:
      'טענו מחדש את מפת המושבים כדי להמשיך. מושבים שכבר בעגלה שלכם נשארים מוחזקים עד שהטיימר מסתיים.',
  dismissError: 'סגירת השגיאה',
  testModeLong: 'מצב בדיקה · שום דבר לא מוזמן',
  accessNeeds: <String, String>{
    'wheelchair': 'מקום לכיסא גלגלים',
    'companion': 'מושב מלווה',
    'semi-ambulatory': 'ניידות מוגבלת',
    'designated-aisle': 'מעבר / העברה',
    'step-free': 'ללא מדרגות',
    'hearing': 'עזר שמיעה',
    'cart': 'כתוביות בזמן אמת',
    'sign-language': 'שפת סימנים',
    'low-vision': 'לקות ראייה',
    'sensory-friendly': 'ידידותי לחושים',
    'plus-size': 'מושב רחב',
    'lift-armrest': 'משענת יד מתרוממת',
  },
  seatsLeft: _seatsLeftHe,
  moreCount: _moreCountHe,
  addMinutes: _addMinutesHe,
  fromPrice: _fromPriceHe,
  sightline: _sightlineHe,
  secureMoreAndCheckout: _secureMoreAndCheckoutHe,
  accessFreeCount: _accessFreeCountHe,
  seatJustTakenByAnother: _seatJustTakenByAnotherHe,
  peekSecured: _peekSecuredHe,
  venueMap: _venueMapHe,
  accessibleStep: _accessibleStepHe,
  chooseMinMaxGuests: _chooseMinMaxGuestsHe,
  chooseMore: _chooseMoreHe,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeHe,
  ticketCount: _ticketCountHe,
  findBestSeats: _findBestSeatsHe,
  reselectSeats: _reselectSeatsHe,
  seatsFree: _seatsFreeHe,
  seatsLeftInSection: _seatsLeftInSectionHe,
  holdLapsedStillFree: _holdLapsedStillFreeHe,
  holdLapsedSomeTaken: _holdLapsedSomeTakenHe,
  holdLapsedAllTaken: _holdLapsedAllTakenHe,
  accessibleSections: _accessibleSectionsHe,
  placesAvailable: _placesAvailableHe,
  removeTickets: _removeTicketsHe,
  holdMinutesLeft: _holdMinutesLeftHe,
  holdSecondsLeft: _holdSecondsLeftHe,
  holdLapsedBody: _holdLapsedBodyHe,
  seatsNotRecovered: _seatsNotRecoveredHe,
  continueWithTotal: _continueWithTotalHe,
);
