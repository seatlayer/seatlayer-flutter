// The system ends the page (iPhone, low memory): a new one takes its place,
// opened on the same hold, and a page that cannot stay up ends in the failure
// view.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/bridge/bridge_page_recovery.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/picker/picker_header.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';
import 'run_harness.dart';
import 'season_harness.dart';

const _words = SeatLayerPickerStrings();

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i += 1) {
    await tester.pump();
  }
}

void _appIs(WidgetTester tester, AppLifecycleState state) {
  tester.binding.handleAppLifecycleStateChanged(state);
  addTearDown(
    () => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed),
  );
}

Widget _app(Widget child) => MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: child,
      ),
    );

/// Plays picker.html's part of the bridge.
class _EventPage extends SeasonPage {
  _EventPage(super.fake);

  var _session = 0;

  @override
  Future<void> boot(WidgetTester tester, {String? holdOwner}) async {
    _session += 1;
    post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.3',
      'protocol': <String, Object?>{'min': 1, 'max': 2},
      'capabilities': <String>[
        ...SeatLayerBridgeProfile.picker().requiredCapabilities,
        'native-chrome-contract-v1',
      ],
      'events': <String>[],
      'commands': <String>[],
    });
    await tester.pump();
    evt('sys.ready', <String, Object?>{
      'protocol': 2,
      'snapshot': snapshot(1, holdOwner: holdOwner),
    });
    await _settle(tester);
  }

  Map<String, Object?> snapshot(int revision, {String? holdOwner}) =>
      pickerSnapshot(
        sessionId: 'session-$_session',
        revision: revision,
        holdOwner: holdOwner,
      );

  /// What the newest page was started with.
  Map<Object?, Object?> get config =>
      (sent.lastWhere((e) => e.kind == EnvelopeKind.init).payload!
          as Map)['config']! as Map<Object?, Object?>;

  bool get asked =>
      sent.any((envelope) => envelope.type == 'picker.resumeHold');
}

void main() {
  group('how often a lost page is replaced', () {
    test('twice a minute, and again once the minute has passed', () {
      var now = DateTime(2026, 11, 26, 20);
      final recovery = SeatLayerPageRecovery(now: () => now);
      expect(recovery.lost(), isTrue);
      expect(recovery.lost(), isTrue);
      expect(recovery.lost(), isFalse);
      now = now.add(const Duration(minutes: 1));
      expect(recovery.lost(), isTrue);
    });

    test('from the start again when the buyer asks', () {
      final recovery = SeatLayerPageRecovery(now: () => DateTime(2026));
      recovery
        ..lost()
        ..lost();
      expect(recovery.lost(), isFalse);
      recovery.reset();
      expect(recovery.lost(), isTrue);
    });
  });

  testWidgets('a bare view reports it, and refuses what was waiting',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = _EventPage(fake);
    final controller = SeatLayerController();
    addTearDown(controller.dispose);
    final errors = <SeatLayerError>[];
    controller.onError.listen(errors.add);
    await tester.pumpWidget(_app(SeatLayerView(
      controller: controller,
      configuration: SeatLayerConfiguration(event: 'ev_test'),
    )));
    await page.boot(tester);
    expect(controller.isReady, isTrue);

    Object? refused;
    controller
        .runBridgeCommand('chart.fit')
        .then<void>((_) {}, onError: (Object error) => refused = error);
    fake.endPage();
    await _settle(tester);
    expect(errors.single, isA<TransportFailure>());
    expect(errors.single.code, 'sl_transport');
    expect(refused, isA<TransportFailure>());
    expect(controller.isReady, isFalse);
    expect(fake.loads, hasLength(1));
  });

  group('event', () {
    Future<(FakeWebViewPlatform, _EventPage, SeatLayerPickerController)> open(
      WidgetTester tester, {
      SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
      SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
    }) async {
      final fake = useFakeWebViewPlatform();
      usePhoneSurface(tester);
      final controller = SeatLayerPickerController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SeatLayerPickerScope(
            configuration: SeatLayerConfiguration(event: 'ev_test'),
            controller: controller,
            options: options,
            callbacks: callbacks,
            child: const SeatLayerPickerMap(),
          ),
        ),
      ));
      return (fake, _EventPage(fake), controller);
    }

    testWidgets('a new page comes up and answers', (tester) async {
      final errors = <SeatLayerError>[];
      final (fake, page, controller) = await open(
        tester,
        callbacks: SeatLayerPickerCallbacks(onError: errors.add),
      );
      await page.boot(tester);
      fake.endPage();
      await _settle(tester);
      expect(fake.loads, hasLength(2));
      expect(controller.state.phase, SeatLayerPickerPhase.initializing);

      page.reloaded();
      await page.boot(tester);
      expect(controller.state.isReady, isTrue);
      // The page that was replaced takes nothing of this one with it.
      expect(controller.mapController.isReady, isTrue);
      final synced = controller.synchronize();
      await tester.pump();
      page.answer('picker.getSnapshot', <String, Object?>{
        'revision': 2,
        'snapshot': page.snapshot(2),
      });
      await _settle(tester);
      await synced;
      expect(errors, isEmpty);
      expect(page.asked, isFalse);
    });

    testWidgets('Try again brings a page that answers', (tester) async {
      final (fake, page, controller) = await open(tester);
      await page.boot(tester);
      final retried = controller.retry();
      await tester.pump();
      page.answer('picker.destroy', const <String, Object?>{});
      await _settle(tester);
      await retried;
      expect(fake.loads, hasLength(2));
      page.reloaded();
      await page.boot(tester);
      expect(controller.mapController.isReady, isTrue);
      expect(controller.state.isReady, isTrue);
    });

    testWidgets('the hold the app opened on is taken up once the page is up',
        (tester) async {
      final (fake, page, controller) = await open(
        tester,
        options: const SeatLayerPickerOptions(initialHoldId: 'hold-1'),
      );
      await page.boot(tester, holdOwner: 'host');
      expect(page.config['initialHoldId'], 'hold-1');
      expect(controller.state.hasHostOwnedHold, isTrue);

      fake.endPage();
      await _settle(tester);
      page.reloaded();
      await page.boot(tester);
      expect(page.config.containsKey('initialHoldId'), isFalse);
      expect(
        page.last('picker.resumeHold').payload,
        <String, Object?>{'holdId': 'hold-1'},
      );
      page.answer('picker.resumeHold', <String, Object?>{
        'revision': 2,
        'snapshot': page.snapshot(2, holdOwner: 'host'),
      });
      await _settle(tester);
      expect(controller.state.hold, isNotNull);
      expect(fake.loads, hasLength(2));
    });

    testWidgets('behind another app it waits', (tester) async {
      final (fake, page, _) = await open(tester);
      await page.boot(tester);
      _appIs(tester, AppLifecycleState.inactive);
      _appIs(tester, AppLifecycleState.hidden);
      _appIs(tester, AppLifecycleState.paused);
      fake.endPage();
      await _settle(tester);
      expect(fake.loads, hasLength(1));

      _appIs(tester, AppLifecycleState.hidden);
      _appIs(tester, AppLifecycleState.inactive);
      await _settle(tester);
      expect(fake.loads, hasLength(1));
      _appIs(tester, AppLifecycleState.resumed);
      await _settle(tester);
      expect(fake.loads, hasLength(2));
      page.reloaded();
      await page.boot(tester);
    });

    testWidgets('a third time in a minute it fails, and Try again starts over',
        (tester) async {
      final errors = <SeatLayerError>[];
      final (fake, page, controller) = await open(
        tester,
        callbacks: SeatLayerPickerCallbacks(onError: errors.add),
      );
      await page.boot(tester);
      for (var i = 0; i < 2; i += 1) {
        fake.endPage();
        await _settle(tester);
        page.reloaded();
        await page.boot(tester);
      }
      expect(errors, isEmpty);
      fake.endPage();
      await _settle(tester);
      expect(fake.loads, hasLength(3));
      expect(controller.state.phase, SeatLayerPickerPhase.failed);
      expect(errors.single.code, 'sl_transport');

      await controller.retry();
      await _settle(tester);
      page.reloaded();
      await page.boot(tester);
      expect(controller.state.isReady, isTrue);
      fake.endPage();
      await _settle(tester);
      expect(fake.loads, hasLength(5));
      page.reloaded();
      await page.boot(tester);
    });
  });

  group('Season', () {
    Map<Object?, Object?> config(SeasonPage page) =>
        (page.sent.lastWhere((e) => e.kind == EnvelopeKind.init).payload!
            as Map)['config']! as Map<Object?, Object?>;

    Future<
        (
          FakeWebViewPlatform,
          SeasonPage,
          List<(SeatLayerSeasonCloseOutcome, String?)>
        )> open(
      WidgetTester tester, {
      SeatLayerSeasonConfiguration? configuration,
    }) async {
      final fake = useFakeWebViewPlatform();
      final page = SeasonPage(fake);
      final closes = <(SeatLayerSeasonCloseOutcome, String?)>[];
      await tester.pumpWidget(_app(SeatLayerSeasonPicker(
        configuration: configuration ?? seasonConfiguration,
        onContinue: (_) {},
        onClose: (outcome, operationId) => closes.add((outcome, operationId)),
      )));
      await page.boot(tester);
      return (fake, page, closes);
    }

    testWidgets('a new page opens on the hold', (tester) async {
      final (fake, page, _) = await open(tester);
      page.held('sop_a');
      await _settle(tester);
      fake.endPage();
      await _settle(tester);
      expect(fake.loads, hasLength(2));
      expect(find.byType(SeatLayerPickerErrorView), findsNothing);

      page.reloaded();
      await page.boot(tester);
      expect(config(page)['initialOperationId'], 'sop_a');
      page.held('sop_a');
      await _settle(tester);
      expect(find.byType(SeatLayerHoldClock), findsOneWidget);
    });

    testWidgets('a page lost before it took the hold up hands it on',
        (tester) async {
      final (fake, page, _) = await open(tester);
      page.held('sop_a');
      await _settle(tester);
      fake.endPage();
      await _settle(tester);
      fake.endPage();
      await _settle(tester);
      page.reloaded();
      await page.boot(tester);
      expect(config(page)['initialOperationId'], 'sop_a');
    });

    testWidgets('a hold that is gone does not fail the Season', (tester) async {
      final (fake, page, _) = await open(
        tester,
        configuration: SeatLayerSeasonConfiguration(
          season: 'sea_test',
          initialOperationId: 'sop_a',
        ),
      );
      page.held('sop_a');
      await _settle(tester);
      fake.endPage();
      await _settle(tester);
      page.reloaded();
      page.post(EnvelopeKind.hello, 'hello', <String, Object?>{
        'bundle': '1.0.0',
        'protocol': <String, Object?>{'min': 2, 'max': 2},
        'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
        'events': <String>[],
        'commands': <String>[],
      });
      await tester.pump();
      page.evt('sys.error', <String, Object?>{'code': 'hold_gone'});
      await _settle(tester);
      expect(find.byType(SeatLayerPickerErrorView), findsNothing);
      expect(fake.loads, hasLength(3));
      page.reloaded();
      await page.boot(tester);
      expect(config(page).containsKey('initialOperationId'), isFalse);
    });

    testWidgets('✕ closes at once while no page is up', (tester) async {
      final (fake, _, closes) = await open(tester);
      _appIs(tester, AppLifecycleState.inactive);
      fake.endPage();
      await _settle(tester);
      await tester.tap(find.byTooltip('Close seat selection'));
      await _settle(tester);
      expect(closes, <(SeatLayerSeasonCloseOutcome, String?)>[
        (SeatLayerSeasonCloseOutcome.closed, null),
      ]);
    });

    testWidgets('✕ with seats held and no page says they are kept',
        (tester) async {
      final (fake, page, closes) = await open(tester);
      page.held('sop_a');
      await _settle(tester);
      for (var i = 0; i < 3; i += 1) {
        fake.endPage();
        await _settle(tester);
      }
      expect(fake.loads, hasLength(3));
      expect(find.byType(SeatLayerPickerErrorView), findsOneWidget);
      await tester.tap(find.byTooltip('Close seat selection'));
      await _settle(tester);
      expect(closes, <(SeatLayerSeasonCloseOutcome, String?)>[
        (SeatLayerSeasonCloseOutcome.kept, 'sop_a'),
      ]);
    });

    testWidgets('a question the page had open does not keep ✕ from closing',
        (tester) async {
      final (fake, page, closes) = await open(tester);
      page.held('sop_a');
      await _settle(tester);
      await tester.tap(find.byTooltip('Close seat selection'));
      await _settle(tester);
      expect(closes, isEmpty);
      _appIs(tester, AppLifecycleState.inactive);
      fake.endPage();
      await _settle(tester);
      await tester.tap(find.byTooltip('Close seat selection'));
      await _settle(tester);
      expect(closes, hasLength(1));
    });

    testWidgets('Try again after the third time opens on the hold',
        (tester) async {
      final (fake, page, _) = await open(tester);
      page.held('sop_a');
      await _settle(tester);
      for (var i = 0; i < 3; i += 1) {
        fake.endPage();
        await _settle(tester);
      }
      await tester.tap(find.text(_words.retry));
      await _settle(tester);
      page.reloaded();
      await page.boot(tester);
      expect(config(page)['initialOperationId'], 'sop_a');
    });
  });

  group('run', () {
    testWidgets('a new page opens on the hold', (tester) async {
      final fake = useFakeWebViewPlatform();
      final page = RunPage(fake);
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        onContinue: (_) {},
      )));
      await page.boot(tester);
      page.held('pghop_a');
      await _settle(tester);
      fake.endPage();
      await _settle(tester);
      expect(fake.loads, hasLength(2));
      page.reloaded();
      await page.boot(tester);
      final config = (page.sent
          .lastWhere((e) => e.kind == EnvelopeKind.init)
          .payload! as Map)['config']! as Map;
      expect(config['initialOperationId'], 'pghop_a');
      expect(config['initialHoldId'], 'hold_1');
      page.answer('group.getHeldOrder', <String, Object?>{
        'heldOrder': runHandoff('pghop_a'),
      });
      await _settle(tester);
      expect(find.byType(SeatLayerHoldClock), findsOneWidget);
    });

    testWidgets('a third time in a minute the failure view stands',
        (tester) async {
      final fake = useFakeWebViewPlatform();
      final page = RunPage(fake);
      await tester.pumpWidget(_app(SeatLayerRunPicker(
        configuration: runConfiguration,
        onContinue: (_) {},
      )));
      await page.boot(tester);
      for (var i = 0; i < 3; i += 1) {
        fake.endPage();
        await _settle(tester);
      }
      expect(fake.loads, hasLength(3));
      expect(find.byType(SeatLayerPickerErrorView), findsOneWidget);
      expect(find.text(_words.retry), findsOneWidget);
    });
  });
}
