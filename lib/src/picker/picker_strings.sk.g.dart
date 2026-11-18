// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sk)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftSk(int count) => 'Zostáva $count';

String _moreCountSk(int count) => '+$count ďalších';

String _addMinutesSk(int minutes) => '+$minutes min';

String _fromPriceSk(String money) => 'Od $money';

String _sightlineSk(String metres) => '≈ $metres m k pódiu';

String _secureMoreAndCheckoutSk(int count) => 'Zaistiť ešte $count a zaplatiť';

String _accessFreeCountSk(int count) => 'Voľných: $count';

String _seatJustTakenByAnotherSk(String label) =>
    'Miesto $label práve obsadil iný kupujúci.';

String _peekSecuredSk(int count, String total) =>
    '✓ $count zaistených · $total. Zatiaľ vám nič nestrhneme';

String _ticketCountSk(int count) => switch (pickerPluralCategory('sk', count)) {
  PickerPluralCategory.one => '$count vstupenka',
  PickerPluralCategory.few => '$count vstupenky',
  PickerPluralCategory.many => '$count vstupenky',
  _ => '$count vstupeniek',
};

String _findBestSeatsSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Nájsť $count najlepšie miesto',
      PickerPluralCategory.few => 'Nájsť $count najlepšie miesta',
      PickerPluralCategory.many => 'Nájsť $count najlepšieho miesta',
      _ => 'Nájsť $count najlepších miest',
    };

String _reselectSeatsSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Vybrať ho znova',
      PickerPluralCategory.few => 'Vybrať ich znova',
      PickerPluralCategory.many => 'Vybrať ich znova',
      _ => 'Vybrať ich znova',
    };

String _seatsFreeSk(int count) => switch (pickerPluralCategory('sk', count)) {
  PickerPluralCategory.one => '$count miesto',
  PickerPluralCategory.few => '$count miesta',
  PickerPluralCategory.many => '$count miesta',
  _ => '$count miest',
};

String _seatsLeftInSectionSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Zostáva $count miesto',
      PickerPluralCategory.few => 'Zostávajú $count miesta',
      PickerPluralCategory.many => 'Zostáva $count miesta',
      _ => 'Zostáva $count miest',
    };

String _holdLapsedStillFreeSk(int count) => switch (pickerPluralCategory(
  'sk',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša rezervácia vypršala, kým ste boli preč. Toto miesto je stále voľné.',
  PickerPluralCategory.few =>
    'Vaša rezervácia vypršala, kým ste boli preč. Tieto miesta sú stále voľné.',
  PickerPluralCategory.many =>
    'Vaša rezervácia vypršala, kým ste boli preč. Tieto miesta sú stále voľné.',
  _ =>
    'Vaša rezervácia vypršala, kým ste boli preč. Tieto miesta sú stále voľné.',
};

String _holdLapsedSomeTakenSk(int count) => switch (pickerPluralCategory(
  'sk',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša rezervácia vypršala, kým ste boli preč, a $count z týchto miest je už obsadené. Zvyšok je stále voľný.',
  PickerPluralCategory.few =>
    'Vaša rezervácia vypršala, kým ste boli preč, a $count z týchto miest sú už obsadené. Zvyšok je stále voľný.',
  PickerPluralCategory.many =>
    'Vaša rezervácia vypršala, kým ste boli preč, a $count z týchto miest je už obsadených. Zvyšok je stále voľný.',
  _ =>
    'Vaša rezervácia vypršala, kým ste boli preč, a $count z týchto miest je už obsadených. Zvyšok je stále voľný.',
};

String _holdLapsedAllTakenSk(int count) => switch (pickerPluralCategory(
  'sk',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša rezervácia vypršala, kým ste boli preč, a toto miesto je už obsadené.',
  PickerPluralCategory.few =>
    'Vaša rezervácia vypršala, kým ste boli preč, a tieto miesta sú už obsadené.',
  PickerPluralCategory.many =>
    'Vaša rezervácia vypršala, kým ste boli preč, a tieto miesta sú už obsadené.',
  _ =>
    'Vaša rezervácia vypršala, kým ste boli preč, a tieto miesta sú už obsadené.',
};

String _continueWithTotalSk(String money) => 'Pokračovať \u00b7 $money';

/// The `sk` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSk = SeatLayerPickerStrings(
  close: 'Zavrieť',
  overview: 'Miesto konania',
  backToVenue: 'Späť do areálu',
  cancel: 'Zrušiť',
  select: 'Vybrať',
  removeSeat: 'Odobrať miesto',
  viewFromHere: 'Výhľad odtiaľto',
  openVenue360: 'Otvoriť areál v 360°',
  recentre: 'Znova vycentrovať na pódium',
  viewFromYourSeat: 'pohľad z vášho miesta',
  emptyTrayHint:
      'Ťuknite na miesto v pláne, alebo nechajte nás vybrať najlepšie dostupné za vás.',
  anyTicketType: 'Akýkoľvek typ vstupenky',
  anyVenueZone: 'Akákoľvek zóna areálu',
  bestSeats: 'Najlepšie miesta',
  showLess: 'Zobraziť menej',
  undo: 'Späť',
  holdAndCheckout: 'Rezervovať miesta a zaplatiť',
  poweredBy: 'Beží na SeatLayer',
  testMode: 'TESTOVACÍ REŽIM',
  accessibility: 'Prístupnosť a farby',
  accessibilityTitle: 'Prístupnosť a farby',
  fitVenue: 'Zobraziť celé miesto konania',
  fitWholeVenue: 'Zobraziť celé miesto konania',
  loading: 'Načítava sa plán miest…',
  errorMessage: 'Plán miest sa nenačítal',
  retry: 'Skúsiť znova',
  accessRefresh: 'Obnoviť',
  noSeatsSelected: 'Nevybrané žiadne miesta',
  findBestSeatsCta: 'Nájsť najlepšie miesta',
  organizerNote: 'Poznámka organizátora',
  accessiblePhysicalSeat: 'Bezbariérové fyzické miesto',
  emptyWheelchairSpace: 'Voľné miesto pre vozík',
  findSeatsTogether: 'Nájsť miesta vedľa seba',
  aboutBestSeats: 'O hľadaní miest vedľa seba',
  closestGroupChosenInstantly: 'Najbližšia dostupná skupina, vybraná okamžite.',
  hideLimitedView: 'Skryť miesta s obmedzeným výhľadom',
  colorblindSafe: 'Farby vhodné pre farboslepých',
  notAvailable: 'Nedostupné',
  restrictedView: 'Obmedzený výhľad',
  obstructedView: 'Zakrytý výhľad',
  premiumSeat: 'Prémiové miesto',
  continueWord: 'Pokračovať',
  allFloors: 'Všetky poschodia',
  previousSection: 'Predchádzajúci sektor',
  nextSection: 'Ďalší sektor',
  addSeat: 'Pridať miesto',
  added: 'Pridané',
  sectionWord: 'Sektor',
  rowWord: 'Rad',
  seatWord: 'Miesto',
  seeItIn3D: 'Zobraziť v 3D',
  viewFromThisSeat: 'Výhľad z tohto miesta',
  allPrices: 'Všetky ceny',
  ticketType: 'Typ vstupenky',
  tierCompanionGuidance: 'Vyžaduje susedné miesto pre vozík',
  findingBestSeats: 'Hľadáme najlepšie miesta…',
  findSeats: 'Nájsť miesta',
  expandCart: 'Otvoriť panel vstupeniek',
  collapseCart: 'Zbaliť panel vstupeniek',
  continueToCheckout: 'Pokračovať k platbe',
  secureMore: 'Zaistiť viac',
  selectSeats: 'Vybrať miesta',
  pickYourSeats: 'Vyberte si miesta',
  salesClosedPill: 'Predaj ukončený',
  salesClosedCta: 'Predaj ukončený',
  confirmOrCancelSeat: 'Potvrdiť alebo zrušiť toto miesto',
  securingSeats: 'Zaisťujeme vaše miesta…',
  openingCheckout: 'Otvárame zabezpečenú platbu…',
  testModeExplained: 'Rezervácie tu nie sú skutočné a karta sa neúčtuje',
  displayOptions: 'Možnosti zobrazenia',
  companionSeatsNote: 'Susedné miesta pre sprievod zostávajú voliteľné',
  zoomIn: 'Priblížiť',
  zoomOut: 'Oddialiť',
  rotateVenue: 'Ťahaním otočte miesto konania',
  moveVenue: 'Ťahaním posuňte miesto konania',
  mapView: 'Plán',
  flat2dMap: 'Plochý 2D plán',
  interactive3dVenueView: 'Interaktívny 3D pohľad na areál',
  venueView: 'Pohľad na areál',
  holdLapsedTitle: 'Vaše miesta boli uvoľnené',
  salesClosed: 'Predaj ukončený',
  salesClosedCopy: 'Predaj vstupeniek na toto podujatie sa skončil.',
  salesClosedToast: 'Predaj na toto podujatie je ukončený.',
  soldOutEyebrow: 'Toto podujatie',
  soldOutTitle: 'Vypredané',
  soldOutCopy:
      'Na toto podujatie momentálne nie sú dostupné žiadne číslované miesta.',
  holdExpired: 'Vaša rezervácia vypršala. Miesta boli uvoľnené. Vyberte znova.',
  addingEllipsis: 'Pridáva sa…',
  moreTimeAdded: 'Čas predĺžený. Vaše miesta sú stále rezervované.',
  couldNotAddMoreTime:
      'Nepodarilo sa pridať čas. Prejdite prosím k platbe hneď.',
  seatsJustTaken:
      'Jedno alebo viac miest bolo práve obsadených. Vyberte prosím znova.',
  allSetTitle: 'Všetko je pripravené',
  confirmedAndOnWay: 'potvrdené. Potvrdenie je na ceste.',
  backToMap: 'Späť na plán',
  mapDidNotLoad: 'Plán miest sa nenačítal',
  checkConnection: 'Skontrolujte pripojenie a skúste to znova.',
  accessPausedTitle: 'Tieto miesta sú práve blokované',
  accessPausedCopy:
      'Organizátor tento výber pozastavil. Skúste to o pár minút znova.',
  accessRevokedTitle: 'Tento prístupový odkaz už nie je aktívny',
  accessRevokedCopy:
      'Požiadajte toho, kto vám poslal odkaz, o nový, aby ste mohli tieto miesta ďalej rezervovať.',
  accessUnverifiedTitle: 'Nepodarilo sa nám overiť váš prístup',
  accessUnverifiedCopy:
      'Stále si môžete kúpiť všetko, čo je zobrazené ako dostupné. O prístup k zvyšku požiadajte toho, kto vám poslal odkaz.',
  generalAdmission: 'Voľný vstup',
  numberOfGuests: 'Počet hostí',
  chooseGuestsCopy:
      'Vyberte, koľko hostí bude sedieť spolu. Tento stôl je rezervovaný výhradne pre vašu spoločnosť.',
  fewerGuests: 'Menej hostí',
  moreGuests: 'Viac hostí',
  selectTable: 'Vybrať stôl',
  updateTable: 'Aktualizovať stôl',
  removeWord: 'Odobrať',
  floorWord: 'Poschodie',
  totalWord: 'Spolu',
  accessNeeds: <String, String>{
    'wheelchair': 'Miesto pre vozík',
    'companion': 'Miesto pre sprievod',
    'semi-ambulatory': 'Obmedzená pohyblivosť',
    'designated-aisle': 'Ulička / presun',
    'step-free': 'Bez schodov',
    'hearing': 'Podpora počutia',
    'cart': 'Živé titulky',
    'sign-language': 'Posunkový jazyk',
    'low-vision': 'Slabozrakosť',
    'sensory-friendly': 'Zmyslovo šetrné',
    'plus-size': 'Rozšírené miesto',
    'lift-armrest': 'Sklopná lakťová opierka',
  },
  seatsLeft: _seatsLeftSk,
  moreCount: _moreCountSk,
  addMinutes: _addMinutesSk,
  fromPrice: _fromPriceSk,
  sightline: _sightlineSk,
  secureMoreAndCheckout: _secureMoreAndCheckoutSk,
  accessFreeCount: _accessFreeCountSk,
  seatJustTakenByAnother: _seatJustTakenByAnotherSk,
  peekSecured: _peekSecuredSk,
  ticketCount: _ticketCountSk,
  findBestSeats: _findBestSeatsSk,
  reselectSeats: _reselectSeatsSk,
  seatsFree: _seatsFreeSk,
  seatsLeftInSection: _seatsLeftInSectionSk,
  holdLapsedStillFree: _holdLapsedStillFreeSk,
  holdLapsedSomeTaken: _holdLapsedSomeTakenSk,
  holdLapsedAllTaken: _holdLapsedAllTakenSk,
  continueWithTotal: _continueWithTotalSk,
);
