// GENERATED — do not edit.
//
// Source: design/locale_strings.json (el)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftEl(int count) => 'Απομένουν $count';

String _moreCountEl(int count) => '+$count ακόμη';

String _addMinutesEl(int minutes) => '+$minutes λεπτά';

String _fromPriceEl(String money) => 'Από $money';

String _sightlineEl(String metres) => '≈ $metres m από τη σκηνή';

String _secureMoreAndCheckoutEl(int count) =>
    'Εξασφαλίστε $count ακόμη και πληρώστε';

String _accessFreeCountEl(int count) => '$count ελεύθερες';

String _seatJustTakenByAnotherEl(String label) =>
    'Η θέση $label μόλις καταλήφθηκε από άλλον αγοραστή.';

String _peekSecuredEl(int count, String total) =>
    '✓ $count εξασφαλίστηκαν · $total. Δεν θα χρεωθείτε ακόμη';

String _ticketCountEl(int count) => switch (pickerPluralCategory('el', count)) {
  PickerPluralCategory.one => '$count εισιτήριο',
  _ => '$count εισιτήρια',
};

String _findBestSeatsEl(int count) =>
    switch (pickerPluralCategory('el', count)) {
      PickerPluralCategory.one => 'Βρείτε $count καλύτερη θέση',
      _ => 'Βρείτε τις $count καλύτερες θέσεις',
    };

String _reselectSeatsEl(int count) =>
    switch (pickerPluralCategory('el', count)) {
      PickerPluralCategory.one => 'Επιλέξτε την ξανά',
      _ => 'Επιλέξτε τις ξανά',
    };

String _seatsFreeEl(int count) => switch (pickerPluralCategory('el', count)) {
  PickerPluralCategory.one => '$count θέση',
  _ => '$count θέσεις',
};

String _seatsLeftInSectionEl(int count) =>
    switch (pickerPluralCategory('el', count)) {
      PickerPluralCategory.one => 'Απομένει $count θέση',
      _ => 'Απομένουν $count θέσεις',
    };

String _holdLapsedStillFreeEl(int count) => switch (pickerPluralCategory(
  'el',
  count,
)) {
  PickerPluralCategory.one =>
    'Η κράτησή σας έληξε όσο λείπατε. Αυτή η θέση είναι ακόμη ελεύθερη.',
  _ =>
    'Η κράτησή σας έληξε όσο λείπατε. Αυτές οι θέσεις είναι ακόμη ελεύθερες.',
};

String _holdLapsedSomeTakenEl(int count) => switch (pickerPluralCategory(
  'el',
  count,
)) {
  PickerPluralCategory.one =>
    'Η κράτησή σας έληξε όσο λείπατε και $count από αυτές τις θέσεις έχει ήδη κρατηθεί. Οι υπόλοιπες είναι ακόμη ελεύθερες.',
  _ =>
    'Η κράτησή σας έληξε όσο λείπατε και $count από αυτές τις θέσεις έχουν ήδη κρατηθεί. Οι υπόλοιπες είναι ακόμη ελεύθερες.',
};

String _holdLapsedAllTakenEl(int count) => switch (pickerPluralCategory(
  'el',
  count,
)) {
  PickerPluralCategory.one =>
    'Η κράτησή σας έληξε όσο λείπατε και αυτή η θέση έχει ήδη κρατηθεί.',
  _ =>
    'Η κράτησή σας έληξε όσο λείπατε και αυτές οι θέσεις έχουν ήδη κρατηθεί.',
};

String _continueWithTotalEl(String money) => 'Συνέχεια \u00b7 $money';

/// The `el` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsEl = SeatLayerPickerStrings(
  close: 'Κλείσιμο',
  overview: 'Χώρος',
  backToVenue: 'Επιστροφή στον χώρο',
  cancel: 'Ακύρωση',
  select: 'Επιλογή',
  removeSeat: 'Αφαίρεση θέσης',
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
  fitVenue: 'Εμφάνιση όλου του χώρου',
  fitWholeVenue: 'Εμφάνιση όλου του χώρου',
  loading: 'Φόρτωση χάρτη θέσεων…',
  errorMessage: 'Ο χάρτης θέσεων δεν φορτώθηκε',
  retry: 'Δοκιμάστε ξανά',
  accessRefresh: 'Ανανέωση',
  noSeatsSelected: 'Δεν επιλέχθηκαν θέσεις',
  findBestSeatsCta: 'Βρείτε τις καλύτερες θέσεις',
  organizerNote: 'Σημείωση διοργανωτή',
  accessiblePhysicalSeat: 'Προσβάσιμη φυσική θέση',
  emptyWheelchairSpace: 'Κενή θέση αναπηρικού αμαξιδίου',
  findSeatsTogether: 'Βρείτε θέσεις μαζί',
  aboutBestSeats: 'Σχετικά με την εύρεση θέσεων μαζί',
  closestGroupChosenInstantly:
      'Η πλησιέστερη διαθέσιμη ομάδα, επιλεγμένη αμέσως.',
  hideLimitedView: 'Απόκρυψη θέσεων με περιορισμένη θέα',
  colorblindSafe: 'Χρώματα φιλικά προς την αχρωματοψία',
  notAvailable: 'Μη διαθέσιμο',
  restrictedView: 'Περιορισμένη θέα',
  obstructedView: 'Θέα με εμπόδιο',
  premiumSeat: 'Θέση premium',
  continueWord: 'Συνέχεια',
  allFloors: 'Όλοι οι όροφοι',
  previousSection: 'Προηγούμενο τμήμα',
  nextSection: 'Επόμενο τμήμα',
  addSeat: 'Προσθήκη θέσης',
  added: 'Προστέθηκε',
  sectionWord: 'Τμήμα',
  rowWord: 'Σειρά',
  seatWord: 'Θέση',
  seeItIn3D: 'Δείτε το σε 3D',
  viewFromThisSeat: 'Θέα από αυτή τη θέση',
  allPrices: 'Όλες οι τιμές',
  ticketType: 'Τύπος εισιτηρίου',
  tierCompanionGuidance: 'Απαιτεί τη διπλανή θέση αναπηρικού αμαξιδίου',
  findingBestSeats: 'Αναζήτηση των καλύτερων θέσεων…',
  findSeats: 'Εύρεση θέσεων',
  expandCart: 'Άνοιγμα πίνακα εισιτηρίων',
  collapseCart: 'Σύμπτυξη πίνακα εισιτηρίων',
  continueToCheckout: 'Συνέχεια στην πληρωμή',
  secureMore: 'Εξασφαλίστε περισσότερες',
  selectSeats: 'Επιλογή θέσεων',
  pickYourSeats: 'Επιλέξτε τις θέσεις σας',
  salesClosedPill: 'Οι πωλήσεις έκλεισαν',
  salesClosedCta: 'Οι πωλήσεις έκλεισαν',
  confirmOrCancelSeat: 'Επιβεβαιώστε ή ακυρώστε αυτή τη θέση',
  securingSeats: 'Εξασφαλίζουμε τις θέσεις σας…',
  openingCheckout: 'Άνοιγμα ασφαλούς πληρωμής…',
  testModeExplained:
      'Οι κρατήσεις εδώ δεν είναι πραγματικές και δεν χρεώνεται καμία κάρτα',
  displayOptions: 'Επιλογές εμφάνισης',
  companionSeatsNote: 'Οι διπλανές θέσεις συνοδού παραμένουν επιλέξιμες',
  zoomIn: 'Μεγέθυνση',
  zoomOut: 'Σμίκρυνση',
  rotateVenue: 'Σύρετε για περιστροφή του χώρου',
  moveVenue: 'Σύρετε για μετακίνηση του χώρου',
  mapView: 'Χάρτης',
  flat2dMap: 'Επίπεδος χάρτης 2D',
  interactive3dVenueView: 'Διαδραστική προβολή 3D του χώρου',
  venueView: 'Προβολή χώρου',
  holdLapsedTitle: 'Οι θέσεις σας αποδεσμεύτηκαν',
  salesClosed: 'Οι πωλήσεις έκλεισαν',
  salesClosedCopy: 'Η πώληση εισιτηρίων για αυτή την εκδήλωση ολοκληρώθηκε.',
  salesClosedToast: 'Οι πωλήσεις για αυτή την εκδήλωση έχουν κλείσει.',
  soldOutEyebrow: 'Αυτή η εκδήλωση',
  soldOutTitle: 'Εξαντλήθηκε',
  soldOutCopy:
      'Δεν υπάρχουν αυτή τη στιγμή διαθέσιμες αριθμημένες θέσεις για αυτή την εκδήλωση.',
  holdExpired: 'Η κράτησή σας έληξε. Οι θέσεις αποδεσμεύτηκαν. Επιλέξτε ξανά.',
  addingEllipsis: 'Προσθήκη…',
  moreTimeAdded: 'Προστέθηκε χρόνος. Οι θέσεις σας παραμένουν δεσμευμένες.',
  couldNotAddMoreTime:
      'Δεν ήταν δυνατή η προσθήκη χρόνου. Προχωρήστε τώρα στην πληρωμή.',
  seatsJustTaken:
      'Μία ή περισσότερες θέσεις μόλις καταλήφθηκαν. Επιλέξτε ξανά.',
  allSetTitle: 'Όλα έτοιμα',
  confirmedAndOnWay: 'επιβεβαιώθηκε. Η επιβεβαίωση είναι καθ\' οδόν.',
  backToMap: 'Επιστροφή στον χάρτη',
  mapDidNotLoad: 'Ο χάρτης θέσεων δεν φορτώθηκε',
  checkConnection: 'Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.',
  accessPausedTitle: 'Αυτές οι θέσεις είναι δεσμευμένες αυτή τη στιγμή',
  accessPausedCopy:
      'Ο διοργανωτής έχει διακόψει προσωρινά αυτή την επιλογή. Δοκιμάστε ξανά σε λίγα λεπτά.',
  accessRevokedTitle: 'Αυτός ο σύνδεσμος πρόσβασης δεν είναι πλέον ενεργός',
  accessRevokedCopy:
      'Ζητήστε από όποιον σας έστειλε εδώ έναν νέο σύνδεσμο για να συνεχίσετε να κρατάτε αυτές τις θέσεις.',
  accessUnverifiedTitle: 'Δεν μπορέσαμε να επαληθεύσουμε την πρόσβασή σας',
  accessUnverifiedCopy:
      'Μπορείτε ακόμη να αγοράσετε ό,τι εμφανίζεται ως διαθέσιμο. Επικοινωνήστε με όποιον σας έστειλε εδώ για πρόσβαση στα υπόλοιπα.',
  generalAdmission: 'Ελεύθερη είσοδος',
  numberOfGuests: 'Αριθμός καλεσμένων',
  chooseGuestsCopy:
      'Επιλέξτε πόσοι καλεσμένοι θα καθίσουν μαζί. Αυτό το τραπέζι κρατείται αποκλειστικά για την παρέα σας.',
  fewerGuests: 'Λιγότεροι καλεσμένοι',
  moreGuests: 'Περισσότεροι καλεσμένοι',
  selectTable: 'Επιλογή τραπεζιού',
  updateTable: 'Ενημέρωση τραπεζιού',
  removeWord: 'Αφαίρεση',
  floorWord: 'Όροφος',
  totalWord: 'Σύνολο',
  accessNeeds: <String, String>{
    'wheelchair': 'Θέση αμαξιδίου',
    'companion': 'Θέση συνοδού',
    'semi-ambulatory': 'Περιορισμένη κινητικότητα',
    'designated-aisle': 'Διάδρομος / μετακίνηση',
    'step-free': 'Χωρίς σκαλιά',
    'hearing': 'Υποβοήθηση ακοής',
    'cart': 'Ζωντανοί υπότιτλοι',
    'sign-language': 'Νοηματική γλώσσα',
    'low-vision': 'Χαμηλή όραση',
    'sensory-friendly': 'Αισθητηριακά φιλική',
    'plus-size': 'Μεγαλύτερο μέγεθος',
    'lift-armrest': 'Ανασηκούμενο μπράτσο',
  },
  seatsLeft: _seatsLeftEl,
  moreCount: _moreCountEl,
  addMinutes: _addMinutesEl,
  fromPrice: _fromPriceEl,
  sightline: _sightlineEl,
  secureMoreAndCheckout: _secureMoreAndCheckoutEl,
  accessFreeCount: _accessFreeCountEl,
  seatJustTakenByAnother: _seatJustTakenByAnotherEl,
  peekSecured: _peekSecuredEl,
  ticketCount: _ticketCountEl,
  findBestSeats: _findBestSeatsEl,
  reselectSeats: _reselectSeatsEl,
  seatsFree: _seatsFreeEl,
  seatsLeftInSection: _seatsLeftInSectionEl,
  holdLapsedStillFree: _holdLapsedStillFreeEl,
  holdLapsedSomeTaken: _holdLapsedSomeTakenEl,
  holdLapsedAllTaken: _holdLapsedAllTakenEl,
  continueWithTotal: _continueWithTotalEl,
);
