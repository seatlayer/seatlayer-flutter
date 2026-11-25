// The Season controller over season.html's contract
// (seatlayer-season-surface-v1.json, runtime 1.0.0), against a fake page.
import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_error.dart';
import 'package:seatlayer/src/season/season_configuration.dart';
import 'package:seatlayer/src/season/season_models.dart';
import 'package:seatlayer/src/season/seat_layer_season_controller.dart';

final class _Page implements BridgeChannel {
  final sent = <Envelope>[];

  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);
}

String _frame(EnvelopeKind kind, String type, Object? payload,
        {int? n, String? id}) =>
    Envelope(kind: kind, type: type, sequence: n, id: id, payload: payload)
        .encode();

Map<String, Object?> _handoff(String operationId) => <String, Object?>{
      'seasonKey': 'sea_test',
      'planActivationId': 'spa_1',
      'operationId': operationId,
      'holdId': 'hold_1',
      'expiresAt': 1767225600000,
      'policy': 'fixed_inclusion_same_seat',
      'pricingAuthority': 'host',
      'authoritativeAmountIncluded': false,
      'state': 'held',
      'allocations': <Object?>[],
    };

const _hello = <String, Object?>{
  'bundle': '1.0.0',
  'protocol': <String, Object?>{'min': 2, 'max': 2},
  'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
  'events': <String>[],
  'commands': <String>[],
};

void main() {
  late SeatLayerSeasonController season;
  late _Page page;
  var n = 0;

  void evt(String type, Object? payload) =>
      season.ingestRaw(_frame(EnvelopeKind.evt, type, payload, n: ++n));

  Future<void> boot({
    SeatLayerSeasonConfiguration? configuration,
    Map<String, Object?> hello = _hello,
  }) async {
    unawaited(season
        .beginHandshake(
          page,
          configuration ??
              SeatLayerSeasonConfiguration(
                season: 'sea_test',
                publicKey: 'pk_test_x',
                locale: 'de',
              ),
          profile: SeatLayerBridgeProfile.season(
            config: const <String, Object?>{'theme': 'dark'},
          ),
        )
        .then<void>((_) {}, onError: (Object _) {}));
    season.ingestRaw(_frame(EnvelopeKind.hello, 'hello', hello));
    await pumpEventQueue();
  }

  /// Answers the last command with [result].
  Future<void> answer(Object? result) async {
    final command = page.sent.last;
    season.ingestRaw(
      _frame(EnvelopeKind.res, command.type, result, id: command.id),
    );
    await pumpEventQueue();
  }

  setUp(() {
    season = SeatLayerSeasonController();
    page = _Page();
    n = 0;
  });
  tearDown(() => season.dispose());

  test('init is the Season surface, with the boot theme folded in', () async {
    await boot();
    final init = page.sent.single;
    expect(init.kind, EnvelopeKind.init);
    final payload = init.payload! as Map<String, Object?>;
    expect(payload['surface'], <String, Object?>{'kind': 'season'});
    expect(payload['protocol'], <String, Object?>{'min': 2, 'max': 2});
    expect(payload['config'], <String, Object?>{
      'season': 'sea_test',
      'publicKey': 'pk_test_x',
      'locale': 'de',
      'theme': 'dark',
      'appBar': true,
    });
    // The picker's blocks are the picker's: the Season page takes none.
    expect(payload.containsKey('requirements'), isFalse);
    expect(payload.containsKey('chrome'), isFalse);
  });

  test('the status carries the Season\'s name and its club\'s brand', () async {
    await boot();
    evt('season.status', <String, Object?>{
      'kind': 'ready',
      'message': 'Ready',
      'season': <String, Object?>{'name': 'Main Stage 2026/27'},
      'branding': <String, Object?>{
        'brandName': 'Grand Theatre',
        'logoUrl': 'https://api.example.test/logo.png',
        'accent': '#0f766e',
      },
    });
    expect(season.status?.seasonName, 'Main Stage 2026/27');
    expect(season.status?.branding?.brandName, 'Grand Theatre');
    expect(
      season.status?.branding?.logoUrl,
      'https://api.example.test/logo.png',
    );
    expect(season.status?.branding?.accent, '#0f766e');
    // A club that set none of them sends an empty brand.
    evt('season.status', <String, Object?>{
      'kind': 'held',
      'message': 'Held',
      'season': <String, Object?>{'name': 'Main Stage 2026/27'},
      'branding': <String, Object?>{},
    });
    expect(season.status?.seasonName, 'Main Stage 2026/27');
    expect(season.status?.branding?.brandName, isNull);
    // An older page sends neither.
    evt('season.status', <String, Object?>{'kind': 'ready', 'message': ''});
    expect(season.status?.seasonName, isNull);
    expect(season.status?.branding, isNull);
  });

  test('a page without the app-shell hooks is refused before init', () async {
    final errors = <SeatLayerError>[];
    season.onError.listen(errors.add);
    await boot(hello: <String, Object?>{
      ..._hello,
      'capabilities': <String>['season-surface-v1'],
    });
    expect(page.sent, isEmpty);
    expect(errors.single, isA<IncompatibleFailure>());
    expect('${errors.single}', contains('season-app-shell-v1'));
  });

  test('a members-only Season asks the app for tokens', () async {
    await boot(
      configuration: SeatLayerSeasonConfiguration(
        season: 'sea_test',
        buyerAccessTokenProvider: (_) =>
            const BuyerAccessToken(token: 'tok_test'),
      ),
    );
    final config = (page.sent.single.payload! as Map)['config'] as Map;
    expect(config['nativeAccessProvider'], isTrue);
    expect(config.containsKey('buyerAccessToken'), isFalse);
  });

  test('status, hold and expiry are tracked and streamed', () async {
    await boot();
    final statuses = <SeatLayerSeasonStatus>[];
    final holds = <SeatLayerSeasonHandoff?>[];
    var expired = 0;
    season.onStatus.listen(statuses.add);
    season.onHold.listen(holds.add);
    season.onHoldExpired.listen((_) => expired += 1);

    evt('season.status', <String, Object?>{
      'kind': 'ready',
      'message': 'Bereit',
      'dates': <Object?>[
        <String, Object?>{
          'position': 1,
          'eventKey': 'ev_1',
          'name': 'Opening night',
          'startsAt': 1767225600000,
          'startsAtLabel': 'Sa 15. Aug · 15:00',
        },
        <String, Object?>{
          'position': 2,
          'eventKey': 'ev_2',
          'name': 'TBA',
          'startsAt': null,
          'startsAtLabel': null,
          'past': true
        },
        <String, Object?>{'name': 'malformed'},
      ],
    });
    evt('season.hold', <String, Object?>{'handoff': _handoff('sop_a')});
    evt('season.holdChanged', <String, Object?>{'handoff': null});
    evt('season.hold', <String, Object?>{'handoff': _handoff('sop_b')});
    evt('season.holdExpired', const <String, Object?>{});
    await pumpEventQueue();

    final ready = statuses.single;
    expect(ready.kind, SeatLayerSeasonStatusKind.ready);
    expect(ready.dates!.map((d) => d.eventKey), <String>['ev_1', 'ev_2']);
    expect(ready.dates!.first.startsAtLabel, 'Sa 15. Aug · 15:00');
    expect(ready.dates!.last.startsAt, isNull);
    expect(ready.dates!.last.past, isTrue);
    expect(holds.map((h) => h?.operationId),
        <String?>['sop_a', null, 'sop_b', null]);
    expect(expired, 1);
    expect(season.hold, isNull);
    expect(season.status, same(ready));
  });

  test('a repeated Continue for one hold reaches the app once', () async {
    await boot();
    final continued = <String>[];
    season.onContinue.listen((h) => continued.add(h.operationId));
    evt('season.continue', <String, Object?>{'handoff': _handoff('sop_a')});
    evt('season.continue', <String, Object?>{'handoff': _handoff('sop_a')});
    evt('season.continue', <String, Object?>{'handoff': _handoff('sop_b')});
    await pumpEventQueue();
    expect(continued, <String>['sop_a', 'sop_b']);
  });

  test('a Season refusal is an error; an unknown event stays unknown',
      () async {
    await boot();
    final errors = <SeatLayerError>[];
    final unknown = <String>[];
    season.onError.listen(errors.add);
    season.onUnknownEvent.listen((e) => unknown.add(e.name));
    evt('season.error', <String, Object?>{
      'code': 'seats_unavailable',
      'message': 'Taken',
    });
    evt('season.somethingNew', const <String, Object?>{});
    await pumpEventQueue();
    expect((errors.single as BridgeFailure).payload.code, 'seats_unavailable');
    expect(unknown, <String>['season.somethingNew']);
  });

  test('commands carry the contract payloads and read the answers', () async {
    await boot();

    final held = season.holdSameSeat(
      <String>['A-1', 'A-2'],
      priceTypes: <String, String>{'A-2': 'child'},
    );
    await pumpEventQueue();
    final hold = page.sent.last;
    expect(hold.type, 'season.holdSameSeat');
    final holdPayload = hold.payload! as Map;
    expect(holdPayload['labels'], <String>['A-1', 'A-2']);
    expect(holdPayload['priceTypes'], <String, String>{'A-2': 'child'});
    expect(holdPayload['operationId'], startsWith('sop_'));
    await answer(<String, Object?>{'handoff': _handoff('sop_a')});
    expect((await held).holdId, 'hold_1');

    final booked = season.markBooked(operationId: 'sop_a');
    await pumpEventQueue();
    expect(page.sent.last.payload, <String, Object?>{'operationId': 'sop_a'});
    await answer(<String, Object?>{'booked': true, 'status': 'already_booked'});
    expect(await booked, SeatLayerSeasonBookedStatus.alreadyBooked);

    final released = season.release();
    await pumpEventQueue();
    expect((page.sent.last.payload! as Map)['releaseActionId'],
        startsWith('sra_'));
    await answer(<String, Object?>{'released': false});
    expect(await released, isFalse);

    final close = season.requestClose();
    await pumpEventQueue();
    expect(page.sent.last.type, 'season.requestClose');
    await answer(<String, Object?>{'outcome': 'kept', 'operationId': 'sop_a'});
    final closed = await close;
    expect(closed.outcome, SeatLayerSeasonCloseOutcome.kept);
    expect(closed.outcome.closes, isTrue);
    expect(closed.operationId, 'sop_a');

    final foreground = season.setForeground(true);
    await pumpEventQueue();
    expect(page.sent.last.payload, <String, Object?>{'state': 'foreground'});
    await answer(<String, Object?>{'state': 'foreground', 'held': false});
    expect(await foreground, isFalse);

    final order = season.getHeldOrder();
    await pumpEventQueue();
    await answer(<String, Object?>{'heldOrder': null});
    expect(await order, isNull);

    final theme = season.setThemeMode(SeatLayerThemeMode.light);
    await pumpEventQueue();
    expect(page.sent.last.payload, <String, Object?>{'mode': 'light'});
    await answer(const <String, Object?>{});
    await theme;

    final insets = season.setViewportInsets(
      const EdgeInsets.only(bottom: 34),
    );
    await pumpEventQueue();
    expect(page.sent.last.payload, <String, Object?>{
      'top': 0.0,
      'right': 0.0,
      'bottom': 34.0,
      'left': 0.0,
    });
    await answer(const <String, Object?>{});
    await insets;
  });

  test('the close question waits for the buyer, past the command deadline',
      () async {
    await boot(
      configuration: SeatLayerSeasonConfiguration(
        season: 'sea_test',
        commandTimeout: const Duration(milliseconds: 20),
      ),
    );
    // An ordinary command keeps its deadline.
    await expectLater(season.markBooked(), throwsA(isA<TimeoutFailure>()));

    final close = season.requestClose();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await answer(<String, Object?>{'outcome': 'released'});
    expect((await close).outcome, SeatLayerSeasonCloseOutcome.released);
  });

  test('a page that goes away fails the open question', () async {
    await boot();
    final close = season.requestClose();
    await pumpEventQueue();
    season.detachTransport();
    await expectLater(close, throwsA(isA<DestroyedFailure>()));
  });

  test('each id is caller-stable and new', () {
    final ids = <String>{
      for (var i = 0; i < 50; i++) SeatLayerSeasonController.newOperationId(),
    };
    expect(ids, hasLength(50));
    expect(
        ids.every((id) => RegExp(r'^sop_[0-9a-z]{20}$').hasMatch(id)), isTrue);
  });
}
