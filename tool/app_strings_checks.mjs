// Checks the app strings against the runtime dictionaries before they are
// merged, so a gap fails the extraction with its locale and key named instead
// of quietly leaving English in a translated locale.
//
// Pure: it reads nothing from disk, so it is tested on fixtures.

/**
 * Every problem with [appFiles] against the runtime locales, one line each.
 *
 * @param {object} input
 * @param {string[]} input.runtimeLocales locales the package ships (one runtime dictionary each)
 * @param {Record<string, Record<string, unknown>>} input.appFiles app strings per locale
 * @param {string[]} input.sourceKeys app strings keys the tool takes
 * @param {string[]} input.ignoredKeys app strings keys deliberately not taken
 * @param {string[]} input.pluralForms plural category names the tool knows
 * @returns {string[]}
 */
export function appStringsProblems({
  runtimeLocales,
  appFiles,
  sourceKeys,
  ignoredKeys,
  pluralForms,
}) {
  const problems = [];
  const known = new Set(sourceKeys);
  const ignored = new Set(ignoredKeys);
  const forms = new Set(pluralForms);
  const shipped = new Set(runtimeLocales);

  for (const locale of [...shipped].sort()) {
    if (!(locale in appFiles)) {
      problems.push(`app strings: no file for locale "${locale}", which the package ships`);
    }
  }
  for (const locale of Object.keys(appFiles).sort()) {
    if (!shipped.has(locale)) {
      problems.push(`app strings: locale "${locale}" has no runtime dictionary`);
    }
  }

  // Which mapped keys each locale has, by family.
  const present = new Map();
  for (const [locale, file] of Object.entries(appFiles)) {
    const families = new Set();
    for (const key of Object.keys(file)) {
      if (known.has(key) || ignored.has(key)) {
        families.add(key);
        continue;
      }
      const dot = key.lastIndexOf('.');
      const base = dot < 0 ? key : key.slice(0, dot);
      if (dot >= 0 && (known.has(base) || ignored.has(base))) {
        const form = key.slice(dot + 1);
        if (!forms.has(form)) {
          problems.push(
            `app strings: unknown plural category "${form}" in "${key}" (locale "${locale}")`,
          );
        }
        families.add(base);
        continue;
      }
      problems.push(
        `app strings: key "${key}" (locale "${locale}") is neither taken nor listed as ignored`,
      );
    }
    present.set(locale, families);
  }

  for (const key of [...known].sort()) {
    const having = [...present].filter(([, families]) => families.has(key));
    if (having.length === 0 || having.length === present.size) continue;
    for (const [locale, families] of [...present].sort(([a], [b]) => a.localeCompare(b))) {
      if (!families.has(key)) {
        problems.push(`app strings: key "${key}" is missing in locale "${locale}"`);
      }
    }
  }
  return problems;
}
