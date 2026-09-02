// A hold that ends while the buyer is away has to be said out loud.
//
// Until now the SDK fired a haptic and `onHoldExpired` and showed the buyer
// nothing, which is fine while they are watching the countdown and useless
// after a background — where the in-app timer may never have fired at all. The
// buyer comes back to a cart that is simply empty, with no account of why.
//
// One line in the cart sheet and one toast. No dialog: they have just returned
// from somewhere else, and a modal is one more thing between them and the
// answer to the question they came back with.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Future<void> _noopCheckout(_) async {}

Widget _sheet() => SeatLayerCartSheet(
      expanded: false,
      onExpandedChanged: (_) {},
      onCheckout: _noopCheckout,
    );

/// A runtime whose hold has lapsed, leaving [recoverable] free.
FakePickerMap _lapsingMap(List<String> recoverable) => FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async =>
          command == 'picker.refreshAvailability'
              ? availabilityRefresh(
                  snapshot: lapsedRowSnapshot(revision: 4),
                  holdLapsed: true,
                  lapsedLabels: const <String>['A-1', 'A-2', 'A-3'],
                  recoverable: recoverable,
                  revision: 4,
                )
              : <String, Object?>{
                  'revision': 5,
                  'snapshot': lapsedRowSnapshot(revision: 5),
                },
    );

const SeatLayerPickerOptions _fifteenMinutes = SeatLayerPickerOptions(
  holdTtl: Duration(minutes: 15),
);

/// Mount the cart sheet over a held cart, then let the hold lapse.
Future<SeatLayerPickerController> _lapse(
  WidgetTester tester,
  FakePickerMap map, {
  SeatLayerPickerOptions options = _fifteenMinutes,
  Brightness platformBrightness = Brightness.light,
  Widget Function(Widget sheet)? frame,
}) async {
  final controller = SeatLayerPickerController(mapController: map);
  final sheet = frame == null ? _sheet() : frame(_sheet());
  await tester.pumpWidget(
    pickerHarness(
      map,
      Align(alignment: Alignment.bottomCenter, child: sheet),
      controller: controller,
      options: options,
      platformBrightness: platformBrightness,
    ),
  );
  map.emit(heldRowSnapshot());
  await pumpToRest(tester);
  await controller.refreshAvailability();
  await pumpToRest(tester);
  return controller;
}

void main() {
  testWidgets('the sheet says what happened, and offers the seats back',
      (tester) async {
    final map = _lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _lapse(tester, map);

    expect(find.text('Your seats were released.'), findsWidgets);
    expect(find.text('They were held for 15 minutes.'), findsOneWidget);
    expect(find.text('Select them again'), findsOneWidget);
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: 'a returning buyer must not be met by a modal',
    );

    await tester.tap(find.text('Select them again'));
    await pumpToRest(tester);

    expect(
      (map.callsTo('picker.selectObjects').single.$2!
          as Map<String, Object?>)['objects'],
      <String>['A-1', 'A-2', 'A-3'],
    );
    expect(find.text('Select them again'), findsNothing);
  });

  testWidgets('the toast carries the lapse telling for a full recovery',
      (tester) async {
    final map = _lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    final controller = await _lapse(tester, map);

    // The toast and the tray line are two surfaces for one fact, so the
    // sentence is raised on the picker's own queue rather than on Material's
    // snack bar, which paints a white slab across a dark picker.
    final toast = seatLayerPickerToasts(controller).current;
    expect(
        toast!.message,
        'Your hold ended while you were away. '
        'Those seats are still free.');
    expect(toast.tone, SeatLayerPickerToastTone.warning);
    expect(toast.actionLabel, 'Select them again');
  });

  testWidgets('a partial recovery says how many are gone', (tester) async {
    final map = _lapsingMap(const <String>['A-1']);
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _lapse(tester, map);

    expect(
      find.text('They were held for 15 minutes. 2 could not be recovered'),
      findsOneWidget,
    );
    // Three lapsed, one is still free, and the offer is counted on what it
    // would RE-TAKE — so it is singular even though the hold was not.
    expect(find.text('Select it again'), findsOneWidget);
    expect(find.text('Select them again'), findsNothing);

    await tester.tap(find.text('Select it again'));
    await pumpToRest(tester);
    expect(
      (map.callsTo('picker.selectObjects').single.$2!
          as Map<String, Object?>)['objects'],
      <String>['A-1'],
    );
  });

  testWidgets('nothing recoverable leaves the buyer on the map',
      (tester) async {
    final map = _lapsingMap(const <String>[]);
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _lapse(tester, map);

    expect(find.text('Your seats were released.'), findsWidgets);
    expect(
      find.text('Select them again'),
      findsNothing,
      reason: 'offering seats that are gone is worse than offering nothing',
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await pumpToRest(tester);
    expect(find.text('Your seats were released.'), findsNothing);
  });

  testWidgets('a hold that is still good says nothing at all', (tester) async {
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(
        snapshot: heldRowSnapshot(revision: 4),
        revision: 4,
      ),
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    final controller = await _lapse(tester, map);

    expect(find.text('Your seats were released.'), findsNothing);
    expect(seatLayerPickerToasts(controller).current, isNull);
    expect(controller.state.hold, isNotNull);
    expect(controller.state.selection, hasLength(3));
  });

  testWidgets('announceHoldLapse: false draws nothing', (tester) async {
    final map = _lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    final controller = await _lapse(
      tester,
      map,
      options: const SeatLayerPickerOptions(
        holdTtl: Duration(minutes: 15),
        announceHoldLapse: false,
      ),
    );

    expect(find.text('Your seats were released.'), findsNothing);
    expect(seatLayerPickerToasts(controller).current, isNull);
    expect(controller.holdLapse, isNotNull);
  });

  testWidgets('a pushed route popping back re-reads availability',
      (tester) async {
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(),
    );
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    final controller = SeatLayerPickerController(mapController: map);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        navigatorObservers: <NavigatorObserver>[SeatLayerPicker.routeObserver],
        home: SeatLayerPicker(
          configuration: SeatLayerConfiguration(event: 'ev_test'),
          controller: controller,
          onCheckout: _noopCheckout,
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);
    final before = map.callsTo('picker.refreshAvailability').length;

    // The host's own checkout screen, over the still-mounted picker. Nothing
    // backgrounds, so no lifecycle event fires and only the route observer can
    // notice the buyer is back.
    unawaited(
      navigator.currentState!.push<void>(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      ),
    );
    await pumpToRest(tester);
    navigator.currentState!.pop();
    await pumpToRest(tester);

    expect(map.callsTo('picker.refreshAvailability'), hasLength(before + 1));
  });

  testWidgets('no registered observer is not an error', (tester) async {
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(),
    );
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: SeatLayerPicker(
          configuration: SeatLayerConfiguration(event: 'ev_test'),
          controller: SeatLayerPickerController(mapController: map),
          onCheckout: _noopCheckout,
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    unawaited(
      navigator.currentState!.push<void>(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      ),
    );
    await pumpToRest(tester);
    navigator.currentState!.pop();
    await pumpToRest(tester);

    expect(tester.takeException(), isNull);
    expect(map.callsTo('picker.refreshAvailability'), isEmpty);
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('cart sheet lapsed — ${brightness.name}', (tester) async {
        final map = _lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await _lapse(
          tester,
          map,
          platformBrightness: brightness,
          frame: goldenSubject,
        );

        await expectGolden(tester, 'cart_sheet_lapsed_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
