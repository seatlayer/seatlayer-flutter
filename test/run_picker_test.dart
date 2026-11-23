// The run picker in the app: the event header over group.html, driven
// through a fake page that answers like runtime 1.0.0's.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_header.dart';

import 'fake_webview_platform.dart';
import 'run_harness.dart';

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
  testWidgets('the event header stands over group.html; the run names itself',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = RunPage(fake);
    await tester.pumpWidget(_app(SeatLayerRunPicker(
      configuration: runConfiguration,
      onContinue: (_) {},
      onClose: () {},
    )));

    expect(fake.loads, <String>[seatLayerRunPageUrl]);
    expect(find.text('Choose your seats'), findsOneWidget);
    expect(find.byTooltip('Close seat selection'), findsOneWidget);

    await page.boot(tester);
    final init = page.sent.firstWhere((e) => e.kind == EnvelopeKind.init);
    final payload = init.payload! as Map<String, Object?>;
    expect(payload['surface'], <String, Object?>{'kind': 'group'});
    final config = payload['config']! as Map;
    expect(config['theme'], 'light');
    expect(config['header'], isFalse);

    // group.ready carries the run's name at runtime 1.0.0.
    page.ready('The Lantern Keeper');
    await _settle(tester);
    expect(find.text('The Lantern Keeper'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);

    // The page takes no insets: the app keeps it above the home indicator.
    expect(
      tester.getRect(find.byType(SeatLayerRunView)).bottom,
      tester.getRect(find.byType(SeatLayerRunPicker)).bottom - 34,
    );
    expect(page.sent.where((e) => e.type.contains('Insets')), isEmpty);
  });

  testWidgets('a hold puts the clock in the header', (tester) async {
    final page = RunPage(useFakeWebViewPlatform());
    await tester.pumpWidget(_app(SeatLayerRunPicker(
      configuration: runConfiguration,
      onContinue: (_) {},
    )));
    await page.boot(tester);
    expect(find.byType(SeatLayerHoldClock), findsNothing);
    // Without onClose the way out is the host's.
    expect(find.byTooltip('Close seat selection'), findsNothing);

    page.held('pghop_a');
    await _settle(tester);
    expect(find.text('15:00'), findsOneWidget);

    page.evt('group.holdExpired', const <String, Object?>{});
    await _settle(tester);
    expect(find.byType(SeatLayerHoldClock), findsNothing);
  });

  testWidgets('close lets the page release what was not handed off, once',
      (tester) async {
    final page = RunPage(useFakeWebViewPlatform());
    var closed = 0;
    await tester.pumpWidget(_app(SeatLayerRunPicker(
      configuration: runConfiguration,
      onContinue: (_) {},
      onClose: () => closed++,
    )));
    await page.boot(tester);
    page.held('pghop_a');
    await _settle(tester);

    await tester.tap(find.byTooltip('Close seat selection'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Close seat selection'));
    await _settle(tester);
    expect(page.sent.where((e) => e.type == 'group.destroy'), hasLength(1));
    expect(closed, 0, reason: 'the release settles first');

    page.answer('group.destroy', <String, Object?>{'destroyed': true});
    await _settle(tester);
    expect(closed, 1);
  });

  testWidgets('a theme flip changes nothing: no reload, no command',
      (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = RunPage(fake);
    Widget picker() => SeatLayerRunPicker(
          configuration: runConfiguration,
          onContinue: (_) {},
        );
    await tester.pumpWidget(_app(picker()));
    await page.boot(tester);
    final sent = page.sent.length;

    await tester.pumpWidget(_app(picker(), brightness: Brightness.dark));
    await tester.pump(const Duration(milliseconds: 300));
    await _settle(tester);
    expect(fake.loads, hasLength(1));
    expect(page.sent, hasLength(sent));
    // The bar keeps the page's side.
    expect(
      tester.widget<SeatLayerHeaderBar>(find.byType(SeatLayerHeaderBar))
          .theme
          .brightness,
      Brightness.light,
    );
  });

  testWidgets('the app going away and coming back is told to the page',
      (tester) async {
    final page = RunPage(useFakeWebViewPlatform());
    await tester.pumpWidget(_app(SeatLayerRunPicker(
      configuration: runConfiguration,
      onContinue: (_) {},
    )));
    await page.boot(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(page.last('group.lifecycle').payload,
        <String, Object?>{'state': 'background'});
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(page.last('group.lifecycle').payload,
        <String, Object?>{'state': 'foreground'});
  });

  testWidgets(
      'a run that cannot be shown gets the event picker\'s failure view; '
      'Retry boots a new page', (tester) async {
    final fake = useFakeWebViewPlatform();
    final page = RunPage(fake);
    await tester.pumpWidget(_app(SeatLayerRunPicker(
      configuration: runConfiguration,
      onContinue: (_) {},
      onClose: () {},
    )));
    await page.fail(tester);
    await _settle(tester);
    const words = SeatLayerPickerStrings();
    expect(find.byType(SeatLayerPickerErrorView), findsOneWidget);
    expect(find.text(words.mapDidNotLoad), findsOneWidget);
    expect(find.byType(SeatLayerHeaderBar), findsOneWidget);

    await tester.tap(find.text(words.retry));
    await _settle(tester);
    expect(fake.loads, <String>[seatLayerRunPageUrl, seatLayerRunPageUrl]);
    page.reloaded();
    await page.boot(tester);
    page.ready('The Lantern Keeper');
    await _settle(tester);
    expect(find.text('The Lantern Keeper'), findsOneWidget);
  });

  testWidgets('on a route: Back closes, Continue pops with the hold once',
      (tester) async {
    final page = RunPage(useFakeWebViewPlatform());
    final results = <SeatLayerRunHandoff?>[];
    final continued = <String>[];
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => results.add(await showSeatLayerRunPicker(
          context,
          configuration: runConfiguration,
          onContinue: (handoff) => continued.add(handoff.operationId),
        )),
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await page.boot(tester);
    page.held('pghop_a');
    page.evt('group.checkout',
        <String, Object?>{'handoff': runHandoff('pghop_a')});
    page.evt('group.checkout',
        <String, Object?>{'handoff': runHandoff('pghop_a')});
    await tester.pumpAndSettle();
    expect(continued, <String>['pghop_a']);
    expect(results.single?.operationId, 'pghop_a');
    expect(find.byType(SeatLayerRunPicker), findsNothing);

    // Again, and this time Back: the page releases, then the route closes.
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    page.reloaded();
    await page.boot(tester);
    await tester.binding.handlePopRoute();
    await _settle(tester);
    page.answer('group.destroy', <String, Object?>{'destroyed': true});
    await tester.pumpAndSettle();
    expect(results, hasLength(2));
    expect(results.last, isNull);
    expect(find.byType(SeatLayerRunPicker), findsNothing);
  });
}
