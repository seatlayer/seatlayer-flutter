// A device appearance flip must repaint the picker, never reboot it.
//
// The boot mode is frozen by `PickerThemeModeSync`, but the init config the
// WebView is handed carries more than the mode. Anything in it that follows the
// live brightness changes the bridge profile on a flip, and a changed profile
// is what `SeatLayerView.didUpdateWidget` treats as a reload — which destroys
// the runtime and takes the buyer's section, selection and 3D scene with it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_view.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

SeatLayerBridgeProfile _profile(WidgetTester tester) =>
    tester.widget<SeatLayerView>(find.byType(SeatLayerView)).bridgeProfile;

void main() {
  testWidgets('a flip keeps the init config identical and sends one command',
      (tester) async {
    final web = useFakeWebViewPlatform();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    Widget build(Brightness platform) => pickerHarness(
          map,
          const SeatLayerPickerMap(),
          platformBrightness: platform,
        );

    await tester.pumpWidget(build(Brightness.light));
    map.emit(pickerSnapshot());
    await tester.pump();
    final before = _profile(tester);
    final viewBefore = tester.element(find.byType(SeatLayerView));

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pump();
    final after = _profile(tester);

    expect(
      before.equivalentTo(after),
      isTrue,
      reason: 'a changed profile reboots the runtime and drops the selection',
    );
    expect(tester.element(find.byType(SeatLayerView)), same(viewBefore));
    expect(web.controllersCreated, 1, reason: 'the WebView was rebuilt');
    expect(web.loads.length, 1, reason: 'the document was loaded twice');
    expect(map.callsTo('picker.destroy'), isEmpty);
    expect(
      map.callsTo('picker.setThemeMode').single.$2,
      <String, Object?>{'mode': 'dark'},
    );
  });

  testWidgets('a mode-derived map ground is left to the runtime',
      (tester) async {
    useFakeWebViewPlatform();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerMap()),
    );
    await tester.pump();

    expect(_profile(tester).config, isNot(contains('mapTheme')));
  });

  testWidgets('a map ground the host authored is still handed over',
      (tester) async {
    useFakeWebViewPlatform();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerMap(),
        theme: const SeatLayerPickerThemeData(
          mapTheme: SeatLayerMapThemeData(background: Color(0xFF102030)),
        ),
      ),
    );
    await tester.pump();

    expect(
      _profile(tester).config['mapTheme'],
      containsPair('background', '#102030'),
    );
  });
}
