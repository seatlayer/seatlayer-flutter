// Generates the per-locale defaults for `SeatLayerPickerStrings`.
//
//   dart run tool/gen_locale_strings.dart          # write the files
//   dart run tool/gen_locale_strings.dart --check  # fail if any is stale
//
// Input is `design/locale_strings.json`, which is itself rebuilt from the
// SeatLayer runtime's own dictionaries by `tool/extract_runtime_locales.mjs`.
// Output is one `lib/src/picker/picker_strings.<locale>.g.dart` per locale and
// one index the resolver reads.
//
// Why generated and not hand-written: the runtime already ships a reviewed
// translation of these sentences for thirty-seven locales. Writing them again
// on this side would be the same words drifting in two places.
import 'dart:convert';
import 'dart:io';

const String _input = 'design/locale_strings.json';
const String _outputDirectory = 'lib/src/picker';
const String _indexFile = 'lib/src/picker/picker_strings_locales.g.dart';

/// Strings that are one value and nothing else.
const List<String> _plainFields = <String>[
  'close',
  'overview',
  'backToVenue',
  'cancel',
  'select',
  'viewFromHere',
  'openVenue360',
  'recentre',
  'viewFromYourSeat',
  'emptyTrayHint',
  'anyTicketType',
  'anyVenueZone',
  'bestSeats',
  'showLess',
  'undo',
  'holdAndCheckout',
  'poweredBy',
  'testMode',
  'accessibility',
  'accessibilityTitle',
  'fitVenue',
  'loading',
  'errorMessage',
  'retry',
  'hideLimitedView',
  'colorblindSafe',
];

/// Strings the runtime writes with one placeholder, and the Dart parameter
/// that fills it.
const Map<String, ({String parameter, String type, String placeholder})>
    _interpolated =
    <String, ({String parameter, String type, String placeholder})>{
  'seatsLeft': (parameter: 'count', type: 'int', placeholder: '{count}'),
  'moreCount': (parameter: 'count', type: 'int', placeholder: '{count}'),
  'addMinutes': (parameter: 'minutes', type: 'int', placeholder: '{count}'),
  'fromPrice': (parameter: 'money', type: 'String', placeholder: '{price}'),
  'sightline': (parameter: 'metres', type: 'String', placeholder: '{m}'),
};

/// Strings with a singular and a plural form.
const List<String> _plurals = <String>[
  'ticketCount',
  'findBestSeats',
  'reselectSeats',
];

void main(List<String> args) {
  final check = args.contains('--check');
  final raw =
      jsonDecode(File(_input).readAsStringSync()) as Map<String, Object?>;
  final table = raw['strings']! as Map<String, Object?>;
  final locales = table.keys.toList()..sort();

  final wanted = <String, String>{};
  for (final locale in locales) {
    wanted[_pathFor(locale)] = _formatted(
        _renderLocale(locale, (table[locale]! as Map<String, Object?>)));
  }
  wanted[_indexFile] = _formatted(_renderIndex(locales));

  final stale = <String>[];
  for (final entry in wanted.entries) {
    final file = File(entry.key);
    final current = file.existsSync() ? file.readAsStringSync() : '';
    if (current == entry.value) continue;
    stale.add(entry.key);
    if (!check) file.writeAsStringSync(entry.value);
  }
  // A locale removed upstream leaves a file behind that nothing imports and
  // every reader still believes.
  for (final orphan in _orphans(wanted.keys.toSet())) {
    stale.add(orphan);
    if (!check) File(orphan).deleteSync();
  }

  if (!check) {
    stdout.writeln('wrote ${wanted.length} files (${stale.length} changed)');
    return;
  }
  if (stale.isEmpty) {
    stdout.writeln('${wanted.length} locale files are up to date');
    return;
  }
  stderr.writeln(
    'stale: ${stale.join(', ')}\n'
    'Run `dart run tool/gen_locale_strings.dart`.',
  );
  exitCode = 1;
}

/// Generated files under [_outputDirectory] that [wanted] does not claim.
List<String> _orphans(Set<String> wanted) {
  final directory = Directory(_outputDirectory);
  if (!directory.existsSync()) return const <String>[];
  return <String>[
    for (final entity in directory.listSync())
      if (entity is File &&
          RegExp(r'picker_strings\.[a-z_]+\.g\.dart$').hasMatch(entity.path) &&
          !wanted.contains(entity.path))
        entity.path,
  ]..sort();
}

String _pathFor(String locale) =>
    '$_outputDirectory/picker_strings.${_fileTag(locale)}.g.dart';

/// `zh-Hans` as it appears in a file name.
String _fileTag(String locale) => locale.toLowerCase().replaceAll('-', '_');

/// `zh-Hans` as it appears in an identifier.
String _identifier(String locale) => locale
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
    .join();

String _renderLocale(String locale, Map<String, Object?> values) {
  final buffer = StringBuffer()
    ..writeln(_header(locale))
    ..writeln("import 'picker_strings.dart';")
    ..writeln();

  final suffix = _identifier(locale);
  final functions = <String, String>{};

  for (final entry in _interpolated.entries) {
    final value = values[entry.key] as String?;
    if (value == null) continue;
    final name = '_${entry.key}$suffix';
    functions[entry.key] = name;
    buffer
      ..writeln(
        'String $name(${entry.value.type} ${entry.value.parameter}) => '
        '${_template(value, entry.value.placeholder, entry.value.parameter)};',
      )
      ..writeln();
  }

  for (final field in _plurals) {
    final other = values['$field.other'] as String?;
    if (other == null) continue;
    // A locale with no `one` category — Japanese, Chinese, Korean — uses the
    // same form for both, which is the whole point of it having no `one`.
    final one = (values['$field.one'] as String?) ?? other;
    final name = '_$field$suffix';
    functions[field] = name;
    buffer
      ..writeln(
        'String $name(int count) => count == 1\n'
        '    ? ${_template(one, '{count}', 'count')}\n'
        '    : ${_template(other, '{count}', 'count')};',
      )
      ..writeln();
  }

  final continueWord = values['continueWord'] as String?;
  if (continueWord != null) {
    const name = '_continueWithTotal';
    functions['continueWithTotal'] = '$name$suffix';
    buffer
      ..writeln(
        'String $name$suffix(String money) => '
        "'${_escape(continueWord)} \\u00b7 \$money';",
      )
      ..writeln();
  }

  buffer
    ..writeln('/// The `$locale` defaults for the native picker chrome.')
    ..writeln(
      'const SeatLayerPickerStrings seatLayerPickerStrings$suffix =',
    )
    ..writeln('    SeatLayerPickerStrings(');
  for (final field in _plainFields) {
    final value = values[field] as String?;
    if (value == null) continue;
    buffer.writeln("  $field: '${_escape(value)}',");
  }
  for (final entry in functions.entries) {
    buffer.writeln('  ${entry.key}: ${entry.value},');
  }
  buffer.writeln(');');
  return buffer.toString();
}

String _renderIndex(List<String> locales) {
  final buffer = StringBuffer()
    ..writeln(_header('every locale'))
    ..writeln("import 'picker_strings.dart';");
  for (final locale in locales) {
    buffer.writeln("import 'picker_strings.${_fileTag(locale)}.g.dart';");
  }
  buffer
    ..writeln()
    ..writeln('/// The defaults for every locale the runtime translates.')
    ..writeln('///')
    ..writeln('/// Keyed by the runtime\'s own dictionary name, which is a')
    ..writeln('/// language code or a language-and-script tag.')
    ..writeln(
      'const Map<String, SeatLayerPickerStrings> '
      'seatLayerPickerStringsByLocale =',
    )
    ..writeln('    <String, SeatLayerPickerStrings>{');
  for (final locale in locales) {
    buffer
        .writeln("  '$locale': seatLayerPickerStrings${_identifier(locale)},");
  }
  buffer.writeln('};');
  return buffer.toString();
}

String _header(String subject) => '''
// GENERATED — do not edit.
//
// Source: $_input ($subject)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.
''';

/// Characters that would be read as part of an interpolated name.
final RegExp _identifierPart = RegExp(r'[A-Za-z0-9_]');

/// [value] as a Dart string with [placeholder] replaced by [parameter].
String _template(String value, String placeholder, String parameter) {
  final escaped = _escape(value);
  // `_escape` turns a literal `$` into `\$`, so the only `$` this can
  // introduce is the interpolation being asked for. Braces go on only where
  // the next character would otherwise join the name: Japanese writes the
  // unit straight after the figure ("約{m}m"), where a bare `$metres` parses
  // as an identifier called `metresm`. Bracing everything instead would be
  // simpler and would trip `unnecessary_brace_in_string_interps` on the other
  // thirty-six locales.
  final buffer = StringBuffer();
  var rest = escaped;
  while (true) {
    final at = rest.indexOf(placeholder);
    if (at < 0) break;
    final after = at + placeholder.length;
    final joins = after < rest.length && _identifierPart.hasMatch(rest[after]);
    buffer
      ..write(rest.substring(0, at))
      ..write(joins ? '\${$parameter}' : '\$$parameter');
    rest = rest.substring(after);
  }
  buffer.write(rest);
  return "'$buffer'";
}

String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll("'", r"\'");

/// [source] as `dart format` would write it.
String _formatted(String source) {
  final scratch = Directory.systemTemp.createTempSync('seatlayer-locales');
  try {
    final file = File('${scratch.path}/generated.dart')
      ..writeAsStringSync(source);
    final result = Process.runSync('dart', <String>['format', file.path]);
    if (result.exitCode != 0) {
      throw StateError('dart format failed: ${result.stderr}');
    }
    return file.readAsStringSync();
  } finally {
    scratch.deleteSync(recursive: true);
  }
}
