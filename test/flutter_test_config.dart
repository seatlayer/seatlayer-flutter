import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_header.dart';

/// Makes every test in this package draw the same pixels on every host.
///
/// The goldens were recorded on macOS and failed on the Linux CI runner by a
/// few percent per image, in identical amounts for each light/dark pair.
/// Nothing about the widgets was host-specific. Two things were:
///
///   * **Fonts.** `flutter test` runs the engine with `--use-test-fonts` and
///     `--disable-asset-fonts`, so the only text face available is the Ahem
///     stand-in and no asset-declared font is loaded at all — adding
///     `uses-material-design` to the pubspec would not have helped. Every
///     `Icon` therefore asked for family `MaterialIcons`, found nothing, and
///     fell through to the host's own missing-glyph box, which macOS and Linux
///     draw differently. Fonts registered at runtime through [FontLoader] *are*
///     honoured, so this file registers both faces from bytes that are pinned
///     on every host: Roboto from `test/fonts/` (Apache-2.0, see
///     `test/fonts/LICENSE.txt`) and Material Icons from the pinned Flutter SDK
///     itself, which CI installs at exactly the version this repo builds with.
///
///   * **The clock.** The header golden contains a live hold countdown. Under
///     Ahem every digit was the same box, so the golden never noticed; with a
///     real face it changed every second. The countdown is pinned below.
///
/// A golden must be a picture of the widget, not of the machine that recorded
/// it. As a bonus the goldens stop being a wall of tofu and become readable, so
/// a text-layout or icon regression is now visible in them.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Shadow rasterisation has drifted between engine builds; a golden should not
  // be hostage to that.
  debugDisableShadows = true;

  // A fixed instant, so the hold countdown renders the same digits every run.
  SeatLayerPickerHoldCountdown.debugClock =
      () => DateTime.utc(2026, 1, 1, 12, 0, 0);

  await _loadRoboto();
  await _loadMaterialIcons();

  return testMain();
}

/// The Roboto faces that back every weight the picker asks for.
///
/// Roboto ships 400/500/700/900; the picker also asks for w600 and w800, which
/// the engine resolves to the nearest registered face — the same way on every
/// host, because the faces themselves are the same bytes everywhere.
const List<String> _robotoFaces = <String>[
  'Roboto-Regular.ttf',
  'Roboto-Medium.ttf',
  'Roboto-Bold.ttf',
  'Roboto-Black.ttf',
];

Future<void> _loadRoboto() async {
  final loader = FontLoader('Roboto');
  for (final face in _robotoFaces) {
    loader.addFont(_bytesOf(File('test/fonts/$face')));
  }
  await loader.load();
}

/// Registers the Material Icons face the framework's [Icons] codepoints mean.
///
/// Taken from the running Flutter SDK rather than committed here, so the glyphs
/// can never drift out of step with the `Icons` constants they are drawn for.
Future<void> _loadMaterialIcons() async {
  final root = _flutterRoot();
  final font = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  final loader = FontLoader('MaterialIcons')..addFont(_bytesOf(font));
  await loader.load();
}

/// Where the Flutter SDK that is running this test lives.
String _flutterRoot() {
  final fromEnvironment = Platform.environment['FLUTTER_ROOT'];
  if (fromEnvironment != null && fromEnvironment.isNotEmpty) {
    return fromEnvironment;
  }
  // Fall back to walking up from `bin/cache/artifacts/engine/<host>/flutter_tester`.
  var directory = File(Platform.resolvedExecutable).parent;
  while (directory.path != directory.parent.path) {
    if (Directory('${directory.path}/bin/cache/artifacts/material_fonts')
        .existsSync()) {
      return directory.path;
    }
    directory = directory.parent;
  }
  throw StateError(
    'Could not locate the Flutter SDK to load Material Icons from. Goldens '
    'cannot be recorded or compared without it — see '
    'test/flutter_test_config.dart.',
  );
}

Future<ByteData> _bytesOf(File file) async {
  if (!file.existsSync()) {
    throw StateError(
      'Missing golden font ${file.path}. Goldens cannot be recorded or '
      'compared without it — see test/flutter_test_config.dart.',
    );
  }
  return ByteData.sublistView(await file.readAsBytes());
}
