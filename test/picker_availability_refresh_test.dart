// A picker that has been away cannot trust what it last saw.
//
// The buyer leaves for a payment sheet, a call, a password manager. Nothing on
// the device is running to notice that somebody else took the seat they had
// selected, or that their own fifteen minutes ran out. `picker.refreshAvailability`
// asks the server what is true now, and the answer — not the local countdown —
// is what the picker acts on.
//
// The invariant these tests exist to protect: a refresh never costs the buyer
// anything they already own. Their held seats read as `held` on the server
// because THEY hold them, and a refresh that treated that as a loss would empty
// the cart of the one buyer it was meant to help.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_availability.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// A controller bound to [map], already holding a snapshot.
///
/// The emitted snapshot travels a broadcast stream, so the controller is only
/// ready one microtask later — awaited here so every test below starts from a
/// live session rather than an initializing one.
Future<SeatLayerPickerController> _ready(
  FakePickerMap map, {
  Map<String, Object?>? snapshot,
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
}) async {
  final controller = SeatLayerPickerController(mapController: map);
  addTearDown(controller.dispose);
  controller.attach(
    configuration: SeatLayerConfiguration(event: 'ev_test'),
    options: options,
    callbacks: callbacks,
  );
  map.emit(snapshot ?? pickerSnapshot());
  await Future<void>.delayed(Duration.zero);
  return controller;
}

void main() {
  test('a runtime that cannot refresh is asked nothing, and does not fail',
      () async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = await _ready(map);

    final result = await controller.refreshAvailability();

    expect(result.refreshed, isFalse);
    expect(result.isQuiet, isTrue);
    expect(map.callsTo('picker.refreshAvailability'), isEmpty);
    expect(controller.state.error, isNull);
  });

  test('two overlapping refreshes are one round trip', () async {
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(),
    );
    addTearDown(map.dispose);
    final controller = await _ready(map);

    final first = controller.refreshAvailability();
    final second = controller.refreshAvailability();
    expect(identical(first, second), isTrue);
    await first;

    expect(map.callsTo('picker.refreshAvailability'), hasLength(1));
  });

  test('a refresh never puts the picker in a busy state', () async {
    var busyDuringCall = false;
    late SeatLayerPickerController controller;
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async {
        busyDuringCall = busyDuringCall || controller.state.isBusy;
        return availabilityRefresh();
      },
    );
    addTearDown(map.dispose);
    controller = await _ready(map);

    await controller.refreshAvailability();

    expect(
      busyDuringCall,
      isFalse,
      reason: 'a background refresh that greyed the chrome would read as the '
          'picker breaking every time the buyer came back',
    );
  });

  test(
      'a refresh over the buyer\'s own three held seats leaves them, and takes '
      'the one somebody else bought', () async {
    final labels = <String>[];
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(
        snapshot: heldRowSnapshot(revision: 4),
        lost: const <String>['A-4'],
        revision: 4,
      ),
    );
    addTearDown(map.dispose);
    final controller = await _ready(
      map,
      snapshot: heldRowSnapshot(),
      callbacks: SeatLayerPickerCallbacks(
        onSelectedObjectUnavailable: (event) => labels.addAll(event.labels),
      ),
    );
    final totalBefore = controller.state.snapshot!.cartTotal;

    final result = await controller.refreshAvailability();

    expect(
      controller.state.selection.map((seat) => seat.label),
      containsAll(<String>['A-1', 'A-2', 'A-3']),
      reason: 'the server calls these held because this buyer holds them',
    );
    expect(controller.state.snapshot!.cartTotal, totalBefore);
    expect(controller.state.hold, isNotNull);
    expect(result.lostLabels, <String>['A-4']);
    expect(
      labels,
      <String>['A-4'],
      reason: 'a seat lost in the background reaches the same host callback a '
          'seat lost in the foreground does',
    );
    expect(controller.holdLapse, isNull);
  });

  test('a still-valid hold survives a resume untouched', () async {
    var holdExpired = 0;
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(
          snapshot: heldRowSnapshot(revision: 4), revision: 4),
    );
    addTearDown(map.dispose);
    final controller = await _ready(
      map,
      snapshot: heldRowSnapshot(),
      callbacks:
          SeatLayerPickerCallbacks(onHoldExpired: () => holdExpired += 1),
    );
    final expiry = controller.state.hold!.expiresAt;

    final result = await controller.refreshAvailability();

    expect(result.holdLapsed, isFalse);
    expect(controller.holdLapse, isNull);
    expect(holdExpired, 0);
    expect(controller.state.hold!.expiresAt, expiry);
    expect(controller.state.selection, hasLength(3));
  });

  group('a hold that lapsed while the app was away', () {
    Future<SeatLayerPickerController> lapse(
      FakePickerMap map, {
      SeatLayerPickerOptions options = const SeatLayerPickerOptions(
        holdTtl: Duration(minutes: 15),
      ),
      SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
    }) async {
      final controller = await _ready(
        map,
        snapshot: heldRowSnapshot(),
        options: options,
        callbacks: callbacks,
      );
      await controller.refreshAvailability();
      return controller;
    }

    FakePickerMap lapsingMap(List<String> recoverable) => FakePickerMap(
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
                      'snapshot': heldRowSnapshot(revision: 5),
                    },
        );

    test('is believed over the local countdown, and clears the selection',
        () async {
      var holdExpired = 0;
      final map = lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
      addTearDown(map.dispose);
      final controller = await lapse(
        map,
        callbacks:
            SeatLayerPickerCallbacks(onHoldExpired: () => holdExpired += 1),
      );

      expect(controller.state.hold, isNull);
      expect(controller.state.selection, isEmpty);
      expect(controller.state.snapshot!.cartTotal, 0);
      expect(holdExpired, 1);
      expect(controller.holdLapse, isNotNull);
      expect(controller.holdLapse!.heldFor, const Duration(minutes: 15));
    });

    test('offers every seat back when every seat is still free', () async {
      final map = lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
      addTearDown(map.dispose);
      final controller = await lapse(map);

      expect(controller.holdLapse!.recovery, SeatLayerRecovery.all);
      expect(controller.holdLapse!.unrecoveredCount, 0);

      await controller.reselectLapsedSeats();

      final call = map.callsTo('picker.selectObjects').single;
      expect(
        (call.$2! as Map<String, Object?>)['objects'],
        <String>['A-1', 'A-2', 'A-3'],
      );
      expect(controller.holdLapse, isNull);
    });

    test('offers back only what is free, and says how many are gone', () async {
      final map = lapsingMap(const <String>['A-1']);
      addTearDown(map.dispose);
      final controller = await lapse(map);

      expect(controller.holdLapse!.recovery, SeatLayerRecovery.partial);
      expect(controller.holdLapse!.unrecoveredCount, 2);

      await controller.reselectLapsedSeats();

      expect(
        (map.callsTo('picker.selectObjects').single.$2!
            as Map<String, Object?>)['objects'],
        <String>['A-1'],
      );
    });

    test('leaves the buyer on the map when nothing can be recovered', () async {
      final map = lapsingMap(const <String>[]);
      addTearDown(map.dispose);
      final controller = await lapse(map);

      expect(controller.holdLapse!.recovery, SeatLayerRecovery.none);

      await controller.reselectLapsedSeats();

      expect(map.callsTo('picker.selectObjects'), isEmpty);
      expect(controller.state.phase.name, 'ready');
    });

    test('a seat the runtime did not lapse is never offered back', () async {
      final map = lapsingMap(const <String>['A-1', 'B-9']);
      addTearDown(map.dispose);
      final controller = await lapse(map);

      expect(
        controller.holdLapse!.recoverableLabels,
        <String>['A-1'],
        reason: 'B-9 was never this buyer\'s seat',
      );
    });

    test('announceHoldLapse: false still tells the host', () async {
      var holdExpired = 0;
      final map = lapsingMap(const <String>['A-1', 'A-2', 'A-3']);
      addTearDown(map.dispose);
      final controller = await lapse(
        map,
        options: const SeatLayerPickerOptions(
          holdTtl: Duration(minutes: 15),
          announceHoldLapse: false,
        ),
        callbacks:
            SeatLayerPickerCallbacks(onHoldExpired: () => holdExpired += 1),
      );

      expect(holdExpired, 1);
      expect(
        controller.holdLapse,
        isNotNull,
        reason: 'the option hides the built-in message, not the fact; a '
            'composed layout still reads it',
      );
    });

    test('the same lapse is announced once, however often it is re-read',
        () async {
      var holdExpired = 0;
      final map = lapsingMap(const <String>[]);
      addTearDown(map.dispose);
      final controller = await lapse(
        map,
        callbacks:
            SeatLayerPickerCallbacks(onHoldExpired: () => holdExpired += 1),
      );

      // A second resume, still with no hold: the server says the same thing
      // and the buyer must not be told a second time.
      await controller.refreshAvailability();

      expect(holdExpired, 1);
      expect(controller.holdLapse, isNotNull);
    });
  });

  testWidgets('coming back to the front refreshes instead of synchronizing',
      (tester) async {
    final map = FakePickerMap(
      bundle: refreshingBundle(),
      handler: (command, payload) async => availabilityRefresh(),
    );
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(
        map,
        SeatLayerPickerAdaptiveLayout(
          onCheckout: (_) async {},
        )));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.lifecycle'), hasLength(1));
    expect(map.callsTo('picker.refreshAvailability'), hasLength(1));
    expect(
      map.callsTo('picker.getSnapshot'),
      isEmpty,
      reason: 'the refresh already answered with a snapshot; asking again is '
          'a second round trip and a second revision for one answer',
    );
  });

  testWidgets('refreshOnResume: false asks for nothing', (tester) async {
    final map = FakePickerMap(bundle: refreshingBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {}),
        options: const SeatLayerPickerOptions(refreshOnResume: false),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.refreshAvailability'), isEmpty);
    expect(
      map.callsTo('picker.getSnapshot'),
      hasLength(1),
      reason: 'the pre-existing resume synchronize is not part of the opt-out',
    );
  });
}
