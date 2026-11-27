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

String _labelNoLongerAvailableSk(String label) =>
    '$label už nie je dostupné. Vyberte iné miesto.';

String _labelsNoLongerAvailableSk(String labels) =>
    '$labels už nie sú dostupné. Vyberte inú skupinu.';

String _couldNotFindSeatsTogetherSk(int count) =>
    'Nenašli sme $count miest vedľa seba. Skúste menej miest alebo iný typ vstupenky.';

String _maxTicketsForOrderSk(int count) =>
    'Do tejto objednávky môžete vybrať najviac $count vstupeniek.';

String _couldNotRemoveLabelSk(String label) =>
    'Nepodarilo sa odobrať $label. Rezervácia zostáva bez zmeny.';

String _peekSecuredSk(int count, String total) =>
    '✓ $count zaistených · $total. Zatiaľ vám nič nestrhneme';

String _venueMapSk(String venue) => '$venue: plán sedadiel';

String _accessibleStepSk(int index, int total) => '$index z $total';

String _chooseMinMaxGuestsSk(int min, int max) =>
    'Vyberte od $min do $max hostí.';

String _chooseMoreSk(int count) => 'Vyberte ešte $count';

String _seatsHeldForNeedMoreTimeSk(String time) =>
    'Vaše miesta držíme ešte $time. Potrebujete viac času?';

String _accessNeedWithCountSk(String need, int count) => '$need · $count';

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

String _accessibleSectionsSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => '$count sektor',
      PickerPluralCategory.few => '$count sektory',
      PickerPluralCategory.many => '$count sektora',
      _ => '$count sektorov',
    };

String _placesAvailableSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Momentálne je k dispozícii $count miesto',
      PickerPluralCategory.few => 'Momentálne sú k dispozícii $count miesta',
      PickerPluralCategory.many => 'Momentálne je k dispozícii $count miesta',
      _ => 'Momentálne je k dispozícii $count miest',
    };

String _removeTicketsSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Odobrať $count vstupenku',
      PickerPluralCategory.few => 'Odobrať $count vstupenky',
      PickerPluralCategory.many => 'Odobrať $count vstupenky',
      _ => 'Odobrať $count vstupeniek',
    };

String _holdMinutesLeftSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Zostáva $count minúta',
      PickerPluralCategory.few => 'Zostávajú $count minúty',
      PickerPluralCategory.many => 'Zostáva $count minúty',
      _ => 'Zostáva $count minút',
    };

String _holdSecondsLeftSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Zostáva $count sekunda',
      PickerPluralCategory.few => 'Zostávajú $count sekundy',
      PickerPluralCategory.many => 'Zostáva $count sekundy',
      _ => 'Zostáva $count sekúnd',
    };

String _holdLapsedBodySk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => 'Boli držané $count minútu.',
      PickerPluralCategory.few => 'Boli držané $count minúty.',
      PickerPluralCategory.many => 'Boli držané $count minúty.',
      _ => 'Boli držané $count minút.',
    };

String _seatsNotRecoveredSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => '$count miesto sa nepodarilo obnoviť',
      PickerPluralCategory.few => '$count miesta sa nepodarilo obnoviť',
      PickerPluralCategory.many => '$count miesta sa nepodarilo obnoviť',
      _ => '$count miest sa nepodarilo obnoviť',
    };

String _activeFiltersSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => '$count filter',
      PickerPluralCategory.few => '$count filtre',
      PickerPluralCategory.many => '$count filtra',
      _ => '$count filtrov',
    };

String _accessibilityFiltersActiveSk(int count) =>
    switch (pickerPluralCategory('sk', count)) {
      PickerPluralCategory.one => '$count aktívny filter prístupnosti',
      PickerPluralCategory.few => '$count aktívne filtre prístupnosti',
      PickerPluralCategory.many => '$count aktívneho filtra prístupnosti',
      _ => '$count aktívnych filtrov prístupnosti',
    };

String _onlyLeftSk(int count) => switch (pickerPluralCategory('sk', count)) {
  PickerPluralCategory.one => 'Zostáva $count miesto',
  PickerPluralCategory.few => 'Zostávajú $count miesta',
  PickerPluralCategory.many => 'Zostáva $count miesta',
  _ => 'Zostáva $count miest',
};

String _maintenancePausedSk(int count) => switch (pickerPluralCategory(
  'sk',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervácia je pozastavená z dôvodu údržby. Skúste to znova približne o $count minútu.',
  PickerPluralCategory.few =>
    'Rezervácia je pozastavená z dôvodu údržby. Skúste to znova približne o $count minúty.',
  PickerPluralCategory.many =>
    'Rezervácia je pozastavená z dôvodu údržby. Skúste to znova približne o $count minúty.',
  _ =>
    'Rezervácia je pozastavená z dôvodu údržby. Skúste to znova približne o $count minút.',
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
  testMode: 'Testovací režim',
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
  viewGroupTitle: 'ZOBRAZENIE',
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
  ticketPrices: 'Ceny vstupeniek',
  yourSeats: 'Vaše miesta',
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
  ticketTypeSoldOut: 'Tento typ vstupenky je vypredaný. Skúste iný typ.',
  seatsNoLongerAvailableTryAnother:
      'Tieto miesta už nie sú dostupné. Skúste iný počet alebo typ vstupenky.',
  companionPairRequired:
      'Ku každej vstupenke pre sprievod vyberte susedné miesto pre vozík.',
  ticketOptionNotApplicable:
      'Tento typ vstupenky nie je pre vybrané miesto dostupný.',
  maintenancePausedShortly:
      'Rezervácia je na niekoľko minút pozastavená z dôvodu údržby. Skúste to znova o chvíľu.',
  guestsOnly: 'Toto podujatie je pre pozvaných hostí.',
  guestChoiceClosed: 'Výber miest teraz nie je otvorený.',
  maxOneTicketForOrder:
      'Do tejto objednávky môžete vybrať najviac 1 vstupenku.',
  tooManyAttempts: 'Príliš veľa pokusov. Chvíľu počkajte a skúste to znova.',
  seatHeldForRenewal:
      'Jedno z týchto miest je vyhradené pre držiteľa permanentky, ktorý si ju ešte môže predĺžiť. Vyberte iné miesto.',
  seatUnavailable: 'Toto miesto nie je k dispozícii.',
  eventUnavailable: 'Vstupenky tu teraz nie je možné rezervovať.',
  savedSeatsNotRestored:
      'Vaše predchádzajúce miesta sa nepodarilo obnoviť. Vyberte ich, prosím, znova.',
  allSetTitle: 'Všetko je pripravené',
  confirmedAndOnWay: 'potvrdené. Potvrdenie je na ceste.',
  backToMap: 'Späť na plán',
  mapDidNotLoad: 'Plán miest sa nenačítal',
  checkConnection: 'Skontrolujte pripojenie a skúste to znova.',
  offline: 'Ste offline',
  backOnline: 'Opäť online',
  stillHeld: 'Vaše miesta sú stále rezervované.',
  updating: 'Aktualizuje sa…',
  takingLonger: 'Trvá to dlhšie než zvyčajne. Chvíľu strpenia…',
  loadingTakingLonger:
      'Načítanie plánu miest trvá dlhšie ako zvyčajne. Chvíľu strpenia…',
  couldNotReachCheckout: 'Nepodarilo sa pripojiť k pokladni.',
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
  adjustSelection: 'Upraviť výber miest',
  backToSeatMap: 'Späť na plán miest',
  chooseSeats: 'Vyberte si miesta',
  chooseTickets: 'Vyberte vstupenky',
  placeWord: 'MIESTO',
  guestsWord: 'Hostia',
  tableWord: 'Stôl',
  ticketWord: 'Vstupenka',
  passport: 'Profil miesta',
  venue3D: '3D',
  venueZone: 'Zóna areálu',
  venueMapHint:
      'Miesta sa vyberajú pomocou ovládacích prvkov okolo plánu: cenového pásu nad ním, ovládania sektorov pod ním a panela vstupeniek dole.',
  previousSeat: 'Predchádzajúce miesto',
  nextSeat: 'Ďalšie miesto',
  orbitMode: 'Otočiť areál',
  panMode: 'Posunúť areál',
  openInteractive3dVenue: 'Otvoriť interaktívny 3D pohľad na areál',
  showSeatsFor: 'ZOBRAZIŤ MIESTA:',
  accessJumpFirstSection: 'Prejsť na prvý sektor',
  accessJumpNextSection: 'Prejsť na ďalší sektor',
  fewerTickets: 'Menej vstupeniek',
  moreTickets: 'Viac vstupeniek',
  addTickets: 'Pridať vstupenky',
  noSelectableSeats: 'Momentálne nie sú k dispozícii žiadne miesta na výber.',
  confirmYourTickets: 'Potvrďte svoje vstupenky',
  seatsSecuredOpeningCheckout: 'Miesta zaistené. Otvárame pokladňu…',
  holdInCheckoutTitle: 'Vaše miesta sú už v pokladni',
  holdInCheckoutBody:
      'Dokončite nákup, aby ste o ne neprišli. Ak chcete vybrať iné miesta, najprv tieto uvoľnite — vrátia sa do predaja.',
  releaseAndChangeSeats: 'Uvoľniť a zmeniť miesta',
  holdAlreadyHeldTitle: 'Vaše miesta už držíme',
  holdAlreadyHeldBody: 'Pokračujte k platbe, aby ste o ne neprišli.',
  accessExpiredTitle: 'Vaša relácia výberu miest vypršala',
  accessExpiredCopy:
      'Ak chcete pokračovať, znova načítajte plán sedadiel. Miesta, ktoré už máte v košíku, zostávajú držané, kým neskončí odpočet.',
  dismissError: 'Zavrieť chybové hlásenie',
  testModeLong: 'Testovací režim · nič sa nerezervuje',
  seatRemoved: 'Vstupenka odobraná',
  reloadSeatMap: 'Znova načítať plán sedadiel',
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
  labelNoLongerAvailable: _labelNoLongerAvailableSk,
  labelsNoLongerAvailable: _labelsNoLongerAvailableSk,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherSk,
  maxTicketsForOrder: _maxTicketsForOrderSk,
  couldNotRemoveLabel: _couldNotRemoveLabelSk,
  peekSecured: _peekSecuredSk,
  venueMap: _venueMapSk,
  accessibleStep: _accessibleStepSk,
  chooseMinMaxGuests: _chooseMinMaxGuestsSk,
  chooseMore: _chooseMoreSk,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeSk,
  accessNeedWithCount: _accessNeedWithCountSk,
  ticketCount: _ticketCountSk,
  findBestSeats: _findBestSeatsSk,
  reselectSeats: _reselectSeatsSk,
  seatsFree: _seatsFreeSk,
  seatsLeftInSection: _seatsLeftInSectionSk,
  holdLapsedStillFree: _holdLapsedStillFreeSk,
  holdLapsedSomeTaken: _holdLapsedSomeTakenSk,
  holdLapsedAllTaken: _holdLapsedAllTakenSk,
  accessibleSections: _accessibleSectionsSk,
  placesAvailable: _placesAvailableSk,
  removeTickets: _removeTicketsSk,
  holdMinutesLeft: _holdMinutesLeftSk,
  holdSecondsLeft: _holdSecondsLeftSk,
  holdLapsedBody: _holdLapsedBodySk,
  seatsNotRecovered: _seatsNotRecoveredSk,
  activeFilters: _activeFiltersSk,
  accessibilityFiltersActive: _accessibilityFiltersActiveSk,
  onlyLeft: _onlyLeftSk,
  maintenancePaused: _maintenancePausedSk,
  continueWithTotal: _continueWithTotalSk,
);
