import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_theme_sync.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_widget_harness.dart';

void main() {
  testWidgets('auto follows the device and re-resolves without a reload',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final observed = <Brightness>[];

    Widget build(Brightness platform) => pickerHarness(
          map,
          Builder(
            builder: (context) {
              observed.add(SeatLayerPickerScope.brightnessOf(context));
              return const SizedBox.shrink();
            },
          ),
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    expect(observed.last, Brightness.light);

    await tester.pumpWidget(build(Brightness.dark));
    expect(observed.last, Brightness.dark);
  });

  testWidgets('an explicit mode ignores the device', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    late Brightness resolved;

    await tester.pumpWidget(
      pickerHarness(
        map,
        Builder(
          builder: (context) {
            resolved = SeatLayerPickerScope.brightnessOf(context);
            return const SizedBox.shrink();
          },
        ),
        themeMode: SeatLayerThemeMode.light,
        platformBrightness: Brightness.dark,
      ),
    );

    expect(resolved, Brightness.light);
  });

  testWidgets('the boot mode is frozen and a flip becomes a live command',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final bootModes = <SeatLayerThemeMode>[];

    Widget build(Brightness platform) => pickerHarness(
          map,
          PickerThemeModeSync(
            builder: (context, boot) {
              bootModes.add(boot.mode);
              return const SizedBox.shrink();
            },
          ),
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    await tester.pump();
    expect(bootModes.last, SeatLayerThemeMode.light);
    expect(map.callsTo('picker.setThemeMode'), isEmpty);

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pump();

    // The init config never changes, so the WebView is never rebuilt.
    expect(bootModes.last, SeatLayerThemeMode.light);
    expect(
      map.callsTo('picker.setThemeMode').single.$2,
      <String, Object?>{'mode': 'dark'},
    );
    expect(map.callsTo('picker.destroy'), isEmpty);
  });

  testWidgets('the host is told which side was resolved', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final announced = <Brightness>[];

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SizedBox.shrink(),
        callbacks: SeatLayerPickerCallbacks(onThemeResolved: announced.add),
        platformBrightness: Brightness.dark,
      ),
    );
    await tester.pump();

    expect(announced, <Brightness>[Brightness.dark]);
  });

  test('both presets keep body text above the 4.5:1 contrast floor', () {
    for (final preset in <SeatLayerPickerThemeData>[
      const SeatLayerPickerThemeData.light(),
      const SeatLayerPickerThemeData.dark(),
    ]) {
      expect(_contrast(preset.text!, preset.surface!), greaterThan(4.5));
      expect(_contrast(preset.text!, preset.background!), greaterThan(4.5));
      expect(_contrast(preset.mutedText!, preset.surface!), greaterThan(4.5));
    }
  });

  test('the light map ground is recessed under white chrome', () {
    expect(
      const SeatLayerMapThemeData.light().toBridgeConfig()['background'],
      '#e9edf4',
    );
    expect(const SeatLayerPickerThemeData.light().surface, Colors.white);
  });
}

double _contrast(Color foreground, Color background) {
  final a = _luminance(foreground);
  final b = _luminance(background);
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

double _luminance(Color color) => color.computeLuminance();
