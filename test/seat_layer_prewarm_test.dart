// Opening the picker spends a WebView process start and a document fetch
// before the runtime has said a word. Measured on the Reference app pilot that is
// most of the wait — and all of it can happen while the buyer is still
// reading the event page. `SeatLayerPicker.prewarm()` is that head start.
//
// The load-bearing part is not the load: it is that a page with no view yet
// still emits its bridge `hello`, and nothing is listening. The warm page
// buffers it and the claiming view replays it, so a picker that mounts onto a
// page which has already finished loading still completes its handshake.
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';
import 'package:seatlayer/src/seat_layer_prewarm.dart';
import 'package:seatlayer/src/seat_layer_view.dart';

import 'fake_webview_platform.dart';

/// What the runtime says the moment it boots, before anyone has asked.
String _hello() => const Envelope(
      kind: EnvelopeKind.hello,
      type: 'hello',
      payload: <String, Object?>{
        'bundle': '0.71.3',
        'protocol': <String, Object?>{'min': 1, 'max': 1},
        'events': <String>['sys.ready'],
        'commands': <String>[],
      },
    ).encode();

String _ready() => const Envelope(
      kind: EnvelopeKind.evt,
      type: 'sys.ready',
      sequence: 1,
      payload: <String, Object?>{
        'protocol': 1,
        'mode': 'test',
        'transport': 'flutter',
        'chart': <String, Object?>{'event': 'ev_test'},
      },
    ).encode();

Widget _view(
  SeatLayerController controller, {
  String? assetPath,
  void Function(ReadyInfo info)? onReady,
}) =>
    MaterialApp(
      home: SizedBox(
        width: 320,
        height: 480,
        child: SeatLayerView(
          controller: controller,
          onReady: onReady,
          configuration: SeatLayerConfiguration(
            event: 'ev_test',
            assetPath: assetPath ?? SeatLayerConfiguration.defaultAssetPath,
          ),
        ),
      ),
    );

void main() {
  setUp(SeatLayerRuntimePrewarm.resetForTesting);
  tearDown(SeatLayerRuntimePrewarm.resetForTesting);

  testWidgets('a prewarm loads the runtime page with no view and no event',
      (tester) async {
    final fake = useFakeWebViewPlatform();

    SeatLayerPicker.prewarm();
    await tester.pump();

    expect(fake.controllersCreated, 1);
    expect(fake.loads, <String>[SeatLayerConfiguration.defaultAssetPath]);

    // The TTL timer is real; a test may not walk away leaving it pending.
    SeatLayerRuntimePrewarm.discardAll();
  });

  testWidgets('a second prewarm is a no-op, not a second WebView',
      (tester) async {
    final fake = useFakeWebViewPlatform();

    SeatLayerPicker.prewarm();
    SeatLayerPicker.prewarm();
    await tester.pump();

    expect(fake.controllersCreated, 1);
    expect(fake.loads, hasLength(1));

    SeatLayerRuntimePrewarm.discardAll();
  });

  testWidgets('a view mounts onto the warm page instead of starting its own',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    SeatLayerPicker.prewarm();
    await tester.pump();

    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_view(controller));
    await tester.pump();

    // The saving in one line: no second process start, no second fetch.
    expect(fake.controllersCreated, 1);
    expect(fake.loads, hasLength(1));
    expect(SeatLayerRuntimePrewarm.warmUrls, isEmpty);
  });

  testWidgets('the hello the page said before the view existed is replayed',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    SeatLayerPicker.prewarm();
    await tester.pump();

    // The page finishes loading and greets an empty room.
    fake.postFromPage(_hello());

    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    ReadyInfo? ready;

    await tester.pumpWidget(
      _view(controller, onReady: (info) => ready = info),
    );
    await tester.pump();

    // Replayed on adoption, so the runtime is told to init exactly as if the
    // view had been there all along.
    fake.postFromPage(_ready());
    await tester.pump();
    await tester.pump();

    expect(ready, isNotNull, reason: 'the buffered hello was dropped');
  });

  testWidgets('a page the buyer left sitting is re-loaded, not adopted stale',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    SeatLayerPicker.prewarm();
    await tester.pump();
    fake.postFromPage(_hello());

    // The buyer read the event page for a minute. The runtime's own clock
    // started when the document loaded and it gives up on the host after ten
    // seconds, so a page adopted now would already have errored.
    final loaded = SeatLayerRuntimePrewarm.now();
    SeatLayerRuntimePrewarm.now =
        () => loaded.add(const Duration(minutes: 1));

    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_view(controller));
    await tester.pump();

    // The WebView — the expensive half — is still the warm one.
    expect(fake.controllersCreated, 1);
    // …but the document is requested again, which is a cache hit.
    expect(fake.loads, hasLength(2));
    expect(fake.loads.last, SeatLayerConfiguration.defaultAssetPath);
  });

  testWidgets('a page nobody claimed is thrown away when its time is up',
      (tester) async {
    final fake = useFakeWebViewPlatform();

    fakeAsync((async) {
      SeatLayerPicker.prewarm(ttl: const Duration(minutes: 5));
      expect(SeatLayerRuntimePrewarm.warmUrls, hasLength(1));
      async.elapse(const Duration(minutes: 5, seconds: 1));
      expect(SeatLayerRuntimePrewarm.warmUrls, isEmpty);
    });

    // …and a picker opened afterwards simply starts its own page.
    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_view(controller));
    await tester.pump();

    expect(fake.controllersCreated, 2);
  });

  testWidgets('memory pressure drops every unclaimed page', (tester) async {
    useFakeWebViewPlatform();
    SeatLayerPicker.prewarm();
    await tester.pump();
    expect(SeatLayerRuntimePrewarm.warmUrls, hasLength(1));

    // A convenience must never be what gets the host application killed.
    tester.binding.handleMemoryPressure();
    await tester.pump();

    expect(SeatLayerRuntimePrewarm.warmUrls, isEmpty);
  });

  testWidgets('a view on a different document ignores the warm page',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    SeatLayerPicker.prewarm();
    await tester.pump();

    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _view(controller, assetPath: 'assets/offline-fixture.html'),
    );
    await tester.pump();

    expect(fake.controllersCreated, 2);
    expect(fake.loads.last, 'assets/offline-fixture.html');
    expect(SeatLayerRuntimePrewarm.warmUrls, hasLength(1));

    SeatLayerRuntimePrewarm.discardAll();
  });

  testWidgets('a bundled fixture is not worth prewarming', (tester) async {
    final fake = useFakeWebViewPlatform();

    SeatLayerPicker.prewarm(
      configuration: SeatLayerConfiguration(
        event: 'ev_test',
        assetPath: 'assets/offline-fixture.html',
      ),
    );
    await tester.pump();

    expect(fake.controllersCreated, 0);
    expect(SeatLayerRuntimePrewarm.warmUrls, isEmpty);
  });

  testWidgets('cancelPrewarm gives the page back', (tester) async {
    useFakeWebViewPlatform();
    SeatLayerPicker.prewarm();
    await tester.pump();

    SeatLayerPicker.cancelPrewarm();
    expect(SeatLayerRuntimePrewarm.warmUrls, isEmpty);
  });
}
