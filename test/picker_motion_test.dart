import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_motion.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  group('the catalogue', () {
    test('every token stays inside the 420 ms budget', () {
      for (final entry in SeatLayerPickerMotion.catalog.entries) {
        expect(
          entry.value,
          lessThanOrEqualTo(const Duration(milliseconds: 420)),
          reason: '${entry.key} is longer than a buyer will watch',
        );
        expect(entry.value, greaterThan(Duration.zero), reason: entry.key);
      }
    });

    test('a departure is never slower than the arrival it undoes', () {
      expect(
        SeatLayerPickerMotion.exit,
        lessThan(SeatLayerPickerMotion.enter),
      );
    });

    test('the catalogue names every token the picker spends', () {
      expect(
        SeatLayerPickerMotion.catalog.keys,
        containsAll(<String>[
          'enter',
          'exit',
          'dock',
          'sheet',
          'fly',
          'pop',
          'stagger',
          'crossfade',
          'toast',
          'immersive',
        ]),
      );
    });
  });

  group('reduced motion', () {
    testWidgets('collapses every token to nothing', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(SeatLayerPickerMotion.reduced(captured), isTrue);
      for (final token in SeatLayerPickerMotion.catalog.values) {
        expect(SeatLayerPickerMotion.of(captured, token), Duration.zero);
      }
    });

    testWidgets('leaves the tokens alone otherwise', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        SeatLayerPickerMotion.of(captured, SeatLayerPickerMotion.dock),
        SeatLayerPickerMotion.dock,
      );
    });

    testWidgets('a chrome animation spends the token, not its own number',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
      map.emit(pickerSnapshot(sections: pickerSections()));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).duration,
        SeatLayerPickerMotion.dock,
      );
    });
  });
}
