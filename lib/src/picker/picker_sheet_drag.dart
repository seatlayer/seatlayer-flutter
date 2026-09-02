import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'picker_tokens.g.dart';

/// Where the cart sheet rests.
///
/// Three positions, not a fraction: a sheet that can stop anywhere has no
/// position a buyer can return to, and the picker's own chrome — the peek
/// bar's height, the map's clearance — is drawn against these and nothing
/// between them.
enum SeatLayerSheetDetent {
  /// The peek bar alone: the head, and the device's bottom inset under it.
  peek,

  /// The sheet at the height of its own content, capped at the web picker's
  /// ceilings. The height the sheet opens to, and the only one it ever
  /// chooses for itself.
  content,

  /// The buyer pulled the sheet past the ceiling to see the rest of a long
  /// order. Offered only when there IS a rest — see
  /// [PickerSheetDetents.offersFull].
  full,
}

/// The heights [SeatLayerSheetDetent] means, in logical points of sheet BODY —
/// the part below the head, which is what actually changes size.
///
/// Peek is zero by construction: the head and the bottom inset are always
/// drawn, so collapsing the sheet is collapsing its body to nothing.
@immutable
class PickerSheetDetents {
  /// Creates a detent table. [full] is clamped up to [content]: a sheet whose
  /// content fits under the ceiling has nothing to open further onto.
  const PickerSheetDetents({required this.content, required double full})
      : full = full < content ? content : full;

  /// The sheet at its own content height, under the web picker's ceiling.
  final double content;

  /// The tallest the buyer can drag it. Equal to [content] unless the content
  /// overflows the ceiling.
  final double full;

  /// Two heights are the same detent when they differ by less than this.
  static const double epsilon = .5;

  /// Whether [SeatLayerSheetDetent.full] is a place of its own.
  bool get offersFull => full > content + epsilon;

  /// The highest detent on offer.
  double get top => offersFull ? full : content;

  /// The height [detent] rests at.
  double heightOf(SeatLayerSheetDetent detent) => switch (detent) {
        SeatLayerSheetDetent.peek => 0,
        SeatLayerSheetDetent.content => content,
        SeatLayerSheetDetent.full => top,
      };

  /// Every detent on offer, from the shortest up.
  List<SeatLayerSheetDetent> get offered => <SeatLayerSheetDetent>[
        SeatLayerSheetDetent.peek,
        SeatLayerSheetDetent.content,
        if (offersFull) SeatLayerSheetDetent.full,
      ];

  /// Where a body [height] settles when the finger simply lets go.
  SeatLayerSheetDetent nearest(double height) {
    var best = SeatLayerSheetDetent.peek;
    var bestGap = double.infinity;
    for (final detent in offered) {
      final gap = (heightOf(detent) - height).abs();
      if (gap < bestGap) {
        bestGap = gap;
        best = detent;
      }
    }
    return best;
  }

  /// Where a body [height] settles when the finger was still moving at
  /// [velocity] — points of body height per second, positive while the sheet
  /// is opening.
  ///
  /// A fling is an instruction, not a measurement: past
  /// [SeatLayerPhysicsTokens.sheetFlingVelocity] the sheet goes to the next
  /// detent in the direction thrown even when it is nowhere near it, which is
  /// what lets one flick off the peek bar open the whole sheet.
  SeatLayerSheetDetent settle(
      {required double height, required double velocity}) {
    if (velocity.abs() < SeatLayerPhysicsTokens.sheetFlingVelocity) {
      return nearest(height);
    }
    final order = offered;
    if (velocity > 0) {
      for (final detent in order) {
        if (heightOf(detent) > height + epsilon) return detent;
      }
      return order.last;
    }
    for (final detent in order.reversed) {
      if (heightOf(detent) < height - epsilon) return detent;
    }
    return order.first;
  }

  @override
  bool operator ==(Object other) =>
      other is PickerSheetDetents &&
      other.content == content &&
      other.full == full;

  @override
  int get hashCode => Object.hash(content, full);

  @override
  String toString() => 'PickerSheetDetents(content: $content, full: $full)';
}

/// [raw], held inside `[low, high]` by a band that gives rather than stops.
///
/// A hard clamp tells the buyer their finger has stopped working. A rubber
/// band tells them they have reached the end and are still holding the sheet:
/// the surface keeps moving, at a fraction of the finger's speed, and lets go
/// back to the edge the moment they do.
double pickerRubberBand(double raw, double low, double high) {
  if (raw > high) {
    return high + (raw - high) * SeatLayerPhysicsTokens.rubberBand;
  }
  if (raw < low) return low - (low - raw) * SeatLayerPhysicsTokens.rubberBand;
  return raw;
}

/// The one spring the picker settles surfaces with.
const SpringDescription pickerSheetSpring = SpringDescription(
  mass: SeatLayerPhysicsTokens.sheetSpringMass,
  stiffness: SeatLayerPhysicsTokens.sheetSpringStiffness,
  damping: SeatLayerPhysicsTokens.sheetSpringDamping,
);

/// Reports its child's laid-out height, once per change.
///
/// The sheet has to know how tall its content WANTS to be before it can decide
/// where the content detent is — and it has to know that without ever drawing
/// the sheet at that height first, which is what an [IntrinsicHeight] would
/// cost on a list of tickets.
class PickerMeasuredHeight extends SingleChildRenderObjectWidget {
  /// Measures [child] and reports its height to [onHeight].
  const PickerMeasuredHeight({
    super.key,
    required this.onHeight,
    required Widget super.child,
  });

  /// Called after layout whenever the measured height changes.
  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasuredHeight(onHeight);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderMeasuredHeight).onHeight = onHeight;
}

class _RenderMeasuredHeight extends RenderProxyBox {
  _RenderMeasuredHeight(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final measured = size.height;
    if (_reported != null &&
        (measured - _reported!).abs() < PickerSheetDetents.epsilon) {
      return;
    }
    _reported = measured;
    // After the frame: this runs inside layout, and a listener that rebuilds
    // the sheet from here would be changing the tree it is being measured in.
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(measured));
  }
}
