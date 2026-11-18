// GENERATED — do not edit.
//
// Source: design/locale_strings.json (et)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.

import 'picker_plural_rules.dart';
import 'picker_strings.dart';

String _seatsLeftEt(int count) => 'Jäänud $count';

String _moreCountEt(int count) => '+$count veel';

String _addMinutesEt(int minutes) => '+$minutes min';

String _fromPriceEt(String money) => 'Alates $money';

String _sightlineEt(String metres) => '≈ $metres m laval';

String _secureMoreAndCheckoutEt(int count) => 'Kindlusta veel $count ja maksa';

String _accessFreeCountEt(int count) => '$count vaba';

String _seatJustTakenByAnotherEt(String label) =>
    'Koha $label võttis just teine ostja.';

String _peekSecuredEt(int count, String total) =>
    '✓ $count kindlustatud · $total. Veel ei võeta tasu';

String _ticketCountEt(int count) => switch (pickerPluralCategory('et', count)) {
  PickerPluralCategory.one => '$count pilet',
  _ => '$count piletit',
};

String _findBestSeatsEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Leia $count parim koht',
      _ => 'Leia $count parimat kohta',
    };

String _reselectSeatsEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Vali see uuesti',
      _ => 'Vali need uuesti',
    };

String _seatsFreeEt(int count) => switch (pickerPluralCategory('et', count)) {
  PickerPluralCategory.one => '$count koht',
  _ => '$count kohta',
};

String _seatsLeftInSectionEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Jäänud $count koht',
      _ => 'Jäänud $count kohta',
    };

String _holdLapsedStillFreeEt(int count) => switch (pickerPluralCategory(
  'et',
  count,
)) {
  PickerPluralCategory.one =>
    'Sinu broneering aegus, kui olid eemal. See koht on endiselt vaba.',
  _ => 'Sinu broneering aegus, kui olid eemal. Need kohad on endiselt vabad.',
};

String _holdLapsedSomeTakenEt(int count) => switch (pickerPluralCategory(
  'et',
  count,
)) {
  PickerPluralCategory.one =>
    'Sinu broneering aegus, kui olid eemal, ja $count neist kohtadest on juba hõivatud. Ülejäänud on endiselt vabad.',
  _ =>
    'Sinu broneering aegus, kui olid eemal, ja $count neist kohtadest on juba hõivatud. Ülejäänud on endiselt vabad.',
};

String _holdLapsedAllTakenEt(int count) => switch (pickerPluralCategory(
  'et',
  count,
)) {
  PickerPluralCategory.one =>
    'Sinu broneering aegus, kui olid eemal, ja see koht on juba hõivatud.',
  _ => 'Sinu broneering aegus, kui olid eemal, ja need kohad on juba hõivatud.',
};

String _continueWithTotalEt(String money) => 'Jätka \u00b7 $money';

/// The `et` defaults for the native picker chrome.
const SeatLayerPickerStrings seatLayerPickerStringsEt = SeatLayerPickerStrings(
  close: 'Sulge',
  overview: 'Toimumiskoht',
  backToVenue: 'Tagasi kohta',
  cancel: 'Tühista',
  select: 'Vali',
  removeSeat: 'Eemalda koht',
  viewFromHere: 'Vaade siit',
  openVenue360: 'Ava koht 360° vaates',
  recentre: 'Keskenda uuesti lavale',
  viewFromYourSeat: 'vaade sinu kohalt',
  emptyTrayHint:
      'Puuduta plaanil kohta või lase meil valida sulle parimad vabad kohad.',
  anyTicketType: 'Ükskõik milline piletitüüp',
  anyVenueZone: 'Ükskõik milline tsoon',
  bestSeats: 'Parimad kohad',
  showLess: 'Näita vähem',
  undo: 'Võta tagasi',
  holdAndCheckout: 'Broneeri kohad ja maksa',
  poweredBy: 'Töötab SeatLayeri baasil',
  testMode: 'TESTREŽIIM',
  accessibility: 'Ligipääsetavuse ja värvide valikud',
  accessibilityTitle: 'Ligipääsetavuse ja värvide valikud',
  fitVenue: 'Näita kogu toimumiskohta',
  fitWholeVenue: 'Näita kogu toimumiskohta',
  loading: 'Laadime istekohtade plaani…',
  errorMessage: 'Istekohtade plaan ei laadinud',
  retry: 'Proovi uuesti',
  accessRefresh: 'Värskenda',
  noSeatsSelected: 'Ühtki kohta pole valitud',
  findBestSeatsCta: 'Leia parimad kohad',
  organizerNote: 'Korraldaja märkus',
  accessiblePhysicalSeat: 'Ligipääsetav füüsiline koht',
  emptyWheelchairSpace: 'Vaba ratastoolikoht',
  findSeatsTogether: 'Otsi kõrvuti kohti',
  aboutBestSeats: 'Kõrvuti kohtade leidmisest',
  closestGroupChosenInstantly: 'Lähim vaba rühm, valitud kohe.',
  hideLimitedView: 'Peida piiratud vaatega kohad',
  colorblindSafe: 'Värvipimedasõbralikud värvid',
  notAvailable: 'Pole saadaval',
  restrictedView: 'Piiratud vaade',
  obstructedView: 'Varjatud vaade',
  premiumSeat: 'Premium-koht',
  continueWord: 'Jätka',
  allFloors: 'Kõik korrused',
  previousSection: 'Eelmine sektor',
  nextSection: 'Järgmine sektor',
  addSeat: 'Lisa koht',
  added: 'Lisatud',
  sectionWord: 'Sektor',
  rowWord: 'Rida',
  seatWord: 'Koht',
  seeItIn3D: 'Vaata 3D-s',
  viewFromThisSeat: 'Vaade sellelt kohalt',
  allPrices: 'Kõik hinnad',
  ticketType: 'Piletitüüp',
  tierCompanionGuidance: 'Nõuab kõrvalasuvat ratastoolikohta',
  findingBestSeats: 'Otsime parimaid kohti…',
  findSeats: 'Otsi kohti',
  expandCart: 'Ava piletipaneel',
  collapseCart: 'Ahenda piletipaneel',
  continueToCheckout: 'Jätka maksmisega',
  secureMore: 'Kindlusta rohkem',
  selectSeats: 'Vali kohad',
  pickYourSeats: 'Vali oma kohad',
  salesClosedPill: 'Müük on suletud',
  salesClosedCta: 'Müük on suletud',
  confirmOrCancelSeat: 'Kinnita või tühista see koht',
  securingSeats: 'Kindlustame sinu kohti…',
  openingCheckout: 'Avame turvalise makse…',
  testModeExplained: 'Broneeringud siin ei ole päris ja kaarti ei debiteerita',
  displayOptions: 'Kuvamise valikud',
  companionSeatsNote: 'Kõrvalasuvad saatjakohad jäävad valitavaks',
  zoomIn: 'Suurenda',
  zoomOut: 'Vähenda',
  rotateVenue: 'Lohista toimumiskoha pööramiseks',
  moveVenue: 'Lohista toimumiskoha liigutamiseks',
  mapView: 'Plaan',
  flat2dMap: 'Lame 2D-plaan',
  interactive3dVenueView: 'Interaktiivne 3D-vaade kohast',
  venueView: 'Koha vaade',
  holdLapsedTitle: 'Teie kohad vabastati',
  salesClosed: 'Müük on suletud',
  salesClosedCopy: 'Selle sündmuse piletimüük on lõppenud.',
  salesClosedToast: 'Selle sündmuse müük on suletud.',
  soldOutEyebrow: 'See sündmus',
  soldOutTitle: 'Välja müüdud',
  soldOutCopy: 'Selle sündmuse jaoks pole praegu vabu nummerdatud kohti.',
  holdExpired: 'Sinu broneering aegus. Kohad vabastati. Vali uuesti.',
  addingEllipsis: 'Lisame…',
  moreTimeAdded: 'Aega lisati. Sinu kohad on endiselt broneeritud.',
  couldNotAddMoreTime: 'Aega ei õnnestunud lisada. Mine kohe maksma.',
  seatsJustTaken: 'Üks või mitu kohta võeti just ära. Palun vali uuesti.',
  allSetTitle: 'Kõik on valmis',
  confirmedAndOnWay: 'kinnitatud. Kinnitus on teel.',
  backToMap: 'Tagasi plaanile',
  mapDidNotLoad: 'Istekohtade plaan ei laadinud',
  checkConnection: 'Kontrolli ühendust ja proovi uuesti.',
  accessPausedTitle: 'Need kohad on praegu broneeritud',
  accessPausedCopy:
      'Korraldaja on selle valiku peatanud. Proovi mõne minuti pärast uuesti.',
  accessRevokedTitle: 'See juurdepääsulink ei ole enam aktiivne',
  accessRevokedCopy:
      'Küsi uus link sellelt, kes selle sulle saatis, et neid kohti edasi broneerida.',
  accessUnverifiedTitle: 'Me ei suutnud sinu juurdepääsu kinnitada',
  accessUnverifiedCopy:
      'Saad endiselt osta kõike, mis on kuvatud saadaolevana. Ülejäänule juurdepääsuks võta ühendust sellega, kes sind siia saatis.',
  generalAdmission: 'Vaba sissepääs',
  numberOfGuests: 'Külaliste arv',
  chooseGuestsCopy:
      'Vali, mitu külalist koos istub. See laud broneeritakse ainult sinu seltskonnale.',
  fewerGuests: 'Vähem külalisi',
  moreGuests: 'Rohkem külalisi',
  selectTable: 'Vali laud',
  updateTable: 'Uuenda lauda',
  removeWord: 'Eemalda',
  floorWord: 'Korrus',
  totalWord: 'Kokku',
  accessNeeds: <String, String>{
    'wheelchair': 'Ratastoolikoht',
    'companion': 'Saatjakoht',
    'semi-ambulatory': 'Piiratud liikumisvõime',
    'designated-aisle': 'Vahekäik / ümberistumine',
    'step-free': 'Astmeteta',
    'hearing': 'Kuulmisabi',
    'cart': 'Reaalajas subtiitrid',
    'sign-language': 'Viipekeel',
    'low-vision': 'Vaegnägemine',
    'sensory-friendly': 'Meelesõbralik',
    'plus-size': 'Laiem koht',
    'lift-armrest': 'Ülestõstetav käetugi',
  },
  seatsLeft: _seatsLeftEt,
  moreCount: _moreCountEt,
  addMinutes: _addMinutesEt,
  fromPrice: _fromPriceEt,
  sightline: _sightlineEt,
  secureMoreAndCheckout: _secureMoreAndCheckoutEt,
  accessFreeCount: _accessFreeCountEt,
  seatJustTakenByAnother: _seatJustTakenByAnotherEt,
  peekSecured: _peekSecuredEt,
  ticketCount: _ticketCountEt,
  findBestSeats: _findBestSeatsEt,
  reselectSeats: _reselectSeatsEt,
  seatsFree: _seatsFreeEt,
  seatsLeftInSection: _seatsLeftInSectionEt,
  holdLapsedStillFree: _holdLapsedStillFreeEt,
  holdLapsedSomeTaken: _holdLapsedSomeTakenEt,
  holdLapsedAllTaken: _holdLapsedAllTakenEt,
  continueWithTotal: _continueWithTotalEt,
);
