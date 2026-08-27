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

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Iterable<Object?> _insetPayloads(FakePickerMap map) =>
    map.callsTo('picker.setViewportInsets').map((call) => call.$2);

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

void main() {
  testWidgets('the dock arriving changes what the runtime frames against',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections(), rung: 'overview'));
    await tester.pumpAndSettle();

    final atOverview = _insetPayloads(map).last! as Map<String, Object?>;
    expect(atOverview['top'], 44.0, reason: 'the price rail caps the map');
    expect(
      atOverview['bottom'],
      0.0,
      reason: 'no section is focused, so there is no dock',
    );

    map.emit(
      pickerSnapshot(revision: 2, sections: pickerSections(), rung: 'seats'),
    );
    await tester.pumpAndSettle();

    final focused = _insetPayloads(map).last! as Map<String, Object?>;
    expect(
      focused['bottom'],
      greaterThan(0),
      reason: 'the dock now stands on the bottom of the map',
    );
    expect(focused['top'], 44.0);
  });

  testWidgets('a settled layout stops reporting', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.setViewportInsets'), isEmpty);
  });

  testWidgets('a runtime that never handshook is left alone', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

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
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();
    expect(_insetPayloads(map), isNotEmpty);

    await tester.pumpWidget(pickerHarness(map, const SizedBox.shrink()));
    await tester.pumpAndSettle();

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
}
