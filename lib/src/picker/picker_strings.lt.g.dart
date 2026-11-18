// GENERATED — do not edit.
//
// Source: design/locale_strings.json (lt)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftLt(int count) => 'Liko $count';

String _moreCountLt(int count) => '+$count daugiau';

String _addMinutesLt(int minutes) => '+$minutes min';

String _fromPriceLt(String money) => 'Nuo $money';

String _sightlineLt(String metres) => '≈ $metres m iki scenos';

String _secureMoreAndCheckoutLt(int count) => 'Užtikrinti dar $count ir mokėti';

String _accessFreeCountLt(int count) => 'Laisvų: $count';

String _seatJustTakenByAnotherLt(String label) =>
    'Vietą $label ką tik užėmė kitas pirkėjas.';

String _peekSecuredLt(int count, String total) =>
    '✓ $count užtikrinta · $total. Kol kas nieko nenuskaičiuosime';

String _ticketCountLt(int count) => switch (pickerPluralCategory('lt', count)) {
  PickerPluralCategory.one => '$count bilietas',
  PickerPluralCategory.few => '$count bilietai',
  PickerPluralCategory.many => '$count bilieto',
  _ => '$count bilietų',
};

String _findBestSeatsLt(int count) =>
    switch (pickerPluralCategory('lt', count)) {
      PickerPluralCategory.one => 'Rasti $count geriausią vietą',
      PickerPluralCategory.few => 'Rasti $count geriausias vietas',
      PickerPluralCategory.many => 'Rasti $count geriausios vietos',
      _ => 'Rasti $count geriausių vietų',
    };

String _reselectSeatsLt(int count) =>
    switch (pickerPluralCategory('lt', count)) {
      PickerPluralCategory.one => 'Pasirinkti ją dar kartą',
      PickerPluralCategory.few => 'Pasirinkti jas dar kartą',
      PickerPluralCategory.many => 'Pasirinkti jas dar kartą',
      _ => 'Pasirinkti jas dar kartą',
    };

String _seatsFreeLt(int count) => switch (pickerPluralCategory('lt', count)) {
  PickerPluralCategory.one => '$count vieta',
  PickerPluralCategory.few => '$count vietos',
  PickerPluralCategory.many => '$count vietos',
  _ => '$count vietų',
};

String _seatsLeftInSectionLt(int count) =>
    switch (pickerPluralCategory('lt', count)) {
      PickerPluralCategory.one => 'Liko $count vieta',
      PickerPluralCategory.few => 'Liko $count vietos',
      PickerPluralCategory.many => 'Liko $count vietos',
      _ => 'Liko $count vietų',
    };

String _holdLapsedStillFreeLt(int count) => switch (pickerPluralCategory(
  'lt',
  count,
)) {
  PickerPluralCategory.one =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo. Ta vieta vis dar laisva.',
  PickerPluralCategory.few =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo. Tos vietos vis dar laisvos.',
  PickerPluralCategory.many =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo. Tos vietos vis dar laisvos.',
  _ => 'Jūsų rezervacija baigėsi, kol jūsų nebuvo. Tos vietos vis dar laisvos.',
};

String _holdLapsedSomeTakenLt(int count) => switch (pickerPluralCategory(
  'lt',
  count,
)) {
  PickerPluralCategory.one =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir $count iš tų vietų jau užimta. Likusios vis dar laisvos.',
  PickerPluralCategory.few =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir $count iš tų vietų jau užimtos. Likusios vis dar laisvos.',
  PickerPluralCategory.many =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir $count iš tų vietų jau užimtos. Likusios vis dar laisvos.',
  _ =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir $count iš tų vietų jau užimta. Likusios vis dar laisvos.',
};

String _holdLapsedAllTakenLt(int count) => switch (pickerPluralCategory(
  'lt',
  count,
)) {
  PickerPluralCategory.one =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir ta vieta jau užimta.',
  PickerPluralCategory.few =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir tos vietos jau užimtos.',
  PickerPluralCategory.many =>
    'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir tos vietos jau užimtos.',
  _ => 'Jūsų rezervacija baigėsi, kol jūsų nebuvo, ir tos vietos jau užimtos.',
};

String _continueWithTotalLt(String money) => 'Tęsti \u00b7 $money';

/// The `lt` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsLt = SeatLayerPickerStrings(
  close: 'Uždaryti',
  overview: 'Vieta',
  backToVenue: 'Atgal į vietą',
  cancel: 'Atšaukti',
  select: 'Pasirinkti',
  removeSeat: 'Pašalinti vietą',
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
  fitVenue: 'Rodyti visą renginio vietą',
  fitWholeVenue: 'Rodyti visą renginio vietą',
  loading: 'Įkeliamas vietų planas…',
  errorMessage: 'Vietų planas neįsikėlė',
  retry: 'Bandyti dar kartą',
  accessRefresh: 'Atnaujinti',
  noSeatsSelected: 'Vietų nepasirinkta',
  findBestSeatsCta: 'Rasti geriausias vietas',
  organizerNote: 'Organizatoriaus pastaba',
  accessiblePhysicalSeat: 'Pritaikyta fizinė vieta',
  emptyWheelchairSpace: 'Laisva vieta vežimėliui',
  findSeatsTogether: 'Rasti vietas greta',
  aboutBestSeats: 'Apie vietų šalia viena kitos paiešką',
  closestGroupChosenInstantly: 'Artimiausia laisva grupė, parinkta iškart.',
  hideLimitedView: 'Slėpti vietas su ribotu matomumu',
  colorblindSafe: 'Daltonikams pritaikytos spalvos',
  notAvailable: 'Negalima',
  restrictedView: 'Ribotas matomumas',
  obstructedView: 'Užstotas vaizdas',
  premiumSeat: 'Premium vieta',
  continueWord: 'Tęsti',
  allFloors: 'Visi aukštai',
  previousSection: 'Ankstesnis sektorius',
  nextSection: 'Kitas sektorius',
  addSeat: 'Pridėti vietą',
  added: 'Pridėta',
  sectionWord: 'Sektorius',
  rowWord: 'Eilė',
  seatWord: 'Vieta',
  seeItIn3D: 'Peržiūrėti 3D',
  viewFromThisSeat: 'Vaizdas iš šios vietos',
  allPrices: 'Visos kainos',
  ticketType: 'Bilieto tipas',
  tierCompanionGuidance: 'Reikalinga gretima vieta vežimėliui',
  findingBestSeats: 'Ieškome geriausių vietų…',
  findSeats: 'Rasti vietas',
  expandCart: 'Atverti bilietų skydelį',
  collapseCart: 'Sutraukti bilietų skydelį',
  continueToCheckout: 'Tęsti į mokėjimą',
  secureMore: 'Užtikrinti daugiau',
  selectSeats: 'Pasirinkti vietas',
  pickYourSeats: 'Pasirinkite savo vietas',
  salesClosedPill: 'Pardavimas uždarytas',
  salesClosedCta: 'Pardavimas uždarytas',
  confirmOrCancelSeat: 'Patvirtinkite arba atšaukite šią vietą',
  securingSeats: 'Užtikriname jūsų vietas…',
  openingCheckout: 'Atidaromas saugus mokėjimas…',
  testModeExplained: 'Užsakymai čia nėra tikri, jokia kortelė nenuskaičiuojama',
  displayOptions: 'Rodymo parinktys',
  companionSeatsNote: 'Greta esančios palydovo vietos lieka pasirenkamos',
  zoomIn: 'Priartinti',
  zoomOut: 'Atitolinti',
  rotateVenue: 'Vilkite, kad pasuktumėte renginio vietą',
  moveVenue: 'Vilkite, kad perkeltumėte renginio vietą',
  mapView: 'Planas',
  flat2dMap: 'Plokščias 2D planas',
  interactive3dVenueView: 'Interaktyvus 3D vietos vaizdas',
  venueView: 'Vietos vaizdas',
  holdLapsedTitle: 'Jūsų vietos atlaisvintos',
  salesClosed: 'Pardavimas uždarytas',
  salesClosedCopy: 'Šio renginio bilietų pardavimas baigėsi.',
  salesClosedToast: 'Šio renginio pardavimas uždarytas.',
  soldOutEyebrow: 'Šis renginys',
  soldOutTitle: 'Išparduota',
  soldOutCopy: 'Šiuo metu šiam renginiui nėra laisvų numeruotų vietų.',
  holdExpired:
      'Jūsų rezervacija baigėsi. Vietos atlaisvintos. Rinkitės iš naujo.',
  addingEllipsis: 'Pridedama…',
  moreTimeAdded: 'Pridėta laiko. Jūsų vietos tebėra rezervuotos.',
  couldNotAddMoreTime: 'Nepavyko pridėti laiko. Pereikite prie mokėjimo dabar.',
  seatsJustTaken: 'Viena ar kelios vietos ką tik užimtos. Rinkitės iš naujo.',
  allSetTitle: 'Viskas paruošta',
  confirmedAndOnWay: 'patvirtinta. Patvirtinimas jau pakeliui.',
  backToMap: 'Atgal į planą',
  mapDidNotLoad: 'Vietų planas neįsikėlė',
  checkConnection: 'Patikrinkite ryšį ir bandykite dar kartą.',
  accessPausedTitle: 'Šios vietos šiuo metu rezervuotos',
  accessPausedCopy:
      'Organizatorius pristabdė šį pasirinkimą. Pabandykite po kelių minučių.',
  accessRevokedTitle: 'Ši prieigos nuoroda nebeaktyvi',
  accessRevokedCopy:
      'Paprašykite naujos nuorodos to, kas ją jums atsiuntė, kad galėtumėte toliau rezervuoti šias vietas.',
  accessUnverifiedTitle: 'Nepavyko patvirtinti jūsų prieigos',
  accessUnverifiedCopy:
      'Vis dar galite įsigyti viską, kas rodoma kaip laisva. Dėl prieigos prie kitų kreipkitės į tą, kas atsiuntė jums nuorodą.',
  generalAdmission: 'Laisvas įėjimas',
  numberOfGuests: 'Svečių skaičius',
  chooseGuestsCopy:
      'Pasirinkite, kiek svečių sėdės kartu. Šis stalas rezervuojamas tik jūsų kompanijai.',
  fewerGuests: 'Mažiau svečių',
  moreGuests: 'Daugiau svečių',
  selectTable: 'Pasirinkti stalą',
  updateTable: 'Atnaujinti stalą',
  removeWord: 'Pašalinti',
  floorWord: 'Aukštas',
  totalWord: 'Iš viso',
  accessNeeds: <String, String>{
    'wheelchair': 'Vieta vežimėliui',
    'companion': 'Palydovo vieta',
    'semi-ambulatory': 'Ribotas judrumas',
    'designated-aisle': 'Takas / persėdimas',
    'step-free': 'Be laiptelių',
    'hearing': 'Klausos pagalba',
    'cart': 'Tiesioginiai subtitrai',
    'sign-language': 'Gestų kalba',
    'low-vision': 'Silpnaregystė',
    'sensory-friendly': 'Jusliškai draugiška',
    'plus-size': 'Platesnė vieta',
    'lift-armrest': 'Pakeliamas porankis',
  },
  seatsLeft: _seatsLeftLt,
  moreCount: _moreCountLt,
  addMinutes: _addMinutesLt,
  fromPrice: _fromPriceLt,
  sightline: _sightlineLt,
  secureMoreAndCheckout: _secureMoreAndCheckoutLt,
  accessFreeCount: _accessFreeCountLt,
  seatJustTakenByAnother: _seatJustTakenByAnotherLt,
  peekSecured: _peekSecuredLt,
  ticketCount: _ticketCountLt,
  findBestSeats: _findBestSeatsLt,
  reselectSeats: _reselectSeatsLt,
  seatsFree: _seatsFreeLt,
  seatsLeftInSection: _seatsLeftInSectionLt,
  holdLapsedStillFree: _holdLapsedStillFreeLt,
  holdLapsedSomeTaken: _holdLapsedSomeTakenLt,
  holdLapsedAllTaken: _holdLapsedAllTakenLt,
  continueWithTotal: _continueWithTotalLt,
);
