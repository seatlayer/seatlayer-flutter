import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';
import 'package:seatlayer/src/seat_layer_error.dart';

import 'picker_test_fixture.dart';

final class _CommandCall {
  const _CommandCall(this.name, this.payload);

  final String name;
  final Object? payload;
}

final class _FakeMapController extends SeatLayerController {
  _FakeMapController(this.handler, {this.ready = false});

  final Future<Object?> Function(String command, Object? payload) handler;
  final bool ready;
  final events = StreamController<EventSignal>.broadcast();
  final calls = <_CommandCall>[];

  @override
  bool get isReady => ready;

  @override
  Stream<EventSignal> get onBridgeEvent => events.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) {
    calls.add(_CommandCall(command, payload));
    return handler(command, payload);
  }

  void emitSnapshot(Map<String, Object?> snapshot, {int sequence = 1}) {
    events.add(
      EventSignal(
        name: 'picker.snapshot',
        payload: <String, Object?>{'snapshot': snapshot},
        sequence: sequence,
      ),
    );
  }

  void emitReadySnapshot(Map<String, Object?> snapshot, {int sequence = 1}) {
    events.add(
      EventSignal(
        name: 'sys.ready',
        payload: <String, Object?>{'snapshot': snapshot},
        sequence: sequence,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(events.close());
    super.dispose();
  }
}

SeatLayerPickerController _picker(
  _FakeMapController map, {
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
}) {
  final picker = SeatLayerPickerController(mapController: map);
  picker.attach(
    configuration: SeatLayerConfiguration(event: 'ev_test'),
    options: options,
  );
  return picker;
}

Future<void> _deliver(
  _FakeMapController map,
  Map<String, Object?> snapshot, {
  int sequence = 1,
}) async {
  map.emitSnapshot(snapshot, sequence: sequence);
  await pumpEventQueue();
}

void main() {
  test('retry destroys a ready picker before replacing its runtime', () async {
    final map = _FakeMapController((command, _) async {
      expect(command, 'picker.destroy');
      return <String, Object?>{'destroyed': true};
    }, ready: true);
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());

    await picker.retry();

    expect(map.calls.map((call) => call.name), <String>['picker.destroy']);
    expect(picker.reloadGeneration, 1);
    expect(picker.state.phase, SeatLayerPickerPhase.initializing);
  });

  test('retry after a failed handshake does not send destroy', () async {
    final map = _FakeMapController((command, _) async {
      fail('unexpected command $command');
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });

    await picker.retry();

    expect(map.calls, isEmpty);
    expect(picker.reloadGeneration, 1);
  });

  test('sys.ready keeps applying its embedded initial snapshot', () async {
    final map = _FakeMapController((_, __) async => null);
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });

    map.emitReadySnapshot(pickerSnapshot());
    await pumpEventQueue();

    expect(picker.state.sessionId, 'session-1');
    expect(picker.state.revision, 1);
    expect(picker.state.selection.single.id, 'seat-a-1');
  });

  test('wrapped snapshot event updates state without fallback polling',
      () async {
    final map = _FakeMapController((command, _) async {
      if (command == 'picker.setCategoryFilter') {
        return <String, Object?>{'revision': 2};
      }
      fail('unexpected fallback command $command');
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());

    final action = picker.setCategoryFilter(<String>{'standard'});
    await pumpEventQueue();
    await _deliver(map, pickerSnapshot(revision: 2), sequence: 2);
    await action;

    expect(picker.state.revision, 2);
    expect(
      map.calls.map((call) => call.name),
      <String>['picker.setCategoryFilter'],
    );
  });

  test('empty category filter clears the runtime filter with null', () async {
    final map = _FakeMapController((command, payload) async {
      expect(command, 'picker.setCategoryFilter');
      expect(payload, <String, Object?>{'categoryKeys': null});
      return <String, Object?>{
        'revision': 2,
        'snapshot': pickerSnapshot(revision: 2),
      };
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());

    await picker.setCategoryFilter(<String>{});

    expect(map.calls, hasLength(1));
  });

  test('read-only picker rejects selection and hold commands locally',
      () async {
    final map = _FakeMapController((command, _) async {
      fail('read-only action reached the runtime: $command');
    });
    final picker = _picker(
      map,
      options: const SeatLayerPickerOptions(readOnly: true),
    );
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());

    final actions = <Future<Object?> Function()>[
      picker.clearSelection,
      () => picker.removeObject('A-1'),
      () => picker.setSeatTier('seat-a-1', 'adult'),
      () => picker.selectObjects(<String>['A-1']),
      () => picker.deselectObjects(<String>['A-1']),
      () => picker.selectCategories(<String>['standard']),
      () => picker.deselectCategories(<String>['standard']),
      () => picker.setSelectableObjects(<String>['A-1']),
      () => picker.setMaxSelection(4),
      () => picker.bestAvailable(quantity: 2),
      () => picker.setGeneralAdmissionQuantity(
            areaId: 'ga-1',
            quantitiesByTier: const <String?, int>{null: 1},
          ),
      () => picker.setTableQuantity(label: 'T-1', quantity: 2),
      () => picker.resumeHold('hold-1'),
      picker.extendHold,
      picker.checkout,
    ];

    for (final action in actions) {
      await expectLater(
        action(),
        throwsA(
          isA<SeatLayerError>().having(
            (error) => error.code,
            'code',
            'read_only',
          ),
        ),
      );
    }
    expect(map.calls, isEmpty);
  });

  test('custom component actions use the picker-v2 command payloads', () async {
    var revision = 1;
    final map = _FakeMapController((command, _) async {
      if (command == 'picker.destroy') {
        return <String, Object?>{'destroyed': true};
      }
      revision += 1;
      return <String, Object?>{
        'revision': revision,
        'snapshot': pickerSnapshot(revision: revision),
      };
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());

    await picker.selectObjects(<String>['A-1']);
    await picker.deselectObjects(<String>['A-1']);
    await picker.selectCategories(<String>['vip']);
    await picker.deselectCategories(<String>['vip']);
    await picker.setSelectableObjects(null);
    await picker.setMaxSelection(6);
    await picker.resumeHold('hold-restored');
    await picker.destroy();

    expect(
      map.calls.map((call) => call.name),
      <String>[
        'picker.selectObjects',
        'picker.deselectObjects',
        'picker.selectCategories',
        'picker.deselectCategories',
        'picker.setSelectableObjects',
        'picker.setMaxSelection',
        'picker.resumeHold',
        'picker.destroy',
      ],
    );
    expect(map.calls[0].payload, <String, Object?>{
      'objects': <String>['A-1'],
    });
    expect(map.calls[1].payload, <String, Object?>{
      'objects': <String>['A-1'],
    });
    expect(map.calls[2].payload, <String, Object?>{
      'categoryKeys': <String>['vip'],
    });
    expect(map.calls[3].payload, <String, Object?>{
      'categoryKeys': <String>['vip'],
    });
    expect(map.calls[4].payload, <String, Object?>{'objects': null});
    expect(map.calls[5].payload, <String, Object?>{'maxSelection': 6});
    expect(
      map.calls[6].payload,
      <String, Object?>{'holdId': 'hold-restored'},
    );
    expect(map.calls[7].payload, isNull);
    expect(picker.state.phase, SeatLayerPickerPhase.closed);
  });

  test('immersive actions use real venue and seat-view commands', () async {
    var revision = 1;
    final map = _FakeMapController((_, __) async {
      revision += 1;
      return <String, Object?>{
        'revision': revision,
        'snapshot': pickerSnapshot(revision: revision),
      };
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());
    final seat = picker.state.selection.single;

    await picker.showSeatIn3D(seat);
    await picker.openSeatView(seat);
    await picker.set3DNavigationMode(SeatLayer3DNavigationMode.move);
    await picker.setBuyerView(SeatLayerBuyerView.map);

    expect(
      map.calls.map((call) => call.name),
      <String>[
        'picker.setBuyerView',
        'picker.openSeatView',
        'picker.setVenue3DNavigationMode',
        'picker.setBuyerView',
      ],
    );
    expect(map.calls[0].payload, <String, Object?>{
      'view': 'venue3d',
      'flyToSeatId': 'seat-a-1',
    });
    expect(map.calls[1].payload, <String, Object?>{'seatId': 'seat-a-1'});
    expect(map.calls[2].payload, <String, Object?>{'mode': 'pan'});
    expect(map.calls[3].payload, <String, Object?>{'view': 'map'});
  });

  test('handoff rejection remains allowed in read-only mode', () async {
    final map = _FakeMapController((command, payload) async {
      expect(command, 'picker.rejectHandoff');
      expect(payload, <String, Object?>{'holdId': 'hold-1'});
      return <String, Object?>{
        'revision': 2,
        'snapshot': pickerSnapshot(revision: 2, withSelection: false),
      };
    });
    final picker = _picker(
      map,
      options: const SeatLayerPickerOptions(readOnly: true),
    );
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot(holdOwner: 'host'));
    final handoff = SeatLayerCheckoutHandoff.fromJson(checkoutHandoff())!;

    await picker.rejectCheckoutHandoff(handoff);

    expect(map.calls, hasLength(1));
    expect(picker.state.hold, isNull);
  });

  test('same-session stale revisions never regress native state', () async {
    final map = _FakeMapController((_, __) async => null);
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });

    await _deliver(map, pickerSnapshot(revision: 3));
    await _deliver(
      map,
      pickerSnapshot(revision: 2, withSelection: false),
      sequence: 2,
    );

    expect(picker.state.revision, 3);
    expect(picker.state.selection.single.id, 'seat-a-1');
  });

  test('a new runtime session may restart its revision counter', () async {
    final map = _FakeMapController((_, __) async => null);
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });

    await _deliver(map, pickerSnapshot(revision: 9));
    await _deliver(
      map,
      pickerSnapshot(
        revision: 1,
        sessionId: 'session-2',
        withSelection: false,
      ),
      sequence: 2,
    );

    expect(picker.state.sessionId, 'session-2');
    expect(picker.state.revision, 1);
    expect(picker.state.selection, isEmpty);
  });

  test('double checkout shares one command and hands hold ownership to host',
      () async {
    final gate = Completer<void>();
    final map = _FakeMapController((command, _) async {
      expect(command, 'picker.continue');
      await gate.future;
      return <String, Object?>{
        'revision': 2,
        'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
        'handoff': checkoutHandoff(),
      };
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot());

    final first = picker.checkout();
    final second = picker.checkout();
    expect(identical(first, second), isTrue);
    gate.complete();

    final results = await Future.wait(<Future<SeatLayerCheckoutHandoff>>[
      first,
      second,
    ]);
    expect(map.calls.where((call) => call.name == 'picker.continue'),
        hasLength(1));
    expect(results.first.holdId, 'hold-1');
    expect(picker.state.checkoutHandoff?.holdId, 'hold-1');
    expect(picker.state.holdOwner, SeatLayerHoldOwner.host);
  });

  test('closing releases a picker-owned hold exactly once', () async {
    final map = _FakeMapController((command, _) async {
      expect(command, 'picker.abort');
      return <String, Object?>{
        'revision': 2,
        'snapshot': pickerSnapshot(revision: 2, withSelection: false),
      };
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot(holdOwner: 'picker'));

    final first = picker.close();
    final second = picker.close();
    expect(identical(first, second), isTrue);
    await Future.wait(<Future<void>>[first, second]);

    expect(
        map.calls.where((call) => call.name == 'picker.abort'), hasLength(1));
    expect(picker.state.phase, SeatLayerPickerPhase.closed);
  });

  test('closing never releases a host-owned hold', () async {
    final map = _FakeMapController((command, _) async {
      fail('unexpected command $command');
    });
    final picker = _picker(map);
    addTearDown(() {
      picker.dispose();
      map.dispose();
    });
    await _deliver(map, pickerSnapshot(holdOwner: 'host'));

    await picker.close();

    expect(map.calls, isEmpty);
    expect(picker.state.hold?.active, isTrue);
    expect(picker.state.phase, SeatLayerPickerPhase.closed);
  });
}
