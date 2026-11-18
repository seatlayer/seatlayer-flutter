// GENERATED — do not edit.
//
// Source: design/locale_strings.json (ro)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftRo(int count) => 'Au rămas $count';

String _moreCountRo(int count) => '+$count în plus';

String _addMinutesRo(int minutes) => '+$minutes min';

String _fromPriceRo(String money) => 'De la $money';

String _sightlineRo(String metres) => '≈ $metres m până la scenă';

String _secureMoreAndCheckoutRo(int count) => 'Asigură încă $count și plătește';

String _accessFreeCountRo(int count) => '$count libere';

String _seatJustTakenByAnotherRo(String label) =>
    'Locul $label tocmai a fost luat de alt cumpărător.';

String _peekSecuredRo(int count, String total) =>
    '✓ $count asigurate · $total. Încă nu vei fi taxat';

String _ticketCountRo(int count) => switch (pickerPluralCategory('ro', count)) {
  PickerPluralCategory.one => '$count bilet',
  PickerPluralCategory.few => '$count bilete',
  _ => '$count de bilete',
};

String _findBestSeatsRo(int count) =>
    switch (pickerPluralCategory('ro', count)) {
      PickerPluralCategory.one => 'Găsește $count cel mai bun loc',
      PickerPluralCategory.few => 'Găsește cele mai bune $count locuri',
      _ => 'Găsește cele mai bune $count de locuri',
    };

String _reselectSeatsRo(int count) =>
    switch (pickerPluralCategory('ro', count)) {
      PickerPluralCategory.one => 'Selectează-l din nou',
      PickerPluralCategory.few => 'Selectează-le din nou',
      _ => 'Selectează-le din nou',
    };

String _seatsFreeRo(int count) => switch (pickerPluralCategory('ro', count)) {
  PickerPluralCategory.one => '$count loc',
  PickerPluralCategory.few => '$count locuri',
  _ => '$count de locuri',
};

String _seatsLeftInSectionRo(int count) =>
    switch (pickerPluralCategory('ro', count)) {
      PickerPluralCategory.one => 'A rămas $count loc',
      PickerPluralCategory.few => 'Au rămas $count locuri',
      _ => 'Au rămas $count de locuri',
    };

String _holdLapsedStillFreeRo(int count) => switch (pickerPluralCategory(
  'ro',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervarea ta a expirat cât ai fost plecat. Locul este încă liber.',
  PickerPluralCategory.few =>
    'Rezervarea ta a expirat cât ai fost plecat. Locurile sunt încă libere.',
  _ => 'Rezervarea ta a expirat cât ai fost plecat. Locurile sunt încă libere.',
};

String _holdLapsedSomeTakenRo(int count) => switch (pickerPluralCategory(
  'ro',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervarea ta a expirat cât ai fost plecat, iar $count dintre aceste locuri a fost deja ocupat. Restul sunt încă libere.',
  PickerPluralCategory.few =>
    'Rezervarea ta a expirat cât ai fost plecat, iar $count dintre aceste locuri au fost deja ocupate. Restul sunt încă libere.',
  _ =>
    'Rezervarea ta a expirat cât ai fost plecat, iar $count dintre aceste locuri au fost deja ocupate. Restul sunt încă libere.',
};

String _holdLapsedAllTakenRo(int count) => switch (pickerPluralCategory(
  'ro',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervarea ta a expirat cât ai fost plecat, iar acest loc a fost deja ocupat.',
  PickerPluralCategory.few =>
    'Rezervarea ta a expirat cât ai fost plecat, iar aceste locuri au fost deja ocupate.',
  _ =>
    'Rezervarea ta a expirat cât ai fost plecat, iar aceste locuri au fost deja ocupate.',
};

String _continueWithTotalRo(String money) => 'Continuă \u00b7 $money';

/// The `ro` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsRo = SeatLayerPickerStrings(
  close: 'Închide',
  overview: 'Locație',
  backToVenue: 'Înapoi la locație',
  cancel: 'Anulează',
  select: 'Selectează',
  removeSeat: 'Elimină loc',
  viewFromHere: 'Priveliștea de aici',
  openVenue360: 'Deschide locația în 360°',
  recentre: 'Recentrează pe scenă',
  viewFromYourSeat: 'priveliștea de la locul dvs.',
  emptyTrayHint:
      'Atinge un loc pe hartă sau lasă-ne să alegem cele mai bune locuri disponibile pentru tine.',
  anyTicketType: 'Orice tip de bilet',
  anyVenueZone: 'Orice zonă a locației',
  bestSeats: 'Cele mai bune locuri',
  showLess: 'Afișează mai puțin',
  undo: 'Anulează',
  holdAndCheckout: 'Rezervă locurile și plătește',
  poweredBy: 'Susținut de SeatLayer',
  testMode: 'MOD DE TESTARE',
  accessibility: 'Opțiuni de accesibilitate și culoare',
  accessibilityTitle: 'Opțiuni de accesibilitate și culoare',
  fitVenue: 'Afișează întreaga locație',
  fitWholeVenue: 'Afișează întreaga locație',
  loading: 'Se încarcă harta locurilor…',
  errorMessage: 'Harta locurilor nu s-a încărcat',
  retry: 'Încearcă din nou',
  accessRefresh: 'Reîmprospătează',
  noSeatsSelected: 'Niciun loc selectat',
  findBestSeatsCta: 'Găsește cele mai bune locuri',
  organizerNote: 'Notă de la organizator',
  accessiblePhysicalSeat: 'Loc fizic accesibil',
  emptyWheelchairSpace: 'Spațiu liber pentru scaun cu rotile',
  findSeatsTogether: 'Găsește locuri alăturate',
  aboutBestSeats: 'Despre găsirea locurilor alăturate',
  closestGroupChosenInstantly:
      'Cel mai apropiat grup disponibil, ales instantaneu.',
  hideLimitedView: 'Ascunde locurile cu vizibilitate limitată',
  colorblindSafe: 'Culori potrivite pentru daltonism',
  notAvailable: 'Indisponibil',
  restrictedView: 'Vizibilitate limitată',
  obstructedView: 'Vizibilitate obstrucționată',
  premiumSeat: 'Loc premium',
  continueWord: 'Continuă',
  allFloors: 'Toate etajele',
  previousSection: 'Sectorul anterior',
  nextSection: 'Sectorul următor',
  addSeat: 'Adaugă loc',
  added: 'Adăugat',
  sectionWord: 'Sector',
  rowWord: 'Rând',
  seatWord: 'Loc',
  seeItIn3D: 'Vezi în 3D',
  viewFromThisSeat: 'Priveliștea de la acest loc',
  allPrices: 'Toate prețurile',
  ticketType: 'Tip de bilet',
  tierCompanionGuidance: 'Necesită locul alăturat pentru scaun cu rotile',
  findingBestSeats: 'Căutăm cele mai bune locuri…',
  findSeats: 'Găsește locuri',
  expandCart: 'Deschide panoul de bilete',
  collapseCart: 'Restrânge panoul de bilete',
  continueToCheckout: 'Continuă spre plată',
  secureMore: 'Asigură mai multe',
  selectSeats: 'Selectează locuri',
  pickYourSeats: 'Alege-ți locurile',
  salesClosedPill: 'Vânzările s-au închis',
  salesClosedCta: 'Vânzările s-au închis',
  confirmOrCancelSeat: 'Confirmă sau anulează acest loc',
  securingSeats: 'Îți asigurăm locurile…',
  openingCheckout: 'Deschidem plata securizată…',
  testModeExplained:
      'Rezervările de aici nu sunt reale și niciun card nu este taxat',
  displayOptions: 'Opțiuni de afișare',
  companionSeatsNote: 'Locurile alăturate pentru însoțitor rămân selectabile',
  zoomIn: 'Mărește',
  zoomOut: 'Micșorează',
  rotateVenue: 'Trage pentru a roti locația',
  moveVenue: 'Trage pentru a muta locația',
  mapView: 'Hartă',
  flat2dMap: 'Hartă 2D plată',
  interactive3dVenueView: 'Vizualizare 3D interactivă a locației',
  venueView: 'Vizualizarea locației',
  holdLapsedTitle: 'Locurile tale au fost eliberate',
  salesClosed: 'Vânzările s-au închis',
  salesClosedCopy: 'Vânzarea biletelor pentru acest eveniment s-a încheiat.',
  salesClosedToast: 'Vânzările pentru acest eveniment sunt închise.',
  soldOutEyebrow: 'Acest eveniment',
  soldOutTitle: 'Epuizat',
  soldOutCopy:
      'Momentan nu există locuri numerotate disponibile pentru acest eveniment.',
  holdExpired:
      'Rezervarea ta a expirat. Locurile au fost eliberate. Alege din nou.',
  addingEllipsis: 'Se adaugă…',
  moreTimeAdded:
      'S-a adăugat timp. Locurile tale sunt în continuare rezervate.',
  couldNotAddMoreTime: 'Nu am putut adăuga timp. Mergi acum la plată.',
  seatsJustTaken:
      'Unul sau mai multe locuri tocmai au fost luate. Alege din nou.',
  allSetTitle: 'Totul e pregătit',
  confirmedAndOnWay: 'confirmat. Confirmarea este pe drum.',
  backToMap: 'Înapoi la hartă',
  mapDidNotLoad: 'Harta locurilor nu s-a încărcat',
  checkConnection: 'Verifică-ți conexiunea și încearcă din nou.',
  accessPausedTitle: 'Aceste locuri sunt blocate momentan',
  accessPausedCopy:
      'Organizatorul a pus această selecție pe pauză. Încearcă din nou peste câteva minute.',
  accessRevokedTitle: 'Acest link de acces nu mai este activ',
  accessRevokedCopy:
      'Cere un link nou persoanei care ți l-a trimis, ca să rezervi în continuare aceste locuri.',
  accessUnverifiedTitle: 'Nu am putut verifica accesul tău',
  accessUnverifiedCopy:
      'Poți cumpăra în continuare tot ce apare ca disponibil. Contactează persoana care ți-a trimis linkul pentru acces la restul.',
  generalAdmission: 'Acces general',
  numberOfGuests: 'Numărul de invitați',
  chooseGuestsCopy:
      'Alege câți invitați stau împreună. Această masă este rezervată exclusiv pentru grupul tău.',
  fewerGuests: 'Mai puțini invitați',
  moreGuests: 'Mai mulți invitați',
  selectTable: 'Selectează masa',
  updateTable: 'Actualizează masa',
  removeWord: 'Elimină',
  floorWord: 'Etaj',
  totalWord: 'Total',
  accessNeeds: <String, String>{
    'wheelchair': 'Spațiu pentru scaun cu rotile',
    'companion': 'Loc pentru însoțitor',
    'semi-ambulatory': 'Mobilitate redusă',
    'designated-aisle': 'Culoar / transfer',
    'step-free': 'Fără trepte',
    'hearing': 'Asistență auditivă',
    'cart': 'Subtitrare în direct',
    'sign-language': 'Limbajul semnelor',
    'low-vision': 'Vedere slabă',
    'sensory-friendly': 'Prietenos senzorial',
    'plus-size': 'Loc mai lat',
    'lift-armrest': 'Cotieră rabatabilă',
  },
  seatsLeft: _seatsLeftRo,
  moreCount: _moreCountRo,
  addMinutes: _addMinutesRo,
  fromPrice: _fromPriceRo,
  sightline: _sightlineRo,
  secureMoreAndCheckout: _secureMoreAndCheckoutRo,
  accessFreeCount: _accessFreeCountRo,
  seatJustTakenByAnother: _seatJustTakenByAnotherRo,
  peekSecured: _peekSecuredRo,
  ticketCount: _ticketCountRo,
  findBestSeats: _findBestSeatsRo,
  reselectSeats: _reselectSeatsRo,
  seatsFree: _seatsFreeRo,
  seatsLeftInSection: _seatsLeftInSectionRo,
  holdLapsedStillFree: _holdLapsedStillFreeRo,
  holdLapsedSomeTaken: _holdLapsedSomeTakenRo,
  holdLapsedAllTaken: _holdLapsedAllTakenRo,
  continueWithTotal: _continueWithTotalRo,
);
