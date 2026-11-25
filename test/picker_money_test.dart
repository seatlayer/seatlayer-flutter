// The chrome writes an amount as the drawn map beside it does.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_money.dart';
import 'package:seatlayer/src/picker/picker_money_table.g.dart';
import 'package:seatlayer/src/picker/picker_strings_locales.g.dart';

void main() {
  // Recorded from the hosted map, runtime 1.0.3.
  final fixture = jsonDecode(
    File('test/fixtures/money_web.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final amounts = (fixture['amounts']! as List).cast<num>();
  final money = fixture['money']! as Map<String, Object?>;

  test('has a row for every language of the picker', () {
    expect(money.keys.toSet(), seatLayerPickerStringsByLocale.keys.toSet());
    expect(pickerMoneyRules.keys.toSet(), money.keys.toSet());
  });

  for (final locale in money.keys) {
    test('$locale is written as the map writes it', () {
      for (final entry in (money[locale]! as Map<String, Object?>).entries) {
        expect(
          <String>[
            for (final amount in amounts)
              pickerCompactMoney(amount.toDouble(), entry.key, locale: locale),
          ],
          entry.value,
          reason: entry.key,
        );
      }
    });
  }

  test('English when no language is given, or one nobody knows', () {
    for (final locale in <String?>[null, '', ' ', 'xx', 'english please']) {
      expect(pickerCompactMoney(1200, 'JPY', locale: locale), '¥1,200');
      expect(
          pickerCompactMoney(12.625, 'KWD', locale: locale), 'KWD\u{A0}12.625');
      expect(pickerCompactMoney(75, 'USD', locale: locale), r'$75');
    }
  });

  test('a language with its country, in any spelling', () {
    for (final locale in <String>['de', 'de-AT', 'de_AT', 'DE']) {
      expect(pickerCompactMoney(1200, 'EUR', locale: locale), '1.200\u{A0}€');
    }
    expect(
      pickerCompactMoney(5, 'USD', locale: 'zh-TW'),
      pickerCompactMoney(5, 'USD', locale: 'zh-Hant'),
    );
    expect(
      pickerCompactMoney(5, 'USD', locale: 'nb-NO'),
      pickerCompactMoney(5, 'USD', locale: 'no'),
    );
  });

  test('an amount below zero, a code nobody knows, an amount that is none', () {
    expect(pickerCompactMoney(-5, 'EUR'), '-€5');
    expect(pickerCompactMoney(5, 'zzz'), 'ZZZ\u{A0}5');
    expect(pickerCompactMoney(5, ' '), r'$5');
    expect(pickerCompactMoney(double.nan, 'EUR'), '€0');
  });

  test('is written in one place', () {
    final writers = <String>[
      for (final file in Directory('lib/src/picker').listSync())
        if (file is File &&
            RegExp(r"toStringAsFixed\((0|2|decimals)\)")
                .hasMatch(file.readAsStringSync()) &&
            file.readAsStringSync().contains('urrency'))
          file.uri.pathSegments.last,
    ];
    expect(writers, <String>['picker_money.dart']);
  });
}
