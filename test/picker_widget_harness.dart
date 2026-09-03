import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_buyer_asset_loader.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';

import 'picker_test_fixture.dart';

/// The phone the goldens are taken on: iPhone 14/15/16 logical size.
const Size phoneSize = Size(390, 844);

/// What a runtime speaking the whole native-chrome contract advertises.
///
/// Only the parts the SDK gates on; the real `hello` carries more.
BundleInfo nativeChromeBundle({
  List<String> capabilities = const <String>[
    'native-chrome-contract-v1',
    'viewport-insets-v1',
  ],
  List<String> commands = const <String>[
    'picker.setThemeMode',
    'picker.setViewportInsets',
  ],
}) =>
    BundleInfo(
      bundle: 'seatlayer-js@0.71.2',
      protocolRange: const ProtocolRange(min: 1, max: 2),
      capabilities: capabilities,
      events: const <String>['picker.snapshot'],
      commands: commands,
    );

/// A runtime that also speaks `availability-refresh-v1` and `access-needs-v1`.
///
/// [holdSelection] is the third capability, split out because an older runtime
/// that can refresh but cannot hold a selection on its own is a real shape the
/// recovery action has to degrade to.
BundleInfo refreshingBundle({bool holdSelection = true}) => nativeChromeBundle(
      capabilities: <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'availability-refresh-v1',
        'access-needs-v1',
        if (holdSelection) 'hold-selection-v1',
      ],
      commands: <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.refreshAvailability',
        if (holdSelection) 'picker.holdSelection',
      ],
    );

/// A runtime that also reports authored seat-view thumbnails.
///
/// The seat-view fields on `selection[]` are gated on this capability, so a
/// fixture that carries them still shows nothing without it.
BundleInfo thumbnailBundle() => nativeChromeBundle(
      capabilities: <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'seat-view-thumbnail-v1',
      ],
    );

/// A runtime that flies for an accessibility filter and counts per section.
///
/// The two capabilities are separate on the wire and are separable here: a
/// runtime can answer the tour without reporting counts, and chrome that
/// assumed the pair would draw a `0` for a section nobody counted.
BundleInfo accessibilityFocusBundle({
  bool focus = true,
  bool counts = true,
}) =>
    nativeChromeBundle(
      capabilities: <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'access-needs-v1',
        'colorblind-safe',
        if (focus) 'accessibility-focus-v1',
        if (counts) 'section-access-counts-v1',
      ],
      commands: <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setAccessibilityFilter',
        'picker.setColorblindSafe',
        if (focus) ...<String>[
          'picker.focusAccessibilityFilter',
          'picker.focusNextAccessibleSection',
        ],
      ],
    );

/// A map controller that answers every bridge command from a local snapshot.
final class FakePickerMap extends SeatLayerController {
  /// Creates a fake runtime, optionally with a custom command [handler].
  FakePickerMap({this.handler, this.bundle});

  /// Replaces the default "echo a bumped snapshot" reply.
  final Future<Object?> Function(String command, Object? payload)? handler;

  /// What this fake runtime advertised in `hello`.
  ///
  /// Null is a runtime that never handshook, which is what most component
  /// tests want: capability-gated commands are withheld from it.
  final BundleInfo? bundle;

  @override
  BundleInfo? get bundleInfo => bundle;

  /// Every command the picker sent, in order.
  final List<(String, Object?)> calls = <(String, Object?)>[];

  final StreamController<EventSignal> _events =
      StreamController<EventSignal>.broadcast();

  final StreamController<ReadyInfo> _ready =
      StreamController<ReadyInfo>.broadcast();

  @override
  Stream<ReadyInfo> get onReady => _ready.stream;

  /// Report a finished handshake, as [SeatLayerView] would.
  void emitReady(ReadyInfo info) => _ready.add(info);

  /// The snapshot this fake currently reports.
  Map<String, Object?> current = pickerSnapshot();

  /// The revision [current] is at, so a test can move the snapshot on without
  /// stepping behind the controller.
  int get revision => current['revision']! as int;

  final Map<String, Completer<void>> _gates = <String, Completer<void>>{};

  /// Commands that answer with a failure rather than a snapshot.
  ///
  /// A removal that the server refuses is the ordinary race — the seat was
  /// taken between the pick and the press — and the chrome owes the row back.
  final Set<String> failing = <String>{};

  /// Hold [command] open until [gate] completes.
  ///
  /// The slow commands are the interesting ones: `picker.removeCartLine`
  /// re-holds the rest of the cart on the server before it answers, and the
  /// chrome that covers that window can only be tested from inside it. A fake
  /// that replies on the next microtask has already left it.
  ///
  /// A test that means to answer with a *changed* cart sets [current] to the
  /// snapshot it wants before releasing the gate.
  void gate(String command, Completer<void> gate) => _gates[command] = gate;

  @override
  Stream<EventSignal> get onBridgeEvent => _events.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async {
    calls.add((command, payload));
    final held = _gates[command];
    if (held != null) await held.future;
    if (failing.contains(command)) {
      throw StateError('$command was refused');
    }
    if (handler != null) return handler!(command, payload);
    current = <String, Object?>{
      ...current,
      'revision': (current['revision']! as int) + 1,
    };
    return <String, Object?>{
      'revision': current['revision'],
      'snapshot': current
    };
  }

  /// Push [snapshot] as if the runtime had emitted it.
  void emit(Map<String, Object?> snapshot) {
    current = snapshot;
    _events.add(
      EventSignal(name: 'picker.snapshot', payload: snapshot, sequence: 1),
    );
  }

  final StreamController<SelectedObjectUnavailableEvent> _conflicts =
      StreamController<SelectedObjectUnavailableEvent>.broadcast();

  @override
  Stream<SelectedObjectUnavailableEvent> get onSelectedObjectsUnavailable =>
      _conflicts.stream;

  /// Report [labels] as taken by another buyer.
  ///
  /// A conflict does not arrive as a snapshot — it is the runtime interrupting
  /// with news about seats the buyer already had — so it has its own entry
  /// point here rather than riding on [emit].
  void emitConflict(List<String> labels) => _conflicts.add(
        SelectedObjectUnavailableEvent(
          labels: labels,
          reason: const SelectedObjectUnavailableReason('taken'),
        ),
      );

  /// Push one arbitrary bridge event, for the surfaces that are not snapshots.
  void emitEvent(String name, Object? payload, {int sequence = 1}) => _events
      .add(EventSignal(name: name, payload: payload, sequence: sequence));

  /// Commands whose name is [command].
  Iterable<(String, Object?)> callsTo(String command) =>
      calls.where((call) => call.$1 == command);

  @override
  void dispose() {
    unawaited(_events.close());
    unawaited(_ready.close());
    unawaited(_conflicts.close());
    super.dispose();
  }
}

/// Wrap [child] in the ambient tree every picker component expects.
Widget pickerHarness(
  FakePickerMap map,
  Widget child, {
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  SeatLayerPickerThemeData? theme,
  SeatLayerThemeMode themeMode = SeatLayerThemeMode.auto,
  SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
  Brightness platformBrightness = Brightness.light,
  SeatLayerPickerController? controller,
  SeatLayerBuyerAssetLoader? assetLoader,
}) {
  final picker = controller ?? SeatLayerPickerController(mapController: map);
  // Installed before the scope attaches, which leaves an already-bound loader
  // for the same event alone.
  if (assetLoader != null) picker.assetLoader = assetLoader;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    // The harness models the ordinary case: an application that follows the
    // device. `auto` asks the HOST theme first — that is the switch a buyer
    // actually moves — so a test that only flipped `platformBrightness` here
    // would be describing an app that had pinned itself to light.
    theme: ThemeData(brightness: platformBrightness),
    // MaterialApp cross-fades a theme change over 200ms. A test that pumps
    // one frame after a flip would read the halfway theme.
    themeAnimationDuration: Duration.zero,
    builder: (context, inner) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        platformBrightness: platformBrightness,
      ),
      child: inner!,
    ),
    home: Scaffold(
      body: SeatLayerPickerScope(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        controller: picker,
        options: options,
        theme: theme,
        themeMode: themeMode,
        callbacks: callbacks,
        child: child,
      ),
    ),
  );
}

/// A loader whose fetch never answers: the photo strip stays on its neutral
/// gradient, which is what the card looked like before photographs arrived.
SeatLayerBuyerAssetLoader pendingAssetLoader() => SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'test-bearer'),
      fetch: (uri, headers) => Completer<Uint8List>().future,
    );

/// A loader that answers every reference with [bytes], and counts the asks.
SeatLayerBuyerAssetLoader photoAssetLoader(
  Uint8List bytes, {
  List<Uri>? requested,
}) =>
    SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'test-bearer'),
      fetch: (uri, headers) async {
        requested?.add(uri);
        return bytes;
      },
    );

/// A loader that answers every reference with nothing, as a 403 would.
SeatLayerBuyerAssetLoader missingAssetLoader() => SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'test-bearer'),
      fetch: (uri, headers) => throw StateError('403'),
    );

/// A [size]-square PNG, painted here so no photograph is checked in.
Future<Uint8List> tinyPng(
    {int size = 4, Color color = const Color(0xFF3366CC)}) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..color = color,
  );
  final image = await recorder.endRecording().toImage(size, size);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Size the test surface to one phone screen at device pixel ratio 1.
///
/// Ratio 1 keeps a golden's pixels equal to its logical points, so a diff is
/// read in the same units the specification is written in.
void usePhoneSurface(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = phoneSize;
  addTearDown(tester.view.reset);
}

/// Wait for everything on screen except an animation that never ends.
///
/// `pumpAndSettle` cannot be used while the confirm card is up. The card
/// breathes under `Add seat` for as long as the buyer leaves it unanswered, so
/// a settle pumps frames until the harness gives up rather than until the
/// interface is still. This pumps a bounded sequence instead, and lands on the
/// frame the breathing starts from: the arrival highlight has finished
/// crossing the button, and the button is at exactly its resting size.
Future<void> pumpToRest(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(pickerRestDelay);
}

/// How long past the first frame [pumpToRest] lands.
///
/// The confirm card's own `inviteBreatheDelay`: long enough for every arrival
/// in the picker, and the one instant after it at which the breath is at zero.
const Duration pickerRestDelay = Duration(milliseconds: 1000);

/// Identifies the subtree a golden is taken of.
const Key goldenSubjectKey = ValueKey<String>('seatlayer-golden-subject');

/// Give [child] its own layer so a golden captures it and nothing else.
///
/// Without this the nearest repaint boundary is the whole test surface, and
/// every golden would be a picture of one widget floating on an empty screen.
Widget goldenSubject(Widget child) =>
    RepaintBoundary(key: goldenSubjectKey, child: child);

/// The tag every golden test carries, so one CI job can select exactly them.
const String goldenTag = 'golden';

/// Why this host does not compare goldens — `null` on macOS, which does.
///
/// Fonts were the first half of the cross-host problem and are fixed for good
/// in `test/flutter_test_config.dart`: Roboto and Material Icons are now loaded
/// from pinned bytes, so every host lays out the same glyphs in the same
/// places. The second half cannot be fixed the same way. Skia rasterises those
/// glyphs through the host's own text backend — CoreText on macOS, FreeType on
/// Linux — and the two disagree on the anti-aliased edge of every letter. The
/// residue is 2-5% of pixels per image, all of it one pixel deep around glyph
/// outlines, with nothing structural left. Loosening the comparator far enough
/// to swallow that would also swallow a real regression, so instead the goldens
/// are recorded on macOS and enforced on macOS, by the `goldens` job in
/// `.github/workflows/ci.yml`. Every other check still runs everywhere.
final Object? goldenSkip = Platform.isMacOS
    ? null
    : 'Goldens are recorded and enforced on macOS (the `goldens` CI job); '
        'this host rasterises glyph edges differently.';

/// Compare the [goldenSubject] on screen against `test/goldens/<name>.png`.
Future<void> expectGolden(WidgetTester tester, String name) => expectLater(
      find.byKey(goldenSubjectKey),
      matchesGoldenFile('goldens/$name.png'),
    );
