import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// Three selected seats, with the scene sitting in one of them.
Map<String, Object?> _seated({String at = 'seat-a-2', int revision = 3}) {
  final snapshot = snapshotWithTicketCount(3, revision: revision);
  final map = snapshot['map']! as Map<String, Object?>;
  map['buyerView'] = 'venue3d';
  map['view3dTargetSeatId'] = at;
  map['categoryFilter'] = <Object?>[];
  return snapshot;
}

/// The same scene, in a venue whose row names repeat their section.
///
/// A real chart writes `Stalls D` as the section and `Stalls D C` as the row.
Map<String, Object?> _seatedInQualifiedRow() {
  final snapshot = _seated(at: 'seat-a-1');
  final selection = snapshot['selection']! as Map<String, Object?>;
  selection['seats'] = (selection['seats']! as List<Object?>)
      .map((seat) => <String, Object?>{
            ...seat! as Map<String, Object?>,
            'sectionLabel': 'Stalls D',
            'rowLabel': 'Stalls D C',
          })
      .toList(growable: false);
  return snapshot;
}

void main() {
  testWidgets('the chrome stays away until the scene is up', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Open venue 360°'), findsNothing);
    expect(find.text('Back to venue'), findsNothing);
  });

  testWidgets('the caption says where the buyer is sitting', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    expect(
      find.text('Gallery · Row A · Seat 2 · view from your seat'),
      findsOneWidget,
    );
    expect(find.text('Back to venue'), findsOneWidget);
    expect(find.text('Open venue 360°'), findsOneWidget);
  });

  testWidgets('the caption drops the section the row name repeats',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seatedInQualifiedRow());
    await tester.pumpAndSettle();

    expect(
      find.text('Stalls D · Row C · Seat 1 · view from your seat'),
      findsOneWidget,
    );
    expect(find.textContaining('Row Stalls D C'), findsNothing);
  });

  testWidgets('stepping retargets the scene rather than rebuilding it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next seat'));
    await tester.pump();

    expect(map.callsTo('picker.setBuyerView').single.$2, <String, Object?>{
      'view': 'venue3d',
      'flyToSeatId': 'seat-a-3',
    });
  });

  testWidgets('stepping stops at the ends', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated(at: 'seat-a-1'));
    await tester.pumpAndSettle();

    expect(_iconEnabled(tester, 'Previous seat'), isFalse);
    expect(_iconEnabled(tester, 'Next seat'), isTrue);
  });

  testWidgets('the venue view and the recentre reset the camera',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open venue 360°'));
    await tester.pump();
    expect(map.callsTo('picker.setBuyerView').last.$2, <String, Object?>{
      'view': 'venue3d',
      'resetView': true,
    });

    await tester.tap(find.byTooltip('Recentre the view'));
    await tester.pump();
    expect(map.callsTo('picker.setBuyerView').last.$2, <String, Object?>{
      'view': 'venue3d',
      'flyToSeatId': 'seat-a-2',
      'resetView': true,
    });
  });

  testWidgets('back to venue returns to the map', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to venue'));
    await tester.pump();

    expect(
      map.callsTo('picker.setBuyerView').single.$2,
      <String, Object?>{'view': 'map'},
    );
  });

  testWidgets('the chrome is dark over a light picker', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerVenue3D(),
        platformBrightness: Brightness.light,
      ),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    final caption = tester.widget<Text>(
      find.text('Gallery · Row A · Seat 2 · view from your seat'),
    );
    expect(caption.style!.color, const Color(0xFFEEF1F8));
  });

  testWidgets('the map-only controls stand down while the scene is up',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerMapControls(compact: true)),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    // There is no flat map to fit or filter, and the 3D chrome owns that
    // corner.
    expect(find.byType(SeatLayerPickerZoomToFitButton), findsNothing);
    expect(find.byType(SeatLayerPickerAccessibilityFilters), findsNothing);
    // The way back out stays.
    expect(find.byType(SeatLayerPickerViewModeControl), findsOneWidget);
  });

  testWidgets('the legend over the scene takes the scene palette',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPriceLegend(compact: true),
        platformBrightness: Brightness.light,
      ),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('€25')).style!.color,
      const Color(0xFFEEF1F8),
    );
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('venue 3D golden — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              // The scene is the WebView; the golden is the chrome over a stand-in.
              const ColoredBox(
                color: Color(0xFF10151F),
                child: SizedBox.expand(child: SeatLayerVenue3D()),
              ),
            ),
            platformBrightness: brightness,
          ),
        );
        map.emit(_seated());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'venue_3d_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}

bool _iconEnabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;
