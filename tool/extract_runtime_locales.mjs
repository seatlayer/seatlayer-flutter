// Rebuilds `design/locale_strings.json` from the SeatLayer runtime's own
// dictionaries.
//
//   node tool/extract_runtime_locales.mjs <SeatLayer runtime locale directory>
//
// The runtime already ships a translated dictionary per locale, reviewed by
// the same people who review the web picker's wording. Re-translating the same
// sentences on this side would drift, so the native chrome takes them from
// there — but through a file committed HERE, because a generator that reaches
// outside the package could not be checked by this package's own test suite.
//
// Only the keys the native chrome actually renders are extracted. A Flutter
// string with no equivalent on the runtime side is simply absent, and keeps
// its English default at runtime.
import fs from 'node:fs';
import path from 'node:path';

/** Flutter string key -> the runtime dictionary key it is taken from. */
const KEYS = {
  close: 'picker.close',
  overview: 'picker.overview',
  backToVenue: 'picker.backToVenue',
  cancel: 'common.cancel',
  select: 'picker.select',
  viewFromHere: 'picker.viewFromHere',
  sightline: 'picker.sightline',
  openVenue360: 'picker.openAuthored360',
  recentre: 'picker.recentreOnStage',
  viewFromYourSeat: 'picker.viewFromYourSeat',
  emptyTrayHint: 'picker.trayHintTapOrBest',
  anyTicketType: 'picker.anyTicketType',
  anyVenueZone: 'picker.anyVenueZone',
  bestSeats: 'picker.bestSeatsPremium',
  showLess: 'picker.showLess',
  undo: 'picker.undo',
  holdAndCheckout: 'picker.holdSeatsAndCheckout',
  poweredBy: 'picker.poweredBy',
  testMode: 'picker.testMode',
  accessibility: 'picker.accessibilityOptions',
  accessibilityTitle: 'picker.accessibilityOptions',
  fitVenue: 'picker.fitToScreen',
  loading: 'picker.loadingSeatMap',
  errorMessage: 'picker.mapDidNotLoad',
  retry: 'picker.accessRetry',
  hideLimitedView: 'picker.hideLimitedView',
  colorblindSafe: 'picker.colorblindColors',
  continueWord: 'picker.continue',
  seatsLeft: 'picker.seatsLeftShort',
  fromPrice: 'picker.peekFromPrice',
  moreCount: 'picker.moreCount',
  addMinutes: 'picker.addMinutes',
  'ticketCount.one': 'picker.ticketsCount.one',
  'ticketCount.other': 'picker.ticketsCount.other',
  'findBestSeats.one': 'picker.findBestSeatsCount.one',
  'findBestSeats.other': 'picker.findBestSeatsCount.other',
  'reselectSeats.one': 'picker.holdLapsedSelectAgain.one',
  'reselectSeats.other': 'picker.holdLapsedSelectAgain.other',
};

const dir = process.argv[2];
if (!dir) throw new Error('usage: node tool/extract_runtime_locales.mjs <locales dir>');

/** One locale file, evaluated as a module with its type annotation removed. */
async function readDictionary(file) {
  const code = fs
    .readFileSync(file, 'utf8')
    .replace(/^import[\s\S]*?;$/m, '')
    .replace(/export const\s+[A-Za-z0-9_$]+\s*:\s*Dict\s*=\s*/, 'export default ');
  const scratch = path.join(fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'sl-')), 'dict.mjs');
  fs.writeFileSync(scratch, code);
  try {
    return (await import(`file://${scratch}`)).default;
  } finally {
    fs.rmSync(path.dirname(scratch), { recursive: true, force: true });
  }
}

const strings = {};
for (const file of fs.readdirSync(dir).filter((name) => name.endsWith('.ts')).sort()) {
  const dictionary = await readDictionary(path.join(dir, file));
  const entry = {};
  for (const [key, source] of Object.entries(KEYS)) {
    if (typeof dictionary[source] === 'string') entry[key] = dictionary[source];
  }
  strings[file.replace(/\.ts$/, '')] = entry;
}

fs.writeFileSync(
  'design/locale_strings.json',
  `${JSON.stringify(
    { source: 'the SeatLayer runtime locale dictionaries', strings },
    null,
    2,
  )}\n`,
);
process.stdout.write(`wrote design/locale_strings.json (${Object.keys(strings).length} locales)\n`);
