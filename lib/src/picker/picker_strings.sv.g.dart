// GENERATED — do not edit.
//
// Source: design/locale_strings.json (sv)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
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

String _labelNoLongerAvailableSv(String label) =>
    '$label är inte längre tillgänglig. Välj en annan plats.';

String _labelsNoLongerAvailableSv(String labels) =>
    '$labels är inte längre tillgängliga. Välj en annan grupp.';

String _couldNotFindSeatsTogetherSv(int count) =>
    'Vi hittade inte $count platser bredvid varandra. Prova färre platser eller en annan biljettyp.';

String _couldNotRemoveLabelSv(String label) =>
    'Kunde inte ta bort $label. Din reservation är oförändrad.';

String _peekSecuredSv(int count, String total) =>
    '✓ $count säkrade · $total. Du debiteras inte än';

String _venueMapSv(String venue) => 'Platskarta för $venue';

String _accessibleStepSv(int index, int total) => '$index av $total';

String _chooseMinMaxGuestsSv(int min, int max) =>
    'Välj mellan $min och $max gäster.';

String _chooseMoreSv(int count) => 'Välj $count till';

String _seatsHeldForNeedMoreTimeSv(String time) =>
    'Dina platser är reserverade i $time. Behöver du mer tid?';

String _accessNeedWithCountSv(String need, int count) => '$need · $count';

String _ticketCountSv(int count) => switch (pickerPluralCategory('sv', count)) {
  PickerPluralCategory.one => '$count biljett',
  _ => '$count biljetter',
};

String _findBestSeatsSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => 'Hitta $count bästa plats',
      _ => 'Hitta $count bästa platser',
    };

String _reselectSeatsSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => 'Välj den igen',
      _ => 'Välj dem igen',
    };

String _seatsFreeSv(int count) => switch (pickerPluralCategory('sv', count)) {
  PickerPluralCategory.one => '$count plats',
  _ => '$count platser',
};

String _seatsLeftInSectionSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count plats kvar',
      _ => '$count platser kvar',
    };

String _holdLapsedStillFreeSv(int count) => switch (pickerPluralCategory(
  'sv',
  count,
)) {
  PickerPluralCategory.one =>
    'Din reservation gick ut medan du var borta. Platsen är fortfarande ledig.',
  _ =>
    'Din reservation gick ut medan du var borta. Platserna är fortfarande lediga.',
};

String _holdLapsedSomeTakenSv(int count) => switch (pickerPluralCategory(
  'sv',
  count,
)) {
  PickerPluralCategory.one =>
    'Din reservation gick ut medan du var borta och $count av platserna har tagits. Resten är fortfarande lediga.',
  _ =>
    'Din reservation gick ut medan du var borta och $count av platserna har tagits. Resten är fortfarande lediga.',
};

String _holdLapsedAllTakenSv(int count) => switch (pickerPluralCategory(
  'sv',
  count,
)) {
  PickerPluralCategory.one =>
    'Din reservation gick ut medan du var borta och platsen har tagits.',
  _ => 'Din reservation gick ut medan du var borta och platserna har tagits.',
};

String _accessibleSectionsSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count sektion',
      _ => '$count sektioner',
    };

String _placesAvailableSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count plats ledig just nu',
      _ => '$count platser lediga just nu',
    };

String _removeTicketsSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => 'Ta bort $count biljett',
      _ => 'Ta bort $count biljetter',
    };

String _holdMinutesLeftSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count minut kvar',
      _ => '$count minuter kvar',
    };

String _holdSecondsLeftSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count sekund kvar',
      _ => '$count sekunder kvar',
    };

String _holdLapsedBodySv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => 'De var reserverade i $count minut.',
      _ => 'De var reserverade i $count minuter.',
    };

String _seatsNotRecoveredSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count plats kunde inte reserveras igen',
      _ => '$count platser kunde inte reserveras igen',
    };

String _activeFiltersSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count filter',
      _ => '$count filter',
    };

String _accessibilityFiltersActiveSv(int count) =>
    switch (pickerPluralCategory('sv', count)) {
      PickerPluralCategory.one => '$count tillgänglighetsfilter är aktivt',
      _ => '$count tillgänglighetsfilter är aktiva',
    };

String _onlyLeftSv(int count) => switch (pickerPluralCategory('sv', count)) {
  PickerPluralCategory.one => '$count plats kvar',
  _ => '$count platser kvar',
};

String _maintenancePausedSv(int count) => switch (pickerPluralCategory(
  'sv',
  count,
)) {
  PickerPluralCategory.one =>
    'Bokningen är pausad för underhåll. Försök igen om cirka $count minut.',
  _ =>
    'Bokningen är pausad för underhåll. Försök igen om cirka $count minuter.',
};

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
  testMode: 'Testläge',
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
  viewGroupTitle: 'VISNING',
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
  ticketPrices: 'Biljettpriser',
  yourSeats: 'Dina platser',
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
  ticketTypeSoldOut: 'Den biljettypen är slutsåld. Prova en annan biljettyp.',
  seatsNoLongerAvailableTryAnother:
      'De platserna är inte längre tillgängliga. Prova ett annat antal eller en annan biljettyp.',
  companionPairRequired:
      'Välj den intilliggande rullstolsplatsen till varje ledsagarbiljett.',
  ticketOptionNotApplicable:
      'Det biljettvalet är inte tillgängligt för den valda platsen.',
  maintenancePausedShortly:
      'Bokningen är pausad några minuter för underhåll. Försök igen om en liten stund.',
  guestsOnly: 'Det här evenemanget är för inbjudna gäster.',
  guestChoiceClosed: 'Platsvalet är inte öppet just nu.',
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
  adjustSelection: 'Justera platsvalet',
  backToSeatMap: 'Tillbaka till platskartan',
  chooseSeats: 'Välj dina platser',
  chooseTickets: 'Välj biljetter',
  placeWord: 'PLATS',
  ticketWord: 'Biljett',
  passport: 'Platsprofil',
  venue3D: '3D',
  venueZone: 'Zon i arenan',
  venueMapHint:
      'Platser väljs med kontrollerna runt kartan: prisraden ovanför, sektionskontrollerna nedanför och biljettpanelen längst ned.',
  previousSeat: 'Föregående plats',
  nextSeat: 'Nästa plats',
  orbitMode: 'Rotera arenan',
  panMode: 'Flytta arenan',
  openInteractive3dVenue: 'Öppna interaktiv 3D-vy av arenan',
  showSeatsFor: 'VISA PLATSER FÖR',
  accessJumpFirstSection: 'Gå till den första sektionen',
  accessJumpNextSection: 'Gå till nästa sektion',
  fewerTickets: 'Färre biljetter',
  moreTickets: 'Fler biljetter',
  addTickets: 'Lägg till biljetter',
  noSelectableSeats: 'Det finns inga valbara platser just nu.',
  confirmYourTickets: 'Bekräfta dina biljetter',
  seatsSecuredOpeningCheckout: 'Platserna är säkrade. Öppnar kassan…',
  holdInCheckoutTitle: 'Dina platser är redan i kassan',
  holdInCheckoutBody:
      'Slutför köpet i kassan för att behålla dem. Vill du välja andra platser släpper du först de här — de går tillbaka till försäljning.',
  releaseAndChangeSeats: 'Släpp och byt platser',
  holdAlreadyHeldTitle: 'Dina platser är redan reserverade',
  holdAlreadyHeldBody: 'Fortsätt till kassan för att behålla dem.',
  accessExpiredTitle: 'Din session har gått ut',
  accessExpiredCopy:
      'Ladda om platskartan för att fortsätta. Platser som redan ligger i din varukorg förblir reserverade tills tiden går ut.',
  dismissError: 'Stäng felmeddelandet',
  testModeLong: 'Testläge · inget bokas',
  seatRemoved: 'Biljett borttagen',
  reloadSeatMap: 'Ladda om platskartan',
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
  labelNoLongerAvailable: _labelNoLongerAvailableSv,
  labelsNoLongerAvailable: _labelsNoLongerAvailableSv,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherSv,
  couldNotRemoveLabel: _couldNotRemoveLabelSv,
  peekSecured: _peekSecuredSv,
  venueMap: _venueMapSv,
  accessibleStep: _accessibleStepSv,
  chooseMinMaxGuests: _chooseMinMaxGuestsSv,
  chooseMore: _chooseMoreSv,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeSv,
  accessNeedWithCount: _accessNeedWithCountSv,
  ticketCount: _ticketCountSv,
  findBestSeats: _findBestSeatsSv,
  reselectSeats: _reselectSeatsSv,
  seatsFree: _seatsFreeSv,
  seatsLeftInSection: _seatsLeftInSectionSv,
  holdLapsedStillFree: _holdLapsedStillFreeSv,
  holdLapsedSomeTaken: _holdLapsedSomeTakenSv,
  holdLapsedAllTaken: _holdLapsedAllTakenSv,
  accessibleSections: _accessibleSectionsSv,
  placesAvailable: _placesAvailableSv,
  removeTickets: _removeTicketsSv,
  holdMinutesLeft: _holdMinutesLeftSv,
  holdSecondsLeft: _holdSecondsLeftSv,
  holdLapsedBody: _holdLapsedBodySv,
  seatsNotRecovered: _seatsNotRecoveredSv,
  activeFilters: _activeFiltersSv,
  accessibilityFiltersActive: _accessibilityFiltersActiveSv,
  onlyLeft: _onlyLeftSv,
  maintenancePaused: _maintenancePausedSv,
  continueWithTotal: _continueWithTotalSv,
);
