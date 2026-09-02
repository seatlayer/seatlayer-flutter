// Chrome drawn on the map follows the MAP's palette, not the picker's side.
//
// The immersive scene is dark whatever side the picker is on. Anything capping
// that surface has to go dark with it, or it reads as a mistake: the first
// 3D screenshots show a white cart sheet over a dark venue, beside a header
// and legend that had already gone dark.
//
// The test-mode badge is the one piece that keeps ONE recipe on every ground —
// a tint of the warning colour over the surface behind it — because an
// environment flag that changes its clothes reads as a different state of the
// event rather than the same fact.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_attribution.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The picker in the immersive scene.
Map<String, Object?> _inVenue3D({int revision = 3}) {
  final snapshot = pickerSnapshot(revision: revision);
  (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
  return snapshot;
}

Color _badgeGround(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .ancestor(
          of: find.text('Test mode'),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (box.decoration as BoxDecoration).color!;
}

Color _badgeInk(WidgetTester tester) =>
    tester.widget<Text>(find.text('Test mode')).style!.color!;

Color _sheetGround(WidgetTester tester) => tester
    .widget<Material>(
      find
          .descendant(
            of: find.byType(SeatLayerCartSheet),
            matching: find.byType(Material),
          )
          .first,
    )
    .color!;

void main() {
  /// The badge's recipe, resolved against [surface].
  ({Color ground, Color ink}) badgeRecipe(
          Color warning, Color surface, Color text) =>
      (
        ground: Color.alphaBlend(warning.withAlpha(41), surface),
        ink: Color.lerp(warning, text, .52)!,
      );

  testWidgets('the test badge is a warning tint of the light map',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerTestModeIndicator(compact: true),
        themeMode: SeatLayerThemeMode.light,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final want = badgeRecipe(
      SeatLayerLightTokens.warning,
      SeatLayerLightTokens.surface,
      SeatLayerLightTokens.text,
    );
    expect(_badgeGround(tester), want.ground);
    expect(_badgeInk(tester), want.ink);
    // Never the solid amber lozenge: on a map it reads as a highlighter
    // stripe left on the screen.
    expect(_badgeGround(tester), isNot(SeatLayerLightTokens.warning));
  });

  testWidgets('the same recipe carries onto a dark map', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerTestModeIndicator(compact: true),
        themeMode: SeatLayerThemeMode.dark,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final want = badgeRecipe(
      SeatLayerDarkTokens.warning,
      SeatLayerDarkTokens.surface,
      SeatLayerDarkTokens.text,
    );
    expect(_badgeGround(tester), want.ground);
    expect(_badgeInk(tester), want.ink);
  });

  testWidgets('the badge goes dark inside the scene, on a LIGHT picker',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerTestModeIndicator(compact: true),
        themeMode: SeatLayerThemeMode.light,
      ),
    );
    map.emit(_inVenue3D());
    await tester.pumpAndSettle();

    final want = badgeRecipe(
      SeatLayerDarkTokens.warning,
      SeatLayerDarkTokens.surface,
      SeatLayerDarkTokens.text,
    );
    expect(_badgeGround(tester), want.ground);
    expect(_badgeInk(tester), want.ink);
  });

  testWidgets('the cart sheet takes the scene palette, like the header',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerCartSheet(
          expanded: false,
          onExpandedChanged: (_) {},
          onCheckout: (_) {},
        ),
        themeMode: SeatLayerThemeMode.light,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    expect(_sheetGround(tester), SeatLayerLightTokens.surface);

    map.emit(_inVenue3D(revision: 4));
    await tester.pumpAndSettle();
    expect(_sheetGround(tester), SeatLayerDarkTokens.surface);
  });

  testWidgets('the credit line keeps its words on the scene sheet',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerAttribution(),
        themeMode: SeatLayerThemeMode.light,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    Color ink() =>
        tester.widget<Text>(find.text('Powered by SeatLayer')).style!.color!;
    expect(ink(), SeatLayerLightTokens.text);

    // Dark ink on the dark sheet was the one thing the first 3D build hid.
    map.emit(_inVenue3D(revision: 4));
    await tester.pumpAndSettle();
    expect(ink(), SeatLayerDarkTokens.text);
  });
}
