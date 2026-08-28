// The runtime can only see what happens after its own document exists, and the
// app can only see up to the moment the runtime says it is ready. `evt
// telemetry.chartLoad` is the runtime's half; this is where the two are joined
// so a host gets one number covering the whole open.
//
// Capability-gated on the way in: a runtime that has not advertised
// `chart-load-trace-v1` is not read for it, whatever is on the wire.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_chart_load.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The trace the pilot's iOS Simulator produced, verbatim from the contract.
Map<String, Object?> _trace({Map<String, Object?> overrides = const {}}) =>
    <String, Object?>{
      'event': 'ev_reference',
      'scope': 'event',
      'surface': 'seating_chart',
      'outcome': 'success',
      'stage': '',
      'ms': 800,
      'api': 569,
      'scene': 128,
      'panel': 0,
      'paint': 40,
      'normalize': 26,
      'renderer': 11,
      'availabilityMs': 563,
      'seats': 3628,
      'floors': 2,
      'view': 'map',
      'load': 'cold',
      'transport': 'pubapi',
      'chartBytes': 184320,
      'chartCache': 'hit',
      'server': 41,
      'r2Head': 7,
      'cacheLookup': 3,
      'r2Get': 0,
      'transform': 12,
      'host': 'webview',
      'platform': 'flutter',
      'bundle': '0.71.3',
      'protocol': 2,
      'chromeOwner': 'native',
      'bootMs': 1018,
      'documentMs': 212,
      'handshakeMs': 1,
      ...overrides,
    };

BundleInfo _tracingBundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'chart-load-trace-v1',
      ],
    );

/// Mount a picker on [map] and hand back what its `onChartLoad` callback saw.
Future<List<SeatLayerChartLoad>> _pump(
  WidgetTester tester,
  FakePickerMap map,
) async {
  final seen = <SeatLayerChartLoad>[];
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      const SizedBox.shrink(),
      callbacks: SeatLayerPickerCallbacks(onChartLoad: seen.add),
    ),
  );
  return seen;
}

void main() {
  group('the trace itself', () {
    test('every documented field is read', () {
      final trace = SeatLayerChartLoadTrace.fromJson(_trace())!;

      expect(trace.event, 'ev_reference');
      expect(trace.outcome, 'success');
      expect(trace.succeeded, isTrue);
      expect(trace.ms, 800);
      expect(trace.availabilityMs, 563);
      expect(trace.seats, 3628);
      expect(trace.floors, 2);
      expect(trace.chartBytes, 184320);
      expect(trace.chartCache, 'hit');
      // The five host fields, which are the reason this beacon reaches us.
      expect(trace.host, 'webview');
      expect(trace.platform, 'flutter');
      expect(trace.bundle, '0.71.3');
      expect(trace.protocol, 2);
      expect(trace.chromeOwner, 'native');
      // The three document-relative spans.
      expect(trace.bootMs, 1018);
      expect(trace.documentMs, 212);
      expect(trace.handshakeMs, 1);
    });

    test('a field this release has never heard of survives on raw', () {
      final trace = SeatLayerChartLoadTrace.fromJson(
        _trace(overrides: <String, Object?>{'tilesMs': 44}),
      )!;

      // Tolerated, not dropped: a host must not have to wait for an SDK
      // release to read a number the runtime already sends.
      expect(trace.raw['tilesMs'], 44);
      expect(trace.bootMs, 1018);
    });

    test('an integral double reads as an int, the way every number does', () {
      final trace = SeatLayerChartLoadTrace.fromJson(
        _trace(overrides: <String, Object?>{'bootMs': 1018.0}),
      )!;

      expect(trace.bootMs, 1018);
    });

    test('a payload that is not an object is not a trace', () {
      expect(SeatLayerChartLoadTrace.fromJson(null), isNull);
      expect(SeatLayerChartLoadTrace.fromJson('boot'), isNull);
      expect(SeatLayerChartLoadTrace.fromJson(<Object?>[]), isNull);
    });

    test('a failed attempt still decodes, and says where it stopped', () {
      final trace = SeatLayerChartLoadTrace.fromJson(
        _trace(overrides: <String, Object?>{
          'outcome': 'error',
          'stage': 'api',
        }),
      )!;

      expect(trace.succeeded, isFalse);
      expect(trace.stage, 'api');
    });
  });

  group('the merge', () {
    test('hostMs is everything outside the page', () {
      const load = SeatLayerChartLoad(
        trace: SeatLayerChartLoadTrace(bootMs: 1018),
        tapToReadyMs: 3513,
      );

      expect(load.hostMs, 2495);
    });

    test('two clocks started by two processes never report a negative span',
        () {
      const load = SeatLayerChartLoad(
        trace: SeatLayerChartLoadTrace(bootMs: 1020),
        tapToReadyMs: 1018,
      );

      expect(load.hostMs, 0);
    });

    test('no page span, no host span', () {
      const load = SeatLayerChartLoad(
        trace: SeatLayerChartLoadTrace(),
        tapToReadyMs: 3513,
      );

      expect(load.hostMs, isNull);
    });
  });

  group('over the bridge', () {
    testWidgets('a tracing runtime reports one load per render attempt',
        (tester) async {
      final map = FakePickerMap(bundle: _tracingBundle());
      addTearDown(map.dispose);
      final seen = await _pump(tester, map);

      map.emitReady(
        const ReadyInfo(
          protocolRevision: 2,
          mode: EventMode.test,
          transport: TransportName.flutter,
          eventKey: 'ev_reference',
          timeToReadyMs: 1082,
        ),
      );
      map.emitEvent(
        'telemetry.chartLoad',
        <String, Object?>{'trace': _trace()},
      );
      await tester.pump();

      expect(seen, hasLength(1));
      expect(seen.single.trace.bundle, '0.71.3');
      // The SDK's own span, measured from the mount rather than from the
      // handshake — so it exists even though the page reported its own.
      expect(seen.single.tapToReadyMs, isNotNull);
      expect(seen.single.tapToReadyMs, greaterThanOrEqualTo(0));
      // And the handshake travels with it, so a host has both spans at once.
      expect(seen.single.ready?.timeToReadyMs, 1082);
      expect(seen.single.ready?.eventKey, 'ev_reference');
    });

    testWidgets('a runtime that never said it traces is never read for one',
        (tester) async {
      // The capability is the whole gate: this bundle speaks the rest of the
      // native-chrome contract and still must produce nothing here.
      final map = FakePickerMap(bundle: nativeChromeBundle());
      addTearDown(map.dispose);
      final seen = await _pump(tester, map);

      map.emitEvent(
        'telemetry.chartLoad',
        <String, Object?>{'trace': _trace()},
      );
      await tester.pump();

      expect(seen, isEmpty);
    });

    testWidgets('and neither is a runtime that never handshook', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final seen = await _pump(tester, map);

      map.emitEvent(
        'telemetry.chartLoad',
        <String, Object?>{'trace': _trace()},
      );
      await tester.pump();

      expect(seen, isEmpty);
    });

    testWidgets('a failed load arrives with no ready span at all',
        (tester) async {
      final map = FakePickerMap(bundle: _tracingBundle());
      addTearDown(map.dispose);
      final seen = await _pump(tester, map);

      map.emitEvent(
        'telemetry.chartLoad',
        <String, Object?>{
          'trace': _trace(
            overrides: <String, Object?>{'outcome': 'error', 'stage': 'api'},
          ),
        },
      );
      await tester.pump();

      expect(seen, hasLength(1));
      expect(seen.single.trace.succeeded, isFalse);
      expect(seen.single.tapToReadyMs, isNull);
      expect(seen.single.ready, isNull);
    });

    testWidgets('a trace with no trace object is not a load', (tester) async {
      final map = FakePickerMap(bundle: _tracingBundle());
      addTearDown(map.dispose);
      final seen = await _pump(tester, map);

      map.emitEvent('telemetry.chartLoad', <String, Object?>{'trace': null});
      await tester.pump();

      expect(seen, isEmpty);
    });

    testWidgets('the stream carries the same load the callback does',
        (tester) async {
      final map = FakePickerMap(bundle: _tracingBundle());
      addTearDown(map.dispose);
      final controller = SeatLayerPickerController(mapController: map);
      addTearDown(controller.dispose);
      final streamed = <SeatLayerChartLoad>[];
      final subscription = controller.onChartLoad.listen(streamed.add);
      addTearDown(subscription.cancel);

      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(map, const SizedBox.shrink(), controller: controller),
      );
      map.emitEvent(
        'telemetry.chartLoad',
        <String, Object?>{'trace': _trace()},
      );
      await tester.pump();

      expect(streamed, hasLength(1));
      expect(streamed.single.trace.platform, 'flutter');
    });

    testWidgets('a snapshot is never mistaken for a trace', (tester) async {
      final map = FakePickerMap(bundle: _tracingBundle());
      addTearDown(map.dispose);
      final seen = await _pump(tester, map);

      map.emit(pickerSnapshot());
      await tester.pump();

      expect(seen, isEmpty);
    });
  });
}
