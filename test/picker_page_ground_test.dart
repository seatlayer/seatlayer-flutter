// The full-screen page must paint the picker's ground, not the host's.
//
// `SeatLayerPickerPage` hands its top inset to a SafeArea rather than to the
// header, so whatever the Scaffold paints shows through above the header. A
// bare Scaffold paints the HOST application's `scaffoldBackgroundColor`, which
// put a white band over a dark picker on the first dark screenshot.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_presentation.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'fake_webview_platform.dart';
import 'picker_widget_harness.dart';

Color? _scaffoldGround(WidgetTester tester) =>
    tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;

Future<void> _pumpPage(
  WidgetTester tester, {
  required SeatLayerThemeMode themeMode,
  required ThemeData hostTheme,
}) async {
  useFakeWebViewPlatform();
  usePhoneSurface(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: hostTheme,
      home: SeatLayerPickerPage(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        themeMode: themeMode,
        onCheckout: (_) {},
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a dark picker inside a light host has no white top band',
      (tester) async {
    await _pumpPage(
      tester,
      themeMode: SeatLayerThemeMode.dark,
      hostTheme: ThemeData.light(),
    );

    expect(_scaffoldGround(tester), SeatLayerDarkTokens.surface);
    expect(_scaffoldGround(tester),
        isNot(ThemeData.light().scaffoldBackgroundColor));
  });

  testWidgets('a light picker inside a dark host has no black top band',
      (tester) async {
    await _pumpPage(
      tester,
      themeMode: SeatLayerThemeMode.light,
      hostTheme: ThemeData.dark(),
    );

    expect(_scaffoldGround(tester), SeatLayerLightTokens.surface);
  });

  testWidgets("the ground follows the host application's own theme under auto",
      (tester) async {
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    // `auto` asks the host first — the switch inside the app is the one the
    // buyer actually moved. The device is left on light throughout, so this
    // fails if the picker is still reading `platformBrightness`.
    Widget build(Brightness host) => MaterialApp(
          theme: ThemeData(brightness: host),
          themeAnimationDuration: Duration.zero,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(platformBrightness: Brightness.light),
            child: child!,
          ),
          home: SeatLayerPickerPage(
            configuration: SeatLayerConfiguration(event: 'ev_test'),
            onCheckout: (_) {},
          ),
        );

    await tester.pumpWidget(build(Brightness.light));
    await tester.pump();
    expect(_scaffoldGround(tester), SeatLayerLightTokens.surface);

    await tester.pumpWidget(build(Brightness.dark));
    await tester.pump();
    expect(_scaffoldGround(tester), SeatLayerDarkTokens.surface);
  });
}
