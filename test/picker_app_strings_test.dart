// Sentences only an app draws, in every language, with the right plural form.
//
// The runtime keeps a second set of translations beside its shared
// dictionary: sentences the web never draws, written for the app SDKs. These
// tests pin that the package takes them, that each counted one chooses its
// form the way `Intl.PluralRules` does, and that no translation lost a
// placeholder on the way.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

final Map<String, Object?> _table =
    _json('design/locale_strings.json')['strings']! as Map<String, Object?>;
final Map<String, Object?> _fixture =
    _json('test/fixtures/plural_categories.json');

Map<String, Object?> _entry(String locale) =>
    _table[locale]! as Map<String, Object?>;

/// The category `Intl.PluralRules(locale)` gives [count], from the fixture
/// the extractor writes with Node, not from the Dart rules under test.
String _category(String locale, int count) {
  final counts = (_fixture['counts']! as List<Object?>).cast<int>();
  final categories = ((_fixture['categories']! as Map<String, Object?>)[locale]!
          as List<Object?>)
      .cast<String>();
  return categories[counts.indexOf(count)];
}

/// Every category the locale's rule produces over the fixture's counts.
Set<String> _categoriesOf(String locale) =>
    ((_fixture['categories']! as Map<String, Object?>)[locale]!
            as List<Object?>)
        .cast<String>()
        .toSet();

/// The sentence the runtime would draw for [count]: its own form, or `other`.
String _expected(String locale, String key, int count) {
  final entry = _entry(locale);
  final form = (entry['$key.${_category(locale, count)}'] ??
      entry['$key.other'])! as String;
  return form.replaceAll('{count}', '$count');
}

/// The counted strings this step takes from the app strings.
final Map<String, String Function(int) Function(SeatLayerPickerStrings)>
    _counted = <String, String Function(int) Function(SeatLayerPickerStrings)>{
  'removeTickets': (s) => s.removeTickets,
  'holdMinutesLeft': (s) => s.holdMinutesLeft,
  'holdSecondsLeft': (s) => s.holdSecondsLeft,
  'holdLapsedBody': (s) => s.holdLapsedBody,
  'accessibleSections': (s) => s.accessibleSections,
  'placesAvailable': (s) => s.placesAvailable,
  'seatsNotRecovered': (s) => s.seatsNotRecovered,
};

const List<String> _probeLocales = <String>['en', 'de', 'pl', 'ar', 'ja'];
const List<int> _probeCounts = <int>[0, 1, 2, 5, 11, 21];

SeatLayerPickerStrings _strings(String locale) =>
    SeatLayerPickerStrings.forLocale(Locale(locale));

void main() {
  for (final key in _counted.keys) {
    test('$key draws the runtime\'s form for every count', () {
      for (final locale in _probeLocales) {
        final draw = _counted[key]!(_strings(locale));
        for (final count in _probeCounts) {
          expect(
            draw(count),
            _expected(locale, key, count),
            reason: '$key in $locale for $count',
          );
        }
      }
    });
  }

  test('the counted sentences read correctly where it shows', () {
    expect(
      const SeatLayerPickerStrings().holdLapsedBody(1),
      'They were held for 1 minute.',
    );
    expect(
      const SeatLayerPickerStrings().holdLapsedBody(5),
      'They were held for 5 minutes.',
    );
    expect(_strings('pl').removeTickets(2), 'Usuń 2 bilety');
    expect(_strings('pl').removeTickets(5), 'Usuń 5 biletów');
    expect(_strings('pl').removeTickets(22), 'Usuń 22 bilety');
    expect(_strings('de').holdMinutesLeft(1), isNot(contains('minute left')));
    // Arabic: the six counts cover zero, one, two, few (5) and many (11,
    // 21), and each draws that category's own sentence.
    expect(
      <String>{for (final count in _probeCounts) _category('ar', count)},
      <String>{'zero', 'one', 'two', 'few', 'many'},
    );
    expect(_strings('ar').holdSecondsLeft(2), 'بقيت 2 ثانيتان');
    expect(_strings('ar').holdSecondsLeft(5), 'بقيت 5 ثوانٍ');
    final ja = _strings('ja');
    expect(ja.removeTickets(1).replaceAll('1', '#'),
        ja.removeTickets(5).replaceAll('5', '#'));
  });

  test('every locale carries every category its rule can produce', () {
    final missing = <String>[];
    for (final locale in _table.keys) {
      final entry = _entry(locale);
      for (final key in _counted.keys) {
        if (entry['$key.other'] == null) {
          missing.add('$locale $key (no family)');
          continue;
        }
        for (final category in _categoriesOf(locale)) {
          if (entry['$key.$category'] == null) {
            missing.add('$locale $key.$category');
          }
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('every translation keeps exactly the placeholders English has', () {
    final english = _entry('en');
    final placeholder = RegExp(r'\{[a-z]+\}');
    Set<String> slots(String value) =>
        placeholder.allMatches(value).map((m) => m[0]!).toSet();
    String family(String key) => key.contains('.')
        ? '${key.substring(0, key.lastIndexOf('.'))}.other'
        : key;
    final broken = <String>[];
    for (final locale in _table.keys) {
      _entry(locale).forEach((key, value) {
        final source = english[family(key)] as String?;
        if (source == null) return;
        if (!slots(value! as String).containsAll(slots(source)) ||
            !slots(source).containsAll(slots(value as String))) {
          broken.add('$locale $key');
        }
      });
    }
    expect(broken, isEmpty);
  });

  test('the app-only sentences reach every locale they are translated in', () {
    expect(_strings('de').seatsSecuredOpeningCheckout,
        _entry('de')['seatsSecuredOpeningCheckout']);
    for (final locale in <String>['de', 'pl', 'ar', 'ja', 'tr']) {
      final strings = _strings(locale);
      final entry = _entry(locale);
      expect(strings.orbitMode, entry['orbitMode'], reason: locale);
      expect(strings.panMode, entry['panMode'], reason: locale);
      expect(strings.showSeatsFor, entry['showSeatsFor'], reason: locale);
      expect(strings.viewGroupTitle, entry['viewGroupTitle'], reason: locale);
      expect(strings.testMode, entry['testMode'], reason: locale);
      expect(strings.orbitMode, isNot('Rotate venue'), reason: locale);
    }
    // The heading is drawn as written: Turkish capitals keep their dotted İ.
    expect(_strings('tr').showSeatsFor, 'KOLTUKLARI GÖSTER:');
  });

  test('the English counted defaults choose by the plural rule', () {
    const strings = SeatLayerPickerStrings();
    // `count == 1` called -1 plural; the rule, like Intl.PluralRules('en'),
    // calls it singular. Only such odd counts differ.
    expect(strings.ticketCount(-1), '-1 ticket');
    expect(strings.seatsFree(-1), '-1 seat');
    expect(strings.removeTickets(-1), 'Remove -1 ticket');
    expect(strings.holdMinutesLeft(-1), '-1 minute left');
    expect(strings.activeFilters(-1), '-1 filter');
    for (final count in _probeCounts) {
      final one = count == 1;
      expect(strings.ticketCount(count), one ? '1 ticket' : '$count tickets');
      expect(strings.seatsFree(count), one ? '1 seat' : '$count seats');
      expect(strings.activeFilters(count), one ? '1 filter' : '$count filters');
      expect(strings.accessibleSections(count),
          one ? '1 section' : '$count sections');
      expect(
          strings.placesAvailable(count),
          one
              ? '1 place currently available'
              : '$count places currently available');
    }
  });

  test('no locale has a filters sentence yet, so all draw English', () {
    expect(_strings('de').activeFilters(2), '2 filters');
  });

  test('Norwegian Bokmål devices get the Norwegian strings', () {
    final norwegian = SeatLayerPickerStrings.forLocale(const Locale('no'));
    expect(norwegian.sectionWord,
        isNot(const SeatLayerPickerStrings().sectionWord));
    expect(
        norwegian.orbitMode, isNot(const SeatLayerPickerStrings().orbitMode));
    for (final locale in <Locale>[
      const Locale('nb'),
      const Locale('nb', 'NO')
    ]) {
      final strings = SeatLayerPickerStrings.forLocale(locale);
      // One shared runtime string and one app string.
      expect(strings.sectionWord, norwegian.sectionWord, reason: '$locale');
      expect(strings.orbitMode, norwegian.orbitMode, reason: '$locale');
    }
  });
}
