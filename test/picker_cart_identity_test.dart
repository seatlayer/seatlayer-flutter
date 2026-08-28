// A cart line has to say where its seat is, however the seat was acquired.
//
// Best Available clears the renderer selection before it holds, and a resumed
// hold was never in one, so joining a line back to `selection` to render an
// address finds nothing for exactly the two paths where the buyer did not tap
// the seat — the line arrived as a price with no place on it. The runtime now
// puts the address on the line, and the dense list reads it from there first.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_models.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The dense list draws its identity as one `Text.rich`, so a plain text
/// finder cannot see it.
Finder _identity(String value) => find.byWidgetPredicate(
      (widget) =>
          widget is Text && widget.textSpan?.toPlainText() == value,
      description: 'a dense line reading "$value"',
    );

void main() {
  testWidgets('seats the buyer never tapped still say where they are',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SingleChildScrollView(child: SeatLayerCartList())),
    );
    map.emit(bestAvailableHeldSnapshot());
    await tester.pumpAndSettle();

    // Two consecutive seats fold into one run, and the row keeps only its own
    // name: the chart authored it `Choir A`, inside a section already named.
    expect(_identity('Choir · A · 9–10'), findsOneWidget);
  });

  testWidgets('a line with no address of its own falls back to the join',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SingleChildScrollView(child: SeatLayerCartList())),
    );
    // The tapped-seat path: the line carries no identity, the selection does.
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(_identity('Gallery · A · 1'), findsOneWidget);
  });

  testWidgets('an older runtime keeps the category name it always showed',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SingleChildScrollView(child: SeatLayerCartList())),
    );
    map.emit(bestAvailableHeldSnapshot(identityOnLines: false));
    await tester.pumpAndSettle();

    // Nothing knows the address, so the line reads as it did before: the
    // category, then the raw inventory labels.
    expect(_identity('Standard · A-9, A-10'), findsOneWidget);
  });

  test('a line knows whether it carries an address', () {
    const bare = SeatLayerCheckoutLineItem(
      lineKey: 'k',
      label: 'A-9',
      objectId: 'A-9',
      objectType: ObjectType.seat,
      categoryKey: 'standard',
      unitPrice: 25,
      currency: 'EUR',
      quantity: 1,
    );
    expect(bare.hasSeatIdentity, isFalse);

    const addressed = SeatLayerCheckoutLineItem(
      lineKey: 'k',
      label: 'A-9',
      objectId: 'A-9',
      objectType: ObjectType.seat,
      categoryKey: 'standard',
      unitPrice: 25,
      currency: 'EUR',
      quantity: 1,
      seatId: 'seat-a-9',
      sectionLabel: 'Choir',
      rowLabel: 'Choir A',
      seatNumber: '9',
    );
    expect(addressed.hasSeatIdentity, isTrue);
  });

  test('the address survives a round trip through the wire form', () {
    final decoded = SeatLayerCheckoutLineItem.fromJson(<String, Object?>{
      'label': 'A-9',
      'seatId': 'seat-a-9',
      'sectionLabel': 'Choir',
      'rowLabel': 'Choir A',
      'seatNumber': '9',
      'categoryKey': 'standard',
      'unitPrice': 25.0,
      'currency': 'EUR',
      'quantity': 1,
    })!;

    expect(decoded.seatId, 'seat-a-9');
    expect(decoded.sectionLabel, 'Choir');
    expect(decoded.rowLabel, 'Choir A');
    expect(decoded.seatNumber, '9');
  });
}
