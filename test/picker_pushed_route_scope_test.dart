// Everything the picker pushes onto a Navigator has to keep its own scope.
//
// A route builder runs under the Navigator's overlay, which is an ANCESTOR of
// SeatLayerPickerScope rather than a descendant. Mounting the same widget
// inline — which is what every earlier component test did — cannot fail that
// way, which is why a pushed sheet reached the red screen on a real device
// while the suite stayed green.
//
// The accessibility sheet is the picker's one pushed route on a phone: the
// cart keeps no re-entry into the best-seats form, because once a phone cart
// has tickets it stays a cart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  testWidgets('the accessibility sheet is pushed with the scope and the theme',
      (tester) async {
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'access-needs-v1',
        ],
        commands: const <String>['picker.setAccessibilityFilter'],
      ),
    );
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
    map.emit(
      pickerSnapshot(
        accessNeeds: <Object?>[accessNeed('wheelchair', 1)],
      ),
    );
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
