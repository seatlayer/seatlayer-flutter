import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_options.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Map<String, Object?> _withoutImmersiveFeatures() {
  final snapshot = pickerSnapshot();
  return <String, Object?>{
    ...snapshot,
    'features': <String, Object?>{'bestAvailable': true},
  };
}

void main() {
  testWidgets('the card states one seat, its price, and nothing else',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Gallery · Row A · Seat 1'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    // The dot already carries the category; its name would repeat the section.
    expect(find.text('Standard'), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
  });

  testWidgets('the phone card selects a tier and updates its headline price',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(tieredSeatSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Adult'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
    expect(find.text('For children aged 12 and under.'), findsOneWidget);
    expect(find.text('€100'), findsNWidgets(2));
    expect(find.text('€60'), findsOneWidget);

    await tester.tap(find.text('Child'));
    await tester.pump();

    expect(find.text('€100'), findsOneWidget);
    expect(find.text('€60'), findsNWidgets(2));

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.setSeatTier').single.$2,
      <String, Object?>{'seatId': 'seat-a-1', 'tierId': 'child'},
    );
  });

  testWidgets('the strip carries both pills when the event has both',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('View from here'), findsOneWidget);
    expect(find.text('3D'), findsOneWidget);
    expect(
      tester.getSize(find.byType(SeatLayerConfirmCard)).height,
      158,
    );
  });

  testWidgets('an event with neither drops the strip entirely', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_withoutImmersiveFeatures());
    await tester.pumpAndSettle();

    expect(find.text('View from here'), findsNothing);
    expect(find.text('3D'), findsNothing);
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 89);
  });

  testWidgets('the card is the screen less a gutter, capped at 360',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey<String>('seatlayer.confirm-card.surface'),
            ),
          )
          .width,
      358,
    );
  });

  testWidgets('Cancel removes the seat and Select tells the host',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    var selected = 0;

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerConfirmCard(onConfirm: (_) async => selected++),
        callbacks: SeatLayerPickerCallbacks(onSeatSelected: (_) => selected++),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(selected, 2);
  });

  testWidgets('Cancel gives the seat back', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.removeCartLine').single.$2,
      <String, Object?>{'label': 'A-1'},
    );
  });

  testWidgets('read-only sessions never offer a decision', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Select'), findsNothing);
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('confirm card golden with strip — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerConfirmCard()),
            platformBrightness: brightness,
          ),
        );
        map.emit(pickerSnapshot());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'confirm_card_strip_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('confirm card golden without strip — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerConfirmCard()),
            platformBrightness: brightness,
          ),
        );
        map.emit(_withoutImmersiveFeatures());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'confirm_card_plain_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
