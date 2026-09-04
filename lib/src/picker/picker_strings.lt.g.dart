// GENERATED — do not edit.
//
// Source: design/locale_strings.json (lt)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_strings.dart';

String _seatsLeftLt(int count) => 'Liko $count';

String _moreCountLt(int count) => '+$count daugiau';

String _addMinutesLt(int minutes) => '+$minutes min';

String _fromPriceLt(String money) => 'Nuo $money';

String _sightlineLt(String metres) => '≈ $metres m iki scenos';

String _ticketCountLt(int count) =>
    count == 1 ? '$count bilietas' : '$count bilietų';

String _findBestSeatsLt(int count) => count == 1
    ? 'Rasti $count geriausią vietą'
    : 'Rasti $count geriausių vietų';

String _reselectSeatsLt(int count) =>
    count == 1 ? 'Pasirinkti ją dar kartą' : 'Pasirinkti jas dar kartą';

String _continueWithTotalLt(String money) => 'Tęsti \u00b7 $money';

/// The `lt` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsLt = SeatLayerPickerStrings(
  close: 'Uždaryti',
  overview: 'Vieta',
  backToVenue: 'Atgal į vietą',
  cancel: 'Atšaukti',
  select: 'Pasirinkti',
  viewFromHere: 'Vaizdas iš čia',
  openVenue360: 'Atverti vietą 360°',
  recentre: 'Vėl centruoti į sceną',
  viewFromYourSeat: 'vaizdas iš jūsų vietos',
  emptyTrayHint:
      'Bakstelėkite vietą plane arba leiskite mums parinkti geriausias laisvas vietas.',
  anyTicketType: 'Bet koks bilieto tipas',
  anyVenueZone: 'Bet kuri zona',
  bestSeats: 'Geriausios vietos',
  showLess: 'Rodyti mažiau',
  undo: 'Atšaukti',
  holdAndCheckout: 'Rezervuoti vietas ir mokėti',
  poweredBy: 'Veikia su SeatLayer',
  testMode: 'BANDYMO REŽIMAS',
  accessibility: 'Prieinamumo ir spalvų parinktys',
  accessibilityTitle: 'Prieinamumo ir spalvų parinktys',
  fitVenue: 'Pritaikyti ekranui',
  loading: 'Įkeliamas vietų planas…',
  errorMessage: 'Vietų planas neįsikėlė',
  retry: 'Bandyti dar kartą',
  hideLimitedView: 'Slėpti vietas su ribotu matomumu',
  colorblindSafe: 'Daltonikams pritaikytos spalvos',
  continueWord: 'Tęsti',
  seatsLeft: _seatsLeftLt,
  moreCount: _moreCountLt,
  addMinutes: _addMinutesLt,
  fromPrice: _fromPriceLt,
  sightline: _sightlineLt,
  ticketCount: _ticketCountLt,
  findBestSeats: _findBestSeatsLt,
  reselectSeats: _reselectSeatsLt,
  continueWithTotal: _continueWithTotalLt,
);
