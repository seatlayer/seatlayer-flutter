import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';

final class _Channel implements BridgeChannel {
  final sent = <Envelope>[];

  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);
}

Map<String, Object?> _hello() => <String, Object?>{
      'bundle': '0.68.1-test',
      'protocol': <String, Object?>{'min': 1, 'max': 1},
      'events': <String>['sys.ready'],
      'commands': <String>[],
    };

void main() {
  test('a live handshake reports how long the cold start took', () async {
    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    final ready = controller.beginHandshake(
      _Channel(),
      SeatLayerConfiguration(event: 'ev_test'),
    );

    controller.ingestRaw(
      Envelope(
        kind: EnvelopeKind.hello,
        type: 'hello',
        payload: _hello(),
      ).encode(),
    );
    await pumpEventQueue();

    controller.ingestRaw(
      const Envelope(
        kind: EnvelopeKind.evt,
        type: 'sys.ready',
        sequence: 1,
        payload: <String, Object?>{
          'protocol': 1,
          'mode': 'test',
          'transport': 'flutter',
          'chart': <String, Object?>{'event': 'ev_test'},
        },
      ).encode(),
    );

    // The whole cold path — WebView creation, page fetch, bundle parse,
    // handshake and first render — measured at the one place both halves are
    // visible. Nothing is logged with it; reporting it is the host's call.
    final info = await ready;
    expect(info.timeToHelloMs, isNotNull);
    expect(info.timeToHelloMs, greaterThanOrEqualTo(0));
    expect(info.timeToReadyMs, isNotNull);
    expect(info.timeToReadyMs, greaterThanOrEqualTo(0));
    expect(info.timeToReadyMs, greaterThanOrEqualTo(info.timeToHelloMs!));
    expect(controller.readyInfo!.timeToHelloMs, info.timeToHelloMs);
    expect(controller.readyInfo!.timeToReadyMs, info.timeToReadyMs);
  });

  test('a ReadyInfo not produced by a handshake carries no timing', () {
    const info = ReadyInfo(
      protocolRevision: 2,
      mode: EventMode.live,
      transport: TransportName.flutter,
    );
    expect(info.timeToHelloMs, isNull);
    expect(info.timeToReadyMs, isNull);
  });
}
