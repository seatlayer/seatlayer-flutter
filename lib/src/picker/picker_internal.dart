import 'dart:async';

import 'package:flutter/widgets.dart';

import 'picker_models.dart';
import 'seat_layer_picker_scope.dart';

/// [color] at [opacity], without the deprecated `withOpacity`.
Color pickerAlpha(Color color, double opacity) =>
    color.withAlpha((opacity.clamp(0, 1) * 255).round());

/// Parse a chart-authored `#rrggbb` or `#aarrggbb` colour, or null.
Color? pickerColor(String? raw) {
  if (raw == null) return null;
  final value = raw.trim().replaceFirst('#', '');
  if (value.length != 6 && value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}

/// Render [amount] the way the host asked, or with SeatLayer's own compact
/// format when the host supplied no formatter.
String pickerMoney(BuildContext context, double amount, String currency) {
  final formatter = SeatLayerPickerScope.optionsOf(context).pricing?.formatter;
  if (formatter != null) return formatter(amount, currency);
  return pickerCompactMoney(amount, currency);
}

/// `$75`, `€1,080` — symbol where one is known, currency code where it is not.
String pickerCompactMoney(double amount, String currency) {
  const symbols = <String, String>{
    'EUR': '€',
    'USD': r'$',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'KRW': '₩',
  };
  final decimals = amount == amount.roundToDouble() ? 0 : 2;
  final value = amount.toStringAsFixed(decimals);
  final code = currency.toUpperCase();
  final symbol = symbols[code];
  return symbol == null ? '$code $value' : '$symbol$value';
}

/// Run a controller action for its effect.
///
/// Every failure a picker action can have is already published as typed state
/// on the controller and rendered by [SeatLayerPickerActionError]; letting the
/// same failure also escape as an unhandled Future error would only crash the
/// zone that started it.
void ignorePickerAction(Future<void> action) {
  unawaited(action.catchError((Object _) {}));
}

/// Separators a chart puts between a section token and the row's own name.
const List<String> _rowPrefixSeparators = <String>[
  '-',
  '\u00b7', // ·
  '/',
  ' ',
  '\u2013', // en dash
  '\u2014', // em dash
];

/// The row's own name, with the section it already names taken back off.
///
/// Charts are commonly authored with fully qualified row names, in two shapes.
/// A row in `Stalls D` is stored as `Stalls D C`, and a row in `Gallery` is
/// stored under the section's CODE as `GALL-H`. The snapshot repeats whichever
/// the chart used, verbatim, so printing it beside the section it already
/// contains gives `Stalls D · Row Stalls D C` or `Gallery · Row GALL-H`.
///
/// Three things are taken off, in order of how certain they are:
///
/// 1. the section's own label, when the row literally starts with it;
/// 2. a leading token equal to [sectionCode] — the section's code, short code
///    or id, whichever the snapshot exposed;
/// 3. a leading ALL-CAPS token that is a prefix of the section's name, which
///    is what `GALL-` is to `Gallery` and `ORCH-` to `Orchestra`.
///
/// Anything else is left exactly as the chart authored it: a row that shares
/// no prefix with its section keeps its whole name, a row that is nothing but
/// its section keeps its full name rather than becoming empty, and a row with
/// no separator at all — a bare `A` — is never mistaken for a code.
String pickerRowLabel(
  String? rowLabel,
  String? sectionLabel, {
  String? sectionCode,
}) {
  final row = rowLabel?.trim() ?? '';
  final section = sectionLabel?.trim() ?? '';
  if (row.isEmpty) return row;

  if (section.isNotEmpty &&
      row.toLowerCase().startsWith(section.toLowerCase())) {
    final rest = _withoutLeadingSeparator(row.substring(section.length));
    if (rest.isNotEmpty) return rest;
  }

  final split = _splitLeadingToken(row);
  if (split == null) return row;
  final (head, rest) = split;
  if (rest.isEmpty) return row;
  return _namesSection(head, section, sectionCode) ? rest : row;
}

/// [value] without a separator the section's name left behind.
String _withoutLeadingSeparator(String value) {
  var rest = value.trim();
  while (rest.isNotEmpty && _rowPrefixSeparators.contains(rest[0])) {
    rest = rest.substring(1).trim();
  }
  return rest;
}

/// [row] as its first token and everything after it, or null with no separator.
(String, String)? _splitLeadingToken(String row) {
  for (var index = 0; index < row.length; index++) {
    if (!_rowPrefixSeparators.contains(row[index])) continue;
    return (
      row.substring(0, index),
      _withoutLeadingSeparator(row.substring(index)),
    );
  }
  return null;
}

/// Whether [head] is the section saying its own name again.
bool _namesSection(String head, String section, String? code) {
  if (head.isEmpty) return false;
  final upper = head.toUpperCase();
  final trimmedCode = code?.trim() ?? '';
  if (trimmedCode.isNotEmpty && upper == trimmedCode.toUpperCase()) return true;
  if (section.isEmpty) return false;
  if (upper == section.toUpperCase()) return true;
  // An abbreviation, and only an abbreviation: a mixed-case token is a place
  // name in its own right, and one letter is a row group far more often than
  // it is a section code.
  if (head != upper || head.length < 2) return false;
  if (!RegExp('[A-Z]').hasMatch(head)) return false;
  return section.toUpperCase().replaceAll(' ', '').startsWith(upper);
}

/// The code the snapshot gave the section named [sectionLabel], if any.
///
/// Sections travel with an id as well as a label, and a chart authored with
/// `id: GALL, label: Gallery` names its rows `GALL-H`. Handing the id to
/// [pickerRowLabel] strips exactly that token, without leaning on the
/// abbreviation rule.
String? pickerSectionCode(
  SeatLayerPickerState state,
  String? sectionLabel,
) {
  final label = sectionLabel?.trim().toLowerCase();
  if (label == null || label.isEmpty) return null;
  for (final section
      in state.snapshot?.sections ?? const <SeatLayerPickerSectionSummary>[]) {
    if (section.label.trim().toLowerCase() == label ||
        section.displayLabel?.trim().toLowerCase() == label) {
      return section.id;
    }
  }
  return null;
}

/// The colour that stands for a section in native chrome.
///
/// The section reports both a resolved colour and the key of the category most
/// of its free seats belong to. The key is preferred: it resolves against the
/// same category list the legend paints from, so the dot beside a section name
/// and the chip beside its price are one colour rather than two that agree
/// only until a palette changes underneath them. A colourblind-safe repaint is
/// exactly that case.
///
/// Falls back to the section's own colour, then to [fallback], for a section
/// with nothing free to be dominant and for runtimes that report no key.
Color pickerSectionColor(
  SeatLayerPickerSectionSummary section,
  List<SeatLayerPickerCategory> categories, {
  required Color fallback,
}) {
  final key = section.dominantCategoryKey;
  if (key != null) {
    for (final category in categories) {
      if (category.key == key) {
        final resolved = pickerColor(category.color);
        if (resolved != null) return resolved;
      }
    }
  }
  return pickerColor(section.color) ?? fallback;
}
