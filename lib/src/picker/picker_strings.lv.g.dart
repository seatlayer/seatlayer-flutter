// GENERATED — do not edit.
//
// Source: design/locale_strings.json (lv)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftLv(int count) => 'Atlicis $count';

String _moreCountLv(int count) => '+$count vairāk';

String _addMinutesLv(int minutes) => '+$minutes min';

String _fromPriceLv(String money) => 'No $money';

String _sightlineLv(String metres) => '≈ $metres m līdz skatuvei';

String _secureMoreAndCheckoutLv(int count) => 'Nodrošināt vēl $count un maksāt';

String _accessFreeCountLv(int count) => '$count brīvas';

String _seatJustTakenByAnotherLv(String label) =>
    'Vietu $label tikko aizņēma cits pircējs.';

String _peekSecuredLv(int count, String total) =>
    '✓ $count nodrošinātas · $total. Vēl nekas netiks norakstīts';

String _venueMapLv(String venue) => 'Vietu plāns: $venue';

String _accessibleStepLv(int index, int total) => '$index no $total';

String _chooseMinMaxGuestsLv(int min, int max) =>
    'Izvēlieties no $min līdz $max viesiem.';

String _chooseMoreLv(int count) => 'Izvēlēties vēl $count';

String _seatsHeldForNeedMoreTimeLv(String time) =>
    'Jūsu vietas rezervētas vēl $time. Vai nepieciešams vairāk laika?';

String _ticketCountLv(int count) => switch (pickerPluralCategory('lv', count)) {
  PickerPluralCategory.zero => '$count biļešu',
  PickerPluralCategory.one => '$count biļete',
  _ => '$count biļetes',
};

String _findBestSeatsLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Atrast $count labāko vietu',
      PickerPluralCategory.one => 'Atrast $count labāko vietu',
      _ => 'Atrast $count labākās vietas',
    };

String _reselectSeatsLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Izvēlēties tās vēlreiz',
      PickerPluralCategory.one => 'Izvēlēties to vēlreiz',
      _ => 'Izvēlēties tās vēlreiz',
    };

String _seatsFreeLv(int count) => switch (pickerPluralCategory('lv', count)) {
  PickerPluralCategory.zero => '$count vietu',
  PickerPluralCategory.one => '$count vieta',
  _ => '$count vietas',
};

String _seatsLeftInSectionLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Atlikušas $count vietu',
      PickerPluralCategory.one => 'Atlikusi $count vieta',
      _ => 'Atlikušas $count vietas',
    };

String _holdLapsedStillFreeLv(int count) => switch (pickerPluralCategory(
  'lv',
  count,
)) {
  PickerPluralCategory.zero =>
    'Tavs rezervējums beidzās, kamēr biji prom. Šīs vietas joprojām ir brīvas.',
  PickerPluralCategory.one =>
    'Tavs rezervējums beidzās, kamēr biji prom. Šī vieta joprojām ir brīva.',
  _ =>
    'Tavs rezervējums beidzās, kamēr biji prom. Šīs vietas joprojām ir brīvas.',
};

String _holdLapsedSomeTakenLv(int count) => switch (pickerPluralCategory(
  'lv',
  count,
)) {
  PickerPluralCategory.zero =>
    'Tavs rezervējums beidzās, kamēr biji prom, un $count no šīm vietām jau ir aizņemtas. Pārējās joprojām ir brīvas.',
  PickerPluralCategory.one =>
    'Tavs rezervējums beidzās, kamēr biji prom, un $count no šīm vietām jau ir aizņemta. Pārējās joprojām ir brīvas.',
  _ =>
    'Tavs rezervējums beidzās, kamēr biji prom, un $count no šīm vietām jau ir aizņemtas. Pārējās joprojām ir brīvas.',
};

String _holdLapsedAllTakenLv(int count) => switch (pickerPluralCategory(
  'lv',
  count,
)) {
  PickerPluralCategory.zero =>
    'Tavs rezervējums beidzās, kamēr biji prom, un šīs vietas jau ir aizņemtas.',
  PickerPluralCategory.one =>
    'Tavs rezervējums beidzās, kamēr biji prom, un šī vieta jau ir aizņemta.',
  _ =>
    'Tavs rezervējums beidzās, kamēr biji prom, un šīs vietas jau ir aizņemtas.',
};

String _accessibleSectionsLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => '$count sektori',
      PickerPluralCategory.one => '$count sektors',
      _ => '$count sektori',
    };

String _placesAvailableLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Pašlaik pieejamas $count vietas',
      PickerPluralCategory.one => 'Pašlaik pieejama $count vieta',
      _ => 'Pašlaik pieejamas $count vietas',
    };

String _removeTicketsLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Noņemt $count biļetes',
      PickerPluralCategory.one => 'Noņemt $count biļeti',
      _ => 'Noņemt $count biļetes',
    };

String _holdMinutesLeftLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Atlikušas $count minūtes',
      PickerPluralCategory.one => 'Atlikusi $count minūte',
      _ => 'Atlikušas $count minūtes',
    };

String _holdSecondsLeftLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Atlikušas $count sekundes',
      PickerPluralCategory.one => 'Atlikusi $count sekunde',
      _ => 'Atlikušas $count sekundes',
    };

String _holdLapsedBodyLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => 'Tās bija rezervētas uz $count minūtēm.',
      PickerPluralCategory.one => 'Tās bija rezervētas uz $count minūti.',
      _ => 'Tās bija rezervētas uz $count minūtēm.',
    };

String _seatsNotRecoveredLv(int count) =>
    switch (pickerPluralCategory('lv', count)) {
      PickerPluralCategory.zero => '$count vietas neizdevās atgūt',
      PickerPluralCategory.one => '$count vietu neizdevās atgūt',
      _ => '$count vietas neizdevās atgūt',
    };

String _continueWithTotalLv(String money) => 'Turpināt \u00b7 $money';

/// The `lv` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsLv = SeatLayerPickerStrings(
  close: 'Aizvērt',
  overview: 'Norises vieta',
  backToVenue: 'Atpakaļ uz norises vietu',
  cancel: 'Atcelt',
  select: 'Izvēlēties',
  removeSeat: 'Noņemt vietu',
  viewFromHere: 'Skats no šejienes',
  openVenue360: 'Atvērt norises vietu 360°',
  recentre: 'Atkal centrēt uz skatuvi',
  viewFromYourSeat: 'skats no jūsu vietas',
  emptyTrayHint:
      'Pieskarieties vietai plānā vai ļaujiet mums izvēlēties labākās pieejamās jums.',
  anyTicketType: 'Jebkurš biļetes veids',
  anyVenueZone: 'Jebkura zona',
  bestSeats: 'Labākās vietas',
  showLess: 'Rādīt mazāk',
  undo: 'Atsaukt',
  holdAndCheckout: 'Rezervēt vietas un maksāt',
  poweredBy: 'Darbojas ar SeatLayer',
  testMode: 'Testa režīms',
  accessibility: 'Pieejamības un krāsu iestatījumi',
  accessibilityTitle: 'Pieejamības un krāsu iestatījumi',
  fitVenue: 'Rādīt visu norises vietu',
  fitWholeVenue: 'Rādīt visu norises vietu',
  loading: 'Ielādējam vietu plānu…',
  errorMessage: 'Vietu plāns neielādējās',
  retry: 'Mēģināt vēlreiz',
  accessRefresh: 'Pārlādēt',
  noSeatsSelected: 'Nav izvēlēta neviena vieta',
  findBestSeatsCta: 'Atrast labākās vietas',
  organizerNote: 'Organizatora piezīme',
  accessiblePhysicalSeat: 'Pieejama fiziska vieta',
  emptyWheelchairSpace: 'Brīva ratiņkrēsla vieta',
  findSeatsTogether: 'Atrast vietas blakus',
  aboutBestSeats: 'Par blakus esošu vietu atrašanu',
  closestGroupChosenInstantly: 'Tuvākā pieejamā grupa, izvēlēta uzreiz.',
  hideLimitedView: 'Paslēpt vietas ar ierobežotu skatu',
  colorblindSafe: 'Daltoniķiem draudzīgas krāsas',
  notAvailable: 'Nav pieejams',
  viewGroupTitle: 'SKATS',
  restrictedView: 'Ierobežots skats',
  obstructedView: 'Aizsegts skats',
  premiumSeat: 'Premium vieta',
  continueWord: 'Turpināt',
  allFloors: 'Visi stāvi',
  previousSection: 'Iepriekšējais sektors',
  nextSection: 'Nākamais sektors',
  addSeat: 'Pievienot vietu',
  added: 'Pievienots',
  sectionWord: 'Sektors',
  rowWord: 'Rinda',
  seatWord: 'Vieta',
  seeItIn3D: 'Skatīt 3D',
  viewFromThisSeat: 'Skats no šīs vietas',
  allPrices: 'Visas cenas',
  ticketType: 'Biļetes veids',
  tierCompanionGuidance: 'Nepieciešama blakus esošā ratiņkrēsla vieta',
  findingBestSeats: 'Meklējam labākās vietas…',
  findSeats: 'Atrast vietas',
  expandCart: 'Atvērt biļešu paneli',
  collapseCart: 'Sakļaut biļešu paneli',
  continueToCheckout: 'Turpināt uz maksājumu',
  secureMore: 'Nodrošināt vairāk',
  selectSeats: 'Izvēlēties vietas',
  pickYourSeats: 'Izvēlieties savas vietas',
  salesClosedPill: 'Pārdošana slēgta',
  salesClosedCta: 'Pārdošana slēgta',
  confirmOrCancelSeat: 'Apstipriniet vai atceliet šo vietu',
  securingSeats: 'Nodrošinām jūsu vietas…',
  openingCheckout: 'Atveram drošo maksājumu…',
  testModeExplained:
      'Rezervācijas šeit nav īstas, un neviena karte netiek apmaksāta',
  displayOptions: 'Attēlojuma iestatījumi',
  companionSeatsNote: 'Blakus esošās pavadoņa vietas paliek izvēlamas',
  zoomIn: 'Tuvināt',
  zoomOut: 'Tālināt',
  rotateVenue: 'Velciet, lai pagrieztu norises vietu',
  moveVenue: 'Velciet, lai pārvietotu norises vietu',
  mapView: 'Plāns',
  flat2dMap: 'Plakans 2D plāns',
  interactive3dVenueView: 'Interaktīvs norises vietas 3D skats',
  venueView: 'Norises vietas skats',
  holdLapsedTitle: 'Jūsu vietas tika atbrīvotas',
  salesClosed: 'Pārdošana slēgta',
  salesClosedCopy: 'Biļešu pārdošana šim pasākumam ir beigusies.',
  salesClosedToast: 'Pārdošana šim pasākumam ir slēgta.',
  soldOutEyebrow: 'Šis pasākums',
  soldOutTitle: 'Izpārdots',
  soldOutCopy: 'Šim pasākumam pašlaik nav pieejamu numurētu vietu.',
  holdExpired:
      'Jūsu rezervācija beidzās. Vietas tika atbrīvotas. Izvēlieties no jauna.',
  addingEllipsis: 'Pievienojam…',
  moreTimeAdded: 'Pievienots laiks. Jūsu vietas joprojām ir rezervētas.',
  couldNotAddMoreTime:
      'Neizdevās pievienot laiku. Dodieties uz maksājumu tagad.',
  seatsJustTaken:
      'Viena vai vairākas vietas tikko tika aizņemtas. Izvēlieties no jauna.',
  allSetTitle: 'Viss ir gatavs',
  confirmedAndOnWay: 'apstiprināts. Apstiprinājums jau ceļā.',
  backToMap: 'Atpakaļ uz plānu',
  mapDidNotLoad: 'Vietu plāns neielādējās',
  checkConnection: 'Pārbaudiet savienojumu un mēģiniet vēlreiz.',
  accessPausedTitle: 'Šīs vietas pašlaik ir rezervētas',
  accessPausedCopy:
      'Organizators ir apturējis šo izvēli. Mēģiniet vēlreiz pēc dažām minūtēm.',
  accessRevokedTitle: 'Šī piekļuves saite vairs nav aktīva',
  accessRevokedCopy:
      'Palūdziet jaunu saiti tam, kas to jums nosūtīja, lai turpinātu rezervēt šīs vietas.',
  accessUnverifiedTitle: 'Neizdevās pārbaudīt jūsu piekļuvi',
  accessUnverifiedCopy:
      'Joprojām varat iegādāties visu, kas rādīts kā pieejams. Par piekļuvi pārējam sazinieties ar to, kas jums nosūtīja saiti.',
  generalAdmission: 'Brīva ieeja',
  numberOfGuests: 'Viesu skaits',
  chooseGuestsCopy:
      'Izvēlieties, cik viesu sēdēs kopā. Šis galds tiek rezervēts tikai jūsu kompānijai.',
  fewerGuests: 'Mazāk viesu',
  moreGuests: 'Vairāk viesu',
  selectTable: 'Izvēlēties galdu',
  updateTable: 'Atjaunināt galdu',
  removeWord: 'Noņemt',
  floorWord: 'Stāvs',
  totalWord: 'Kopā',
  chooseSeats: 'Izvēlieties savas vietas',
  chooseTickets: 'Izvēlieties biļetes',
  placeWord: 'VIETA',
  ticketWord: 'Biļete',
  passport: 'Vietas profils',
  venue3D: '3D',
  venueZone: 'Norises vietas zona',
  venueMapHint:
      'Vietas izvēlas ar vadīklām ap plānu: cenu joslu virs tā, sektoru vadīklām zem tā un biļešu paneli apakšā.',
  previousSeat: 'Iepriekšējā vieta',
  nextSeat: 'Nākamā vieta',
  orbitMode: 'Pagriezt norises vietu',
  panMode: 'Pārvietot norises vietu',
  openInteractive3dVenue: 'Atvērt interaktīvu norises vietas 3D skatu',
  showSeatsFor: 'RĀDĪT PIEMĒROTĀS VIETAS',
  accessJumpFirstSection: 'Pāriet uz pirmo sektoru',
  accessJumpNextSection: 'Pāriet uz nākamo sektoru',
  fewerTickets: 'Mazāk biļešu',
  moreTickets: 'Vairāk biļešu',
  addTickets: 'Pievienot biļetes',
  noSelectableSeats: 'Pašlaik nav pieejamu vietu, ko izvēlēties.',
  confirmYourTickets: 'Apstiprināt biļetes',
  seatsSecuredOpeningCheckout: 'Vietas nodrošinātas. Atveram maksājumu…',
  holdInCheckoutTitle: 'Jūsu vietas jau ir maksājuma procesā',
  holdInCheckoutBody:
      'Pabeidziet maksājumu, lai tās paturētu. Lai izvēlētos citas vietas, vispirms atbrīvojiet šīs — tās atgriezīsies pārdošanā.',
  releaseAndChangeSeats: 'Atbrīvot un mainīt vietas',
  holdAlreadyHeldTitle: 'Jūsu vietas jau ir rezervētas',
  holdAlreadyHeldBody: 'Turpiniet uz maksājumu, lai tās paturētu.',
  accessExpiredTitle: 'Jūsu vietu izvēles sesija ir beigusies',
  accessExpiredCopy:
      'Pārlādējiet vietu plānu, lai turpinātu. Vietas, kas jau ir jūsu grozā, paliek rezervētas, līdz beidzas taimeris.',
  dismissError: 'Aizvērt kļūdas paziņojumu',
  testModeLong: 'Testa režīms · nekas netiek rezervēts',
  accessNeeds: <String, String>{
    'wheelchair': 'Ratiņkrēsla vieta',
    'companion': 'Pavadoņa vieta',
    'semi-ambulatory': 'Ierobežota kustība',
    'designated-aisle': 'Eja / pārsēšanās',
    'step-free': 'Bez pakāpieniem',
    'hearing': 'Dzirdes atbalsts',
    'cart': 'Tiešraides subtitri',
    'sign-language': 'Zīmju valoda',
    'low-vision': 'Vājredzība',
    'sensory-friendly': 'Sensori draudzīga',
    'plus-size': 'Platāka vieta',
    'lift-armrest': 'Paceļams roku balsts',
  },
  seatsLeft: _seatsLeftLv,
  moreCount: _moreCountLv,
  addMinutes: _addMinutesLv,
  fromPrice: _fromPriceLv,
  sightline: _sightlineLv,
  secureMoreAndCheckout: _secureMoreAndCheckoutLv,
  accessFreeCount: _accessFreeCountLv,
  seatJustTakenByAnother: _seatJustTakenByAnotherLv,
  peekSecured: _peekSecuredLv,
  venueMap: _venueMapLv,
  accessibleStep: _accessibleStepLv,
  chooseMinMaxGuests: _chooseMinMaxGuestsLv,
  chooseMore: _chooseMoreLv,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeLv,
  ticketCount: _ticketCountLv,
  findBestSeats: _findBestSeatsLv,
  reselectSeats: _reselectSeatsLv,
  seatsFree: _seatsFreeLv,
  seatsLeftInSection: _seatsLeftInSectionLv,
  holdLapsedStillFree: _holdLapsedStillFreeLv,
  holdLapsedSomeTaken: _holdLapsedSomeTakenLv,
  holdLapsedAllTaken: _holdLapsedAllTakenLv,
  accessibleSections: _accessibleSectionsLv,
  placesAvailable: _placesAvailableLv,
  removeTickets: _removeTicketsLv,
  holdMinutesLeft: _holdMinutesLeftLv,
  holdSecondsLeft: _holdSecondsLeftLv,
  holdLapsedBody: _holdLapsedBodyLv,
  seatsNotRecovered: _seatsNotRecoveredLv,
  continueWithTotal: _continueWithTotalLv,
);
