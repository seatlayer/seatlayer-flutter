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

String _peekSecuredCs(int count, String total) =>
    '✓ $count zajištěno · $total. Zatím vám nic nestrhneme';

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
  testMode: 'TESTOVACÍ REŽIM',
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
  allSetTitle: 'Vše je připraveno',
  confirmedAndOnWay: 'potvrzeno. Potvrzení je na cestě.',
  backToMap: 'Zpět na plán',
  mapDidNotLoad: 'Plán míst se nenačetl',
  checkConnection: 'Zkontrolujte připojení a zkuste to znovu.',
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
  peekSecured: _peekSecuredCs,
  ticketCount: _ticketCountCs,
  findBestSeats: _findBestSeatsCs,
  reselectSeats: _reselectSeatsCs,
  seatsFree: _seatsFreeCs,
  seatsLeftInSection: _seatsLeftInSectionCs,
  holdLapsedStillFree: _holdLapsedStillFreeCs,
  holdLapsedSomeTaken: _holdLapsedSomeTakenCs,
  holdLapsedAllTaken: _holdLapsedAllTakenCs,
  continueWithTotal: _continueWithTotalCs,
);
