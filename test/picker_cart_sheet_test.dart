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
  testWidgets('the peek states the cart and the way on, and nothing else',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
            alignment: Alignment.bottomCenter, child: _sheet(expanded: false)),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('1 ticket · €25'), findsOneWidget);
    expect(find.text('Continue · €25'), findsOneWidget);
    // The tray form is the only way into best seats.
    expect(find.text('Best seats'), findsNothing);
    expect(_sheetHeight(tester), 50);
  });

  testWidgets('an empty peek offers the cheapest ticket, not a button',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
            alignment: Alignment.bottomCenter, child: _sheet(expanded: false)),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    expect(find.text('From €25'), findsOneWidget);
    expect(find.textContaining('Continue'), findsNothing);
  });

  testWidgets('the expanded header states the count once', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, Align(alignment: Alignment.bottomCenter, child: _sheet())),
    );
    map.emit(snapshotWithTicketCount(6));
    await tester.pumpAndSettle();

    expect(find.text('6 tickets'), findsOneWidget);
    expect(find.textContaining('6 tickets · '), findsNothing);
    expect(find.text('Your tickets'), findsNothing);
  });

  testWidgets('the sheet follows its content and stops at three fifths',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, Align(alignment: Alignment.bottomCenter, child: _sheet())),
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

  testWidgets('an empty tray stays short and hides its hint from the eye',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, Align(alignment: Alignment.bottomCenter, child: _sheet())),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    expect(_sheetHeight(tester), lessThanOrEqualTo(200));
    expect(
      find.text('Tap a seat on the map, or let us pick the best available '
          'for you.'),
      findsNothing,
    );
    expect(find.text('Find the best seats together'), findsNothing);
    expect(find.byType(SeatLayerBestSeatsForm), findsOneWidget);
    expect(find.text('Find 2 best seats'), findsOneWidget);
  });

  testWidgets('the footer carries one full-width call to action',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, Align(alignment: Alignment.bottomCenter, child: _sheet())),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Hold seats & checkout'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    expect(
      tester.getSize(find.byType(SeatLayerBookButton)).width,
      390,
    );
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
  });

  testWidgets('six seats in one row collapse to one line', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
          map, Align(alignment: Alignment.bottomCenter, child: _sheet())),
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
          map, Align(alignment: Alignment.bottomCenter, child: _sheet())),
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

  for (final brightness in Brightness.values) {
    for (final entry in <(String, Map<String, Object?>, bool)>[
      ('empty', bestAvailableSnapshot(), true),
      ('one', pickerSnapshot(), true),
      ('six', snapshotWithTicketCount(6), true),
      ('many', _tenDistinctRows(), true),
      ('peek', pickerSnapshot(), false),
    ]) {
      testWidgets('cart sheet golden ${entry.$1} — ${brightness.name}',
          (tester) async {
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
      });
    }
  }
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
