import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';

import 'picker_test_fixture.dart';

final class _CommandCall {
  const _CommandCall(this.name, this.payload);

  final String name;
  final Object? payload;
}

final class _FakeMapController extends SeatLayerController {
  _FakeMapController(this.handler);

  final Future<Object?> Function(String command, Object? payload) handler;
  final events = StreamController<EventSignal>.broadcast();
  final calls = <_CommandCall>[];

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
        payload: snapshot,
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

SeatLayerPickerController _picker(_FakeMapController map) {
  final picker = SeatLayerPickerController(mapController: map);
  picker.attach(
    configuration: SeatLayerConfiguration(event: 'ev_test'),
    options: const SeatLayerPickerOptions(),
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
