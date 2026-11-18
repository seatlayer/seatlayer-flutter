// A counted sentence takes the form the runtime would give it.
//
// The runtime chooses with `Intl.PluralRules`; the native chrome chooses with
// the rules in `picker_plural_rules.dart`. The fixture is what Intl answered
// for every shipped locale (written by `tool/extract_runtime_locales.mjs`),
// so the two are compared count by count rather than by reading CLDR twice.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_plural_rules.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import '../tool/gen_locale_strings.dart' as generator;

Map<String, Object?> _fixture() =>
    jsonDecode(File('test/fixtures/plural_categories.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _table() =>
    (jsonDecode(File('design/locale_strings.json').readAsStringSync())
        as Map<String, Object?>)['strings']! as Map<String, Object?>;

/// The runtime's sentence for [field] at [count] in [tag]: the form its
/// category names, else `other`, as `tCount` does.
String _runtimeSentence(String tag, String field, int count) {
  final fixture = _fixture();
  final counts = (fixture['counts']! as List<Object?>).cast<int>();
  final categories =
      ((fixture['categories']! as Map<String, Object?>)[tag]! as List<Object?>)
          .cast<String>();
  final category = categories[counts.indexOf(count)];
  final values = _table()[tag]! as Map<String, Object?>;
  final raw = (values['$field.$category'] ?? values['$field.other'])! as String;
  return raw.replaceAll('{count}', '$count');
}

void main() {
  test('every shipped locale chooses as Intl.PluralRules does', () {
    final fixture = _fixture();
    final counts = (fixture['counts']! as List<Object?>).cast<int>();
    final categories = fixture['categories']! as Map<String, Object?>;
    // Compared tag by tag, as shipped: Portuguese and French count 0 as
    // singular where Spanish does not, and a rule written for a family would
    // hide that.
    expect(categories.keys.toSet(), _table().keys.toSet());
    final wrong = <String>[];
    for (final MapEntry(key: tag, value: list) in categories.entries) {
      final expected = (list! as List<Object?>).cast<String>();
      for (var i = 0; i < counts.length; i++) {
        final got = pickerPluralCategory(tag, counts[i]).name;
        if (got != expected[i]) {
          wrong.add('$tag ${counts[i]}: $got, not ${expected[i]}');
        }
      }
    }
    expect(wrong, isEmpty, reason: wrong.take(20).join('\n'));
  });

  test('the rule lookup falls back the way the strings do', () {
    // A region the runtime does not split on counts as its language.
    expect(pickerPluralCategory('pt-BR', 0), PickerPluralCategory.one);
    expect(pickerPluralCategory('ru-RU', 5), PickerPluralCategory.many);
    // A language with no rule here counts as English does.
    expect(pickerPluralCategory('tlh', 1), PickerPluralCategory.one);
    expect(pickerPluralCategory('tlh', 0), PickerPluralCategory.other);
    expect(pickerPluralCategory('tlh', 5), PickerPluralCategory.other);
  });

  group('the sentences match the runtime\'s own, count by count', () {
    const counts = <int>[0, 1, 2, 3, 5, 11, 21, 22, 25, 101];
    for (final tag in <String>['ru', 'pl', 'ar', 'cs', 'lt', 'cy']) {
      test(tag, () {
        final strings = SeatLayerPickerStrings.forLocale(Locale(tag));
        for (final count in counts) {
          expect(
            strings.seatsLeftInSection(count),
            _runtimeSentence(tag, 'seatsLeftInSection', count),
            reason: 'seatsLeftInSection($count)',
          );
          expect(
            strings.ticketCount(count),
            _runtimeSentence(tag, 'ticketCount', count),
            reason: 'ticketCount($count)',
          );
          expect(
            strings.holdLapsedSomeTaken(count),
            _runtimeSentence(tag, 'holdLapsedSomeTaken', count),
            reason: 'holdLapsedSomeTaken($count)',
          );
        }
      });
    }

    test('Russian, as a reader would check it', () {
      final russian = SeatLayerPickerStrings.forLocale(const Locale('ru'));
      expect(russian.seatsLeftInSection(5), endsWith('мест'));
      expect(russian.seatsLeftInSection(21), endsWith('место'));
      expect(russian.seatsLeftInSection(22), endsWith('места'));
    });
  });

  test('a form the dictionary lacks falls back to other', () {
    // Russian needs `few` and `many`; a dictionary that carried only `one`
    // and `other` must answer `other` for them, as the runtime does.
    final source = generator.renderLocale('ru', <String, Object?>{
      'seatsLeftInSection.one': 'Остался {count}',
      'seatsLeftInSection.other': 'Осталось {count}',
    });
    expect(source, contains('PickerPluralCategory.one =>'));
    expect(source, isNot(contains('PickerPluralCategory.few')));
    expect(source, contains(r"_ => 'Осталось $count'"));
  });

  test('a language with no number agreement needs no choice', () {
    final source = generator.renderLocale('ja', <String, Object?>{
      'ticketCount.other': '{count}枚',
    });
    expect(source, isNot(contains('pickerPluralCategory')));
    expect(source, isNot(contains('picker_plural_rules.dart')));
  });

  test('a translated line break stays inside its literal', () {
    // A raw line break ends a single-quoted Dart string, and `dart format`
    // then fails on the whole generated file.
    expect(generator.escapeDartString('one\ntwo'), r'one\ntwo');
    expect(generator.escapeDartString('one\r\ntwo'), r'one\r\ntwo');
    final source = generator.renderLocale('de', <String, Object?>{
      'close': 'Schließen\nbitte',
    });
    expect(source, contains(r"close: 'Schließen\nbitte',"));
  });

  test('the fixture is not stale', () {
    final ProcessResult result;
    try {
      result = Process.runSync('node', <String>[
        'tool/extract_runtime_locales.mjs',
        '--plural-categories',
        '--check',
      ]);
    } on ProcessException {
      markTestSkipped('node is not installed on this host');
      return;
    }
    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  });
}
