// The Season picker in the app: the event header over season.html, driven
// through a fake page that answers like it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_header.dart';

import 'fake_webview_platform.dart';
import 'season_harness.dart';

/// A page event reaches the widget after the frame that pump draws, so the
/// widget's rebuild needs the next one.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Widget _app(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          padding: EdgeInsets.only(top: 47, bottom: 34),
        ),
        child: child,
      ),
    );

void main() {
  testWidgets('the event header stands over season.html, loading words first',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (_, __) {},
    )));

    expect(fake.loads, <String>[seatLayerSeasonPageUrl]);
    expect(find.byType(SeatLayerHeaderBar), findsOneWidget);
    expect(find.text('Choose your seats'), findsOneWidget);
    expect(find.byTooltip('Close seat selection'), findsOneWidget);

    await page.boot(tester);
    final init = page.sent.firstWhere((e) => e.kind == EnvelopeKind.init);
    final payload = init.payload! as Map<String, Object?>;
    expect(payload['surface'], <String, Object?>{'kind': 'season'});
    expect((payload['config']! as Map)['theme'], 'light');
    expect((payload['config']! as Map)['appBar'], isTrue);

    // The page names the Season and its club on `ready`.
    page.evt('season.status', <String, Object?>{
      'kind': 'ready',
      'message': 'Ready',
      'season': <String, Object?>{'key': 'sea_test', 'name': 'Winter season'},
      'branding': <String, Object?>{'brandName': 'Riverside FC'},
    });
    await _settle(tester);
    expect(find.text('Winter season'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);

    // The safe area under the page goes to its cart.
    expect(page.last('season.setViewportInsets').payload, <String, Object?>{
      'top': 0.0,
      'right': 0.0,
      'bottom': 34.0,
      'left': 0.0,
    });
  });

  testWidgets('every status of season-app-shell-v2 keeps the name and the mark',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (_, __) {},
    )));
    page.appBarPage = true;
    await page.boot(tester);
    // The club's logo is a picture; without one its colour and letter stand.
    const brand = <String, Object?>{
      'brandName': 'Grand Theatre',
      'accent': '#0f766e',
    };
    for (final kind in <String>[
      'ready',
      'pending',
      'held',
      'failed',
      'released',
      'booked',
    ]) {
      page.statusV2(kind, branding: brand);
      if (kind == 'held') page.held('sop_a');
      await _settle(tester);
      expect(find.text('Main Stage 2026/27'), findsOneWidget, reason: kind);
      expect(find.text('Choose your seats'), findsNothing, reason: kind);
      expect(find.text('G'), findsOneWidget, reason: kind);
    }
    final bar =
        tester.widget<SeatLayerHeaderBar>(find.byType(SeatLayerHeaderBar));
    expect(bar.theme.accent, const Color(0xFF0F766E));
    // One clock, the app's, and the bottom for the page's cart.
    expect(find.byType(SeatLayerHoldClock), findsOneWidget);
    expect(
      (page.last('season.setViewportInsets').payload! as Map)['bottom'],
      34.0,
    );
  });

  testWidgets('an older page: no name on its statuses, the loading words stay',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (_, __) {},
    )));
    await page.boot(tester);
    for (final kind in <String>['ready', 'held', 'released']) {
      page.evt('season.status', <String, Object?>{
        'kind': kind,
        'message': kind,
      });
      await _settle(tester);
      expect(find.text('Choose your seats'), findsOneWidget, reason: kind);
    }
    expect(
      (page.last('season.setViewportInsets').payload! as Map)['bottom'],
      34.0,
    );
  });

  testWidgets('mounted bare and held sideways it steps clear of the sides',
      (tester) async {
    useFakeWebViewPlatform();
    tester.view
      ..physicalSize = const Size(844, 390)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const sides = EdgeInsets.fromLTRB(59, 0, 47, 21);
    final picker = SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (_, __) {},
    );
    Widget held(Widget child) => MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(844, 390), padding: sides),
            child: child,
          ),
        );
    Rect place() => tester.getRect(find.byWidgetPredicate((w) => w is SeatLayerSeasonView));

    await tester.pumpWidget(held(picker));
    final bare = place();
    expect(bare.left, 59);
    expect(bare.right, 844 - 47);
    expect(
      tester.getRect(find.byTooltip('Close seat selection')).right,
      lessThanOrEqualTo(844 - 47),
    );

    // Inside a surface that has taken the sides nothing is taken twice.
    await tester.pumpWidget(held(SafeArea(bottom: false, child: picker)));
    expect(place(), bare);
  });

  testWidgets('a hold puts the clock in the header', (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
    )));
    await page.boot(tester);
    expect(find.byType(SeatLayerHoldClock), findsNothing);
    // Without onClose the way out is the host's.
    expect(find.byTooltip('Close seat selection'), findsNothing);

    page.evt(
        'season.hold', <String, Object?>{'handoff': seasonHandoff('sop_a')});
    await _settle(tester);
    expect(find.byType(SeatLayerHoldClock), findsOneWidget);
    expect(find.text('15:00'), findsOneWidget);

    page.evt('season.holdExpired', const <String, Object?>{});
    await _settle(tester);
    expect(find.byType(SeatLayerHoldClock), findsNothing);
  });

  testWidgets('close asks the page; stayed stays and kept closes',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    final closes = <(SeatLayerSeasonCloseOutcome, String?)>[];
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (outcome, operationId) => closes.add((outcome, operationId)),
    )));
    await page.boot(tester);

    // Back pressed twice: the second press is sent, and the page answers
    // both that the buyer stayed.
    await tester.tap(find.byTooltip('Close seat selection'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Close seat selection'));
    await _settle(tester);
    final asked =
        page.sent.where((e) => e.type == 'season.requestClose').toList();
    expect(asked, hasLength(2));
    for (final question in asked) {
      page.post(
        EnvelopeKind.res,
        'season.requestClose',
        <String, Object?>{'outcome': 'stayed'},
        id: question.id,
      );
    }
    await _settle(tester);
    expect(closes, isEmpty);

    await tester.tap(find.byTooltip('Close seat selection'));
    await _settle(tester);
    page.answer('season.requestClose', <String, Object?>{
      'outcome': 'kept',
      'operationId': 'sop_a',
    });
    await _settle(tester);
    expect(closes, <(SeatLayerSeasonCloseOutcome, String?)>[
      (SeatLayerSeasonCloseOutcome.kept, 'sop_a'),
    ]);
  });

  testWidgets(
      'a Season that cannot be shown gets the event picker\'s failure view; '
      'Retry boots a new page', (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    final closes = <SeatLayerSeasonCloseOutcome>[];
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (outcome, _) => closes.add(outcome),
    )));
    const words = SeatLayerPickerStrings();

    // season.html renders nothing for a Season it cannot mount and says so
    // instead of sys.ready.
    page.post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.0',
      'protocol': <String, Object?>{'min': 2, 'max': 2},
      'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
      'events': <String>[],
      'commands': <String>[],
    });
    await tester.pump();
    page.evt('sys.error', <String, Object?>{
      'code': 'not_found',
      'message': 'Season not found',
    });
    await _settle(tester);

    expect(find.byType(SeatLayerSeasonView), findsNothing);
    expect(find.byType(SeatLayerPickerErrorView), findsOneWidget);
    expect(find.text(words.mapDidNotLoad), findsOneWidget);
    expect(find.text(words.checkConnection), findsOneWidget);
    // The page's code and sentence are the app's (onError), not the buyer's.
    expect(find.textContaining('not_found'), findsNothing);
    expect(find.textContaining('Season not found'), findsNothing);
    // The bar stays, so the buyer still has the way out.
    expect(find.byType(SeatLayerHeaderBar), findsOneWidget);

    await tester.tap(find.text(words.retry));
    await _settle(tester);
    expect(find.byType(SeatLayerPickerErrorView), findsNothing);
    expect(
        fake.loads, <String>[seatLayerSeasonPageUrl, seatLayerSeasonPageUrl]);
    page.reloaded();
    await page.boot(tester);
    expect(page.sent.where((e) => e.kind == EnvelopeKind.init), hasLength(2));
    page.held('sop_a');
    await _settle(tester);
    expect(find.byType(SeatLayerHoldClock), findsOneWidget);
    expect(closes, isEmpty);
  });

  testWidgets('a page that never loads closes at once', (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    final closes = <SeatLayerSeasonCloseOutcome>[];
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
      onClose: (outcome, _) => closes.add(outcome),
    )));
    page.post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.0',
      'protocol': <String, Object?>{'min': 2, 'max': 2},
      'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
      'events': <String>[],
      'commands': <String>[],
    });
    await tester.pump();
    page.evt('sys.error', <String, Object?>{'code': 'render_failed'});
    await _settle(tester);
    expect(find.byType(SeatLayerPickerErrorView), findsOneWidget);

    await tester.tap(find.byTooltip('Close seat selection'));
    await _settle(tester);
    expect(page.sent.where((e) => e.type == 'season.requestClose'), isEmpty);
    expect(closes, <SeatLayerSeasonCloseOutcome>[
      SeatLayerSeasonCloseOutcome.closed,
    ]);
  });

  testWidgets('a theme flip repaints the page in place', (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    Widget picker() => SeatLayerSeasonPicker(
          configuration: seasonConfiguration,
          onContinue: (_) {},
        );
    await tester.pumpWidget(_app(picker()));
    await page.boot(tester);

    await tester.pumpWidget(_app(picker(), brightness: Brightness.dark));
    // MaterialApp animates between its themes.
    await tester.pump(const Duration(milliseconds: 300));
    await _settle(tester);
    expect(page.last('season.setThemeMode').payload,
        <String, Object?>{'mode': 'dark'});
    expect(fake.loads, hasLength(1));
  });

  testWidgets('the app going away and coming back is told to the page',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    await tester.pumpWidget(_app(SeatLayerSeasonPicker(
      configuration: seasonConfiguration,
      onContinue: (_) {},
    )));
    await page.boot(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(page.last('season.lifecycle').payload,
        <String, Object?>{'state': 'background'});
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(page.last('season.lifecycle').payload,
        <String, Object?>{'state': 'foreground'});
  });

  testWidgets('on a route: Back asks the page, Continue pops with the hold',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = SeasonPage(fake);
    final results = <SeatLayerSeasonHandoff?>[];
    final continued = <String>[];
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => results.add(await showSeatLayerSeasonPicker(
          context,
          configuration: seasonConfiguration,
          onContinue: (handoff) => continued.add(handoff.operationId),
        )),
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await page.boot(tester);

    // System Back is the page's question first.
    await tester.binding.handlePopRoute();
    await _settle(tester);
    expect(page.last('season.requestClose'), isNotNull);
    page.answer('season.requestClose', <String, Object?>{'outcome': 'stayed'});
    await tester.pumpAndSettle();
    expect(find.byType(SeatLayerSeasonPicker), findsOneWidget);

    page.evt('season.continue',
        <String, Object?>{'handoff': seasonHandoff('sop_a')});
    page.evt('season.continue',
        <String, Object?>{'handoff': seasonHandoff('sop_a')});
    await tester.pumpAndSettle();
    expect(continued, <String>['sop_a']);
    expect(results.single?.operationId, 'sop_a');
    expect(find.byType(SeatLayerSeasonPicker), findsNothing);
  });
}
