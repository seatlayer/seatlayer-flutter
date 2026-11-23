// The run controller over group.html's contract
// (seatlayer-group-surface-v1.json, runtime 1.0.0), against a fake page.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/run/run_configuration.dart';
import 'package:seatlayer/src/run/run_models.dart';
import 'package:seatlayer/src/run/seat_layer_run_controller.dart';
import 'package:seatlayer/src/seat_layer_error.dart';

import 'run_harness.dart';

final class _Page implements BridgeChannel {
  final sent = <Envelope>[];

  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);
}

String _frame(EnvelopeKind kind, String type, Object? payload,
        {int? n, String? id}) =>
    Envelope(kind: kind, type: type, sequence: n, id: id, payload: payload)
        .encode();

void main() {
  late SeatLayerRunController run;
  late _Page page;
  var n = 0;

  void evt(String type, Object? payload) =>
      run.ingestRaw(_frame(EnvelopeKind.evt, type, payload, n: ++n));

  Future<void> boot({
    SeatLayerRunConfiguration? configuration,
    Map<String, Object?> hello = runHello,
  }) async {
    unawaited(run
        .beginHandshake(
          page,
          configuration ??
              SeatLayerRunConfiguration(run: 'pg_test', locale: 'de'),
          profile: SeatLayerBridgeProfile.group(
            config: const <String, Object?>{'theme': 'dark'},
          ),
        )
        .then<void>((_) {}, onError: (Object _) {}));
    run.ingestRaw(_frame(EnvelopeKind.hello, 'hello', hello));
    await pumpEventQueue();
  }

  Future<void> answer(Object? result) async {
    final command = page.sent.last;
    run.ingestRaw(
      _frame(EnvelopeKind.res, command.type, result, id: command.id),
    );
    await pumpEventQueue();
  }

  setUp(() {
    run = SeatLayerRunController();
    page = _Page();
    n = 0;
  });
  tearDown(() => run.dispose());

  test('init is the group surface: the page header off, the checkout the app\'s',
      () async {
    await boot();
    final init = page.sent.single;
    expect(init.kind, EnvelopeKind.init);
    final payload = init.payload! as Map<String, Object?>;
    expect(payload['surface'], <String, Object?>{'kind': 'group'});
    expect(payload['protocol'], <String, Object?>{'min': 2, 'max': 2});
    expect(payload['config'], <String, Object?>{
      'performanceGroup': 'pg_test',
      'locale': 'de',
      'header': false,
      'checkout': 'handoff',
      'theme': 'dark',
    });
    expect(payload.containsKey('requirements'), isFalse);
    expect(payload.containsKey('chrome'), isFalse);
  });

  test('a page without the app-shell hooks is refused before init', () async {
    final errors = <SeatLayerError>[];
    run.onError.listen(errors.add);
    await boot(hello: <String, Object?>{
      ...runHello,
      'capabilities': <String>['group-surface-v1'],
    });
    expect(page.sent, isEmpty);
    expect(errors.single, isA<IncompatibleFailure>());
    expect('${errors.single}', contains('group-app-shell-v1'));
  });

  test('the page\'s own refusals are refused here first', () {
    expect(
      () => SeatLayerRunConfiguration(
        run: 'pg_test',
        selectionMode: SeatLayerRunSelectionMode.perPerformance,
      ),
      throwsArgumentError,
    );
    expect(
      () => SeatLayerRunConfiguration(
          run: 'pg_test', allowSelectionModeSwitch: true),
      throwsArgumentError,
    );
    expect(
      () => SeatLayerRunConfiguration(run: 'pg_test', initialHoldId: 'h'),
      throwsArgumentError,
    );
    final config = SeatLayerRunConfiguration(
      run: 'pg_test',
      selectionMode: SeatLayerRunSelectionMode.perPerformance,
      numberOfPlacesToSelect: 2,
      initialHoldId: 'hold_1',
      initialOperationId: 'pghop_1',
      buyerAccessTokenProvider: (_) => const BuyerAccessToken(token: 'tok'),
    ).initPayload()['config']! as Map;
    expect(config['selectionMode'], 'per_performance');
    expect(config['numberOfPlacesToSelect'], 2);
    expect(config['initialOperationId'], 'pghop_1');
    expect(config['nativeAccessProvider'], isTrue);
  });

  test('the run, status, hold and expiry are tracked and streamed', () async {
    await boot();
    final holds = <String?>[];
    final expired = <void>[];
    run.onHold.listen((h) => holds.add(h?.operationId));
    run.onHoldExpired.listen(expired.add);

    evt('group.ready', runReady('The Lantern Keeper'));
    await pumpEventQueue();
    expect(run.descriptor!.name, 'The Lantern Keeper');
    expect(run.descriptor!.performances.map((p) => p.startsAtLabel),
        <String>['Sat 9 Mar · 14:30', 'Thu 14 Mar · 19:30']);
    expect(run.selectionMode, SeatLayerRunSelectionMode.sameSeat);

    evt('group.status', <String, Object?>{
      'kind': 'recovery_failed',
      'message': 'We could not confirm your seats.',
      'reference': 'R-7Q2',
    });
    await pumpEventQueue();
    expect(run.status!.kind, SeatLayerRunStatusKind.recoveryFailed);
    expect(run.status!.reference, 'R-7Q2');

    evt('group.hold', <String, Object?>{'handoff': runHandoff('pghop_a')});
    evt('group.holdChanged', <String, Object?>{'handoff': runHandoff('pghop_a')});
    await pumpEventQueue();
    expect(run.hold!.seatLabels, <String>['A-1', 'A-2']);
    expect(run.hold!.performanceKeys, <String>['ev_1', 'ev_2']);
    expect(run.hold!.booked, isFalse);

    evt('group.holdExpired', const <String, Object?>{});
    evt('group.holdChanged', const <String, Object?>{'handoff': null});
    await pumpEventQueue();
    expect(run.hold, isNull);
    expect(holds, <String?>['pghop_a', 'pghop_a', null, null]);
    expect(expired, hasLength(1));
  });

  test('a repeated Continue or booking for one hold reaches the app once',
      () async {
    await boot();
    final continued = <String>[];
    final booked = <String>[];
    run.onContinue.listen((h) => continued.add(h.operationId));
    run.onBooked.listen((h) => booked.add(h.operationId));
    for (var i = 0; i < 2; i++) {
      evt('group.checkout', <String, Object?>{'handoff': runHandoff('pghop_a')});
      evt('group.booked', <String, Object?>{
        'handoff': runHandoff('pghop_a', booked: true),
      });
    }
    await pumpEventQueue();
    expect(continued, <String>['pghop_a']);
    expect(booked, <String>['pghop_a']);
  });

  test('a group refusal is an error; an unknown event stays unknown',
      () async {
    await boot();
    final errors = <SeatLayerError>[];
    final unknown = <String>[];
    run.onError.listen(errors.add);
    run.onUnknownEvent.listen((e) => unknown.add(e.name));
    evt('group.error', <String, Object?>{
      'code': 'seats_unavailable',
      'message': 'Taken',
    });
    evt('group.somethingNew', const <String, Object?>{});
    await pumpEventQueue();
    expect((errors.single as BridgeFailure).payload.code, 'seats_unavailable');
    expect(unknown, <String>['group.somethingNew']);
  });

  test('commands carry the contract payloads and read the answers', () async {
    await boot();

    final continued = run.continueToCheckout();
    await pumpEventQueue();
    expect(page.sent.last.type, 'group.continue');
    await answer(<String, Object?>{'handoff': runHandoff('pghop_a')});
    expect((await continued).holdId, 'hold_1');

    final booked = run.markBooked(operationId: 'pghop_a');
    await pumpEventQueue();
    expect(page.sent.last.type, 'group.markBooked');
    expect(page.sent.last.payload, <String, Object?>{'operationId': 'pghop_a'});
    await answer(<String, Object?>{'booked': true, 'status': 'booked'});
    expect(await booked, SeatLayerRunBookedStatus.booked);

    final released = run.release();
    await pumpEventQueue();
    expect(page.sent.last.type, 'group.release');
    expect(page.sent.last.payload, const <String, Object?>{});
    await answer(<String, Object?>{'released': false});
    expect(await released, isFalse);

    final held = run.getHeldOrder();
    await pumpEventQueue();
    await answer(<String, Object?>{'heldOrder': null});
    expect(await held, isNull);

    final switched =
        run.setSelectionMode(SeatLayerRunSelectionMode.perPerformance);
    await pumpEventQueue();
    expect(page.sent.last.payload,
        <String, Object?>{'mode': 'per_performance'});
    await answer(<String, Object?>{
      'selectionMode': 'per_performance',
      'changed': true,
    });
    expect(await switched, isTrue);

    final foreground = run.setForeground(true);
    await pumpEventQueue();
    expect(page.sent.last.type, 'group.lifecycle');
    expect(page.sent.last.payload, <String, Object?>{'state': 'foreground'});
    await answer(<String, Object?>{'state': 'foreground', 'held': true});
    expect(await foreground, isTrue);

    final destroyed = run.destroy();
    await pumpEventQueue();
    expect(page.sent.last.type, 'group.destroy');
    await answer(<String, Object?>{'destroyed': true});
    await destroyed;
    expect(run.hold, isNull);
  });
}
