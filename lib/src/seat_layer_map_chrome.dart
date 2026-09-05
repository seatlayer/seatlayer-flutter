// Native chrome standing on the map, and the one physical touch it must spend.
//
// The map is an iOS `UiKitView` (a `WKWebView`) and an Android platform view.
// On iOS the embedded view is a real `UIView` in the native hierarchy, wrapped
// by the engine in a touch-intercepting view whose delaying recognizer holds
// each touch until Flutter says who won it:
//
// - Flutter's arena awards the sequence to the platform view → `acceptGesture`
//   → the delaying recognizer FAILS → UIKit delivers the held touches to the
//   web view. This is what makes the map pan, pinch and pick.
// - Flutter's arena awards it elsewhere → `rejectGesture` → the delaying
//   recognizer ENDS → the touches are swallowed and the web view sees nothing.
// - **Neither** → the delaying recognizer is never resolved, and at the end of
//   the sequence UIKit delivers the held touches to the web view anyway.
//
// That third case is the whole bug. `RenderUiKitView.handleEvent` is what puts
// the platform view into the arena, and it only runs if the render object was
// hit-tested. A plain `Stack` stops hit-testing at the topmost child that
// reports a hit, so a native button drawn over the map takes the pointer and
// the map is never visited — no accept, no reject, and the same physical tap
// lands on the button in Flutter AND on a seat in the web view.
//
// `IgnorePointer` does not help: removing the map from the hit test is exactly
// the state that leaks. The fix has to put the map INTO the arena and make it
// lose there:
//
// - [SeatLayerMapChromeStack] hit-tests chrome first, exactly as `Stack` does,
//   and then always gives the map layer its turn as well, so the platform view
//   is in the arena for every touch inside the map band.
// - [SeatLayerMapSurfaceGestureRecognizer] stays eager — it claims the gesture
//   on pointer down, which is what buys the map its latency-free pan and pinch
//   — **unless** the same hit test landed on chrome, in which case it resigns
//   and the platform view is told it lost.
//
// Chrome over the map must therefore compete for the pointer (a button, an
// `InkWell`, a `GestureDetector` — anything that enters the arena). A bare
// `Listener` observes pointers without competing, so nothing would claim the
// sequence and the map would still win it.
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Whether the hit test that is about to be dispatched landed on native chrome
/// drawn over the map.
///
/// Written by [SeatLayerMapChromeStack] during hit testing and read by
/// [SeatLayerMapSurfaceGestureRecognizer] when the resulting pointer is
/// dispatched — the same frame, in that order, because Flutter hit-tests a
/// pointer down immediately before delivering it.
class SeatLayerMapChromeLatch {
  /// Whether the last hit test over the map band was claimed by chrome.
  bool claimed = false;
}

/// Hands the latch owned by the layout down to the map surface.
class SeatLayerMapChromeScope extends InheritedWidget {
  /// Creates a scope carrying [latch].
  const SeatLayerMapChromeScope({
    super.key,
    required this.latch,
    required super.child,
  });

  /// The latch shared with the [SeatLayerMapChromeStack] above the map.
  final SeatLayerMapChromeLatch latch;

  /// The enclosing latch, or null in a host-composed layout that does not use
  /// [SeatLayerMapChromeStack]. Without one the map keeps the plain eager
  /// recognizer, which is the behaviour every release before this one had.
  static SeatLayerMapChromeLatch? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SeatLayerMapChromeScope>()
      ?.latch;

  @override
  bool updateShouldNotify(SeatLayerMapChromeScope oldWidget) =>
      oldWidget.latch != latch;
}

/// Eager like [EagerGestureRecognizer], except over chrome.
///
/// Claiming on pointer down is what lets the map start panning on the first
/// moved pixel instead of after the arena resolves. When the same touch landed
/// on native chrome the recognizer resigns instead, which is what carries the
/// platform view a `rejectGesture` and stops the touch at the Flutter layer.
class SeatLayerMapSurfaceGestureRecognizer
    extends OneSequenceGestureRecognizer {
  /// Creates a recognizer that consults [latch] for every new pointer.
  SeatLayerMapSurfaceGestureRecognizer(this.latch);

  /// The chrome hit test for the pointer being added.
  final SeatLayerMapChromeLatch latch;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    resolve(
      latch.claimed ? GestureDisposition.rejected : GestureDisposition.accepted,
    );
  }

  @override
  String get debugDescription => 'seat layer map surface';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    stopTrackingIfPointerNoLongerDown(event);
  }
}

/// A [Stack] whose first child is the map and whose remaining children are the
/// native chrome standing on it.
///
/// Identical to [Stack] in layout and painting. In hit testing it differs in
/// one way: a chrome hit no longer hides the map from the hit test, so the
/// platform view always joins the arena and always learns whether it won.
class SeatLayerMapChromeStack extends Stack {
  /// Creates a map stack sharing [latch] with the map surface below it.
  const SeatLayerMapChromeStack({
    super.key,
    required this.latch,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
    super.children,
  });

  /// The latch this stack writes on every hit test.
  final SeatLayerMapChromeLatch latch;

  @override
  RenderStack createRenderObject(BuildContext context) =>
      _RenderMapChromeStack(latch)
        ..alignment = alignment
        ..textDirection = textDirection ?? Directionality.maybeOf(context)
        ..fit = fit
        ..clipBehavior = clipBehavior;

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    super.updateRenderObject(context, renderObject);
    (renderObject as _RenderMapChromeStack).latch = latch;
  }
}

class _RenderMapChromeStack extends RenderStack {
  _RenderMapChromeStack(this.latch);

  SeatLayerMapChromeLatch latch;

  bool _hitChild(RenderBox child, BoxHitTestResult result, Offset position) {
    final parentData = child.parentData! as StackParentData;
    return result.addWithPaintOffset(
      offset: parentData.offset,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? map = firstChild;
    // Chrome, topmost first and first hit wins, exactly as `Stack` resolves it.
    var chromeHit = false;
    RenderBox? child = lastChild;
    while (child != null && child != map) {
      if (_hitChild(child, result, position)) {
        chromeHit = true;
        break;
      }
      child = (child.parentData! as StackParentData).previousSibling;
    }
    // The map goes into the arena either way. Entry order still puts chrome
    // first, so chrome wins the sequence and the platform view is rejected —
    // which is the only thing that stops iOS forwarding the touch to the web
    // view underneath.
    latch.claimed = chromeHit;
    final mapHit = map != null && _hitChild(map, result, position);
    return chromeHit || mapHit;
  }
}
