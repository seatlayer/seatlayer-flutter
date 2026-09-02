import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_seat_view_chrome.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The stand-in map surface, so its rect can be measured.
const Key _mapSurfaceKey = ValueKey<String>('seatlayer-test-map-surface');

/// The layout with the WebView replaced, so the composition can be tested
/// without a platform view.
Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(key: _mapSurfaceKey),
      ),
    );

/// Where the map surface itself begins and ends.
Rect _mapRect(WidgetTester tester) =>
    tester.getRect(find.byKey(_mapSurfaceKey));

/// A snapshot whose catalogue carries [count] sellable categories.
///
/// Prices climb so no two chips are the same width, which is how a real
/// venue's legend runs off the end of the rail.
Map<String, Object?> _snapshotWithCategories(int count, {int revision = 1}) {
  final snapshot = pickerSnapshot(revision: revision);
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
      // Two lines: the prices have the band to themselves and the control
      // sits on the map's top line under it, so nothing is ever clipped.
      expect(
        tester.getRect(control).top,
        greaterThanOrEqualTo(prices.bottom),
      );
    });
  }

  testWidgets('the top rail is a band above the map, never on it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_snapshotWithCategories(8));
    await tester.pumpAndSettle();

    final surface = _mapRect(tester);
    final prices = tester.getRect(find.byType(SeatLayerPriceLegend));
    final control = tester.getRect(find.byType(SeatLayerPickerViewModeControl));

    // The band is chrome of the same Column as the header: the map starts
    // under it, so no seat number is ever read through a price chip. The
    // Map/3D control keeps the map's own top-right corner.
    expect(prices.bottom, lessThanOrEqualTo(surface.top));
    expect(control.top - surface.top, closeTo(8, .5));
    expect(
      surface.right - control.right,
      closeTo(SeatLayerSizeTokens.mapAnchorInset, .5),
    );
    for (final chip in find
        .descendant(
            of: find.byType(SeatLayerPriceLegend), matching: find.byType(Text))
        .evaluate()) {
      expect(
        tester.getRect(find.byWidget(chip.widget)).overlaps(surface),
        isFalse,
      );
    }
  });

  testWidgets('the test badge sits in the map\'s own top corner',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_snapshotWithCategories(3));
    await tester.pumpAndSettle();

    final badge = tester.getRect(find.byType(SeatLayerPickerTestModeIndicator));
    expect(badge.top - _mapRect(tester).top, closeTo(8, .5));
    expect(
      badge.left - _mapRect(tester).left,
      closeTo(SeatLayerSizeTokens.mapAnchorInset, .5),
    );
  });

  testWidgets('the badge keeps that corner in a scene with no seat targeted',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    final snapshot = _snapshotWithCategories(3);
    (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
    map.emit(snapshot);
    await tester.pumpAndSettle();

    // Nothing is drawn above it: `‹ Back to venue` only appears once the
    // scene is aimed at a seat.
    expect(find.text('Back to venue'), findsNothing);
    final badge = tester.getRect(find.byType(SeatLayerPickerTestModeIndicator));
    expect(badge.top - _mapRect(tester).top, closeTo(8, .5));
  });

  testWidgets('the immersive scene has no price rail', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_snapshotWithCategories(5));
    await tester.pumpAndSettle();
    expect(find.byType(SeatLayerPriceLegend), findsOneWidget);

    final snapshot = _snapshotWithCategories(5, revision: 2);
    (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
    map.emit(snapshot);
    await tester.pumpAndSettle();

    // A price is a fact about a seat; in the scene the buyer is choosing where
    // to stand. The band would also cost the venue forty-four points of sky.
    expect(find.byType(SeatLayerPriceLegend), findsNothing);
  });

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

  testWidgets('a panorama leaves its web exit and gestures unobstructed',
      (tester) async {
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'viewport-insets-v1',
          'native-seat-view-chrome-v1',
        ],
      ),
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    final snapshot = _snapshotWithCategories(3);
    (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
    map.emit(snapshot);
    map.emitEvent('seatView.changed', <String, Object?>{
      'seatView': <String, Object?>{
        'seatId': 'seat-a-1',
        'title': 'View from Gallery · A-1',
        'caption': 'Drag to look around',
        'real': true,
        'generated': false,
      },
    });
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerSeatViewChrome), findsOneWidget);
    expect(find.byType(SeatLayerPriceLegend), findsNothing);
    expect(find.byType(SeatLayerPickerMapControls), findsNothing);
    expect(find.byType(SeatLayerPickerViewModeControl), findsNothing);
    expect(find.byType(SeatLayerPickerAccessibilityFilters), findsNothing);
    expect(find.byType(SeatLayerVenue3D), findsNothing);
    expect(find.byType(SeatLayerPickerTestModeIndicator), findsNothing);
    expect(find.byType(SeatLayerDockBar), findsNothing);
  });

  testWidgets('the test badge stacks below the way back out of 3D',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    final snapshot = _snapshotWithCategories(8);
    final mapState = snapshot['map']! as Map<String, Object?>;
    final selectedSeat = ((snapshot['selection']!
            as Map<String, Object?>)['seats']! as List<Object?>)
        .single! as Map<String, Object?>;
    mapState
      ..['buyerView'] = 'venue3d'
      ..['view3dTargetSeatId'] = selectedSeat['id']
      ..['view3dTargetSeat'] = selectedSeat
      ..['view3dPreviousSeatId'] = null
      ..['view3dNextSeatId'] = null
      ..['view3dFocusedSectionId'] = 'section-a';
    map.emit(snapshot);
    await tester.pumpAndSettle();

    final badge = tester.getRect(
      find.byType(SeatLayerPickerTestModeIndicator),
    );
    final back = tester.getRect(find.text('Back to venue'));
    expect(find.byType(SeatLayerDockBar), findsNothing);
    expect(badge.top, greaterThanOrEqualTo(back.bottom));
    expect(
      badge.top,
      lessThan(back.bottom + SeatLayerVenue3D.backPillHeight),
    );
  });

  testWidgets('the compact test badge fills the band the layout reserves',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerTestModeIndicator(compact: true)),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    // The badge is drawn ON the map and the layout reserves exactly
    // `compactHeight` for it, so the two have to agree whatever the words and
    // the font metrics do.
    expect(find.text('Test mode'), findsOneWidget);
    expect(
      tester.getSize(find.byType(SeatLayerPickerTestModeIndicator)).height,
      SeatLayerPickerTestModeIndicator.compactHeight,
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
