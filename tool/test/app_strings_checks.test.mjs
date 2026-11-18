import assert from 'node:assert/strict';
import test from 'node:test';

import { appStringsProblems } from '../app_strings_checks.mjs';

const base = {
  sourceKeys: ['orbitMode', 'removeTickets'],
  ignoredKeys: ['testEventSemantics'],
  pluralForms: ['zero', 'one', 'two', 'few', 'many', 'other'],
};

const complete = {
  orbitMode: 'Rotate',
  'removeTickets.one': 'Remove {count} ticket',
  'removeTickets.other': 'Remove {count} tickets',
  testEventSemantics: 'Test event',
};

test('complete files pass', () => {
  assert.deepEqual(
    appStringsProblems({
      ...base,
      runtimeLocales: ['de', 'en'],
      appFiles: { de: complete, en: complete },
    }),
    [],
  );
});

test('a shipped locale without an app strings file fails', () => {
  assert.deepEqual(
    appStringsProblems({ ...base, runtimeLocales: ['de', 'en'], appFiles: { en: complete } }),
    ['app strings: no file for locale "de", which the package ships'],
  );
});

test('a locale only the app strings have fails', () => {
  assert.deepEqual(
    appStringsProblems({
      ...base,
      runtimeLocales: ['en'],
      appFiles: { en: complete, xx: complete },
    }),
    ['app strings: locale "xx" has no runtime dictionary'],
  );
});

test('a key missing in one locale fails', () => {
  const { orbitMode: _, ...withoutOrbit } = complete;
  assert.deepEqual(
    appStringsProblems({
      ...base,
      runtimeLocales: ['de', 'en'],
      appFiles: { de: withoutOrbit, en: complete },
    }),
    ['app strings: key "orbitMode" is missing in locale "de"'],
  );
});

test('an unknown plural category fails', () => {
  assert.deepEqual(
    appStringsProblems({
      ...base,
      runtimeLocales: ['pl'],
      appFiles: { pl: { ...complete, 'removeTickets.Few': 'Usuń {count} bilety' } },
    }),
    ['app strings: unknown plural category "Few" in "removeTickets.Few" (locale "pl")'],
  );
});

test('a key neither taken nor ignored fails', () => {
  assert.deepEqual(
    appStringsProblems({
      ...base,
      runtimeLocales: ['en'],
      appFiles: { en: { ...complete, brandNewSentence: 'New' } },
    }),
    ['app strings: key "brandNewSentence" (locale "en") is neither taken nor listed as ignored'],
  );
});
