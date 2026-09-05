// Native chrome covers the map, and the runtime frames against the whole map.
//
// The picker reports the bands its own chrome is standing on so a focused
// section lands where the buyer can see it. The two things worth pinning are
// that the report follows a layout change, and that it is withheld entirely
// from a runtime that never advertised the capability — the hosted CDN build
// is one of those, and sending it a command it does not know would fail an
// action the buyer started.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Iterable<Object?> _insetPayloads(FakePickerMap map) =>
    map.callsTo('picker.setViewportInsets').map((call) => call.$2);

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// The map's top line: the test badge in one corner and the Map/3D control
/// in the other, and the control is the taller of the two.
const double _badgeBand = 8 + SeatLayerPickerViewModeControl.height;

/// The badge once the scene's way back is drawn above it — and the way back
/// itself steps under the Map/3D control that shares the map's top line.
const double _seatedBadgeBand = (8 +
        SeatLayerPickerViewModeControl.height +
        SeatLayerVenue3D.captionGap) +
    SeatLayerVenue3D.backPillHeight +
    SeatLayerVenue3D.captionGap +
    SeatLayerPickerTestModeIndicator.compactHeight;

/// The picker with the immersive scene up, optionally sitting in a seat.
Map<String, Object?> _inVenue3D({int revision = 3, String? seatedOn}) {
  final snapshot =
      pickerSnapshot(revision: revision, sections: pickerSections());
  final map = snapshot['map']! as Map<String, Object?>;
  map['buyerView'] = 'venue3d';
  map['view3dTargetSeatId'] = seatedOn;
  return snapshot;
}

void main() {
  testWidgets('a focused section stands on nothing the phone has to clear',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: controller),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), rung: 'overview'));
    await pumpToRest(tester);

    final atOverview = _insetPayloads(map).last! as Map<String, Object?>;
    expect(
      atOverview['top'],
      _badgeBand,
      reason: 'the price rail is a row above the map, so only the test badge '
          'stands on it',
    );
    expect(atOverview['bottom'], 0.0);

    map.emit(
      pickerSnapshot(
        revision: controller.state.revision + 1,
        sections: pickerSections(),
        rung: 'seats',
      ),
    );
    await pumpToRest(tester);

    expect(controller.state.snapshot?.map.rung, 'seats');
    expect(controller.state.snapshot?.map.focusedSectionId, 'section-a');
    final focused = _insetPayloads(map).last! as Map<String, Object?>;
    expect(
      focused['bottom'],
      0.0,
      reason: 'the phone mounts no dock, so the map keeps its own bottom edge',
    );
    expect(focused['top'], _badgeBand);
  });

  testWidgets('a dock the host asked for is reported as covering the map',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        controller: controller,
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(showDockBar: true),
        ),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), rung: 'overview'));
    await pumpToRest(tester);
    expect((_insetPayloads(map).last! as Map<String, Object?>)['bottom'], 0.0);

    map.emit(
      pickerSnapshot(
        revision: controller.state.revision + 1,
        sections: pickerSections(),
        rung: 'seats',
      ),
    );
    await pumpToRest(tester);

    final focused = _insetPayloads(map).last! as Map<String, Object?>;
    expect(
      focused['bottom'],
      greaterThan(0),
      reason: 'the dock now stands on the bottom of the map',
    );
  });

  testWidgets('a settled layout stops reporting', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);
    final settled = _insetPayloads(map).length;

    // Several rebuilds carrying the same chrome. Each would otherwise mint its
    // own command and its own map revision.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(_insetPayloads(map).length, settled);
  });

  testWidgets('a runtime that never advertised the capability is left alone',
      (tester) async {
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>['native-chrome-contract-v1'],
        commands: const <String>['picker.setThemeMode'],
      ),
    );
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);

    expect(map.callsTo('picker.setViewportInsets'), isEmpty);
  });

  testWidgets('a runtime that never handshook is left alone', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);

    expect(map.callsTo('picker.setViewportInsets'), isEmpty);
  });

  testWidgets('chrome the host turned off is not reported as covering the map',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(
            showPriceRail: false,
            showMapControls: false,
            showDockBar: false,
          ),
        ),
      ),
    );
    // A live event, so nothing at all is drawn over the map: the test badge
    // is not one of the chrome switches and would still stand on it.
    map.emit(pickerSnapshot(sections: pickerSections(), testEvent: false));
    await pumpToRest(tester);

    expect(
      _insetPayloads(map).last,
      <String, Object?>{'top': 0.0, 'right': 0.0, 'bottom': 0.0, 'left': 0.0},
    );
  });

  testWidgets('the chrome going away hands the whole surface back',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);
    expect(_insetPayloads(map), isNotEmpty);

    await tester.pumpWidget(pickerHarness(map, const SizedBox.shrink()));
    await pumpToRest(tester);

    expect(_insetPayloads(map).last, <String, Object?>{'insets': null});
  });

  test('the wire form never carries a side the runtime would refuse', () {
    // A mis-measured piece of chrome is a bad number, not a reason to fail the
    // buyer's next action: the runtime answers `bad_payload` for a negative or
    // non-finite side.
    const insets = SeatLayerViewportInsets(
      top: -12,
      right: double.nan,
      bottom: double.infinity,
      left: 8,
    );
    expect(
      insets.toBridgePayload(),
      <String, Object?>{'top': 0.0, 'right': 0.0, 'bottom': 0.0, 'left': 8.0},
    );
  });

  test('what the runtime is framing against is read back off the snapshot', () {
    final snapshot = pickerSnapshot();
    (snapshot['map']! as Map<String, Object?>)['viewportInsets'] =
        <String, Object?>{'top': 46, 'bottom': 268};
    final decoded = SeatLayerPickerSnapshot.fromJson(snapshot)!;

    expect(
      decoded.map.viewportInsets,
      const SeatLayerViewportInsets(top: 46, bottom: 268),
    );
  });

  test('a runtime that reports no insets frames against the whole surface', () {
    expect(
      SeatLayerPickerSnapshot.fromJson(pickerSnapshot())!.map.viewportInsets,
      isNull,
    );
  });

  testWidgets('the immersive scene reports its own chrome, not the map rail',
      (tester) async {
    // In 3D the scene's own furniture takes over: `‹ Back to venue` at the
    // top once a seat is targeted, the seat deck at the bottom. Reporting a
    // band for chrome that is not drawn would crop the venue for nothing.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);
    final onMap = _insetPayloads(map).last! as Map<String, Object?>;

    map.emit(_inVenue3D(revision: 4));
    await pumpToRest(tester);
    final inScene = _insetPayloads(map).last! as Map<String, Object?>;

    expect(inScene, isNot(onMap));
    // Looking around the venue, nothing is drawn in the badge's corner: the
    // way back appears only once the scene is aimed at a seat.
    expect(inScene['top'], _badgeBand);
    // 10 + the dock + the seat deck, which has a caption once the buyer is
    // sitting somewhere.
    expect(
      inScene['bottom'],
      greaterThan(onMap['bottom']! as double),
      reason: 'the seat deck stands on more of the map than the dock alone',
    );
  });

  testWidgets('the seat deck grows a caption and reports the taller band',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: controller),
    );
    map.emit(
      _inVenue3D(revision: controller.state.revision + 1),
    );
    await pumpToRest(tester);
    final looking = _insetPayloads(map).last! as Map<String, Object?>;

    map.emit(
      _inVenue3D(
        revision: controller.state.revision + 1,
        seatedOn: 'seat-a-1',
      ),
    );
    await pumpToRest(tester);
    expect(controller.state.snapshot?.map.view3DTargetSeatId, 'seat-a-1');
    final seated = _insetPayloads(map).last! as Map<String, Object?>;

    expect(
      looking['top'],
      _badgeBand,
      reason: 'nothing is drawn above the badge while looking around',
    );
    expect(
      seated['top'],
      _seatedBadgeBand,
      reason: 'the badge steps below `Back to venue` once it is drawn',
    );
    expect(
      seated['bottom']! as double,
      (looking['bottom']! as double) +
          SeatLayerVenue3D.captionChipHeight +
          SeatLayerVenue3D.captionGap,
      reason: 'the caption chip plus its gap',
    );
  });
}
