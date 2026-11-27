// The run and Season pickers when the line to the server goes: the page draws
// its own status over its map; the app keeps its hold clock at 0:00 until the
// server answers, and stands its own panels in for a page that did not open.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'fake_webview_platform.dart';
import 'run_harness.dart';
import 'season_harness.dart';

const _words = SeatLayerPickerStrings();

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Widget _app(Widget child) => MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          padding: EdgeInsets.only(top: 47, bottom: 34),
        ),
        child: child,
      ),
    );

void _changed(SeasonPage page, String state) =>
    page.evt('connection.changed', <String, Object?>{'state': state});

/// The web view could not load the page: the device has no network.
void _noNetwork(FakeWebViewPlatform fake) => fake.resourceErrors.last(
      const WebResourceError(
        errorCode: -1009,
        description: 'net::ERR_INTERNET_DISCONNECTED',
        errorType: WebResourceErrorType.hostLookup,
        isForMainFrame: true,
      ),
    );

/// The server answered the page with a fault.
void _serverFault(SeasonPage page) => page.evt('sys.error', <String, Object?>{
      'code': 'picker_error',
      'message': 'request_failed',
      'details': <String, Object?>{'status': 503},
    });

bool _awaitingServer(WidgetTester tester) =>
    tester.widget<SeatLayerHoldClock>(find.byType(SeatLayerHoldClock))
        .awaitingServer;

void main() {
  group('the session', () {
    testWidgets('follows connection.changed; repeats and unknown words change '
        'nothing; a new page starts without a state', (tester) async {
      final page = RunPage(useFakeWebViewPlatform());
      final controller = SeatLayerRunController();
      addTearDown(controller.dispose);
      final heard = <SeatLayerConnectionState>[];
      final subscription = controller.onConnection.listen(heard.add);
      addTearDown(subscription.cancel);
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        controller: controller,
        onContinue: (_) {},
      )));
      await page.boot(tester);
      expect(controller.connection, isNull);

      _changed(page, 'offline');
      _changed(page, 'offline');
      _changed(page, 'satellite');
      _changed(page, 'reconnecting');
      _changed(page, 'live');
      await _settle(tester);
      expect(heard, <SeatLayerConnectionState>[
        SeatLayerConnectionState.offline,
        SeatLayerConnectionState.reconnecting,
        SeatLayerConnectionState.live,
      ]);
      expect(controller.connection, SeatLayerConnectionState.live);

      controller.detachTransport();
      expect(controller.connection, isNull);
    });
  });

  group('run', () {
    testWidgets('the hold clock waits at 0:00 while the line is down',
        (tester) async {
      final page = RunPage(useFakeWebViewPlatform());
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        onContinue: (_) {},
      )));
      await page.boot(tester);
      page.held('pghop_a');
      await _settle(tester);
      expect(_awaitingServer(tester), isFalse);

      _changed(page, 'offline');
      await _settle(tester);
      expect(_awaitingServer(tester), isTrue);

      _changed(page, 'reconnecting');
      await _settle(tester);
      expect(_awaitingServer(tester), isTrue);

      _changed(page, 'polling');
      await _settle(tester);
      expect(_awaitingServer(tester), isFalse);
    });

    testWidgets('a page that could not load for want of a network: the '
        'offline panel, which tries again after 10 and 20 s', (tester) async {
      final fake = useFakeWebViewPlatform();
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        onContinue: (_) {},
      )));
      await tester.pump();
      _noNetwork(fake);
      await _settle(tester);
      expect(find.text(_words.offline), findsOneWidget);
      expect(find.text(_words.checkConnection), findsOneWidget);
      expect(find.text(_words.mapDidNotLoad), findsNothing);
      expect(find.textContaining('ERR_'), findsNothing);
      expect(fake.loads, hasLength(1));

      await tester.pump(const Duration(seconds: 9));
      expect(fake.loads, hasLength(1));
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);
      expect(fake.loads, hasLength(2));

      // Still no network: the panel again, and the next try 20 s on.
      _noNetwork(fake);
      await _settle(tester);
      expect(find.text(_words.offline), findsOneWidget);
      await tester.pump(const Duration(seconds: 19));
      expect(fake.loads, hasLength(2));
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);
      expect(fake.loads, hasLength(3));
    });

    testWidgets('in the background the offline panel waits', (tester) async {
      final fake = useFakeWebViewPlatform();
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        onContinue: (_) {},
      )));
      await tester.pump();
      _noNetwork(fake);
      await _settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 40));
      expect(fake.loads, hasLength(1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 10));
      await _settle(tester);
      expect(fake.loads, hasLength(2));
    });

    testWidgets('a server fault: the map did not load, without the line '
        'about the connection', (tester) async {
      final page = RunPage(useFakeWebViewPlatform());
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        onContinue: (_) {},
      )));
      await tester.pump();
      page.post(EnvelopeKind.hello, 'hello', runHello);
      await tester.pump();
      _serverFault(page);
      await _settle(tester);
      expect(find.text(_words.mapDidNotLoad), findsOneWidget);
      expect(find.text(_words.checkConnection), findsNothing);
      expect(find.text(_words.offline), findsNothing);
      expect(find.text(_words.retry), findsOneWidget);
    });
  });

  group('Season', () {
    testWidgets('the hold clock waits at 0:00 while the line is down',
        (tester) async {
      final page = SeasonPage(useFakeWebViewPlatform());
      await tester.pumpWidget(_app(SeatLayerSeasonPicker(
        configuration: seasonConfiguration,
        onContinue: (_) {},
      )));
      await page.boot(tester);
      page.held('op_a');
      await _settle(tester);
      expect(_awaitingServer(tester), isFalse);

      _changed(page, 'offline');
      await _settle(tester);
      expect(_awaitingServer(tester), isTrue);

      _changed(page, 'live');
      await _settle(tester);
      expect(_awaitingServer(tester), isFalse);
    });

    testWidgets('a page that could not load for want of a network: the '
        'offline panel, which tries again by itself', (tester) async {
      final fake = useFakeWebViewPlatform();
      await tester.pumpWidget(_app(SeatLayerSeasonPicker(
        configuration: seasonConfiguration,
        onContinue: (_) {},
      )));
      await tester.pump();
      _noNetwork(fake);
      await _settle(tester);
      expect(find.text(_words.offline), findsOneWidget);
      expect(find.text(_words.mapDidNotLoad), findsNothing);
      await tester.pump(const Duration(seconds: 10));
      await _settle(tester);
      expect(fake.loads, hasLength(2));
    });

    testWidgets('a server fault: the map did not load, without the line '
        'about the connection', (tester) async {
      final page = SeasonPage(useFakeWebViewPlatform());
      await tester.pumpWidget(_app(SeatLayerSeasonPicker(
        configuration: seasonConfiguration,
        onContinue: (_) {},
      )));
      await tester.pump();
      page.post(EnvelopeKind.hello, 'hello', <String, Object?>{
        'bundle': '1.0.0',
        'protocol': <String, Object?>{'min': 2, 'max': 2},
        'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
        'events': <String>[],
        'commands': <String>[],
      });
      await tester.pump();
      _serverFault(page);
      await _settle(tester);
      expect(find.text(_words.mapDidNotLoad), findsOneWidget);
      expect(find.text(_words.checkConnection), findsNothing);
    });
  });
}
