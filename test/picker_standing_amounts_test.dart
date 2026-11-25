// The standing-area prompt: only amounts the page accepts, and its refusal.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_standing_amounts.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();

/// A snapshot with room for [remaining] more tickets.
Map<String, Object?> _snapshot({
  List<Map<String, Object?>> areas = const <Map<String, Object?>>[],
  int remaining = 10,
  bool wheelchairOnly = false,
  int revision = 1,
}) {
  final base = pickerSnapshot(
    revision: revision,
    withSelection: false,
    accessibilityFilter:
        wheelchairOnly ? const <String>['wheelchair'] : const <String>[],
  );
  return <String, Object?>{
    ...base,
    'catalog': <String, Object?>{
      ...base['catalog']! as Map<String, Object?>,
      'gaAreas': areas,
    },
    'selection': <String, Object?>{
      ...base['selection']! as Map<String, Object?>,
      'maxSelection': remaining,
    },
  };
}

SeatLayerStandingAmounts? _amounts(
  GAArea area, {
  int remaining = 10,
  bool wheelchairOnly = false,
}) =>
    seatLayerStandingAmounts(
      area,
      SeatLayerPickerSnapshot.fromJson(
        _snapshot(remaining: remaining, wheelchairOnly: wheelchairOnly),
      ),
    );

void main() {
  setUp(useFakeWebViewPlatform);

  group('what one standing area or box can be asked for', () {
    test('reads the box and wheelchair facts the page sends', () {
      final box = GAArea.fromJson(<String, Object?>{
        'id': 'box',
        'available': 6,
        'bookingMode': 'variable',
        'minOccupancy': 2,
        'maxOccupancy': 6,
        'wheelchairPlaces': 1,
        'wheelchairAvailable': 1,
      })!;
      expect(box.bookingMode, 'variable');
      expect(box.minOccupancy, 2);
      expect(box.maxOccupancy, 6);
      expect(box.wheelchairPlaces, 1);
      expect(box.wheelchairAvailable, 1);

      // An older page sends none of them.
      final area = GAArea.fromJson(<String, Object?>{'id': 'ga'})!;
      expect(area.bookingMode, isNull);
      expect(area.minOccupancy, isNull);
      expect(area.maxOccupancy, isNull);
      expect(area.wheelchairPlaces, isNull);
      expect(area.wheelchairAvailable, isNull);
    });

    test('per person: one up to what is free and left in the order', () {
      expect(_amounts(const GAArea(id: 'ga', available: 4)),
          (minimum: 1, maximum: 4));
      expect(_amounts(const GAArea(id: 'ga', available: 99)),
          (minimum: 1, maximum: 10));
      expect(_amounts(const GAArea(id: 'ga')), (minimum: 1, maximum: 10));
      expect(_amounts(const GAArea(id: 'ga', available: 0)), isNull);
      expect(
          _amounts(const GAArea(id: 'ga', available: 4), remaining: 0), isNull);
    });

    test('a whole box is exactly its places', () {
      const box = GAArea(
        id: 'box',
        available: 8,
        bookingMode: 'whole',
        maxOccupancy: 8,
      );
      expect(_amounts(box), (minimum: 8, maximum: 8));
      // The places come from the capacity when no maximum is named.
      expect(
        _amounts(const GAArea(
          id: 'box',
          available: 8,
          bookingMode: 'whole',
          capacity: 8,
        )),
        (minimum: 8, maximum: 8),
      );
      expect(
        _amounts(const GAArea(
          id: 'box',
          available: 0,
          bookingMode: 'whole',
          maxOccupancy: 8,
        )),
        isNull,
      );
      // More places than the order may still take: it cannot be offered.
      expect(_amounts(box, remaining: 7), isNull);
    });

    test('a party box stays inside its range', () {
      const box = GAArea(
        id: 'box',
        available: 6,
        bookingMode: 'variable',
        minOccupancy: 2,
        maxOccupancy: 6,
      );
      expect(_amounts(box), (minimum: 2, maximum: 6));
      expect(_amounts(box, remaining: 4), (minimum: 2, maximum: 4));
      expect(_amounts(box, remaining: 1), isNull);
      expect(
        _amounts(const GAArea(
          id: 'box',
          available: 6,
          bookingMode: 'variable',
          maxOccupancy: 6,
        )),
        (minimum: 1, maximum: 6),
      );
    });

    test('the wheelchair filter offers wheelchair places alone', () {
      expect(
        _amounts(
          const GAArea(
            id: 'ga',
            available: 40,
            wheelchairPlaces: 4,
            wheelchairAvailable: 3,
          ),
          wheelchairOnly: true,
        ),
        (minimum: 1, maximum: 3),
      );
      expect(
        _amounts(const GAArea(id: 'ga', available: 40), wheelchairOnly: true),
        isNull,
      );
      const range = GAArea(
        id: 'box',
        available: 6,
        bookingMode: 'variable',
        minOccupancy: 2,
        maxOccupancy: 6,
      );
      expect(_amounts(range, wheelchairOnly: true), isNull);
      expect(
        _amounts(
          const GAArea(
            id: 'box',
            available: 6,
            bookingMode: 'variable',
            minOccupancy: 2,
            maxOccupancy: 6,
            wheelchairPlaces: 1,
          ),
          wheelchairOnly: true,
        ),
        (minimum: 2, maximum: 6),
      );
    });
  });

  group('the prompt', () {
    const box = <String, Object?>{
      'id': 'box',
      'label': 'Box 1',
      'available': 4,
      'bookingMode': 'variable',
      'minOccupancy': 2,
      'maxOccupancy': 4,
    };

    Future<(FakePickerMap, SeatLayerPickerController)> open(
      WidgetTester tester, {
      required Map<String, Object?> area,
      Map<String, Object?> Function(Map<String, Object?> next)? reply,
      Map<String, Object?>? after,
    }) async {
      late final FakePickerMap map;
      map = FakePickerMap(
        handler: (command, payload) async {
          final next = <String, Object?>{
            ...(command == 'picker.holdGA' && after != null
                ? after
                : map.current),
            'revision': map.revision + 1,
          };
          map.current = next;
          final answer = <String, Object?>{
            'revision': next['revision'],
            'snapshot': next,
          };
          return command == 'picker.holdGA' && reply != null
              ? reply(answer)
              : answer;
        },
      );
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      await tester.pumpWidget(
        pickerHarness(
          map,
          SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {}),
          controller: picker,
        ),
      );
      map.emit(_snapshot(areas: <Map<String, Object?>>[area]));
      await tester.pump();
      map.emitStandingTap(GAArea.fromJson(area)!);
      await tester.pumpAndSettle();
      return (map, picker);
    }

    testWidgets('opens a box at its smallest party and steps in its range',
        (tester) async {
      final (map, _) = await open(tester, area: box);
      expect(find.text('2'), findsOneWidget);
      for (var press = 0; press < 4; press += 1) {
        await tester.tap(find.byIcon(Icons.add_rounded).last);
        await tester.pump();
      }
      expect(find.text('4'), findsOneWidget);
      for (var press = 0; press < 4; press += 1) {
        await tester.tap(find.byIcon(Icons.remove_rounded).last);
        await tester.pump();
      }
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text(_strings.addTickets));
      await tester.pumpAndSettle();
      expect(
        (map.callsTo('picker.holdGA').single.$2! as Map)['qty'],
        2,
      );
      expect(find.byType(SeatLayerPickerGeneralAdmissionPrompt), findsNothing);
    });

    testWidgets('stays and says the places were taken when they are refused',
        (tester) async {
      final (_, picker) = await open(
        tester,
        area: box,
        reply: (answer) => <String, Object?>{...answer, 'held': false},
      );
      await tester.tap(find.text(_strings.addTickets));
      await tester.pumpAndSettle();

      expect(
          find.byType(SeatLayerPickerGeneralAdmissionPrompt), findsOneWidget);
      expect(find.text(_strings.seatsJustTaken), findsOneWidget);
      expect(picker.state.error, isA<BridgeFailure>());
      expect(picker.state.isBusy, isFalse);
    });

    testWidgets('offers nothing more once the refusal took the last place',
        (tester) async {
      await open(
        tester,
        area: box,
        reply: (answer) => <String, Object?>{...answer, 'held': false},
        after: _snapshot(areas: <Map<String, Object?>>[
          <String, Object?>{...box, 'available': 0},
        ]),
      );
      await tester.tap(find.text(_strings.addTickets));
      await tester.pumpAndSettle();

      expect(find.text(_strings.seatsJustTaken), findsOneWidget);
      expect(find.text(_strings.placesAvailable(0)), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, _strings.addTickets))
            .onPressed,
        isNull,
      );
    });

    for (final short in <bool>[true, false]) {
      testWidgets(
          short
              ? 'keeps its buttons clear of the cart handle where it scrolls'
              : 'takes no room under its buttons where it fits',
          (tester) async {
        await tester.binding.setSurfaceSize(
          short ? const Size(568, 320) : const Size(375, 812),
        );
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.platformDispatcher.textScaleFactorTestValue = short ? 1.6 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await open(tester, area: box);
        final prompt = find.byType(SeatLayerPickerGeneralAdmissionPrompt);
        final sheet =
            find.descendant(of: prompt, matching: find.byType(Material)).first;
        final button = find.widgetWithText(FilledButton, _strings.addTickets);
        expect(
          tester.getRect(sheet).bottom - tester.getRect(button).bottom,
          closeTo(short ? SeatLayerSizeTokens.sheetHandleOverhang + 8 : 18, .5),
        );
      });
    }

    testWidgets('centres a button whose words take two lines', (tester) async {
      await open(tester, area: box);
      expect(
        tester.widget<Text>(find.text(_strings.addTickets)).textAlign,
        TextAlign.center,
      );
    });

    testWidgets('is not opened by an area with nothing to offer',
        (tester) async {
      final (_, picker) = await open(
        tester,
        area: <String, Object?>{...box, 'available': 0},
      );
      expect(picker.state.generalAdmissionCandidate, isNull);
      expect(find.byType(SeatLayerPickerGeneralAdmissionPrompt), findsNothing);
    });

    testWidgets('closes on a hold the page confirms', (tester) async {
      final (_, picker) = await open(
        tester,
        area: box,
        reply: (answer) => <String, Object?>{...answer, 'held': true},
      );
      await tester.tap(find.text(_strings.addTickets));
      await tester.pumpAndSettle();
      expect(picker.state.generalAdmissionCandidate, isNull);
      expect(picker.state.error, isNull);
    });
  });
}
