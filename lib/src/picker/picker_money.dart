/// Amounts, written as the drawn map writes them in the picker's language.
library;

import 'package:flutter/widgets.dart';

import 'picker_money_table.g.dart';
import 'picker_strings.dart';
import 'seat_layer_picker_scope.dart';

/// How one language writes an amount.
@immutable
final class PickerMoneyRule {
  const PickerMoneyRule({
    required this.group,
    required this.decimal,
    required this.marks,
    this.markFirst = false,
    this.lead = '',
    this.gap = '',
    this.groupsFromFive = false,
    this.lakhs = false,
    this.digits = '0123456789',
  });

  /// The currency before the number.
  final bool markFirst;

  /// What stands before the whole.
  final String lead;

  /// What stands between the currency and the number.
  final String gap;

  final String group;
  final String decimal;

  /// No separator in a number of four digits.
  final bool groupsFromFive;

  /// Thousands, then pairs: 12,34,567.
  final bool lakhs;

  /// Its digits, 0 to 9.
  final String digits;

  /// `CODEmark|CODEmark`, for the currencies not written as their code.
  final String marks;

  String markOf(String code) {
    for (final entry in marks.split('|')) {
      if (entry.startsWith(code)) return entry.substring(code.length);
    }
    return code;
  }
}

/// Render [amount] the way the host asked, or as the picker's language writes
/// the currency when the host supplied no formatter.
String pickerMoney(BuildContext context, double amount, String currency) {
  final formatter = SeatLayerPickerScope.optionsOf(context).pricing?.formatter;
  if (formatter != null) return formatter(amount, currency);
  return pickerCompactMoney(
    amount,
    currency,
    locale: SeatLayerPickerScope.configurationOf(context).locale,
  );
}

/// Currencies whose amounts are not written with two decimals.
const Set<String> _noDecimals = <String>{
  'AFN', 'ALL', 'BIF', 'CLP', 'COP', 'DJF', 'GNF', 'HUF', 'IDR', 'IQD', //
  'IRR', 'ISK', 'JPY', 'KMF', 'KPW', 'KRW', 'LAK', 'LBP', 'MGA', 'MMK',
  'PKR', 'PYG', 'RWF', 'SLL', 'SOS', 'SYP', 'UGX', 'VND', 'VUV', 'XAF',
  'XOF', 'XPF', 'YER',
};
const Set<String> _threeDecimals = <String>{
  'BHD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND', //
};

/// `$75`, `€1,080`, `1.080 €`: English when no [locale] is given. A whole
/// amount has no decimals; any other has as many as its currency has.
String pickerCompactMoney(double amount, String currency, {String? locale}) {
  final value = amount.isFinite ? amount : 0.0;
  final trimmed = currency.trim().toUpperCase();
  final code = trimmed.isEmpty ? 'USD' : trimmed;
  final rule = _ruleFor(locale);
  final decimals = value == value.roundToDouble() || _noDecimals.contains(code)
      ? 0
      : _threeDecimals.contains(code)
          ? 3
          : 2;
  final parts = value.abs().toStringAsFixed(decimals).split('.');
  final number = _digits(rule, _grouped(rule, parts.first)) +
      (decimals == 0 ? '' : rule.decimal + _digits(rule, parts.last));
  final mark = rule.markOf(code);
  final sign = value < 0 ? '-' : '';
  if (!rule.markFirst) return '${rule.lead}$sign$number${rule.gap}$mark';
  // A mark that ends in a letter is kept off the number.
  final gap =
      rule.gap.isEmpty && !_symbolEnd.hasMatch(mark) ? '\u{A0}' : rule.gap;
  return '${rule.lead}$sign$mark$gap$number';
}

final RegExp _symbolEnd = RegExp(r'[\p{S}\p{Z}]$', unicode: true);

PickerMoneyRule _ruleFor(String? locale) {
  final english = pickerMoneyRules['en']!;
  final tag = locale?.trim().replaceAll('_', '-') ?? '';
  if (tag.isEmpty) return english;
  final parts = tag.split('-');
  final language = parts.first.toLowerCase();
  String? script;
  String? country;
  for (final part in parts.skip(1)) {
    if (part.length == 4) {
      script ??= part[0].toUpperCase() + part.substring(1).toLowerCase();
    } else if (part.length == 2) {
      country ??= part.toUpperCase();
    }
  }
  if (language.isEmpty) return english;
  final wanted = Locale.fromSubtags(
    languageCode: language,
    scriptCode: script,
    countryCode: country,
  );
  for (final candidate in SeatLayerPickerStrings.localeNames(wanted)) {
    final rule = pickerMoneyRules[candidate];
    if (rule != null) return rule;
  }
  return english;
}

String _grouped(PickerMoneyRule rule, String whole) {
  if (whole.length < (rule.groupsFromFive ? 5 : 4)) return whole;
  final groups = <String>[whole.substring(whole.length - 3)];
  final size = rule.lakhs ? 2 : 3;
  for (var end = whole.length - 3; end > 0; end -= size) {
    groups.insert(0, whole.substring(end > size ? end - size : 0, end));
  }
  return groups.join(rule.group);
}

String _digits(PickerMoneyRule rule, String text) {
  if (rule.digits.startsWith('0')) return text;
  return text.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => rule.digits[int.parse(match[0]!)],
  );
}
