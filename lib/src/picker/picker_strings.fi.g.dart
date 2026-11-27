// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fi)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftFi(int count) => '$count jäljellä';

String _moreCountFi(int count) => '+$count lisää';

String _addMinutesFi(int minutes) => '+$minutes min';

String _fromPriceFi(String money) => 'Alkaen $money';

String _sightlineFi(String metres) => '≈ $metres m lavalle';

String _secureMoreAndCheckoutFi(int count) =>
    'Varmista vielä $count ja siirry kassalle';

String _accessFreeCountFi(int count) => '$count vapaana';

String _seatJustTakenByAnotherFi(String label) =>
    'Toinen ostaja otti juuri paikan $label.';

String _labelNoLongerAvailableFi(String label) =>
    '$label ei ole enää saatavilla. Valitse toinen paikka.';

String _labelsNoLongerAvailableFi(String labels) =>
    '$labels eivät ole enää saatavilla. Valitse toinen ryhmä.';

String _couldNotFindSeatsTogetherFi(int count) =>
    'Emme löytäneet $count paikkaa vierekkäin. Kokeile vähempää paikkaa tai toista lipputyyppiä.';

String _maxTicketsForOrderFi(int count) =>
    'Voit valita tähän tilaukseen enintään $count lippua.';

String _couldNotRemoveLabelFi(String label) =>
    'Kohdetta $label ei voitu poistaa. Varauksesi on ennallaan.';

String _peekSecuredFi(int count, String total) =>
    '✓ $count varmistettu · $total. Emme veloita vielä';

String _venueMapFi(String venue) => '$venue – paikkakartta';

String _accessibleStepFi(int index, int total) => '$index/$total';

String _chooseMinMaxGuestsFi(int min, int max) => 'Valitse $min–$max vierasta.';

String _chooseMoreFi(int count) => 'Valitse vielä $count';

String _seatsHeldForNeedMoreTimeFi(String time) =>
    'Paikkasi ovat varattuina vielä $time. Tarvitsetko lisäaikaa?';

String _accessNeedWithCountFi(String need, int count) => '$need · $count';

String _ticketCountFi(int count) => switch (pickerPluralCategory('fi', count)) {
  PickerPluralCategory.one => '$count lippu',
  _ => '$count lippua',
};

String _findBestSeatsFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => 'Etsi $count paras paikka',
      _ => 'Etsi $count parasta paikkaa',
    };

String _reselectSeatsFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => 'Valitse se uudelleen',
      _ => 'Valitse ne uudelleen',
    };

String _seatsFreeFi(int count) => switch (pickerPluralCategory('fi', count)) {
  PickerPluralCategory.one => '$count paikka',
  _ => '$count paikkaa',
};

String _seatsLeftInSectionFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count paikka jäljellä',
      _ => '$count paikkaa jäljellä',
    };

String _holdLapsedStillFreeFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one =>
        'Varauksesi vanheni poissa ollessasi. Tämä paikka on yhä vapaana.',
      _ => 'Varauksesi vanheni poissa ollessasi. Nämä paikat ovat yhä vapaana.',
    };

String _holdLapsedSomeTakenFi(int count) => switch (pickerPluralCategory(
  'fi',
  count,
)) {
  PickerPluralCategory.one =>
    'Varauksesi vanheni poissa ollessasi, ja $count näistä paikoista on jo varattu. Loput ovat yhä vapaana.',
  _ =>
    'Varauksesi vanheni poissa ollessasi, ja $count näistä paikoista on jo varattu. Loput ovat yhä vapaana.',
};

String _holdLapsedAllTakenFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one =>
        'Varauksesi vanheni poissa ollessasi, ja tämä paikka on jo varattu.',
      _ => 'Varauksesi vanheni poissa ollessasi, ja nämä paikat on jo varattu.',
    };

String _accessibleSectionsFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count lohko',
      _ => '$count lohkoa',
    };

String _placesAvailableFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count paikka vapaana nyt',
      _ => '$count paikkaa vapaana nyt',
    };

String _removeTicketsFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => 'Poista $count lippu',
      _ => 'Poista $count lippua',
    };

String _holdMinutesLeftFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count minuutti jäljellä',
      _ => '$count minuuttia jäljellä',
    };

String _holdSecondsLeftFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count sekunti jäljellä',
      _ => '$count sekuntia jäljellä',
    };

String _holdLapsedBodyFi(int count) => switch (pickerPluralCategory(
  'fi',
  count,
)) {
  PickerPluralCategory.one => 'Paikat olivat varattuina $count minuutin ajan.',
  _ => 'Paikat olivat varattuina $count minuutin ajan.',
};

String _seatsNotRecoveredFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count paikkaa ei voitu varata uudelleen',
      _ => '$count paikkaa ei voitu varata uudelleen',
    };

String _activeFiltersFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count suodatin',
      _ => '$count suodatinta',
    };

String _accessibilityFiltersActiveFi(int count) =>
    switch (pickerPluralCategory('fi', count)) {
      PickerPluralCategory.one => '$count esteettömyyssuodatin käytössä',
      _ => '$count esteettömyyssuodatinta käytössä',
    };

String _onlyLeftFi(int count) => switch (pickerPluralCategory('fi', count)) {
  PickerPluralCategory.one => '$count paikka jäljellä',
  _ => '$count paikkaa jäljellä',
};

String _maintenancePausedFi(int count) => switch (pickerPluralCategory(
  'fi',
  count,
)) {
  PickerPluralCategory.one =>
    'Varaaminen on keskeytetty huollon ajaksi. Yritä uudelleen noin $count minuutin kuluttua.',
  _ =>
    'Varaaminen on keskeytetty huollon ajaksi. Yritä uudelleen noin $count minuutin kuluttua.',
};

String _continueWithTotalFi(String money) => 'Jatka \u00b7 $money';

/// The `fi` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsFi = SeatLayerPickerStrings(
  close: 'Sulje',
  overview: 'Paikka',
  backToVenue: 'Takaisin tapahtumapaikkaan',
  cancel: 'Peruuta',
  select: 'Valitse',
  removeSeat: 'Poista paikka',
  viewFromHere: 'Näkymä täältä',
  openVenue360: 'Avaa tapahtumapaikka 360°:na',
  recentre: 'Keskitä takaisin lavaan',
  viewFromYourSeat: 'näkymä paikaltasi',
  emptyTrayHint:
      'Napauta paikkaa kartalla tai anna meidän valita parhaat vapaat puolestasi.',
  anyTicketType: 'Mikä tahansa lipputyyppi',
  anyVenueZone: 'Mikä tahansa alue',
  bestSeats: 'Parhaat paikat',
  showLess: 'Näytä vähemmän',
  undo: 'Kumoa',
  holdAndCheckout: 'Varaa paikat ja siirry kassalle',
  poweredBy: 'Palvelun tarjoaa SeatLayer',
  testMode: 'Testitila',
  accessibility: 'Esteettömyys- ja väriasetukset',
  accessibilityTitle: 'Esteettömyys- ja väriasetukset',
  fitVenue: 'Näytä koko tapahtumapaikka',
  fitWholeVenue: 'Näytä koko tapahtumapaikka',
  loading: 'Ladataan paikkakarttaa…',
  errorMessage: 'Paikkakartta ei latautunut',
  retry: 'Yritä uudelleen',
  accessRefresh: 'Lataa uudelleen',
  noSeatsSelected: 'Ei valittuja paikkoja',
  findBestSeatsCta: 'Etsi parhaat paikat',
  organizerNote: 'Järjestäjän huomautus',
  accessiblePhysicalSeat: 'Esteetön fyysinen paikka',
  emptyWheelchairSpace: 'Vapaa pyörätuolipaikka',
  findSeatsTogether: 'Etsi paikat vierekkäin',
  aboutBestSeats: 'Tietoa vierekkäisten paikkojen löytämisestä',
  closestGroupChosenInstantly: 'Lähin vapaa ryhmä, valittu heti.',
  hideLimitedView: 'Piilota paikat, joissa on rajoitettu näkyvyys',
  colorblindSafe: 'Värisokeusystävälliset värit',
  notAvailable: 'Ei saatavilla',
  viewGroupTitle: 'NÄKYMÄ',
  restrictedView: 'Rajoitettu näkyvyys',
  obstructedView: 'Estynyt näkyvyys',
  premiumSeat: 'Premium-paikka',
  continueWord: 'Jatka',
  allFloors: 'Kaikki kerrokset',
  previousSection: 'Edellinen lohko',
  nextSection: 'Seuraava lohko',
  addSeat: 'Lisää paikka',
  added: 'Lisätty',
  sectionWord: 'Lohko',
  rowWord: 'Rivi',
  seatWord: 'Paikka',
  seeItIn3D: 'Katso 3D:nä',
  viewFromThisSeat: 'Näkymä tältä paikalta',
  allPrices: 'Kaikki hinnat',
  ticketPrices: 'Lippujen hinnat',
  yourSeats: 'Paikkasi',
  ticketType: 'Lipputyyppi',
  tierCompanionGuidance: 'Vaatii viereisen pyörätuolipaikan',
  findingBestSeats: 'Etsitään parhaita paikkoja…',
  findSeats: 'Etsi paikkoja',
  expandCart: 'Avaa lippupaneeli',
  collapseCart: 'Kutista lippupaneeli',
  continueToCheckout: 'Jatka kassalle',
  secureMore: 'Varmista lisää',
  selectSeats: 'Valitse paikat',
  pickYourSeats: 'Valitse paikkasi',
  salesClosedPill: 'Myynti suljettu',
  salesClosedCta: 'Myynti suljettu',
  confirmOrCancelSeat: 'Vahvista tai peruuta tämä paikka',
  securingSeats: 'Varmistetaan paikkojasi…',
  openingCheckout: 'Avataan suojattua kassaa…',
  testModeExplained:
      'Varaukset täällä eivät ole oikeita, eikä korttia veloiteta',
  displayOptions: 'Näyttöasetukset',
  companionSeatsNote: 'Viereiset avustajapaikat pysyvät valittavina',
  zoomIn: 'Lähennä',
  zoomOut: 'Loitonna',
  rotateVenue: 'Vedä kääntääksesi tapahtumapaikkaa',
  moveVenue: 'Vedä siirtääksesi tapahtumapaikkaa',
  mapView: 'Kartta',
  flat2dMap: 'Litteä 2D-kartta',
  interactive3dVenueView: 'Interaktiivinen 3D-näkymä tapahtumapaikasta',
  venueView: 'Tapahtumapaikan näkymä',
  holdLapsedTitle: 'Paikkasi vapautettiin',
  salesClosed: 'Myynti suljettu',
  salesClosedCopy: 'Tämän tapahtuman lipunmyynti on päättynyt.',
  salesClosedToast: 'Tämän tapahtuman myynti on suljettu.',
  soldOutEyebrow: 'Tämä tapahtuma',
  soldOutTitle: 'Loppuunmyyty',
  soldOutCopy:
      'Tähän tapahtumaan ei ole tällä hetkellä vapaita numeroituja paikkoja.',
  holdExpired: 'Varauksesi vanheni. Paikat vapautettiin. Valitse uudelleen.',
  addingEllipsis: 'Lisätään…',
  moreTimeAdded: 'Lisäaikaa annettu. Paikkasi ovat yhä varattuina.',
  couldNotAddMoreTime: 'Lisäaikaa ei voitu antaa. Siirry kassalle nyt.',
  seatsJustTaken: 'Yksi tai useampi paikka otettiin juuri. Valitse uudelleen.',
  ticketTypeSoldOut:
      'Tuo lipputyyppi on loppuunmyyty. Kokeile toista lipputyyppiä.',
  seatsNoLongerAvailableTryAnother:
      'Nuo paikat eivät ole enää saatavilla. Kokeile toista määrää tai lipputyyppiä.',
  companionPairRequired:
      'Valitse viereinen pyörätuolipaikka jokaisen avustajalipun kanssa.',
  ticketOptionNotApplicable:
      'Tämä lippuvalinta ei ole saatavilla valitulle paikalle.',
  maintenancePausedShortly:
      'Varaaminen on keskeytetty muutamaksi minuutiksi huollon vuoksi. Yritä pian uudelleen.',
  guestsOnly: 'Tämä tapahtuma on kutsutuille vieraille.',
  guestChoiceClosed: 'Paikkojen valinta ei ole nyt auki.',
  maxOneTicketForOrder: 'Voit valita tähän tilaukseen enintään 1 lipun.',
  tooManyAttempts: 'Liian monta yritystä. Odota hetki ja yritä uudelleen.',
  seatHeldForRenewal:
      'Yksi näistä paikoista on varattu kausilipun haltijalle, joka voi vielä uusia sen. Valitse toinen paikka.',
  seatUnavailable: 'Tämä paikka ei ole saatavilla.',
  eventUnavailable: 'Lippuja ei voi varata täällä juuri nyt.',
  savedSeatsNotRestored:
      'Aiempia paikkojasi ei voitu palauttaa. Valitse uudelleen.',
  allSetTitle: 'Kaikki valmista',
  confirmedAndOnWay: 'vahvistettu. Vahvistus on matkalla.',
  backToMap: 'Takaisin karttaan',
  mapDidNotLoad: 'Paikkakartta ei latautunut',
  checkConnection: 'Tarkista yhteytesi ja yritä uudelleen.',
  accessPausedTitle: 'Nämä paikat on juuri nyt varattu',
  accessPausedCopy:
      'Järjestäjä on keskeyttänyt tämän valinnan. Yritä uudelleen muutaman minuutin kuluttua.',
  accessRevokedTitle: 'Tämä käyttöoikeuslinkki ei ole enää voimassa',
  accessRevokedCopy:
      'Pyydä uusi linkki siltä, joka lähetti sinut tänne, jotta voit jatkaa näiden paikkojen varaamista.',
  accessUnverifiedTitle: 'Emme voineet vahvistaa käyttöoikeuttasi',
  accessUnverifiedCopy:
      'Voit yhä varata kaiken, mikä näkyy vapaana. Pyydä loput käyttöoikeudet siltä, joka lähetti sinut tänne.',
  generalAdmission: 'Vapaa sisäänpääsy',
  numberOfGuests: 'Vieraiden määrä',
  chooseGuestsCopy:
      'Valitse, montako vierasta istuu yhdessä. Tämä pöytä varataan yksinomaan seurueellesi.',
  fewerGuests: 'Vähemmän vieraita',
  moreGuests: 'Enemmän vieraita',
  selectTable: 'Valitse pöytä',
  updateTable: 'Päivitä pöytä',
  removeWord: 'Poista',
  floorWord: 'Kerros',
  totalWord: 'Yhteensä',
  adjustSelection: 'Säädä paikkavalintaa',
  backToSeatMap: 'Takaisin paikkakarttaan',
  chooseSeats: 'Valitse paikkasi',
  chooseTickets: 'Valitse liput',
  placeWord: 'PAIKKA',
  guestsWord: 'Vieraat',
  tableWord: 'Pöytä',
  ticketWord: 'Lippu',
  passport: 'Paikan profiili',
  venue3D: '3D',
  venueZone: 'Alue',
  venueMapHint:
      'Paikat valitaan kartan ympärillä olevilla säätimillä: hintapalkki kartan yläpuolella, lohkosäätimet sen alapuolella ja lippupaneeli alareunassa.',
  previousSeat: 'Edellinen paikka',
  nextSeat: 'Seuraava paikka',
  orbitMode: 'Käännä tapahtumapaikkaa',
  panMode: 'Siirrä tapahtumapaikkaa',
  openInteractive3dVenue: 'Avaa interaktiivinen 3D-näkymä tapahtumapaikasta',
  showSeatsFor: 'NÄYTÄ PAIKAT:',
  accessJumpFirstSection: 'Siirry ensimmäiseen lohkoon',
  accessJumpNextSection: 'Siirry seuraavaan lohkoon',
  fewerTickets: 'Vähemmän lippuja',
  moreTickets: 'Enemmän lippuja',
  addTickets: 'Lisää liput',
  noSelectableSeats: 'Valittavia paikkoja ei ole tällä hetkellä saatavilla.',
  confirmYourTickets: 'Vahvista lippusi',
  seatsSecuredOpeningCheckout: 'Paikat varmistettu. Avataan kassaa…',
  holdInCheckoutTitle: 'Paikkasi ovat jo kassalla',
  holdInCheckoutBody:
      'Viimeistele maksu, niin pidät ne. Jos haluat valita eri paikat, vapauta nämä ensin — ne palaavat myyntiin.',
  releaseAndChangeSeats: 'Vapauta ja vaihda paikat',
  holdAlreadyHeldTitle: 'Paikkasi on jo varattu',
  holdAlreadyHeldBody: 'Jatka kassalle, niin pidät ne.',
  accessExpiredTitle: 'Istuntosi vanheni',
  accessExpiredCopy:
      'Lataa paikkakartta uudelleen jatkaaksesi. Ostoskorissasi olevat paikat pysyvät varattuina, kunnes ajastin päättyy.',
  dismissError: 'Sulje virheilmoitus',
  testModeLong: 'Testitila · mitään ei varata',
  seatRemoved: 'Lippu poistettu',
  reloadSeatMap: 'Lataa paikkakartta uudelleen',
  accessNeeds: <String, String>{
    'wheelchair': 'Pyörätuolipaikka',
    'companion': 'Avustajapaikka',
    'semi-ambulatory': 'Rajoittunut liikuntakyky',
    'designated-aisle': 'Käytävä / siirtyminen',
    'step-free': 'Portaaton',
    'hearing': 'Induktiosilmukka',
    'cart': 'Livetekstitys',
    'sign-language': 'Viittomakieli',
    'low-vision': 'Heikkonäköinen',
    'sensory-friendly': 'Aistiystävällinen',
    'plus-size': 'Leveämpi paikka',
    'lift-armrest': 'Ylösnostettava käsinoja',
  },
  seatsLeft: _seatsLeftFi,
  moreCount: _moreCountFi,
  addMinutes: _addMinutesFi,
  fromPrice: _fromPriceFi,
  sightline: _sightlineFi,
  secureMoreAndCheckout: _secureMoreAndCheckoutFi,
  accessFreeCount: _accessFreeCountFi,
  seatJustTakenByAnother: _seatJustTakenByAnotherFi,
  labelNoLongerAvailable: _labelNoLongerAvailableFi,
  labelsNoLongerAvailable: _labelsNoLongerAvailableFi,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherFi,
  maxTicketsForOrder: _maxTicketsForOrderFi,
  couldNotRemoveLabel: _couldNotRemoveLabelFi,
  peekSecured: _peekSecuredFi,
  venueMap: _venueMapFi,
  accessibleStep: _accessibleStepFi,
  chooseMinMaxGuests: _chooseMinMaxGuestsFi,
  chooseMore: _chooseMoreFi,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeFi,
  accessNeedWithCount: _accessNeedWithCountFi,
  ticketCount: _ticketCountFi,
  findBestSeats: _findBestSeatsFi,
  reselectSeats: _reselectSeatsFi,
  seatsFree: _seatsFreeFi,
  seatsLeftInSection: _seatsLeftInSectionFi,
  holdLapsedStillFree: _holdLapsedStillFreeFi,
  holdLapsedSomeTaken: _holdLapsedSomeTakenFi,
  holdLapsedAllTaken: _holdLapsedAllTakenFi,
  accessibleSections: _accessibleSectionsFi,
  placesAvailable: _placesAvailableFi,
  removeTickets: _removeTicketsFi,
  holdMinutesLeft: _holdMinutesLeftFi,
  holdSecondsLeft: _holdSecondsLeftFi,
  holdLapsedBody: _holdLapsedBodyFi,
  seatsNotRecovered: _seatsNotRecoveredFi,
  activeFilters: _activeFiltersFi,
  accessibilityFiltersActive: _accessibilityFiltersActiveFi,
  onlyLeft: _onlyLeftFi,
  maintenancePaused: _maintenancePausedFi,
  continueWithTotal: _continueWithTotalFi,
);
