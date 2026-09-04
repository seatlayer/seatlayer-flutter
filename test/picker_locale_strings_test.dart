// The native chrome speaks the languages the drawn map already speaks.
//
// The runtime ships a reviewed dictionary for thirty-seven locales, and the
// map inside the WebView uses it. Until now the Flutter chrome around that map
// was English whatever the host asked for, so a French buyer got a French seat
// map under an English header. The defaults are generated from the runtime's
// own files so the two sides cannot drift into two wordings of one sentence.
import 'dart:convert';
import 'dart:io';

import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_strings_locales.g.dart';

Map<String, Object?> _table() =>
    (jsonDecode(File('design/locale_strings.json').readAsStringSync())
        as Map<String, Object?>)['strings']! as Map<String, Object?>;

void main() {
  test('every locale the runtime translates has defaults here', () {
    final table = _table();
    expect(table, hasLength(37));
    expect(
      seatLayerPickerStringsByLocale.keys.toSet(),
      table.keys.toSet(),
    );
  });

  test('every extracted key actually reaches the generated locales', () {
    // The extractor and the generator are two lists, and a key can be in the
    // first without being in the second. A string that takes a placeholder
    // has to be declared as a formatter to be emitted at all, and one that
    // was not simply vanished: every locale kept the English default while
    // `design/locale_strings.json` said otherwise, and the staleness check
    // still passed because the generated files did match the generator.
    //
    // German is the probe. Any locale would do; what matters is that a key
    // present in the table is not silently dropped on the way to Dart.
    final german = _table()['de']! as Map<String, Object?>;
    final generated = File(
      'lib/src/picker/picker_strings.de.g.dart',
    ).readAsStringSync();
    final missing = german.keys
        .where((key) => !generated.contains(key.split('.').first))
        .toList(growable: false)
      ..sort();
    expect(
      missing,
      isEmpty,
      reason: 'extracted but never generated: ${missing.join(', ')}\n'
          'A placeholder string must also be declared in the generator\'s '
          'formatter table.',
    );
  });

  test('a language code resolves to its own wording', () {
    expect(SeatLayerPickerStrings.forLocale(const Locale('de')).overview,
        'Spielstätte');
    expect(SeatLayerPickerStrings.forLocale(const Locale('fr')).retry,
        isNot('Try again'));
    // A region the runtime does not split on still resolves by language.
    expect(
      SeatLayerPickerStrings.forLocale(const Locale('de', 'AT')).overview,
      'Spielstätte',
    );
  });

  test('Chinese resolves by script, and a bare zh is Simplified', () {
    final simplified = SeatLayerPickerStrings.forLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    final traditional = SeatLayerPickerStrings.forLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    expect(simplified.overview, isNot(traditional.overview));
    expect(SeatLayerPickerStrings.forLocale(const Locale('zh')).overview,
        simplified.overview);
    expect(SeatLayerPickerStrings.forLocale(const Locale('zh', 'TW')).overview,
        traditional.overview);
  });

  test('an untranslated locale falls back to English, entry by entry', () {
    const english = SeatLayerPickerStrings();
    final klingon = SeatLayerPickerStrings.forLocale(const Locale('tlh'));
    expect(klingon.overview, english.overview);
    expect(klingon.holdAndCheckout, english.holdAndCheckout);

    // And a single string the runtime has no equivalent for stays English even
    // inside a translated locale.
    final german = SeatLayerPickerStrings.forLocale(const Locale('de'));
    expect(german.applyFilters, english.applyFilters);
    expect(german.overview, isNot(english.overview));
  });

  test('interpolation survives translation', () {
    final german = SeatLayerPickerStrings.forLocale(const Locale('de'));
    expect(german.seatsLeft(74), contains('74'));
    expect(german.fromPrice('€25'), contains('€25'));
    expect(german.moreCount(6), contains('6'));
    expect(german.continueWithTotal('€320'), contains('€320'));
    expect(german.ticketCount(1), isNot(german.ticketCount(6)));
    expect(german.ticketCount(6), contains('6'));
    expect(german.findBestSeats(2), contains('2'));
  });

  test('the recovery action is counted, not interpolated', () {
    // It carries no number at all — the count only chooses between two
    // sentences, so the singular and the plural must genuinely differ.
    const english = SeatLayerPickerStrings();
    expect(english.reselectSeats(1), 'Select it again');
    expect(english.reselectSeats(3), 'Select them again');

    // French marks the object's number on the pronoun, so the two forms of the
    // translated sentence are genuinely different sentences.
    final french = SeatLayerPickerStrings.forLocale(const Locale('fr'));
    expect(french.reselectSeats(1), 'La sélectionner à nouveau');
    expect(french.reselectSeats(3), 'Les sélectionner à nouveau');

    // German says it one way whatever the number, and the generator must carry
    // that through rather than invent a distinction the language does not make.
    final german = SeatLayerPickerStrings.forLocale(const Locale('de'));
    expect(german.reselectSeats(1), german.reselectSeats(3));
    expect(german.reselectSeats(1), isNot('Select it again'));
  });

  test('a language with no singular category uses one form for both', () {
    // Japanese has no `one` in Intl.PluralRules; the runtime's dictionary says
    // so by carrying only `.other`, and the generated form must not invent one.
    final japanese = SeatLayerPickerStrings.forLocale(const Locale('ja'));
    expect(japanese.ticketCount(1), contains('1'));
    expect(japanese.ticketCount(6), contains('6'));
    expect(
      japanese.ticketCount(1).replaceAll('1', '#'),
      japanese.ticketCount(6).replaceAll('6', '#'),
    );
  });

  test('every entry is still overridable', () {
    final german = SeatLayerPickerStrings.forLocale(const Locale('de'));
    expect(german.overview, 'Spielstätte');
    const mine = SeatLayerPickerStrings(overview: 'Übersicht');
    expect(mine.overview, 'Übersicht');
  });

  test('the generated locale files are not stale', () {
    final result = Process.runSync(
      'dart',
      <String>['run', 'tool/gen_locale_strings.dart', '--check'],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  });
}
