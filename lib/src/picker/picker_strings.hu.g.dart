// GENERATED — do not edit.
//
// Source: design/locale_strings.json (hu)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftHu(int count) => '$count maradt';

String _moreCountHu(int count) => '+$count további';

String _addMinutesHu(int minutes) => '+$minutes perc';

String _fromPriceHu(String money) => '$money-tól';

String _sightlineHu(String metres) => '≈ $metres m a színpadig';

String _secureMoreAndCheckoutHu(int count) => 'Még $count rögzítése és fizetés';

String _accessFreeCountHu(int count) => '$count szabad';

String _seatJustTakenByAnotherHu(String label) =>
    'A(z) $label helyet az imént elvitte egy másik vásárló.';

String _peekSecuredHu(int count, String total) =>
    '✓ $count rögzítve · $total. Még nem terhelünk meg';

String _ticketCountHu(int count) => count == 1 ? '$count jegy' : '$count jegy';

String _findBestSeatsHu(int count) => count == 1
    ? '$count legjobb hely keresése'
    : '$count legjobb hely keresése';

String _reselectSeatsHu(int count) =>
    count == 1 ? 'Válassza ki újra' : 'Válassza ki őket újra';

String _seatsFreeHu(int count) => count == 1 ? '$count hely' : '$count hely';

String _seatsLeftInSectionHu(int count) =>
    count == 1 ? '$count hely maradt' : '$count hely maradt';

String _holdLapsedStillFreeHu(int count) => count == 1
    ? 'A foglalása lejárt, amíg távol volt. Ez a hely még szabad.'
    : 'A foglalása lejárt, amíg távol volt. Ezek a helyek még szabadok.';

String _holdLapsedSomeTakenHu(int count) => count == 1
    ? 'A foglalása lejárt, amíg távol volt, és ezek közül $count hely már elkelt. A többi még szabad.'
    : 'A foglalása lejárt, amíg távol volt, és ezek közül $count hely már elkelt. A többi még szabad.';

String _holdLapsedAllTakenHu(int count) => count == 1
    ? 'A foglalása lejárt, amíg távol volt, és ez a hely már elkelt.'
    : 'A foglalása lejárt, amíg távol volt, és ezek a helyek már elkeltek.';

String _continueWithTotalHu(String money) => 'Tovább \u00b7 $money';

/// The `hu` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHu = SeatLayerPickerStrings(
  close: 'Bezárás',
  overview: 'Helyszín',
  backToVenue: 'Vissza a helyszínhez',
  cancel: 'Mégse',
  select: 'Kiválasztás',
  removeSeat: 'Hely eltávolítása',
  viewFromHere: 'Kilátás innen',
  openVenue360: 'Helyszín megnyitása 360°-ban',
  recentre: 'Középre a színpadra',
  viewFromYourSeat: 'kilátás az Ön helyéről',
  emptyTrayHint:
      'Koppints egy helyre az üléstervben, vagy bízd ránk a legjobb szabad helyek kiválasztását.',
  anyTicketType: 'Bármelyik jegytípus',
  anyVenueZone: 'Bármelyik zóna',
  bestSeats: 'Legjobb helyek',
  showLess: 'Kevesebb megjelenítése',
  undo: 'Visszavonás',
  holdAndCheckout: 'Helyek foglalása és fizetés',
  poweredBy: 'SeatLayer technológiával',
  testMode: 'TESZTÜZEMMÓD',
  accessibility: 'Akadálymentesítési és színbeállítások',
  accessibilityTitle: 'Akadálymentesítési és színbeállítások',
  fitVenue: 'Teljes helyszín megjelenítése',
  fitWholeVenue: 'Teljes helyszín megjelenítése',
  loading: 'Ülésterv betöltése…',
  errorMessage: 'Az ülésterv nem töltődött be',
  retry: 'Újrapróbálom',
  accessRefresh: 'Frissítés',
  noSeatsSelected: 'Nincs kiválasztott hely',
  findBestSeatsCta: 'Legjobb helyek keresése',
  organizerNote: 'Szervezői megjegyzés',
  accessiblePhysicalSeat: 'Akadálymentes fizikai hely',
  emptyWheelchairSpace: 'Üres kerekesszékes hely',
  findSeatsTogether: 'Egymás melletti helyek keresése',
  aboutBestSeats: 'Az egymás melletti helyek kereséséről',
  closestGroupChosenInstantly:
      'A legközelebbi szabad csoport, azonnal kiválasztva.',
  hideLimitedView: 'Korlátozott kilátású helyek elrejtése',
  colorblindSafe: 'Színvakbarát színek',
  notAvailable: 'Nem elérhető',
  restrictedView: 'Korlátozott kilátás',
  obstructedView: 'Takart kilátás',
  premiumSeat: 'Prémium hely',
  continueWord: 'Tovább',
  allFloors: 'Minden emelet',
  previousSection: 'Előző szektor',
  nextSection: 'Következő szektor',
  addSeat: 'Hely hozzáadása',
  added: 'Hozzáadva',
  sectionWord: 'Szektor',
  rowWord: 'Sor',
  seatWord: 'Hely',
  seeItIn3D: 'Megnézem 3D-ben',
  viewFromThisSeat: 'Kilátás erről a helyről',
  allPrices: 'Minden ár',
  ticketType: 'Jegytípus',
  tierCompanionGuidance: 'A szomszédos kerekesszékes helyet igényli',
  findingBestSeats: 'A legjobb helyeket keressük…',
  findSeats: 'Helyek keresése',
  expandCart: 'Jegypanel megnyitása',
  collapseCart: 'Jegypanel összecsukása',
  continueToCheckout: 'Tovább a fizetéshez',
  secureMore: 'Több rögzítése',
  selectSeats: 'Helyek kiválasztása',
  pickYourSeats: 'Válaszd ki a helyeidet',
  salesClosedPill: 'Az értékesítés lezárult',
  salesClosedCta: 'Az értékesítés lezárult',
  confirmOrCancelSeat: 'Erősítsd meg vagy vond vissza ezt a helyet',
  securingSeats: 'Helyeid rögzítése…',
  openingCheckout: 'Biztonságos fizetés megnyitása…',
  testModeExplained:
      'Az itteni foglalások nem valósak, és nem terhelünk meg semmilyen kártyát',
  displayOptions: 'Megjelenítési beállítások',
  companionSeatsNote: 'A mellettük lévő kísérőhelyek továbbra is választhatók',
  zoomIn: 'Nagyítás',
  zoomOut: 'Kicsinyítés',
  rotateVenue: 'Húzza a helyszín forgatásához',
  moveVenue: 'Húzza a helyszín mozgatásához',
  mapView: 'Ülésterv',
  flat2dMap: 'Sík 2D ülésterv',
  interactive3dVenueView: 'Interaktív 3D helyszínnézet',
  venueView: 'Helyszínnézet',
  holdLapsedTitle: 'A helyeit felszabadítottuk',
  salesClosed: 'Az értékesítés lezárult',
  salesClosedCopy: 'Az eseményre a jegyértékesítés véget ért.',
  salesClosedToast: 'Az eseményre az értékesítés lezárult.',
  soldOutEyebrow: 'Ez az esemény',
  soldOutTitle: 'Elfogyott',
  soldOutCopy: 'Jelenleg nincs szabad számozott hely erre az eseményre.',
  holdExpired: 'A foglalásod lejárt. A helyek felszabadultak. Válassz újra.',
  addingEllipsis: 'Hozzáadás…',
  moreTimeAdded: 'Több időt adtunk. A helyeid továbbra is le vannak foglalva.',
  couldNotAddMoreTime:
      'Nem sikerült több időt adni. Kérjük, most menj a fizetéshez.',
  seatsJustTaken: 'Egy vagy több helyet az imént elvittek. Válassz újra.',
  allSetTitle: 'Minden készen áll',
  confirmedAndOnWay: 'megerősítve. A visszaigazolás úton van.',
  backToMap: 'Vissza az üléstervhez',
  mapDidNotLoad: 'Az ülésterv nem töltődött be',
  checkConnection: 'Ellenőrizd a kapcsolatot, és próbáld újra.',
  accessPausedTitle: 'Ezek a helyek épp zárolva vannak',
  accessPausedCopy:
      'A szervező szüneteltette ezt a kiválasztást. Próbáld újra néhány perc múlva.',
  accessRevokedTitle: 'Ez a hozzáférési link már nem aktív',
  accessRevokedCopy:
      'Kérj új linket attól, aki ide küldött, hogy tovább foglalhasd ezeket a helyeket.',
  accessUnverifiedTitle: 'Nem tudtuk ellenőrizni a hozzáférésedet',
  accessUnverifiedCopy:
      'Továbbra is megvásárolhatsz mindent, ami szabadként látszik. A többihez való hozzáférésért fordulj ahhoz, aki ide küldött.',
  generalAdmission: 'Szabad beülés',
  numberOfGuests: 'Vendégek száma',
  chooseGuestsCopy:
      'Válaszd ki, hány vendég ül együtt. Ezt az asztalt kizárólag a te társaságodnak tartjuk fenn.',
  fewerGuests: 'Kevesebb vendég',
  moreGuests: 'Több vendég',
  selectTable: 'Asztal kiválasztása',
  updateTable: 'Asztal frissítése',
  removeWord: 'Eltávolítás',
  floorWord: 'Emelet',
  totalWord: 'Összesen',
  accessNeeds: <String, String>{
    'wheelchair': 'Kerekesszékes hely',
    'companion': 'Kísérőhely',
    'semi-ambulatory': 'Korlátozott mozgásképesség',
    'designated-aisle': 'Sorszél / átülés',
    'step-free': 'Lépcsőmentes',
    'hearing': 'Hallássegítő rendszer',
    'cart': 'Élő feliratozás',
    'sign-language': 'Jelnyelv',
    'low-vision': 'Gyengénlátó',
    'sensory-friendly': 'Ingerszegény',
    'plus-size': 'Szélesebb hely',
    'lift-armrest': 'Felhajtható kartámasz',
  },
  seatsLeft: _seatsLeftHu,
  moreCount: _moreCountHu,
  addMinutes: _addMinutesHu,
  fromPrice: _fromPriceHu,
  sightline: _sightlineHu,
  secureMoreAndCheckout: _secureMoreAndCheckoutHu,
  accessFreeCount: _accessFreeCountHu,
  seatJustTakenByAnother: _seatJustTakenByAnotherHu,
  peekSecured: _peekSecuredHu,
  ticketCount: _ticketCountHu,
  findBestSeats: _findBestSeatsHu,
  reselectSeats: _reselectSeatsHu,
  seatsFree: _seatsFreeHu,
  seatsLeftInSection: _seatsLeftInSectionHu,
  holdLapsedStillFree: _holdLapsedStillFreeHu,
  holdLapsedSomeTaken: _holdLapsedSomeTakenHu,
  holdLapsedAllTaken: _holdLapsedAllTakenHu,
  continueWithTotal: _continueWithTotalHu,
);
