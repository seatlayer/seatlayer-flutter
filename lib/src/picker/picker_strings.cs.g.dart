// GENERATED — do not edit.
//
// Source: design/locale_strings.json (cs)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftCs(int count) => 'Zbývá $count';

String _moreCountCs(int count) => '+$count dalších';

String _addMinutesCs(int minutes) => '+$minutes min';

String _fromPriceCs(String money) => 'Od $money';

String _sightlineCs(String metres) => '≈ $metres m k pódiu';

String _secureMoreAndCheckoutCs(int count) =>
    'Zajistit ještě $count a zaplatit';

String _accessFreeCountCs(int count) => 'Volných: $count';

String _seatJustTakenByAnotherCs(String label) =>
    'Místo $label právě obsadil jiný kupující.';

String _labelNoLongerAvailableCs(String label) =>
    '$label už není dostupné. Vyberte jiné místo.';

String _labelsNoLongerAvailableCs(String labels) =>
    '$labels už nejsou dostupná. Vyberte jinou skupinu.';

String _couldNotFindSeatsTogetherCs(int count) =>
    'Nenašli jsme $count míst vedle sebe. Zkuste méně míst nebo jiný typ vstupenky.';

String _maxTicketsForOrderCs(int count) =>
    'Do této objednávky můžete vybrat nejvýše $count vstupenek.';

String _couldNotRemoveLabelCs(String label) =>
    'Nepodařilo se odebrat $label. Rezervace zůstává beze změny.';

String _peekSecuredCs(int count, String total) =>
    '✓ $count zajištěno · $total. Zatím vám nic nestrhneme';

String _venueMapCs(String venue) => '$venue: plán sedadel';

String _accessibleStepCs(int index, int total) => '$index z $total';

String _chooseMinMaxGuestsCs(int min, int max) =>
    'Vyberte od $min do $max hostů.';

String _chooseMoreCs(int count) => 'Vyberte ještě $count';

String _seatsHeldForNeedMoreTimeCs(String time) =>
    'Vaše místa jsou rezervována ještě $time. Potřebujete více času?';

String _accessNeedWithCountCs(String need, int count) => '$need · $count';

String _ticketCountCs(int count) => switch (pickerPluralCategory('cs', count)) {
  PickerPluralCategory.one => '$count vstupenka',
  PickerPluralCategory.few => '$count vstupenky',
  PickerPluralCategory.many => '$count vstupenky',
  _ => '$count vstupenek',
};

String _findBestSeatsCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Najít $count nejlepší místo',
      PickerPluralCategory.few => 'Najít $count nejlepší místa',
      PickerPluralCategory.many => 'Najít $count nejlepšího místa',
      _ => 'Najít $count nejlepších míst',
    };

String _reselectSeatsCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Vybrat ho znovu',
      PickerPluralCategory.few => 'Vybrat je znovu',
      PickerPluralCategory.many => 'Vybrat je znovu',
      _ => 'Vybrat je znovu',
    };

String _seatsFreeCs(int count) => switch (pickerPluralCategory('cs', count)) {
  PickerPluralCategory.one => '$count místo',
  PickerPluralCategory.few => '$count místa',
  PickerPluralCategory.many => '$count místa',
  _ => '$count míst',
};

String _seatsLeftInSectionCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Zbývá $count místo',
      PickerPluralCategory.few => 'Zbývají $count místa',
      PickerPluralCategory.many => 'Zbývá $count místa',
      _ => 'Zbývá $count míst',
    };

String _holdLapsedStillFreeCs(int count) => switch (pickerPluralCategory(
  'cs',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaše rezervace vypršela, zatímco jste byli pryč. Toto místo je stále volné.',
  PickerPluralCategory.few =>
    'Vaše rezervace vypršela, zatímco jste byli pryč. Tato místa jsou stále volná.',
  PickerPluralCategory.many =>
    'Vaše rezervace vypršela, zatímco jste byli pryč. Tato místa jsou stále volná.',
  _ =>
    'Vaše rezervace vypršela, zatímco jste byli pryč. Tato místa jsou stále volná.',
};

String _holdLapsedSomeTakenCs(int count) => switch (pickerPluralCategory(
  'cs',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a $count z těchto míst je již obsazené. Zbytek je stále volný.',
  PickerPluralCategory.few =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a $count z těchto míst jsou již obsazená. Zbytek je stále volný.',
  PickerPluralCategory.many =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a $count z těchto míst je již obsazeno. Zbytek je stále volný.',
  _ =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a $count z těchto míst je již obsazeno. Zbytek je stále volný.',
};

String _holdLapsedAllTakenCs(int count) => switch (pickerPluralCategory(
  'cs',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a toto místo je již obsazené.',
  PickerPluralCategory.few =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a tato místa jsou již obsazená.',
  PickerPluralCategory.many =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a tato místa jsou již obsazená.',
  _ =>
    'Vaše rezervace vypršela, zatímco jste byli pryč, a tato místa jsou již obsazená.',
};

String _accessibleSectionsCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => '$count sektor',
      PickerPluralCategory.few => '$count sektory',
      PickerPluralCategory.many => '$count sektoru',
      _ => '$count sektorů',
    };

String _placesAvailableCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Aktuálně je k dispozici $count místo',
      PickerPluralCategory.few => 'Aktuálně jsou k dispozici $count místa',
      PickerPluralCategory.many => 'Aktuálně je k dispozici $count místa',
      _ => 'Aktuálně je k dispozici $count míst',
    };

String _removeTicketsCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Odebrat $count vstupenku',
      PickerPluralCategory.few => 'Odebrat $count vstupenky',
      PickerPluralCategory.many => 'Odebrat $count vstupenky',
      _ => 'Odebrat $count vstupenek',
    };

String _holdMinutesLeftCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Zbývá $count minuta',
      PickerPluralCategory.few => 'Zbývají $count minuty',
      PickerPluralCategory.many => 'Zbývá $count minuty',
      _ => 'Zbývá $count minut',
    };

String _holdSecondsLeftCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Zbývá $count sekunda',
      PickerPluralCategory.few => 'Zbývají $count sekundy',
      PickerPluralCategory.many => 'Zbývá $count sekundy',
      _ => 'Zbývá $count sekund',
    };

String _holdLapsedBodyCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => 'Byla rezervována $count minutu.',
      PickerPluralCategory.few => 'Byla rezervována $count minuty.',
      PickerPluralCategory.many => 'Byla rezervována $count minuty.',
      _ => 'Byla rezervována $count minut.',
    };

String _seatsNotRecoveredCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => '$count místo se nepodařilo obnovit',
      PickerPluralCategory.few => '$count místa se nepodařilo obnovit',
      PickerPluralCategory.many => '$count místa se nepodařilo obnovit',
      _ => '$count míst se nepodařilo obnovit',
    };

String _activeFiltersCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => '$count filtr',
      PickerPluralCategory.few => '$count filtry',
      PickerPluralCategory.many => '$count filtru',
      _ => '$count filtrů',
    };

String _accessibilityFiltersActiveCs(int count) =>
    switch (pickerPluralCategory('cs', count)) {
      PickerPluralCategory.one => '$count aktivní filtr přístupnosti',
      PickerPluralCategory.few => '$count aktivní filtry přístupnosti',
      PickerPluralCategory.many => '$count aktivního filtru přístupnosti',
      _ => '$count aktivních filtrů přístupnosti',
    };

String _onlyLeftCs(int count) => switch (pickerPluralCategory('cs', count)) {
  PickerPluralCategory.one => 'Zbývá $count místo',
  PickerPluralCategory.few => 'Zbývají $count místa',
  PickerPluralCategory.many => 'Zbývá $count místa',
  _ => 'Zbývá $count míst',
};

String _maintenancePausedCs(int count) => switch (pickerPluralCategory(
  'cs',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervace je pozastavena kvůli údržbě. Zkuste to znovu asi za $count minutu.',
  PickerPluralCategory.few =>
    'Rezervace je pozastavena kvůli údržbě. Zkuste to znovu asi za $count minuty.',
  PickerPluralCategory.many =>
    'Rezervace je pozastavena kvůli údržbě. Zkuste to znovu asi za $count minuty.',
  _ =>
    'Rezervace je pozastavena kvůli údržbě. Zkuste to znovu asi za $count minut.',
};

String _continueWithTotalCs(String money) => 'Pokračovat \u00b7 $money';

/// The `cs` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsCs = SeatLayerPickerStrings(
  close: 'Zavřít',
  overview: 'Místo konání',
  backToVenue: 'Zpět do areálu',
  cancel: 'Zrušit',
  select: 'Vybrat',
  removeSeat: 'Odebrat místo',
  viewFromHere: 'Výhled odsud',
  openVenue360: 'Otevřít areál ve 360°',
  recentre: 'Vycentrovat zpět na pódium',
  viewFromYourSeat: 'pohled z vašeho místa',
  emptyTrayHint:
      'Klepněte na místo v plánu, nebo nechte nás vybrat nejlepší dostupná za vás.',
  anyTicketType: 'Jakýkoli typ vstupenky',
  anyVenueZone: 'Jakákoli zóna areálu',
  bestSeats: 'Nejlepší místa',
  showLess: 'Zobrazit méně',
  undo: 'Zpět',
  holdAndCheckout: 'Rezervovat místa a zaplatit',
  poweredBy: 'Běží na SeatLayer',
  testMode: 'Testovací režim',
  accessibility: 'Přístupnost a barvy',
  accessibilityTitle: 'Přístupnost a barvy',
  fitVenue: 'Zobrazit celé místo konání',
  fitWholeVenue: 'Zobrazit celé místo konání',
  loading: 'Načítání plánu míst…',
  errorMessage: 'Plán míst se nenačetl',
  retry: 'Zkusit znovu',
  accessRefresh: 'Obnovit',
  noSeatsSelected: 'Nevybrána žádná místa',
  findBestSeatsCta: 'Najít nejlepší místa',
  organizerNote: 'Poznámka pořadatele',
  accessiblePhysicalSeat: 'Bezbariérové fyzické místo',
  emptyWheelchairSpace: 'Volné místo pro vozík',
  findSeatsTogether: 'Najít místa vedle sebe',
  aboutBestSeats: 'O hledání míst vedle sebe',
  closestGroupChosenInstantly: 'Nejbližší dostupná skupina, vybraná okamžitě.',
  hideLimitedView: 'Skrýt místa s omezeným výhledem',
  colorblindSafe: 'Barvy vhodné pro barvoslepé',
  notAvailable: 'Není k dispozici',
  viewGroupTitle: 'ZOBRAZENÍ',
  restrictedView: 'Omezený výhled',
  obstructedView: 'Zakrytý výhled',
  premiumSeat: 'Prémiové místo',
  continueWord: 'Pokračovat',
  allFloors: 'Všechna patra',
  previousSection: 'Předchozí sektor',
  nextSection: 'Další sektor',
  addSeat: 'Přidat místo',
  added: 'Přidáno',
  sectionWord: 'Sektor',
  rowWord: 'Řada',
  seatWord: 'Místo',
  seeItIn3D: 'Zobrazit ve 3D',
  viewFromThisSeat: 'Výhled z tohoto místa',
  allPrices: 'Všechny ceny',
  ticketPrices: 'Ceny vstupenek',
  yourSeats: 'Vaše místa',
  ticketType: 'Typ vstupenky',
  tierCompanionGuidance: 'Vyžaduje sousední místo pro vozík',
  findingBestSeats: 'Hledáme nejlepší místa…',
  findSeats: 'Najít místa',
  expandCart: 'Otevřít panel vstupenek',
  collapseCart: 'Sbalit panel vstupenek',
  continueToCheckout: 'Pokračovat k platbě',
  secureMore: 'Zajistit více',
  selectSeats: 'Vybrat místa',
  pickYourSeats: 'Vyberte si místa',
  salesClosedPill: 'Prodej ukončen',
  salesClosedCta: 'Prodej ukončen',
  confirmOrCancelSeat: 'Potvrdit nebo zrušit toto místo',
  securingSeats: 'Zajišťujeme vaše místa…',
  openingCheckout: 'Otevíráme zabezpečenou platbu…',
  testModeExplained: 'Rezervace zde nejsou skutečné a karta se neúčtuje',
  displayOptions: 'Možnosti zobrazení',
  companionSeatsNote: 'Sousední místa pro doprovod zůstávají volitelná',
  zoomIn: 'Přiblížit',
  zoomOut: 'Oddálit',
  rotateVenue: 'Tažením otočíte místo konání',
  moveVenue: 'Tažením posunete místo konání',
  mapView: 'Plán',
  flat2dMap: 'Plochý 2D plán',
  interactive3dVenueView: 'Interaktivní 3D pohled na areál',
  venueView: 'Pohled na areál',
  holdLapsedTitle: 'Vaše místa byla uvolněna',
  salesClosed: 'Prodej ukončen',
  salesClosedCopy: 'Prodej vstupenek na tuto akci skončil.',
  salesClosedToast: 'Prodej na tuto akci je ukončen.',
  soldOutEyebrow: 'Tato akce',
  soldOutTitle: 'Vyprodáno',
  soldOutCopy: 'Na tuto akci nejsou momentálně dostupná žádná číslovaná místa.',
  holdExpired: 'Vaše rezervace vypršela. Místa byla uvolněna. Vyberte znovu.',
  addingEllipsis: 'Přidávání…',
  moreTimeAdded: 'Čas prodloužen. Vaše místa jsou stále rezervovaná.',
  couldNotAddMoreTime:
      'Nepodařilo se přidat čas. Přejděte prosím k platbě hned.',
  seatsJustTaken:
      'Jedno nebo více míst bylo právě obsazeno. Vyberte prosím znovu.',
  ticketTypeSoldOut: 'Tento typ vstupenky je vyprodaný. Zkuste jiný typ.',
  seatsNoLongerAvailableTryAnother:
      'Tato místa už nejsou dostupná. Zkuste jiný počet nebo typ vstupenky.',
  companionPairRequired:
      'Ke každé vstupence pro doprovod vyberte sousední místo pro vozík.',
  ticketOptionNotApplicable:
      'Tento typ vstupenky není pro vybrané místo dostupný.',
  maintenancePausedShortly:
      'Rezervace je na několik minut pozastavena kvůli údržbě. Zkuste to znovu za chvíli.',
  guestsOnly: 'Tato akce je pro pozvané hosty.',
  guestChoiceClosed: 'Výběr míst teď není otevřený.',
  maxOneTicketForOrder: 'Do této objednávky můžete vybrat nejvýše 1 vstupenku.',
  tooManyAttempts: 'Příliš mnoho pokusů. Chvíli počkejte a zkuste to znovu.',
  seatHeldForRenewal:
      'Jedno z těchto míst je vyhrazeno pro držitele permanentky, který si ji ještě může prodloužit. Vyberte jiné místo.',
  seatUnavailable: 'Toto místo není k dispozici.',
  eventUnavailable: 'Vstupenky tu teď nelze rezervovat.',
  savedSeatsNotRestored:
      'Vaše předchozí místa se nepodařilo obnovit. Vyberte je prosím znovu.',
  allSetTitle: 'Vše je připraveno',
  confirmedAndOnWay: 'potvrzeno. Potvrzení je na cestě.',
  backToMap: 'Zpět na plán',
  mapDidNotLoad: 'Plán míst se nenačetl',
  checkConnection: 'Zkontrolujte připojení a zkuste to znovu.',
  offline: 'Jste offline',
  backOnline: 'Opět online',
  stillHeld: 'Vaše místa jsou stále rezervovaná.',
  updating: 'Aktualizace…',
  takingLonger: 'Trvá to déle než obvykle. Chvíli strpení…',
  loadingTakingLonger:
      'Načítání plánu míst trvá déle než obvykle. Chvíli strpení…',
  couldNotReachCheckout: 'Nepodařilo se připojit k pokladně.',
  accessPausedTitle: 'Tato místa jsou právě blokovaná',
  accessPausedCopy:
      'Pořadatel tento výběr pozastavil. Zkuste to za pár minut znovu.',
  accessRevokedTitle: 'Tento přístupový odkaz už není aktivní',
  accessRevokedCopy:
      'Požádejte toho, kdo vám poslal odkaz, o nový, ať můžete tato místa dál rezervovat.',
  accessUnverifiedTitle: 'Nepodařilo se nám ověřit váš přístup',
  accessUnverifiedCopy:
      'Stále si můžete koupit vše, co je zobrazeno jako dostupné. O přístup ke zbytku požádejte toho, kdo vám poslal odkaz.',
  generalAdmission: 'Volný vstup',
  numberOfGuests: 'Počet hostů',
  chooseGuestsCopy:
      'Vyberte, kolik hostů bude sedět spolu. Tento stůl je rezervován výhradně pro vaši společnost.',
  fewerGuests: 'Méně hostů',
  moreGuests: 'Více hostů',
  selectTable: 'Vybrat stůl',
  updateTable: 'Aktualizovat stůl',
  removeWord: 'Odebrat',
  floorWord: 'Patro',
  totalWord: 'Celkem',
  adjustSelection: 'Upravit výběr míst',
  backToSeatMap: 'Zpět na plán míst',
  chooseSeats: 'Vyberte si místa',
  chooseTickets: 'Vyberte vstupenky',
  placeWord: 'MÍSTO',
  guestsWord: 'Hosté',
  tableWord: 'Stůl',
  ticketWord: 'Vstupenka',
  passport: 'Profil místa',
  venue3D: '3D',
  venueZone: 'Zóna areálu',
  venueMapHint:
      'Místa se vybírají pomocí ovládacích prvků kolem plánu: cenového pruhu nad ním, ovládání sektorů pod ním a panelu vstupenek dole.',
  previousSeat: 'Předchozí místo',
  nextSeat: 'Další místo',
  orbitMode: 'Otočit areál',
  panMode: 'Posunout areál',
  openInteractive3dVenue: 'Otevřít interaktivní 3D pohled na areál',
  showSeatsFor: 'ZOBRAZIT MÍSTA:',
  accessJumpFirstSection: 'Přejít na první sektor',
  accessJumpNextSection: 'Přejít na další sektor',
  fewerTickets: 'Méně vstupenek',
  moreTickets: 'Více vstupenek',
  addTickets: 'Přidat vstupenky',
  noSelectableSeats: 'Momentálně nejsou k dispozici žádná místa k výběru.',
  confirmYourTickets: 'Potvrďte své vstupenky',
  seatsSecuredOpeningCheckout: 'Místa zajištěna. Otevíráme pokladnu…',
  holdInCheckoutTitle: 'Vaše místa už jsou v pokladně',
  holdInCheckoutBody:
      'Dokončete nákup, abyste o ně nepřišli. Pokud chcete vybrat jiná místa, nejprve tato uvolněte — vrátí se do prodeje.',
  releaseAndChangeSeats: 'Uvolnit a změnit místa',
  holdAlreadyHeldTitle: 'Vaše místa už jsou rezervována',
  holdAlreadyHeldBody: 'Pokračujte k platbě, abyste o ně nepřišli.',
  accessExpiredTitle: 'Vaše relace výběru míst vypršela',
  accessExpiredCopy:
      'Pro pokračování znovu načtěte plán sedadel. Místa, která už máte v košíku, zůstávají rezervována, dokud neskončí odpočet.',
  dismissError: 'Zavřít chybovou zprávu',
  testModeLong: 'Testovací režim · nic se nerezervuje',
  seatRemoved: 'Vstupenka odebrána',
  reloadSeatMap: 'Znovu načíst plán sedadel',
  accessNeeds: <String, String>{
    'wheelchair': 'Místo pro vozík',
    'companion': 'Místo pro doprovod',
    'semi-ambulatory': 'Omezená pohyblivost',
    'designated-aisle': 'Ulička / přesun',
    'step-free': 'Bez schodů',
    'hearing': 'Podpora poslechu',
    'cart': 'Živé titulky',
    'sign-language': 'Znakový jazyk',
    'low-vision': 'Slabozrakost',
    'sensory-friendly': 'Šetrné ke smyslům',
    'plus-size': 'Rozšířené místo',
    'lift-armrest': 'Sklopná područka',
  },
  seatsLeft: _seatsLeftCs,
  moreCount: _moreCountCs,
  addMinutes: _addMinutesCs,
  fromPrice: _fromPriceCs,
  sightline: _sightlineCs,
  secureMoreAndCheckout: _secureMoreAndCheckoutCs,
  accessFreeCount: _accessFreeCountCs,
  seatJustTakenByAnother: _seatJustTakenByAnotherCs,
  labelNoLongerAvailable: _labelNoLongerAvailableCs,
  labelsNoLongerAvailable: _labelsNoLongerAvailableCs,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherCs,
  maxTicketsForOrder: _maxTicketsForOrderCs,
  couldNotRemoveLabel: _couldNotRemoveLabelCs,
  peekSecured: _peekSecuredCs,
  venueMap: _venueMapCs,
  accessibleStep: _accessibleStepCs,
  chooseMinMaxGuests: _chooseMinMaxGuestsCs,
  chooseMore: _chooseMoreCs,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeCs,
  accessNeedWithCount: _accessNeedWithCountCs,
  ticketCount: _ticketCountCs,
  findBestSeats: _findBestSeatsCs,
  reselectSeats: _reselectSeatsCs,
  seatsFree: _seatsFreeCs,
  seatsLeftInSection: _seatsLeftInSectionCs,
  holdLapsedStillFree: _holdLapsedStillFreeCs,
  holdLapsedSomeTaken: _holdLapsedSomeTakenCs,
  holdLapsedAllTaken: _holdLapsedAllTakenCs,
  accessibleSections: _accessibleSectionsCs,
  placesAvailable: _placesAvailableCs,
  removeTickets: _removeTicketsCs,
  holdMinutesLeft: _holdMinutesLeftCs,
  holdSecondsLeft: _holdSecondsLeftCs,
  holdLapsedBody: _holdLapsedBodyCs,
  seatsNotRecovered: _seatsNotRecoveredCs,
  activeFilters: _activeFiltersCs,
  accessibilityFiltersActive: _accessibilityFiltersActiveCs,
  onlyLeft: _onlyLeftCs,
  maintenancePaused: _maintenancePausedCs,
  continueWithTotal: _continueWithTotalCs,
);
