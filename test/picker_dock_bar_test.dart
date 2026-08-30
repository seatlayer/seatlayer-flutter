import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// A venue whose only section is called [name], with [seatsLeft] free.
Map<String, Object?> _oneSection(String name, {int? seatsLeft = 73}) =>
    pickerSnapshot(
      withSelection: false,
      sections: <Object?>[
        <String, Object?>{
          'id': 'section-a',
          'label': name,
          'color': '#635BFF',
          'seatsLeft': seatsLeft,
        },
      ],
    );

/// The dock at exactly [width] points, showing a section called [name].
Future<void> _pumpDockAt(
  WidgetTester tester, {
  required double width,
  required String name,
  int? seatsLeft = 73,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  final map = FakePickerMap();
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  final dock = SizedBox(
    width: width,
    child: const SeatLayerDockBar(reserveBottomInset: false),
  );
  await tester.pumpWidget(
    pickerHarness(
      map,
      Align(
        alignment: Alignment.bottomLeft,
        child: golden ? goldenSubject(dock) : dock,
      ),
      platformBrightness: brightness,
    ),
  );
  map.emit(_oneSection(name, seatsLeft: seatsLeft));
  await tester.pumpAndSettle();
}

/// The laid-out paragraph the section name was drawn into.
RenderParagraph _nameParagraph(WidgetTester tester, String name) =>
    tester.renderObject<RenderParagraph>(find.text(name));

/// The fixture venue with [count] seats picked in `Gallery`.
Map<String, Object?> _galleryPicks(int count, {int revision = 2}) {
  final snapshot =
      pickerSnapshot(sections: pickerSections(), revision: revision);
  final selection = snapshot['selection']! as Map<String, Object?>;
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = List<Object?>.generate(
    count,
    (index) => <String, Object?>{
      ...seat,
      'id': 'seat-a-${index + 1}',
      'label': 'A-${index + 1}',
      'seatNumber': '${index + 1}',
    },
  );
  return snapshot;
}

void main() {
  testWidgets('the dock names the focused section and its remaining seats',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(find.text('Gallery'), findsOneWidget);
    // 74 free, less the one seat the fixture's buyer has already picked there.
    expect(find.text('73 left'), findsOneWidget);
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

  testWidgets('Venue returns directly to all sections',
      (tester) async {
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

  group('the name never loses letters before anything else does', () {
    // The owner's screenshot: `Sponsor Ta… · 72 left`. A truncated place name
    // is the one thing in the dock a buyer cannot reconstruct, and it was
    // being cut while the count still spelled out its own word.
    testWidgets('a long name keeps its letters and the count keeps its word',
        (tester) async {
      await _pumpDockAt(tester, width: 390, name: 'Sponsor Tables');

      expect(
          _nameParagraph(tester, 'Sponsor Tables').didExceedMaxLines, isFalse);
      expect(find.text('73 left'), findsOneWidget);
      expect(find.text('Venue'), findsOneWidget);
    });

    testWidgets('a longer name collapses the count to the number',
        (tester) async {
      await _pumpDockAt(tester, width: 390, name: 'Sponsor Tables VIP');

      expect(_nameParagraph(tester, 'Sponsor Tables VIP').didExceedMaxLines,
          isFalse);
      // The exact number survives; only the word it is counting goes.
      expect(find.text('73'), findsOneWidget);
      expect(find.text('73 left'), findsNothing);
      expect(find.text('Venue'), findsOneWidget);
    });

    testWidgets('a narrow bar drops the count, then the Venue label',
        (tester) async {
      await _pumpDockAt(tester, width: 320, name: 'Sponsor Tables');

      expect(
          _nameParagraph(tester, 'Sponsor Tables').didExceedMaxLines, isFalse);
      expect(find.textContaining('73'), findsNothing);
      // The word goes; the control and its accessible name stay.
      expect(find.text('Venue'), findsNothing);
      expect(find.byTooltip('Venue'), findsOneWidget);
      // And the way through the venue is never what pays for the room.
      expect(find.byTooltip('Previous section'), findsOneWidget);
      expect(find.byTooltip('Next section'), findsOneWidget);
    });

    testWidgets('a name with nowhere left to go takes a second line',
        (tester) async {
      const name = 'Sponsor Tables VIP Terrace East';
      await _pumpDockAt(tester, width: 260, name: name);

      final paragraph = _nameParagraph(tester, name);
      expect(paragraph.maxLines, 2);
      // Two lines of 13 would crowd a 52-point bar.
      expect(paragraph.text.style?.fontSize, 12);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.size.height, greaterThan(19));
    });

    for (final width in <double>[390, 360, 320, 280]) {
      testWidgets('the dock never overflows at $width', (tester) async {
        // A row that overflows throws in a test, so this also pins the
        // measured width of a Material icon control: underestimate it in
        // `_stepWidth` and the ladder hands the name room that is not there.
        await _pumpDockAt(
          tester,
          width: width,
          name: 'Sponsor Tables VIP Terrace East',
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('goldens', () {
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
      }, tags: goldenTag);
    }

    // The two phone widths the ladder is specified against: a current handset
    // and the narrowest one still in use.
    for (final width in <double>[390, 320]) {
      testWidgets('dock bar golden — long name at $width', (tester) async {
        await _pumpDockAt(
          tester,
          width: width,
          name: 'Sponsor Tables VIP',
          golden: true,
        );

        await expectGolden(tester, 'dock_bar_long_name_${width.round()}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);

  testWidgets("the count comes down by the buyer's own picks", (tester) async {
    // The runtime counts a seat as available until it is held, so a section
    // the buyer has just taken two seats out of still reports its whole free
    // count. The dock said `74 left` with two of the seventy-four already in
    // the buyer's cart.
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    // One seat, in `Gallery`, which is section-a's label in the fixture.
    expect(find.text('73 left'), findsOneWidget);
    expect(find.text('74 left'), findsNothing);

    map.emit(_galleryPicks(3, revision: 4));
    await tester.pumpAndSettle();
    expect(find.text('71 left'), findsOneWidget);
  });

  testWidgets('a seat in another section leaves this one alone',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    final snapshot = pickerSnapshot(sections: pickerSections());
    for (final seat in (snapshot['selection']!
        as Map<String, Object?>)['seats']! as List<Object?>) {
      (seat! as Map<String, Object?>)['sectionLabel'] = 'Terrace';
    }
    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(find.text('74 left'), findsOneWidget);
  });

  testWidgets('a section that reports no count still reports none',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerDockBar()));
    map.emit(
      pickerSnapshot(sections: pickerSections(), focusedSectionId: 'section-c'),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('left'), findsNothing);
    expect(find.text('Orchestra'), findsOneWidget);
  });
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
    find
        .descendant(
          of: find.byType(SeatLayerDockBar),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (decorated.decoration as BoxDecoration).color;
}
