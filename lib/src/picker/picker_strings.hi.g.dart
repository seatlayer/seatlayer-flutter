// GENERATED — do not edit.
//
// Source: design/locale_strings.json (hi)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftHi(int count) => '$count बाकी';

String _moreCountHi(int count) => '+$count और';

String _addMinutesHi(int minutes) => '+$minutes मिनट';

String _fromPriceHi(String money) => '$money से';

String _sightlineHi(String metres) => 'स्टेज से ≈ $metres मी';

String _secureMoreAndCheckoutHi(int count) =>
    '$count और होल्ड करें और चेकआउट करें';

String _accessFreeCountHi(int count) => '$count खाली';

String _seatJustTakenByAnotherHi(String label) =>
    'सीट $label अभी-अभी किसी और खरीदार ने ले ली।';

String _peekSecuredHi(int count, String total) =>
    '✓ $count होल्ड · $total। अभी पैसे नहीं कटेंगे';

String _venueMapHi(String venue) => '$venue का सीट मैप';

String _accessibleStepHi(int index, int total) => '$total में से $index';

String _chooseMinMaxGuestsHi(int min, int max) => '$min से $max मेहमान चुनें।';

String _chooseMoreHi(int count) => '$count और चुनें';

String _seatsHeldForNeedMoreTimeHi(String time) =>
    'आपकी सीटें $time के लिए होल्ड हैं। और समय चाहिए?';

String _ticketCountHi(int count) => switch (pickerPluralCategory('hi', count)) {
  PickerPluralCategory.one => '$count टिकट',
  _ => '$count टिकट',
};

String _findBestSeatsHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count सबसे अच्छी सीट खोजें',
      _ => '$count सबसे अच्छी सीटें खोजें',
    };

String _reselectSeatsHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => 'इसे फिर से चुनें',
      _ => 'इन्हें फिर से चुनें',
    };

String _seatsFreeHi(int count) => switch (pickerPluralCategory('hi', count)) {
  PickerPluralCategory.one => '$count सीट',
  _ => '$count सीटें',
};

String _seatsLeftInSectionHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count सीट बाकी',
      _ => '$count सीटें बाकी',
    };

String _holdLapsedStillFreeHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one =>
        'आपके दूर रहने पर होल्ड खत्म हो गया। वह सीट अब भी खाली है।',
      _ => 'आपके दूर रहने पर होल्ड खत्म हो गया। वे सीटें अब भी खाली हैं।',
    };

String _holdLapsedSomeTakenHi(int count) => switch (pickerPluralCategory(
  'hi',
  count,
)) {
  PickerPluralCategory.one =>
    'आपके दूर रहने पर होल्ड खत्म हो गया, और उनमें से $count सीट बुक हो चुकी है। बाकी अब भी खाली हैं।',
  _ =>
    'आपके दूर रहने पर होल्ड खत्म हो गया, और उनमें से $count सीटें बुक हो चुकी हैं। बाकी अब भी खाली हैं।',
};

String _holdLapsedAllTakenHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one =>
        'आपके दूर रहने पर होल्ड खत्म हो गया, और वह सीट बुक हो चुकी है।',
      _ => 'आपके दूर रहने पर होल्ड खत्म हो गया, और वे सीटें बुक हो चुकी हैं।',
    };

String _accessibleSectionsHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count सेक्शन',
      _ => '$count सेक्शन',
    };

String _placesAvailableHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => 'अभी $count स्थान उपलब्ध है',
      _ => 'अभी $count स्थान उपलब्ध हैं',
    };

String _removeTicketsHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count टिकट हटाएँ',
      _ => '$count टिकट हटाएँ',
    };

String _holdMinutesLeftHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count मिनट बाकी',
      _ => '$count मिनट बाकी',
    };

String _holdSecondsLeftHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count सेकंड बाकी',
      _ => '$count सेकंड बाकी',
    };

String _holdLapsedBodyHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => 'ये सीटें $count मिनट के लिए होल्ड थीं।',
      _ => 'ये सीटें $count मिनट के लिए होल्ड थीं।',
    };

String _seatsNotRecoveredHi(int count) =>
    switch (pickerPluralCategory('hi', count)) {
      PickerPluralCategory.one => '$count सीट वापस नहीं मिल सकी',
      _ => '$count सीटें वापस नहीं मिल सकीं',
    };

String _continueWithTotalHi(String money) => 'आगे बढ़ें \u00b7 $money';

/// The `hi` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHi = SeatLayerPickerStrings(
  close: 'बंद करें',
  overview: 'वेन्यू',
  backToVenue: 'वेन्यू पर वापस',
  cancel: 'रद्द करें',
  select: 'चुनें',
  removeSeat: 'सीट हटाएँ',
  viewFromHere: 'यहाँ से व्यू',
  openVenue360: 'वेन्यू 360° खोलें',
  recentre: 'स्टेज को बीच में लाएँ',
  viewFromYourSeat: 'आपकी सीट से व्यू',
  emptyTrayHint:
      'मैप पर किसी सीट पर टैप करें, या हमें आपके लिए सबसे अच्छी उपलब्ध सीटें चुनने दें।',
  anyTicketType: 'कोई भी टिकट टाइप',
  anyVenueZone: 'कोई भी ज़ोन',
  bestSeats: 'सबसे अच्छी सीटें',
  showLess: 'कम दिखाएँ',
  undo: 'पहले जैसा करें',
  holdAndCheckout: 'सीटें होल्ड करें और चेकआउट करें',
  poweredBy: 'SeatLayer द्वारा संचालित',
  testMode: 'टेस्ट मोड',
  accessibility: 'सुलभता और रंग के विकल्प',
  accessibilityTitle: 'सुलभता और रंग के विकल्प',
  fitVenue: 'पूरा वेन्यू दिखाएँ',
  fitWholeVenue: 'पूरा वेन्यू दिखाएँ',
  loading: 'सीट मैप लोड हो रहा है…',
  errorMessage: 'सीट मैप लोड नहीं हुआ',
  retry: 'फिर कोशिश करें',
  accessRefresh: 'रिफ़्रेश करें',
  noSeatsSelected: 'कोई सीट नहीं चुनी गई',
  findBestSeatsCta: 'सबसे अच्छी सीटें खोजें',
  organizerNote: 'आयोजक का नोट',
  accessiblePhysicalSeat: 'सुलभ सीट',
  emptyWheelchairSpace: 'खाली व्हीलचेयर स्थान',
  findSeatsTogether: 'साथ वाली सीटें खोजें',
  aboutBestSeats: 'साथ वाली सीटें खोजने के बारे में',
  closestGroupChosenInstantly: 'सबसे पास का उपलब्ध ग्रुप, तुरंत चुना गया।',
  hideLimitedView: 'सीमित व्यू वाली सीटें छिपाएँ',
  colorblindSafe: 'कलरब्लाइंड-फ़्रेंडली रंग',
  notAvailable: 'उपलब्ध नहीं',
  viewGroupTitle: 'दृश्य',
  restrictedView: 'सीमित व्यू',
  obstructedView: 'रुकावट वाला व्यू',
  premiumSeat: 'प्रीमियम सीट',
  continueWord: 'आगे बढ़ें',
  allFloors: 'सभी फ़्लोर',
  previousSection: 'पिछला सेक्शन',
  nextSection: 'अगला सेक्शन',
  addSeat: 'सीट जोड़ें',
  added: 'जोड़ी गई',
  sectionWord: 'सेक्शन',
  rowWord: 'पंक्ति',
  seatWord: 'सीट',
  seeItIn3D: '3D में देखें',
  viewFromThisSeat: 'इस सीट से व्यू',
  allPrices: 'सभी कीमतें',
  ticketType: 'टिकट टाइप',
  tierCompanionGuidance: 'बगल वाला व्हीलचेयर स्थान भी लेना ज़रूरी है',
  findingBestSeats: 'सबसे अच्छी सीटें खोज रहे हैं…',
  findSeats: 'सीटें खोजें',
  expandCart: 'टिकट पैनल खोलें',
  collapseCart: 'टिकट पैनल छोटा करें',
  continueToCheckout: 'चेकआउट पर जाएँ',
  secureMore: 'और होल्ड करें',
  selectSeats: 'सीटें चुनें',
  pickYourSeats: 'अपनी सीटें चुनें',
  salesClosedPill: 'बिक्री बंद है',
  salesClosedCta: 'बिक्री बंद',
  confirmOrCancelSeat: 'यह सीट कन्फ़र्म या रद्द करें',
  securingSeats: 'आपकी सीटें होल्ड की जा रही हैं…',
  openingCheckout: 'सुरक्षित चेकआउट खुल रहा है…',
  testModeExplained:
      'यहाँ की बुकिंग असली नहीं है और कार्ड से कोई पैसा नहीं कटेगा',
  displayOptions: 'डिस्प्ले विकल्प',
  companionSeatsNote: 'बगल की साथी सीटें चुनी जा सकती हैं',
  zoomIn: 'ज़ूम इन',
  zoomOut: 'ज़ूम आउट',
  rotateVenue: 'वेन्यू घुमाने के लिए ड्रैग करें',
  moveVenue: 'वेन्यू खिसकाने के लिए ड्रैग करें',
  mapView: 'मैप',
  flat2dMap: '2D मैप',
  interactive3dVenueView: 'इंटरैक्टिव 3D वेन्यू व्यू',
  venueView: 'वेन्यू व्यू',
  holdLapsedTitle: 'आपकी सीटें छोड़ दी गईं',
  salesClosed: 'बिक्री बंद है',
  salesClosedCopy: 'इस इवेंट की टिकट बिक्री खत्म हो गई है।',
  salesClosedToast: 'इस इवेंट की बिक्री बंद है।',
  soldOutEyebrow: 'यह इवेंट',
  soldOutTitle: 'सोल्ड आउट',
  soldOutCopy: 'इस इवेंट के लिए अभी कोई रिज़र्व्ड सीट उपलब्ध नहीं है।',
  holdExpired:
      'आपकी सीटों का होल्ड खत्म हो गया और वे छोड़ दी गईं। फिर से चुनें।',
  addingEllipsis: 'जोड़ रहे हैं…',
  moreTimeAdded: 'और समय जोड़ दिया गया। आपकी सीटें अब भी होल्ड पर हैं।',
  couldNotAddMoreTime: 'और समय नहीं जुड़ सका। कृपया अभी चेकआउट करें।',
  seatsJustTaken: 'एक या ज़्यादा सीटें अभी-अभी बुक हो गईं। कृपया फिर से चुनें।',
  allSetTitle: 'सब तैयार है',
  confirmedAndOnWay: 'की बुकिंग कन्फ़र्म हो गई है। कन्फ़र्मेशन भेजा जा रहा है।',
  backToMap: 'मैप पर वापस',
  mapDidNotLoad: 'सीट मैप लोड नहीं हुआ',
  checkConnection: 'अपना इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।',
  accessPausedTitle: 'ये सीटें अभी होल्ड पर हैं',
  accessPausedCopy:
      'आयोजक ने यह चयन फ़िलहाल रोक दिया है। कुछ मिनट बाद फिर कोशिश करें।',
  accessRevokedTitle: 'यह एक्सेस लिंक अब चालू नहीं है',
  accessRevokedCopy:
      'ये सीटें बुक करना जारी रखने के लिए, जिन्होंने आपको लिंक भेजा है उनसे नया लिंक माँगें।',
  accessUnverifiedTitle: 'हम आपका एक्सेस वेरिफ़ाई नहीं कर पाए',
  accessUnverifiedCopy:
      'उपलब्ध दिख रही कोई भी सीट आप अब भी बुक कर सकते हैं। बाकी सीटों के एक्सेस के लिए उनसे संपर्क करें जिन्होंने आपको यह लिंक भेजा है।',
  generalAdmission: 'जनरल एडमिशन',
  numberOfGuests: 'मेहमानों की संख्या',
  chooseGuestsCopy:
      'चुनें कि कितने मेहमान साथ बैठेंगे। यह टेबल सिर्फ़ आपके ग्रुप के लिए होल्ड है।',
  fewerGuests: 'कम मेहमान',
  moreGuests: 'ज़्यादा मेहमान',
  selectTable: 'टेबल चुनें',
  updateTable: 'टेबल अपडेट करें',
  removeWord: 'हटाएँ',
  floorWord: 'फ़्लोर',
  totalWord: 'कुल',
  chooseSeats: 'अपनी सीटें चुनें',
  chooseTickets: 'टिकट चुनें',
  placeWord: 'स्थान',
  ticketWord: 'टिकट',
  passport: 'सीट प्रोफ़ाइल',
  venue3D: '3D',
  venueZone: 'वेन्यू ज़ोन',
  venueMapHint:
      'सीटें मैप के आसपास के कंट्रोल से चुनी जाती हैं: ऊपर प्राइस रेल, नीचे सेक्शन कंट्रोल, और सबसे नीचे टिकट पैनल।',
  previousSeat: 'पिछली सीट',
  nextSeat: 'अगली सीट',
  orbitMode: 'वेन्यू घुमाएँ',
  panMode: 'वेन्यू खिसकाएँ',
  openInteractive3dVenue: 'इंटरैक्टिव 3D वेन्यू खोलें',
  showSeatsFor: 'इनके लिए सीटें दिखाएँ',
  accessJumpFirstSection: 'पहले सेक्शन पर जाएँ',
  accessJumpNextSection: 'अगले सेक्शन पर जाएँ',
  fewerTickets: 'कम टिकट',
  moreTickets: 'ज़्यादा टिकट',
  addTickets: 'टिकट जोड़ें',
  noSelectableSeats: 'अभी चुनने लायक कोई सीट उपलब्ध नहीं है।',
  confirmYourTickets: 'अपने टिकट कन्फ़र्म करें',
  seatsSecuredOpeningCheckout: 'सीटें होल्ड हो गईं। चेकआउट खुल रहा है…',
  holdInCheckoutTitle: 'आपकी सीटें पहले से चेकआउट में हैं',
  holdInCheckoutBody:
      'इन्हें रखने के लिए चेकआउट पूरा करें। दूसरी सीटें चुनने के लिए पहले इन्हें छोड़ें — ये फिर से बिक्री पर चली जाएँगी।',
  releaseAndChangeSeats: 'छोड़ें और सीटें बदलें',
  holdAlreadyHeldTitle: 'आपकी सीटें पहले से होल्ड पर हैं',
  holdAlreadyHeldBody: 'इन्हें रखने के लिए चेकआउट पर जाएँ।',
  accessExpiredTitle: 'आपका सीट सेशन खत्म हो गया',
  accessExpiredCopy:
      'जारी रखने के लिए सीट मैप दोबारा लोड करें। आपकी कार्ट में पहले से रखी सीटें टाइमर खत्म होने तक होल्ड पर रहेंगी।',
  dismissError: 'एरर बंद करें',
  testModeLong: 'टेस्ट मोड · कुछ भी बुक नहीं होगा',
  accessNeeds: <String, String>{
    'wheelchair': 'व्हीलचेयर स्थान',
    'companion': 'साथी सीट',
    'semi-ambulatory': 'सीमित गतिशीलता',
    'designated-aisle': 'आइल / ट्रांसफ़र',
    'step-free': 'बिना सीढ़ी',
    'hearing': 'सुनने में सहायता',
    'cart': 'लाइव कैप्शन',
    'sign-language': 'साइन लैंग्वेज',
    'low-vision': 'कम दृष्टि',
    'sensory-friendly': 'सेंसरी-फ़्रेंडली',
    'plus-size': 'प्लस-साइज़',
    'lift-armrest': 'उठने वाला आर्मरेस्ट',
  },
  seatsLeft: _seatsLeftHi,
  moreCount: _moreCountHi,
  addMinutes: _addMinutesHi,
  fromPrice: _fromPriceHi,
  sightline: _sightlineHi,
  secureMoreAndCheckout: _secureMoreAndCheckoutHi,
  accessFreeCount: _accessFreeCountHi,
  seatJustTakenByAnother: _seatJustTakenByAnotherHi,
  peekSecured: _peekSecuredHi,
  venueMap: _venueMapHi,
  accessibleStep: _accessibleStepHi,
  chooseMinMaxGuests: _chooseMinMaxGuestsHi,
  chooseMore: _chooseMoreHi,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeHi,
  ticketCount: _ticketCountHi,
  findBestSeats: _findBestSeatsHi,
  reselectSeats: _reselectSeatsHi,
  seatsFree: _seatsFreeHi,
  seatsLeftInSection: _seatsLeftInSectionHi,
  holdLapsedStillFree: _holdLapsedStillFreeHi,
  holdLapsedSomeTaken: _holdLapsedSomeTakenHi,
  holdLapsedAllTaken: _holdLapsedAllTakenHi,
  accessibleSections: _accessibleSectionsHi,
  placesAvailable: _placesAvailableHi,
  removeTickets: _removeTicketsHi,
  holdMinutesLeft: _holdMinutesLeftHi,
  holdSecondsLeft: _holdSecondsLeftHi,
  holdLapsedBody: _holdLapsedBodyHi,
  seatsNotRecovered: _seatsNotRecoveredHi,
  continueWithTotal: _continueWithTotalHi,
);
