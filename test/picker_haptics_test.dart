import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/picker/picker_haptics.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';

import 'picker_test_fixture.dart';

/// A snapshot with the three things the policy watches dialled independently.
///
/// Built by editing the shared fixture rather than by hand, so a change to the
/// snapshot's wire shape breaks these tests in the same place it breaks
/// everything else.
SeatLayerPickerSnapshot _snapshot({
  int revision = 1,
  String sessionId = 'session-1',
  int seats = 0,
  String? focusedSectionId = 'section-a',
  bool holdActive = false,
}) {
  final raw = Map<String, Object?>.from(
    pickerSnapshot(
      revision: revision,
      sessionId: sessionId,
      holdOwner: holdActive ? 'picker' : null,
      withSelection: seats > 0,
    ),
  );

  final map = Map<String, Object?>.from(raw['map']! as Map<String, Object?>);
  if (focusedSectionId == null) {
    map.remove('focusedSection');
    map.remove('focusedSectionId');
  } else {
    map['focusedSection'] = <String, Object?>{
      'id': focusedSectionId,
      'label': focusedSectionId,
    };
    map['focusedSectionId'] = focusedSectionId;
  }
  raw['map'] = map;

  final selection =
      Map<String, Object?>.from(raw['selection']! as Map<String, Object?>);
  final template = (selection['seats']! as List<Object?>).isEmpty
      ? null
      : (selection['seats']! as List<Object?>).first as Map<String, Object?>;
  selection['seats'] = <Object?>[
    for (var i = 0; i < seats; i++)
      <String, Object?>{
        ...?template,
        'id': 'seat-$i',
        'label': 'A-$i',
      },
  ];
  raw['selection'] = selection;

  final decoded = SeatLayerPickerSnapshot.fromJson(raw);
  if (decoded == null) throw StateError('fixture did not decode');
  return decoded;
}

final class _FakeMapController extends SeatLayerController {
  final events = StreamController<EventSignal>.broadcast();
  final expiries = StreamController<void>.broadcast();

  @override
  Stream<EventSignal> get onBridgeEvent => events.stream;

  @override
  Stream<void> get onHoldExpired => expiries.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async =>
      null;

  void emit(Map<String, Object?> snapshot, {int sequence = 1}) {
    events.add(
      EventSignal(
        name: 'picker.snapshot',
        payload: <String, Object?>{'snapshot': snapshot},
        sequence: sequence,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(events.close());
    unawaited(expiries.close());
    super.dispose();
  }
}

void main() {
  group('PickerHapticsPolicy', () {
    test('the first snapshot never fires', () {
      final policy = PickerHapticsPolicy();
      // A buyer returning to a picker that already has a focused section, a
      // selection and a resumed hold has not just done any of those things.
      expect(
        policy.onSnapshot(
          _snapshot(seats: 3, focusedSectionId: 'section-a', holdActive: true),
        ),
        isEmpty,
      );
    });

    test('only a GROWING selection is worth a cue', () {
      final policy = PickerHapticsPolicy();
      policy.onSnapshot(_snapshot(seats: 1));
      expect(
        policy.onSnapshot(_snapshot(revision: 2, seats: 2)),
        <PickerHapticCue>[PickerHapticCue.selectionAdded],
      );
      // Removals arrive in bulk when a hold lapses, and a burst of clicks for
      // seats being taken away reads as the app celebrating a loss.
      expect(policy.onSnapshot(_snapshot(revision: 3, seats: 0)), isEmpty);
    });

    test('a section fires on arrival, and the overview stays silent', () {
      final policy = PickerHapticsPolicy();
      policy.onSnapshot(_snapshot(focusedSectionId: null));
      expect(
        policy.onSnapshot(_snapshot(revision: 2, focusedSectionId: 'sec-b')),
        <PickerHapticCue>[PickerHapticCue.sectionFocused],
      );
      // Same section again is not a change of place.
      expect(
        policy.onSnapshot(_snapshot(revision: 3, focusedSectionId: 'sec-b')),
        isEmpty,
      );
      // Going back to the overview is a step BACK — the buyer already felt the
      // tap that took them there.
      expect(
        policy.onSnapshot(_snapshot(revision: 4, focusedSectionId: null)),
        isEmpty,
      );
    });

    test('a hold fires on the transition, not on every snapshot that has one',
        () {
      final policy = PickerHapticsPolicy();
      policy.onSnapshot(_snapshot());
      expect(
        policy.onSnapshot(_snapshot(revision: 2, holdActive: true)),
        <PickerHapticCue>[PickerHapticCue.holdCreated],
      );
      expect(
        policy.onSnapshot(_snapshot(revision: 3, holdActive: true)),
        isEmpty,
      );
      // Losing a hold is silent; taking a new one fires again.
      expect(policy.onSnapshot(_snapshot(revision: 4)), isEmpty);
      expect(
        policy.onSnapshot(_snapshot(revision: 5, holdActive: true)),
        <PickerHapticCue>[PickerHapticCue.holdCreated],
      );
    });

    test('reset re-seeds, so a reload does not replay the session', () {
      final policy = PickerHapticsPolicy();
      policy.onSnapshot(_snapshot());
      policy.reset();
      expect(
        policy.onSnapshot(
          _snapshot(seats: 2, focusedSectionId: 'sec-c', holdActive: true),
        ),
        isEmpty,
      );
    });
  });

  group('controller wiring', () {
    test('fires through the snapshot stream, once per change', () async {
      final map = _FakeMapController();
      final picker = SeatLayerPickerController(mapController: map);
      final fired = <PickerHapticCue>[];
      picker.playHaptic = fired.add;
      picker.attach(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        options: const SeatLayerPickerOptions(),
      );
      addTearDown(() {
        picker.dispose();
        map.dispose();
      });

      map.emit(pickerSnapshot(withSelection: false));
      await pumpEventQueue();
      expect(fired, isEmpty, reason: 'the first snapshot seeds, it never fires');

      map.emit(pickerSnapshot(revision: 2, holdOwner: 'picker'), sequence: 2);
      await pumpEventQueue();
      expect(fired, contains(PickerHapticCue.holdCreated));
    });

    test('a lapsed hold is the heaviest cue, and the only uninvited one',
        () async {
      final map = _FakeMapController();
      final picker = SeatLayerPickerController(mapController: map);
      final fired = <PickerHapticCue>[];
      picker.playHaptic = fired.add;
      picker.attach(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        options: const SeatLayerPickerOptions(),
      );
      addTearDown(() {
        picker.dispose();
        map.dispose();
      });

      // Deliberately not derived from the snapshot: a hold going inactive
      // looks identical whether it lapsed or the buyer let it go on purpose.
      map.expiries.add(null);
      await pumpEventQueue();
      expect(fired, <PickerHapticCue>[PickerHapticCue.holdExpired]);
    });

    test('haptics: false stays silent', () async {
      final map = _FakeMapController();
      final picker = SeatLayerPickerController(mapController: map);
      final fired = <PickerHapticCue>[];
      picker.playHaptic = fired.add;
      picker.attach(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        options: const SeatLayerPickerOptions(haptics: false),
      );
      addTearDown(() {
        picker.dispose();
        map.dispose();
      });

      map.emit(pickerSnapshot(withSelection: false));
      await pumpEventQueue();
      map.emit(pickerSnapshot(revision: 2, holdOwner: 'picker'), sequence: 2);
      await pumpEventQueue();
      expect(fired, isEmpty);
    });
  });
}
