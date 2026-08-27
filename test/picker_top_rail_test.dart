import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The layout with the WebView replaced, so the composition can be tested
/// without a platform view.
Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(),
      ),
    );

void main() {
  testWidgets('the phone top rail never draws Map/3D over the prices',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final control = find.byType(SeatLayerPickerViewModeControl);
    expect(control, findsOneWidget);
    final prices = tester.getRect(find.byType(SeatLayerPriceLegend));
    expect(tester.getRect(control).left, greaterThanOrEqualTo(prices.right));
  });

  testWidgets('a composed host still gets Map/3D from the map controls',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerMapControls(compact: true)),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerPickerViewModeControl), findsOneWidget);
  });
}
