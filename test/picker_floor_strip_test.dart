// A venue stacked three levels deep drawn all at once is a picture of a
// building, not a plan of one: stalls, circle and gallery overlap and the
// buyer cannot tell which seats are where. The strip is how they pick a level.
//
// Everything here is capability-gated on the snapshot. A runtime that reports
// no floors, or one floor, or no `floorMode`, must produce no chrome at all —
// the SDK never invents a control the runtime cannot honour.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_floor_strip.dart';
import 'package:seatlayer/src/picker/picker_models.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The fixture venue with [floors] and, optionally, a reported floor mode.
Map<String, Object?> _venue({
  List<Object?>? floors,
  String? activeFloorId = 'stalls',
  String? floorMode = 'single',
}) {
  final snapshot = pickerSnapshot(sections: pickerSections());
  final map = snapshot['map']! as Map<String, Object?>;
  map['floors'] = floors ??
      <Object?>[
        <String, Object?>{'id': 'stalls', 'name': 'Stalls', 'level': 0},
        <String, Object?>{'id': 'circle', 'name': 'Dress circle', 'level': 1},
        <String, Object?>{'id': 'gallery', 'name': 'Gallery', 'level': 2},
      ];
  map['activeFloorId'] = activeFloorId;
  if (floorMode == null) {
    map.remove('floorMode');
  } else {
    map['floorMode'] = floorMode;
  }
  return snapshot;
}

Future<FakePickerMap> _pumpStrip(
  WidgetTester tester,
  Map<String, Object?> snapshot, {
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  final map = FakePickerMap();
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  const strip = SeatLayerFloorStrip();
  await tester.pumpWidget(
    pickerHarness(
      map,
      Align(
        alignment: Alignment.topCenter,
        child: golden ? goldenSubject(const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: strip,
        )) : strip,
      ),
      platformBrightness: brightness,
    ),
  );
  map.emit(snapshot);
  await tester.pumpAndSettle();
  return map;
}

void main() {
  testWidgets('a multi-floor venue names every floor and the all-floors view',
      (tester) async {
    await _pumpStrip(tester, _venue());

    expect(find.text('All floors'), findsOneWidget);
    expect(find.text('Stalls'), findsOneWidget);
    expect(find.text('Dress circle'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('the floors read top down, the way a lift panel does',
      (tester) async {
    await _pumpStrip(tester, _venue());

    final order = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .toList();
    expect(
      order,
      <String>['All floors', 'Gallery', 'Dress circle', 'Stalls'],
    );
  });

  testWidgets('floors with no level keep the order the chart gave them',
      (tester) async {
    await _pumpStrip(
      tester,
      _venue(
        floors: <Object?>[
          <String, Object?>{'id': 'a', 'name': 'Lower'},
          <String, Object?>{'id': 'b', 'name': 'Upper', 'level': 1},
        ],
        activeFloorId: 'a',
      ),
    );

    // A partial ordering would move one floor and leave the other where it
    // was, which reads as a bug rather than as an ordering.
    final order = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .toList();
    expect(order, <String>['All floors', 'Lower', 'Upper']);
  });

  testWidgets('choosing a floor sends setFloor', (tester) async {
    final map = await _pumpStrip(tester, _venue());

    await tester.tap(find.text('Gallery'));
    await tester.pump();

    expect(
      map.callsTo('picker.setFloor').single.$2,
      <String, Object?>{'floorId': 'gallery'},
    );
  });

  testWidgets('choosing All floors sends the runtime its own sentinel',
      (tester) async {
    final map = await _pumpStrip(tester, _venue());

    await tester.tap(find.text('All floors'));
    await tester.pump();

    expect(
      map.callsTo('picker.setFloor').single.$2,
      <String, Object?>{'floorId': seatLayerAllFloors},
    );
  });

  testWidgets('the active floor is the selected chip and is inert',
      (tester) async {
    final map = await _pumpStrip(tester, _venue(activeFloorId: 'circle'));

    await tester.tap(find.text('Dress circle'));
    await tester.pump();

    // Re-choosing the floor already drawn is a command with nothing to do.
    expect(map.callsTo('picker.setFloor'), isEmpty);
  });

  testWidgets('showing all floors selects the all chip instead', (tester) async {
    final map = await _pumpStrip(
      tester,
      _venue(activeFloorId: 'stalls', floorMode: 'all'),
    );

    await tester.tap(find.text('All floors'));
    await tester.pump();
    expect(map.callsTo('picker.setFloor'), isEmpty);

    await tester.tap(find.text('Stalls'));
    await tester.pump();
    expect(map.callsTo('picker.setFloor'), hasLength(1));
  });

  group('it renders nothing it was not told about', () {
    testWidgets('a runtime reporting no floorMode offers no all-floors chip',
        (tester) async {
      await _pumpStrip(tester, _venue(floorMode: null));

      expect(find.text('All floors'), findsNothing);
      expect(find.text('Stalls'), findsOneWidget);
    });

    testWidgets('one floor is not a choice', (tester) async {
      await _pumpStrip(
        tester,
        _venue(
          floors: <Object?>[
            <String, Object?>{'id': 'ground', 'name': 'Ground floor'},
          ],
          activeFloorId: 'ground',
        ),
      );

      expect(find.byType(Text), findsNothing);
      expect(tester.getSize(find.byType(SeatLayerFloorStrip)), Size.zero);
    });

    testWidgets('and neither is a chart with no floors at all', (tester) async {
      await _pumpStrip(
        tester,
        _venue(floors: <Object?>[], activeFloorId: null, floorMode: null),
      );

      expect(tester.getSize(find.byType(SeatLayerFloorStrip)), Size.zero);
    });
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('floor strip golden — ${brightness.name}', (tester) async {
        await _pumpStrip(
          tester,
          _venue(),
          brightness: brightness,
          golden: true,
        );

        await expectGolden(tester, 'floor_strip_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
