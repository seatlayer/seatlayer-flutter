import 'package:flutter_test/flutter_test.dart';
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

FakePickerMap _map() => FakePickerMap(
      bundle: nativeChromeBundle(),
      handler: (command, payload) async => <String, Object?>{
        'revision': 2,
        'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
        'handoff': _handoff(),
      },
    );

SeatLayerPickerController _attach(
  FakePickerMap map, {
  SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
}) {
  final controller = SeatLayerPickerController(mapController: map);
  addTearDown(controller.dispose);
  controller.attach(
    configuration: SeatLayerConfiguration(event: 'ev_test'),
    options: const SeatLayerPickerOptions(),
    callbacks: callbacks,
  );
  return controller;
}

void main() {
  test('a handed-off hold that vanishes unannounced is a booking', () async {
    final map = _map();
    addTearDown(map.dispose);
    final booked = <SeatLayerCheckoutHandoff>[];
    final controller = _attach(
      map,
      callbacks: SeatLayerPickerCallbacks(onBooked: booked.add),
    );

    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();
    expect(controller.bookedHandoff, isNull);
    expect(booked, isEmpty);

    map.emit(pickerSnapshot(revision: 3));
    await Future<void>.delayed(Duration.zero);
    expect(controller.bookedHandoff?.holdId, 'hold-1');
    expect(booked.map((h) => h.holdId), ['hold-1']);

    // A later snapshot with the hold still gone does not tell it twice.
    map.emit(pickerSnapshot(revision: 4));
    await Future<void>.delayed(Duration.zero);
    expect(booked, hasLength(1));

    // A new live hold starts a new story.
    map.emit(pickerSnapshot(revision: 5, holdOwner: 'picker'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.bookedHandoff, isNull);
  });

  test('an announced expiry is not a booking', () async {
    final map = _map();
    addTearDown(map.dispose);
    final booked = <SeatLayerCheckoutHandoff>[];
    final controller = _attach(
      map,
      callbacks: SeatLayerPickerCallbacks(onBooked: booked.add),
    );

    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();
    map.emitEvent('hold.expired', null);
    await Future<void>.delayed(Duration.zero);
    map.emit(pickerSnapshot(revision: 3));
    await Future<void>.delayed(Duration.zero);

    expect(controller.bookedHandoff, isNull);
    expect(booked, isEmpty);
  });

  test('a hold that never left the picker is not a booking', () async {
    final map = _map();
    addTearDown(map.dispose);
    final controller = _attach(map);

    map.emit(pickerSnapshot(holdOwner: 'picker'));
    map.emit(pickerSnapshot(revision: 2));
    await Future<void>.delayed(Duration.zero);

    expect(controller.bookedHandoff, isNull);
  });
}
