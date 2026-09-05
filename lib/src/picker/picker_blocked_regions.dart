/// Where the native chrome lies over the map, told to the runtime.
///
/// The map is a platform view, and on iOS a tap on a control drawn over it
/// reaches the web view as well — measured on iOS 26.5: the shell rejects the
/// platform view's gesture 134 ms before the finger lifts and the page still
/// gets the touch, so a press on the `−` disc selected the seat under it. A
/// guard sent on pointer-down loses the race (a bridge round trip is ~180 ms
/// against a 24 ms tap); the only one that works is standing before the finger
/// lands. So every piece of chrome that stands on the map reports its
/// rectangle, once per layout, and the runtime swallows any pointer sequence
/// that starts inside one before its own gesture machine or canvas can see it.
///
/// Three parts: the value ([SeatLayerBlockedRegion]), the command on the
/// controller ([SeatLayerPickerBlockedRegions]), and the widgets that measure
/// ([SeatLayerMapChromeRegion] under a [SeatLayerBlockedRegionScope]).
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'picker_viewport_report.dart';
import 'seat_layer_picker_controller.dart';

/// The bridge command, named once so the gate and the send cannot drift.
@internal
const String seatLayerBlockedRegionsCommand = 'picker.setBlockedRegions';

/// One rectangle of native chrome over the map, in the map's own logical px,
/// measured from the map surface's top-left corner.
@immutable
class SeatLayerBlockedRegion {
  /// Creates a region. Non-finite sides and negative sizes are floored to
  /// zero rather than sent: the runtime refuses the WHOLE list for one bad
  /// rectangle, and a mis-measured disc must not drop the guard on the rest.
  SeatLayerBlockedRegion({
    required double x,
    required double y,
    required double w,
    required double h,
  })  : x = _finite(x),
        y = _finite(y),
        w = _size(w),
        h = _size(h);

  /// From a [Rect] in the map's coordinates.
  SeatLayerBlockedRegion.fromRect(Rect rect)
      : this(x: rect.left, y: rect.top, w: rect.width, h: rect.height);

  /// Left edge.
  final double x;

  /// Top edge.
  final double y;

  /// Width.
  final double w;

  /// Height.
  final double h;

  static double _finite(double value) => value.isFinite ? value : 0;
  static double _size(double value) => value.isFinite && value > 0 ? value : 0;

  /// The payload entry `picker.setBlockedRegions` accepts.
  Map<String, Object?> toBridgePayload() =>
      <String, Object?>{'x': x, 'y': y, 'w': w, 'h': h};

  @override
  bool operator ==(Object other) =>
      other is SeatLayerBlockedRegion &&
      other.x == x &&
      other.y == y &&
      other.w == w &&
      other.h == h;

  @override
  int get hashCode => Object.hash(x, y, w, h);

  @override
  String toString() => 'SeatLayerBlockedRegion($x, $y, $w × $h)';
}

/// Element-wise equality, for the coalescing report.
bool seatLayerBlockedRegionsEqual(
  List<SeatLayerBlockedRegion> a,
  List<SeatLayerBlockedRegion> b,
) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The blocked-regions report: the whole list, replaced on every send.
typedef PickerBlockedRegionsReport
    = PickerCoalescedReport<List<SeatLayerBlockedRegion>>;

/// The one input-only command.
extension SeatLayerPickerBlockedRegions on SeatLayerPickerController {
  /// Whether the mounted runtime takes the rectangles at all.
  ///
  /// Gated on the command being in the bundle's own `hello` table: this
  /// changes nothing a snapshot reports, so the command table IS the whole
  /// contract. An older runtime is left as it was — the platform-view
  /// gesture boundary still resigns the touch, which is right everywhere the
  /// leak does not happen.
  bool get supportsBlockedRegions =>
      mapController.bundleInfo?.supportsCommand(
        seatLayerBlockedRegionsCommand,
      ) ==
      true;
}

/// Collects the rectangles every [SeatLayerMapChromeRegion] measures and hands
/// the runtime the whole list, once per frame, only when it has changed.
///
/// Owned by the layout that composes the chrome, and handed down through a
/// [SeatLayerBlockedRegionScope]; the widgets register by identity and leave
/// on dispose, so a control that unmounts takes its rectangle with it.
class SeatLayerBlockedRegionRegistry {
  /// Creates a registry that hands each settled list to [report].
  SeatLayerBlockedRegionRegistry({
    required this.report,
    this.linger = defaultLinger,
  });

  /// How long a rectangle keeps blocking after its control has gone.
  ///
  /// The leak this guards against is a touch delivered to the web view
  /// ~134 ms AFTER the shell has already handled it. A control that leaves
  /// on its own tap — the seat card's Add button, the overview disc — would
  /// otherwise take its rectangle away before that late touch lands, and the
  /// runtime would be told to stop guarding exactly where the finger is.
  static const Duration defaultLinger = Duration(milliseconds: 600);

  /// Delivers the whole list; the caller coalesces and de-duplicates.
  final void Function(List<SeatLayerBlockedRegion> rects) report;

  /// See [defaultLinger].
  final Duration linger;

  final Map<Object, SeatLayerBlockedRegion> _rects =
      <Object, SeatLayerBlockedRegion>{};
  final Map<Object, VoidCallback> _measure = <Object, VoidCallback>{};
  final Map<Object, Timer> _leaving = <Object, Timer>{};
  bool _flushScheduled = false;
  bool _remeasureScheduled = false;

  /// What is registered right now, in registration order.
  List<SeatLayerBlockedRegion> get rects =>
      List<SeatLayerBlockedRegion>.unmodifiable(_rects.values);

  /// Record [rect] for [key], or forget [key] with null.
  ///
  /// Forgetting is deferred by [linger]; recording again in the meantime
  /// simply keeps the rectangle.
  void set(Object key, SeatLayerBlockedRegion? rect) {
    final previous = _rects[key];
    if (rect == null) {
      if (previous == null || _leaving.containsKey(key)) return;
      if (linger == Duration.zero) {
        _rects.remove(key);
        _scheduleFlush();
        return;
      }
      _leaving[key] = Timer(linger, () {
        _leaving.remove(key);
        if (_rects.remove(key) != null) _scheduleFlush();
      });
      return;
    }
    _leaving.remove(key)?.cancel();
    if (previous == rect) return;
    _rects[key] = rect;
    _scheduleFlush();
  }

  /// Forget everything at once, with no linger — the layout itself is gone
  /// and the runtime either goes with it or is told `[]` by whoever mounts
  /// next.
  void dispose() {
    for (final timer in _leaving.values) {
      timer.cancel();
    }
    _leaving.clear();
    _measure.clear();
    _rects.clear();
  }

  /// Keep [measure] for [key] so a layout pass can ask every region again.
  void attach(Object key, VoidCallback measure) => _measure[key] = measure;

  /// The region is gone: its rectangle and its measurer go with it.
  void detach(Object key) {
    _measure.remove(key);
    set(key, null);
  }

  /// Ask every region to measure itself again after this frame.
  ///
  /// Called from the composing layout's build: chrome that moves without
  /// rebuilding the region inside it — a column riding up as the dock arrives
  /// — would otherwise keep reporting where it used to be.
  void remeasureAfterFrame() {
    if (_remeasureScheduled) return;
    _remeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _remeasureScheduled = false;
      for (final measure in List<VoidCallback>.of(_measure.values)) {
        measure();
      }
    });
  }

  void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    // A microtask, not a frame: the measurers already run after the frame,
    // and the report itself coalesces per frame. This only folds the several
    // regions of one pass into one call.
    scheduleMicrotask(() {
      _flushScheduled = false;
      report(rects);
    });
  }
}

/// Hands the registry and the map's box to the chrome standing on the map.
class SeatLayerBlockedRegionScope extends InheritedWidget {
  /// Creates the scope.
  const SeatLayerBlockedRegionScope({
    super.key,
    required this.registry,
    required this.mapBox,
    required super.child,
  });

  /// Where the regions register.
  final SeatLayerBlockedRegionRegistry registry;

  /// The map surface's render box, or null before it is laid out.
  final RenderBox? Function() mapBox;

  /// The nearest scope, or null in a composition that reports nothing.
  static SeatLayerBlockedRegionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeatLayerBlockedRegionScope>();

  /// Guard the WHOLE map while [run] is in progress.
  ///
  /// For a surface that is not in the map's stack at all — a modal sheet or a
  /// dialog pushed over the page. Its scrim covers the map, and on iOS the
  /// tap that dismisses it reaches the web view too, so the accessibility
  /// sheet used to close and step the camera out with one touch. The guard
  /// lingers past the future, which is what catches that late touch.
  static Future<T> coverWhile<T>(
    BuildContext context,
    Future<T> Function() run,
  ) async {
    final scope =
        context.getInheritedWidgetOfExactType<SeatLayerBlockedRegionScope>();
    final map = scope?.mapBox();
    if (scope == null || map == null) return run();
    final key = Object();
    scope.registry.set(
      key,
      SeatLayerBlockedRegion.fromRect(Offset.zero & map.size),
    );
    try {
      return await run();
    } finally {
      scope.registry.set(key, null);
    }
  }

  @override
  bool updateShouldNotify(SeatLayerBlockedRegionScope oldWidget) =>
      oldWidget.registry != registry;
}

/// A piece of native chrome standing on the map.
///
/// Wraps the control and reports its rectangle, in the map's coordinates,
/// after every frame it is built in and whenever the layout asks. Draws
/// nothing of its own and takes no pointer event: the control underneath
/// still competes for the touch exactly as §2.4 requires — this is the second
/// guard, for the platform that lets the touch through anyway.
class SeatLayerMapChromeRegion extends StatefulWidget {
  /// Creates a region around [child].
  const SeatLayerMapChromeRegion({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// The control.
  final Widget child;

  /// Whether the rectangle is reported at all. A surface that stays mounted
  /// while empty — the prompt layer between prompts — reports nothing then.
  final bool enabled;

  @override
  State<SeatLayerMapChromeRegion> createState() =>
      _SeatLayerMapChromeRegionState();
}

class _SeatLayerMapChromeRegionState extends State<SeatLayerMapChromeRegion> {
  SeatLayerBlockedRegionScope? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = SeatLayerBlockedRegionScope.maybeOf(context);
    if (scope?.registry != _scope?.registry) {
      _scope?.registry.detach(this);
      _scope = scope;
      scope?.registry.attach(this, _measure);
    }
  }

  @override
  void dispose() {
    _scope?.registry.detach(this);
    _scope = null;
    super.dispose();
  }

  void _measure() {
    final scope = _scope;
    if (!mounted || scope == null) return;
    final box = context.findRenderObject();
    final map = scope.mapBox();
    if (!widget.enabled ||
        box is! RenderBox ||
        map == null ||
        !box.attached ||
        !map.attached ||
        !box.hasSize ||
        !map.hasSize) {
      scope.registry.set(this, null);
      return;
    }
    // In the map's own coordinates: the map is the web view, and the web
    // view's page fills it edge to edge. The two are siblings in one stack,
    // so the difference of their global origins is the offset between them.
    final origin =
        box.localToGlobal(Offset.zero) - map.localToGlobal(Offset.zero);
    scope.registry.set(
      this,
      SeatLayerBlockedRegion.fromRect(origin & box.size),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layout is not a place to report from; the frame that lays this out is.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return widget.child;
  }
}
