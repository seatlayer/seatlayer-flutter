// The accessible-section tour, from the sheet's count to the map's stepper.
//
// The web menu is a popover: pressing "12 free" steps the camera while the
// menu stays open, so the walk never has to leave the surface it started on.
// A phone's accessibility sheet is a modal that covers the map, so the same
// press has to close the sheet and hand the walk to a control standing where
// the map is visible. These tests pin both halves, and the thing that makes
// them safe: every one of them is withheld from a runtime that did not
// advertise the capability, because a jump command an old runtime cannot
// answer is a button that does nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_accessibility_focus.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// A runtime whose `focusNextAccessibleSection` walks [steps], then runs out.
FakePickerMap _walkingMap({
  required List<Map<String, Object?>?> steps,
  bool focus = true,
  bool counts = true,
  Map<String, Object?>? snapshot,
}) {
  var taken = 0;
  var current = snapshot ?? pickerSnapshot();
  late final FakePickerMap map;
  map = FakePickerMap(
    bundle: accessibilityFocusBundle(focus: focus, counts: counts),
    handler: (command, payload) async {
      if (command == 'picker.focusNextAccessibleSection') {
        final step = taken < steps.length ? steps[taken] : null;
        taken++;
        return <String, Object?>{'step': step};
      }
      current = <String, Object?>{
        ...current,
        'revision': (current['revision']! as int) + 1,
      };
      return <String, Object?>{
        'revision': current['revision'],
        'snapshot': current,
      };
    },
  );
  return map;
}

Map<String, Object?> _step({
  String id = 'section-a',
  String label = 'Gallery',
  int free = 4,
  required int index,
  required int total,
}) =>
    <String, Object?>{
      'id': id,
      'label': label,
      'free': free,
      'index': index,
      'total': total,
    };

/// The counts a runtime advertising `section-access-counts-v1` reports.
Map<String, Map<String, Object?>> _counts() => <String, Map<String, Object?>>{
      'section-a': <String, Object?>{'wheelchair': 2},
      'section-b': <String, Object?>{'wheelchair': 4},
    };

SeatLayerPickerController _attached(FakePickerMap map) {
  final controller = SeatLayerPickerController(mapController: map);
  addTearDown(controller.dispose);
  return controller;
}

Future<void> _mountStepper(
  WidgetTester tester,
  FakePickerMap map,
  Map<String, Object?> snapshot, {
  SeatLayerPickerController? controller,
}) async {
  await tester.pumpWidget(
    pickerHarness(
      map,
      const Align(
        alignment: Alignment.bottomLeft,
        child: SeatLayerPickerAccessibleStepper(),
      ),
      controller: controller,
    ),
  );
  map.emit(snapshot);
  await tester.pumpAndSettle();
}

Future<void> _openSheet(WidgetTester tester, FakePickerMap map,
    Map<String, Object?> snapshot) async {
  await tester.pumpWidget(
    pickerHarness(
      map,
      const Align(
        alignment: Alignment.bottomLeft,
        child: SeatLayerPickerAccessibilityFilters(compact: true),
      ),
    ),
  );
  map.emit(snapshot);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(IconButton));
  await tester.pumpAndSettle();
}

void main() {
  group('the commands', () {
    test('focusNextAccessibleSection sends its types and decodes the step',
        () async {
      final map = _walkingMap(
        steps: <Map<String, Object?>?>[
          _step(index: 0, total: 6),
        ],
      );
      addTearDown(map.dispose);
      final controller = _attached(map);

      final step = await controller.focusNextAccessibleSection(
        types: <String>{'wheelchair'},
      );

      expect(map.callsTo('picker.focusNextAccessibleSection').single.$2, <String,
          Object?>{
        'types': <String>['wheelchair'],
      });
      expect(
        step,
        const SeatLayerAccessibleStep(
          id: 'section-a',
          label: 'Gallery',
          free: 4,
          index: 0,
          total: 6,
        ),
      );
    });

    test('an empty type set is left off, so the runtime uses the live filter',
        () async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[null]);
      addTearDown(map.dispose);
      final controller = _attached(map);

      await controller.focusNextAccessibleSection(types: const <String>{});

      expect(
        map.callsTo('picker.focusNextAccessibleSection').single.$2,
        <String, Object?>{},
      );
    });

    test('a null step is an answer, not a failure', () async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[null]);
      addTearDown(map.dispose);
      final controller = _attached(map);

      expect(await controller.focusNextAccessibleSection(), isNull);
    });

    test('focusAccessibilityFilter re-runs the flight with no payload',
        () async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      final controller = _attached(map);

      await controller.focusAccessibilityFilter();

      expect(map.callsTo('picker.focusAccessibilityFilter').single.$2, isNull);
    });

    test('both capabilities are read independently', () {
      final flying = _walkingMap(steps: <Map<String, Object?>?>[], counts: false);
      addTearDown(flying.dispose);
      final counting = _walkingMap(steps: <Map<String, Object?>?>[], focus: false);
      addTearDown(counting.dispose);

      expect(_attached(flying).supportsAccessibilityFocus, isTrue);
      expect(_attached(flying).supportsSectionAccessCounts, isFalse);
      expect(_attached(counting).supportsAccessibilityFocus, isFalse);
      expect(_attached(counting).supportsSectionAccessCounts, isTrue);
    });
  });

  group('the map stepper', () {
    testWidgets('says how many sections match before the first step is taken',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(
          sections: pickerSections(accessibleFree: _counts()),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );

      expect(find.text('2 sections'), findsOneWidget);
    });

    testWidgets('a press walks the tour and reads "index of total"',
        (tester) async {
      final map = _walkingMap(
        steps: <Map<String, Object?>?>[
          _step(index: 0, total: 6),
          _step(id: 'section-b', label: 'Terrace', index: 1, total: 6),
        ],
      );
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(
          sections: pickerSections(accessibleFree: _counts()),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.text('1 of 6'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.text('2 of 6'), findsOneWidget);
    });

    testWidgets('a null step takes the pill down', (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[null]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(
          sections: pickerSections(accessibleFree: _counts()),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );
      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('nothing is drawn without accessibility-focus-v1',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[], focus: false);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(
          sections: pickerSections(accessibleFree: _counts()),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('nothing is drawn with no filter on', (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(sections: pickerSections(accessibleFree: _counts())),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('a counted venue with nothing matching draws no pill',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(
          sections: pickerSections(
            accessibleFree: <String, Map<String, Object?>>{
              'section-a': <String, Object?>{'wheelchair': 0},
            },
          ),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('a runtime that flies but does not count still offers the tour',
        (tester) async {
      final map = _walkingMap(
        steps: <Map<String, Object?>?>[_step(index: 0, total: 3)],
        counts: false,
      );
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _mountStepper(
        tester,
        map,
        pickerSnapshot(accessibilityFilter: const <String>['wheelchair']),
      );

      expect(find.byType(InkWell), findsOneWidget);
      expect(find.text('2 sections'), findsNothing);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('1 of 3'), findsOneWidget);
    });
  });

  group('the sheet count', () {
    testWidgets('presses through to a filter, a close and the first step',
        (tester) async {
      final map = _walkingMap(
        steps: <Map<String, Object?>?>[_step(index: 0, total: 6)],
        snapshot: pickerSnapshot(
          accessNeeds: <Object?>[accessNeed('wheelchair', 15)],
        ),
      );
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _openSheet(
        tester,
        map,
        pickerSnapshot(accessNeeds: <Object?>[accessNeed('wheelchair', 15)]),
      );

      await tester.tap(find.text('15 free'));
      await tester.pumpAndSettle();

      expect(
        map.callsTo('picker.setAccessibilityFilter').single.$2,
        <String, Object?>{
          'types': <String>['wheelchair'],
        },
      );
      expect(
        map.callsTo('picker.focusNextAccessibleSection').single.$2,
        <String, Object?>{
          'types': <String>['wheelchair'],
        },
      );
      // The sheet is a modal over the map, and the walk it started happens on
      // the map: it has to be gone by the time the camera moves.
      expect(find.text('15 free'), findsNothing);
    });

    testWidgets('the count is not pressable without accessibility-focus-v1',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[], focus: false);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _openSheet(
        tester,
        map,
        pickerSnapshot(accessNeeds: <Object?>[accessNeed('wheelchair', 15)]),
      );

      await tester.tap(find.text('15 free'));
      await tester.pumpAndSettle();

      expect(map.callsTo('picker.focusNextAccessibleSection'), isEmpty);
      // The sheet stays up: the number is a fact, not a button.
      expect(find.text('15 free'), findsOneWidget);
    });

    testWidgets('a sold-out provision offers no jump', (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await _openSheet(
        tester,
        map,
        pickerSnapshot(accessNeeds: <Object?>[accessNeed('wheelchair', 0)]),
      );

      await tester.tap(find.text('None left'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(map.callsTo('picker.focusNextAccessibleSection'), isEmpty);
    });
  });

  group('the dock bar count', () {
    testWidgets('appends the matching free spaces of the focused section',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
      map.emit(
        pickerSnapshot(
          sections: pickerSections(accessibleFree: _counts()),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('· ♿ 2'), findsOneWidget);
    });

    testWidgets('says nothing without section-access-counts-v1',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[], counts: false);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
      map.emit(
        pickerSnapshot(
          sections: pickerSections(accessibleFree: _counts()),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('♿'), findsNothing);
    });

    testWidgets('says nothing with no filter on', (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
      map.emit(
        pickerSnapshot(sections: pickerSections(accessibleFree: _counts())),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('♿'), findsNothing);
    });

    testWidgets('an uncounted section stays silent rather than saying zero',
        (tester) async {
      final map = _walkingMap(steps: <Map<String, Object?>?>[]);
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
      map.emit(
        pickerSnapshot(
          sections: pickerSections(
            accessibleFree: <String, Map<String, Object?>>{
              'section-b': <String, Object?>{'wheelchair': 4},
            },
          ),
          accessibilityFilter: const <String>['wheelchair'],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('♿'), findsNothing);
    });
  });

  group('accessibleFree decoding', () {
    test('present decodes, absent is empty, junk is dropped', () {
      final present = SeatLayerPickerSectionSummary.fromJson(
        <String, Object?>{
          'id': 'a',
          'accessibleFree': <String, Object?>{
            'wheelchair': 2,
            'companion': 1.0,
            'hearing': 'two',
            'lift-armrest': null,
          },
        },
      );
      expect(
        present!.accessibleFree,
        <String, int>{'wheelchair': 2, 'companion': 1},
        reason: 'an integral double is a JSON integer; a string is not a count',
      );

      final absent =
          SeatLayerPickerSectionSummary.fromJson(<String, Object?>{'id': 'b'});
      expect(absent!.accessibleFree, isEmpty);

      final junk = SeatLayerPickerSectionSummary.fromJson(
        <String, Object?>{'id': 'c', 'accessibleFree': 'wheelchair'},
      );
      expect(junk!.accessibleFree, isEmpty);
    });

    test('a missing key is not counted, and zero is not a match', () {
      final sections = <SeatLayerPickerSectionSummary>[
        SeatLayerPickerSectionSummary.fromJson(<String, Object?>{
          'id': 'a',
          'accessibleFree': <String, Object?>{'wheelchair': 0},
        })!,
        SeatLayerPickerSectionSummary.fromJson(<String, Object?>{'id': 'b'})!,
      ];

      expect(
        seatLayerSectionAccessibleFree(sections.first, <String>{'wheelchair'}),
        0,
      );
      expect(
        seatLayerSectionAccessibleFree(sections.last, <String>{'wheelchair'}),
        isNull,
        reason: 'not counted is not zero',
      );
    });
  });
}
