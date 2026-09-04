// GENERATED — do not edit.
//
// Source: design/locale_strings.json (lv)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftLv(int count) => 'Atlicis $count';

String _moreCountLv(int count) => '+$count vairāk';

String _addMinutesLv(int minutes) => '+$minutes min';

String _fromPriceLv(String money) => 'No $money';

String _sightlineLv(String metres) => '≈ $metres m līdz skatuvei';

String _ticketCountLv(int count) =>
    count == 1 ? '$count biļete' : '$count biļetes';

String _findBestSeatsLv(int count) =>
    count == 1 ? 'Atrast $count labāko vietu' : 'Atrast $count labākās vietas';

String _reselectSeatsLv(int count) =>
    count == 1 ? 'Izvēlēties to vēlreiz' : 'Izvēlēties tās vēlreiz';

String _continueWithTotalLv(String money) => 'Turpināt \u00b7 $money';

/// The `lv` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsLv = SeatLayerPickerStrings(
  close: 'Aizvērt',
  overview: 'Norises vieta',
  backToVenue: 'Atpakaļ uz norises vietu',
  cancel: 'Atcelt',
  select: 'Izvēlēties',
  viewFromHere: 'Skats no šejienes',
  openVenue360: 'Atvērt norises vietu 360°',
  recentre: 'Atkal centrēt uz skatuvi',
  viewFromYourSeat: 'skats no jūsu vietas',
  emptyTrayHint:
      'Pieskarieties vietai plānā vai ļaujiet mums izvēlēties labākās pieejamās jums.',
  anyTicketType: 'Jebkurš biļetes veids',
  anyVenueZone: 'Jebkura zona',
  bestSeats: 'Labākās vietas',
  showLess: 'Rādīt mazāk',
  undo: 'Atsaukt',
  holdAndCheckout: 'Rezervēt vietas un maksāt',
  poweredBy: 'Darbojas ar SeatLayer',
  testMode: 'TESTA REŽĪMS',
  accessibility: 'Pieejamības un krāsu iestatījumi',
  accessibilityTitle: 'Pieejamības un krāsu iestatījumi',
  fitVenue: 'Pielāgot ekrānam',
  loading: 'Ielādējam vietu plānu…',
  errorMessage: 'Vietu plāns neielādējās',
  retry: 'Mēģināt vēlreiz',
  accessRefresh: 'Pārlādēt',
  hideLimitedView: 'Paslēpt vietas ar ierobežotu skatu',
  colorblindSafe: 'Daltoniķiem draudzīgas krāsas',
  continueWord: 'Turpināt',
  seatsLeft: _seatsLeftLv,
  moreCount: _moreCountLv,
  addMinutes: _addMinutesLv,
  fromPrice: _fromPriceLv,
  sightline: _sightlineLv,
  ticketCount: _ticketCountLv,
  findBestSeats: _findBestSeatsLv,
  reselectSeats: _reselectSeatsLv,
  continueWithTotal: _continueWithTotalLv,
);
