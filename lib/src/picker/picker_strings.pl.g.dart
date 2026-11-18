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

String _peekSecuredPl(int count, String total) =>
    '✓ $count zabezpieczone · $total. Jeszcze nic nie pobierzemy';

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
  testMode: 'TRYB TESTOWY',
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
  peekSecured: _peekSecuredPl,
  ticketCount: _ticketCountPl,
  findBestSeats: _findBestSeatsPl,
  reselectSeats: _reselectSeatsPl,
  seatsFree: _seatsFreePl,
  seatsLeftInSection: _seatsLeftInSectionPl,
  holdLapsedStillFree: _holdLapsedStillFreePl,
  holdLapsedSomeTaken: _holdLapsedSomeTakenPl,
  holdLapsedAllTaken: _holdLapsedAllTakenPl,
  continueWithTotal: _continueWithTotalPl,
);
