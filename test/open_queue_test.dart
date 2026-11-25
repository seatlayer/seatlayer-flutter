// What the buyer asks for in the first seconds is not kept behind a command
// the page could not answer yet.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/picker/picker_internal.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';
import 'season_harness.dart';

const _command = 'picker.setInteractionEnabled';

/// Plays picker.html's part of the bridge.
class _EventPage extends SeasonPage {
  _EventPage(super.fake);

  /// What the page was told about its touches, in order.
  List<Object?> get told => <Object?>[
        for (final envelope in sent)
          if (envelope.type == _command) (envelope.payload! as Map)['enabled'],
      ];

  bool asked(String command) => sent.any((e) => e.type == command);

  Future<void> hello(WidgetTester tester) async {
    post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.3',
      'protocol': <String, Object?>{'min': 1, 'max': 2},
      'capabilities': <String>[
        ...SeatLayerBridgeProfile.picker().requiredCapabilities,
        'native-chrome-contract-v1',
      ],
      'events': <String>[],
      'commands': <String>[_command, 'picker.setThemeMode'],
    });
    await tester.pump();
  }

  Future<void> ready(
    WidgetTester tester, {
    bool withSelection = false,
  }) async {
    evt('sys.ready', <String, Object?>{
      'protocol': 2,
      'snapshot': pickerSnapshot(withSelection: withSelection),
    });
    for (var i = 0; i < 4; i += 1) {
      await tester.pump();
    }
  }
}

void main() {
  Future<(_EventPage, SeatLayerPickerController)> open(
    WidgetTester tester,
  ) async {
    final fake = useFakeWebViewPlatform();
    usePhoneSurface(tester);
    final controller = SeatLayerPickerController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SeatLayerPicker(
          configuration: SeatLayerConfiguration(event: 'ev_test'),
          controller: controller,
          onCheckout: (_) async {},
        ),
      ),
    ));
    for (var i = 0; i < 4; i += 1) {
      await tester.pump();
    }
    return (_EventPage(fake), controller);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  }

  testWidgets('the page is told nothing before it is ready', (tester) async {
    final (page, _) = await open(tester);
    await page.hello(tester);
    expect(page.told, isEmpty);
    // The loading view still stands on the map.
    await page.ready(tester);
    expect(page.told, <Object?>[false]);
    await close(tester);
  });

  testWidgets('what the buyer asks for first goes to the page at once',
      (tester) async {
    final (page, controller) = await open(tester);
    await page.hello(tester);
    // A page that is not ready answers nothing.
    final before = page.told.length;
    await page.ready(tester);
    ignorePickerAction(controller.bestAvailable(quantity: 2));
    if (page.told.length > before) {
      page.answer(_command, const <String, Object?>{});
    }
    for (var i = 0; i < 4; i += 1) {
      await tester.pump();
    }
    expect(page.asked('picker.bestAvailable'), isTrue);
    await close(tester);
  });

  testWidgets('the phone turns dark while the page loads', (tester) async {
    final (page, controller) = await open(tester);
    await page.hello(tester);
    ignorePickerAction(controller.setThemeMode(SeatLayerThemeMode.light));
    ignorePickerAction(controller.setThemeMode(SeatLayerThemeMode.dark));
    await tester.pump();
    expect(page.asked('picker.setThemeMode'), isFalse);
    await page.ready(tester);
    page.answer(_command, const <String, Object?>{});
    for (var i = 0; i < 4; i += 1) {
      await tester.pump();
    }
    final asked = page.sent.where((e) => e.type == 'picker.setThemeMode');
    expect(
      asked.map((e) => (e.payload! as Map)['mode']),
      <Object?>['dark'],
    );
    await close(tester);
  });

  testWidgets('a hold pressed first goes to the page at once', (tester) async {
    final (page, controller) = await open(tester);
    await page.hello(tester);
    final before = page.told.length;
    await page.ready(tester, withSelection: true);
    ignorePickerAction(controller.holdSelection());
    if (page.told.length > before) {
      page.answer(_command, const <String, Object?>{});
    }
    for (var i = 0; i < 4; i += 1) {
      await tester.pump();
    }
    expect(page.asked('picker.holdSelection'), isTrue);
    await close(tester);
  });

  testWidgets('a page that never becomes ready fails in its time',
      (tester) async {
    final (page, controller) = await open(tester);
    await page.hello(tester);
    Object? failure;
    unawaited(
      controller.bestAvailable(quantity: 2).catchError((Object error) {
        failure = error;
      }),
    );
    final wait = SeatLayerConfiguration(event: 'ev_test').handshakeTimeout;
    await tester.pump(wait - const Duration(seconds: 1));
    expect(controller.state.phase, SeatLayerPickerPhase.initializing);
    await tester.pump(const Duration(seconds: 2));
    expect(controller.state.phase, SeatLayerPickerPhase.failed);
    expect(failure, isA<SeatLayerError>());
    expect(page.told, isEmpty);
    await close(tester);
  });

  testWidgets('a call before the page is ready reaches the page',
      (tester) async {
    final (page, controller) = await open(tester);
    ignorePickerAction(controller.setMapInteractionEnabled(false));
    await tester.pump();
    expect(page.told, isEmpty);
    await page.hello(tester);
    await page.ready(tester);
    expect(page.told, <Object?>[false]);
    await close(tester);
  });
}
