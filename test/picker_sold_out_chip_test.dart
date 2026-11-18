// A sold-out price stays on the rail, struck through, and stays a toggle.
//
// Removing the chip would rewrite the price ladder the buyer was reading, and
// disabling it would trap a buyer who had pinned that price: the chip they
// switched the filter on with must switch it off. Only a runtime that counts
// seats (`category-availability-v1`) is believed at zero.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

BundleInfo _bundle({required bool counts}) => nativeChromeBundle(
      capabilities: <String>[
        'native-chrome-contract-v1',
        if (counts) 'category-availability-v1',
      ],
    );

Map<String, Object?> _snapshot({int? free, List<Object?>? filter}) {
  final snapshot = pickerSnapshot(withSelection: false);
  final category =
      ((snapshot['catalog']! as Map<String, Object?>)['categories']!
          as List<Object?>)[0]! as Map<String, Object?>;
  if (free != null) category['free'] = free;
  if (filter != null) {
    (snapshot['map']! as Map<String, Object?>)['categoryFilter'] = filter;
  }
  return snapshot;
}

TextDecoration? _decoration(WidgetTester tester) =>
    tester.widget<Text>(find.text('€25')).style?.decoration;

Future<FakePickerMap> _mount(
  WidgetTester tester,
  Map<String, Object?> snapshot, {
  bool counts = true,
}) async {
  final map = FakePickerMap(bundle: _bundle(counts: counts));
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(map, const SeatLayerPriceLegend(compact: true)),
  );
  map.emit(snapshot);
  await tester.pumpAndSettle();
  return map;
}

void main() {
  testWidgets('a counted zero strikes the price and says so', (tester) async {
    final semantics = tester.ensureSemantics();
    await _mount(tester, _snapshot(free: 0));
    expect(_decoration(tester), TextDecoration.lineThrough);
    expect(find.bySemanticsLabel(RegExp(r'€25, Sold out$')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the struck chip still switches the filter on', (tester) async {
    final map = await _mount(tester, _snapshot(free: 0, filter: <Object?>[]));
    await tester.tap(find.text('€25'));
    await tester.pump();
    expect(
      map.callsTo('picker.setCategoryFilter').single.$2,
      <String, Object?>{
        'categoryKeys': <String>['standard'],
        'focus': true,
      },
    );
  });

  testWidgets('and off again, from the same chip', (tester) async {
    final map = await _mount(
      tester,
      _snapshot(free: 0, filter: <Object?>['standard']),
    );
    expect(_decoration(tester), TextDecoration.lineThrough);
    await tester.tap(find.text('€25'));
    await tester.pump();
    expect(
      map.callsTo('picker.setCategoryFilter').single.$2,
      <String, Object?>{'categoryKeys': null, 'focus': true},
    );
  });

  testWidgets('a price with seats left is not struck', (tester) async {
    await _mount(tester, _snapshot(free: 5));
    expect(_decoration(tester), isNull);
  });

  testWidgets('an uncounted price is unknown, not sold out', (tester) async {
    // `available` is 0 before counts arrive; only `free` is believed.
    final snapshot = _snapshot();
    (((snapshot['catalog']! as Map<String, Object?>)['categories']!
        as List<Object?>)[0]! as Map<String, Object?>)['available'] = 0;
    await _mount(tester, snapshot);
    expect(_decoration(tester), isNull);
  });

  testWidgets('a zero from a runtime that does not count is not believed',
      (tester) async {
    await _mount(tester, _snapshot(free: 0), counts: false);
    expect(_decoration(tester), isNull);
  });
}
