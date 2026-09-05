// One physical touch, one surface: native chrome standing on the map must not
// let the same tap reach the map underneath it.
//
// The half of this that lives on the device — iOS forwarding a held touch to
// the embedded `WKWebView` when Flutter never resolves the platform view's
// gesture — cannot be reached from `flutter test`: there is no platform view
// here. What CAN be pinned is the decision behind it: whether the map's
// recognizer is told it lost the sequence. A platform view that is rejected is
// blocked by the engine; one that is never resolved at all is handed the touch
// anyway, and that is the leak.
//
// So these tests stand a double for the platform view in the map's place,
// wired the way `RenderUiKitView` wires the real one — an arena team whose
// captain relays the verdict to the engine — and assert the verdict.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/seat_layer_map_chrome.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// What the engine is told about a touch that started over the map.
enum _Verdict { accepted, rejected }

/// A stand-in for `RenderUiKitView`'s gesture wiring.
///
/// `_UiKitViewGestureRecognizer` captains a team the configured recognizers
/// join, and relays the team's verdict to the engine as `acceptGesture` (the
/// web view is handed the touch) or `rejectGesture` (the engine swallows it).
/// This double is that captain, with the same team shape, so the verdict it
/// records is the one the real platform view would act on.
class _PlatformViewDouble extends OneSequenceGestureRecognizer {
  _PlatformViewDouble(this.verdicts, SeatLayerMapChromeLatch latch) {
    team = GestureArenaTeam()..captain = this;
    _surface = SeatLayerMapSurfaceGestureRecognizer(latch)..team = team;
  }

  final List<_Verdict> verdicts;
  late final SeatLayerMapSurfaceGestureRecognizer _surface;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _surface.addPointer(event);
  }

  @override
  void acceptGesture(int pointer) => verdicts.add(_Verdict.accepted);

  @override
  void rejectGesture(int pointer) => verdicts.add(_Verdict.rejected);

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) =>
      stopTrackingIfPointerNoLongerDown(event);

  @override
  String get debugDescription => 'platform view double';

  @override
  void dispose() {
    _surface.dispose();
    super.dispose();
  }
}

/// The map's place in the tree: an opaque surface that reaches the arena only
/// through the platform-view double, as the real `UiKitView` does.
class _MapDouble extends StatelessWidget {
  const _MapDouble(this.verdicts);

  final List<_Verdict> verdicts;

  @override
  Widget build(BuildContext context) {
    final latch = SeatLayerMapChromeScope.maybeOf(context);
    // The turnkey layout must always publish one; a map without it is the
    // configuration that leaks.
    expect(latch, isNotNull);
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        _PlatformViewDouble:
            GestureRecognizerFactoryWithHandlers<_PlatformViewDouble>(
          () => _PlatformViewDouble(verdicts, latch!),
          (_) {},
        ),
      },
      child: const SizedBox.expand(),
    );
  }
}

Future<void> _noopCheckout(SeatLayerCheckoutHandoff handoff) async {}

Widget _picker(List<_Verdict> verdicts) => SeatLayerPickerAdaptiveLayout(
      onCheckout: _noopCheckout,
      builders: SeatLayerPickerBuilders(
        map: (context, part) => _MapDouble(verdicts),
      ),
    );

const SeatLayerPickerOptions _withZoomDiscs = SeatLayerPickerOptions(
  chrome: SeatLayerPickerChromeOptions(showZoomControls: true),
);

void main() {
  testWidgets('a corner disc spends the tap on itself, not on the map',
      (tester) async {
    // The zoom-out disc floats inside the map's own bounds, in the bottom
    // corner. One tap on it must step the camera out and leave the map with
    // nothing: on iOS a platform view that is neither accepted nor rejected is
    // handed the touch anyway, which is how one press became a zoom AND a seat.
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final verdicts = <_Verdict>[];

    await tester.pumpWidget(
      pickerHarness(map, _picker(verdicts), options: _withZoomDiscs),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    final disc = find.byTooltip('Zoom out');
    expect(disc, findsOneWidget);
    await tester.tap(disc);
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.zoomOut'), hasLength(1));
    // The map heard the touch and was told, in the same sequence, that it lost
    // it. That verdict is what stops the engine forwarding it to the web view.
    expect(verdicts, <_Verdict>[_Verdict.rejected]);
    expect(map.callsTo('picker.selectObjects'), isEmpty);
  });

  testWidgets('the map still claims a touch that landed on the map',
      (tester) async {
    // The other half of the same rule: away from chrome the map keeps the
    // eager claim it makes on pointer down, which is what its pan and pinch
    // are built on. A fix that made the map wait for the arena would be a
    // regression in feel even though nothing leaked.
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final verdicts = <_Verdict>[];

    await tester.pumpWidget(
      pickerHarness(map, _picker(verdicts), options: _withZoomDiscs),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    // The middle of the map band, clear of every corner, rail and strip.
    final gesture = await tester.startGesture(const Offset(195, 420));
    // Claimed already, on the press — nothing has been lifted yet.
    expect(verdicts, <_Verdict>[_Verdict.accepted]);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a layout that publishes no latch leaves the map eager',
      (tester) async {
    // A host composing its own layout has no map stack and no latch, so the
    // map surface keeps the plain eager recognizer every release before this
    // one used. Source compatibility, and no new way for a custom composition
    // to lose its gestures.
    SeatLayerMapChromeLatch? seen;
    var built = false;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          built = true;
          seen = SeatLayerMapChromeScope.maybeOf(context);
          return const SizedBox();
        },
      ),
    );
    expect(built, isTrue);
    expect(seen, isNull);
  });
}
