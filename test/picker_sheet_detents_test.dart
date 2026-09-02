import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_sheet_drag.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

/// The sheet's physics, away from the sheet: where a finger's last position and
/// speed say the sheet should come to rest.
void main() {
  group('detents', () {
    test('a cart that fits under the ceiling has two places to stop', () {
      const detents = PickerSheetDetents(content: 180, full: 180);
      expect(detents.offersFull, isFalse);
      expect(
        detents.offered,
        <SeatLayerSheetDetent>[
          SeatLayerSheetDetent.peek,
          SeatLayerSheetDetent.content,
        ],
      );
      expect(detents.top, 180);
    });

    test('full is only a place of its own once the content overflows', () {
      const detents = PickerSheetDetents(content: 300, full: 620);
      expect(detents.offersFull, isTrue);
      expect(detents.heightOf(SeatLayerSheetDetent.full), 620);
      expect(detents.heightOf(SeatLayerSheetDetent.peek), 0);
    });

    test('a full below the ceiling cannot be shorter than the content', () {
      const detents = PickerSheetDetents(content: 300, full: 120);
      expect(detents.full, 300);
      expect(detents.offersFull, isFalse);
    });

    test('letting go settles at the nearest place to stop', () {
      const detents = PickerSheetDetents(content: 300, full: 620);
      expect(detents.nearest(20), SeatLayerSheetDetent.peek);
      expect(detents.nearest(260), SeatLayerSheetDetent.content);
      expect(detents.nearest(500), SeatLayerSheetDetent.full);
    });

    test('a fling goes where it was thrown, not where it was let go', () {
      const detents = PickerSheetDetents(content: 300, full: 620);
      const thrown = SeatLayerPhysicsTokens.sheetFlingVelocity + 1;
      // Barely off the peek bar, thrown upward: the next place up, not the one
      // the sheet is still sitting next to.
      expect(
        detents.settle(height: 12, velocity: thrown),
        SeatLayerSheetDetent.content,
      );
      // Nearly at the top, thrown downward.
      expect(
        detents.settle(height: 600, velocity: -thrown),
        SeatLayerSheetDetent.content,
      );
      // A throw with nowhere further to go stops at the end.
      expect(
        detents.settle(height: 620, velocity: thrown),
        SeatLayerSheetDetent.full,
      );
      // Below the fling threshold it is simply a measurement again.
      expect(
        detents.settle(height: 12, velocity: 10),
        SeatLayerSheetDetent.peek,
      );
    });
  });

  group('the rubber band', () {
    test('leaves everything inside the ends alone', () {
      expect(pickerRubberBand(120, 0, 300), 120);
      expect(pickerRubberBand(0, 0, 300), 0);
      expect(pickerRubberBand(300, 0, 300), 300);
    });

    test('gives past the ends, at a fraction of the finger', () {
      expect(
        pickerRubberBand(400, 0, 300),
        300 + 100 * SeatLayerPhysicsTokens.rubberBand,
      );
      expect(
        pickerRubberBand(-100, 0, 300),
        -100 * SeatLayerPhysicsTokens.rubberBand,
      );
    });
  });
}
