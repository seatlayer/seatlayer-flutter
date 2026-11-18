// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sv)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftSv(int count) => '$count kvar';

String _moreCountSv(int count) => '+$count fler';

String _addMinutesSv(int minutes) => '+$minutes min';

String _fromPriceSv(String money) => 'Från $money';

String _sightlineSv(String metres) => '≈ $metres m till scenen';

String _secureMoreAndCheckoutSv(int count) => 'Säkra $count till och betala';

String _accessFreeCountSv(int count) => '$count lediga';

String _seatJustTakenByAnotherSv(String label) =>
    'Plats $label togs precis av en annan köpare.';

String _peekSecuredSv(int count, String total) =>
    '✓ $count säkrade · $total. Du debiteras inte än';

String _ticketCountSv(int count) =>
    count == 1 ? '$count biljett' : '$count biljetter';

String _findBestSeatsSv(int count) =>
    count == 1 ? 'Hitta $count bästa plats' : 'Hitta $count bästa platser';

String _reselectSeatsSv(int count) =>
    count == 1 ? 'Välj den igen' : 'Välj dem igen';

String _seatsFreeSv(int count) =>
    count == 1 ? '$count plats' : '$count platser';

String _seatsLeftInSectionSv(int count) =>
    count == 1 ? '$count plats kvar' : '$count platser kvar';

String _holdLapsedStillFreeSv(int count) => count == 1
    ? 'Din reservation gick ut medan du var borta. Platsen är fortfarande ledig.'
    : 'Din reservation gick ut medan du var borta. Platserna är fortfarande lediga.';

String _holdLapsedSomeTakenSv(int count) => count == 1
    ? 'Din reservation gick ut medan du var borta och $count av platserna har tagits. Resten är fortfarande lediga.'
    : 'Din reservation gick ut medan du var borta och $count av platserna har tagits. Resten är fortfarande lediga.';

String _holdLapsedAllTakenSv(int count) => count == 1
    ? 'Din reservation gick ut medan du var borta och platsen har tagits.'
    : 'Din reservation gick ut medan du var borta och platserna har tagits.';

String _continueWithTotalSv(String money) => 'Fortsätt \u00b7 $money';

/// The `sv` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsSv = SeatLayerPickerStrings(
  close: 'Stäng',
  overview: 'Spelplats',
  backToVenue: 'Tillbaka till arenan',
  cancel: 'Avbryt',
  select: 'Välj',
  removeSeat: 'Ta bort plats',
  viewFromHere: 'Utsikt härifrån',
  openVenue360: 'Öppna arenan i 360°',
  recentre: 'Centrera på scenen igen',
  viewFromYourSeat: 'vy från din plats',
  emptyTrayHint:
      'Tryck på en plats på kartan, eller låt oss välja de bästa lediga åt dig.',
  anyTicketType: 'Vilken biljettyp som helst',
  anyVenueZone: 'Vilken zon som helst',
  bestSeats: 'Bästa platserna',
  showLess: 'Visa färre',
  undo: 'Ångra',
  holdAndCheckout: 'Reservera platser och betala',
  poweredBy: 'Drivs av SeatLayer',
  testMode: 'TESTLÄGE',
  accessibility: 'Tillgänglighet och färger',
  accessibilityTitle: 'Tillgänglighet och färger',
  fitVenue: 'Visa hela lokalen',
  fitWholeVenue: 'Visa hela lokalen',
  loading: 'Läser in platskartan…',
  errorMessage: 'Platskartan laddades inte',
  retry: 'Försök igen',
  accessRefresh: 'Ladda om',
  noSeatsSelected: 'Inga platser valda',
  findBestSeatsCta: 'Hitta bästa platserna',
  organizerNote: 'Meddelande från arrangören',
  accessiblePhysicalSeat: 'Tillgänglig fysisk plats',
  emptyWheelchairSpace: 'Ledig rullstolsplats',
  findSeatsTogether: 'Hitta platser bredvid varandra',
  aboutBestSeats: 'Om att hitta platser tillsammans',
  closestGroupChosenInstantly: 'Närmaste lediga grupp, vald direkt.',
  hideLimitedView: 'Dölj platser med begränsad sikt',
  colorblindSafe: 'Färgblindvänliga färger',
  notAvailable: 'Inte tillgänglig',
  restrictedView: 'Begränsad sikt',
  obstructedView: 'Skymd sikt',
  premiumSeat: 'Premiumplats',
  continueWord: 'Fortsätt',
  allFloors: 'Alla våningar',
  previousSection: 'Föregående sektion',
  nextSection: 'Nästa sektion',
  addSeat: 'Lägg till plats',
  added: 'Tillagd',
  sectionWord: 'Sektion',
  rowWord: 'Rad',
  seatWord: 'Plats',
  seeItIn3D: 'Se den i 3D',
  viewFromThisSeat: 'Utsikt från den här platsen',
  allPrices: 'Alla priser',
  ticketType: 'Biljettyp',
  tierCompanionGuidance: 'Kräver den intilliggande rullstolsplatsen',
  findingBestSeats: 'Söker de bästa platserna…',
  findSeats: 'Hitta platser',
  expandCart: 'Öppna biljettpanelen',
  collapseCart: 'Fäll ihop biljettpanelen',
  continueToCheckout: 'Fortsätt till kassan',
  secureMore: 'Säkra fler',
  selectSeats: 'Välj platser',
  pickYourSeats: 'Välj dina platser',
  salesClosedPill: 'Försäljningen stängd',
  salesClosedCta: 'Försäljningen stängd',
  confirmOrCancelSeat: 'Bekräfta eller avbryt den här platsen',
  securingSeats: 'Säkrar dina platser…',
  openingCheckout: 'Öppnar säker kassa…',
  testModeExplained: 'Bokningar här är inte riktiga och inget kort debiteras',
  displayOptions: 'Visningsalternativ',
  companionSeatsNote: 'Ledsagarplatserna bredvid går fortfarande att välja',
  zoomIn: 'Zooma in',
  zoomOut: 'Zooma ut',
  rotateVenue: 'Dra för att rotera lokalen',
  moveVenue: 'Dra för att flytta lokalen',
  mapView: 'Karta',
  flat2dMap: 'Platt 2D-karta',
  interactive3dVenueView: 'Interaktiv 3D-vy av arenan',
  venueView: 'Arenavy',
  holdLapsedTitle: 'Dina platser släpptes',
  salesClosed: 'Försäljningen stängd',
  salesClosedCopy:
      'Biljettförsäljningen för det här evenemanget har avslutats.',
  salesClosedToast: 'Försäljningen för det här evenemanget är stängd.',
  soldOutEyebrow: 'Det här evenemanget',
  soldOutTitle: 'Slutsålt',
  soldOutCopy:
      'Det finns inga numrerade platser tillgängliga för det här evenemanget just nu.',
  holdExpired: 'Din reservation har gått ut. Platserna släpptes. Välj igen.',
  addingEllipsis: 'Lägger till…',
  moreTimeAdded: 'Mer tid tillagd. Dina platser är fortfarande reserverade.',
  couldNotAddMoreTime: 'Kunde inte lägga till mer tid. Gå till kassan nu.',
  seatsJustTaken: 'En eller flera platser togs precis. Välj igen.',
  allSetTitle: 'Allt är klart',
  confirmedAndOnWay: 'bekräftat. En bekräftelse är på väg.',
  backToMap: 'Tillbaka till kartan',
  mapDidNotLoad: 'Platskartan laddades inte',
  checkConnection: 'Kontrollera din anslutning och försök igen.',
  accessPausedTitle: 'De här platserna är spärrade just nu',
  accessPausedCopy:
      'Arrangören har pausat det här urvalet. Försök igen om några minuter.',
  accessRevokedTitle: 'Den här åtkomstlänken är inte längre aktiv',
  accessRevokedCopy:
      'Be den som skickade dig hit om en ny länk för att fortsätta boka de här platserna.',
  accessUnverifiedTitle: 'Vi kunde inte verifiera din åtkomst',
  accessUnverifiedCopy:
      'Du kan fortfarande boka allt som visas som tillgängligt. Kontakta den som skickade dig hit för åtkomst till resten.',
  generalAdmission: 'Fri placering',
  numberOfGuests: 'Antal gäster',
  chooseGuestsCopy:
      'Välj hur många gäster som ska sitta tillsammans. Bordet reserveras exklusivt för ditt sällskap.',
  fewerGuests: 'Färre gäster',
  moreGuests: 'Fler gäster',
  selectTable: 'Välj bord',
  updateTable: 'Uppdatera bordet',
  removeWord: 'Ta bort',
  floorWord: 'Våning',
  totalWord: 'Totalt',
  accessNeeds: <String, String>{
    'wheelchair': 'Rullstolsplats',
    'companion': 'Ledsagarplats',
    'semi-ambulatory': 'Nedsatt rörlighet',
    'designated-aisle': 'Gång / överflyttning',
    'step-free': 'Trappfri',
    'hearing': 'Hörslinga',
    'cart': 'Livetextning',
    'sign-language': 'Teckenspråk',
    'low-vision': 'Synsvag',
    'sensory-friendly': 'Sinnesvänlig',
    'plus-size': 'Extra bred',
    'lift-armrest': 'Uppfällbart armstöd',
  },
  seatsLeft: _seatsLeftSv,
  moreCount: _moreCountSv,
  addMinutes: _addMinutesSv,
  fromPrice: _fromPriceSv,
  sightline: _sightlineSv,
  secureMoreAndCheckout: _secureMoreAndCheckoutSv,
  accessFreeCount: _accessFreeCountSv,
  seatJustTakenByAnother: _seatJustTakenByAnotherSv,
  peekSecured: _peekSecuredSv,
  ticketCount: _ticketCountSv,
  findBestSeats: _findBestSeatsSv,
  reselectSeats: _reselectSeatsSv,
  seatsFree: _seatsFreeSv,
  seatsLeftInSection: _seatsLeftInSectionSv,
  holdLapsedStillFree: _holdLapsedStillFreeSv,
  holdLapsedSomeTaken: _holdLapsedSomeTakenSv,
  holdLapsedAllTaken: _holdLapsedAllTakenSv,
  continueWithTotal: _continueWithTotalSv,
);
