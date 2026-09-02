// The device's clock, wifi glyph and battery are drawn by the operating
// system on a surface the picker owns, so the picker has to say what colour
// they should be. The owner's screenshot of the dark picker showed the iOS
// defaults: near-black glyphs on a near-black header, invisible.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_presentation.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The style a host that owns its own bars would have left standing.
const SystemUiOverlayStyle _hostStyle = SystemUiOverlayStyle(
  statusBarColor: Color(0xFF00FF00),
  statusBarBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
);

/// The fixture snapshot with the immersive scene up.
Map<String, Object?> _in3D() {
  final snapshot = pickerSnapshot(sections: pickerSections());
  (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
  return snapshot;
}

Future<SeatLayerPickerController> _pumpPage(
  WidgetTester tester, {
  required Widget Function(SeatLayerPickerController controller) build,
}) async {
  useFakeWebViewPlatform();
  usePhoneSurface(tester);
  final map = FakePickerMap();
  addTearDown(map.dispose);
  final controller = SeatLayerPickerController(mapController: map);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    // An outer region standing in for a host that dressed the bars itself.
    // With it in place `latestStyle` is never null, so "the picker set
    // nothing" is a real assertion rather than the absence of a frame.
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: _hostStyle,
      child: build(controller),
    ),
  );
  await tester.pump();
  return controller;
}

Widget _page({
  required SeatLayerPickerController controller,
  SeatLayerThemeMode themeMode = SeatLayerThemeMode.auto,
  Brightness hostBrightness = Brightness.light,
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
}) =>
    MaterialApp(
      theme: ThemeData(brightness: hostBrightness),
      themeAnimationDuration: Duration.zero,
      home: SeatLayerPickerPage(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        controller: controller,
        themeMode: themeMode,
        options: options,
        onCheckout: (_) {},
      ),
    );

SystemUiOverlayStyle _style() {
  final style = SystemChrome.latestStyle;
  expect(style, isNotNull, reason: 'nothing annotated the system bars');
  return style!;
}

Color? _scaffoldGround(WidgetTester tester) =>
    tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;

void main() {
  testWidgets('a light picker asks for dark icons on its light ground',
      (tester) async {
    await _pumpPage(
      tester,
      build: (controller) => _page(
        controller: controller,
        themeMode: SeatLayerThemeMode.light,
      ),
    );

    final style = _style();
    // iOS names the BACKGROUND; Android names the ICONS. They are opposites.
    expect(style.statusBarBrightness, Brightness.light);
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.statusBarColor, SeatLayerLightTokens.surface);
    expect(style.systemNavigationBarColor, SeatLayerLightTokens.surface);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });

  testWidgets('a dark picker asks for light icons — the reported defect',
      (tester) async {
    await _pumpPage(
      tester,
      build: (controller) => _page(
        controller: controller,
        themeMode: SeatLayerThemeMode.dark,
      ),
    );

    final style = _style();
    expect(style.statusBarBrightness, Brightness.dark);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.statusBarColor, SeatLayerDarkTokens.surface);
    expect(style.systemNavigationBarColor, SeatLayerDarkTokens.surface);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });

  testWidgets("the bars follow the host application's theme under auto",
      (tester) async {
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);

    Widget build(Brightness host) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: _hostStyle,
          child: _page(controller: controller, hostBrightness: host),
        );

    await tester.pumpWidget(build(Brightness.light));
    await tester.pump();
    expect(_style().statusBarIconBrightness, Brightness.dark);

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pump();
    expect(_style().statusBarIconBrightness, Brightness.light);
    expect(_style().statusBarBrightness, Brightness.dark);
  });

  testWidgets('the immersive scene forces the dark style on a light picker',
      (tester) async {
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: _hostStyle,
        child: _page(
          controller: controller,
          themeMode: SeatLayerThemeMode.light,
        ),
      ),
    );
    await tester.pump();
    expect(_style().statusBarIconBrightness, Brightness.dark);
    expect(_scaffoldGround(tester), SeatLayerLightTokens.surface);

    map.emit(_in3D());
    await pumpToRest(tester);

    // A white clock over a black venue is the only legible answer, whatever
    // side the picker itself resolved to.
    expect(_style().statusBarIconBrightness, Brightness.light);
    expect(_style().statusBarBrightness, Brightness.dark);
    // …and the page's own top strip goes with it, which is the residual round
    // five recorded: a white band above a black 3D scene.
    expect(_scaffoldGround(tester), SeatLayerDarkTokens.surface);
  });

  testWidgets('manageSystemOverlays: false leaves the host bars alone',
      (tester) async {
    await _pumpPage(
      tester,
      build: (controller) => _page(
        controller: controller,
        themeMode: SeatLayerThemeMode.dark,
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(manageSystemOverlays: false),
        ),
      ),
    );

    expect(_style(), _hostStyle);
  });
}
