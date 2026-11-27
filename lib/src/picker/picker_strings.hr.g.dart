// GENERATED — do not edit.
//
// Source: design/locale_strings.json (hr)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftHr(int count) => 'Preostalo $count';

String _moreCountHr(int count) => '+$count više';

String _addMinutesHr(int minutes) => '+$minutes min';

String _fromPriceHr(String money) => 'Od $money';

String _sightlineHr(String metres) => '≈ $metres m do pozornice';

String _secureMoreAndCheckoutHr(int count) => 'Osiguraj još $count i plati';

String _accessFreeCountHr(int count) => 'Slobodnih: $count';

String _seatJustTakenByAnotherHr(String label) =>
    'Mjesto $label upravo je zauzeo drugi kupac.';

String _labelNoLongerAvailableHr(String label) =>
    '$label više nije dostupno. Odaberite drugo mjesto.';

String _labelsNoLongerAvailableHr(String labels) =>
    '$labels više nisu dostupna. Odaberite drugu skupinu.';

String _couldNotFindSeatsTogetherHr(int count) =>
    'Nismo pronašli $count mjesta jedno uz drugo. Pokušajte s manje mjesta ili drugom vrstom ulaznice.';

String _maxTicketsForOrderHr(int count) =>
    'Za ovu narudžbu možete odabrati najviše $count ulaznica.';

String _couldNotRemoveLabelHr(String label) =>
    'Nismo mogli ukloniti $label. Rezervacija je nepromijenjena.';

String _peekSecuredHr(int count, String total) =>
    '✓ $count osigurano · $total. Još vas nećemo teretiti';

String _venueMapHr(String venue) => 'Plan mjesta – $venue';

String _accessibleStepHr(int index, int total) => '$index od $total';

String _chooseMinMaxGuestsHr(int min, int max) =>
    'Odaberite između $min i $max gostiju.';

String _chooseMoreHr(int count) => 'Odaberi još $count';

String _seatsHeldForNeedMoreTimeHr(String time) =>
    'Vaša su mjesta rezervirana još $time. Trebate li više vremena?';

String _accessNeedWithCountHr(String need, int count) => '$need · $count';

String _ticketCountHr(int count) => switch (pickerPluralCategory('hr', count)) {
  PickerPluralCategory.one => '$count ulaznica',
  PickerPluralCategory.few => '$count ulaznice',
  _ => '$count ulaznica',
};

String _findBestSeatsHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Pronađi $count najbolje mjesto',
      PickerPluralCategory.few => 'Pronađi $count najbolja mjesta',
      _ => 'Pronađi $count najboljih mjesta',
    };

String _reselectSeatsHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Ponovno ga odaberite',
      PickerPluralCategory.few => 'Ponovno ih odaberite',
      _ => 'Ponovno ih odaberite',
    };

String _seatsFreeHr(int count) => switch (pickerPluralCategory('hr', count)) {
  PickerPluralCategory.one => '$count mjesto',
  PickerPluralCategory.few => '$count mjesta',
  _ => '$count mjesta',
};

String _seatsLeftInSectionHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Preostalo $count mjesto',
      PickerPluralCategory.few => 'Preostala $count mjesta',
      _ => 'Preostalo $count mjesta',
    };

String _holdLapsedStillFreeHr(int count) => switch (pickerPluralCategory(
  'hr',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša je rezervacija istekla dok vas nije bilo. To je mjesto i dalje slobodno.',
  PickerPluralCategory.few =>
    'Vaša je rezervacija istekla dok vas nije bilo. Ta su mjesta i dalje slobodna.',
  _ =>
    'Vaša je rezervacija istekla dok vas nije bilo. Ta su mjesta i dalje slobodna.',
};

String _holdLapsedSomeTakenHr(int count) => switch (pickerPluralCategory(
  'hr',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša je rezervacija istekla dok vas nije bilo, a $count od tih mjesta je već zauzeto. Ostala su i dalje slobodna.',
  PickerPluralCategory.few =>
    'Vaša je rezervacija istekla dok vas nije bilo, a $count od tih mjesta su već zauzeta. Ostala su i dalje slobodna.',
  _ =>
    'Vaša je rezervacija istekla dok vas nije bilo, a $count od tih mjesta je već zauzeto. Ostala su i dalje slobodna.',
};

String _holdLapsedAllTakenHr(int count) => switch (pickerPluralCategory(
  'hr',
  count,
)) {
  PickerPluralCategory.one =>
    'Vaša je rezervacija istekla dok vas nije bilo, a to je mjesto već zauzeto.',
  PickerPluralCategory.few =>
    'Vaša je rezervacija istekla dok vas nije bilo, a ta su mjesta već zauzeta.',
  _ =>
    'Vaša je rezervacija istekla dok vas nije bilo, a ta su mjesta već zauzeta.',
};

String _accessibleSectionsHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => '$count sektor',
      PickerPluralCategory.few => '$count sektora',
      _ => '$count sektora',
    };

String _placesAvailableHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Trenutno je dostupno $count mjesto',
      PickerPluralCategory.few => 'Trenutno su dostupna $count mjesta',
      _ => 'Trenutno je dostupno $count mjesta',
    };

String _removeTicketsHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Ukloni $count ulaznicu',
      PickerPluralCategory.few => 'Ukloni $count ulaznice',
      _ => 'Ukloni $count ulaznica',
    };

String _holdMinutesLeftHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Preostala je $count minuta',
      PickerPluralCategory.few => 'Preostale su $count minute',
      _ => 'Preostalo je $count minuta',
    };

String _holdSecondsLeftHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Preostala je $count sekunda',
      PickerPluralCategory.few => 'Preostale su $count sekunde',
      _ => 'Preostalo je $count sekundi',
    };

String _holdLapsedBodyHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => 'Bila su rezervirana $count minutu.',
      PickerPluralCategory.few => 'Bila su rezervirana $count minute.',
      _ => 'Bila su rezervirana $count minuta.',
    };

String _seatsNotRecoveredHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => '$count mjesto nije bilo moguće vratiti',
      PickerPluralCategory.few => '$count mjesta nije bilo moguće vratiti',
      _ => '$count mjesta nije bilo moguće vratiti',
    };

String _activeFiltersHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => '$count filtar',
      PickerPluralCategory.few => '$count filtra',
      _ => '$count filtara',
    };

String _accessibilityFiltersActiveHr(int count) =>
    switch (pickerPluralCategory('hr', count)) {
      PickerPluralCategory.one => '$count aktivan filtar pristupačnosti',
      PickerPluralCategory.few => '$count aktivna filtra pristupačnosti',
      _ => '$count aktivnih filtara pristupačnosti',
    };

String _onlyLeftHr(int count) => switch (pickerPluralCategory('hr', count)) {
  PickerPluralCategory.one => 'Preostalo $count mjesto',
  PickerPluralCategory.few => 'Preostala $count mjesta',
  _ => 'Preostalo $count mjesta',
};

String _maintenancePausedHr(int count) => switch (pickerPluralCategory(
  'hr',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezervacija je pauzirana zbog održavanja. Pokušajte ponovno za otprilike $count minutu.',
  PickerPluralCategory.few =>
    'Rezervacija je pauzirana zbog održavanja. Pokušajte ponovno za otprilike $count minute.',
  _ =>
    'Rezervacija je pauzirana zbog održavanja. Pokušajte ponovno za otprilike $count minuta.',
};

String _continueWithTotalHr(String money) => 'Nastavi \u00b7 $money';

/// The `hr` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsHr = SeatLayerPickerStrings(
  close: 'Zatvori',
  overview: 'Prostor',
  backToVenue: 'Natrag na prostor',
  cancel: 'Odustani',
  select: 'Odaberi',
  removeSeat: 'Ukloni mjesto',
  viewFromHere: 'Pogled odavde',
  openVenue360: 'Otvori prostor u 360°',
  recentre: 'Ponovno centriraj na pozornicu',
  viewFromYourSeat: 'pogled s vašeg mjesta',
  emptyTrayHint:
      'Dodirnite mjesto na planu ili prepustite nama da odaberemo najbolja dostupna.',
  anyTicketType: 'Bilo koja vrsta ulaznice',
  anyVenueZone: 'Bilo koja zona prostora',
  bestSeats: 'Najbolja mjesta',
  showLess: 'Prikaži manje',
  undo: 'Poništi',
  holdAndCheckout: 'Rezerviraj mjesta i plati',
  poweredBy: 'Pokreće SeatLayer',
  testMode: 'Testni način',
  accessibility: 'Pristupačnost i boje',
  accessibilityTitle: 'Pristupačnost i boje',
  fitVenue: 'Prikaži cijelo mjesto održavanja',
  fitWholeVenue: 'Prikaži cijelo mjesto održavanja',
  loading: 'Učitavanje plana mjesta…',
  errorMessage: 'Plan mjesta se nije učitao',
  retry: 'Pokušaj ponovno',
  accessRefresh: 'Osvježi',
  noSeatsSelected: 'Nema odabranih mjesta',
  findBestSeatsCta: 'Pronađi najbolja mjesta',
  organizerNote: 'Napomena organizatora',
  accessiblePhysicalSeat: 'Pristupačno fizičko mjesto',
  emptyWheelchairSpace: 'Slobodno mjesto za invalidska kolica',
  findSeatsTogether: 'Pronađi mjesta jedno uz drugo',
  aboutBestSeats: 'O pronalaženju sjedala jedno uz drugo',
  closestGroupChosenInstantly:
      'Najbliža dostupna skupina, odabrana istog trena.',
  hideLimitedView: 'Sakrij mjesta s ograničenim pogledom',
  colorblindSafe: 'Boje prilagođene daltonizmu',
  notAvailable: 'Nije dostupno',
  viewGroupTitle: 'PRIKAZ',
  restrictedView: 'Ograničen pogled',
  obstructedView: 'Zaklonjen pogled',
  premiumSeat: 'Premium mjesto',
  continueWord: 'Nastavi',
  allFloors: 'Svi katovi',
  previousSection: 'Prethodni sektor',
  nextSection: 'Sljedeći sektor',
  addSeat: 'Dodaj mjesto',
  added: 'Dodano',
  sectionWord: 'Sektor',
  rowWord: 'Red',
  seatWord: 'Mjesto',
  seeItIn3D: 'Pogledaj u 3D-u',
  viewFromThisSeat: 'Pogled s ovog mjesta',
  allPrices: 'Sve cijene',
  ticketPrices: 'Cijene ulaznica',
  yourSeats: 'Vaša mjesta',
  ticketType: 'Vrsta ulaznice',
  tierCompanionGuidance: 'Zahtijeva susjedno mjesto za invalidska kolica',
  findingBestSeats: 'Tražimo najbolja mjesta…',
  findSeats: 'Pronađi mjesta',
  expandCart: 'Otvori ploču s ulaznicama',
  collapseCart: 'Sažmi ploču s ulaznicama',
  continueToCheckout: 'Nastavi na plaćanje',
  secureMore: 'Osiguraj još',
  selectSeats: 'Odaberi mjesta',
  pickYourSeats: 'Odaberite svoja mjesta',
  salesClosedPill: 'Prodaja je zatvorena',
  salesClosedCta: 'Prodaja je zatvorena',
  confirmOrCancelSeat: 'Potvrdite ili otkažite ovo mjesto',
  securingSeats: 'Osiguravamo vaša mjesta…',
  openingCheckout: 'Otvaramo sigurno plaćanje…',
  testModeExplained: 'Rezervacije ovdje nisu stvarne i kartica se ne naplaćuje',
  displayOptions: 'Opcije prikaza',
  companionSeatsNote: 'Susjedna mjesta za pratnju ostaju dostupna za odabir',
  zoomIn: 'Približi',
  zoomOut: 'Udalji',
  rotateVenue: 'Povucite za rotiranje mjesta održavanja',
  moveVenue: 'Povucite za pomicanje mjesta održavanja',
  mapView: 'Plan',
  flat2dMap: 'Ravni 2D plan',
  interactive3dVenueView: 'Interaktivni 3D prikaz prostora',
  venueView: 'Prikaz prostora',
  holdLapsedTitle: 'Vaša su mjesta oslobođena',
  salesClosed: 'Prodaja je zatvorena',
  salesClosedCopy: 'Prodaja ulaznica za ovaj događaj je završila.',
  salesClosedToast: 'Prodaja za ovaj događaj je zatvorena.',
  soldOutEyebrow: 'Ovaj događaj',
  soldOutTitle: 'Rasprodano',
  soldOutCopy: 'Trenutačno nema dostupnih numeriranih mjesta za ovaj događaj.',
  holdExpired:
      'Vaša je rezervacija istekla. Mjesta su oslobođena. Odaberite ponovno.',
  addingEllipsis: 'Dodavanje…',
  moreTimeAdded: 'Dodano je vrijeme. Vaša su mjesta i dalje rezervirana.',
  couldNotAddMoreTime:
      'Nije bilo moguće dodati vrijeme. Krenite odmah na plaćanje.',
  seatsJustTaken: 'Jedno ili više mjesta upravo je zauzeto. Odaberite ponovno.',
  ticketTypeSoldOut:
      'Ta je vrsta ulaznice rasprodana. Pokušajte s drugom vrstom.',
  seatsNoLongerAvailableTryAnother:
      'Ta mjesta više nisu dostupna. Pokušajte s drugom količinom ili vrstom ulaznice.',
  companionPairRequired:
      'Uz svaku ulaznicu za pratitelja odaberite susjedno mjesto za invalidska kolica.',
  ticketOptionNotApplicable:
      'Ta vrsta ulaznice nije dostupna za odabrano mjesto.',
  maintenancePausedShortly:
      'Rezervacija je pauzirana na nekoliko minuta zbog održavanja. Pokušajte ponovno uskoro.',
  guestsOnly: 'Ovaj događaj je za pozvane goste.',
  guestChoiceClosed: 'Odabir mjesta trenutačno nije otvoren.',
  maxOneTicketForOrder: 'Za ovu narudžbu možete odabrati najviše 1 ulaznicu.',
  tooManyAttempts: 'Previše pokušaja. Pričekajte trenutak i pokušajte ponovno.',
  seatHeldForRenewal:
      'Jedno od ovih mjesta čuva se za vlasnika sezonske ulaznice koji je još može obnoviti. Odaberite drugo mjesto.',
  seatUnavailable: 'Ovo mjesto nije dostupno.',
  eventUnavailable: 'Ulaznice se ovdje trenutačno ne mogu rezervirati.',
  savedSeatsNotRestored:
      'Vaša prethodna mjesta nije bilo moguće vratiti. Odaberite ponovno.',
  allSetTitle: 'Sve je spremno',
  confirmedAndOnWay: 'potvrđeno. Potvrda je na putu.',
  backToMap: 'Natrag na plan',
  mapDidNotLoad: 'Plan mjesta se nije učitao',
  checkConnection: 'Provjerite vezu i pokušajte ponovno.',
  offline: 'Izvan mreže ste',
  backOnline: 'Ponovno na mreži',
  stillHeld: 'Vaša su mjesta i dalje rezervirana.',
  updating: 'Ažuriranje…',
  takingLonger: 'Ovo traje dulje nego obično. Molimo pričekajte…',
  loadingTakingLonger:
      'Učitavanje plana mjesta traje dulje nego obično. Molimo pričekajte…',
  couldNotReachCheckout: 'Nismo mogli pristupiti plaćanju.',
  accessPausedTitle: 'Ova su mjesta trenutačno blokirana',
  accessPausedCopy:
      'Organizator je pauzirao ovaj odabir. Pokušajte ponovno za nekoliko minuta.',
  accessRevokedTitle: 'Ova poveznica za pristup više nije aktivna',
  accessRevokedCopy:
      'Zatražite novu poveznicu od osobe koja vam ju je poslala kako biste nastavili rezervirati ova mjesta.',
  accessUnverifiedTitle: 'Nismo mogli potvrditi vaš pristup',
  accessUnverifiedCopy:
      'I dalje možete kupiti sve što je prikazano kao dostupno. Za pristup ostalome obratite se osobi koja vam je poslala poveznicu.',
  generalAdmission: 'Slobodan ulaz',
  numberOfGuests: 'Broj gostiju',
  chooseGuestsCopy:
      'Odaberite koliko gostiju sjedi zajedno. Ovaj se stol rezervira isključivo za vaše društvo.',
  fewerGuests: 'Manje gostiju',
  moreGuests: 'Više gostiju',
  selectTable: 'Odaberi stol',
  updateTable: 'Ažuriraj stol',
  removeWord: 'Ukloni',
  floorWord: 'Kat',
  totalWord: 'Ukupno',
  adjustSelection: 'Prilagodi odabir mjesta',
  backToSeatMap: 'Natrag na plan mjesta',
  chooseSeats: 'Odaberite svoja mjesta',
  chooseTickets: 'Odaberite ulaznice',
  placeWord: 'MJESTO',
  guestsWord: 'Gosti',
  tableWord: 'Stol',
  ticketWord: 'Ulaznica',
  passport: 'Profil mjesta',
  venue3D: '3D',
  venueZone: 'Zona prostora',
  venueMapHint:
      'Mjesta se biraju kontrolama oko plana: trakom s cijenama iznad njega, kontrolama sektora ispod njega i pločom s ulaznicama na dnu.',
  previousSeat: 'Prethodno mjesto',
  nextSeat: 'Sljedeće mjesto',
  orbitMode: 'Rotiraj prostor',
  panMode: 'Pomakni prostor',
  openInteractive3dVenue: 'Otvori interaktivni 3D prikaz prostora',
  showSeatsFor: 'PRIKAŽI MJESTA ZA',
  accessJumpFirstSection: 'Idi na prvi sektor',
  accessJumpNextSection: 'Idi na sljedeći sektor',
  fewerTickets: 'Manje ulaznica',
  moreTickets: 'Više ulaznica',
  addTickets: 'Dodaj ulaznice',
  noSelectableSeats: 'Trenutno nema dostupnih mjesta za odabir.',
  confirmYourTickets: 'Potvrdi ulaznice',
  seatsSecuredOpeningCheckout: 'Mjesta su osigurana. Otvaramo plaćanje…',
  holdInCheckoutTitle: 'Plaćanje vaših mjesta već je u tijeku',
  holdInCheckoutBody:
      'Dovršite plaćanje kako biste ih zadržali. Za odabir drugih mjesta najprije oslobodite ova — vraćaju se u prodaju.',
  releaseAndChangeSeats: 'Oslobodi i promijeni mjesta',
  holdAlreadyHeldTitle: 'Vaša su mjesta već rezervirana',
  holdAlreadyHeldBody: 'Nastavite na plaćanje kako biste ih zadržali.',
  accessExpiredTitle: 'Vaša je sesija odabira mjesta istekla',
  accessExpiredCopy:
      'Ponovno učitajte plan mjesta za nastavak. Mjesta koja su već u vašoj košarici ostaju rezervirana dok ne istekne odbrojavanje.',
  dismissError: 'Zatvori obavijest o pogrešci',
  testModeLong: 'Testni način · ništa se ne rezervira',
  seatRemoved: 'Ulaznica uklonjena',
  reloadSeatMap: 'Ponovno učitaj plan mjesta',
  accessNeeds: <String, String>{
    'wheelchair': 'Mjesto za kolica',
    'companion': 'Mjesto za pratnju',
    'semi-ambulatory': 'Ograničena pokretljivost',
    'designated-aisle': 'Prolaz / premještaj',
    'step-free': 'Bez stepenica',
    'hearing': 'Pomoć pri slušanju',
    'cart': 'Titlovi uživo',
    'sign-language': 'Znakovni jezik',
    'low-vision': 'Slabovidnost',
    'sensory-friendly': 'Osjetilno prilagođeno',
    'plus-size': 'Šire mjesto',
    'lift-armrest': 'Podizni naslon za ruku',
  },
  seatsLeft: _seatsLeftHr,
  moreCount: _moreCountHr,
  addMinutes: _addMinutesHr,
  fromPrice: _fromPriceHr,
  sightline: _sightlineHr,
  secureMoreAndCheckout: _secureMoreAndCheckoutHr,
  accessFreeCount: _accessFreeCountHr,
  seatJustTakenByAnother: _seatJustTakenByAnotherHr,
  labelNoLongerAvailable: _labelNoLongerAvailableHr,
  labelsNoLongerAvailable: _labelsNoLongerAvailableHr,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherHr,
  maxTicketsForOrder: _maxTicketsForOrderHr,
  couldNotRemoveLabel: _couldNotRemoveLabelHr,
  peekSecured: _peekSecuredHr,
  venueMap: _venueMapHr,
  accessibleStep: _accessibleStepHr,
  chooseMinMaxGuests: _chooseMinMaxGuestsHr,
  chooseMore: _chooseMoreHr,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeHr,
  accessNeedWithCount: _accessNeedWithCountHr,
  ticketCount: _ticketCountHr,
  findBestSeats: _findBestSeatsHr,
  reselectSeats: _reselectSeatsHr,
  seatsFree: _seatsFreeHr,
  seatsLeftInSection: _seatsLeftInSectionHr,
  holdLapsedStillFree: _holdLapsedStillFreeHr,
  holdLapsedSomeTaken: _holdLapsedSomeTakenHr,
  holdLapsedAllTaken: _holdLapsedAllTakenHr,
  accessibleSections: _accessibleSectionsHr,
  placesAvailable: _placesAvailableHr,
  removeTickets: _removeTicketsHr,
  holdMinutesLeft: _holdMinutesLeftHr,
  holdSecondsLeft: _holdSecondsLeftHr,
  holdLapsedBody: _holdLapsedBodyHr,
  seatsNotRecovered: _seatsNotRecoveredHr,
  activeFilters: _activeFiltersHr,
  accessibilityFiltersActive: _accessibilityFiltersActiveHr,
  onlyLeft: _onlyLeftHr,
  maintenancePaused: _maintenancePausedHr,
  continueWithTotal: _continueWithTotalHr,
);
