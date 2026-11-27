import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_connection_panel.dart';
import 'package:seatlayer/src/picker/picker_error_words.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const _checkConnection = 'Check your connection and try again.';

SeatLayerError _bridge(String code, {String message = '', int? status}) =>
    SeatLayerError.bridge(
      BridgeErrorPayload(
        code: code,
        message: message,
        details: status == null ? null : <String, Object?>{'status': status},
      ),
    );

Future<(FakePickerMap, SeatLayerPickerController)> _pump(
  WidgetTester tester,
  Future<Object?> Function(String command, Object? payload) handler, {
  SeatLayerCheckoutCallback? onCheckout,
}) async {
  final map = FakePickerMap(handler: handler);
  addTearDown(map.dispose);
  final picker = SeatLayerPickerController(mapController: map);
  addTearDown(picker.dispose);
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      Stack(
        children: <Widget>[
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SeatLayerPickerActionError(),
          ),
          Positioned.fill(
            child: SeatLayerPickerToastLayer(onCheckout: onCheckout),
          ),
        ],
      ),
      controller: picker,
    ),
  );
  map.emit(pickerSnapshot());
  await tester.pump();
  return (map, picker);
}

/// The red line's words, if it is drawn.
Finder _redLine() => find.descendant(
      of: find.byType(SeatLayerPickerActionError),
      matching: find.byType(Text),
    );

void main() {
  group('which kind of failure', () {
    test('no answer is the connection', () {
      expect(
        pickerFailureKind(
          const SeatLayerError.timeout('picker.holdSelection', Duration.zero),
        ),
        PickerFailureKind.connection,
      );
      expect(
        pickerFailureKind(const SeatLayerError.handshakeTimeout(Duration.zero)),
        PickerFailureKind.connection,
      );
      expect(
        pickerFailureKind(const SeatLayerError.transport(
          'page load failed: net::ERR_INTERNET_DISCONNECTED',
        )),
        PickerFailureKind.connection,
      );
      expect(
        pickerFailureKind(_bridge('picker_error', message: 'Failed to fetch')),
        PickerFailureKind.connection,
      );
    });

    test('a 5xx answer is the server', () {
      expect(
        pickerFailureKind(
          const SeatLayerError.transport('page load failed: HTTP 503'),
        ),
        PickerFailureKind.server,
      );
      expect(
        pickerFailureKind(
          _bridge('command_failed', message: 'request_failed', status: 502),
        ),
        PickerFailureKind.server,
      );
    });

    test('a refusal is neither', () {
      expect(pickerFailureKind(_bridge('sold_out', status: 409)),
          PickerFailureKind.other);
      expect(
        pickerFailureKind(
          const SeatLayerError.transport('page load failed: HTTP 404'),
        ),
        PickerFailureKind.other,
      );
      expect(
        pickerFailureKind(const SeatLayerError.transport('rejection unavailable')),
        PickerFailureKind.other,
      );
      expect(pickerFailureKind(StateError('app')), PickerFailureKind.other);
    });
  });

  testWidgets('a press without an answer is told in the small message',
      (tester) async {
    final (_, picker) = await _pump(tester, (command, _) async {
      throw const SeatLayerError.timeout(
        'picker.holdSelection',
        Duration(seconds: 45),
      );
    });
    await expectLater(picker.holdSelection(), throwsA(isA<SeatLayerError>()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(_checkConnection), findsOneWidget);
    expect(_redLine(), findsNothing);
  });

  testWidgets('a refusal still has the red line', (tester) async {
    final (_, picker) = await _pump(tester, (command, _) async {
      throw _bridge('hold_already_active');
    });
    await expectLater(picker.holdSelection(), throwsA(isA<SeatLayerError>()));
    await tester.pump();
    expect(_redLine(), findsWidgets);
  });

  testWidgets(
      'a server fault on the way to checkout offers to try checkout again',
      (tester) async {
    var fail = true;
    final handed = <SeatLayerCheckoutHandoff>[];
    final (map, picker) = await _pump(
      tester,
      (command, _) async {
        if (command == 'picker.continue' && !fail) {
          return <String, Object?>{
            'revision': 2,
            'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
            'handoff': checkoutHandoff(),
          };
        }
        throw _bridge('command_failed', message: 'request_failed', status: 502);
      },
      onCheckout: handed.add,
    );
    await expectLater(picker.checkout(), throwsA(isA<SeatLayerError>()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Couldn’t reach checkout.'), findsOneWidget);
    expect(_redLine(), findsNothing);

    fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(
      map.calls.where((call) => call.$1 == 'picker.continue'),
      hasLength(2),
    );
    expect(handed, hasLength(1));
  });

  testWidgets('a slow press says so from ten seconds', (tester) async {
    final answer = Completer<Object?>();
    final (_, picker) = await _pump(tester, (command, _) => answer.future);
    final press = picker.holdSelection();
    await tester.pump(const Duration(seconds: 9));
    expect(
      find.text('This is taking longer than usual. Please wait…'),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('This is taking longer than usual. Please wait…'),
      findsOneWidget,
    );
    answer.complete(<String, Object?>{
      'revision': 2,
      'snapshot': pickerSnapshot(revision: 2),
    });
    await press;
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a slow opening says so from eight seconds', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerLoadingView()),
    );
    await tester.pump(const Duration(seconds: 7));
    expect(find.text('Loading seat map…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('The seat map is taking longer to load. Please wait…'),
      findsOneWidget,
    );
  });

  group('opening offline', () {
    Future<List<int>> panel(WidgetTester tester) async {
      final tries = <int>[];
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      await tester.pumpWidget(
        pickerHarness(
          map,
          Builder(
            builder: (context) => PickerOfflinePanel(
              controller: picker,
              palette: seatLayerPickerThemeOf(context),
              words: const SeatLayerPickerStrings(),
              onRetry: () => tries.add(tries.length + 1),
            ),
          ),
          controller: picker,
        ),
      );
      return tries;
    }

    testWidgets('a page that got no answer opens on this panel',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerErrorView(),
            controller: picker),
      );
      picker.value = picker.value.withError(const SeatLayerError.transport(
        'page load failed: net::ERR_INTERNET_DISCONNECTED',
      ));
      await tester.pump();
      expect(find.text('You’re offline'), findsOneWidget);
      expect(find.textContaining('page load failed'), findsNothing);
      expect(find.text('The seat map didn’t load'), findsNothing);
    });

    testWidgets('a server fault keeps the title and leaves out the connection',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerErrorView(),
            controller: picker),
      );
      picker.value = picker.value.withError(
        const SeatLayerError.transport('page load failed: HTTP 503'),
      );
      await tester.pump();
      expect(find.text('The seat map didn’t load'), findsOneWidget);
      expect(find.text(_checkConnection), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('says the device is offline, with a way to try again',
        (tester) async {
      final tries = await panel(tester);
      expect(find.text('You’re offline'), findsOneWidget);
      expect(find.text(_checkConnection), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(tries, <int>[1]);
    });

    testWidgets('tries by itself after 10, 20, then every 30 seconds',
        (tester) async {
      final tries = await panel(tester);
      await tester.pump(const Duration(seconds: 10));
      expect(tries, hasLength(1));
      await tester.pump(const Duration(seconds: 20));
      expect(tries, hasLength(2));
      await tester.pump(const Duration(seconds: 30));
      expect(tries, hasLength(3));
      await tester.pump(const Duration(seconds: 30));
      expect(tries, hasLength(4));
    });

    testWidgets('waits while the app is in the background', (tester) async {
      final tries = await panel(tester);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(minutes: 2));
      expect(tries, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 10));
      expect(tries, hasLength(1));
    });
  });
}
