import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_options.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  testWidgets('the form is two selects, a stepper and one action',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    // The venue's own defaults are already filled in.
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Find 2 best seats'), findsOneWidget);
    // No card title, no helper paragraph.
    expect(find.text('Find the best seats together'), findsNothing);
    expect(find.text('Ticket type'), findsNothing);
  });

  testWidgets('the two selects share one row at the specified height',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    final selects = find.byType(DropdownButtonHideUnderline);
    expect(selects, findsNWidgets(2));
    final first = tester.getRect(selects.first);
    final second = tester.getRect(selects.last);
    expect(first.top, second.top);
    expect(first.right, lessThan(second.left));

    final boxes = find.ancestor(
      of: selects.first,
      matching: find.byType(Container),
    );
    expect(
      tester.getSize(boxes.first).height,
      const SeatLayerPickerLayout().selectorHeight,
    );
  });

  testWidgets('it searches the focused zone and the filtered category',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find 2 best seats'));
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.bestAvailable').single.$2, <String, Object?>{
      'qty': 2,
      'categoryKey': 'standard',
      'zoneId': 'gallery',
      'preferPremium': false,
    });
  });

  testWidgets('an explicit category and the whole venue can be chosen',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    map.emit(
      bestAvailableSnapshot(categoryFilter: <Object?>['standard', 'premium']),
    );
    await tester.pumpAndSettle();

    expect(find.text('Any ticket type'), findsOneWidget);
    // A category the organizer marked not-for-sale is never offered.
    expect(find.text('Internal'), findsNothing);

    await tester.tap(find.text('Any ticket type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Premium').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gallery').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any venue zone').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find 2 best seats'));
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.bestAvailable').single.$2, <String, Object?>{
      'qty': 2,
      'categoryKey': 'premium',
      'preferPremium': false,
    });
  });

  testWidgets('the stepper changes what the action asks for', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More tickets'));
    await tester.pumpAndSettle();
    expect(find.text('Find 3 best seats'), findsOneWidget);
  });

  testWidgets('a read-only session cannot search', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerBestSeatsForm(),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Find 2 best seats'),
          )
          .onPressed,
      isNull,
    );
    expect(map.calls, isEmpty);
  });

  testWidgets('the feature can be turned off entirely', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerBestSeatsForm(),
        options: const SeatLayerPickerOptions(enableBestAvailable: false),
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Find 2 best seats'), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('best seats golden — ${brightness.name}', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Padding(
            padding: const EdgeInsets.all(14),
            child: goldenSubject(const SeatLayerBestSeatsForm()),
          ),
          platformBrightness: brightness,
        ),
      );
      map.emit(bestAvailableSnapshot());
      await tester.pumpAndSettle();

      await expectGolden(tester, 'best_seats_${brightness.name}');
    });
  }
}
