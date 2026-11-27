// A table booked as one names itself on the seat card by its party size and
// its name, not as a row and a seat that both read the table's name. The
// card draws its eyebrow words upper-case.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Future<void> _pumpTable(
  WidgetTester tester, {
  required String bookingMode,
  String? sectionLabel = 'Gallery',
  String locale = 'en',
}) async {
  final map = FakePickerMap();
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      const SeatLayerConfirmCard(),
      options: SeatLayerPickerOptions(
        strings: SeatLayerPickerStrings.forLocale(Locale(locale)),
      ),
    ),
  );
  final snapshot = pickerSnapshot();
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
            if (bookingMode == 'variable') ...<String, Object?>{
              'minOccupancy': 2,
              'maxOccupancy': 6,
            },
            if (sectionLabel != null) 'sectionLabel': sectionLabel,
          })
      .toList();
  map.emit(<String, Object?>{...snapshot, 'selection': selection});
  await pumpToRest(tester);
}

void main() {
  testWidgets('a whole table: section, guests and the table\'s name',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpTable(tester, bookingMode: 'whole');
    expect(find.text('GUESTS'), findsOneWidget);
    expect(find.text('TABLE'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);
    expect(find.text('ROW'), findsNothing);
    expect(find.text('SEAT'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp(r'Gallery · Guests 4 · Table T2\b')),
      findsWidgets,
    );
    expect(find.bySemanticsLabel(RegExp(r'Seat T2')), findsNothing);
    semantics.dispose();
  });

  testWidgets('a party table says how many guests it takes', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpTable(tester, bookingMode: 'variable');
    expect(find.text('2–6'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'Guests 2–6 · Table T2\b')),
        findsWidgets);
    semantics.dispose();
  });

  testWidgets('the table is named without a section too', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpTable(tester, bookingMode: 'whole', sectionLabel: null);
    expect(find.text('GUESTS'), findsOneWidget);
    expect(find.text('TABLE'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);
    expect(find.text('SECTION'), findsNothing);
    semantics.dispose();
  });

  testWidgets('the words are the buyer\'s language', (tester) async {
    await _pumpTable(tester, bookingMode: 'whole', locale: 'de');
    expect(find.text('GÄSTE'), findsOneWidget);
    expect(find.text('TISCH'), findsOneWidget);
  });

  testWidgets('a seat at a table booked by the seat keeps row and seat',
      (tester) async {
    await _pumpTable(tester, bookingMode: '');
    expect(find.text('GUESTS'), findsNothing);
    expect(find.text('SEAT'), findsOneWidget);
  });
}
