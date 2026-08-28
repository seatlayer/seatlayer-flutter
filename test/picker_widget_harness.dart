import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/payloads.dart';
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

  /// The snapshot this fake currently reports.
  Map<String, Object?> current = pickerSnapshot();

  @override
  Stream<EventSignal> get onBridgeEvent => _events.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async {
    calls.add((command, payload));
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

  /// Commands whose name is [command].
  Iterable<(String, Object?)> callsTo(String command) =>
      calls.where((call) => call.$1 == command);

  @override
  void dispose() {
    unawaited(_events.close());
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
}) {
  final picker = controller ?? SeatLayerPickerController(mapController: map);
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

/// Size the test surface to one phone screen at device pixel ratio 1.
///
/// Ratio 1 keeps a golden's pixels equal to its logical points, so a diff is
/// read in the same units the specification is written in.
void usePhoneSurface(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = phoneSize;
  addTearDown(tester.view.reset);
}

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
