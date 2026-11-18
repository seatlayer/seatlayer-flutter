// GENERATED — do not edit.
//
// Source: design/locale_strings.json (fi)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

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

String _peekSecuredFi(int count, String total) =>
    '✓ $count varmistettu · $total. Emme veloita vielä';

String _ticketCountFi(int count) =>
    count == 1 ? '$count lippu' : '$count lippua';

String _findBestSeatsFi(int count) =>
    count == 1 ? 'Etsi $count paras paikka' : 'Etsi $count parasta paikkaa';

String _reselectSeatsFi(int count) =>
    count == 1 ? 'Valitse se uudelleen' : 'Valitse ne uudelleen';

String _seatsFreeFi(int count) =>
    count == 1 ? '$count paikka' : '$count paikkaa';

String _seatsLeftInSectionFi(int count) =>
    count == 1 ? '$count paikka jäljellä' : '$count paikkaa jäljellä';

String _holdLapsedStillFreeFi(int count) => count == 1
    ? 'Varauksesi vanheni poissa ollessasi. Tämä paikka on yhä vapaana.'
    : 'Varauksesi vanheni poissa ollessasi. Nämä paikat ovat yhä vapaana.';

String _holdLapsedSomeTakenFi(int count) => count == 1
    ? 'Varauksesi vanheni poissa ollessasi, ja $count näistä paikoista on jo varattu. Loput ovat yhä vapaana.'
    : 'Varauksesi vanheni poissa ollessasi, ja $count näistä paikoista on jo varattu. Loput ovat yhä vapaana.';

String _holdLapsedAllTakenFi(int count) => count == 1
    ? 'Varauksesi vanheni poissa ollessasi, ja tämä paikka on jo varattu.'
    : 'Varauksesi vanheni poissa ollessasi, ja nämä paikat on jo varattu.';

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
  testMode: 'TESTITILA',
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
  peekSecured: _peekSecuredFi,
  ticketCount: _ticketCountFi,
  findBestSeats: _findBestSeatsFi,
  reselectSeats: _reselectSeatsFi,
  seatsFree: _seatsFreeFi,
  seatsLeftInSection: _seatsLeftInSectionFi,
  holdLapsedStillFree: _holdLapsedStillFreeFi,
  holdLapsedSomeTaken: _holdLapsedSomeTakenFi,
  holdLapsedAllTaken: _holdLapsedAllTakenFi,
  continueWithTotal: _continueWithTotalFi,
);
