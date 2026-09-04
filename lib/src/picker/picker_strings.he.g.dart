// GENERATED — do not edit.
//
// Source: design/locale_strings.json (he)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftHe(int count) => 'נותרו $count';

String _moreCountHe(int count) => '+$count נוספים';

String _addMinutesHe(int minutes) => '+$minutes דק׳';

String _fromPriceHe(String money) => 'החל מ-$money';

String _sightlineHe(String metres) => '‏≈ $metres מ׳ מהבמה';

String _ticketCountHe(int count) =>
    count == 1 ? '$count כרטיס' : '$count כרטיסים';

String _findBestSeatsHe(int count) =>
    count == 1 ? 'מצאו $count מושב הכי טוב' : 'מצאו $count מושבים הכי טובים';

String _reselectSeatsHe(int count) =>
    count == 1 ? 'בחר אותו שוב' : 'בחר אותם שוב';

String _continueWithTotalHe(String money) => 'המשך \u00b7 $money';

/// The `he` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHe = SeatLayerPickerStrings(
  close: 'סגירה',
  overview: 'מקום',
  backToVenue: 'חזרה למתחם',
  cancel: 'ביטול',
  select: 'בחירה',
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
  fitVenue: 'התאמה למסך',
  loading: 'טוענים את מפת המושבים…',
  errorMessage: 'מפת המושבים לא נטענה',
  retry: 'נסו שוב',
  hideLimitedView: 'הסתרת מושבים עם נוף מוגבל',
  colorblindSafe: 'צבעים ידידותיים לעיוורי צבעים',
  seatsLeft: _seatsLeftHe,
  moreCount: _moreCountHe,
  addMinutes: _addMinutesHe,
  fromPrice: _fromPriceHe,
  sightline: _sightlineHe,
  ticketCount: _ticketCountHe,
  findBestSeats: _findBestSeatsHe,
  reselectSeats: _reselectSeatsHe,
  continueWithTotal: _continueWithTotalHe,
);
