import 'dart:async';

import 'package:flutter/widgets.dart';

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

/// The row's own name, with the section's name taken back off the front.
///
/// Charts are commonly authored with fully qualified row names — a row in
/// `Stalls D` is stored as `Stalls D C` — and the snapshot repeats that name
/// verbatim. Printing it beside the section it already contains gives
/// `Stalls D · Row Stalls D C`, so the shared prefix comes off before the row
/// is shown. A row whose name does not start with its section is left alone,
/// and a row that is nothing but its section keeps its full name rather than
/// becoming empty.
String pickerRowLabel(String? rowLabel, String? sectionLabel) {
  final row = rowLabel?.trim() ?? '';
  final section = sectionLabel?.trim() ?? '';
  if (row.isEmpty || section.isEmpty) return row;
  if (!row.toLowerCase().startsWith(section.toLowerCase())) return row;
  final rest = row.substring(section.length).trim();
  return rest.isEmpty ? row : rest;
}
