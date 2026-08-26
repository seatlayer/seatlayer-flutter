import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';

void main() {
  group('negotiate — range intersection, both directions', () {
    test('old app + new bundle: agree on the lowest shared revision', () {
      // native pins 1..1 (this SDK); bundle can speak 1..3 → agreed 1.
      final result = negotiate(
        native: const ProtocolRange(min: 1, max: 1),
        web: const ProtocolRange(min: 1, max: 3),
      );
      expect(result, isA<NegotiationAgreed>());
      expect((result as NegotiationAgreed).protocol, 1);
    });

    test('new app + old bundle: no overlap → incompatible', () {
      // native wants 2..4; bundle only speaks 1..1 → agreed 1 < nativeMin 2.
      final result = negotiate(
        native: const ProtocolRange(min: 2, max: 4),
        web: const ProtocolRange(min: 1, max: 1),
      );
      expect(result, isA<NegotiationIncompatible>());
    });

    test('overlapping ranges agree on the highest shared revision', () {
      final result = negotiate(
        native: const ProtocolRange(min: 1, max: 3),
        web: const ProtocolRange(min: 2, max: 5),
      );
      expect((result as NegotiationAgreed).protocol, 3);
    });

    test('disjoint ranges (bundle ahead) → incompatible', () {
      final result = negotiate(
        native: const ProtocolRange(min: 1, max: 1),
        web: const ProtocolRange(min: 2, max: 4),
      );
      expect(result, isA<NegotiationIncompatible>());
      expect((result as NegotiationIncompatible).reason,
          contains('no shared protocol'));
    });

    test('default native range covers raw v1 and picker v2', () {
      final result = negotiate(web: const ProtocolRange(min: 1, max: 9));
      expect((result as NegotiationAgreed).protocol, 2);
    });
  });

  group('ProtocolRange.from', () {
    test('a bare number normalises to a single-revision range', () {
      expect(ProtocolRange.from(2), const ProtocolRange(min: 2, max: 2));
    });
    test('a {min,max} object normalises directly', () {
      expect(ProtocolRange.from({'min': 1, 'max': 4}),
          const ProtocolRange(min: 1, max: 4));
    });
    test('min > max is rejected', () {
      expect(ProtocolRange.from({'min': 4, 'max': 1}), isNull);
    });
    test('a string protocol is rejected', () {
      expect(ProtocolRange.from('v1'), isNull);
    });
    test('null is rejected', () {
      expect(ProtocolRange.from(null), isNull);
    });
  });
}
