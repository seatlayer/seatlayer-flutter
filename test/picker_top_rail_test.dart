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

/// A snapshot whose catalogue carries [count] sellable categories.
///
/// Prices climb so no two chips are the same width, which is how a real
/// venue's legend runs off the end of the rail.
Map<String, Object?> _snapshotWithCategories(int count) {
  final snapshot = pickerSnapshot();
  final catalog = snapshot['catalog']! as Map<String, Object?>;
  catalog['categories'] = List<Object?>.generate(count, (index) {
    final price = 45.0 + index * 35;
    return <String, Object?>{
      'key': 'tier-$index',
      'label': 'Tier $index',
      'color': '#635BFF',
      'priceMin': price,
      'priceMax': price,
      'available': 10,
      'notForSale': false,
      'tiers': <Object?>[],
    };
  });
  (snapshot['map']! as Map<String, Object?>)['categoryFilter'] = <Object?>[];
  return snapshot;
}

void main() {
  for (final count in <int>[5, 8]) {
    testWidgets('the phone top rail never draws Map/3D over $count prices',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_snapshotWithCategories(count));
      await tester.pumpAndSettle();

      final control = find.byType(SeatLayerPickerViewModeControl);
      expect(control, findsOneWidget);
      final prices = tester.getRect(find.byType(SeatLayerPriceLegend));
      expect(tester.getRect(control).left, greaterThanOrEqualTo(prices.right));
    });
  }

  testWidgets('a legend that runs off the rail fades rather than cuts',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_snapshotWithCategories(8));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SeatLayerPriceLegend),
        matching: find.byType(ShaderMask),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a legend that fits the rail draws no soft edge', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_snapshotWithCategories(1));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SeatLayerPriceLegend),
        matching: find.byType(ShaderMask),
      ),
      findsNothing,
    );
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
