// GENERATED — do not edit.
//
// Source: design/locale_strings.json (pl)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftPl(int count) => 'Zostało $count';

String _moreCountPl(int count) => '+$count więcej';

String _fromPricePl(String money) => 'Od $money';

String _ticketCountPl(int count) =>
    count == 1 ? '$count bilet' : '$count biletu';

String _findBestSeatsPl(int count) => count == 1
    ? 'Znajdź $count najlepsze miejsce'
    : 'Znajdź $count najlepszego miejsca';

String _reselectSeatsPl(int count) =>
    count == 1 ? 'Wybierz je ponownie' : 'Wybierz je ponownie';

String _continueWithTotalPl(String money) => 'Dalej \u00b7 $money';

/// The `pl` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsPl = SeatLayerPickerStrings(
  close: 'Zamknij',
  overview: 'Obiekt',
  backToVenue: 'Wróć do obiektu',
  cancel: 'Anuluj',
  select: 'Wybierz',
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
  fitVenue: 'Dopasuj do ekranu',
  loading: 'Wczytywanie planu miejsc…',
  errorMessage: 'Plan miejsc się nie wczytał',
  retry: 'Spróbuj ponownie',
  hideLimitedView: 'Ukryj miejsca z ograniczoną widocznością',
  colorblindSafe: 'Kolory przyjazne daltonistom',
  seatsLeft: _seatsLeftPl,
  moreCount: _moreCountPl,
  fromPrice: _fromPricePl,
  ticketCount: _ticketCountPl,
  findBestSeats: _findBestSeatsPl,
  reselectSeats: _reselectSeatsPl,
  continueWithTotal: _continueWithTotalPl,
);
