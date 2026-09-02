// Generates `lib/src/picker/picker_tokens.g.dart` from `design/tokens.json`.
//
//   dart run tool/gen_tokens.dart          # write the file
//   dart run tool/gen_tokens.dart --check  # fail if it is out of date
//
// `design/tokens.json` is the single source for the picker's colours, sizes,
// radii, elevations, type scale, motion and default strings. Keeping the Dart
// defaults generated is what stops the Flutter package and the iOS, Android
// and React Native ports from drifting apart: they all read one file.
import 'dart:convert';
import 'dart:io';

const String _output = 'lib/src/picker/picker_tokens.g.dart';
const String _input = 'design/tokens.json';

void main(List<String> args) {
  final check = args.contains('--check');
  final tokens =
      jsonDecode(File(_input).readAsStringSync()) as Map<String, Object?>;
  final generated = _render(tokens);
  final file = File(_output);

  // Compare formatted against formatted: `dart format` is part of the
  // repository's own definition of correct source, so a generator that emitted
  // unformatted text would leave the file permanently "stale".
  final formatted = _formatted(generated);

  if (!check) {
    file.writeAsStringSync(formatted);
    stdout.writeln('wrote $_output');
    return;
  }
  final current = file.existsSync() ? file.readAsStringSync() : '';
  if (current == formatted) {
    stdout.writeln('$_output is up to date');
    return;
  }
  stderr.writeln(
    '$_output is out of date. Run `dart run tool/gen_tokens.dart`.',
  );
  exitCode = 1;
}

/// [source] as `dart format` would write it.
String _formatted(String source) {
  final scratch = Directory.systemTemp.createTempSync('seatlayer-tokens');
  try {
    final file = File('${scratch.path}/picker_tokens.g.dart')
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

Map<String, Object?> _map(Object? value) => value! as Map<String, Object?>;

String _color(Object? value) {
  final hex = (value! as String).replaceFirst('#', '');
  final argb = hex.length == 6 ? 'FF$hex' : hex;
  return 'Color(0x${argb.toUpperCase()})';
}

num _num(Object? value) => value! as num;

String _double(Object? value) {
  final value0 = _num(value);
  return value0 == value0.roundToDouble()
      ? '${value0.toInt()}'
      : '$value0';
}

String _dartString(Object? value) {
  final escaped = (value! as String)
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');
  return "'$escaped'";
}

String _render(Map<String, Object?> tokens) {
  final light = _map(_map(tokens['color'])['light']);
  final dark = _map(_map(tokens['color'])['dark']);
  final size = _map(tokens['size']);
  final radius = _map(tokens['radius']);
  final elevation = _map(tokens['elevation']);
  final motion = _map(tokens['motion']);
  final durations = _map(motion['duration']);
  final outside = _map(motion['durationOutsideBudget']);
  final physics = _map(motion['physics']);
  final haptics = _map(tokens['haptics']);
  final strings = _map(tokens['strings']);

  final buffer = StringBuffer()
    ..writeln('// GENERATED — do not edit.')
    ..writeln('//')
    ..writeln('// Source: $_input')
    ..writeln('// Regenerate: dart run tool/gen_tokens.dart')
    ..writeln('//')
    ..writeln('// This file is the one place the picker\'s spec numbers enter')
    ..writeln('// Dart. Change the JSON, not this file.')
    ..writeln("import 'dart:ui' show Color;")
    ..writeln()
    ..writeln('/// The design-token version this file was generated from.')
    ..writeln('const int seatLayerTokensVersion = ${_num(tokens['version'])};')
    ..writeln()
    ..writeln('/// The light palette.')
    ..writeln('abstract final class SeatLayerLightTokens {');
  light.forEach((key, value) {
    buffer.writeln('  /// `$value`');
    buffer.writeln('  static const Color $key = ${_color(value)};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// The dark palette.')
    ..writeln('abstract final class SeatLayerDarkTokens {');
  dark.forEach((key, value) {
    buffer.writeln('  /// `$value`');
    buffer.writeln('  static const Color $key = ${_color(value)};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// The measured sizes the phone chrome is built from.')
    ..writeln('abstract final class SeatLayerSizeTokens {');
  size.forEach((key, value) {
    // Two of the size tokens are counts of things rather than measurements,
    // and a count that arrives as `4.0` cannot index a list.
    const Set<String> counts = <String>{
      'denseVisibleLines',
      'denseCollapseFrom',
    };
    final isCount = counts.contains(key);
    buffer.writeln('  /// `$value`');
    buffer.writeln(
      isCount
          ? '  static const int $key = ${_num(value).toInt()};'
          : '  static const double $key = ${_double(value)};',
    );
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// Corner radii.')
    ..writeln('abstract final class SeatLayerRadiusTokens {');
  radius.forEach((key, value) {
    buffer.writeln('  /// `$value`');
    buffer.writeln('  static const double $key = ${_double(value)};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// Material elevations.')
    ..writeln('abstract final class SeatLayerElevationTokens {');
  elevation.forEach((key, value) {
    buffer.writeln('  /// `$value`');
    buffer.writeln('  static const double $key = ${_double(value)};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// Motion durations, in milliseconds.')
    ..writeln('abstract final class SeatLayerMotionTokens {')
    ..writeln('  /// Nothing in [durations] may exceed this.')
    ..writeln(
      '  static const int budgetMs = ${_num(motion['budgetMs']).toInt()};',
    );
  durations.forEach((key, value) {
    buffer.writeln('  /// `$value` ms');
    buffer.writeln('  static const int $key = ${_num(value).toInt()};');
  });
  outside.forEach((key, value) {
    buffer.writeln('  /// `$value` ms — deliberately outside the budget.');
    buffer.writeln('  static const int $key = ${_num(value).toInt()};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// What a finger on glass is answered with.')
    ..writeln('///')
    ..writeln('/// Native-only: the web picker has no simulation to feed.')
    ..writeln('abstract final class SeatLayerPhysicsTokens {');
  physics.forEach((key, value) {
    if (key == 'note') return;
    buffer.writeln('  /// `$value`');
    buffer.writeln('  static const double $key = ${_double(value)};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// Which platform haptic each cue fires.')
    ..writeln('abstract final class SeatLayerHapticTokens {');
  haptics.forEach((key, value) {
    if (key == 'note') return;
    buffer.writeln('  /// `$value`');
    buffer.writeln('  static const String $key = ${_dartString(value)};');
  });
  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// The English default for every buyer-facing chrome string.')
    ..writeln('abstract final class SeatLayerStringTokens {');
  strings.forEach((key, value) {
    buffer.writeln('  /// $value');
    buffer.writeln('  static const String $key = ${_dartString(value)};');
  });
  buffer.writeln('}');
  return buffer.toString();
}
