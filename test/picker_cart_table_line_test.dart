// A table booked as one is named once in the cart, as the web's cart names
// it: "Table T2", and how many guests it is for under it. Its name is both its
// row and its label, and the card read "T2 · T2".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Future<void> _pumpTable(
  WidgetTester tester, {
  required String bookingMode,
  String locale = 'en',
}) async {
  final map = FakePickerMap();
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      const SingleChildScrollView(child: SeatLayerCartList()),
      options: SeatLayerPickerOptions(
        strings: SeatLayerPickerStrings.forLocale(Locale(locale)),
      ),
    ),
  );
  final snapshot = pickerSnapshot(
    cartItems: <Object?>[
      <String, Object?>{
        'lineKey': 'table:T2',
        'label': 'T2',
        'displayLabel': 'T2',
        'objectId': 'seat-a-1',
        'objectType': 'table',
        'categoryKey': 'standard',
        'unitPrice': 25.0,
        'currency': 'EUR',
        'quantity': 4,
      },
    ],
  );
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  // What the runtime sends for a table booked as one: the table's name as
  // the row and as the display label, and no seat number.
  selection['seats'] = (selection['seats']! as List<Object?>)
      .map((item) => <String, Object?>{
            ...(item! as Map<String, Object?>)
              ..remove('seatNumber')
              ..remove('displayType')
              ..remove('sectionLabel'),
            'label': 'T2',
            'displayLabel': 'T2',
            'rowLabel': 'T2',
            'objectType': 'table',
            'bookingMode': bookingMode,
            'capacity': 4,
          })
      .toList();
  map.emit(<String, Object?>{...snapshot, 'selection': selection});
  await pumpToRest(tester);
}

Finder _line(String value) => find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          (widget.data ?? widget.textSpan?.toPlainText()) == value,
      description: 'a cart card line reading "$value"',
    );

void main() {
  testWidgets('a whole table: its name once, and its guests', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpTable(tester, bookingMode: 'whole');
    expect(_line('Table T2'), findsOneWidget);
    expect(_line('Guests 4 · Standard'), findsOneWidget);
    expect(find.textContaining('T2 · T2'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp(r'Table T2 · Guests 4')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('in the buyer\'s language', (tester) async {
    await _pumpTable(tester, bookingMode: 'whole', locale: 'de');
    expect(_line('Tisch T2'), findsOneWidget);
  });

  testWidgets('a chair of a table booked by the chair keeps its seat',
      (tester) async {
    await _pumpTable(tester, bookingMode: '');
    expect(_line('Table T2'), findsNothing);
  });
}
