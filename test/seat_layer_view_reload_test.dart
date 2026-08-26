import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';
import 'package:seatlayer/src/seat_layer_view.dart';

final class _ReloadController extends SeatLayerController {
  _ReloadController({this.gate});

  final Completer<void>? gate;
  final calls = <String>[];

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async {
    calls.add(command);
    await gate?.future;
    return <String, Object?>{'destroyed': true};
  }
}

void main() {
  test('picker config reload waits for acknowledged destroy', () async {
    final gate = Completer<void>();
    final oldController = _ReloadController(gate: gate);
    addTearDown(oldController.dispose);

    var completed = false;
    final reload = prepareSeatLayerRuntimeReload(
      oldController: oldController,
      oldProfile: SeatLayerBridgeProfile.picker(),
    ).then((_) => completed = true);
    await pumpEventQueue();

    expect(oldController.calls, <String>['picker.destroy']);
    expect(completed, isFalse);

    gate.complete();
    await reload;
    expect(completed, isTrue);
  });

  test('picker controller swap also destroys the old picker', () async {
    final oldController = _ReloadController();
    addTearDown(oldController.dispose);

    await prepareSeatLayerRuntimeReload(
      oldController: oldController,
      oldProfile: SeatLayerBridgeProfile.picker(),
    );

    expect(oldController.calls, <String>['picker.destroy']);
  });

  test('raw chart reload keeps the protocol-v1 detach path', () async {
    final oldController = _ReloadController();
    addTearDown(oldController.dispose);

    await prepareSeatLayerRuntimeReload(
      oldController: oldController,
      oldProfile: SeatLayerBridgeProfile.chart,
    );

    expect(oldController.calls, isEmpty);
  });
}
