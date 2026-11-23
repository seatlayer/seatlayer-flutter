// A phone is a phone however it is held.
//
// Turned sideways a phone is 844 to 932 wide, past both the wide composition's
// breakpoint and the dialog's, but only 390 to 430 tall. The side panel and
// the dialog are built for a tablet's height: on a phone the panel's column
// overflowed by up to 77 points. So the device's shortest side decides.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_wide_panel.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_presentation.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const List<Size> _sidewaysPhones = <Size>[
  Size(844, 390),
  Size(915, 412),
  Size(932, 430),
];

const List<Size> _tablets = <Size>[Size(1024, 768), Size(1180, 820)];

void _useSurface(WidgetTester tester, Size size) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _mountLayout(WidgetTester tester, Size size) async {
  final map = FakePickerMap(bundle: nativeChromeBundle());
  addTearDown(map.dispose);
  _useSurface(tester, size);
  await tester.pumpWidget(
    pickerHarness(
      map,
      SeatLayerPickerAdaptiveLayout(
        onCheckout: (_) async {},
        builders: SeatLayerPickerBuilders(
          map: (context, part) => const SizedBox.expand(),
        ),
      ),
    ),
  );
  map.emit(pickerSnapshot(withSelection: false));
  await pumpToRest(tester);
}

Future<void> _show(WidgetTester tester, Size size) async {
  useFakeWebViewPlatform();
  _useSurface(tester, size);
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showSeatLayerPicker(
            context,
            configuration: SeatLayerConfiguration(event: 'ev_test'),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('the composition', () {
    for (final size in _sidewaysPhones) {
      testWidgets('a phone held sideways, $size, keeps the phone layout',
          (tester) async {
        await _mountLayout(tester, size);
        expect(find.byType(SeatLayerWidePanelHeading), findsNothing);
      });
    }
    for (final size in _tablets) {
      testWidgets('a tablet, $size, takes the wide layout', (tester) async {
        await _mountLayout(tester, size);
        expect(find.byType(SeatLayerWidePanelHeading), findsWidgets);
      });
    }
  });

  group('showSeatLayerPicker', () {
    for (final size in _sidewaysPhones) {
      testWidgets('a phone held sideways, $size, opens full screen',
          (tester) async {
        await _show(tester, size);
        expect(find.byType(Dialog), findsNothing);
        expect(find.byType(SeatLayerPickerPage), findsOneWidget);
      });
    }
    for (final size in _tablets) {
      testWidgets('a tablet, $size, opens the dialog', (tester) async {
        await _show(tester, size);
        expect(find.byType(Dialog), findsOneWidget);
      });
    }
  });
}
