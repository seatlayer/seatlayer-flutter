// One load, not two.
//
// The picker used to reveal the map on the first snapshot, which arrives
// before the runtime has been told what the native chrome covers. The buyer
// saw the chart appear at one framing and re-fit a moment later — a spinner,
// then a map that popped in wrong. These tests pin the three parts of the fix:
// the wait for the frame, the placeholder the wait is spent on, and the
// backstop that stops the wait from ever becoming the experience.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerResolvedPickerTheme _theme = SeatLayerResolvedPickerTheme(
  brightness: Brightness.light,
  background: SeatLayerLightTokens.background,
  surface: SeatLayerLightTokens.surface,
  text: SeatLayerLightTokens.text,
  mutedText: SeatLayerLightTokens.mutedText,
  accent: SeatLayerLightTokens.accent,
  onAccent: SeatLayerLightTokens.onAccent,
  divider: SeatLayerLightTokens.divider,
  error: SeatLayerLightTokens.error,
  warning: SeatLayerLightTokens.warning,
  radius: SeatLayerRadiusTokens.base,
  buttonRadius: SeatLayerRadiusTokens.button,
  layout: SeatLayerPickerLayout(),
);

/// The venue outline the loading view draws while the real one is on its way.
Finder _silhouette() => find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          '${widget.painter}'.contains('_VenueSilhouettePainter'),
    );

double _breath(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find
          .ancestor(
            of: _silhouette(),
            matching: find.byType(FadeTransition),
          )
          .first,
    )
    .opacity
    .value;

Widget _standalone({bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: const Scaffold(
          body: SeatLayerPickerLoadingView.standalone(theme: _theme),
        ),
      ),
    );

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// A runtime that takes the chrome bands and does not answer until [gate].
FakePickerMap _stalledFraming(Completer<Object?> gate) {
  late final FakePickerMap map;
  return map = FakePickerMap(
    bundle: nativeChromeBundle(),
    handler: (command, payload) async {
      if (command == 'picker.setViewportInsets') await gate.future;
      return <String, Object?>{
        'revision': map.current['revision'],
        'snapshot': map.current,
      };
    },
  );
}

void main() {
  testWidgets('the wait is spent on a venue, not a spinner', (tester) async {
    await tester.pumpWidget(_standalone());
    await tester.pump();

    expect(_silhouette(), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // The standalone constructor is what a host uses before a scope exists.
    expect(find.text('Loading seat map…'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the venue breathes, and holds still for a viewer who asked',
      (tester) async {
    await tester.pumpWidget(_standalone());
    await tester.pump(const Duration(milliseconds: 800));
    expect(_breath(tester), lessThan(1));

    await tester.pumpWidget(_standalone(reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 800));
    expect(_breath(tester), 1);
  });

  testWidgets('the map is revealed once the runtime has framed it',
      (tester) async {
    final framed = Completer<Object?>();
    final map = _stalledFraming(framed);
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: controller),
    );
    expect(find.byType(SeatLayerPickerLoadingView), findsOneWidget);

    // Ready — but the chrome the buyer is about to see has not been reported
    // yet, so revealing the map now shows it framed for the wrong surface.
    map.emit(pickerSnapshot(sections: pickerSections(), rung: 'seats'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.state.isReady, isTrue);
    expect(controller.state.mapFramed, isFalse);
    expect(
      find.byType(SeatLayerPickerLoadingView),
      findsOneWidget,
      reason: 'the map would be shown once and then re-fitted',
    );

    framed.complete(null);
    await tester.pumpAndSettle();

    expect(controller.state.mapFramed, isTrue);
    expect(find.byType(SeatLayerPickerLoadingView), findsNothing);
  });

  testWidgets('a runtime that never answers cannot hold the buyer there',
      (tester) async {
    // The report goes out and is never acknowledged: the backstop is the only
    // thing that can give this buyer their map.
    final never = Completer<Object?>();
    final map = _stalledFraming(never);
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: controller),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), rung: 'seats'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SeatLayerPickerLoadingView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byType(SeatLayerPickerLoadingView),
      findsNothing,
      reason: 'a refinement must never become the experience',
    );

    never.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets("the header borrows the host's event name until the runtime's "
      'own arrives', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerHeader(compact: true),
        options: const SeatLayerPickerOptions(eventName: 'Riverside Nights'),
      ),
    );
    await tester.pump();

    expect(find.text('Riverside Nights'), findsOneWidget);
    expect(find.text('Choose your seats'), findsNothing);

    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(find.text('Mobile Test Event'), findsOneWidget);
    expect(find.text('Riverside Nights'), findsNothing);
  });

  test('the host name never reaches the runtime, and never reboots it', () {
    const options = SeatLayerPickerOptions(eventName: 'Riverside Nights');
    expect(options.toBridgeConfig().values, isNot(contains('Riverside Nights')));
  });
}
