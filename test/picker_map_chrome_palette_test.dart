// Chrome drawn on the map follows the MAP's palette, not the picker's side.
//
// The immersive scene is dark whatever side the picker is on. Anything capping
// that surface has to go dark with it, or it reads as a mistake: the first
// 3D screenshots show an amber TEST MODE lozenge and a white cart sheet over a
// dark venue, beside a header and legend that had already gone dark.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
          of: find.text('TEST MODE'),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (box.decoration as BoxDecoration).color!;
}

Color _badgeInk(WidgetTester tester) =>
    tester.widget<Text>(find.text('TEST MODE')).style!.color!;

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
  testWidgets('the test badge is an amber lozenge on a light map',
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

    expect(_badgeGround(tester), SeatLayerLightTokens.warning);
    expect(_badgeInk(tester), const Color(0xFF1A1200));
  });

  testWidgets('the test badge goes dark with a dark map', (tester) async {
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

    expect(_badgeGround(tester), isNot(SeatLayerLightTokens.warning));
    expect(_badgeInk(tester), SeatLayerLightTokens.warning);
  });

  testWidgets('the test badge goes dark inside the scene, on a LIGHT picker',
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

    expect(_badgeInk(tester), SeatLayerLightTokens.warning);
    expect(_badgeGround(tester), isNot(SeatLayerLightTokens.warning));
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
}
