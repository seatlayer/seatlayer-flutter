// The shared session must carry a page that is not the event's: the Season
// and the run will stand on it. Nothing here may need an event key.
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/bridge/bridge_session.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/seat_layer_surface_configuration.dart';

final class _Channel implements BridgeChannel {
  final sent = <Envelope>[];

  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);
}

final class _OtherConfiguration implements SeatLayerSurfaceConfiguration {
  _OtherConfiguration({this.buyerAccessTokenProvider});

  @override
  String get assetPath => 'other.html';

  @override
  Duration get commandTimeout => const Duration(seconds: 5);

  @override
  Duration get handshakeTimeout => const Duration(seconds: 5);

  @override
  final BuyerAccessTokenProvider? buyerAccessTokenProvider;

  @override
  Map<String, Object?> initPayload({required ProtocolRange protocolRange}) =>
      <String, Object?>{
        'protocol': protocolRange.toJson(),
        'config': <String, Object?>{'season': 'ss_test'},
      };

  @override
  bool semanticallyEquals(_OtherConfiguration other) => true;
}

final class _OtherSession extends SeatLayerBridgeSession<_OtherConfiguration> {
  final surfaceEvents = <String>[];

  @override
  void handleSurfaceEvent(String name, Object? payload) =>
      surfaceEvents.add(name);
}

String _frame(EnvelopeKind kind, String type, Object? payload, {int? n}) =>
    Envelope(kind: kind, type: type, sequence: n, payload: payload).encode();

void main() {
  test('a page other than the event boots on the shared session', () async {
    final session = _OtherSession();
    addTearDown(session.dispose);
    final channel = _Channel();
    final requests = <BuyerAccessRefreshReason>[];
    final ready = session.beginHandshake(
      channel,
      _OtherConfiguration(
        buyerAccessTokenProvider: (context) {
          requests.add(context.reason);
          return const BuyerAccessToken(token: 'tok_test');
        },
      ),
    );

    session.ingestRaw(
      _frame(EnvelopeKind.hello, 'hello', <String, Object?>{
        'bundle': '1.0.0-test',
        'protocol': <String, Object?>{'min': 1, 'max': 1},
        'events': <String>['sys.ready'],
        'commands': <String>[],
      }),
    );
    await pumpEventQueue();

    // Its init is its own configuration's, nothing of the event's.
    final init = channel.sent.single;
    expect(init.kind, EnvelopeKind.init);
    expect(init.payload, <String, Object?>{
      'protocol': <String, Object?>{'min': 1, 'max': 1},
      'config': <String, Object?>{'season': 'ss_test'},
    });

    session.ingestRaw(
      _frame(
        EnvelopeKind.evt,
        'sys.ready',
        <String, Object?>{'protocol': 1, 'transport': 'flutter'},
        n: 1,
      ),
    );
    expect((await ready).protocolRevision, 1);
    expect(session.isReady, isTrue);

    // Its own events reach it; access requests are the session's.
    session.ingestRaw(
      _frame(EnvelopeKind.evt, 'other.status', const <String, Object?>{},
          n: 2),
    );
    session.ingestRaw(
      _frame(
        EnvelopeKind.evt,
        'access.token.request',
        <String, Object?>{'requestId': 'r1', 'reason': 'expired'},
        n: 3,
      ),
    );
    await pumpEventQueue();

    expect(session.surfaceEvents, <String>['other.status']);
    expect(requests, <BuyerAccessRefreshReason>[BuyerAccessRefreshReason.expired]);
    final provide = channel.sent.last;
    expect(provide.kind, EnvelopeKind.cmd);
    expect(provide.type, 'access.token.provide');
    expect(
      provide.payload,
      <String, Object?>{'requestId': 'r1', 'token': 'tok_test'},
    );
  });
}
