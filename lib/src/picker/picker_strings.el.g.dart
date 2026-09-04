// GENERATED — do not edit.
//
// Source: design/locale_strings.json (el)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftEl(int count) => 'Απομένουν $count';

String _moreCountEl(int count) => '+$count ακόμη';

String _addMinutesEl(int minutes) => '+$minutes λεπτά';

String _fromPriceEl(String money) => 'Από $money';

String _sightlineEl(String metres) => '≈ $metres m από τη σκηνή';

String _ticketCountEl(int count) =>
    count == 1 ? '$count εισιτήριο' : '$count εισιτήρια';

String _findBestSeatsEl(int count) => count == 1
    ? 'Βρείτε $count καλύτερη θέση'
    : 'Βρείτε τις $count καλύτερες θέσεις';

String _reselectSeatsEl(int count) =>
    count == 1 ? 'Επιλέξτε την ξανά' : 'Επιλέξτε τις ξανά';

String _continueWithTotalEl(String money) => 'Συνέχεια \u00b7 $money';

/// The `el` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsEl = SeatLayerPickerStrings(
  close: 'Κλείσιμο',
  overview: 'Χώρος',
  backToVenue: 'Επιστροφή στον χώρο',
  cancel: 'Ακύρωση',
  select: 'Επιλογή',
  viewFromHere: 'Θέα από εδώ',
  openVenue360: 'Άνοιγμα του χώρου σε 360°',
  recentre: 'Επανακεντράρισμα στη σκηνή',
  viewFromYourSeat: 'θέα από τη θέση σας',
  emptyTrayHint:
      'Πατήστε μια θέση στον χάρτη ή αφήστε μας να επιλέξουμε τις καλύτερες διαθέσιμες για εσάς.',
  anyTicketType: 'Οποιοσδήποτε τύπος εισιτηρίου',
  anyVenueZone: 'Οποιαδήποτε ζώνη',
  bestSeats: 'Καλύτερες θέσεις',
  showLess: 'Εμφάνιση λιγότερων',
  undo: 'Αναίρεση',
  holdAndCheckout: 'Κράτηση θέσεων και πληρωμή',
  poweredBy: 'Με την υποστήριξη του SeatLayer',
  testMode: 'ΔΟΚΙΜΑΣΤΙΚΗ ΛΕΙΤΟΥΡΓΙΑ',
  accessibility: 'Επιλογές προσβασιμότητας και χρωμάτων',
  accessibilityTitle: 'Επιλογές προσβασιμότητας και χρωμάτων',
  fitVenue: 'Προσαρμογή στην οθόνη',
  loading: 'Φόρτωση χάρτη θέσεων…',
  errorMessage: 'Ο χάρτης θέσεων δεν φορτώθηκε',
  retry: 'Δοκιμάστε ξανά',
  hideLimitedView: 'Απόκρυψη θέσεων με περιορισμένη θέα',
  colorblindSafe: 'Χρώματα φιλικά προς την αχρωματοψία',
  continueWord: 'Συνέχεια',
  seatsLeft: _seatsLeftEl,
  moreCount: _moreCountEl,
  addMinutes: _addMinutesEl,
  fromPrice: _fromPriceEl,
  sightline: _sightlineEl,
  ticketCount: _ticketCountEl,
  findBestSeats: _findBestSeatsEl,
  reselectSeats: _reselectSeatsEl,
  continueWithTotal: _continueWithTotalEl,
);
