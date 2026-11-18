// Which form of a counted sentence a locale uses for a count.
//
// The SeatLayer runtime picks a counted sentence's form with
// `Intl.PluralRules(locale).select(count)`. These are the same CLDR rules,
// written out for the integers the picker counts, so the native chrome
// chooses the same form for the same number: Russian says "5 мест" and
// "21 место", Arabic has six forms, Welsh has its own for 3 and 6.
//
// `test/picker_plural_rules_test.dart` checks every shipped locale against
// `test/fixtures/plural_categories.json`, which the locale extractor writes
// from `Intl.PluralRules` itself.
//
// Counts are whole numbers. Decimal counts (CLDR's `v`, `f` and `t`
// operands) are not supported: nothing in the picker counts in fractions.
import 'package:meta/meta.dart';

/// A CLDR plural category.
@internal
enum PickerPluralCategory { zero, one, two, few, many, other }

/// The category [count] takes in the locale [tag].
///
/// [tag] is a locale tag as the strings resolve it (`pt-BR`, `zh-Hant`, `ru`).
/// It is looked up whole, then by its language, the way
/// `SeatLayerPickerStrings.forLocale` falls back. A language with no rule
/// here counts as English does: one and other.
@internal
PickerPluralCategory pickerPluralCategory(String tag, int count) {
  final rule = _rules[tag] ?? _rules[tag.split(RegExp('[-_]')).first];
  return (rule ?? _oneOther)(count.abs());
}

typedef _Rule = PickerPluralCategory Function(int n);

bool _within(int n, int low, int high) => n >= low && n <= high;

PickerPluralCategory _oneOther(int n) =>
    n == 1 ? PickerPluralCategory.one : PickerPluralCategory.other;

/// 0 and 1 are both singular (Persian, Hindi).
PickerPluralCategory _zeroAndOne(int n) =>
    n == 0 || n == 1 ? PickerPluralCategory.one : PickerPluralCategory.other;

/// No number agreement at all (Chinese, Japanese, Korean, Thai…).
PickerPluralCategory _otherOnly(int n) => PickerPluralCategory.other;

/// Whole millions take their own form (`1 million de places`).
bool _wholeMillion(int n) => n != 0 && n % 1000000 == 0;

/// French and Portuguese: 0 and 1 singular, whole millions their own form.
PickerPluralCategory _french(int n) => n == 0 || n == 1
    ? PickerPluralCategory.one
    : _wholeMillion(n)
        ? PickerPluralCategory.many
        : PickerPluralCategory.other;

/// Spanish, Italian, Catalan: 1 singular, whole millions their own form.
PickerPluralCategory _spanish(int n) => n == 1
    ? PickerPluralCategory.one
    : _wholeMillion(n)
        ? PickerPluralCategory.many
        : PickerPluralCategory.other;

/// Russian, Ukrainian, Belarusian.
PickerPluralCategory _eastSlavic(int n) {
  final ten = n % 10;
  final hundred = n % 100;
  if (ten == 1 && hundred != 11) return PickerPluralCategory.one;
  if (_within(ten, 2, 4) && !_within(hundred, 12, 14)) {
    return PickerPluralCategory.few;
  }
  return PickerPluralCategory.many;
}

PickerPluralCategory _polish(int n) {
  if (n == 1) return PickerPluralCategory.one;
  final ten = n % 10;
  final hundred = n % 100;
  if (_within(ten, 2, 4) && !_within(hundred, 12, 14)) {
    return PickerPluralCategory.few;
  }
  return PickerPluralCategory.many;
}

/// Czech and Slovak. Their `many` is for decimals only.
PickerPluralCategory _czech(int n) => n == 1
    ? PickerPluralCategory.one
    : _within(n, 2, 4)
        ? PickerPluralCategory.few
        : PickerPluralCategory.other;

PickerPluralCategory _lithuanian(int n) {
  final ten = n % 10;
  final hundred = n % 100;
  if (_within(hundred, 11, 19)) return PickerPluralCategory.other;
  if (ten == 1) return PickerPluralCategory.one;
  if (_within(ten, 2, 9)) return PickerPluralCategory.few;
  return PickerPluralCategory.other;
}

PickerPluralCategory _latvian(int n) {
  final ten = n % 10;
  final hundred = n % 100;
  if (ten == 0 || _within(hundred, 11, 19)) return PickerPluralCategory.zero;
  if (ten == 1 && hundred != 11) return PickerPluralCategory.one;
  return PickerPluralCategory.other;
}

PickerPluralCategory _arabic(int n) {
  final hundred = n % 100;
  if (n == 0) return PickerPluralCategory.zero;
  if (n == 1) return PickerPluralCategory.one;
  if (n == 2) return PickerPluralCategory.two;
  if (_within(hundred, 3, 10)) return PickerPluralCategory.few;
  if (_within(hundred, 11, 99)) return PickerPluralCategory.many;
  return PickerPluralCategory.other;
}

PickerPluralCategory _welsh(int n) => switch (n) {
      0 => PickerPluralCategory.zero,
      1 => PickerPluralCategory.one,
      2 => PickerPluralCategory.two,
      3 => PickerPluralCategory.few,
      6 => PickerPluralCategory.many,
      _ => PickerPluralCategory.other,
    };

PickerPluralCategory _hebrew(int n) => switch (n) {
      1 => PickerPluralCategory.one,
      2 => PickerPluralCategory.two,
      _ => PickerPluralCategory.other,
    };

PickerPluralCategory _slovenian(int n) => switch (n % 100) {
      1 => PickerPluralCategory.one,
      2 => PickerPluralCategory.two,
      3 || 4 => PickerPluralCategory.few,
      _ => PickerPluralCategory.other,
    };

/// Croatian and Serbian.
PickerPluralCategory _southSlavic(int n) {
  final ten = n % 10;
  final hundred = n % 100;
  if (ten == 1 && hundred != 11) return PickerPluralCategory.one;
  if (_within(ten, 2, 4) && !_within(hundred, 12, 14)) {
    return PickerPluralCategory.few;
  }
  return PickerPluralCategory.other;
}

PickerPluralCategory _romanian(int n) {
  if (n == 1) return PickerPluralCategory.one;
  if (n == 0 || _within(n % 100, 1, 19)) return PickerPluralCategory.few;
  return PickerPluralCategory.other;
}

/// Every locale the strings ship, by the tag they ship under.
const Map<String, _Rule> _rules = <String, _Rule>{
  'ar': _arabic,
  'be': _eastSlavic,
  'bg': _oneOther,
  'ca': _spanish,
  'cs': _czech,
  'cy': _welsh,
  'da': _oneOther,
  'de': _oneOther,
  'el': _oneOther,
  'en': _oneOther,
  'es': _spanish,
  'et': _oneOther,
  'fa': _zeroAndOne,
  'fi': _oneOther,
  'fr': _french,
  'he': _hebrew,
  'hi': _zeroAndOne,
  'hr': _southSlavic,
  'hu': _oneOther,
  'id': _otherOnly,
  'it': _spanish,
  'ja': _otherOnly,
  'ko': _otherOnly,
  'ku': _oneOther,
  'lt': _lithuanian,
  'lv': _latvian,
  'ms': _otherOnly,
  'nl': _oneOther,
  'no': _oneOther,
  'pl': _polish,
  'pt': _french,
  'ro': _romanian,
  'ru': _eastSlavic,
  'sk': _czech,
  'sl': _slovenian,
  'sr': _southSlavic,
  'sv': _oneOther,
  'th': _otherOnly,
  'tr': _oneOther,
  'uk': _eastSlavic,
  'vi': _otherOnly,
  'zh': _otherOnly,
  'zh-Hans': _otherOnly,
  'zh-Hant': _otherOnly,
};
