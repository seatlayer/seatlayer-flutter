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

String _labelNoLongerAvailableEt(String label) =>
    '$label pole enam saadaval. Vali teine koht.';

String _labelsNoLongerAvailableEt(String labels) =>
    '$labels pole enam saadaval. Vali teine rühm.';

String _couldNotFindSeatsTogetherEt(int count) =>
    'Me ei leidnud $count kõrvuti kohta. Proovi vähem kohti või muud piletitüüpi.';

String _maxTicketsForOrderEt(int count) =>
    'Selle tellimuse jaoks saad valida kuni $count piletit.';

String _couldNotRemoveLabelEt(String label) =>
    '$label eemaldamine ebaõnnestus. Broneering on muutumatu.';

String _peekSecuredEt(int count, String total) =>
    '✓ $count kindlustatud · $total. Veel ei võeta tasu';

String _venueMapEt(String venue) => 'Istekohtade plaan: $venue';

String _accessibleStepEt(int index, int total) => '$index/$total';

String _chooseMinMaxGuestsEt(int min, int max) =>
    'Vali $min kuni $max külalist.';

String _chooseMoreEt(int count) => 'Vali veel $count';

String _seatsHeldForNeedMoreTimeEt(String time) =>
    'Sinu kohad on broneeritud veel $time. Vajad rohkem aega?';

String _accessNeedWithCountEt(String need, int count) => '$need · $count';

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

String _accessibleSectionsEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => '$count sektor',
      _ => '$count sektorit',
    };

String _placesAvailableEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Praegu on saadaval $count koht',
      _ => 'Praegu on saadaval $count kohta',
    };

String _removeTicketsEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Eemalda $count pilet',
      _ => 'Eemalda $count piletit',
    };

String _holdMinutesLeftEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Jäänud $count minut',
      _ => 'Jäänud $count minutit',
    };

String _holdSecondsLeftEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Jäänud $count sekund',
      _ => 'Jäänud $count sekundit',
    };

String _holdLapsedBodyEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => 'Need olid broneeritud $count minutiks.',
      _ => 'Need olid broneeritud $count minutiks.',
    };

String _seatsNotRecoveredEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => '$count kohta ei õnnestunud taastada',
      _ => '$count kohta ei õnnestunud taastada',
    };

String _activeFiltersEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => '$count filter',
      _ => '$count filtrit',
    };

String _accessibilityFiltersActiveEt(int count) =>
    switch (pickerPluralCategory('et', count)) {
      PickerPluralCategory.one => '$count ligipääsetavusfilter on sees',
      _ => '$count ligipääsetavusfiltrit on sees',
    };

String _onlyLeftEt(int count) => switch (pickerPluralCategory('et', count)) {
  PickerPluralCategory.one => 'Jäänud $count koht',
  _ => 'Jäänud $count kohta',
};

String _maintenancePausedEt(int count) => switch (pickerPluralCategory(
  'et',
  count,
)) {
  PickerPluralCategory.one =>
    'Broneerimine on hoolduse ajaks peatatud. Proovi uuesti umbes $count minuti pärast.',
  _ =>
    'Broneerimine on hoolduse ajaks peatatud. Proovi uuesti umbes $count minuti pärast.',
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
  testMode: 'Testrežiim',
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
  viewGroupTitle: 'VAADE',
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
  ticketPrices: 'Piletihinnad',
  yourSeats: 'Sinu kohad',
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
  ticketTypeSoldOut: 'See piletitüüp on välja müüdud. Proovi muud tüüpi.',
  seatsNoLongerAvailableTryAnother:
      'Need kohad pole enam saadaval. Proovi teist kogust või piletitüüpi.',
  companionPairRequired:
      'Vali iga saatja pileti juurde kõrvalasuv ratastoolikoht.',
  ticketOptionNotApplicable:
      'See piletivalik pole valitud koha jaoks saadaval.',
  maintenancePausedShortly:
      'Broneerimine on hoolduse tõttu mõneks minutiks peatatud. Proovi varsti uuesti.',
  guestsOnly: 'See üritus on kutsutud külalistele.',
  guestChoiceClosed: 'Kohtade valik ei ole praegu avatud.',
  maxOneTicketForOrder: 'Selle tellimuse jaoks saad valida kuni 1 pileti.',
  tooManyAttempts: 'Liiga palju katseid. Oodake hetk ja proovige uuesti.',
  seatHeldForRenewal:
      'Üks neist kohtadest on hoitud hooajapileti omanikule, kes saab selle veel pikendada. Vali muu koht.',
  seatUnavailable: 'See koht pole saadaval.',
  eventUnavailable: 'Pileteid ei saa siin praegu broneerida.',
  savedSeatsNotRestored:
      'Teie varasemaid kohti ei õnnestunud taastada. Palun valige uuesti.',
  allSetTitle: 'Kõik on valmis',
  confirmedAndOnWay: 'kinnitatud. Kinnitus on teel.',
  backToMap: 'Tagasi plaanile',
  mapDidNotLoad: 'Istekohtade plaan ei laadinud',
  checkConnection: 'Kontrolli ühendust ja proovi uuesti.',
  offline: 'Oled võrguühenduseta',
  backOnline: 'Taas võrgus',
  stillHeld: 'Sinu kohad on endiselt broneeritud.',
  updating: 'Uuendame…',
  takingLonger: 'See võtab tavalisest kauem aega. Palun oota…',
  loadingTakingLonger:
      'Istekohtade plaani laadimine võtab tavalisest kauem. Palun oota…',
  couldNotReachCheckout: 'Kassaga ei õnnestunud ühendust saada.',
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
  adjustSelection: 'Kohanda kohtade valikut',
  backToSeatMap: 'Tagasi istekohtade plaanile',
  chooseSeats: 'Vali oma kohad',
  chooseTickets: 'Vali piletid',
  placeWord: 'KOHT',
  guestsWord: 'Külalised',
  tableWord: 'Laud',
  ticketWord: 'Pilet',
  passport: 'Koha profiil',
  venue3D: '3D',
  venueZone: 'Toimumiskoha tsoon',
  venueMapHint:
      'Kohti valitakse plaani ümber olevate juhtnuppudega: hinnariba selle kohal, sektorite juhtnupud selle all ja piletipaneel allservas.',
  previousSeat: 'Eelmine koht',
  nextSeat: 'Järgmine koht',
  orbitMode: 'Pööra toimumiskohta',
  panMode: 'Liiguta toimumiskohta',
  openInteractive3dVenue: 'Ava toimumiskoha interaktiivne 3D-vaade',
  showSeatsFor: 'NÄITA SOBIVAID KOHTI',
  accessJumpFirstSection: 'Mine esimesse sektorisse',
  accessJumpNextSection: 'Mine järgmisse sektorisse',
  fewerTickets: 'Vähem pileteid',
  moreTickets: 'Rohkem pileteid',
  addTickets: 'Lisa piletid',
  noSelectableSeats: 'Praegu pole valitavaid kohti saadaval.',
  confirmYourTickets: 'Kinnita oma piletid',
  seatsSecuredOpeningCheckout: 'Kohad on kindlustatud. Avame makse…',
  holdInCheckoutTitle: 'Sinu kohtade makse on juba pooleli',
  holdInCheckoutBody:
      'Lõpeta makse, et kohad endale jätta. Teiste kohtade valimiseks vabasta esmalt need — need lähevad tagasi müüki.',
  releaseAndChangeSeats: 'Vabasta ja vaheta kohad',
  holdAlreadyHeldTitle: 'Sinu kohad on juba broneeritud',
  holdAlreadyHeldBody: 'Jätka maksmisega, et need endale jätta.',
  accessExpiredTitle: 'Sinu kohavaliku seanss aegus',
  accessExpiredCopy:
      'Jätkamiseks laadi istekohtade plaan uuesti. Ostukorvis olevad kohad jäävad broneerituks, kuni taimer lõpeb.',
  dismissError: 'Sulge veateade',
  testModeLong: 'Testrežiim · midagi ei broneerita',
  seatRemoved: 'Pilet eemaldatud',
  reloadSeatMap: 'Laadi istekohtade plaan uuesti',
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
  labelNoLongerAvailable: _labelNoLongerAvailableEt,
  labelsNoLongerAvailable: _labelsNoLongerAvailableEt,
  couldNotFindSeatsTogether: _couldNotFindSeatsTogetherEt,
  maxTicketsForOrder: _maxTicketsForOrderEt,
  couldNotRemoveLabel: _couldNotRemoveLabelEt,
  peekSecured: _peekSecuredEt,
  venueMap: _venueMapEt,
  accessibleStep: _accessibleStepEt,
  chooseMinMaxGuests: _chooseMinMaxGuestsEt,
  chooseMore: _chooseMoreEt,
  seatsHeldForNeedMoreTime: _seatsHeldForNeedMoreTimeEt,
  accessNeedWithCount: _accessNeedWithCountEt,
  ticketCount: _ticketCountEt,
  findBestSeats: _findBestSeatsEt,
  reselectSeats: _reselectSeatsEt,
  seatsFree: _seatsFreeEt,
  seatsLeftInSection: _seatsLeftInSectionEt,
  holdLapsedStillFree: _holdLapsedStillFreeEt,
  holdLapsedSomeTaken: _holdLapsedSomeTakenEt,
  holdLapsedAllTaken: _holdLapsedAllTakenEt,
  accessibleSections: _accessibleSectionsEt,
  placesAvailable: _placesAvailableEt,
  removeTickets: _removeTicketsEt,
  holdMinutesLeft: _holdMinutesLeftEt,
  holdSecondsLeft: _holdSecondsLeftEt,
  holdLapsedBody: _holdLapsedBodyEt,
  seatsNotRecovered: _seatsNotRecoveredEt,
  activeFilters: _activeFiltersEt,
  accessibilityFiltersActive: _accessibilityFiltersActiveEt,
  onlyLeft: _onlyLeftEt,
  maintenancePaused: _maintenancePausedEt,
  continueWithTotal: _continueWithTotalEt,
);
