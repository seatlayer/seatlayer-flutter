import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_options.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  testWidgets('the form is a stepper, two selects and one action',
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
    expect(find.text('Find 2 seats together'), findsOneWidget);
    // No card title, no helper paragraph.
    expect(find.text('Find the best seats together'), findsNothing);
    expect(find.text('Ticket type'), findsNothing);
  });

  testWidgets('quantity and type share row one, the zone gets row two',
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
    final type = tester.getRect(selects.first);
    final zone = tester.getRect(selects.last);
    // One explicit track: the zone is under the type, not beside it, because
    // its values are venue names and they are the long ones.
    expect(type.bottom, lessThanOrEqualTo(zone.top));

    final boxes = find.ancestor(
      of: selects.first,
      matching: find.byType(Container),
    );
    expect(
      tester.getSize(boxes.first).height,
      const SeatLayerPickerLayout().selectorHeight,
    );
    // The stepper is fixed, so the type select beside it never moves.
    final stepper = tester.getRect(
      find.ancestor(
        of: find.byTooltip('More tickets'),
        matching: find.byType(Container),
      ).first,
    );
    expect(stepper.width, 112);
    expect(stepper.top, tester.getRect(boxes.first).top);
  });

  testWidgets('a venue with no zones is not asked which zone', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    final snapshot = bestAvailableSnapshot();
    (snapshot['catalog']! as Map<String, Object?>)['bestAvailableZones'] =
        <Object?>[];
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);
    expect(find.text('Any venue zone'), findsNothing);
  });

  testWidgets('every control on the form clears the touch floor',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerBestSeatsForm()),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    // The stepper's own buttons fill the selector's inner height, and the
    // selector is the touch floor itself.
    expect(
      tester.getSize(find.byTooltip('Fewer tickets')).height,
      greaterThanOrEqualTo(
        const SeatLayerPickerLayout().selectorHeight - 2,
      ),
    );
    expect(
      tester.getSize(find.byTooltip('More tickets')).width,
      greaterThanOrEqualTo(40),
    );
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(46),
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

    await tester.tap(find.text('Find 2 seats together'));
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

    await tester.tap(find.text('Find 2 seats together'));
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
    expect(find.text('Find 3 seats together'), findsOneWidget);
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
            find.widgetWithText(FilledButton, 'Find 2 seats together'),
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

    expect(find.text('Find 2 seats together'), findsNothing);
  });

  group('goldens', () {
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
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
