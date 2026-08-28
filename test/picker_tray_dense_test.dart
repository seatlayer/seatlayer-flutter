import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_tray_dense.dart';

SeatLayerTicketLine _line({
  required String seatLabel,
  String section = 'Gallery',
  String rowLabel = 'A',
  String amountText = r'$75',
  bool groupable = true,
  bool held = false,
}) =>
    SeatLayerTicketLine(
      item: SeatLayerCheckoutLineItem(
        lineKey: '$section-$rowLabel-$seatLabel',
        label: '$rowLabel-$seatLabel',
        objectId: '$rowLabel-$seatLabel',
        objectType: ObjectType.seat,
        categoryKey: 'standard',
        unitPrice: 75,
        currency: 'USD',
        quantity: 1,
      ),
      section: section,
      rowLabel: rowLabel,
      seatLabel: seatLabel,
      categoryLabel: 'Standard',
      categoryColor: const Color(0xFF635BFF),
      amountText: amountText,
      amount: 75,
      groupable: groupable,
      held: held,
    );

void main() {
  _seatOrderTests();

  group('runSeatsLabel', () {
    test('one seat reads as itself', () {
      expect(runSeatsLabel(<String>['3']), '3');
    });

    test('consecutive numbers become a range', () {
      expect(runSeatsLabel(<String>['1', '2', '3', '4', '5', '6']), '1–6');
    });

    test('a gap is never smoothed into a range', () {
      // "1–6" for 1, 2, 4, 5, 6 would tell the buyer they hold seat 3.
      expect(runSeatsLabel(<String>['1', '2', '4', '5', '6']), '1, 2, 4 +2');
    });

    test('three or fewer non-consecutive numbers are listed in full', () {
      expect(runSeatsLabel(<String>['1', '3']), '1, 3');
    });

    test('labels that are not numbers are listed, not ranged', () {
      expect(runSeatsLabel(<String>['A', 'B', 'C', 'D']), 'A, B, C +1');
    });
  });

  group('groupTicketLines', () {
    test('consecutive matching tickets fold into one run', () {
      final runs = groupTicketLines(<SeatLayerTicketLine>[
        _line(seatLabel: '1'),
        _line(seatLabel: '2'),
        _line(seatLabel: '3'),
      ]);

      expect(runs, hasLength(1));
      expect(runs.single.seatsLabel, '1–3');
      expect(runs.single.total, 225);
    });

    test('a different row breaks the run', () {
      final runs = groupTicketLines(<SeatLayerTicketLine>[
        _line(seatLabel: '1'),
        _line(seatLabel: '1', rowLabel: 'B'),
      ]);

      expect(runs, hasLength(2));
    });

    test('a different price breaks the run', () {
      final runs = groupTicketLines(<SeatLayerTicketLine>[
        _line(seatLabel: '1'),
        _line(seatLabel: '2', amountText: r'$90'),
      ]);

      expect(runs, hasLength(2));
    });

    test('matching tickets that are not adjacent stay apart', () {
      // The cart's order is the order the buyer picked in; reordering it to
      // make a bigger run would move a ticket out from under their finger.
      final runs = groupTicketLines(<SeatLayerTicketLine>[
        _line(seatLabel: '1'),
        _line(seatLabel: '1', rowLabel: 'B'),
        _line(seatLabel: '2'),
      ]);

      expect(runs, hasLength(3));
    });

    test('a ticket carrying its own control is never folded', () {
      final runs = groupTicketLines(<SeatLayerTicketLine>[
        _line(seatLabel: '1', groupable: false),
        _line(seatLabel: '2', groupable: false),
      ]);

      expect(runs, hasLength(2));
    });

    test('held and fresh tickets do not mix', () {
      final runs = groupTicketLines(<SeatLayerTicketLine>[
        _line(seatLabel: '1', held: true),
        _line(seatLabel: '2'),
      ]);

      expect(runs, hasLength(2));
    });
  });

  group('ticketIsGroupable', () {
    SeatLayerCheckoutLineItem item({int quantity = 1, ObjectType? type}) =>
        SeatLayerCheckoutLineItem(
          lineKey: 'k',
          label: 'A-1',
          objectId: 'a-1',
          objectType: type ?? ObjectType.seat,
          categoryKey: 'standard',
          unitPrice: 75,
          currency: 'USD',
          quantity: quantity,
        );

    test('a plain single seat folds', () {
      expect(ticketIsGroupable(item(), null), isTrue);
    });

    test('a table booked for several guests does not', () {
      expect(ticketIsGroupable(item(quantity: 4), null), isFalse);
    });

    test('general admission does not', () {
      expect(ticketIsGroupable(item(type: ObjectType.ga), null), isFalse);
    });
  });
}

void _seatOrderTests() {
  test('an opened run answers in the order its label reads', () {
    final runs = groupTicketLines(<SeatLayerTicketLine>[
      _line(seatLabel: '6'),
      _line(seatLabel: '5'),
      _line(seatLabel: '7'),
    ]);
    expect(runs.single.seatsLabel, '5–7');
    expect(
      runs.single.membersInSeatOrder
          .map((member) => member.seatLabel)
          .toList(),
      <String>['5', '6', '7'],
    );
  });

  test('unnumbered seats keep the order the buyer picked them in', () {
    final runs = groupTicketLines(<SeatLayerTicketLine>[
      _line(seatLabel: 'B'),
      _line(seatLabel: 'A'),
    ]);
    expect(
      runs.single.membersInSeatOrder
          .map((member) => member.seatLabel)
          .toList(),
      <String>['B', 'A'],
    );
  });
}
