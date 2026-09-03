import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

SeatLayerPickerController _attach(FakePickerMap map) {
  final controller = SeatLayerPickerController(mapController: map);
  addTearDown(controller.dispose);
  controller.attach(
    configuration: SeatLayerConfiguration(event: 'ev_test'),
    options: const SeatLayerPickerOptions(),
  );
  return controller;
}

Future<void> _drain() => Future<void>.delayed(Duration.zero);

void main() {
  test('the seats a hold arrives with are not asked about', () async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = _attach(map);

    map.emit(heldRowSnapshot(count: 2));
    await _drain();

    expect(controller.unansweredSeat, isNull,
        reason: 'a resumed hold, or a best-available pick, is authoritative');
  });

  test('a seat tapped while a hold is live is still asked about', () async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = _attach(map);

    map.emit(heldRowSnapshot(count: 2));
    await _drain();
    map.emit(heldRowSnapshot(count: 3, revision: 2));
    await _drain();

    expect(controller.unansweredSeat?.label, 'A-3',
        reason: 'the hold silenced every later tap; the web asks each time');
  });

  test('a card already open keeps its question when the hold arrives',
      () async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final controller = _attach(map);

    map.emit(snapshotWithTicketCount(1));
    await _drain();
    final asked = controller.unansweredSeat;
    expect(asked?.label, 'A-1');
    controller.setConfirmCardSeat(asked);

    map.emit(heldRowSnapshot(count: 1, revision: 2));
    await _drain();

    expect(controller.unansweredSeat?.label, 'A-1',
        reason: 'inspecting a seat did not press Add seat');
  });
}
