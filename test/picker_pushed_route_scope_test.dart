// Everything the picker pushes onto a Navigator has to keep its own scope.
//
// A route builder runs under the Navigator's overlay, which is an ANCESTOR of
// SeatLayerPickerScope rather than a descendant. Mounting the same widget
// inline — which is what every earlier component test did — cannot fail that
// way, which is why "Best seats" from the cart sheet reached the red screen on
// a real device while the suite stayed green.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The Material surface the pushed bottom sheet is painted on.
Color _modalSheetColor(WidgetTester tester) {
  final sheet = tester.widget<Material>(
    find
        .ancestor(
          of: find.byType(SeatLayerBestSeatsForm).hitTestable(),
          matching: find.byType(Material),
        )
        .last,
  );
  return sheet.color!;
}

void main() {
  testWidgets('best seats opens from the cart sheet through a real Navigator',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerCartSheet(
          expanded: true,
          onExpandedChanged: (_) {},
          onCheckout: (_) {},
        ),
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();
    // A cart with tickets in it is what puts the shortcut in the peek row.
    map.emit(snapshotWithTicketCount(2, revision: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SeatLayerBestSeatsForm), findsOneWidget);
  });

  testWidgets('the pushed best-seats sheet keeps the picker scope alive',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerCartSheet(
          expanded: true,
          onExpandedChanged: (_) {},
          onCheckout: (_) {},
        ),
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();
    map.emit(snapshotWithTicketCount(2, revision: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pumpAndSettle();

    // Not merely mounted: reading the live controller from inside the route is
    // what the crashing build did, and it now answers.
    final inside = tester.element(find.byType(SeatLayerBestSeatsForm));
    expect(
      SeatLayerPickerScope.controllerOf(inside),
      same(SeatLayerPickerScope.controllerOf(
        tester.element(find.byType(SeatLayerCartSheet)),
      )),
    );
    expect(SeatLayerPickerScope.optionsOf(inside), isNotNull);
  });

  testWidgets('a pushed modal wears the picker theme, not the host theme',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    // A DARK picker inside the harness's light Material app: exactly the pilot
    // shape, where the sheet came up white under dark chrome.
    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerCartSheet(
          expanded: true,
          onExpandedChanged: (_) {},
          onCheckout: (_) {},
        ),
        themeMode: SeatLayerThemeMode.dark,
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();
    map.emit(snapshotWithTicketCount(2, revision: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pumpAndSettle();

    expect(_modalSheetColor(tester), SeatLayerDarkTokens.surface);
    final inside = tester.element(find.byType(SeatLayerBestSeatsForm));
    expect(Theme.of(inside).colorScheme.onSurface, SeatLayerDarkTokens.text);
    expect(Theme.of(inside).brightness, Brightness.dark);
  });

  testWidgets('the accessibility sheet is pushed with the scope and the theme',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const Align(
          alignment: Alignment.topLeft,
          child: SeatLayerPickerAccessibilityFilters(compact: true),
        ),
        themeMode: SeatLayerThemeMode.dark,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.accessible_forward_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Accessibility and view'), findsOneWidget);
    final inside = tester.element(find.text('Accessibility and view'));
    // The scope reaches the sheet, so its strings and controller are the
    // picker's — and so is its palette.
    expect(SeatLayerPickerScope.controllerOf(inside), isNotNull);
    expect(Theme.of(inside).colorScheme.onSurface, SeatLayerDarkTokens.text);
  });
}
