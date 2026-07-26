import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/payloads.dart';

void main() {
  group('open enums — unknown values never throw', () {
    test('a known seat status maps to its case', () {
      expect(SeatStatus.fromRaw('booked'), same(SeatStatus.booked));
      expect(SeatStatus.booked.isUnknown, isFalse);
    });

    test('an unfamiliar seat status folds into Unknown, preserving the raw',
        () {
      final s = SeatStatus.fromRaw('quantum_superposition');
      expect(s, isA<SeatStatusUnknown>());
      expect(s.isUnknown, isTrue);
      expect(s.raw, 'quantum_superposition');
    });

    test('an unfamiliar event mode folds into Unknown', () {
      final m = EventMode.fromRaw('rehearsal');
      expect(m.isUnknown, isTrue);
      expect(m.raw, 'rehearsal');
    });

    test('an unfamiliar transport name folds into Unknown', () {
      final t = TransportName.fromRaw('carrier_pigeon');
      expect(t.isUnknown, isTrue);
      expect(t.raw, 'carrier_pigeon');
    });

    test('an unfamiliar object type folds into Unknown', () {
      final o = ObjectType.fromRaw('hovercraft');
      expect(o.isUnknown, isTrue);
      expect(o.raw, 'hovercraft');
    });
  });

  group('numeric tolerance — double-vs-int (the bug a real run once caught)',
      () {
    test('HoldResult.expiresAt decodes from an integer JSON number', () {
      final hold =
          HoldResult.fromJson({'holdId': 'h1', 'expiresAt': 1712000000000});
      expect(hold, isNotNull);
      expect(hold!.expiresAt, 1712000000000.0);
    });

    test('HoldResult.expiresAt decodes from a double JSON number', () {
      final hold =
          HoldResult.fromJson({'holdId': 'h1', 'expiresAt': 1712000000000.0});
      expect(hold!.expiresAt, 1712000000000.0);
    });

    test('HoldLineItem.quantity accepts an integral double', () {
      final item = HoldLineItem.fromJson({'label': 'A-1', 'quantity': 2.0});
      expect(item!.quantity, 2);
    });
  });

  group('struct decoders — tolerate missing and unknown fields', () {
    test('SelectedSeat ignores fields it does not know', () {
      final seat = SelectedSeat.fromJson({
        'id': 's1',
        'label': 'A-1',
        'brandNewFieldFromAFutureBundle': {'nested': true},
        'commercial': {'premium': true, 'anotherNewFlag': 1},
      });
      expect(seat, isNotNull);
      expect(seat!.label, 'A-1');
      expect(seat.commercial!.premium, isTrue);
    });

    test('SelectedSeat.buyerFacingLabel falls back to label', () {
      final plain = SelectedSeat.fromJson({'id': 's1', 'label': 'A-1'})!;
      expect(plain.buyerFacingLabel, 'A-1');
      final display = SelectedSeat.fromJson(
          {'id': 's1', 'label': 'A-1', 'displayLabel': 'Loge 1'})!;
      expect(display.buyerFacingLabel, 'Loge 1');
    });

    test(
        'a seat missing its required id/label decodes to null (dropped by lists)',
        () {
      expect(SelectedSeat.fromJson({'label': 'A-1'}), isNull);
      expect(SelectedSeat.fromJson({'id': 's1'}), isNull);
      expect(SelectedSeat.fromJson('not an object'), isNull);
    });

    test('a hold with a seat list drops only the malformed entries', () {
      final hold = HoldResult.fromJson({
        'holdId': 'h1',
        'expiresAt': 1,
        'seats': [
          {'id': 's1', 'label': 'A-1'},
          {'label': 'no-id'}, // malformed → dropped
          {'id': 's3', 'label': 'A-3'},
        ],
      });
      expect(hold!.seats!.map((s) => s.label), ['A-1', 'A-3']);
    });
  });

  group('ReadyInfo — unknown enum values survive', () {
    test('decodes protocol/mode/transport/event, folding unknowns', () {
      final info = ReadyInfo.fromJson({
        'protocol': 1,
        'mode': 'test',
        'transport': 'flutter',
        'chart': {'event': 'ev_1'},
      });
      expect(info.protocolRevision, 1);
      expect(info.mode, EventMode.test);
      expect(info.transport, TransportName.flutter);
      expect(info.eventKey, 'ev_1');
    });

    test('an unknown mode/transport does not throw', () {
      final info = ReadyInfo.fromJson(
          {'protocol': 9, 'mode': 'dress_rehearsal', 'transport': 'quantum'});
      expect(info.mode.isUnknown, isTrue);
      expect(info.transport.isUnknown, isTrue);
      expect(info.protocolRevision, 9);
    });

    test('missing fields fall back sensibly', () {
      final info = ReadyInfo.fromJson({});
      expect(info.protocolRevision, 1);
      expect(info.mode, EventMode.live);
      expect(info.transport.isUnknown, isTrue);
      expect(info.eventKey, isNull);
    });
  });

  group('BundleInfo', () {
    test('reads hello, and reports command/capability support', () {
      final info = BundleInfo.fromJson({
        'bundle': '0.26.0',
        'protocol': {'min': 1, 'max': 1},
        'capabilities': ['hold', 'ga'],
        'events': ['sys.ready'],
        'commands': ['hold', 'zoomToFit'],
      });
      expect(info.bundle, '0.26.0');
      expect(info.supportsCommand('hold'), isTrue);
      expect(info.supportsCommand('teleport'), isFalse);
      expect(info.supportsCapability('ga'), isTrue);
    });
  });
}
