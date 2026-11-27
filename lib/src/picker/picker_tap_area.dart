/// Presses near a small control, for the control.
///
/// Some phone controls are drawn smaller than 44 points: the close ring, the
/// price chips, the halves of Map | 3D and the map's discs. Each keeps its
/// drawn size and its place; a press that lands on no control, inside the
/// square of 44 around one of them, goes to that control. A Flutter hit box
/// cannot leave its parent, so the root of the picker answers for them.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../seat_layer_map_chrome.dart';
import 'picker_tokens.g.dart';

/// The square a control answers presses on, in points.
const double _reach = SeatLayerSizeTokens.minimumHitTarget;

/// Where presses near a [PickerTapArea] under it are taken for that control.
class PickerTapAreaRoot extends SingleChildRenderObjectWidget {
  /// Creates the root.
  const PickerTapAreaRoot({super.key, this.latch, super.child});

  /// The map's chrome latch: a press given to a control drawn on the map is
  /// chrome's, so the map joins the arena and is turned down, as it is for a
  /// press on the control itself.
  final SeatLayerMapChromeLatch? latch;

  @override
  RenderPickerTapAreaRoot createRenderObject(BuildContext context) =>
      RenderPickerTapAreaRoot()..latch = latch;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPickerTapAreaRoot renderObject,
  ) {
    renderObject.latch = latch;
  }
}

/// A control that answers presses on the square of 44 around it.
///
/// Without a [PickerTapAreaRoot] above it, it answers only on itself.
class PickerTapArea extends SingleChildRenderObjectWidget {
  /// Creates the area.
  const PickerTapArea({super.key, this.enabled = true, required super.child});

  /// Whether the control does anything. A control that does nothing keeps the
  /// presses around it for what is under them.
  final bool enabled;

  @override
  RenderPickerTapArea createRenderObject(BuildContext context) =>
      RenderPickerTapArea(enabled: enabled);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPickerTapArea renderObject,
  ) {
    renderObject.enabled = enabled;
  }
}

/// The render object of [PickerTapArea].
class RenderPickerTapArea extends RenderProxyBox {
  /// Creates the render object.
  RenderPickerTapArea({required this.enabled});

  /// Whether the control does anything.
  bool enabled;

  RenderPickerTapAreaRoot? _root;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (RenderObject? up = parent; up != null; up = up.parent) {
      if (up is RenderPickerTapAreaRoot) {
        _root = up.._areas.add(this);
        break;
      }
    }
  }

  @override
  void detach() {
    _root?._areas.remove(this);
    _root = null;
    super.detach();
  }
}

/// The render object of [PickerTapAreaRoot].
class RenderPickerTapAreaRoot extends RenderProxyBox {
  final Set<RenderPickerTapArea> _areas = <RenderPickerTapArea>{};

  /// See [PickerTapAreaRoot.latch].
  SeatLayerMapChromeLatch? latch;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_areas.isEmpty || !size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    final near = _nearControl(position);
    if (near == null) return super.hitTest(result, position: position);
    final (area, inside, onIt) = near;
    if (onIt) {
      // On the control: its own hit test, unless the press found nothing of
      // it that takes one (the ring drawn around a disc's button).
      final hit = super.hitTest(result, position: position);
      if (_takesPress(result, area)) return hit;
      _addControl(result, area, inside);
      latch?.claimed = true;
      if (!hit) result.add(BoxHitTestEntry(this, position));
      return true;
    }
    // Beside it: the control first, so it wins the press, then what is under
    // the place pressed, so the map joins the arena and is turned down.
    _addControl(result, area, inside);
    final hit = super.hitTest(result, position: position);
    latch?.claimed = true;
    if (!hit) result.add(BoxHitTestEntry(this, position));
    return true;
  }

  /// The control's own hit test at [inside], a point on it in its own
  /// coordinates, so what it holds takes the press as it would its own.
  void _addControl(
    BoxHitTestResult result,
    RenderPickerTapArea area,
    Offset inside,
  ) {
    result.addWithPaintTransform(
      transform: area.getTransformTo(this),
      position: Offset.zero,
      hitTest: (result, _) => area.hitTest(result, position: inside),
    );
  }

  /// Whether [result] reached something under [area] that listens for
  /// pointers.
  static bool _takesPress(BoxHitTestResult result, RenderPickerTapArea area) {
    for (final entry in result.path) {
      final target = entry.target;
      if (target is! RenderPointerListener) continue;
      for (RenderObject? up = target.parent; up != null; up = up.parent) {
        if (identical(up, area)) return true;
      }
    }
    return false;
  }

  /// The control a press at [position] is for, the nearest point on it in its
  /// own coordinates, and whether the press is on it; null where the press
  /// goes the usual way.
  (RenderPickerTapArea, Offset, bool)? _nearControl(Offset position) {
    final rects = <RenderPickerTapArea, Rect>{
      for (final area in _areas)
        if (area.attached && area.hasSize && !area.size.isEmpty)
          area: MatrixUtils.transformRect(
            area.getTransformTo(this),
            Offset.zero & area.size,
          ),
    };
    // A press on a control is that control's, its ring included.
    RenderPickerTapArea? best;
    for (final MapEntry(key: area, value: rect) in rects.entries) {
      if (rect.contains(position)) {
        if (!area.enabled) return null;
        best = area;
      }
    }
    final onIt = best != null;
    var bestDistance = double.infinity;
    if (best == null) {
      for (final MapEntry(key: area, value: rect) in rects.entries) {
        if (!area.enabled) continue;
        // Its square, moved off a neighbour, or the plain square around it:
        // between two close controls the nearer one takes the press.
        if (!_square(rect, rects).contains(position) &&
            !_centred(rect).contains(position)) {
          continue;
        }
        final distance = (position - _nearest(rect, position)).distance;
        if (distance < bestDistance) {
          best = area;
          bestDistance = distance;
        }
      }
    }
    if (best == null) return null;
    final rect = rects[best]!;
    // Its middle: a disc's button is round inside its square, and its ring
    // is drawn around the button, not part of it.
    final nearest = rect.center;
    // The control must take a press on itself there (it is on screen and not
    // under anything), and nothing that answers a tap is drawn over the place
    // pressed.
    if (!_pressReaches(best, nearest)) return null;
    if (_coveredAt(best, rect, position)) return null;
    final local = MatrixUtils.transformPoint(
      best.getTransformTo(this)..invert(),
      nearest,
    );
    return (best, local, onIt);
  }

  /// The square of [_reach] around [rect], moved off a neighbour on a side
  /// where it has room to.
  Rect _square(Rect rect, Map<RenderPickerTapArea, Rect> rects) {
    final square = _centred(rect);
    if (square == rect) return rect;
    var before = 0.0, after = 0.0, above = 0.0, below = 0.0;
    for (final other in rects.values) {
      if (other == rect) continue;
      final theirs = _centred(other);
      if (!square.overlaps(theirs)) continue;
      final sameRow = other.top < rect.bottom && other.bottom > rect.top;
      final sameColumn = other.left < rect.right && other.right > rect.left;
      if (sameRow && other.center.dx > rect.center.dx) {
        after = math.max(after, square.right - theirs.left);
      } else if (sameRow) {
        before = math.max(before, theirs.right - square.left);
      } else if (sameColumn && other.center.dy > rect.center.dy) {
        below = math.max(below, square.bottom - theirs.top);
      } else if (sameColumn) {
        above = math.max(above, theirs.bottom - square.top);
      }
    }
    final dx = after > 0 && before == 0
        ? -after
        : before > 0 && after == 0
            ? before
            : 0.0;
    final dy = below > 0 && above == 0
        ? -below
        : above > 0 && below == 0
            ? above
            : 0.0;
    final moved = square.shift(Offset(dx, dy));
    // On the picker: a square past its edge would lose those presses.
    return moved.shift(Offset(
      _into(moved.left, moved.right, size.width),
      _into(moved.top, moved.bottom, size.height),
    ));
  }

  /// How far to move a span from [start] to [end] to stand inside 0 to [room].
  static double _into(double start, double end, double room) => start < 0
      ? math.min(-start, math.max(0, room - end))
      : end > room
          ? -math.min(end - room, start)
          : 0;

  static Rect _centred(Rect rect) => Rect.fromCenter(
        center: rect.center,
        width: math.max(rect.width, _reach),
        height: math.max(rect.height, _reach),
      );

  static Offset _nearest(Rect rect, Offset point) => Offset(
        point.dx.clamp(rect.left, rect.right),
        point.dy.clamp(rect.top, rect.bottom),
      );

  bool _pressReaches(RenderPickerTapArea area, Offset position) {
    final probe = BoxHitTestResult();
    super.hitTest(probe, position: position);
    return probe.path.any((entry) => identical(entry.target, area));
  }

  /// Whether what a press at [position] lands on is drawn over [area] and
  /// either covers it or answers a tap itself.
  bool _coveredAt(RenderPickerTapArea area, Rect rect, Offset position) {
    final probe = BoxHitTestResult();
    super.hitTest(probe, position: position);
    final mine = <RenderObject>{};
    for (RenderObject? up = area; up != null; up = up.parent) {
      mine.add(up);
    }
    final branch = <RenderObject>[];
    RenderObject? common;
    for (final entry in probe.path) {
      final target = entry.target;
      if (target is! RenderObject) continue;
      if (mine.contains(target)) {
        common = target;
        break;
      }
      branch.add(target);
    }
    // Landed on what the control stands on, or on the control.
    if (branch.isEmpty || identical(common, area)) return false;
    if (common == null) return true;
    final theirs = _childOn(branch.last, common);
    final ours = _childOn(area, common);
    if (theirs == null || ours == null) return true;
    final order = <RenderObject>[];
    common.visitChildren(order.add);
    // Drawn under the control: the map, the panel's own ground.
    if (order.indexOf(theirs) < order.indexOf(ours)) return false;
    if (theirs is RenderBox && theirs.hasSize) {
      final bounds = MatrixUtils.transformRect(
        theirs.getTransformTo(this),
        Offset.zero & theirs.size,
      );
      if (bounds.overlaps(rect)) return true;
    }
    return branch.any(
      (target) =>
          target is RenderSemanticsGestureHandler && target.onTap != null,
    );
  }

  /// The child of [ancestor] that [descendant] is under, or is.
  static RenderObject? _childOn(
      RenderObject descendant, RenderObject ancestor) {
    RenderObject? child = descendant;
    while (child != null && child.parent != ancestor) {
      child = child.parent;
    }
    return child;
  }
}
