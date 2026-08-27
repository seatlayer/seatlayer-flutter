// A device appearance flip repaints. It must not disturb anything else.
//
// On the pilot, flipping the simulator to dark while the cart sheet was open
// with seats selected snapped the sheet shut and re-framed the camera off the
// buyer's own section. Two causes, both here: the sheet's open/closed state
// lived in widget state that a rebuild can replace, and the repaint travelled
// as a mutation whose reply was folded back in as picker state — which is how
// a colours-only command came to move the rung, hide the dock, change the
// insets the layout reports, and re-fit the map.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// A seat already in the cart, with no confirm card standing over it.
///
/// The card collapses the sheet on purpose — it covers the map the buyer is
/// choosing from — so it has to be out of the way before a flip can be blamed
/// for anything.
const SeatLayerPickerOptions _settled =
    SeatLayerPickerOptions(confirmSelection: false);

bool _sheetExpanded(WidgetTester tester) =>
    tester.widget<SeatLayerCartSheet>(find.byType(SeatLayerCartSheet)).expanded;

void main() {
  testWidgets('an expanded cart sheet survives a device appearance flip',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    Widget build(Brightness platform) => pickerHarness(
          map,
          _layout(),
          controller: picker,
          options: _settled,
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    // The buyer opens their cart, with a seat already in it.
    picker.setCartSheetExpanded(true);
    await tester.pumpAndSettle();
    expect(_sheetExpanded(tester), isTrue);

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pumpAndSettle();

    expect(
      _sheetExpanded(tester),
      isTrue,
      reason: 'the flip closed the buyer\'s own cart under them',
    );
  });

  testWidgets('the sheet survives a layout State being replaced',
      (tester) async {
    // The cause behind the symptom: whatever hands the layout a fresh State —
    // a host rebuilding its route, a key change — must not reset the sheet.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    Widget build(String key) => pickerHarness(
          map,
          SeatLayerPickerAdaptiveLayout(
            key: ValueKey<String>(key),
            onCheckout: (_) async {},
          ),
          controller: picker,
          options: _settled,
        );

    await tester.pumpWidget(build('first'));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();
    picker.setCartSheetExpanded(true);
    await tester.pumpAndSettle();

    await tester.pumpWidget(build('second'));
    await tester.pumpAndSettle();

    expect(_sheetExpanded(tester), isTrue);
  });

  testWidgets('a colours-only flip reports no new viewport insets',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    Widget build(Brightness platform) => pickerHarness(
          map,
          _layout(),
          controller: picker,
          options: _settled,
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();
    final before = map.callsTo('picker.setViewportInsets').length;
    expect(before, greaterThan(0), reason: 'the rail and dock are reported');

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.setViewportInsets').length,
      before,
      reason: 'nothing moved; only the colours changed',
    );
    expect(map.callsTo('picker.setThemeMode'), hasLength(1));
  });

  testWidgets('repainting never parks the picker on a busy action',
      (tester) async {
    // `changingView` greys the dock and the confirm card the buyer is looking
    // at, and it is untrue: no view changed.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    final busyActions = <Object?>[];
    picker.addListener(() => busyActions.add(picker.value.busyAction));

    Widget build(Brightness platform) => pickerHarness(
          map,
          _layout(),
          controller: picker,
          options: _settled,
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();
    busyActions.clear();

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.setThemeMode'), hasLength(1));
    expect(busyActions, isEmpty);
  });

  testWidgets('a repaint reply cannot move the rung under the buyer',
      (tester) async {
    // The runtime answers every command with a snapshot. Folding the reply of
    // a colours-only command back in as state is what took the map out of the
    // focused section — collapsing the sheet with it and re-fitting the venue.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    Widget build(Brightness platform) => pickerHarness(
          map,
          _layout(),
          controller: picker,
          options: _settled,
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();
    picker.setCartSheetExpanded(true);
    await tester.pumpAndSettle();
    expect(picker.value.snapshot?.map.rung, 'seats');

    // A runtime whose repaint reply reports the overview — which is exactly
    // what the device showed.
    map.current = pickerSnapshot(
      revision: 9,
      sections: pickerSections(),
      rung: 'overview',
    );
    await tester.pumpWidget(build(Brightness.dark));
    await tester.pumpAndSettle();

    expect(picker.value.snapshot?.map.rung, 'seats');
    expect(_sheetExpanded(tester), isTrue);
  });
}
