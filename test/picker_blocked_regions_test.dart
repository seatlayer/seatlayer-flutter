// Native chrome over the map is reported to the runtime as rectangles a tap
// must never fall through.
//
// On iOS a tap on a control drawn over the map WebView reaches the WebView as
// well, whatever the platform-view gesture boundary decides, and only a guard
// standing BEFORE the finger lands works. So the chrome standing on the map
// tells the runtime where it is — once per layout, the whole list, replaced
// on every send — and a runtime that never advertised the command is never
// told anything.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_blocked_regions.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// The rectangles of every regions command the picker sent, in order.
List<List<SeatLayerBlockedRegion>> _sent(FakePickerMap map) => map
    .callsTo(seatLayerBlockedRegionsCommand)
    .map(
      (call) => ((call.$2! as Map<String, Object?>)['rects']! as List<Object?>)
          .map((raw) {
        final rect = raw! as Map<String, Object?>;
        return SeatLayerBlockedRegion(
          x: rect['x']! as double,
          y: rect['y']! as double,
          w: rect['w']! as double,
          h: rect['h']! as double,
        );
      }).toList(),
    )
    .toList();

BundleInfo _bundle() => nativeChromeBundle(
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setBlockedRegions',
      ],
    );

bool _contains(SeatLayerBlockedRegion r, Offset p) =>
    p.dx >= r.x && p.dx <= r.x + r.w && p.dy >= r.y && p.dy <= r.y + r.h;

void main() {
  testWidgets('every corner control is reported in the map’s own coordinates',
      (tester) async {
    final map = FakePickerMap(bundle: _bundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await pumpToRest(tester);

    final reports = _sent(map);
    expect(reports, isNotEmpty);
    final rects = reports.last;
    expect(rects, isNotEmpty);

    // The `−` disc, the accessibility disc and the Map/3D control each sit
    // inside one reported rectangle, measured from the map surface's corner.
    final mapOrigin = tester.getTopLeft(find.byType(SeatLayerPickerMap));
    for (final control in <Finder>[
      find.byType(SeatLayerPickerZoomOutButton),
      find.byType(SeatLayerPickerViewModeControl),
    ]) {
      expect(control, findsOneWidget);
      final centre = tester.getCenter(control) - mapOrigin;
      expect(
        rects.any((r) => _contains(r, centre)),
        isTrue,
        reason: 'no reported rectangle covers $control at $centre in $rects',
      );
    }
    // And nothing reported lies outside the map.
    final mapSize = tester.getSize(find.byType(SeatLayerPickerMap));
    for (final r in rects) {
      expect(r.x, greaterThanOrEqualTo(-1));
      expect(r.y, greaterThanOrEqualTo(-1));
      expect(r.x + r.w, lessThanOrEqualTo(mapSize.width + 1));
      expect(r.y + r.h, lessThanOrEqualTo(mapSize.height + 1));
    }
  });

  testWidgets('the same layout is not reported twice', (tester) async {
    final map = FakePickerMap(bundle: _bundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await pumpToRest(tester);
    final before = _sent(map).length;

    // Frames pass, the chrome does not move: nothing more is sent.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(_sent(map).length, before);
  });

  testWidgets('a runtime that does not advertise the command is never told',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await pumpToRest(tester);

    expect(map.callsTo(seatLayerBlockedRegionsCommand), isEmpty);
    expect(picker.state.error, isNull);
  });

  testWidgets('the layout going away clears the guard', (tester) async {
    final map = FakePickerMap(bundle: _bundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await pumpToRest(tester);
    expect(_sent(map).last, isNotEmpty);

    await tester
        .pumpWidget(pickerHarness(map, const SizedBox(), controller: picker));
    await pumpToRest(tester);
    expect(_sent(map).last, isEmpty);
  });

  // The seat card's own buttons stand on the map too, and the Add button
  // takes the card away with the very tap that has to be guarded — the late
  // touch lands ~134 ms after the shell handled it.
  testWidgets(
      'a raised seat card is a region, and stays one for a moment after it leaves',
      (tester) async {
    final map = FakePickerMap(bundle: _bundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await pumpToRest(tester);
    final bare = _sent(map).last;

    map.emit(pickerSnapshot(revision: 2, sections: pickerSections()));
    await pumpToRest(tester);
    final withCard = _sent(map).last;
    expect(withCard.length, greaterThan(bare.length));
    final mapSize = tester.getSize(find.byType(SeatLayerPickerMap));
    // The prompt layer fills the map: the whole band is guarded while a
    // decision is open.
    expect(
      withCard
          .any((r) => r.w >= mapSize.width - 1 && r.h >= mapSize.height - 1),
      isTrue,
    );

    await tester.tap(find.text('Add seat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Still guarded: the linger has not elapsed.
    expect(_sent(map).last.length, withCard.length);

    await tester.pump(SeatLayerBlockedRegionRegistry.defaultLinger);
    await pumpToRest(tester);
    expect(_sent(map).last.length, bare.length);
  });

  // The card's rectangle lingers on a timer, and a timer fires between
  // frames. A report that only rode a post-frame callback would wait for a
  // frame an idle app never draws, and the runtime would keep guarding a
  // whole map whose card had long gone.
  testWidgets('a report made outside a frame asks for one', (tester) async {
    final sent = <List<SeatLayerBlockedRegion>>[];
    final report = PickerBlockedRegionsReport(
      send: (rects) async => sent.add(rects),
      equals: seatLayerBlockedRegionsEqual,
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.hasScheduledFrame, isFalse);
    unawaited(report.report(const <SeatLayerBlockedRegion>[]));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump();
    expect(sent, hasLength(1));
  });

  test('a region floors what the runtime would refuse', () {
    final r =
        SeatLayerBlockedRegion(x: 1, y: double.nan, w: -3, h: double.infinity);
    expect(r.toBridgePayload(),
        <String, Object?>{'x': 1.0, 'y': 0.0, 'w': 0.0, 'h': 0.0});
    expect(
      seatLayerBlockedRegionsEqual(
        [SeatLayerBlockedRegion(x: 1, y: 2, w: 3, h: 4)],
        [SeatLayerBlockedRegion(x: 1, y: 2, w: 3, h: 4)],
      ),
      isTrue,
    );
    expect(
      seatLayerBlockedRegionsEqual(
        [SeatLayerBlockedRegion(x: 1, y: 2, w: 3, h: 4)],
        [SeatLayerBlockedRegion(x: 1, y: 2, w: 3, h: 5)],
      ),
      isFalse,
    );
  });

  test('the registry replaces, forgets and folds one pass into one report',
      () async {
    final reports = <List<SeatLayerBlockedRegion>>[];
    final registry = SeatLayerBlockedRegionRegistry(
      report: reports.add,
      linger: Duration.zero,
    );
    final a = Object();
    final b = Object();
    registry
      ..set(a, SeatLayerBlockedRegion(x: 0, y: 0, w: 1, h: 1))
      ..set(b, SeatLayerBlockedRegion(x: 5, y: 5, w: 1, h: 1));
    await Future<void>.delayed(Duration.zero);
    expect(reports, hasLength(1));
    expect(reports.single, hasLength(2));

    // Unchanged: nothing.
    registry.set(a, SeatLayerBlockedRegion(x: 0, y: 0, w: 1, h: 1));
    await Future<void>.delayed(Duration.zero);
    expect(reports, hasLength(1));

    registry.detach(b);
    await Future<void>.delayed(Duration.zero);
    expect(reports.last, hasLength(1));
    registry.set(a, null);
    await Future<void>.delayed(Duration.zero);
    expect(reports.last, isEmpty);
  });
}
