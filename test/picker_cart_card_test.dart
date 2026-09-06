// The cart card is the same card on every width, and it says what the
// organizer said about a seat ONCE, in words.
//
// It used to carry icon markers AND note rows, and since both drew the same
// set the line read as the same fact printed twice. The words won; the glyph
// rows belong to the seat card.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_seat_lift.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();

SelectedSeat _seat({
  List<String>? accessibility,
  String? wheelchairSpaceType,
  bool restricted = false,
  bool obstructed = false,
  bool premium = false,
  String? note,
}) =>
    SelectedSeat(
      id: 'seat-a-1',
      label: 'A-1',
      accessibility: accessibility,
      wheelchairSpaceType: wheelchairSpaceType,
      commercial: SeatCommercialAttributes(
        restrictedView: restricted,
        obstructedView: obstructed,
        premium: premium,
        note: note,
      ),
    );

List<String> _titles(SelectedSeat? seat) =>
    seatLayerCartNoteLines(seat, _strings)
        .map((line) => line.title)
        .toList(growable: false);

/// The fixture snapshot with per-seat attributes on the one selected seat.
Map<String, Object?> _withAttributes(Map<String, Object?> attributes) {
  final snapshot = pickerSnapshot();
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = <Object?>[
    <String, Object?>{...seat, ...attributes},
  ];
  return <String, Object?>{...snapshot, 'selection': selection};
}

void main() {
  group('what a card says about its seat', () {
    test('a seat with nothing on it says nothing', () {
      expect(_titles(_seat()), isEmpty);
      expect(_titles(null), isEmpty);
    });

    test('the order is what the seat provides, then what it costs the buyer',
        () {
      final lines = _titles(
        _seat(
          accessibility: <String>['companion'],
          wheelchairSpaceType: 'no-seat',
          restricted: true,
          obstructed: true,
          premium: true,
        ),
      );
      expect(lines, <String>[
        'Companion',
        'Empty wheelchair space',
        'Restricted view',
        'Obstructed view',
        'Premium seat',
      ]);
    });

    test('restricted and obstructed are separate lines', () {
      // They used to collapse into one with restricted winning, which meant a
      // seat behind both a rail and a pillar told the buyer about the rail.
      final lines = _titles(_seat(restricted: true, obstructed: true));
      expect(lines, <String>['Restricted view', 'Obstructed view']);
    });

    test('a provision replaces the plain wheelchair accommodation', () {
      expect(
        _titles(
          _seat(
            accessibility: <String>['wheelchair'],
            wheelchairSpaceType: 'seat-present',
          ),
        ),
        <String>['Accessible physical seat'],
      );
      // Without a provision the accommodation itself is the line.
      expect(
        _titles(_seat(accessibility: <String>['wheelchair'])),
        <String>['Wheelchair'],
      );
    });

    test('an accommodation this build does not know is dropped, not printed',
        () {
      expect(_titles(_seat(accessibility: <String>['teleporter'])), isEmpty);
    });

    test('the organizer\'s sentence belongs to the first selling mark', () {
      final lines = seatLayerCartNoteLines(
        _seat(restricted: true, premium: true, note: 'Pillar at the aisle end'),
        _strings,
      );
      expect(lines.map((line) => line.title),
          <String>['Restricted view', 'Premium seat']);
      expect(lines.first.note, 'Pillar at the aisle end');
      expect(lines.first.spoken, 'Restricted view: Pillar at the aisle end');
      expect(lines.last.note, isNull);
    });

    test('with no mark to explain, the sentence is its own line', () {
      final lines = seatLayerCartNoteLines(
        _seat(note: 'Bring photo ID'),
        _strings,
      );
      expect(lines.single.title, 'Organizer note');
      expect(lines.single.note, 'Bring photo ID');
    });

    test('an empty sentence is not a note', () {
      expect(_titles(_seat(note: '   ')), isEmpty);
    });
  });

  testWidgets('the words are drawn on the card, and read out with it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, const SingleChildScrollView(child: SeatLayerCartList())),
    );
    map.emit(
      _withAttributes(<String, Object?>{
        'commercial': <String, Object?>{
          'restrictedView': true,
          'note': 'Pillar at the aisle end',
        },
      }),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerCartCard), findsOneWidget);
    // In words, under the line they belong to — and the sentence rides the
    // mark it explains rather than standing on its own.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.textSpan?.toPlainText() ==
                'Restricted view Pillar at the aisle end',
      ),
      findsOneWidget,
    );
    // The whole card is one node: a screen reader hears the ticket and what is
    // true of it, not six unlabelled cells.
    expect(
      tester.getSemantics(find.byType(SeatLayerCartCard)).label,
      contains('Restricted view: Pillar at the aisle end'),
    );
  }, semanticsEnabled: true);

  testWidgets('the eye is drawn only where there is a view to open',
      (tester) async {
    final withThumbnails = nativeChromeBundle(
      capabilities: <String>[
        'native-chrome-contract-v1',
        seatLayerSeatViewThumbnailCapability,
      ],
    );
    final map = FakePickerMap(bundle: withThumbnails);
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, const SingleChildScrollView(child: SeatLayerCartList())),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final eye = find.widgetWithIcon(IconButton, Icons.visibility_outlined);
    expect(eye, findsOneWidget);
    // Both actions are the touch floor exactly: they sit two points apart, so
    // a larger invisible box would let one claim part of the other's ink.
    expect(
      tester.getSize(eye),
      const Size.square(SeatLayerSizeTokens.minimumHitTarget),
    );
    await tester.tap(eye);
    await tester.pumpAndSettle();
    expect(map.callsTo('picker.openSeatView'), hasLength(1));
  });

  testWidgets('a runtime that reports no photographs offers no eye',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, const SingleChildScrollView(child: SeatLayerCartList())),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      find.widgetWithIcon(IconButton, Icons.visibility_outlined),
      findsNothing,
    );
    // The × is still there: it is the one action a cart line always owes.
    expect(
        find.widgetWithIcon(IconButton, Icons.close_rounded), findsOneWidget);
  });

  testWidgets('tapping a card takes the map to the seat and keeps the sheet',
      (tester) async {
    // The sheet used to step down to peek on every card tap, so checking
    // three seats meant opening the cart three times (owner, 2026-09-06).
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        commands: const <String>['picker.frameSeat'],
      ),
    );
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SingleChildScrollView(child: SeatLayerCartList()),
        controller: picker,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    picker.setCartSheetExpanded(true);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SeatLayerCartCard));
    await tester.pumpAndSettle();

    final frames = map.callsTo(seatLayerFrameSeatCommand);
    expect(frames, hasLength(1));
    expect((frames.single.$2! as Map<String, Object?>)['seatId'], 'seat-a-1');
    expect(picker.cartSheetExpanded, isTrue);
  });
}
