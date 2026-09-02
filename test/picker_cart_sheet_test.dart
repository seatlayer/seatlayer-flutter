import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Future<void> _noopCheckout(_) async {}

Widget _sheet({bool expanded = true}) => SeatLayerCartSheet(
  expanded: expanded,
  onExpandedChanged: (_) {},
  onCheckout: _noopCheckout,
);

double _sheetHeight(WidgetTester tester) =>
    tester.getSize(find.byType(SeatLayerCartSheet)).height;

void main() {
  _identityJoinTests();

  testWidgets('the peek states the cart and the way on, and nothing else', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    // The count on the left, the money on the button — never the same number
    // twice on one screen.
    expect(find.text('1 ticket'), findsOneWidget);
    expect(find.text('1 ticket · €25'), findsNothing);
    expect(find.text('Continue · €25'), findsOneWidget);
    // The tray form is the only way into best seats.
    expect(find.text('Best seats'), findsNothing);
    expect(_sheetHeight(tester), 56);
  });

  testWidgets('an empty peek offers the cheapest ticket, not a button', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    expect(find.text('From €25'), findsOneWidget);
    expect(find.textContaining('Continue'), findsNothing);
    // A price with nothing to do about it is not an offer; the pill is.
    expect(find.text('Find seats'), findsOneWidget);
  });

  testWidgets('the empty peek offers a full-size way into the finder', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    var expanded = false;
    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: false,
            onExpandedChanged: (value) => expanded = value,
            onCheckout: _noopCheckout,
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    final pill = find.ancestor(
      of: find.text('Find seats'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(pill.first).height, 44);

    await tester.tap(find.text('Find seats'));
    await tester.pump();
    expect(expanded, isTrue);
  });

  testWidgets('the finder pill is withheld where the form would be refused', (
    tester,
  ) async {
    Future<void> expectNoPill(
      WidgetTester tester,
      Map<String, Object?> snapshot, {
      SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
    }) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Align(
            alignment: Alignment.bottomCenter,
            child: _sheet(expanded: false),
          ),
          options: options,
        ),
      );
      map.emit(snapshot);
      await tester.pumpAndSettle();
      expect(find.text('Find seats'), findsNothing);
    }

    final closed = pickerSnapshot(withSelection: false);
    (closed['event']! as Map<String, Object?>)['salesClosed'] = true;
    await expectNoPill(tester, closed);

    await expectNoPill(
      tester,
      pickerSnapshot(withSelection: false),
      options: const SeatLayerPickerOptions(enableBestAvailable: false),
    );
    await expectNoPill(
      tester,
      pickerSnapshot(withSelection: false),
      options: const SeatLayerPickerOptions(readOnly: true),
    );
    // Seats already reserved: the finder would take them away again.
    await expectNoPill(
      tester,
      pickerSnapshot(withSelection: false, holdOwner: 'picker'),
    );
  });

  testWidgets('the grabber keeps its promise: a swipe opens and closes the sheet',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    bool? asked;
    Widget sheet(bool expanded) => Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: expanded,
            onExpandedChanged: (value) => asked = value,
            onCheckout: _noopCheckout,
          ),
        );
    await tester.pumpWidget(pickerHarness(map, sheet(false)));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.fling(find.byType(SeatLayerCartSheet), const Offset(0, -80), 900);
    await tester.pumpAndSettle();
    expect(asked, isTrue);

    asked = null;
    await tester.pumpWidget(pickerHarness(map, sheet(true)));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(SeatLayerCartSheet), const Offset(0, 80), 900);
    await tester.pumpAndSettle();
    expect(asked, isFalse);
  });

  testWidgets('the collapsed way on is a full-size target', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Continue · €25')).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('a held row wears a lock and its own hairline', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    final row = tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(Icons.lock_rounded),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((row.decoration! as BoxDecoration).border, isNotNull);
  });

  testWidgets('the remove control clears the touch floor', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final remove = tester.getSize(
      find.widgetWithIcon(IconButton, Icons.close_rounded),
    );
    expect(remove.width, greaterThanOrEqualTo(44));
    expect(remove.height, greaterThanOrEqualTo(44));
  });

  testWidgets('the collapsed safe area carries required attribution only', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    Widget subject() => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: const EdgeInsets.only(bottom: 34)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    await tester.pumpWidget(pickerHarness(map, subject()));
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    expect(find.text('Powered by SeatLayer'), findsOneWidget);
    expect(_sheetHeight(tester), 90);
    final attributionRect = tester.getRect(find.text('Powered by SeatLayer'));
    final sheetRect = tester.getRect(find.byType(SeatLayerCartSheet));
    // Centred: a phone's rounded corner clips whatever hugs the trailing edge.
    expect(
      (attributionRect.center.dx - sheetRect.center.dx).abs(),
      lessThan(12),
    );

    final hidden = pickerSnapshot(revision: 2, withSelection: false);
    (hidden['branding']! as Map<String, Object?>)['attributionRequired'] =
        false;
    map.emit(hidden);
    await tester.pumpAndSettle();
    expect(find.text('Powered by SeatLayer'), findsNothing);
    expect(_sheetHeight(tester), 90);
  });

  testWidgets('the expanded header states the count once', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(snapshotWithTicketCount(6));
    await tester.pumpAndSettle();

    expect(find.text('6 tickets'), findsOneWidget);
    expect(find.textContaining('6 tickets · '), findsNothing);
    expect(find.text('Your tickets'), findsNothing);
  });

  testWidgets('the sheet follows its content and stops at three fifths', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    final oneTicket = _sheetHeight(tester);

    map.emit(_tenDistinctRows());
    await tester.pumpAndSettle();
    final tenRows = _sheetHeight(tester);

    expect(oneTicket, lessThan(tenRows));
    expect(tenRows, lessThanOrEqualTo(844 * .6));

    // Ten seats in one row are one run, so the sheet does not grow for them.
    map.emit(snapshotWithTicketCount(10, revision: 20));
    await tester.pumpAndSettle();
    expect(_sheetHeight(tester), oneTicket);
  });

  testWidgets('an empty tray stays short and hides its hint from the eye', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    expect(_sheetHeight(tester), lessThanOrEqualTo(240));
    expect(
      find.text(
        'Tap a seat on the map, or let us pick the best available '
        'for you.',
      ),
      findsNothing,
    );
    expect(find.text('Find the best seats together'), findsNothing);
    expect(find.byType(SeatLayerBestSeatsForm), findsOneWidget);
    expect(find.text('Find 2 seats together'), findsOneWidget);
  });

  testWidgets('the footer carries one full-width call to action', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Hold seats & checkout'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    expect(tester.getSize(find.byType(SeatLayerBookButton)).width, 390);
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
  });

  testWidgets('six seats in one row collapse to one line', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(snapshotWithTicketCount(6));
    await tester.pumpAndSettle();

    expect(find.textContaining('1–6'), findsOneWidget);
    expect(find.text('6 × €25'), findsOneWidget);
    expect(find.text('€150'), findsOneWidget);
  });

  testWidgets('removing a ticket is immediate and undoable', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump();

    expect(map.callsTo('picker.removeCartLine'), hasLength(1));
    expect(find.text('Undo'), findsOneWidget);

    // The undo bar is the picker's chrome, not the app's, so it paints the
    // picker's surface rather than Material's own inverse.
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      const SeatLayerPickerThemeData.light().surface,
    );

    // Let the bar finish rising; it is off-screen until it has.
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(map.callsTo('picker.selectObjects'), hasLength(1));
  });

  testWidgets('a read-only cart offers no removals', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byType(SeatLayerBestSeatsForm), findsNothing);
  });

  testWidgets('a long list collapses behind one more control', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: true,
            onExpandedChanged: (_) {},
            onCheckout: _noopCheckout,
            // One run per line, so the collapse rule is what is under test.
            cartList: const SeatLayerCartList(),
          ),
        ),
      ),
    );
    map.emit(_tenDistinctRows());
    await tester.pumpAndSettle();

    expect(find.text('+5 more'), findsOneWidget);
    await tester.tap(find.text('+5 more'));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      for (final entry in <(String, Map<String, Object?>, bool)>[
        ('empty', bestAvailableSnapshot(), true),
        ('one', pickerSnapshot(), true),
        ('six', snapshotWithTicketCount(6), true),
        ('many', _tenDistinctRows(), true),
        ('peek', pickerSnapshot(), false),
      ]) {
        testWidgets('cart sheet golden ${entry.$1} — ${brightness.name}', (
          tester,
        ) async {
          final map = FakePickerMap();
          addTearDown(map.dispose);
          usePhoneSurface(tester);

          await tester.pumpWidget(
            pickerHarness(
              map,
              Align(
                alignment: Alignment.bottomCenter,
                child: goldenSubject(_sheet(expanded: entry.$3)),
              ),
              platformBrightness: brightness,
            ),
          );
          map.emit(entry.$2);
          await tester.pumpAndSettle();

          await expectGolden(
            tester,
            'cart_sheet_${entry.$1}_${brightness.name}',
          );
        }, tags: goldenTag);
      }
    }
  }, skip: goldenSkip);
}

/// Ten tickets that share nothing, so each is its own run.
Map<String, Object?> _tenDistinctRows({int revision = 10}) {
  final snapshot = snapshotWithTicketCount(10, revision: revision);
  final cart = snapshot['cart']! as Map<String, Object?>;
  final selection = snapshot['selection']! as Map<String, Object?>;
  cart['items'] = <Object?>[
    for (var index = 0; index < 10; index++)
      <String, Object?>{
        ...(cart['items']! as List<Object?>)[index]! as Map<String, Object?>,
      },
  ];
  selection['seats'] = <Object?>[
    for (var index = 0; index < 10; index++)
      <String, Object?>{
        ...(selection['seats']! as List<Object?>)[index]!
            as Map<String, Object?>,
        'rowLabel': String.fromCharCode(65 + index),
      },
  ];
  return snapshot;
}

void _identityJoinTests() {
  testWidgets('a sectionless seat is named by its ticket type, once', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    // A chart with no sections: neither the line nor the seat behind it can
    // say where the seat is, so the ticket type has to.
    final snapshot = pickerSnapshot();
    final seats = (snapshot['selection']! as Map<String, Object?>)['seats']!
        as List<Object?>;
    for (final seat in seats.cast<Map<String, Object?>>()) {
      seat['sectionLabel'] = null;
    }
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(find.textContaining('Standard'), findsOneWidget);
    // And said once: the type that named the line is not read out again in
    // front of it.
    expect(
      tester
          .getSemantics(find.textContaining('Standard'))
          .label
          .contains('Standard, Standard'),
      isFalse,
    );
  });


  testWidgets('a line whose label differs still finds its seat', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    final snapshot = pickerSnapshot();
    // A Best Available result arrives as a line the buyer never tapped: the
    // cart's inventory label and the seat's own label need not agree, but the
    // object id does.
    final cart = snapshot['cart']! as Map<String, Object?>;
    final items = (cart['items']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((item) => <String, Object?>{...item, 'label': 'West Gallery A-1'})
        .toList();
    cart['items'] = items;
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(find.textContaining('Gallery'), findsWidgets);
    expect(find.textContaining('West Gallery A-1'), findsNothing);
  });
}
