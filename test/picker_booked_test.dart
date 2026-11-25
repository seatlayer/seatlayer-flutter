// A sale is what the page says is a sale, never that a hold is gone.
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

/// A picker that has handed `hold-1` to checkout.
final class _Picker {
  final booked = <SeatLayerCheckoutHandoff>[];

  /// What the page answers to every command but the checkout.
  Map<String, Object?> Function(String command)? answer;

  late final FakePickerMap map = FakePickerMap(
    bundle: nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        seatLayerMarkBookedCapability,
      ],
    ),
    handler: (command, _) async => command == 'picker.continue'
        ? <String, Object?>{
            'revision': 2,
            'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
            'handoff': _handoff(),
          }
        : answer!(command),
  );

  late final SeatLayerPickerController controller =
      SeatLayerPickerController(mapController: map)
        ..attach(
          configuration: SeatLayerConfiguration(event: 'ev_test'),
          options: const SeatLayerPickerOptions(),
          callbacks: SeatLayerPickerCallbacks(onBooked: booked.add),
        );

  Future<void> handOff() async {
    addTearDown(map.dispose);
    addTearDown(controller.dispose);
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await controller.checkout();
  }

  Future<void> emit(Map<String, Object?> snapshot) async {
    map.emit(snapshot);
    await Future<void>.delayed(Duration.zero);
  }

  void expectNoSale() {
    expect(booked, isEmpty);
    expect(controller.bookedHandoff, isNull);
  }
}

void main() {
  group('no sale', () {
    test('a page loaded again, by a changed setting, starts without the hold',
        () async {
      final picker = _Picker();
      await picker.handOff();
      await picker.emit(pickerSnapshot(sessionId: 'session-2'));
      picker.expectNoSale();
    });

    test('nor when the buyer then lets go of seats picked on the new page',
        () async {
      final picker = _Picker();
      await picker.handOff();
      await picker.emit(pickerSnapshot(sessionId: 'session-2'));
      await picker.emit(
        pickerSnapshot(
          sessionId: 'session-2',
          revision: 2,
          holdOwner: 'picker',
        ),
      );
      await picker.emit(pickerSnapshot(sessionId: 'session-2', revision: 3));
      picker.expectNoSale();
    });

    test('the host rejects the checkout and the hold is let go', () async {
      final picker = _Picker()
        ..answer = (_) => <String, Object?>{
              'released': true,
              'revision': 3,
              'snapshot': pickerSnapshot(revision: 3),
            };
      await picker.handOff();
      await picker.controller
          .rejectCheckoutHandoff(picker.controller.state.checkoutHandoff!);
      picker.expectNoSale();
      expect(picker.controller.state.hold, isNull);
      expect(picker.controller.state.checkoutHandoff, isNull);
    });

    test('the hold was lost on the server and its seats went to another',
        () async {
      final picker = _Picker();
      await picker.handOff();
      await picker.emit(pickerSnapshot(revision: 3));
      picker.expectNoSale();
    });

    test('the hold ran out', () async {
      final picker = _Picker();
      await picker.handOff();
      picker.map.emitEvent('hold.expired', null);
      await picker.emit(pickerSnapshot(revision: 3));
      picker.expectNoSale();
    });

    test('a hold that never left the picker is let go', () async {
      final picker = _Picker();
      addTearDown(picker.map.dispose);
      addTearDown(picker.controller.dispose);
      picker.controller;
      await picker.emit(pickerSnapshot(holdOwner: 'picker'));
      await picker.emit(pickerSnapshot(revision: 2));
      picker.expectNoSale();
    });
  });

  test('the page says it is booked: told once, until a new hold', () async {
    final picker = _Picker()
      ..answer = (_) => <String, Object?>{
            'booked': true,
            'status': 'booked',
            'holdId': 'hold-1',
            'revision': 3,
            'snapshot': pickerSnapshot(revision: 3),
          };
    await picker.handOff();
    expect(await picker.controller.markBooked(), isTrue);
    expect(picker.booked.map((handoff) => handoff.holdId), ['hold-1']);
    expect(picker.controller.bookedHandoff?.holdId, 'hold-1');

    await picker.emit(pickerSnapshot(revision: 4));
    picker.answer = (_) => <String, Object?>{
          'booked': true,
          'status': 'already_booked',
          'holdId': 'hold-1',
          'revision': 4,
        };
    expect(await picker.controller.markBooked(), isTrue);
    expect(picker.booked, hasLength(1));

    await picker.emit(pickerSnapshot(revision: 5, holdOwner: 'picker'));
    expect(picker.controller.bookedHandoff, isNull);
  });

  test('a booked hold is told once, also after the buyer starts a second cart',
      () async {
    final picker = _Picker()
      ..answer = (_) => <String, Object?>{
            'booked': true,
            'status': 'booked',
            'holdId': 'hold-1',
            'revision': 3,
            'snapshot': pickerSnapshot(revision: 3),
          };
    await picker.handOff();
    expect(await picker.controller.markBooked(holdId: 'hold-1'), isTrue);
    expect(picker.booked, hasLength(1));
    expect(picker.controller.bookedHandoff?.holdId, 'hold-1');

    // The second cart, then your server says again that the first is booked.
    await picker.emit(pickerSnapshot(revision: 4, holdOwner: 'picker'));
    expect(picker.controller.bookedHandoff, isNull);
    picker.answer = (_) => <String, Object?>{
          'booked': true,
          'status': 'already_booked',
          'holdId': 'hold-1',
          'revision': 4,
        };
    expect(await picker.controller.markBooked(holdId: 'hold-1'), isTrue);
    expect(picker.booked, hasLength(1));
    expect(picker.controller.bookedHandoff, isNull);
  });

  test('a booking of another hold is not this checkout\'s', () async {
    final picker = _Picker()
      ..answer = (_) => <String, Object?>{
            'booked': true,
            'status': 'booked',
            'holdId': 'hold-2',
            'revision': 3,
            'snapshot': pickerSnapshot(revision: 3),
          };
    await picker.handOff();
    expect(await picker.controller.markBooked(holdId: 'hold-2'), isTrue);
    picker.expectNoSale();
  });
}
