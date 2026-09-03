import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

void main() {
  test('hosted and fixture runtime versions remain explicitly pinned', () {
    expect(seatLayerHostedWebVersion, '0.77.1');
    expect(seatLayerLegacyFixtureWebVersion, '0.68.0');
    expect(
      seatLayerMobilePageUrl,
      'https://cdn.seatlayer.io/seatlayer-js@$seatLayerHostedWebVersion/mobile.html',
    );
  });

  test('public Platform configuration forwards the publishable key', () {
    final configuration = SeatLayerConfiguration(
      event: 'ev_public',
      publicKey: 'pk_test_example',
    );

    final config =
        configuration.initPayload()['config']! as Map<String, Object?>;
    expect(config['event'], 'ev_public');
    expect(config['publicKey'], 'pk_test_example');
    expect(config.containsKey('nativeAccessProvider'), isFalse);
  });

  test('private provider signal accompanies any configured public key', () {
    final configuration = SeatLayerConfiguration(
      event: 'ev_private',
      publicKey: 'pk_test_example',
      buyerAccessTokenProvider: (_) async =>
          const BuyerAccessToken(token: 'bse_private'),
    );

    final config =
        configuration.initPayload()['config']! as Map<String, Object?>;
    expect(config['publicKey'], 'pk_test_example');
    expect(config['nativeAccessProvider'], isTrue);
    expect(configuration.usesPrivateAccess, isTrue);
  });

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

    test('SelectedSeat keeps buyer-facing spatial and accessibility context',
        () {
      final seat = SelectedSeat.fromJson({
        'id': 's1',
        'label': 'GALL-A-45',
        'displayType': 'Row',
        'sectionLabel': 'Gallery',
        'rowLabel': 'GALL-A',
        'seatNumber': '45',
        'wheelchairSpaceType': 'no-seat',
        'accessibility': ['wheelchair'],
        'tiers': [
          {
            'id': 'companion',
            'name': 'Companion',
            'price': 40,
            'restriction': 'companion',
            'buyerMessage': 'Book with the wheelchair place.',
          },
        ],
      })!;

      expect(seat.sectionLabel, 'Gallery');
      expect(seat.rowLabel, 'GALL-A');
      expect(seat.seatNumber, '45');
      expect(seat.wheelchairSpaceType, 'no-seat');
      expect(seat.accessibility, ['wheelchair']);
      expect(seat.tiers!.single.restriction, 'companion');
      expect(
        seat.tiers!.single.buyerMessage,
        'Book with the wheelchair place.',
      );
    });

    test('a seat carries where the runtime drew it, when it says', () {
      final seat = SelectedSeat.fromJson({
        'id': 's1',
        'label': 'A-1',
        'screenPoint': {'x': 120.5, 'y': 44},
      })!;
      expect(seat.screenPoint, const Offset(120.5, 44));
    });

    test('half a screen point is no screen point', () {
      // Absent on every runtime before `seat-screen-point-v1`, and a point
      // with one coordinate would aim native chrome at the map's corner.
      SelectedSeat decode(Object? point) => SelectedSeat.fromJson({
            'id': 's1',
            'label': 'A-1',
            if (point != null) 'screenPoint': point,
          })!;
      expect(decode(null).screenPoint, isNull);
      expect(decode({'x': 12}).screenPoint, isNull);
      expect(decode({'y': 12}).screenPoint, isNull);
      expect(decode({'x': 'left', 'y': 12}).screenPoint, isNull);
      expect(decode(<Object?>[1, 2]).screenPoint, isNull);
      expect(decode('120,44').screenPoint, isNull);
      expect(decode({'x': double.nan, 'y': 12}).screenPoint, isNull);
      expect(decode({'x': double.infinity, 'y': 12}).screenPoint, isNull);
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

  test('private selection configuration matches the mobile bridge contract',
      () {
    final configuration = SeatLayerConfiguration(
      event: 'ev_private',
      buyerAccessToken:
          const BuyerAccessToken(token: 'bse_seed', expiresAt: 123),
      buyerAccessTokenProvider: (context) =>
          BuyerAccessToken(token: 'bse_${context.reason.raw}'),
      selectedObjects: const ['A-1'],
      selectableObjects: const ['A-1', 'A-2'],
      numberOfPlacesToSelect: 2,
      selectionValidators: const [
        MinimumSelectedPlaces(2),
        ConsecutiveSeats(),
      ],
      initialView: SeatLayerViewMode.perspective,
    );
    final config =
        configuration.initPayload()['config']! as Map<String, Object?>;
    expect(config['buyerAccessToken'], {
      'token': 'bse_seed',
      'expiresAt': 123.0,
    });
    expect(config['nativeAccessProvider'], isTrue);
    expect(config['selectedObjects'], ['A-1']);
    expect(config['numberOfPlacesToSelect'], 2);
    expect(config['selectionValidators'], [
      {'type': 'minimumSelectedPlaces', 'minimum': 2},
      {'type': 'consecutiveSeats'},
    ]);
    expect(config['initialView'], 'perspective');
    expect(configuration.usesPrivateAccess, isTrue);
    expect(configuration.usesSelectionPolicy, isTrue);
  });

  test('selection and access event decoders preserve unknown values', () {
    final validity = SelectionValidity.fromJson({
      'isValid': false,
      'count': 1,
      'required': 2,
      'remaining': 1,
      'seats': [
        {'id': 's1', 'label': 'A-1'},
      ],
      'violations': ['futureRule'],
    })!;
    expect(validity.seats.single.label, 'A-1');
    expect(validity.violations.single.raw, 'futureRule');

    final access = BuyerAccessUnavailableEvent.fromJson({
      'reason': 'future_access_state',
      'retryable': false,
    })!;
    expect(access.reason.raw, 'future_access_state');
  });
}
