// GENERATED — do not edit.
//
// Source: design/locale_strings.json (pl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftPl(int count) => 'Zostało $count';

String _moreCountPl(int count) => '+$count więcej';

String _addMinutesPl(int minutes) => '+$minutes min';

String _fromPricePl(String money) => 'Od $money';

String _sightlinePl(String metres) => '≈ $metres m do sceny';

String _secureMoreAndCheckoutPl(int count) =>
    'Zabezpiecz jeszcze $count i zapłać';

String _accessFreeCountPl(int count) => 'Wolne: $count';

String _seatJustTakenByAnotherPl(String label) =>
    'Miejsce $label właśnie zajął inny kupujący.';

String _labelNoLongerAvailablePl(String label) =>
    '$label nie jest już dostępne. Wybierz inne miejsce.';

String _labelsNoLongerAvailablePl(String labels) =>
    '$labels nie są już dostępne. Wybierz inną grupę.';

String _couldNotFindSeatsTogetherPl(int count) =>
    'Nie znaleźliśmy $count miejsc obok siebie. Spróbuj mniejszej liczby miejsc lub innego rodzaju biletu.';

String _couldNotRemoveLabelPl(String label) =>
    'Nie udało się usunąć $label. Rezerwacja pozostaje bez zmian.';

String _peekSecuredPl(int count, String total) =>
    '✓ $count zabezpieczone · $total. Jeszcze nic nie pobierzemy';

String _venueMapPl(String venue) => 'Plan miejsc: $venue';

String _accessibleStepPl(int index, int total) => '$index z $total';

String _chooseMinMaxGuestsPl(int min, int max) =>
    'Wybierz od $min do $max gości.';

String _chooseMorePl(int count) => 'Wybierz jeszcze $count';

String _seatsHeldForNeedMoreTimePl(String time) =>
    'Twoje miejsca są zarezerwowane jeszcze przez $time. Potrzebujesz więcej czasu?';

String _accessNeedWithCountPl(String need, int count) => '$need · $count';

String _ticketCountPl(int count) => switch (pickerPluralCategory('pl', count)) {
  PickerPluralCategory.one => '$count bilet',
  PickerPluralCategory.few => '$count bilety',
  PickerPluralCategory.many => '$count biletów',
  _ => '$count biletu',
};

String _findBestSeatsPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Znajdź $count najlepsze miejsce',
      PickerPluralCategory.few => 'Znajdź $count najlepsze miejsca',
      PickerPluralCategory.many => 'Znajdź $count najlepszych miejsc',
      _ => 'Znajdź $count najlepszego miejsca',
    };

String _reselectSeatsPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Wybierz je ponownie',
      PickerPluralCategory.few => 'Wybierz je ponownie',
      PickerPluralCategory.many => 'Wybierz je ponownie',
      _ => 'Wybierz je ponownie',
    };

String _seatsFreePl(int count) => switch (pickerPluralCategory('pl', count)) {
  PickerPluralCategory.one => '$count miejsce',
  PickerPluralCategory.few => '$count miejsca',
  PickerPluralCategory.many => '$count miejsc',
  _ => '$count miejsca',
};

String _seatsLeftInSectionPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Zostało $count miejsce',
      PickerPluralCategory.few => 'Zostały $count miejsca',
      PickerPluralCategory.many => 'Zostało $count miejsc',
      _ => 'Zostało $count miejsca',
    };

String _holdLapsedStillFreePl(int count) => switch (pickerPluralCategory(
  'pl',
  count,
)) {
  PickerPluralCategory.one =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności. To miejsce jest nadal wolne.',
  PickerPluralCategory.few =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności. Te miejsca są nadal wolne.',
  PickerPluralCategory.many =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności. Te miejsca są nadal wolne.',
  _ =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności. Te miejsca są nadal wolne.',
};

String _holdLapsedSomeTakenPl(int count) => switch (pickerPluralCategory(
  'pl',
  count,
)) {
  PickerPluralCategory.one =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a $count z tych miejsc zostało już zajęte. Pozostałe są nadal wolne.',
  PickerPluralCategory.few =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a $count z tych miejsc zostały już zajęte. Pozostałe są nadal wolne.',
  PickerPluralCategory.many =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a $count z tych miejsc zostało już zajętych. Pozostałe są nadal wolne.',
  _ =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a $count z tych miejsc zostało już zajętych. Pozostałe są nadal wolne.',
};

String _holdLapsedAllTakenPl(int count) => switch (pickerPluralCategory(
  'pl',
  count,
)) {
  PickerPluralCategory.one =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a to miejsce zostało już zajęte.',
  PickerPluralCategory.few =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a te miejsca zostały już zajęte.',
  PickerPluralCategory.many =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a te miejsca zostały już zajęte.',
  _ =>
    'Twoja rezerwacja wygasła podczas Twojej nieobecności, a te miejsca zostały już zajęte.',
};

String _accessibleSectionsPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => '$count sektor',
      PickerPluralCategory.few => '$count sektory',
      PickerPluralCategory.many => '$count sektorów',
      _ => '$count sektora',
    };

String _placesAvailablePl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Obecnie dostępne jest $count miejsce',
      PickerPluralCategory.few => 'Obecnie dostępne są $count miejsca',
      PickerPluralCategory.many => 'Obecnie dostępnych jest $count miejsc',
      _ => 'Obecnie dostępne jest $count miejsca',
    };

String _removeTicketsPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Usuń $count bilet',
      PickerPluralCategory.few => 'Usuń $count bilety',
      PickerPluralCategory.many => 'Usuń $count biletów',
      _ => 'Usuń $count biletu',
    };

String _holdMinutesLeftPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Została $count minuta',
      PickerPluralCategory.few => 'Zostały $count minuty',
      PickerPluralCategory.many => 'Zostało $count minut',
      _ => 'Zostało $count minuty',
    };

String _holdSecondsLeftPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Została $count sekunda',
      PickerPluralCategory.few => 'Zostały $count sekundy',
      PickerPluralCategory.many => 'Zostało $count sekund',
      _ => 'Zostało $count sekundy',
    };

String _holdLapsedBodyPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Były zarezerwowane przez $count minutę.',
      PickerPluralCategory.few => 'Były zarezerwowane przez $count minuty.',
      PickerPluralCategory.many => 'Były zarezerwowane przez $count minut.',
      _ => 'Były zarezerwowane przez $count minuty.',
    };

String _seatsNotRecoveredPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => 'Nie udało się odzyskać $count miejsca',
      PickerPluralCategory.few => 'Nie udało się odzyskać $count miejsc',
      PickerPluralCategory.many => 'Nie udało się odzyskać $count miejsc',
      _ => 'Nie udało się odzyskać $count miejsca',
    };

String _activeFiltersPl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => '$count filtr',
      PickerPluralCategory.few => '$count filtry',
      PickerPluralCategory.many => '$count filtrów',
      _ => '$count filtra',
    };

String _accessibilityFiltersActivePl(int count) =>
    switch (pickerPluralCategory('pl', count)) {
      PickerPluralCategory.one => '$count aktywny filtr dostępności',
      PickerPluralCategory.few => '$count aktywne filtry dostępności',
      PickerPluralCategory.many => '$count aktywnych filtrów dostępności',
      _ => '$count aktywnego filtra dostępności',
    };

String _onlyLeftPl(int count) => switch (pickerPluralCategory('pl', count)) {
  PickerPluralCategory.one => 'Zostało $count miejsce',
  PickerPluralCategory.few => 'Zostały $count miejsca',
  PickerPluralCategory.many => 'Zostało $count miejsc',
  _ => 'Zostało $count miejsca',
};

String _maintenancePausedPl(int count) => switch (pickerPluralCategory(
  'pl',
  count,
)) {
  PickerPluralCategory.one =>
    'Rezerwacja jest wstrzymana z powodu konserwacji. Spróbuj ponownie za około $count minutę.',
  PickerPluralCategory.few =>
    'Rezerwacja jest wstrzymana z powodu konserwacji. Spróbuj ponownie za około $count minuty.',
  PickerPluralCategory.many =>
    'Rezerwacja jest wstrzymana z powodu konserwacji. Spróbuj ponownie za około $count minut.',
  _ =>
    'Rezerwacja jest wstrzymana z powodu konserwacji. Spróbuj ponownie za około $count minuty.',
};

String _continueWithTotalPl(String money) => 'Dalej \u00b7 $money';

/// The `pl` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsPl = SeatLayerPickerStrings(
  close: 'Zamknij',
  overview: 'Obiekt',
  backToVenue: 'Wróć do obiektu',
  cancel: 'Anuluj',
  select: 'Wybierz',
  removeSeat: 'Usuń miejsce',
  viewFromHere: 'Widok stąd',
  openVenue360: 'Otwórz obiekt w 360°',
  recentre: 'Wyśrodkuj ponownie na scenie',
  viewFromYourSeat: 'widok z Twojego miejsca',
  emptyTrayHint:
      'Dotknij miejsca na planie albo pozwól nam wybrać dla Ciebie najlepsze dostępne.',
  anyTicketType: 'Dowolny rodzaj biletu',
  anyVenueZone: 'Dowolna strefa obiektu',
  bestSeats: 'Najlepsze miejsca',
  showLess: 'Pokaż mniej',
  undo: 'Cofnij',
  holdAndCheckout: 'Zarezerwuj miejsca i zapłać',
  poweredBy: 'Obsługiwane przez SeatLayer',
  testMode: 'Tryb testowy',
  accessibility: 'Dostępność i kolory',
  accessibilityTitle: 'Dostępność i kolory',
  fitVenue: 'Pokaż cały obiekt',
  fitWholeVenue: 'Pokaż cały obiekt',
  loading: 'Wczytywanie planu miejsc…',
  errorMessage: 'Plan miejsc się nie wczytał',
  retry: 'Spróbuj ponownie',
  accessRefresh: 'Odśwież',
  noSeatsSelected: 'Nie wybrano miejsc',
  findBestSeatsCta: 'Znajdź najlepsze miejsca',
  organizerNote: 'Notatka organizatora',
  accessiblePhysicalSeat: 'Dostępne miejsce fizyczne',
  emptyWheelchairSpace: 'Wolne miejsce dla wózka',
  findSeatsTogether: 'Znajdź miejsca obok siebie',
  aboutBestSeats: 'O znajdowaniu miejsc obok siebie',
  closestGroupChosenInstantly:
      'Najbliższa dostępna grupa, wybrana natychmiast.',
  hideLimitedView: 'Ukryj miejsca z ograniczoną widocznością',
  colorblindSafe: 'Kolory przyjazne daltonistom',
  notAvailable: 'Niedostępne',
  viewGroupTitle: 'WIDOK',
  restrictedView: 'Ograniczona widoczność',
  obstructedView: 'Zasłonięty widok',
  premiumSeat: 'Miejsce premium',
  continueWord: 'Dalej',
  allFloors: 'Wszystkie piętra',
  previousSection: 'Poprzedni sektor',
  nextSection: 'Następny sektor',
  addSeat: 'Dodaj miejsce',
  added: 'Dodano',
  sectionWord: 'Sektor',
  rowWord: 'Rząd',
  seatWord: 'Miejsce',
  seeItIn3D: 'Zobacz w 3D',
  viewFromThisSeat: 'Widok z tego miejsca',
  allPrices: 'Wszystkie ceny',
  ticketPrices: 'Ceny biletów',
  yourSeats: 'Twoje miejsca',
  ticketType: 'Rodzaj biletu',
  tierCompanionGuidance: 'Wymaga sąsiedniego miejsca dla wózka',
  findingBestSeats: 'Szukamy najlepszych miejsc…',
  findSeats: 'Znajdź miejsca',
  expandCart: 'Otwórz panel biletów',
  collapseCart: 'Zwiń panel biletów',
  continueToCheckout: 'Przejdź do płatności',
  secureMore: 'Zabezpiecz więcej',
  selectSeats: 'Wybierz miejsca',
  pickYourSeats: 'Wybierz swoje miejsca',
  salesClosedPill: 'Sprzedaż zamknięta',
  salesClosedCta: 'Sprzedaż zamknięta',
  confirmOrCancelSeat: 'Potwierdź lub anuluj to miejsce',
  securingSeats: 'Zabezpieczamy Twoje miejsca…',
  openingCheckout: 'Otwieramy bezpieczną płatność…',
  testModeExplained:
      'Rezerwacje tutaj nie są prawdziwe i nie pobierzemy żadnej karty',
  displayOptions: 'Opcje wyświetlania',
  companionSeatsNote: 'Sąsiednie miejsca dla opiekuna pozostają do wyboru',
  zoomIn: 'Powiększ',
  zoomOut: 'Pomniejsz',
  rotateVenue: 'Przeciągnij, aby obrócić obiekt',
  moveVenue: 'Przeciągnij, aby przesunąć obiekt',
  mapView: 'Plan',
  flat2dMap: 'Płaski plan 2D',
  interactive3dVenueView: 'Interaktywny widok obiektu w 3D',
  venueView: 'Widok obiektu',
  holdLapsedTitle: 'Twoje miejsca zostały zwolnione',
  salesClosed: 'Sprzedaż zamknięta',
  salesClosedCopy: 'Sprzedaż biletów na to wydarzenie została zakończona.',
  salesClosedToast: 'Sprzedaż na to wydarzenie jest zamknięta.',
  soldOutEyebrow: 'To wydarzenie',
  soldOutTitle: 'Wyprzedane',
  soldOutCopy:
      'Obecnie nie ma dostępnych miejsc numerowanych na to wydarzenie.',
  holdExpired:
      'Twoja rezerwacja wygasła. Miejsca zostały zwolnione. Wybierz ponownie.',
  addingEllipsis: 'Dodawanie…',
  moreTimeAdded: 'Dodano więcej czasu. Twoje miejsca są nadal zarezerwowane.',
  couldNotAddMoreTime: 'Nie udało się dodać czasu. Przejdź teraz do płatności.',
  seatsJustTaken: 'Jedno lub więcej miejsc właśnie zajęto. Wybierz ponownie.',
  ticketTypeSoldOut:
      'Ten rodzaj biletu jest wyprzedany. Spróbuj innego rodzaju biletu.',
  seatsNoLongerAvailableTryAnother:
      'Te miejsca nie są już dostępne. Spróbuj innej liczby lub innego rodzaju biletu.',
  companionPairRequired:
      'Do każdego biletu dla opiekuna wybierz sąsiednie miejsce dla wózka.',
  ticketOptionNotApplicable:
      'Ten rodzaj biletu nie jest dostępny dla wybranego miejsca.',
  maintenancePausedShortly:
      'Rezerwacja jest wstrzymana na kilka minut z powodu konserwacji. Spróbuj ponownie za chwilę.',
  guestsOnly: 'To wydarzenie jest dla zaproszonych gości.',
  guestChoiceClosed: 'Wybór miejsc nie jest teraz otwarty.',
  allSetTitle: 'Wszystko gotowe',
  confirmedAndOnWay: 'potwierdzone. Potwierdzenie jest w drodze.',
  backToMap: 'Wróć do planu',
  mapDidNotLoad: 'Plan miejsc się nie wczytał',
  checkConnection: 'Sprawdź połączenie i spróbuj ponownie.',
  accessPausedTitle: 'Te miejsca są w tej chwili zablokowane',
  accessPausedCopy:
      'Organizator wstrzymał ten wybór. Spróbuj ponownie za kilka minut.',
  accessRevokedTitle: 'Ten link dostępu nie jest już aktywny',
  accessRevokedCopy:
      'Poproś osobę, która przesłała Ci ten link, o nowy, aby dalej rezerwować te miejsca.',
  accessUnverifiedTitle: 'Nie udało się zweryfikować Twojego dostępu',
  accessUnverifiedCopy:
      'Nadal możesz zarezerwować wszystko, co jest oznaczone jako dostępne. Skontaktuj się z osobą, która przesłała Ci ten link, aby uzyskać dostęp do reszty.',
  generalAdmission: 'Wstęp wolny',
  numberOfGuests: 'Liczba gości',
  chooseGuestsCopy:
      'Wybierz, ilu gości usiądzie razem. Ten stolik jest zarezerwowany wyłącznie dla Twojej grupy.',
  fewerGuests: 'Mniej gości',
  moreGuests: 'Więcej gości',
  selectTable: 'Wybierz stolik',
  updateTable: 'Zaktualizuj stolik',
  removeWord: 'Usuń',
  floorWord: 'Piętro',
  totalWord: 'Razem',
  adjustSelection: 'Dostosuj wybór miejsc',
  backToSeatMap: 'Wróć do planu miejsc',
  chooseSeats: 'Wybierz swoje miejsca',
  chooseTickets: 'Wybierz bilety',
  placeWord: 'MIEJSCE',
  ticketWord: 'Bilet',
  passport: 'Profil miejsca',
  venue3D: '3D',
  venueZone: 'Strefa obiektu',
  venueMapHint:
      'Miejsca wybiera się za pomocą elementów wokół planu: paska cen nad nim, przycisków sektorów pod nim i panelu biletów na dole.',
  previousSeat: 'Poprzednie miejsce',
  nextSeat: 'Następne miejsce',
  orbitMode: 'Obróć obiekt',
  panMode: 'Przesuń obiekt',
  openInteractive3dVenue: 'Otwórz interaktywny widok obiektu w 3D',
  showSeatsFor: 'POKAŻ MIEJSCA:',
  accessJumpFirstSection: 'Przejdź do pierwszego sektora',
  accessJumpNextSection: 'Przejdź do następnego sektora',
  fewerTickets: 'Mniej biletów',
  moreTickets: 'Więcej biletów',
  addTickets: 'Dodaj bilety',
  noSelectableSeats: 'Obecnie nie ma miejsc dostępnych do wybrania.',
  confirmYourTickets: 'Potwierdź swoje bilety',
  seatsSecuredOpeningCheckout: 'Miejsca zabezpieczone. Otwieramy płatność…',
  holdInCheckoutTitle: 'Twoje miejsca są już w trakcie płatności',
  holdInCheckoutBody:
      'Dokończ płatność, aby je zatrzymać. Aby wybrać inne miejsca, najpierw zwolnij te — wrócą do sprzedaży.',
  releaseAndChangeSeats: 'Zwolnij i zmień miejsca',
  holdAlreadyHeldTitle: 'Twoje miejsca są już zarezerwowane',
  holdAlreadyHeldBody: 'Przejdź do płatności, aby je zatrzymać.',
  accessExpiredTitle: 'Twoja sesja wyboru miejsc wygasła',
  accessExpiredCopy:
      'Odśwież plan miejsc, aby kontynuować. Miejsca, które są już w koszyku, pozostają zarezerwowane, dopóki licznik czasu nie dobiegnie końca.',
  dismissError: 'Zamknij komunikat o błędzie',
  testModeLong: 'Tryb testowy · nic nie zostanie zarezerwowane',
  seatRemoved: 'Usunięto bilet',
  reloadSeatMap: 'Odśwież plan miejsc',
  accessNeeds: <String, String>{
    'wheelchair': 'Miejsce dla wózka',
    'companion': 'Miejsce dla opiekuna',
    'semi-ambulatory': 'Ograniczona sprawność',
    'designated-aisle': 'Przejście / przesiadka',
    'step-free': 'Bez schodów',
    'hearing': 'Wspomaganie słuchu',
    'cart': 'Napisy na żywo',
    'sign-language': 'Język migowy',
    'low-vision': 'Słabowidzenie',
    'sensory-friendly': 'Przyjazne sensorycznie',
    'plus-size': 'Szersze miejsce',
    'lift-armrest': 'Podnoszony podłokietnik',
  },
  seatsLeft: _seatsLeftPl,
  moreCount: _moreCountPl,
  addMinutes: _addMinutesPl,
  fromPrice: _fromPricePl,
  sightline: _sightlinePl,
  secureMoreAndCheckout: _secureMoreAndCheckoutPl,
  accessFreeCount: _accessFreeCountPl,
  seatJustTakenByAnother: _seatJustTakenByAnotherPl,
  labelNoLongerAvailable: _labelNoLongerAvailablePl,
  labelsNoLongerAvailable: _labelsNoLongerAvailablePl,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherPl,
  couldNotRemoveLabel: _couldNotRemoveLabelPl,
  peekSecured: _peekSecuredPl,
  venueMap: _venueMapPl,
  accessibleStep: _accessibleStepPl,
  chooseMinMaxGuests: _chooseMinMaxGuestsPl,
  chooseMore: _chooseMorePl,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimePl,
  accessNeedWithCount: _accessNeedWithCountPl,
  ticketCount: _ticketCountPl,
  findBestSeats: _findBestSeatsPl,
  reselectSeats: _reselectSeatsPl,
  seatsFree: _seatsFreePl,
  seatsLeftInSection: _seatsLeftInSectionPl,
  holdLapsedStillFree: _holdLapsedStillFreePl,
  holdLapsedSomeTaken: _holdLapsedSomeTakenPl,
  holdLapsedAllTaken: _holdLapsedAllTakenPl,
  accessibleSections: _accessibleSectionsPl,
  placesAvailable: _placesAvailablePl,
  removeTickets: _removeTicketsPl,
  holdMinutesLeft: _holdMinutesLeftPl,
  holdSecondsLeft: _holdSecondsLeftPl,
  holdLapsedBody: _holdLapsedBodyPl,
  seatsNotRecovered: _seatsNotRecoveredPl,
  activeFilters: _activeFiltersPl,
  accessibilityFiltersActive: _accessibilityFiltersActivePl,
  onlyLeft: _onlyLeftPl,
  maintenancePaused: _maintenancePausedPl,
  continueWithTotal: _continueWithTotalPl,
);
