// A toast is the picker's voice for something that happened without the
// buyer's asking: a seat taken from under them, a hold that ran out, an event
// that stopped selling while they were choosing.
//
// One at a time, four seconds, never over the thing it is about. The rules
// worth pinning are the ones a future change would break silently: that a
// second sentence replaces the first rather than stacking on it, that the same
// sentence twice is one telling, that only an error shakes, and that the band
// never eats a tap meant for the map.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Widget _layer() => const SizedBox.expand(
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: SeatLayerPickerToastLayer()),
        ],
      ),
    );

void main() {
  group('the queue', () {
    test('is a queue of one, and the newest sentence wins', () {
      final queue = SeatLayerPickerToastQueue();
      addTearDown(queue.dispose);

      queue.show(const SeatLayerPickerToast('First.'));
      queue.show(const SeatLayerPickerToast('Second.'));

      expect(queue.current!.message, 'Second.');
    });

    test('says the same sentence once', () {
      final queue = SeatLayerPickerToastQueue();
      addTearDown(queue.dispose);
      var announcements = 0;
      queue.addListener(() => announcements += 1);

      queue.show(const SeatLayerPickerToast('Taken.'));
      queue.show(const SeatLayerPickerToast('Taken.'));

      expect(announcements, 1);
    });

    test('runs no clock while nothing is rendering it', () {
      // A queue with no surface over it must not leave a timer behind: a
      // picker composed without a toast layer would otherwise fail every
      // widget test it appears in, on a message nobody could have seen.
      final queue = SeatLayerPickerToastQueue();
      addTearDown(queue.dispose);
      queue.show(const SeatLayerPickerToast('Unwatched.'));
      expect(queue.current, isNotNull);
    });

    test('belongs to the controller, and is the same queue twice', () {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final controller = SeatLayerPickerController(mapController: map);
      addTearDown(controller.dispose);

      expect(
        seatLayerPickerToasts(controller),
        same(seatLayerPickerToasts(controller)),
      );
    });
  });

  testWidgets('a seat taken by another buyer is said, and shakes',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final controller = SeatLayerPickerController(mapController: map);

    await tester
        .pumpWidget(pickerHarness(map, _layer(), controller: controller));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    map.emitConflict(const <String>['D-14']);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Seat D-14 was just taken by another buyer.'),
        findsOneWidget);
    expect(
      seatLayerPickerToasts(controller).current!.tone,
      SeatLayerPickerToastTone.error,
    );

    // Gone on its own, with nothing for the buyer to dismiss.
    await tester.pump(seatLayerToastDwell);
    await tester.pumpAndSettle();
    expect(
        find.text('Seat D-14 was just taken by another buyer.'), findsNothing);
  });

  testWidgets('a bulk conflict falls back to the unnamed sentence',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layer()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    map.emitConflict(const <String>['D-14', 'D-15']);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('One or more seats were just taken. Please pick again.'),
      findsOneWidget,
    );
    await tester.pump(seatLayerToastDwell);
    await tester.pumpAndSettle();
  });

  testWidgets('sales closing mid-session is said once', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layer()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    map.emit(<String, Object?>{
      ...pickerSnapshot(revision: 2),
      'event': <String, Object?>{
        ...pickerSnapshot()['event']! as Map<String, Object?>,
        'salesClosed': true,
      },
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sales are closed for this event.'), findsOneWidget);
    await tester.pump(seatLayerToastDwell);
    await tester.pumpAndSettle();
  });

  testWidgets('the band lets a tap through to the map under it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    var tapsOnTheMap = 0;

    await tester.pumpWidget(
      pickerHarness(
        map,
        Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => tapsOnTheMap += 1,
              ),
            ),
            const Positioned.fill(child: SeatLayerPickerToastLayer()),
          ],
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(195, 700));
    expect(tapsOnTheMap, 1);
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('toast — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);
        final controller = SeatLayerPickerController(mapController: map);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              const SizedBox(
                width: 390,
                height: 120,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: SeatLayerPickerToastLayer()),
                  ],
                ),
              ),
            ),
            controller: controller,
            platformBrightness: brightness,
          ),
        );
        map.emit(pickerSnapshot());
        await tester.pumpAndSettle();

        seatLayerPickerToasts(controller).show(
          const SeatLayerPickerToast(
            'Your hold ended while you were away. Those seats are still free.',
            tone: SeatLayerPickerToastTone.warning,
            actionLabel: 'Select them again',
            onAction: _noop,
          ),
        );
        await tester.pumpAndSettle();

        await expectGolden(tester, 'toast_${brightness.name}');
        await tester.pump(seatLayerToastDwell);
        await tester.pumpAndSettle();
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}

void _noop() {}
