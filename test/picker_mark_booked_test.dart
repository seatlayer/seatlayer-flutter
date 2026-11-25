// The host's server booked the hold, and says so.
//
// The runtime settles the hold at once and answers that it is booked; the
// booked rule follows that answer.
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_mark_booked.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Map<String, Object?> _handoff() => <String, Object?>{
      'holdId': 'hold-1',
      'expiresAt': 1999999999000.0,
      'currency': 'EUR',
      'total': 25.0,
      'lineItems': <Object?>[],
    };

/// A runtime that takes `picker.markBooked`.
final _marking = nativeChromeBundle(
  capabilities: const <String>[
    'native-chrome-contract-v1',
    'viewport-insets-v1',
    seatLayerMarkBookedCapability,
  ],
);

/// Hands off `hold-1` on checkout and answers `picker.markBooked` with [mark].
FakePickerMap _map({
  required Object? Function(Object? payload) mark,
  bool advertises = true,
}) =>
    FakePickerMap(
      bundle: advertises ? _marking : nativeChromeBundle(),
      handler: (command, payload) async {
        if (command == seatLayerMarkBookedCommand) return mark(payload);
        return <String, Object?>{
          'revision': 2,
          'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
          'handoff': _handoff(),
        };
      },
    );

/// The runtime's answer once it has settled `hold-1`: the hold is gone.
Object? _booked(Object? _) => <String, Object?>{
      'booked': true,
      'status': 'booked',
      'holdId': 'hold-1',
      'revision': 3,
      'snapshot': pickerSnapshot(revision: 3),
    };

SeatLayerPickerController _attach(
  FakePickerMap map, {
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
}) {
  final controller = SeatLayerPickerController(mapController: map);
  addTearDown(controller.dispose);
  controller.attach(
    configuration: SeatLayerConfiguration(event: 'ev_test'),
    options: options,
    callbacks: callbacks,
  );
  return controller;
}

void main() {
  test('a runtime without hold-mark-booked-v1 is never asked', () async {
    final map = _map(mark: _booked, advertises: false);
    addTearDown(map.dispose);
    final controller = _attach(map);
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();

    expect(controller.supportsMarkBooked, isFalse);
    expect(await controller.markBooked(), isFalse);
    expect(map.callsTo(seatLayerMarkBookedCommand), isEmpty);
    expect(controller.bookedHandoff, isNull);
  });

  test(
    'the handed-off hold, booked by the host, settles on the reply',
    () async {
      final map = _map(mark: _booked);
      addTearDown(map.dispose);
      final booked = <SeatLayerCheckoutHandoff>[];
      final controller = _attach(
        map,
        callbacks: SeatLayerPickerCallbacks(onBooked: booked.add),
      );
      map.emit(pickerSnapshot(holdOwner: 'host'));
      await controller.checkout();
      expect(controller.bookedHandoff, isNull);

      expect(await controller.markBooked(), isTrue);

      // No id means the hand-off hold: nothing else is named on the wire.
      expect(
        map.callsTo(seatLayerMarkBookedCommand).single.$2,
        <String, Object?>{},
      );
      expect(controller.bookedHandoff?.holdId, 'hold-1');
      expect(booked.map((h) => h.holdId), <String>['hold-1']);

      // The runtime's own snapshot after it does not tell it twice.
      map.emit(pickerSnapshot(revision: 4));
      await Future<void>.delayed(Duration.zero);
      expect(booked, hasLength(1));
    },
  );

  test('a named hold travels as holdId', () async {
    final map = _map(mark: _booked);
    addTearDown(map.dispose);
    final controller = _attach(map);
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();

    expect(await controller.markBooked(holdId: 'hold-1'), isTrue);
    expect(map.callsTo(seatLayerMarkBookedCommand).single.$2, <String, Object?>{
      'holdId': 'hold-1',
    });
  });

  test('already booked is still booked', () async {
    final map = _map(
      mark: (_) => <String, Object?>{
        'booked': true,
        'status': 'already_booked',
        'holdId': 'hold-1',
        'revision': 2,
      },
    );
    addTearDown(map.dispose);
    final controller = _attach(map);
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();

    expect(await controller.markBooked(), isTrue);
  });

  test('another hold changes nothing', () async {
    final map = _map(
      mark: (_) => <String, Object?>{
        'booked': false,
        'status': 'different_hold',
        'revision': 2,
      },
    );
    addTearDown(map.dispose);
    final booked = <SeatLayerCheckoutHandoff>[];
    final controller = _attach(
      map,
      callbacks: SeatLayerPickerCallbacks(onBooked: booked.add),
    );
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();

    expect(await controller.markBooked(holdId: 'hold-other'), isFalse);
    expect(controller.bookedHandoff, isNull);
    expect(booked, isEmpty);
    expect(controller.state.hold?.active, isTrue);
  });

  test('a read-only picker may still mark a hold booked', () async {
    final map = _map(mark: _booked);
    addTearDown(map.dispose);
    final controller = _attach(
      map,
      options: const SeatLayerPickerOptions(readOnly: true),
    );
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await Future<void>.delayed(Duration.zero);

    expect(await controller.markBooked(holdId: 'hold-1'), isTrue);
    expect(map.callsTo(seatLayerMarkBookedCommand), hasLength(1));
    expect(controller.state.error, isNull);
  });
}
