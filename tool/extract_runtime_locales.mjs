// Rebuilds `design/locale_strings.json` from the SeatLayer runtime's own
// dictionaries.
//
//   node tool/extract_runtime_locales.mjs <SeatLayer runtime locale directory> <app strings locale directory>
//   node tool/extract_runtime_locales.mjs --plural-categories [--check]
//
// The second form needs no runtime source: it rewrites (or, with --check,
// compares) `test/fixtures/plural_categories.json`, the category
// `Intl.PluralRules` gives each shipped locale for a fixed list of counts. The
// runtime picks a counted sentence's form with `Intl.PluralRules`; the Dart
// rules in `lib/src/picker/picker_plural_rules.dart` are tested against that
// fixture so the two choose the same form for the same count. The first form
// writes the fixture too.
//
// The runtime already ships a translated dictionary per locale, reviewed by
// the same people who review the web picker's wording. Re-translating the same
// sentences on this side would drift, so the native chrome takes them from
// there — but through a file committed HERE, because a generator that reaches
// outside the package could not be checked by this package's own test suite.
//
// The second directory is the runtime's app strings: sentences only the app
// SDKs draw, one flat JSON object per locale, with counted sentences written
// as `<key>.<category>` families (see `APP_KEYS` below). Where both sources
// word the same string, the app strings win: they are written as the app
// picker draws them.
//
// Only the keys the native chrome actually renders are extracted. A Flutter
// string with no equivalent on the runtime side is simply absent, and keeps
// its English default at runtime.
import fs from 'node:fs';
import path from 'node:path';

import { appStringsProblems } from './app_strings_checks.mjs';

/** Flutter string key -> the runtime dictionary key it is taken from. */
const KEYS = {
  close: 'picker.close',
  overview: 'picker.overview',
  backToVenue: 'picker.backToVenue',
  cancel: 'common.cancel',
  select: 'picker.select',
  removeSeat: 'picker.removeSeat',
  viewFromHere: 'picker.viewFromHere',
  sightline: 'picker.sightline',
  openVenue360: 'picker.openAuthored360',
  recentre: 'picker.recentreOnStage',
  viewFromYourSeat: 'picker.viewFromYourSeat',
  emptyTrayHint: 'picker.trayHintTapOrBest',
  anyTicketType: 'picker.anyTicketType',
  anyVenueZone: 'picker.anyVenueZone',
  bestSeats: 'picker.bestSeatsPremium',
  findSeatsTogether: 'picker.findSeatsTogether',
  aboutBestSeats: 'picker.aboutBestSeats',
  closestGroupChosenInstantly: 'picker.closestGroupChosenInstantly',
  showLess: 'picker.showLess',
  undo: 'picker.undo',
  holdAndCheckout: 'picker.holdSeatsAndCheckout',
  poweredBy: 'picker.poweredBy',
  testMode: 'picker.testMode',
  accessibility: 'picker.accessibilityOptions',
  accessibilityTitle: 'picker.accessibilityOptions',
  // The runtime retired its own fit-to-screen wording along with the wide 2D
  // control that used to carry it; both surfaces that still frame a venue say
  // "Show whole venue".
  fitVenue: 'picker.fitWholeVenue',
  fitWholeVenue: 'picker.fitWholeVenue',
  loading: 'picker.loadingSeatMap',
  errorMessage: 'picker.mapDidNotLoad',
  retry: 'picker.accessRetry',
  accessRefresh: 'picker.accessRefresh',
  hideLimitedView: 'picker.hideLimitedView',
  notAvailable: 'picker.notAvailable',
  organizerNote: 'picker.organizerNote',
  emptyWheelchairSpace: 'picker.emptyWheelchairSpace',
  accessiblePhysicalSeat: 'picker.accessiblePhysicalSeat',
  restrictedView: 'picker.restrictedView',
  obstructedView: 'picker.obstructedView',
  premiumSeat: 'picker.premiumSeat',
  // The twelve accommodations, which the seat-note rows, the cart lines and
  // the accessibility sheet all name. Extracted per key and rebuilt into
  // `accessNeeds`.
  //
  // The SHORT name of each, not the taxonomy's own. `picker.access.*` is
  // written for a seat popup, where "Designated aisle / transfer seat" is the
  // honest length; every place this SDK prints a provision is a single line in
  // a narrow column, and the long names wrapped those lines onto two and three
  // each. The English defaults in `design/tokens.json` have always been the
  // short ones, so this is what makes the other locales agree with them.
  // `cart` is the CART live-caption provision, not a vehicle.
  'accessNeeds.wheelchair': 'picker.accessShort.wheelchair',
  'accessNeeds.companion': 'picker.accessShort.companion',
  'accessNeeds.semi-ambulatory': 'picker.accessShort.semi-ambulatory',
  'accessNeeds.designated-aisle': 'picker.accessShort.designated-aisle',
  'accessNeeds.step-free': 'picker.accessShort.step-free',
  'accessNeeds.hearing': 'picker.accessShort.hearing',
  'accessNeeds.cart': 'picker.accessShort.cart',
  'accessNeeds.sign-language': 'picker.accessShort.sign-language',
  'accessNeeds.low-vision': 'picker.accessShort.low-vision',
  'accessNeeds.sensory-friendly': 'picker.accessShort.sensory-friendly',
  'accessNeeds.plus-size': 'picker.accessShort.plus-size',
  'accessNeeds.lift-armrest': 'picker.accessShort.lift-armrest',
  colorblindSafe: 'picker.colorblindColors',
  continueWord: 'picker.continue',
  seatsLeft: 'picker.seatsLeftShort',
  fromPrice: 'picker.peekFromPrice',
  noSeatsSelected: 'picker.noSeatsSelected',
  findBestSeatsCta: 'picker.findBestSeats',
  moreCount: 'picker.moreCount',
  addMinutes: 'picker.addMinutes',
  'ticketCount.one': 'picker.ticketsCount.one',
  'ticketCount.other': 'picker.ticketsCount.other',
  'findBestSeats.one': 'picker.findBestSeatsCount.one',
  'findBestSeats.other': 'picker.findBestSeatsCount.other',
  'reselectSeats.one': 'picker.holdLapsedSelectAgain.one',
  'reselectSeats.other': 'picker.holdLapsedSelectAgain.other',
  // The scarcity count says what it counts, in the dictionary's own counted
  // sentence ("86 seats left"), the same one `seatsLeftInSection` takes.
  'onlyLeft.one': 'picker.seatsLeftInSection.one',
  'onlyLeft.other': 'picker.seatsLeftInSection.other',
  // Two facts joined with the locale's own separator: "Wheelchair · 2".
  // `{need}` fills `{first}` and `{count}` fills `{second}`; Japanese joins
  // them with "・".
  accessNeedWithCount: 'picker.releasedPair',

  // Sentences the native chrome prints that the runtime already words the
  // same way. Matched on meaning, not on key names: where the runtime's
  // English differs from this package's only in punctuation or an article
  // ("Drag to rotate the venue"), its translations are still of the same
  // sentence. Where it differs in meaning, nothing is taken, and the English
  // default stays.
  allFloors: 'picker.allFloors',
  previousSection: 'picker.previousSection',
  nextSection: 'picker.nextSection',
  addSeat: 'picker.addSeat',
  added: 'picker.added',
  sectionWord: 'picker.section',
  rowWord: 'picker.row',
  seatWord: 'picker.seat',
  seeItIn3D: 'picker.seeItIn3d',
  viewFromThisSeat: 'picker.viewFromThisSeat',
  allPrices: 'picker.allPrices',
  ticketPrices: 'picker.ticketPrices',
  yourSeats: 'picker.yourSeats',
  ticketType: 'picker.ticketType',
  tierCompanionGuidance: 'picker.companionRequiresWheelchair',
  findingBestSeats: 'picker.findingBestSeats',
  findSeats: 'picker.findSeats',
  expandCart: 'picker.openTicketPanel',
  collapseCart: 'picker.collapseTicketPanel',
  continueToCheckout: 'picker.continueToCheckout',
  secureMore: 'picker.secureMore',
  selectSeats: 'picker.selectSeats',
  pickYourSeats: 'picker.pickYourSeats',
  salesClosedPill: 'picker.salesClosedPill',
  secureMoreAndCheckout: 'picker.secureMoreAndCheckout',
  peekSecured: 'picker.peekSecured',
  salesClosedCta: 'picker.salesClosedCta',
  confirmOrCancelSeat: 'picker.confirmOrCancelSeat',
  securingSeats: 'picker.securingSeats',
  openingCheckout: 'picker.openingCheckout',
  testModeExplained: 'picker.testModeExplained',
  displayOptions: 'picker.displayOptions',
  companionSeatsNote: 'picker.companionSeatsNote',
  accessFreeCount: 'picker.accessFreeCount',
  zoomIn: 'picker.zoomIn',
  zoomOut: 'picker.zoomOut',
  rotateVenue: 'picker.dragToRotateVenue',
  moveVenue: 'picker.dragToMoveVenue',
  mapView: 'picker.map',
  flat2dMap: 'picker.flat2dMap',
  interactive3dVenueView: 'picker.interactive3dVenueView',
  venueView: 'picker.venueView',
  holdLapsedTitle: 'picker.holdExpiredTitle',
  'seatsLeftInSection.one': 'picker.seatsLeftInSection.one',
  'seatsLeftInSection.other': 'picker.seatsLeftInSection.other',
  'seatsFree.one': 'picker.seatCount.one',
  'seatsFree.other': 'picker.seatCount.other',
  salesClosed: 'picker.salesClosedPill',
  salesClosedCopy: 'picker.salesClosedCopy',
  salesClosedToast: 'picker.salesClosedToast',
  soldOutEyebrow: 'picker.soldOutEyebrow',
  soldOutTitle: 'picker.soldOutTitle',
  soldOutCopy: 'picker.soldOutCopy',
  holdExpired: 'picker.holdExpired',
  'holdLapsedStillFree.one': 'picker.holdLapsedStillFree.one',
  'holdLapsedStillFree.other': 'picker.holdLapsedStillFree.other',
  'holdLapsedSomeTaken.one': 'picker.holdLapsedSomeTaken.one',
  'holdLapsedSomeTaken.other': 'picker.holdLapsedSomeTaken.other',
  'holdLapsedAllTaken.one': 'picker.holdLapsedAllTaken.one',
  'holdLapsedAllTaken.other': 'picker.holdLapsedAllTaken.other',
  addingEllipsis: 'picker.addingEllipsis',
  moreTimeAdded: 'picker.moreTimeAdded',
  couldNotAddMoreTime: 'picker.couldNotAddMoreTime',
  seatJustTakenByAnother: 'picker.seatJustTakenByAnother',
  seatsJustTaken: 'picker.seatsJustTaken',
  // What a refused hold, finder or removal says. One sentence for one seat and
  // one for several; a dictionary with a single form has only `.other`, so the
  // one-seat sentence takes it there (see SINGLE_FORM below).
  labelNoLongerAvailable: 'picker.labelsNoLongerAvailable.one',
  labelsNoLongerAvailable: 'picker.labelsNoLongerAvailable.other',
  couldNotFindSeatsTogether: 'picker.couldNotFindSeatsTogether',
  ticketTypeSoldOut: 'picker.ticketTypeSoldOut',
  seatsNoLongerAvailableTryAnother: 'picker.seatsNoLongerAvailableTryAnother',
  companionPairRequired: 'picker.companionPairRequired',
  ticketOptionNotApplicable: 'picker.ticketOptionNotApplicable',
  couldNotRemoveLabel: 'picker.couldNotRemoveLabel',
  'maintenancePaused.one': 'picker.maintenancePaused.one',
  'maintenancePaused.other': 'picker.maintenancePaused.other',
  maintenancePausedShortly: 'picker.maintenancePausedShortly',
  guestsOnly: 'picker.guestsOnlyToast',
  guestChoiceClosed: 'picker.guestChoiceClosed',
  allSetTitle: 'picker.allSetTitle',
  confirmedAndOnWay: 'picker.confirmedAndOnWay',
  backToMap: 'picker.backToMap',
  mapDidNotLoad: 'picker.mapDidNotLoad',
  checkConnection: 'picker.checkConnection',
  accessPausedTitle: 'picker.accessPausedTitle',
  accessPausedCopy: 'picker.accessPausedBody',
  accessRevokedTitle: 'picker.accessRevokedTitle',
  accessRevokedCopy: 'picker.accessRevokedBody',
  accessUnverifiedTitle: 'picker.accessInvalidTitle',
  accessUnverifiedCopy: 'picker.accessInvalidBody',
  generalAdmission: 'picker.generalAdmission',
  numberOfGuests: 'picker.numberOfGuests',
  chooseGuestsCopy: 'picker.chooseGuestsCopy',
  fewerGuests: 'picker.fewerGuests',
  moreGuests: 'picker.moreGuests',
  selectTable: 'picker.selectTable',
  updateTable: 'picker.updateTable',
  removeWord: 'picker.gaRemove',
  floorWord: 'picker.floor',
  totalWord: 'picker.total',
  adjustSelection: 'picker.adjustSeatSelection',
  // Not in every runtime dictionary yet. A key a dictionary lacks is skipped
  // like any other, so the package keeps its English default for it until the
  // runtime's dictionaries carry it, and the next extraction then takes it.
  backToSeatMap: 'picker.backToSeatMap',
};

/** A key whose dictionary may have one form only -> the key that form is under. */
const SINGLE_FORM = {
  labelNoLongerAvailable: 'picker.labelsNoLongerAvailable.other',
};

/**
 * Flutter string key -> the app strings key it is taken from. A counted
 * sentence is named by its family; every category the locale's file has for
 * it is taken.
 */
const APP_KEYS = {
  chooseSeats: 'chooseSeats',
  chooseTickets: 'chooseTickets',
  placeWord: 'placeWord',
  ticketWord: 'ticketWord',
  passport: 'passport',
  venue3D: 'venue3D',
  venueZone: 'venueZone',
  venueMap: 'venueMap',
  venueMapHint: 'venueMapHint',
  previousSeat: 'previousSeat',
  nextSeat: 'nextSeat',
  orbitMode: 'orbitMode',
  panMode: 'panMode',
  openInteractive3dVenue: 'openInteractive3dVenue',
  viewGroupTitle: 'viewGroupTitle',
  showSeatsFor: 'showSeatsFor',
  accessibleStep: 'accessibleStep',
  accessibleSections: 'accessibleSections',
  accessJumpFirstSection: 'accessJumpFirstSection',
  accessJumpNextSection: 'accessJumpNextSection',
  fewerTickets: 'fewerTickets',
  moreTickets: 'moreTickets',
  addTickets: 'addTickets',
  placesAvailable: 'placesAvailable',
  chooseMinMaxGuests: 'chooseMinMaxGuests',
  noSelectableSeats: 'noSelectableSeats',
  chooseMore: 'chooseMore',
  removeTickets: 'removeTickets',
  confirmYourTickets: 'confirmYourTickets',
  seatsSecuredOpeningCheckout: 'seatsSecuredOpeningCheckout',
  seatsHeldForNeedMoreTime: 'seatsHeldForNeedMoreTime',
  holdMinutesLeft: 'holdMinutesLeft',
  holdSecondsLeft: 'holdSecondsLeft',
  holdLapsedBody: 'holdLapsedBody',
  seatsNotRecovered: 'seatsNotRecovered',
  holdInCheckoutTitle: 'holdInCheckoutTitle',
  holdInCheckoutBody: 'holdInCheckoutBody',
  releaseAndChangeSeats: 'releaseAndChangeSeats',
  holdAlreadyHeldTitle: 'holdAlreadyHeldTitle',
  holdAlreadyHeldBody: 'holdAlreadyHeldBody',
  accessExpiredTitle: 'accessExpiredTitle',
  accessExpiredCopy: 'accessExpiredCopy',
  dismissError: 'dismissError',
  activeFilters: 'activeFilters',
  accessibilityFiltersActive: 'accessibilityFiltersActive',
  seatRemoved: 'seatRemoved',
  reloadSeatMap: 'reloadSeatMap',
  // The app badge's own short word, in sentence case as drawn; the shared
  // `picker.testMode` is the web's capitals.
  testMode: 'testMode',
  testModeLong: 'testModeLong',
};

/**
 * App strings keys deliberately not taken. Each one says why.
 */
const IGNORED_APP_KEYS = [
  // The app's own screen-reader name for its test event; the picker names its
  // test badge with `testModeLong` instead.
  'testEventSemantics',
];

/** One locale file, evaluated as a module with its type annotation removed. */
async function readDictionary(file) {
  const code = fs
    .readFileSync(file, 'utf8')
    .replace(/^import[\s\S]*?;$/gm, '')
    // English spreads its Season page's texts in from a file of their own; the
    // picker draws none of them.
    .replace(/^\s*\.\.\.[A-Za-z0-9_$]+,$/gm, '')
    .replace(/export const\s+[A-Za-z0-9_$]+\s*:\s*Dict\s*=\s*/, 'export default ');
  const scratch = path.join(fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'sl-')), 'dict.mjs');
  fs.writeFileSync(scratch, code);
  try {
    return (await import(`file://${scratch}`)).default;
  } finally {
    fs.rmSync(path.dirname(scratch), { recursive: true, force: true });
  }
}

const PLURAL_FORMS = ['zero', 'one', 'two', 'few', 'many', 'other'];

/** The counts the plural fixture records: every case the rules distinguish. */
const PLURAL_COUNTS = [
  ...Array.from({ length: 201 }, (_, n) => n),
  1000, 1001, 1011, 1021, 1111, 1000000, 1000001, 1000021, 2000000, 10000000,
];

const FIXTURE = 'test/fixtures/plural_categories.json';

/** The fixture for [tags], as the file's text. */
function pluralFixture(tags) {
  const categories = {};
  for (const tag of tags) {
    const rules = new Intl.PluralRules(tag);
    categories[tag] = PLURAL_COUNTS.map((count) => rules.select(count));
  }
  // One line per locale: 43 lines a reviewer can read across, not ten
  // thousand lines of one word each.
  const text = (versions) =>
    [
      '{',
      '  "source": "Intl.PluralRules, as the SeatLayer runtime selects counted sentences",',
      ...Object.entries(versions).map(([key, value]) => `  ${JSON.stringify(key)}: ${JSON.stringify(value)},`),
      `  "counts": ${JSON.stringify(PLURAL_COUNTS)},`,
      '  "categories": {',
      Object.entries(categories)
        .map(([tag, list]) => `    ${JSON.stringify(tag)}: ${JSON.stringify(list)}`)
        .join(',\n'),
      '  }',
      '}',
      '',
    ].join('\n');
  return { categories, text };
}

const versions = {
  node: process.version,
  icu: process.versions.icu,
  cldr: process.versions.cldr,
};

function writePluralFixture(tags) {
  fs.mkdirSync(path.dirname(FIXTURE), { recursive: true });
  fs.writeFileSync(FIXTURE, pluralFixture(tags).text(versions));
  process.stdout.write(`wrote ${FIXTURE} (${tags.length} locales)\n`);
}

if (process.argv[2] === '--plural-categories') {
  const tags = Object.keys(
    JSON.parse(fs.readFileSync('design/locale_strings.json', 'utf8')).strings,
  ).sort();
  if (process.argv.includes('--check')) {
    // Only the categories are compared: the header names the Node and ICU
    // that wrote the file, and a newer one that agrees is not a stale file.
    const current = JSON.parse(fs.readFileSync(FIXTURE, 'utf8'));
    const wanted = pluralFixture(tags).categories;
    const same =
      JSON.stringify(current.counts) === JSON.stringify(PLURAL_COUNTS) &&
      JSON.stringify(current.categories) === JSON.stringify(wanted);
    if (!same) {
      process.stderr.write(
        `${FIXTURE} is stale. Run \`node tool/extract_runtime_locales.mjs --plural-categories\`.\n`,
      );
      process.exit(1);
    }
    process.stdout.write(`${FIXTURE} is up to date\n`);
  } else {
    writePluralFixture(tags);
  }
} else {
  const dir = process.argv[2];
  const appDir = process.argv[3];
  if (!dir || !appDir) {
    throw new Error(
      'usage: node tool/extract_runtime_locales.mjs <locales dir> <app strings locales dir> | --plural-categories [--check]',
    );
  }

  const runtimeFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.ts')).sort();
  const appFiles = {};
  for (const name of fs.readdirSync(appDir).filter((file) => file.endsWith('.json'))) {
    appFiles[name.replace(/\.json$/, '')] = JSON.parse(fs.readFileSync(path.join(appDir, name), 'utf8'));
  }
  // Every gap fails here, named, rather than leaving English in a locale.
  const problems = appStringsProblems({
    runtimeLocales: runtimeFiles.map((file) => file.replace(/\.ts$/, '')),
    appFiles,
    sourceKeys: Object.values(APP_KEYS),
    ignoredKeys: IGNORED_APP_KEYS,
    pluralForms: PLURAL_FORMS,
  });
  if (problems.length > 0) {
    throw new Error(`the app strings do not match the runtime locales:\n  ${problems.join('\n  ')}`);
  }

  const strings = {};
  for (const file of runtimeFiles) {
    const dictionary = await readDictionary(path.join(dir, file));
    const entry = {};
    for (const [key, source] of Object.entries(KEYS)) {
      const value = dictionary[source] ?? dictionary[SINGLE_FORM[key]];
      if (typeof value === 'string') entry[key] = value;
      // A counted sentence: take every form the runtime has for it, not just
      // the two English needs. Russian, Polish, Arabic and the rest choose
      // between `few`, `many`, `two` and `zero` too.
      if (key.endsWith('.other') && source.endsWith('.other')) {
        const base = key.slice(0, -'.other'.length);
        const sourceBase = source.slice(0, -'.other'.length);
        for (const form of PLURAL_FORMS) {
          const value = dictionary[`${sourceBase}.${form}`];
          if (typeof value === 'string') entry[`${base}.${form}`] = value;
        }
      }
    }
    const locale = file.replace(/\.ts$/, '');
    const app = appFiles[locale];
    {
      for (const [key, source] of Object.entries(APP_KEYS)) {
        if (typeof app[source] === 'string') {
          entry[key] = app[source];
          continue;
        }
        let counted = false;
        for (const form of PLURAL_FORMS) {
          const value = app[`${source}.${form}`];
          if (typeof value !== 'string') continue;
          if (!counted) {
            // The app strings replace the whole family, never mix with it.
            for (const stale of PLURAL_FORMS) delete entry[`${key}.${stale}`];
            delete entry[key];
            counted = true;
          }
          entry[`${key}.${form}`] = value;
        }
      }
    }
    strings[locale] = entry;
  }

  fs.writeFileSync(
    'design/locale_strings.json',
    `${JSON.stringify(
      { source: 'the SeatLayer runtime locale dictionaries and app strings', strings },
      null,
      2,
    )}\n`,
  );
  process.stdout.write(`wrote design/locale_strings.json (${Object.keys(strings).length} locales)\n`);
  writePluralFixture(Object.keys(strings).sort());
}
