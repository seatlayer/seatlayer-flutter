import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The layout with the WebView replaced, so the composition can be tested
/// without a platform view.
Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(),
      ),
    );

PopScope<dynamic> _popScope(WidgetTester tester) => tester
    .widgetList<PopScope<dynamic>>(
      find.byWidgetPredicate((widget) => widget is PopScope),
    )
    .last;

void main() {
  testWidgets('the phone layout docks nothing at rung two', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await tester.pumpAndSettle();

    // Focusing a section used to dock a bar onto the map's bottom edge —
    // "406 · 302 seats left ‹ › ‹ Venue". Pinch-out and the zoom-out stepper
    // already walk a buyer back to the venue, so the prev/next arrows bought
    // a two-tap version of a gesture the finger does better, and the
    // per-section count is no longer shown on a phone at all.
    expect(find.byType(SeatLayerDockBar), findsNothing);
    expect(find.text('Gallery'), findsNothing);
  });

  testWidgets('a host can ask for the dock bar back', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(showDockBar: true),
        ),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerDockBar), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('with no dock the corner controls sit at the map\'s own edge',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await tester.pumpAndSettle();

    // The `−` stepper is the phone's one way back now, so nothing may push it
    // up the screen to make room for a bar that is not there.
    final band = tester.getRect(find.byType(SeatLayerPickerMapControls));
    final stepOut = tester.getRect(find.byType(SeatLayerPickerZoomOutButton));
    expect(
      stepOut.bottom,
      closeTo(band.bottom - SeatLayerSizeTokens.mapAnchorInset, .5),
    );
  });

  testWidgets('a system back at rung two climbs one map level', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await tester.pumpAndSettle();

    final scope = _popScope(tester);
    expect(scope.canPop, isFalse);
    scope.onPopInvokedWithResult!(false, null);
    await tester.pump();

    expect(map.callsTo('picker.zoomOut'), hasLength(1));
  });

  testWidgets('a system back at the overview is handed to the host',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(
      pickerSnapshot(
        rung: 'overview',
        sections: pickerSections(),
        withSelection: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(_popScope(tester).canPop, isTrue);
  });

  testWidgets('a system back with the sheet open collapses it to peek first',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(
          readOnly: true,
          panelInitiallyCollapsed: false,
        ),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await tester.pumpAndSettle();

    _popScope(tester).onPopInvokedWithResult!(false, null);
    await tester.pumpAndSettle();

    // The sheet took the gesture, so the map has not moved yet.
    expect(map.callsTo('picker.zoomOut'), isEmpty);

    _popScope(tester).onPopInvokedWithResult!(false, null);
    await tester.pumpAndSettle();
    expect(map.callsTo('picker.zoomOut'), hasLength(1));
  });

  testWidgets('leaving rung two collapses the sheet with it', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(
          readOnly: true,
          panelInitiallyCollapsed: false,
        ),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections(), withSelection: false));
    await tester.pumpAndSettle();
    expect(_popScope(tester).canPop, isFalse);

    // The runtime owns the backdrop tap; the native chrome hears about it as
    // a rung change.
    map.emit(
      pickerSnapshot(
        revision: 9,
        rung: 'overview',
        sections: pickerSections(),
        withSelection: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(_popScope(tester).canPop, isTrue);
  });
}
