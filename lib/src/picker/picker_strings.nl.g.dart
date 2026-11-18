// GENERATED — do not edit.
//
// Source: design/locale_strings.json (nl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

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

String _peekSecuredNl(int count, String total) =>
    '✓ $count vastgelegd · $total. Je betaalt nu nog niets';

String _ticketCountNl(int count) =>
    count == 1 ? '$count ticket' : '$count tickets';

String _findBestSeatsNl(int count) =>
    count == 1 ? 'Zoek $count beste plaats' : 'Zoek $count beste plaatsen';

String _reselectSeatsNl(int count) =>
    count == 1 ? 'Opnieuw selecteren' : 'Opnieuw selecteren';

String _seatsFreeNl(int count) =>
    count == 1 ? '$count plaats' : '$count plaatsen';

String _seatsLeftInSectionNl(int count) =>
    count == 1 ? 'Nog $count plaats' : 'Nog $count plaatsen';

String _holdLapsedStillFreeNl(int count) => count == 1
    ? 'Je reservering is verlopen terwijl je weg was. Die plaats is nog vrij.'
    : 'Je reservering is verlopen terwijl je weg was. Die plaatsen zijn nog vrij.';

String _holdLapsedSomeTakenNl(int count) => count == 1
    ? 'Je reservering is verlopen terwijl je weg was en $count van die plaatsen is inmiddels bezet. De rest is nog vrij.'
    : 'Je reservering is verlopen terwijl je weg was en $count van die plaatsen zijn inmiddels bezet. De rest is nog vrij.';

String _holdLapsedAllTakenNl(int count) => count == 1
    ? 'Je reservering is verlopen terwijl je weg was en die plaats is inmiddels bezet.'
    : 'Je reservering is verlopen terwijl je weg was en die plaatsen zijn inmiddels bezet.';

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
  testMode: 'TESTMODUS',
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
  allSetTitle: 'Je bent klaar',
  confirmedAndOnWay: 'bevestigd. Je bevestiging is onderweg.',
  backToMap: 'Terug naar plattegrond',
  mapDidNotLoad: 'De zaalplattegrond is niet geladen',
  checkConnection: 'Controleer je verbinding en probeer het opnieuw.',
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
  peekSecured: _peekSecuredNl,
  ticketCount: _ticketCountNl,
  findBestSeats: _findBestSeatsNl,
  reselectSeats: _reselectSeatsNl,
  seatsFree: _seatsFreeNl,
  seatsLeftInSection: _seatsLeftInSectionNl,
  holdLapsedStillFree: _holdLapsedStillFreeNl,
  holdLapsedSomeTaken: _holdLapsedSomeTakenNl,
  holdLapsedAllTaken: _holdLapsedAllTakenNl,
  continueWithTotal: _continueWithTotalNl,
);
