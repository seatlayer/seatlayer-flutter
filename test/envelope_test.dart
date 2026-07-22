import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer_flutter/src/bridge/envelope.dart';

void main() {
  group('Envelope.decode — well-formed frames', () {
    test('decodes a JSON string frame', () {
      final env = Envelope.decode('{"sl":1,"k":"evt","t":"sys.ready","n":3,"p":{"mode":"live"}}');
      expect(env, isNotNull);
      expect(env!.kind, EnvelopeKind.evt);
      expect(env.type, 'sys.ready');
      expect(env.sequence, 3);
      expect((env.payload! as Map)['mode'], 'live');
    });

    test('decodes an already-structured object frame', () {
      final env = Envelope.decode({'sl': 1, 'k': 'res', 't': 'hold', 'id': 'n1', 'p': {}});
      expect(env!.kind, EnvelopeKind.res);
      expect(env.id, 'n1');
    });

    test('accepts an integral double as the sequence (JS has one number type)', () {
      final env = Envelope.decode('{"sl":1,"k":"evt","t":"hint","n":7.0}');
      expect(env!.sequence, 7);
    });
  });

  group('Envelope.decode — unknown tolerance (the critical requirement)', () {
    test('an unknown kind decodes to EnvelopeKindUnknown, never null', () {
      final env = Envelope.decode('{"sl":1,"k":"telepathy","t":"x"}');
      expect(env, isNotNull);
      expect(env!.kind, isA<EnvelopeKindUnknown>());
      expect((env.kind as EnvelopeKindUnknown).raw, 'telepathy');
    });

    test('an unknown event type `t` is accepted (any non-empty string is valid)', () {
      final env = Envelope.decode('{"sl":1,"k":"evt","t":"future.event","n":1}');
      expect(env, isNotNull);
      expect(env!.type, 'future.event');
    });

    test('unknown payload fields are carried through untouched', () {
      final env = Envelope.decode('{"sl":1,"k":"evt","t":"hint","n":1,"p":{"message":"hi","brandNew":42}}');
      final p = env!.payload! as Map;
      expect(p['message'], 'hi');
      expect(p['brandNew'], 42);
    });
  });

  group('Envelope.decode — rejects malformed frames', () {
    test('wrong envelope marker → null', () {
      expect(Envelope.decode('{"sl":2,"k":"evt","t":"x"}'), isNull);
    });
    test('missing type → null', () {
      expect(Envelope.decode('{"sl":1,"k":"evt"}'), isNull);
    });
    test('empty type → null', () {
      expect(Envelope.decode('{"sl":1,"k":"evt","t":""}'), isNull);
    });
    test('non-string id → null', () {
      expect(Envelope.decode('{"sl":1,"k":"cmd","t":"hold","id":7}'), isNull);
    });
    test('non-integral sequence → null', () {
      expect(Envelope.decode('{"sl":1,"k":"evt","t":"x","n":1.5}'), isNull);
    });
    test('not JSON → null', () {
      expect(Envelope.decode('not json at all'), isNull);
    });
    test('a JSON array is not an envelope → null', () {
      expect(Envelope.decode('[1,2,3]'), isNull);
    });
    test('missing kind → null', () {
      expect(Envelope.decode('{"sl":1,"t":"x"}'), isNull);
    });
  });

  group('Envelope.encode', () {
    test('round-trips and omits absent optional fields', () {
      const env = Envelope(kind: EnvelopeKind.cmd, type: 'hold', id: 'n1');
      final json = jsonDecode(env.encode()) as Map<String, Object?>;
      expect(json, {'sl': 1, 'k': 'cmd', 't': 'hold', 'id': 'n1'});
      expect(json.containsKey('n'), isFalse);
      expect(json.containsKey('p'), isFalse);
    });

    test('an init envelope encodes k=init', () {
      const env = Envelope(kind: EnvelopeKind.init, type: 'init', payload: {'protocol': {'min': 1, 'max': 1}});
      final json = jsonDecode(env.encode()) as Map<String, Object?>;
      expect(json['k'], 'init');
      expect(json['t'], 'init');
    });

    test('an evt envelope carries its sequence as `n`', () {
      const env = Envelope(kind: EnvelopeKind.evt, type: 'hint', sequence: 5, payload: {});
      final json = jsonDecode(env.encode()) as Map<String, Object?>;
      expect(json['n'], 5);
    });
  });

  group('EnvelopeKind', () {
    test('known raws map to the const singletons', () {
      expect(EnvelopeKind.fromRaw('hello'), same(EnvelopeKind.hello));
      expect(EnvelopeKind.fromRaw('init'), same(EnvelopeKind.init));
      expect(EnvelopeKind.fromRaw('evt'), same(EnvelopeKind.evt));
    });
    test('unknown raw is preserved', () {
      final k = EnvelopeKind.fromRaw('xyz');
      expect(k, const EnvelopeKindUnknown('xyz'));
      expect(k.raw, 'xyz');
    });
  });
}
