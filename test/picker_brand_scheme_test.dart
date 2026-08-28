// One call has to apply a whole brand.
//
// A host that already has a `ColorScheme` should not have to name eight
// picker roles to stop the picker rendering in SeatLayer's indigo, and the
// accent it hands over has to reach EVERY accented element — the peek's
// Continue, the confirm card's Select, Find N best seats, the hold pill, the
// Map/3D control — not just the first one anyone checked.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The pilot's own brand: Reference app red.
const Color _brandRed = Color(0xFFE54558);

ColorScheme _scheme(Brightness brightness) =>
    ColorScheme.fromSeed(seedColor: _brandRed, brightness: brightness);

/// The picker theme a host gets from its own scheme.
SeatLayerPickerThemeData _branded(Brightness brightness) =>
    SeatLayerPickerThemeData.fromColorScheme(_scheme(brightness));

/// Every filled action on screen, and the colour it actually renders.
Iterable<Color?> _filledBackgrounds(WidgetTester tester) =>
    tester.widgetList<Material>(find.byType(Material)).map(
          (material) => material.color,
        );

void main() {
  group('fromColorScheme maps the whole palette', () {
    test('the brand roles come straight off the scheme', () {
      final scheme = _scheme(Brightness.light);
      final theme = SeatLayerPickerThemeData.fromColorScheme(scheme);

      expect(theme.accent, scheme.primary);
      expect(theme.onAccent, scheme.onPrimary);
      expect(theme.surface, scheme.surface);
      expect(theme.text, scheme.onSurface);
      expect(theme.mutedText, scheme.onSurfaceVariant);
      expect(theme.divider, scheme.outlineVariant);
      expect(theme.error, scheme.error);
    });

    test('the page is a step under the chrome, on both sides', () {
      for (final brightness in Brightness.values) {
        final theme = _branded(brightness);
        expect(
          theme.background!.computeLuminance(),
          lessThan(theme.surface!.computeLuminance()),
          reason: 'the chrome must read as raised above the page in '
              '${brightness.name}',
        );
      }
    });

    test('every role is still overridable', () {
      const mine = Color(0xFF00FF88);
      final theme = SeatLayerPickerThemeData.fromColorScheme(
        _scheme(Brightness.light),
        accent: mine,
        background: mine,
        text: mine,
      );

      expect(theme.accent, mine);
      expect(theme.background, mine);
      expect(theme.text, mine);
    });
  });

  testWidgets('of(context) takes the host theme scheme and its typeface',
      (tester) async {
    late SeatLayerPickerThemeData theme;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: _scheme(Brightness.dark),
          fontFamily: 'Roboto',
        ),
        home: Builder(
          builder: (context) {
            theme = SeatLayerPickerThemeData.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(theme.accent, _scheme(Brightness.dark).primary);
    expect(theme.text, _scheme(Brightness.dark).onSurface);
    expect(theme.fontFamily, 'Roboto');
  });

  for (final brightness in Brightness.values) {
    testWidgets('every accented control takes the brand — ${brightness.name}',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      final scheme = _scheme(brightness);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Column(
            children: <Widget>[
              const SeatLayerPickerViewModeControl(),
              const SeatLayerBestSeatsForm(),
              const Expanded(child: SizedBox.shrink()),
              SeatLayerBookButton(onCheckout: (_) {}),
            ],
          ),
          theme: _branded(brightness),
          platformBrightness: brightness,
        ),
      );
      map.emit(bestAvailableSnapshot());
      await tester.pumpAndSettle();

      // Nothing is left standing on SeatLayer's own indigo.
      final painted = _filledBackgrounds(tester).toList();
      expect(
        painted,
        isNot(contains(const Color(0xFF635BFF))),
        reason: 'an accented control kept the SDK accent',
      );
      expect(
        painted,
        contains(scheme.primary),
        reason: "no control took the host's primary",
      );
    });
  }

  testWidgets('a brand accent never recolours a ticket category',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerDockBar(),
        theme: _branded(Brightness.light),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    // The dock's dot stands for a price, not for a brand. Recolouring it would
    // make it disagree with the legend chip it is supposed to match.
    final decorated = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(SeatLayerDockBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((decorated.decoration as BoxDecoration).color,
        const Color(0xFF635BFF));
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('brand scheme — confirm card — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerConfirmCard()),
            theme: _branded(brightness),
            platformBrightness: brightness,
          ),
        );
        map.emit(pickerSnapshot());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'brand_confirm_card_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('brand scheme — cart peek — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            Align(
              alignment: Alignment.bottomCenter,
              child: goldenSubject(
                SeatLayerCartSheet(
                  expanded: false,
                  onExpandedChanged: (_) {},
                  onCheckout: (_) async {},
                ),
              ),
            ),
            theme: _branded(brightness),
            platformBrightness: brightness,
          ),
        );
        map.emit(pickerSnapshot());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'brand_cart_peek_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
