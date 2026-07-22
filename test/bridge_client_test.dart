import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer_flutter/src/bridge/bridge_client.dart';
import 'package:seatlayer_flutter/src/bridge/envelope.dart';
import 'package:seatlayer_flutter/src/seat_layer_error.dart';

class _FakeChannel implements BridgeChannel {
  final List<Envelope> sent = [];
  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);
}

Envelope _res(String id, String t, [Object? p]) =>
    Envelope(kind: EnvelopeKind.res, type: t, id: id, payload: p);
Envelope _err(String id, String t, Object p) =>
    Envelope(kind: EnvelopeKind.err, type: t, id: id, payload: p);
Envelope _evt(String t, int n, [Object? p]) =>
    Envelope(kind: EnvelopeKind.evt, type: t, sequence: n, payload: p);

void main() {
  group('BridgeClient — correlation', () {
    test('a cmd resolves with its correlated res payload', () async {
      final channel = _FakeChannel();
      final client = BridgeClient(channel: channel);

      final future = client.command('hold', payload: {'ttlMs': 5000});
      expect(channel.sent, hasLength(1));
      final sent = channel.sent.single;
      expect(sent.kind, EnvelopeKind.cmd);
      expect(sent.type, 'hold');
      expect(sent.id, 'n1');

      client.ingest(_res('n1', 'hold', {'hold': {'holdId': 'h1'}}));
      final result = await future;
      expect((result! as Map)['hold'], {'holdId': 'h1'});
      expect(client.openCommandCount, 0);
    });

    test('concurrent commands are correlated independently by id', () async {
      final channel = _FakeChannel();
      final client = BridgeClient(channel: channel);

      final slow = client.command('getSelection');
      final fast = client.command('getFloors');
      expect(channel.sent.map((e) => e.id), ['n1', 'n2']);

      // Reply to the second first.
      client.ingest(_res('n2', 'getFloors', {'floors': []}));
      expect(await fast, {'floors': <Object?>[]});

      client.ingest(_res('n1', 'getSelection', {'seats': []}));
      expect(await slow, {'seats': <Object?>[]});
    });

    test('an err reply throws a typed BridgeFailure with the API code intact', () async {
      final client = BridgeClient(channel: _FakeChannel());
      final future = client.command('hold');
      client.ingest(_err('n1', 'hold', {'code': 'sold_out', 'message': 'gone', 'details': {'conflicts': [{'label': 'A-1', 'status': 'booked'}]}}));

      await expectLater(
        future,
        throwsA(isA<BridgeFailure>()
            .having((e) => e.code, 'code', 'sold_out')
            .having((e) => e.conflicts!.single.label, 'conflict label', 'A-1')),
      );
    });

    test('a reply for an unknown id is dropped, not delivered', () async {
      final client = BridgeClient(channel: _FakeChannel());
      final future = client.command('hold');
      // Wrong id — must not resolve the pending command.
      client.ingest(_res('n99', 'hold', {}));
      expect(client.openCommandCount, 1);
      // Correct id resolves it.
      client.ingest(_res('n1', 'hold', {}));
      await future;
      expect(client.openCommandCount, 0);
    });
  });

  group('BridgeClient — 15s timeout', () {
    test('the default deadline is 15 seconds', () {
      expect(BridgeClient.defaultTimeout, const Duration(seconds: 15));
    });

    test('a command with no reply fails with a typed timeout after 15s', () {
      fakeAsync((async) {
        final client = BridgeClient(channel: _FakeChannel());
        Object? caught;
        client.command('hold').catchError((Object e) {
          caught = e;
          return null;
        });

        async.elapse(const Duration(seconds: 14));
        expect(caught, isNull);
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(caught, isA<TimeoutFailure>());
        expect((caught! as TimeoutFailure).command, 'hold');
        expect((caught! as SeatLayerError).code, 'sl_timeout');
        expect(client.openCommandCount, 0);
      });
    });

    test('a LATE reply for a timed-out command is dropped', () {
      fakeAsync((async) {
        final client = BridgeClient(channel: _FakeChannel());
        var completions = 0;
        client.command('hold').then(
          (_) => completions++,
          onError: (_) => completions++,
        );
        async.elapse(const Duration(seconds: 16));
        async.flushMicrotasks();
        expect(completions, 1); // the timeout

        // A reply arriving after the timeout must not fire a second completion.
        client.ingest(_res('n1', 'hold', {}));
        async.flushMicrotasks();
        expect(completions, 1);
      });
    });
  });

  group('BridgeClient — event sequencing', () {
    test('drops a stale event whose n is not greater than the last applied', () {
      final client = BridgeClient(channel: _FakeChannel());
      final received = <int>[];
      client.onSignal((s) {
        if (s is EventSignal) received.add(s.sequence);
      });

      client.ingest(_evt('selection.changed', 5));
      client.ingest(_evt('selection.changed', 3)); // stale
      client.ingest(_evt('selection.changed', 5)); // equal → stale
      client.ingest(_evt('selection.changed', 6)); // fresh

      expect(received, [5, 6]);
      expect(client.highestSequenceFor('selection.changed'), 6);
    });

    test('sequence watermarks are per event type', () {
      final client = BridgeClient(channel: _FakeChannel());
      final byType = <String, List<int>>{};
      client.onSignal((s) {
        if (s is EventSignal) (byType[s.name] ??= []).add(s.sequence);
      });

      client.ingest(_evt('hold.changed', 10));
      client.ingest(_evt('seat.hover', 2)); // lower n, different type → fresh
      client.ingest(_evt('seat.hover', 3));

      expect(byType['hold.changed'], [10]);
      expect(byType['seat.hover'], [2, 3]);
    });

    test('a hello frame is surfaced as a HelloSignal', () {
      final client = BridgeClient(channel: _FakeChannel());
      BridgeSignal? got;
      client.onSignal((s) => got = s);
      client.ingest(const Envelope(kind: EnvelopeKind.hello, type: 'hello', payload: {'bundle': '0.26.0'}));
      expect(got, isA<HelloSignal>());
      expect(((got! as HelloSignal).payload! as Map)['bundle'], '0.26.0');
    });

    test('an unknown-kind frame is surfaced as UnhandledSignal, not dropped', () {
      final client = BridgeClient(channel: _FakeChannel());
      BridgeSignal? got;
      client.onSignal((s) => got = s);
      client.ingest(Envelope(kind: EnvelopeKind.fromRaw('brandnew'), type: 'x'));
      expect(got, isA<UnhandledSignal>());
    });
  });

  group('BridgeClient — out-of-band command error (the iOS fix)', () {
    test('an `error` event in flight fails the most recent failable command', () async {
      final client = BridgeClient(channel: _FakeChannel());
      final future = client.command('bestAvailable', payload: {'qty': 4});

      // The bundle reports the failure out of band as an `error` event…
      client.ingest(_evt('error', 1, {'code': 'not_enough_together', 'message': 'nope'}));
      // …immediately followed by the trailing res { hold: null }.
      client.ingest(_res('n1', 'bestAvailable', {'hold': null}));

      await expectLater(
        future,
        throwsA(isA<BridgeFailure>().having((e) => e.code, 'code', 'not_enough_together')),
      );
      expect(client.openCommandCount, 0); // trailing res was dropped
    });

    test('an `error` event with no failable command in flight is a normal event', () {
      final client = BridgeClient(channel: _FakeChannel());
      final events = <String>[];
      client.onSignal((s) {
        if (s is EventSignal) events.add(s.name);
      });
      // getSelection is NOT in the failable set — an error is genuinely OOB.
      client.command('getSelection');
      client.ingest(_evt('error', 1, {'code': 'socket_error', 'message': 'ws down'}));
      expect(events, ['error']);
    });
  });

  group('BridgeClient — teardown', () {
    test('close fails every open command and rejects further commands', () async {
      final client = BridgeClient(channel: _FakeChannel());
      final future = client.command('hold');
      client.close();
      await expectLater(future, throwsA(isA<DestroyedFailure>()));
      await expectLater(client.command('zoomIn'), throwsA(isA<DestroyedFailure>()));
      expect(client.isClosed, isTrue);
    });

    test('close is idempotent', () {
      final client = BridgeClient(channel: _FakeChannel());
      client.close();
      expect(client.close, returnsNormally);
    });

    test('a command with no channel attached fails with a transport error', () async {
      final client = BridgeClient();
      await expectLater(client.command('hold'), throwsA(isA<TransportFailure>()));
    });
  });
}
