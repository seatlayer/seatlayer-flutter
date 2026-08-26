import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';
import 'package:seatlayer/src/seat_layer_error.dart';

final class _Channel implements BridgeChannel {
  final sent = <Envelope>[];

  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);
}

Map<String, Object?> _hello({bool removeTableCapability = false}) =>
    <String, Object?>{
      'bundle': '0.68.0-test',
      'protocol': <String, Object?>{'min': 1, 'max': 2},
      'capabilities': <String>[
        'picker-session-v2',
        'picker-snapshot-v1',
        'picker-actions-v1',
        'native-picker-chrome-v1',
        'checkout-handoff-v1',
        'checkout-handoff-reject-v1',
        'hold-ownership-v1',
        'cart-line-remove-v1',
        if (!removeTableCapability) 'table-quantity-v1',
        'venue-3d-v1',
        'venue-3d-controls-v1',
        'seat-view-v1',
      ],
      'events': <String>['sys.ready', 'picker.snapshot'],
      'commands': <String>['picker.getSnapshot'],
    };

void main() {
  test('restored holds are configured without caller-controlled ownership', () {
    final config = const SeatLayerPickerOptions(
      initialHoldId: 'hold-restored',
    ).toBridgeConfig();

    expect(config, containsPair('initialHoldId', 'hold-restored'));
    expect(config, isNot(contains('initialHoldOwner')));
  });

  test('raw chart remains a protocol-v1 integration', () {
    final payload = SeatLayerBridgeProfile.chart.initPayload(
      SeatLayerConfiguration(event: 'ev_raw'),
    );

    expect(payload['protocol'], <String, Object?>{'min': 1, 'max': 1});
    expect(payload, isNot(contains('surface')));
    expect(payload, isNot(contains('requirements')));
  });

  test('turnkey picker requests v2 state/actions and native-owned chrome', () {
    final profile = SeatLayerBridgeProfile.picker(
      config: const <String, Object?>{'holdTtlMs': 300000},
    );
    final payload = profile.initPayload(
      SeatLayerConfiguration(event: 'ev_picker'),
    );

    expect(payload['protocol'], <String, Object?>{'min': 2, 'max': 2});
    expect(payload['surface'], <String, Object?>{
      'kind': 'picker',
      'stateContract': 1,
      'chromeOwner': 'native',
    });
    expect(
      payload['requirements'],
      <String, Object?>{'capabilities': profile.requiredCapabilities},
    );
    expect(
      payload['chrome'],
      containsPair('testModeIndicator', false),
    );
    expect(
      payload['config'],
      containsPair('holdTtlMs', 300000),
    );
    expect(
      profile.requiredCapabilities,
      contains('checkout-handoff-reject-v1'),
    );
    expect(
      profile.requiredCapabilities,
      containsAll(<String>[
        'venue-3d-v1',
        'venue-3d-controls-v1',
        'seat-view-v1',
      ]),
    );
  });

  test('picker handshake sends init only after every required capability',
      () async {
    final channel = _Channel();
    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    final ready = controller.beginHandshake(
      channel,
      SeatLayerConfiguration(event: 'ev_picker'),
      profile: SeatLayerBridgeProfile.picker(),
    );

    controller.ingestRaw(
      Envelope(
        kind: EnvelopeKind.hello,
        type: 'hello',
        payload: _hello(),
      ).encode(),
    );
    await pumpEventQueue();

    expect(channel.sent, hasLength(1));
    expect(channel.sent.single.kind, EnvelopeKind.init);
    expect(channel.sent.single.payload, containsPair('surface', isNotNull));

    controller.ingestRaw(
      const Envelope(
        kind: EnvelopeKind.evt,
        type: 'sys.ready',
        sequence: 1,
        payload: <String, Object?>{
          'protocol': 2,
          'mode': 'test',
          'transport': 'flutter',
          'chart': <String, Object?>{'event': 'ev_picker'},
        },
      ).encode(),
    );
    expect((await ready).protocolRevision, 2);
  });

  test('missing component capability fails closed before init', () async {
    final channel = _Channel();
    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    final ready = controller.beginHandshake(
      channel,
      SeatLayerConfiguration(event: 'ev_picker'),
      profile: SeatLayerBridgeProfile.picker(),
    );

    controller.ingestRaw(
      Envelope(
        kind: EnvelopeKind.hello,
        type: 'hello',
        payload: _hello(removeTableCapability: true),
      ).encode(),
    );

    await expectLater(
      ready,
      throwsA(
        isA<SeatLayerError>().having(
          (error) => error.message,
          'message',
          contains('table-quantity-v1'),
        ),
      ),
    );
    expect(channel.sent, isEmpty);
  });
}
