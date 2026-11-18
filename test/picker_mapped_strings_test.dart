// Strings the package draws in words the runtime dictionaries already have.
//
// Each one is taken from an existing runtime sentence rather than translated
// again here: the action on a rejected selection, the Map/3D name inside the
// 3D scene, a need with its count, the scarcity count, and the extend-hold
// button. Also the app strings for a removed ticket and for reloading the map.
// These tests pin that every probe locale draws the source sentence, that every
// placeholder is filled, and that a counted one picks its locale's own form.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import '../tool/gen_locale_strings.dart' as generator;

final Map<String, Object?> _table = (jsonDecode(
  File('design/locale_strings.json').readAsStringSync(),
) as Map<String, Object?>)['strings']! as Map<String, Object?>;

Map<String, Object?> _entry(String locale) =>
    _table[locale]! as Map<String, Object?>;

SeatLayerPickerStrings _strings(String locale) =>
    SeatLayerPickerStrings.forLocale(Locale(locale));

const List<String> _probeLocales = <String>['en', 'de', 'pl', 'ar', 'ja'];
const List<int> _probeCounts = <int>[0, 1, 2, 5, 11, 21];

/// A placeholder left in a drawn string.
final RegExp _rawPlaceholder = RegExp(r'\{[a-z]+\}');

void main() {
  test('the plain sentences come from their source in every probe locale', () {
    final english = _entry('en');
    for (final locale in _probeLocales) {
      final strings = _strings(locale);
      final entry = _entry(locale);
      final drawn = <String, String>{
        'adjustSelection': strings.adjustSelection,
        'seatRemoved': strings.seatRemoved,
        'reloadSeatMap': strings.reloadSeatMap,
      };
      drawn.forEach((key, value) {
        expect(entry[key], isA<String>(), reason: '$key in $locale');
        expect(value, entry[key], reason: '$key in $locale');
        if (locale != 'en') {
          expect(value, isNot(english[key]), reason: '$key in $locale');
        }
      });
    }
    const defaults = SeatLayerPickerStrings();
    expect(defaults.adjustSelection, 'Adjust seat selection');
    expect(defaults.seatRemoved, 'Ticket removed');
    expect(defaults.reloadSeatMap, 'Reload seat map');
    expect(_strings('de').adjustSelection, 'Sitzauswahl anpassen');
  });

  test('backToSeatMap takes the dictionary where it has it, else English', () {
    // The runtime's dictionaries gain this sentence at their next sync. Until
    // a locale carries it, that locale draws the English default.
    for (final locale in _probeLocales) {
      final source = _entry(locale)['backToSeatMap'] as String?;
      expect(
        _strings(locale).backToSeatMap,
        source ?? 'Back to seat map',
        reason: locale,
      );
    }
    expect(const SeatLayerPickerStrings().backToSeatMap, 'Back to seat map');
  });

  test('backToSeatMap is generated once a dictionary carries it', () {
    final source = generator.renderLocale('de', <String, Object?>{
      'backToSeatMap': 'Zurück zum Sitzplan',
    });
    expect(source, contains("backToSeatMap: 'Zurück zum Sitzplan',"));
  });

  test('a need and its count are joined by the locale\'s own pair', () {
    for (final locale in _probeLocales) {
      final pair = _entry(locale)['accessNeedWithCount']! as String;
      expect(pair, contains('{first}'), reason: locale);
      expect(pair, contains('{second}'), reason: locale);
      for (final count in _probeCounts) {
        final drawn = _strings(locale).accessNeedWithCount('Need', count);
        expect(
          drawn,
          pair.replaceAll('{first}', 'Need').replaceAll('{second}', '$count'),
          reason: '$locale $count',
        );
        expect(drawn, isNot(matches(_rawPlaceholder)), reason: locale);
      }
    }
    expect(const SeatLayerPickerStrings().accessNeedWithCount('Wheelchair', 2),
        'Wheelchair · 2');
    expect(_strings('en').accessNeedWithCount('Wheelchair', 2),
        'Wheelchair · 2');
    expect(_strings('ja').accessNeedWithCount('車いす', 2), '車いす・2');
  });

  test('onlyLeft is the dictionary\'s counted seats-left sentence', () {
    for (final locale in _probeLocales) {
      final strings = _strings(locale);
      for (final count in _probeCounts) {
        final drawn = strings.onlyLeft(count);
        expect(drawn, strings.seatsLeftInSection(count),
            reason: '$locale $count');
        expect(drawn, contains('$count'), reason: '$locale $count');
        expect(drawn, isNot(matches(_rawPlaceholder)), reason: locale);
      }
    }
    const english = SeatLayerPickerStrings();
    expect(english.onlyLeft(86), '86 seats left');
    expect(english.onlyLeft(1), '1 seat left');
    expect(english.onlyLeft(0), '0 seats left');
    expect(_strings('en').onlyLeft(86), '86 seats left');
    for (final count in _probeCounts) {
      expect(english.onlyLeft(count), isNot(startsWith('Only')));
    }
    // Polish: one, few and many are three different sentences.
    final pl = _strings('pl');
    expect(pl.onlyLeft(1), 'Zostało 1 miejsce');
    expect(pl.onlyLeft(2), 'Zostały 2 miejsca');
    expect(pl.onlyLeft(5), 'Zostało 5 miejsc');
    expect(pl.onlyLeft(21), 'Zostało 21 miejsc');
    expect(pl.onlyLeft(22), 'Zostały 22 miejsca');
    // Arabic: zero, one, two, few and many each draw their own form.
    final ar = _strings('ar');
    final entry = _entry('ar');
    final byCount = <int, String>{
      0: 'zero',
      1: 'one',
      2: 'two',
      5: 'few',
      11: 'many'
    };
    byCount.forEach((count, form) {
      expect(
        ar.onlyLeft(count),
        (entry['onlyLeft.$form']! as String).replaceAll('{count}', '$count'),
        reason: 'ar $count',
      );
    });
  });

  test('the extend button names the minutes one tap adds', () {
    for (final locale in _probeLocales) {
      final template = _entry(locale)['addMinutes']! as String;
      for (final minutes in <int>[5, 10]) {
        final drawn = _strings(locale).addMinutes(minutes);
        expect(drawn, template.replaceAll('{count}', '$minutes'),
            reason: '$locale $minutes');
        expect(drawn, isNot(matches(_rawPlaceholder)), reason: locale);
      }
    }
    const english = SeatLayerPickerStrings();
    expect(english.addMinutes(5), '+5 min');
    expect(english.addMinutes(10), '+10 min');
    expect(_strings('de').addMinutes(10), '+10 Min.');
    expect(_strings('ja').addMinutes(10), '+10分');
  });
}
