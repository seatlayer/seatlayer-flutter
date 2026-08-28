// Where `auto` gets its answer from, and in what order.
//
// It used to read `MediaQuery.platformBrightness` only. That is the DEVICE's
// setting, not the buyer's: an app with its own dark-mode switch — the
// ordinary `MaterialApp(themeMode:)` — could be sitting in dark mode on a
// light phone, and the picker opened white inside it.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

/// Resolve `auto` for the tree [build] puts around the probe.
Future<Brightness> _resolve(
  WidgetTester tester,
  Widget Function(Widget probe) build, {
  SeatLayerThemeMode mode = SeatLayerThemeMode.auto,
}) async {
  late Brightness resolved;
  await tester.pumpWidget(
    build(
      Builder(
        builder: (context) {
          resolved = resolveSeatLayerThemeBrightness(context, mode);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return resolved;
}

/// A bare tree with no Material or Cupertino theme anywhere in it.
Widget _noTheme(Brightness platform, Widget probe) => MediaQuery(
      data: MediaQueryData(platformBrightness: platform),
      child: Directionality(textDirection: TextDirection.ltr, child: probe),
    );

void main() {
  testWidgets('auto follows the host application, not the device',
      (tester) async {
    // The app is in dark mode. The phone is not. The buyer chose the app.
    final resolved = await _resolve(
      tester,
      (probe) => MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.light),
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          themeAnimationDuration: Duration.zero,
          home: probe,
        ),
      ),
    );

    expect(resolved, Brightness.dark);
  });

  testWidgets('and re-resolves when the host flips its own theme',
      (tester) async {
    Widget build(Brightness host, Widget probe) => MaterialApp(
          theme: ThemeData(brightness: host),
          themeAnimationDuration: Duration.zero,
          home: probe,
        );

    expect(
      await _resolve(tester, (probe) => build(Brightness.light, probe)),
      Brightness.light,
    );
    expect(
      await _resolve(tester, (probe) => build(Brightness.dark, probe)),
      Brightness.dark,
    );
  });

  testWidgets('a Cupertino host is asked the same question', (tester) async {
    final resolved = await _resolve(
      tester,
      (probe) => MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.light),
        child: CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: probe,
        ),
      ),
    );

    expect(resolved, Brightness.dark);
  });

  testWidgets('with no host theme at all, auto falls back to the device',
      (tester) async {
    // `Theme.of` would answer "light" here, because that is its fallback —
    // which reads as a choice the host never made. The device is asked
    // instead.
    expect(
      await _resolve(tester, (probe) => _noTheme(Brightness.dark, probe)),
      Brightness.dark,
    );
    expect(
      await _resolve(tester, (probe) => _noTheme(Brightness.light, probe)),
      Brightness.light,
    );
  });

  testWidgets('an explicit mode wins over both', (tester) async {
    Widget build(Widget probe) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            themeAnimationDuration: Duration.zero,
            home: probe,
          ),
        );

    expect(
      await _resolve(tester, build, mode: SeatLayerThemeMode.light),
      Brightness.light,
    );
    expect(
      await _resolve(tester, build, mode: SeatLayerThemeMode.dark),
      Brightness.dark,
    );
  });
}
