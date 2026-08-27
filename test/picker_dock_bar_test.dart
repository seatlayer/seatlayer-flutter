import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  testWidgets('the dock names the focused section and its remaining seats',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('74 left'), findsOneWidget);
    expect(find.text('Venue'), findsOneWidget);
  });

  testWidgets('the dot follows the section\'s dominant category, not its paint',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    // The section is authored green while every free seat in it is Standard.
    // A drawing decision is not a ticket one: the dot has to agree with the
    // price legend, which paints from the category list.
    map.emit(
      pickerSnapshot(
        sections: <Object?>[
          <String, Object?>{
            'id': 'section-a',
            'label': 'Gallery',
            'color': '#22A06B',
            'dominantCategoryKey': 'standard',
            'seatsLeft': 74,
          },
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(_dotColor(tester), const Color(0xFF635BFF));
  });

  testWidgets('a section that names no dominant category keeps its own colour',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(_dotColor(tester), const Color(0xFF635BFF));
  });

  testWidgets('a dominant category the catalog does not carry falls back',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(
      pickerSnapshot(
        sections: <Object?>[
          <String, Object?>{
            'id': 'section-a',
            'label': 'Gallery',
            'color': '#22A06B',
            'dominantCategoryKey': 'filtered-out',
            'seatsLeft': 74,
          },
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(_dotColor(tester), const Color(0xFF22A06B));
  });

  testWidgets('a section with no known count shows no count at all',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(
      pickerSnapshot(sections: pickerSections(), focusedSectionId: 'section-c'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orchestra'), findsOneWidget);
    expect(find.textContaining('left'), findsNothing);
  });

  testWidgets('the dock slides away at the venue overview', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections(), rung: 'overview'));
    await tester.pumpAndSettle();

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, 0);
  });

  testWidgets('stepping moves by snapshot order and never wraps around',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(_stepEnabled(tester, 'Previous section'), isFalse);

    await tester.tap(find.byTooltip('Next section'));
    await tester.pump();
    expect(
      map.callsTo('picker.focusSection').single.$2,
      <String, Object?>{'sectionId': 'section-b'},
    );

    map.emit(
      pickerSnapshot(
        revision: 5,
        sections: pickerSections(),
        focusedSectionId: 'section-c',
      ),
    );
    await tester.pumpAndSettle();
    expect(_stepEnabled(tester, 'Next section'), isFalse);
  });

  testWidgets('Venue returns the map to the overview', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Venue'));
    await tester.pump();

    expect(map.callsTo('picker.overview'), hasLength(1));
  });

  testWidgets('the dock is 52 points tall plus the device inset',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(SeatLayerDockBar)).height,
      const SeatLayerPickerLayout().dockBarHeight,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets('dock bar golden — ${brightness.name}', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Align(
            alignment: Alignment.bottomCenter,
            child: goldenSubject(
              const SeatLayerDockBar(reserveBottomInset: false),
            ),
          ),
          platformBrightness: brightness,
        ),
      );
      map.emit(pickerSnapshot(sections: pickerSections()));
      await tester.pumpAndSettle();

      await expectGolden(tester, 'dock_bar_${brightness.name}');
    });
  }
}

bool _stepEnabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;

/// The colour of the dock's section dot.
Color? _dotColor(WidgetTester tester) {
  final decorated = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(SeatLayerDockBar),
      matching: find.byType(DecoratedBox),
    ).first,
  );
  return (decorated.decoration as BoxDecoration).color;
}
