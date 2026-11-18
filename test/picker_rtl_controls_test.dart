// In a right-to-left language the map's corners mirror with the reading
// direction; the venue does not.
//
// The header and the price rail already mirrored, so an Arabic buyer read the
// chrome from the right and then found every round control still on the
// right, under their thumb's opposite side.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

BundleInfo _bundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'venue-3d-controls-v1',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setBuyerView',
        'picker.setVenue3DNavigationMode',
        'picker.zoomIn',
        'picker.zoomToFit',
      ],
    );

Future<FakePickerMap> _mount(
  WidgetTester tester,
  TextDirection direction,
  Widget child,
  Map<String, Object?> snapshot,
) async {
  useFakeWebViewPlatform();
  final map = FakePickerMap(bundle: _bundle());
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      Directionality(textDirection: direction, child: child),
    ),
  );
  map.emit(snapshot);
  await pumpToRest(tester);
  return map;
}

double _centreX(WidgetTester tester, Finder finder) =>
    tester.getCenter(finder.first).dx;

/// Whether [icon] is drawn flipped about its vertical axis, the way [Icon]
/// draws a glyph that follows reading direction in a right-to-left context.
bool _mirrored(WidgetTester tester, Finder icon) => tester
    .widgetList<Transform>(
      find.descendant(of: icon, matching: find.byType(Transform)),
    )
    .any((transform) => transform.transform.storage[0] < 0);

void main() {
  final half = phoneSize.width / 2;

  for (final direction in TextDirection.values) {
    final rtl = direction == TextDirection.rtl;
    testWidgets('the map corners follow ${direction.name}', (tester) async {
      await _mount(
        tester,
        direction,
        SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {}),
        pickerSnapshot(withSelection: false),
      );
      final badge =
          _centreX(tester, find.byType(SeatLayerPickerTestModeIndicator));
      final venue =
          _centreX(tester, find.byType(SeatLayerPickerShowWholeVenueButton));
      // The test chip stands at the start edge, the control column at the end.
      expect(badge < half, !rtl, reason: 'test chip at x=$badge');
      expect(venue > half, !rtl, reason: 'whole-venue disc at x=$venue');
    });

    testWidgets('the 3D Rotate / Move pair follows ${direction.name}',
        (tester) async {
      final snapshot = snapshotWithTicketCount(2, revision: 3);
      (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
      await _mount(tester, direction, const SeatLayerVenue3D(), snapshot);
      final pair = _centreX(tester, find.text('Rotate venue'));
      expect(pair > half, !rtl, reason: 'Rotate venue at x=$pair');
    });

    testWidgets('the 3D back pill points to the start edge in ${direction.name}',
        (tester) async {
      final snapshot = snapshotWithTicketCount(1, revision: 3);
      final seat = ((snapshot['selection']! as Map<String, Object?>)['seats']!
              as List<Object?>)
          .first! as Map<String, Object?>;
      final map = snapshot['map']! as Map<String, Object?>;
      map['buyerView'] = 'venue3d';
      map['view3dTargetSeatId'] = seat['id'];
      map['view3dTargetSeat'] = seat;
      await _mount(tester, direction, const SeatLayerVenue3D(), snapshot);
      final label = find.text('Back to venue');
      expect(label, findsOneWidget);
      final pill = _centreX(tester, label);
      expect(pill < half, !rtl, reason: 'back pill at x=$pill');
      final chevron = find.descendant(
        of: find.ancestor(of: label, matching: find.byType(Row)).first,
        matching: find.byIcon(Icons.chevron_left_rounded),
      );
      expect(chevron, findsOneWidget);
      // "Back" points at the edge the pill stands on: left in LTR, right in
      // RTL, where the glyph is drawn mirrored.
      expect(_mirrored(tester, chevron), rtl);
    });

    testWidgets('the way-back control points to the start edge in '
        '${direction.name}', (tester) async {
      await _mount(
        tester,
        direction,
        const Center(child: SeatLayerPickerOverviewButton()),
        pickerSnapshot(withSelection: false),
      );
      final arrow = find.byIcon(Icons.arrow_back_rounded);
      expect(arrow, findsOneWidget);
      expect(_mirrored(tester, arrow), rtl);
    });
  }
}
