// A page that takes another's place is asked for the hold handed to checkout.
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_mark_booked.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_reload_hold.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_error.dart';

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
  _Picker({this.resumed});

  /// What the page answers to being asked for the hold.
  final Object? Function()? resumed;

  final booked = <SeatLayerCheckoutHandoff>[];

  late final FakePickerMap map = FakePickerMap(
    bundle: nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        seatLayerMarkBookedCapability,
      ],
    ),
    handler: (command, _) async => switch (command) {
      'picker.resumeHold' => resumed?.call(),
      seatLayerMarkBookedCommand => <String, Object?>{
          'booked': true,
          'status': 'booked',
          'holdId': 'hold-1',
          'revision': 3,
          'snapshot': pickerSnapshot(sessionId: 'session-2', revision: 3),
        },
      _ => <String, Object?>{
          'revision': 2,
          'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
          'handoff': _handoff(),
        },
    },
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

  /// A new page is up, with no hold of its own.
  Future<void> newPage({String session = 'session-2'}) async {
    map.emit(pickerSnapshot(sessionId: session));
    map.emitReady(ReadyInfo.fromJson(<String, Object?>{
      'protocol': 2,
      'mode': 'test',
      'transport': 'flutter',
    }));
    await settle();
  }

  Future<void> settle() async {
    for (var i = 0; i < 6; i += 1) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  int get asked => map.callsTo('picker.resumeHold').length;
}

Map<String, Object?> _taken({String session = 'session-2'}) =>
    <String, Object?>{
      'revision': 2,
      'snapshot': pickerSnapshot(
        sessionId: session,
        revision: 2,
        holdOwner: 'host',
      ),
    };

SeatLayerError _refused({Map<String, Object?>? details}) =>
    SeatLayerError.bridge(
      BridgeErrorPayload(
        code: 'command_failed',
        message: 'refused',
        details: details,
      ),
    );

void main() {
  group('a hold handed to checkout', () {
    test('is no sale because a settings change brought a new page', () async {
      final picker = _Picker(resumed: _taken);
      await picker.handOff();
      await picker.newPage();
      expect(picker.booked, isEmpty);
      expect(
        picker.map.callsTo('picker.resumeHold').single.$2,
        <String, Object?>{'holdId': 'hold-1'},
      );
      expect(picker.controller.state.hold, isNotNull);
      expect(picker.controller.state.checkoutHandoff?.holdId, 'hold-1');
    });

    test('is a sale when the new page has it and says it is booked', () async {
      final picker = _Picker(resumed: _taken);
      await picker.handOff();
      await picker.newPage();
      expect(await picker.controller.markBooked(), isTrue);
      expect(picker.booked.map((handoff) => handoff.holdId), ['hold-1']);
    });

    test('is let go of when the server says it is gone', () async {
      final picker = _Picker(
        resumed: () => throw _refused(
          details: <String, Object?>{
            'meta': <String, Object?>{'status': 404},
          },
        ),
      );
      await picker.handOff();
      await picker.newPage();
      expect(picker.asked, 1);
      expect(picker.booked, isEmpty);
      expect(picker.controller.state.checkoutHandoff, isNull);

      // A new page is not asked for it again.
      await picker.newPage(session: 'session-3');
      expect(picker.asked, 1);
    });

    test('is still asked for by the page after the next', () async {
      var up = false;
      final picker = _Picker(
        resumed: () => up
            ? _taken(session: 'session-3')
            : throw const SeatLayerError.transport('gone'),
      );
      await picker.handOff();
      await picker.newPage();
      expect(picker.controller.state.hold, isNull);
      up = true;
      await picker.newPage(session: 'session-3');
      expect(picker.asked, 2);
      expect(picker.controller.state.hold, isNotNull);
      expect(picker.booked, isEmpty);
    });

    test('is no sale after Try again', () async {
      final picker = _Picker(resumed: _taken);
      await picker.handOff();
      await picker.controller.retry();
      expect(picker.controller.state.hold, isNull);
      expect(picker.controller.state.checkoutHandoff?.holdId, 'hold-1');
      await picker.newPage();
      expect(picker.controller.state.hold, isNotNull);
      expect(picker.booked, isEmpty);
    });
  });

  test('a hold the picker owns is the server\'s to let go', () async {
    final picker = _Picker(resumed: _taken);
    addTearDown(picker.map.dispose);
    addTearDown(picker.controller.dispose);
    picker.controller;
    picker.map.emit(pickerSnapshot(holdOwner: 'picker'));
    await picker.newPage();
    expect(picker.asked, 0);
  });

  group('a resume nobody answered', () {
    late int asked;
    late List<String> gone;
    late bool holds;
    Object? failure;

    PickerReloadHold hold() {
      asked = 0;
      gone = <String>[];
      holds = false;
      failure = null;
      final reload = PickerReloadHold(
        holdIsActive: () => holds,
        resume: (_) async {
          asked += 1;
          if (failure != null) throw failure!;
          return true;
        },
        gone: gone.add,
      )..remember('hold-1');
      addTearDown(reload.forget);
      return reload;
    }

    testWidgets('is asked once more, then let go', (tester) async {
      final reload = hold();
      failure = _refused();
      reload.pageReady();
      await tester.pump();
      expect(asked, 1);
      expect(gone, isEmpty);
      await tester.pump(PickerReloadHold.retryAfter);
      await tester.pump();
      expect(asked, 2);
      expect(gone, ['hold-1']);
      await tester.pump(PickerReloadHold.retryAfter);
      expect(asked, 2);
    });

    testWidgets('takes the hold up the second time', (tester) async {
      final reload = hold();
      failure = const SeatLayerError.timeout(
        'picker.resumeHold',
        Duration(seconds: 45),
      );
      reload.pageReady();
      await tester.pump();
      failure = null;
      await tester.pump(PickerReloadHold.retryAfter);
      await tester.pump();
      expect(asked, 2);
      expect(gone, isEmpty);
    });

    testWidgets('leaves alone a hold the buyer made meanwhile',
        (tester) async {
      final reload = hold();
      failure = _refused();
      reload.pageReady();
      await tester.pump();
      holds = true;
      await tester.pump(PickerReloadHold.retryAfter);
      expect(asked, 1);
      expect(gone, isEmpty);
    });
  });
}
