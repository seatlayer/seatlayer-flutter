// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftSl(int count) => 'Ostalo $count';

String _moreCountSl(int count) => '+$count več';

String _addMinutesSl(int minutes) => '+$minutes min';

String _fromPriceSl(String money) => 'Od $money';

String _sightlineSl(String metres) => '≈ $metres m do odra';

String _secureMoreAndCheckoutSl(int count) => 'Zagotovi še $count in plačaj';

String _accessFreeCountSl(int count) => 'Prostih: $count';

String _seatJustTakenByAnotherSl(String label) =>
    'Sedež $label je pravkar zasedel drug kupec.';

String _peekSecuredSl(int count, String total) =>
    '✓ $count zagotovljenih · $total. Zdaj še ne bomo bremenili';

String _ticketCountSl(int count) => switch (pickerPluralCategory('sl', count)) {
  PickerPluralCategory.one => '$count vstopnica',
  PickerPluralCategory.two => '$count vstopnici',
  PickerPluralCategory.few => '$count vstopnice',
  _ => '$count vstopnic',
};

String _findBestSeatsSl(int count) =>
    switch (pickerPluralCategory('sl', count)) {
      PickerPluralCategory.one => 'Poišči $count najboljši sedež',
      PickerPluralCategory.two => 'Poišči $count najboljša sedeža',
      PickerPluralCategory.few => 'Poišči $count najboljše sedeže',
      _ => 'Poišči $count najboljših sedežev',
    };

String _reselectSeatsSl(int count) =>
    switch (pickerPluralCategory('sl', count)) {
      PickerPluralCategory.one => 'Znova ga izberite',
      PickerPluralCategory.two => 'Znova ju izberite',
      PickerPluralCategory.few => 'Znova jih izberite',
      _ => 'Znova jih izberite',
    };

String _seatsFreeSl(int count) => switch (pickerPluralCategory('sl', count)) {
  PickerPluralCategory.one => '$count sedež',
  PickerPluralCategory.two => '$count sedeža',
  PickerPluralCategory.few => '$count sedeži',
  _ => '$count sedežev',
};

String _seatsLeftInSectionSl(int count) =>
    switch (pickerPluralCategory('sl', count)) {
      PickerPluralCategory.one => 'Ostal $count sedež',
      PickerPluralCategory.two => 'Ostala $count sedeža',
      PickerPluralCategory.few => 'Ostali $count sedeži',
      _ => 'Ostalo $count sedežev',
    };

String _holdLapsedStillFreeSl(int count) => switch (pickerPluralCategory(
  'sl',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo. Ta sedež je še vedno prost.',
  PickerPluralCategory.two =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo. Ta sedeža sta še vedno prosta.',
  PickerPluralCategory.few =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo. Ti sedeži so še vedno prosti.',
  _ =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo. Ti sedeži so še vedno prosti.',
};

String _holdLapsedSomeTakenSl(int count) => switch (pickerPluralCategory(
  'sl',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in $count teh sedežev je že zaseden. Ostali so še vedno prosti.',
  PickerPluralCategory.two =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in $count teh sedežev sta že zasedena. Ostali so še vedno prosti.',
  PickerPluralCategory.few =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in $count teh sedežev so že zasedeni. Ostali so še vedno prosti.',
  _ =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in $count teh sedežev je že zasedenih. Ostali so še vedno prosti.',
};

String _holdLapsedAllTakenSl(int count) => switch (pickerPluralCategory(
  'sl',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in ta sedež je že zaseden.',
  PickerPluralCategory.two =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in ta sedeža sta že zasedena.',
  PickerPluralCategory.few =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in ti sedeži so že zasedeni.',
  _ =>
    'Vaša rezervacija je potekla, medtem ko vas ni bilo, in ti sedeži so že zasedeni.',
};

String _continueWithTotalSl(String money) => 'Nadaljuj \u00b7 $money';

/// The `sl` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSl = SeatLayerPickerStrings(
  close: 'Zapri',
  overview: 'Prizorišče',
  backToVenue: 'Nazaj na prizorišče',
  cancel: 'Prekliči',
  select: 'Izberi',
  removeSeat: 'Odstrani sedež',
  viewFromHere: 'Pogled od tu',
  openVenue360: 'Odpri prizorišče v 360°',
  recentre: 'Znova centriraj na oder',
  viewFromYourSeat: 'pogled z vašega sedeža',
  emptyTrayHint:
      'Tapnite sedež na načrtu ali pustite, da izberemo najboljše proste za vas.',
  anyTicketType: 'Katera koli vrsta vstopnice',
  anyVenueZone: 'Katero koli območje',
  bestSeats: 'Najboljši sedeži',
  showLess: 'Prikaži manj',
  undo: 'Razveljavi',
  holdAndCheckout: 'Rezerviraj sedeže in plačaj',
  poweredBy: 'Poganja SeatLayer',
  testMode: 'TESTNI NAČIN',
  accessibility: 'Dostopnost in barve',
  accessibilityTitle: 'Dostopnost in barve',
  fitVenue: 'Prikaži celotno prizorišče',
  fitWholeVenue: 'Prikaži celotno prizorišče',
  loading: 'Nalagamo načrt sedežev…',
  errorMessage: 'Načrt sedežev se ni naložil',
  retry: 'Poskusi znova',
  accessRefresh: 'Osveži',
  noSeatsSelected: 'Ni izbranih sedežev',
  findBestSeatsCta: 'Poišči najboljše sedeže',
  organizerNote: 'Opomba organizatorja',
  accessiblePhysicalSeat: 'Dostopen fizični sedež',
  emptyWheelchairSpace: 'Prosto mesto za invalidski voziček',
  findSeatsTogether: 'Poišči sedeže skupaj',
  aboutBestSeats: 'O iskanju sedežev skupaj',
  closestGroupChosenInstantly: 'Najbližja prosta skupina, izbrana takoj.',
  hideLimitedView: 'Skrij sedeže z omejenim pogledom',
  colorblindSafe: 'Barve, prijazne barvni slepoti',
  notAvailable: 'Ni na voljo',
  restrictedView: 'Omejen pogled',
  obstructedView: 'Zakrit pogled',
  premiumSeat: 'Premium sedež',
  continueWord: 'Nadaljuj',
  allFloors: 'Vsa nadstropja',
  previousSection: 'Prejšnji sektor',
  nextSection: 'Naslednji sektor',
  addSeat: 'Dodaj sedež',
  added: 'Dodano',
  sectionWord: 'Sektor',
  rowWord: 'Vrsta',
  seatWord: 'Sedež',
  seeItIn3D: 'Poglej v 3D',
  viewFromThisSeat: 'Pogled s tega sedeža',
  allPrices: 'Vse cene',
  ticketType: 'Vrsta vstopnice',
  tierCompanionGuidance: 'Zahteva sosednje mesto za invalidski voziček',
  findingBestSeats: 'Iščemo najboljše sedeže…',
  findSeats: 'Poišči sedeže',
  expandCart: 'Odpri ploščo z vstopnicami',
  collapseCart: 'Strni ploščo z vstopnicami',
  continueToCheckout: 'Nadaljuj na plačilo',
  secureMore: 'Zagotovi več',
  selectSeats: 'Izberi sedeže',
  pickYourSeats: 'Izberite svoje sedeže',
  salesClosedPill: 'Prodaja je zaprta',
  salesClosedCta: 'Prodaja je zaprta',
  confirmOrCancelSeat: 'Potrdite ali prekličite ta sedež',
  securingSeats: 'Zagotavljamo vaše sedeže…',
  openingCheckout: 'Odpiramo varno plačilo…',
  testModeExplained:
      'Rezervacije tukaj niso resnične in nobena kartica ni obremenjena',
  displayOptions: 'Možnosti prikaza',
  companionSeatsNote: 'Sosednja spremljevalna mesta ostanejo izbirna',
  zoomIn: 'Približaj',
  zoomOut: 'Oddalji',
  rotateVenue: 'Povlecite za vrtenje prizorišča',
  moveVenue: 'Povlecite za premik prizorišča',
  mapView: 'Načrt',
  flat2dMap: 'Ploski 2D-načrt',
  interactive3dVenueView: 'Interaktivni 3D-pogled prizorišča',
  venueView: 'Pogled prizorišča',
  holdLapsedTitle: 'Vaši sedeži so bili sproščeni',
  salesClosed: 'Prodaja je zaprta',
  salesClosedCopy: 'Prodaja vstopnic za ta dogodek se je končala.',
  salesClosedToast: 'Prodaja za ta dogodek je zaprta.',
  soldOutEyebrow: 'Ta dogodek',
  soldOutTitle: 'Razprodano',
  soldOutCopy: 'Za ta dogodek trenutno ni prostih oštevilčenih sedežev.',
  holdExpired:
      'Vaša rezervacija je potekla. Sedeži so bili sproščeni. Izberite znova.',
  addingEllipsis: 'Dodajamo…',
  moreTimeAdded: 'Čas je podaljšan. Vaši sedeži so še vedno rezervirani.',
  couldNotAddMoreTime:
      'Časa ni bilo mogoče podaljšati. Pojdite na plačilo zdaj.',
  seatsJustTaken:
      'Eden ali več sedežev je bilo pravkar zasedenih. Izberite znova.',
  allSetTitle: 'Vse je pripravljeno',
  confirmedAndOnWay: 'potrjeno. Potrdilo je že na poti.',
  backToMap: 'Nazaj na načrt',
  mapDidNotLoad: 'Načrt sedežev se ni naložil',
  checkConnection: 'Preverite povezavo in poskusite znova.',
  accessPausedTitle: 'Ti sedeži so trenutno zadržani',
  accessPausedCopy:
      'Organizator je to izbiro začasno ustavil. Poskusite znova čez nekaj minut.',
  accessRevokedTitle: 'Ta povezava za dostop ni več aktivna',
  accessRevokedCopy:
      'Prosite za novo povezavo tistega, ki vam jo je poslal, da lahko še naprej rezervirate te sedeže.',
  accessUnverifiedTitle: 'Vašega dostopa nismo mogli preveriti',
  accessUnverifiedCopy:
      'Še vedno lahko kupite vse, kar je prikazano kot prosto. Za dostop do ostalega se obrnite na tistega, ki vam je poslal povezavo.',
  generalAdmission: 'Prost vstop',
  numberOfGuests: 'Število gostov',
  chooseGuestsCopy:
      'Izberite, koliko gostov bo sedelo skupaj. Ta miza je rezervirana izključno za vašo družbo.',
  fewerGuests: 'Manj gostov',
  moreGuests: 'Več gostov',
  selectTable: 'Izberi mizo',
  updateTable: 'Posodobi mizo',
  removeWord: 'Odstrani',
  floorWord: 'Nadstropje',
  totalWord: 'Skupaj',
  accessNeeds: <String, String>{
    'wheelchair': 'Mesto za voziček',
    'companion': 'Spremljevalni sedež',
    'semi-ambulatory': 'Omejena gibljivost',
    'designated-aisle': 'Prehod / presedanje',
    'step-free': 'Brez stopnic',
    'hearing': 'Podpora sluhu',
    'cart': 'Podnapisi v živo',
    'sign-language': 'Znakovni jezik',
    'low-vision': 'Slabovidnost',
    'sensory-friendly': 'Čutno prijazno',
    'plus-size': 'Širši sedež',
    'lift-armrest': 'Dvižni naslon za roke',
  },
  seatsLeft: _seatsLeftSl,
  moreCount: _moreCountSl,
  addMinutes: _addMinutesSl,
  fromPrice: _fromPriceSl,
  sightline: _sightlineSl,
  secureMoreAndCheckout: _secureMoreAndCheckoutSl,
  accessFreeCount: _accessFreeCountSl,
  seatJustTakenByAnother: _seatJustTakenByAnotherSl,
  peekSecured: _peekSecuredSl,
  ticketCount: _ticketCountSl,
  findBestSeats: _findBestSeatsSl,
  reselectSeats: _reselectSeatsSl,
  seatsFree: _seatsFreeSl,
  seatsLeftInSection: _seatsLeftInSectionSl,
  holdLapsedStillFree: _holdLapsedStillFreeSl,
  holdLapsedSomeTaken: _holdLapsedSomeTakenSl,
  holdLapsedAllTaken: _holdLapsedAllTakenSl,
  continueWithTotal: _continueWithTotalSl,
);
