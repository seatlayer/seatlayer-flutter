import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_styles.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

ButtonStyle _squareFilled() => FilledButton.styleFrom(
      shape: const RoundedRectangleBorder(),
    );

Future<void> _ignore(SeatLayerCheckoutHandoff handoff) async {}

OutlinedBorder? _shapeOf(WidgetTester tester, Finder button) {
  final style = tester.widget<FilledButton>(button).style;
  return style?.shape?.resolve(const <WidgetState>{});
}

void main() {
  testWidgets('the peek Continue is not a pill by default', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: false,
            onExpandedChanged: (_) {},
            onCheckout: (_) async {},
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    // Material 3 would round this to a stadium; the picker's own button radius
    // is what it carries instead, both in the style it resolves and in the
    // Material it actually paints.
    final button = find.byType(FilledButton);
    expect(button, findsOneWidget);
    expect(_shapeOf(tester, button), isA<RoundedRectangleBorder>());
    expect(
      (_shapeOf(tester, button)! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(SeatLayerRadiusTokens.button),
    );
    final painted = tester
        .widget<Material>(
          find.descendant(of: button, matching: find.byType(Material)).first,
        )
        .shape;
    expect(painted, isA<RoundedRectangleBorder>());
  });

  testWidgets('a continue slot reaches the rendered peek button',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: false,
            onExpandedChanged: (_) {},
            onCheckout: (_) async {},
          ),
        ),
        theme: SeatLayerPickerThemeData(
          styles: SeatLayerPickerStyles(continueButtonStyle: _squareFilled()),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final button = find.byType(FilledButton);
    expect(button, findsOneWidget);
    expect(_shapeOf(tester, button), isA<RoundedRectangleBorder>());
    expect(
      (_shapeOf(tester, button)! as RoundedRectangleBorder).borderRadius,
      BorderRadius.zero,
    );
  });

  testWidgets('a per-instance style wins over the theme slot', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: false,
            onExpandedChanged: (_) {},
            onCheckout: (_) async {},
            continueButtonStyle: FilledButton.styleFrom(
              shape: const StadiumBorder(),
            ),
          ),
        ),
        theme: SeatLayerPickerThemeData(
          styles: SeatLayerPickerStyles(continueButtonStyle: _squareFilled()),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      _shapeOf(tester, find.byType(FilledButton)),
      isA<StadiumBorder>(),
    );
  });

  testWidgets('a primary slot still reshapes the book button', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerBookButton(onCheckout: _ignore),
        ),
        theme: SeatLayerPickerThemeData(
          styles: SeatLayerPickerStyles(
            primaryButtonStyle:
                FilledButton.styleFrom(shape: const StadiumBorder()),
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      _shapeOf(tester, find.byType(FilledButton)),
      isA<StadiumBorder>(),
    );
  });

  testWidgets('a dock slot repaints the bar without replacing it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerDockBar(
            style: SeatLayerSurfaceStyle(color: Color(0xFF123456)),
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    final bar = tester.widgetList<Material>(
      find.descendant(
        of: find.byType(SeatLayerDockBar),
        matching: find.byType(Material),
      ),
    );
    expect(
      bar.any((material) => material.color == const Color(0xFF123456)),
      isTrue,
    );
  });

  test('slots merge rather than replace one another', () {
    const base = SeatLayerPickerStyles(chipShape: RoundedRectangleBorder());
    final merged = base.merge(
      SeatLayerPickerStyles(primaryButtonStyle: _squareFilled()),
    );
    expect(merged.chipShape, isA<RoundedRectangleBorder>());
    expect(merged.primaryButtonStyle, isNotNull);
  });
}
