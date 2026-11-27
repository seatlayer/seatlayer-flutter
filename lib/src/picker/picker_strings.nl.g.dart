// GENERATED — do not edit.
//
// Source: design/locale_strings.json (nl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftNl(int count) => 'Nog $count';

String _moreCountNl(int count) => '+$count meer';

String _addMinutesNl(int minutes) => '+$minutes min';

String _fromPriceNl(String money) => 'Vanaf $money';

String _sightlineNl(String metres) => '≈ $metres m tot het podium';

String _secureMoreAndCheckoutNl(int count) =>
    'Nog $count vastleggen & afrekenen';

String _accessFreeCountNl(int count) => '$count vrij';

String _seatJustTakenByAnotherNl(String label) =>
    'Plaats $label is zojuist door een andere koper genomen.';

String _labelNoLongerAvailableNl(String label) =>
    '$label is niet meer beschikbaar. Kies een andere plaats.';

String _labelsNoLongerAvailableNl(String labels) =>
    '$labels zijn niet meer beschikbaar. Kies een andere groep.';

String _couldNotFindSeatsTogetherNl(int count) =>
    'We konden geen $count plaatsen naast elkaar vinden. Probeer minder plaatsen of een ander tickettype.';

String _maxTicketsForOrderNl(int count) =>
    'Je kunt maximaal $count tickets selecteren voor deze bestelling.';

String _couldNotRemoveLabelNl(String label) =>
    'Kon $label niet verwijderen. Je reservering blijft ongewijzigd.';

String _peekSecuredNl(int count, String total) =>
    '✓ $count vastgelegd · $total. Je betaalt nu nog niets';

String _venueMapNl(String venue) => 'Zaalplattegrond van $venue';

String _accessibleStepNl(int index, int total) => '$index van $total';

String _chooseMinMaxGuestsNl(int min, int max) =>
    'Kies tussen $min en $max gasten.';

String _chooseMoreNl(int count) => 'Nog $count kiezen';

String _seatsHeldForNeedMoreTimeNl(String time) =>
    'Je plaatsen worden nog $time voor je vastgehouden. Meer tijd nodig?';

String _accessNeedWithCountNl(String need, int count) => '$need · $count';

String _ticketCountNl(int count) => switch (pickerPluralCategory('nl', count)) {
  PickerPluralCategory.one => '$count ticket',
  _ => '$count tickets',
};

String _findBestSeatsNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => 'Zoek $count beste plaats',
      _ => 'Zoek $count beste plaatsen',
    };

String _reselectSeatsNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => 'Opnieuw selecteren',
      _ => 'Opnieuw selecteren',
    };

String _seatsFreeNl(int count) => switch (pickerPluralCategory('nl', count)) {
  PickerPluralCategory.one => '$count plaats',
  _ => '$count plaatsen',
};

String _seatsLeftInSectionNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => 'Nog $count plaats',
      _ => 'Nog $count plaatsen',
    };

String _holdLapsedStillFreeNl(int count) => switch (pickerPluralCategory(
  'nl',
  count,
)) {
  PickerPluralCategory.one =>
    'Je reservering is verlopen terwijl je weg was. Die plaats is nog vrij.',
  _ =>
    'Je reservering is verlopen terwijl je weg was. Die plaatsen zijn nog vrij.',
};

String _holdLapsedSomeTakenNl(int count) => switch (pickerPluralCategory(
  'nl',
  count,
)) {
  PickerPluralCategory.one =>
    'Je reservering is verlopen terwijl je weg was en $count van die plaatsen is inmiddels bezet. De rest is nog vrij.',
  _ =>
    'Je reservering is verlopen terwijl je weg was en $count van die plaatsen zijn inmiddels bezet. De rest is nog vrij.',
};

String _holdLapsedAllTakenNl(int count) => switch (pickerPluralCategory(
  'nl',
  count,
)) {
  PickerPluralCategory.one =>
    'Je reservering is verlopen terwijl je weg was en die plaats is inmiddels bezet.',
  _ =>
    'Je reservering is verlopen terwijl je weg was en die plaatsen zijn inmiddels bezet.',
};

String _accessibleSectionsNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => '$count vak',
      _ => '$count vakken',
    };

String _placesAvailableNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => '$count plaats nu beschikbaar',
      _ => '$count plaatsen nu beschikbaar',
    };

String _removeTicketsNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => '$count ticket verwijderen',
      _ => '$count tickets verwijderen',
    };

String _holdMinutesLeftNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => 'Nog $count minuut',
      _ => 'Nog $count minuten',
    };

String _holdSecondsLeftNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => 'Nog $count seconde',
      _ => 'Nog $count seconden',
    };

String _holdLapsedBodyNl(int count) => switch (pickerPluralCategory(
  'nl',
  count,
)) {
  PickerPluralCategory.one => 'Ze werden $count minuut voor je vastgehouden.',
  _ => 'Ze werden $count minuten voor je vastgehouden.',
};

String _seatsNotRecoveredNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one =>
        '$count plaats kon niet opnieuw worden vastgelegd',
      _ => '$count plaatsen konden niet opnieuw worden vastgelegd',
    };

String _activeFiltersNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => '$count filter',
      _ => '$count filters',
    };

String _accessibilityFiltersActiveNl(int count) =>
    switch (pickerPluralCategory('nl', count)) {
      PickerPluralCategory.one => '$count toegankelijkheidsfilter actief',
      _ => '$count toegankelijkheidsfilters actief',
    };

String _onlyLeftNl(int count) => switch (pickerPluralCategory('nl', count)) {
  PickerPluralCategory.one => 'Nog $count plaats',
  _ => 'Nog $count plaatsen',
};

String _maintenancePausedNl(int count) => switch (pickerPluralCategory(
  'nl',
  count,
)) {
  PickerPluralCategory.one =>
    'Boeken is gepauzeerd voor onderhoud. Probeer het over ongeveer $count minuut opnieuw.',
  _ =>
    'Boeken is gepauzeerd voor onderhoud. Probeer het over ongeveer $count minuten opnieuw.',
};

String _continueWithTotalNl(String money) => 'Doorgaan \u00b7 $money';

/// The `nl` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsNl = SeatLayerPickerStrings(
  close: 'Sluiten',
  overview: 'Locatie',
  backToVenue: 'Terug naar de zaal',
  cancel: 'Annuleren',
  select: 'Selecteren',
  removeSeat: 'Plaats verwijderen',
  viewFromHere: 'Uitzicht vanaf hier',
  openVenue360: 'Zaal in 360° openen',
  recentre: 'Opnieuw op het podium centreren',
  viewFromYourSeat: 'zicht vanaf jouw plaats',
  emptyTrayHint:
      'Tik op een plaats op de plattegrond, of laat ons de beste beschikbare voor je kiezen.',
  anyTicketType: 'Elk tickettype',
  anyVenueZone: 'Elke zone in de zaal',
  bestSeats: 'Beste plaatsen',
  showLess: 'Minder tonen',
  undo: 'Ongedaan maken',
  holdAndCheckout: 'Plaatsen vastleggen & afrekenen',
  poweredBy: 'Mogelijk gemaakt door SeatLayer',
  testMode: 'Testmodus',
  accessibility: 'Toegankelijkheid en kleuren',
  accessibilityTitle: 'Toegankelijkheid en kleuren',
  fitVenue: 'Hele locatie tonen',
  fitWholeVenue: 'Hele locatie tonen',
  loading: 'Zaalplattegrond laden…',
  errorMessage: 'De zaalplattegrond is niet geladen',
  retry: 'Opnieuw proberen',
  accessRefresh: 'Vernieuwen',
  noSeatsSelected: 'Geen plaatsen geselecteerd',
  findBestSeatsCta: 'Beste plaatsen zoeken',
  organizerNote: 'Notitie van de organisator',
  accessiblePhysicalSeat: 'Toegankelijke fysieke plaats',
  emptyWheelchairSpace: 'Lege rolstoelplaats',
  findSeatsTogether: 'Zoek plaatsen naast elkaar',
  aboutBestSeats: 'Over stoelen naast elkaar vinden',
  closestGroupChosenInstantly:
      'De dichtstbijzijnde beschikbare groep, direct gekozen.',
  hideLimitedView: 'Plaatsen met beperkt zicht verbergen',
  colorblindSafe: 'Kleurenblindvriendelijke kleuren',
  notAvailable: 'Niet beschikbaar',
  viewGroupTitle: 'WEERGAVE',
  restrictedView: 'Beperkt zicht',
  obstructedView: 'Belemmerd zicht',
  premiumSeat: 'Premium plaats',
  continueWord: 'Doorgaan',
  allFloors: 'Alle verdiepingen',
  previousSection: 'Vorig vak',
  nextSection: 'Volgend vak',
  addSeat: 'Plaats toevoegen',
  added: 'Toegevoegd',
  sectionWord: 'Vak',
  rowWord: 'Rij',
  seatWord: 'Plaats',
  seeItIn3D: 'Bekijk in 3D',
  viewFromThisSeat: 'Uitzicht vanaf deze plaats',
  allPrices: 'Alle prijzen',
  ticketPrices: 'Ticketprijzen',
  yourSeats: 'Jouw plaatsen',
  ticketType: 'Tickettype',
  tierCompanionGuidance: 'Vereist de aangrenzende rolstoelplaats',
  findingBestSeats: 'De beste plaatsen worden gezocht…',
  findSeats: 'Plaatsen zoeken',
  expandCart: 'Ticketpaneel openen',
  collapseCart: 'Ticketpaneel inklappen',
  continueToCheckout: 'Door naar afrekenen',
  secureMore: 'Meer vastleggen',
  selectSeats: 'Plaatsen selecteren',
  pickYourSeats: 'Kies je plaatsen',
  salesClosedPill: 'Verkoop gesloten',
  salesClosedCta: 'Verkoop gesloten',
  confirmOrCancelSeat: 'Deze plaats bevestigen of annuleren',
  securingSeats: 'Je plaatsen worden vastgelegd…',
  openingCheckout: 'Beveiligde betaalpagina wordt geopend…',
  testModeExplained:
      'Boekingen hier zijn niet echt en er wordt geen kaart belast',
  displayOptions: 'Weergave-opties',
  companionSeatsNote: 'De begeleidersplaatsen ernaast blijven selecteerbaar',
  zoomIn: 'Inzoomen',
  zoomOut: 'Uitzoomen',
  rotateVenue: 'Sleep om de locatie te draaien',
  moveVenue: 'Sleep om de locatie te verplaatsen',
  mapView: 'Plattegrond',
  flat2dMap: 'Platte 2D-plattegrond',
  interactive3dVenueView: 'Interactieve 3D-weergave van de zaal',
  venueView: 'Zaalweergave',
  holdLapsedTitle: 'Je plaatsen zijn vrijgegeven',
  salesClosed: 'Verkoop gesloten',
  salesClosedCopy: 'De ticketverkoop voor dit evenement is afgelopen.',
  salesClosedToast: 'De verkoop voor dit evenement is gesloten.',
  soldOutEyebrow: 'Dit evenement',
  soldOutTitle: 'Uitverkocht',
  soldOutCopy:
      'Er zijn momenteel geen genummerde plaatsen beschikbaar voor dit evenement.',
  holdExpired:
      'Je reservering is verlopen. De plaatsen zijn vrijgegeven. Kies opnieuw.',
  addingEllipsis: 'Toevoegen…',
  moreTimeAdded: 'Extra tijd toegevoegd. Je plaatsen blijven gereserveerd.',
  couldNotAddMoreTime:
      'Kon geen extra tijd toevoegen. Ga nu naar de betaalpagina.',
  seatsJustTaken: 'Een of meer plaatsen zijn zojuist genomen. Kies opnieuw.',
  ticketTypeSoldOut:
      'Dat tickettype is uitverkocht. Probeer een ander tickettype.',
  seatsNoLongerAvailableTryAnother:
      'Die plaatsen zijn niet meer beschikbaar. Probeer een ander aantal of tickettype.',
  companionPairRequired:
      'Selecteer bij elk begeleiderticket de aangrenzende rolstoelplaats.',
  ticketOptionNotApplicable:
      'Die ticketkeuze is niet beschikbaar voor de geselecteerde plaats.',
  maintenancePausedShortly:
      'Boeken is enkele minuten gepauzeerd voor onderhoud. Probeer het zo meteen opnieuw.',
  guestsOnly: 'Dit evenement is voor genodigden.',
  guestChoiceClosed: 'Plaatsen kiezen is nu niet mogelijk.',
  maxOneTicketForOrder:
      'Je kunt maximaal 1 ticket selecteren voor deze bestelling.',
  tooManyAttempts: 'Te veel pogingen. Wacht even en probeer het opnieuw.',
  seatHeldForRenewal:
      'Een van deze plaatsen is gereserveerd voor een houder van een seizoensticket die hem nog kan verlengen. Kies een andere plaats.',
  seatUnavailable: 'Deze plaats is niet beschikbaar.',
  eventUnavailable: 'Hier kunnen nu geen tickets worden geboekt.',
  savedSeatsNotRestored:
      'Je eerdere stoelen konden niet worden hersteld. Kies ze opnieuw.',
  allSetTitle: 'Je bent klaar',
  confirmedAndOnWay: 'bevestigd. Je bevestiging is onderweg.',
  backToMap: 'Terug naar plattegrond',
  mapDidNotLoad: 'De zaalplattegrond is niet geladen',
  checkConnection: 'Controleer je verbinding en probeer het opnieuw.',
  offline: 'Je bent offline',
  backOnline: 'Weer online',
  stillHeld: 'Je plaatsen blijven gereserveerd.',
  updating: 'Bijwerken…',
  takingLonger: 'Dit duurt langer dan normaal. Even geduld…',
  loadingTakingLonger:
      'Het laden van de zaalplattegrond duurt langer. Even geduld…',
  couldNotReachCheckout: 'Kon de checkout niet bereiken.',
  accessPausedTitle: 'Deze plaatsen zijn nu even geblokkeerd',
  accessPausedCopy:
      'De organisator heeft deze selectie gepauzeerd. Probeer het over enkele minuten opnieuw.',
  accessRevokedTitle: 'Deze toegangslink is niet meer actief',
  accessRevokedCopy:
      'Vraag wie je deze link stuurde om een nieuwe link om deze plaatsen te blijven boeken.',
  accessUnverifiedTitle: 'We konden je toegang niet verifiëren',
  accessUnverifiedCopy:
      'Je kunt nog steeds alles boeken dat als beschikbaar wordt getoond. Neem contact op met wie je deze link stuurde voor toegang tot de rest.',
  generalAdmission: 'Vrije plaatsen',
  numberOfGuests: 'Aantal gasten',
  chooseGuestsCopy:
      'Kies met hoeveel gasten je samen zit. Deze tafel wordt exclusief voor jullie gereserveerd.',
  fewerGuests: 'Minder gasten',
  moreGuests: 'Meer gasten',
  selectTable: 'Tafel selecteren',
  updateTable: 'Tafel bijwerken',
  removeWord: 'Verwijderen',
  floorWord: 'Verdieping',
  totalWord: 'Totaal',
  adjustSelection: 'Plaatskeuze aanpassen',
  backToSeatMap: 'Terug naar zaalplattegrond',
  chooseSeats: 'Kies je plaatsen',
  chooseTickets: 'Tickets kiezen',
  placeWord: 'PLAATS',
  guestsWord: 'Gasten',
  tableWord: 'Tafel',
  ticketWord: 'Ticket',
  passport: 'Plaatsprofiel',
  venue3D: '3D',
  venueZone: 'Zone in de zaal',
  venueMapHint:
      'Je kiest plaatsen met de knoppen rond de plattegrond: de prijsbalk erboven, de vakknoppen eronder en het ticketpaneel onderaan.',
  previousSeat: 'Vorige plaats',
  nextSeat: 'Volgende plaats',
  orbitMode: 'Zaal draaien',
  panMode: 'Zaal verschuiven',
  openInteractive3dVenue: 'Interactieve 3D-weergave van de zaal openen',
  showSeatsFor: 'PLAATSEN TONEN VOOR',
  accessJumpFirstSection: 'Ga naar het eerste vak',
  accessJumpNextSection: 'Ga naar het volgende vak',
  fewerTickets: 'Minder tickets',
  moreTickets: 'Meer tickets',
  addTickets: 'Tickets toevoegen',
  noSelectableSeats: 'Er zijn op dit moment geen plaatsen om te kiezen.',
  confirmYourTickets: 'Bevestig je tickets',
  seatsSecuredOpeningCheckout:
      'Plaatsen vastgelegd. Betaalpagina wordt geopend…',
  holdInCheckoutTitle: 'Je plaatsen zijn al bij het afrekenen',
  holdInCheckoutBody:
      'Rond het afrekenen af om ze te houden. Wil je andere plaatsen kiezen? Geef deze dan eerst vrij — ze komen weer in de verkoop.',
  releaseAndChangeSeats: 'Vrijgeven en plaatsen wijzigen',
  holdAlreadyHeldTitle: 'Je plaatsen zijn al gereserveerd',
  holdAlreadyHeldBody: 'Ga door naar afrekenen om ze te houden.',
  accessExpiredTitle: 'Je sessie is verlopen',
  accessExpiredCopy:
      'Laad de zaalplattegrond opnieuw om verder te gaan. Plaatsen die al in je winkelwagen zitten, blijven vastgehouden tot de timer afloopt.',
  dismissError: 'Foutmelding sluiten',
  testModeLong: 'Testmodus · boekt niets',
  seatRemoved: 'Ticket verwijderd',
  reloadSeatMap: 'Zaalplattegrond opnieuw laden',
  accessNeeds: <String, String>{
    'wheelchair': 'Rolstoelplaats',
    'companion': 'Begeleidersplaats',
    'semi-ambulatory': 'Beperkte mobiliteit',
    'designated-aisle': 'Gangpad / overstappen',
    'step-free': 'Drempelvrij',
    'hearing': 'Ringleiding',
    'cart': 'Live ondertiteling',
    'sign-language': 'Gebarentaal',
    'low-vision': 'Slechtziend',
    'sensory-friendly': 'Prikkelarm',
    'plus-size': 'Extra brede plaats',
    'lift-armrest': 'Opklapbare armleuning',
  },
  seatsLeft: _seatsLeftNl,
  moreCount: _moreCountNl,
  addMinutes: _addMinutesNl,
  fromPrice: _fromPriceNl,
  sightline: _sightlineNl,
  secureMoreAndCheckout: _secureMoreAndCheckoutNl,
  accessFreeCount: _accessFreeCountNl,
  seatJustTakenByAnother: _seatJustTakenByAnotherNl,
  labelNoLongerAvailable: _labelNoLongerAvailableNl,
  labelsNoLongerAvailable: _labelsNoLongerAvailableNl,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherNl,
  maxTicketsForOrder: _maxTicketsForOrderNl,
  couldNotRemoveLabel: _couldNotRemoveLabelNl,
  peekSecured: _peekSecuredNl,
  venueMap: _venueMapNl,
  accessibleStep: _accessibleStepNl,
  chooseMinMaxGuests: _chooseMinMaxGuestsNl,
  chooseMore: _chooseMoreNl,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeNl,
  accessNeedWithCount: _accessNeedWithCountNl,
  ticketCount: _ticketCountNl,
  findBestSeats: _findBestSeatsNl,
  reselectSeats: _reselectSeatsNl,
  seatsFree: _seatsFreeNl,
  seatsLeftInSection: _seatsLeftInSectionNl,
  holdLapsedStillFree: _holdLapsedStillFreeNl,
  holdLapsedSomeTaken: _holdLapsedSomeTakenNl,
  holdLapsedAllTaken: _holdLapsedAllTakenNl,
  accessibleSections: _accessibleSectionsNl,
  placesAvailable: _placesAvailableNl,
  removeTickets: _removeTicketsNl,
  holdMinutesLeft: _holdMinutesLeftNl,
  holdSecondsLeft: _holdSecondsLeftNl,
  holdLapsedBody: _holdLapsedBodyNl,
  seatsNotRecovered: _seatsNotRecoveredNl,
  activeFilters: _activeFiltersNl,
  accessibilityFiltersActive: _accessibilityFiltersActiveNl,
  onlyLeft: _onlyLeftNl,
  maintenancePaused: _maintenancePausedNl,
  continueWithTotal: _continueWithTotalNl,
);
