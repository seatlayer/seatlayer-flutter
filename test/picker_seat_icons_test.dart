import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_seat_icons.dart';

/// Every key a seat note or an accessibility row can ask for.
const List<String> _keys = <String>[
  'wheelchair',
  'companion',
  'semi-ambulatory',
  'designated-aisle',
  'step-free',
  'hearing',
  'cart',
  'sign-language',
  'low-vision',
  'sensory-friendly',
  'plus-size',
  'lift-armrest',
  'restrictedView',
  'obstructedView',
  'premium',
  'note',
];

void main() {
  test('the twelve accommodations, three marks and the note all draw', () {
    for (final key in _keys) {
      final path = seatLayerSeatIconPath(key);
      expect(path, isNotNull, reason: key);
      expect(path!.getBounds().isEmpty, isFalse, reason: key);
    }
    // The colour row's disc is here too, and it is NOT one of the seat marks.
    expect(seatLayerSeatIconPath('contrast'), isNotNull);
    expect(seatLayerSeatIconFillPath('contrast'), isNotNull);
  });

  test('every glyph stays inside the authored 20-unit box', () {
    for (final key in <String>[..._keys, 'contrast']) {
      final bounds = seatLayerSeatIconPath(key)!.getBounds();
      expect(bounds.left, greaterThanOrEqualTo(-0.01), reason: key);
      expect(bounds.top, greaterThanOrEqualTo(-0.01), reason: key);
      expect(bounds.right,
          lessThanOrEqualTo(seatLayerSeatIconViewBox + 0.01), reason: key);
      expect(bounds.bottom,
          lessThanOrEqualTo(seatLayerSeatIconViewBox + 0.01), reason: key);
    }
  });

  test('no two attributes are the same drawing', () {
    final seen = <String, Rect>{};
    for (final key in _keys) {
      seen[key] = seatLayerSeatIconPath(key)!.getBounds();
    }
    // Restricted and obstructed share the eye and differ in what is on it,
    // which is the whole point of them being two rows.
    expect(seen['restrictedView'], isNot(seen['obstructedView']));
    expect(seen['wheelchair'], isNot(seen['companion']));
  });

  test('a key this build does not know draws nothing, never a broken box', () {
    expect(seatLayerSeatIconPath('an-accommodation-from-the-future'), isNull);
    expect(seatLayerSeatIconFillPath('premium'), isNull);
  });

  group('the path reader', () {
    test('closes a shape, and Z returns to the sub-path start', () {
      final path = seatLayerParseSvgPath('M2 2H8V8Z');
      expect(path.contains(const Offset(3, 2.5)), isTrue);
      expect(path.getBounds(), const Rect.fromLTRB(2, 2, 8, 8));
    });

    test('reads a relative moveto followed by implicit lines', () {
      // `m8 6 2 4 3 2` is a move to (8,6) and then two LINES, not three moves.
      final path = seatLayerParseSvgPath('m8 6 2 4 3 2');
      expect(path.getBounds(), const Rect.fromLTRB(8, 6, 13, 12));
    });

    test('splits a second decimal point into the next number', () {
      // `c.8.7 2.2.7 3 0` is six numbers, and reading `2.2.7` as one would
      // throw the whole curve out.
      final path = seatLayerParseSvgPath('M0 0c.8.7 2.2.7 3 0');
      expect(path.getBounds().right, closeTo(3, 0.001));
    });

    test('turns an arc into the circle it describes', () {
      // A full circle written as two half arcs, the form `<circle>` compiles to.
      final path = seatLayerParseSvgPath('M2 10a8 8 0 1 0 16 0a8 8 0 1 0-16 0');
      final bounds = path.getBounds();
      expect(bounds.left, closeTo(2, 0.05));
      expect(bounds.right, closeTo(18, 0.05));
      expect(bounds.top, closeTo(2, 0.05));
      expect(bounds.bottom, closeTo(18, 0.05));
    });

    test('reflects a smooth cubic off the previous one', () {
      final smooth = seatLayerParseSvgPath('M0 10c2-5 5-5 7 0s5 5 7 0');
      final spelled =
          seatLayerParseSvgPath('M0 10c2-5 5-5 7 0c2-5 5 5 7 0');
      expect(smooth.getBounds(), spelled.getBounds());
    });

    test('refuses data it cannot read rather than drawing half of it', () {
      expect(() => seatLayerParseSvgPath('M0 0Q5 5 10 0'),
          throwsA(isA<FormatException>()));
    });
  });
}
