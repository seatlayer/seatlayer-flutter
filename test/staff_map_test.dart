import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';

final class _Channel implements BridgeChannel {
  final sent = <Envelope>[];

  @override
  Future<void> send(Envelope envelope) async => sent.add(envelope);

  Iterable<Envelope> commands(String type) =>
      sent.where((e) => e.kind == EnvelopeKind.cmd && e.type == type);
}

const _grant = ManageAccessToken(token: 'mse_0123abcd', expiresAt: 9000);

Map<String, Object?> _hello({bool staffMap = true}) => <String, Object?>{
      'bundle': 'test',
      'protocol': <String, Object?>{'min': 1, 'max': 2},
      'capabilities': <String>[
        'native-access-provider',
        if (staffMap) seatLayerStaffMapCapability,
      ],
      'events': <String>['sys.ready'],
      'commands': <String>[],
    };

void _ingest(SeatLayerController controller, Envelope envelope) =>
    controller.ingestRaw(envelope.encode());

void _sendHello(SeatLayerController controller, {bool staffMap = true}) =>
    _ingest(
      controller,
      Envelope(
        kind: EnvelopeKind.hello,
        type: 'hello',
        payload: _hello(staffMap: staffMap),
      ),
    );

void _event(SeatLayerController controller, String type, Object? payload,
        int sequence) =>
    _ingest(
      controller,
      Envelope(
        kind: EnvelopeKind.evt,
        type: type,
        sequence: sequence,
        payload: payload,
      ),
    );

void _reply(SeatLayerController controller, Envelope command,
        [Object? payload]) =>
    _ingest(
      controller,
      Envelope(
        kind: EnvelopeKind.res,
        type: command.type,
        id: command.id,
        payload: payload ?? const <String, Object?>{},
      ),
    );

void main() {
  group('configuration', () {
    test('sends the grant and the renewal flag, and no buyer access', () {
      final config = SeatLayerConfiguration(
        event: 'ev_staff',
        manageAccessToken: _grant,
        manageAccessTokenProvider: (_) => _grant,
      );
      final payload = config.initPayload()['config']! as Map<String, Object?>;
      expect(payload['manageAccessToken'],
          {'token': 'mse_0123abcd', 'expiresAt': 9000});
      expect(payload['manageAccessProvider'], true);
      expect(payload.containsKey('publicKey'), isFalse);
      expect(payload.containsKey('nativeAccessProvider'), isFalse);
      expect(config.usesManageAccess, isTrue);
      expect(config.usesPrivateAccess, isFalse);
    });

    test('a provider alone is enough', () {
      final config = SeatLayerConfiguration(
        event: 'ev_staff',
        manageAccessTokenProvider: (_) => _grant,
      );
      final payload = config.initPayload()['config']! as Map<String, Object?>;
      expect(payload.containsKey('manageAccessToken'), isFalse);
      expect(payload['manageAccessProvider'], true);
    });

    test('refuses anything that is not an mse_ grant', () {
      for (final token in <ManageAccessToken>[
        const ManageAccessToken(token: 'bse_buyer'),
        const ManageAccessToken(token: 'sk_live_secret'),
        const ManageAccessToken(token: ''),
        const ManageAccessToken(token: 'mse_ok', expiresAt: double.infinity),
      ]) {
        expect(
          () => SeatLayerConfiguration(
              event: 'ev_staff', manageAccessToken: token),
          throwsArgumentError,
          reason: token.token,
        );
      }
    });

    test('refuses a grant mixed with buyer access', () {
      expect(
        () => SeatLayerConfiguration(
          event: 'ev_staff',
          publicKey: 'pk_live_x',
          manageAccessToken: _grant,
        ),
        throwsArgumentError,
      );
      expect(
        () => SeatLayerConfiguration(
          event: 'ev_staff',
          buyerAccessTokenProvider: (_) =>
              const BuyerAccessToken(token: 'bse_x'),
          manageAccessTokenProvider: (_) => _grant,
        ),
        throwsArgumentError,
      );
    });

    test('a rebuilt configuration with the same grant is the same map', () {
      SeatLayerConfiguration build() =>
          SeatLayerConfiguration(event: 'ev_staff', manageAccessToken: _grant);
      expect(build().semanticallyEquals(build()), isTrue);
      expect(
        build().semanticallyEquals(SeatLayerConfiguration(
          event: 'ev_staff',
          manageAccessToken: const ManageAccessToken(token: 'mse_other'),
        )),
        isFalse,
      );
    });
  });

  group('handshake', () {
    test('boots the staff map on a renderer that has it', () async {
      final controller = SeatLayerController();
      addTearDown(controller.dispose);
      final channel = _Channel();
      final ready = controller.beginHandshake(
        channel,
        SeatLayerConfiguration(event: 'ev_staff', manageAccessToken: _grant),
      );
      _sendHello(controller);
      await pumpEventQueue();
      final init = channel.sent.singleWhere((e) => e.kind == EnvelopeKind.init);
      final config = (init.payload! as Map)['config'] as Map;
      expect(config['manageAccessToken'], isA<Map<String, Object?>>());

      _event(
        controller,
        'sys.ready',
        <String, Object?>{
          'protocol': 1,
          'mode': 'live',
          'transport': 'flutter',
          'chart': <String, Object?>{'event': 'ev_staff'},
          'surface': <String, Object?>{'kind': 'staff'},
        },
        1,
      );
      expect((await ready).eventKey, 'ev_staff');
    });

    test('fails clearly on a renderer without the staff map', () async {
      final controller = SeatLayerController();
      addTearDown(controller.dispose);
      final channel = _Channel();
      final ready = controller.beginHandshake(
        channel,
        SeatLayerConfiguration(event: 'ev_staff', manageAccessToken: _grant),
      );
      _sendHello(controller, staffMap: false);
      await expectLater(
        ready,
        throwsA(isA<IncompatibleFailure>().having(
          (error) => error.reason,
          'reason',
          contains(seatLayerStaffMapCapability),
        )),
      );
      expect(channel.sent.where((e) => e.kind == EnvelopeKind.init), isEmpty);
    });

    test('refuses the buyer picker surface', () async {
      final controller = SeatLayerController();
      addTearDown(controller.dispose);
      final channel = _Channel();
      final ready = controller.beginHandshake(
        channel,
        SeatLayerConfiguration(event: 'ev_staff', manageAccessToken: _grant),
        profile: SeatLayerBridgeProfile.picker(),
      );
      _ingest(
        controller,
        Envelope(
          kind: EnvelopeKind.hello,
          type: 'hello',
          payload: <String, Object?>{
            ..._hello(),
            'protocol': <String, Object?>{'min': 2, 'max': 2},
            'capabilities': <String>[
              ...SeatLayerBridgeProfile.picker().requiredCapabilities,
              seatLayerStaffMapCapability,
            ],
          },
        ),
      );
      await expectLater(
        ready,
        throwsA(isA<BridgeFailure>()
            .having((error) => error.code, 'code', 'bad_payload')),
      );
    });
  });

  group('while running', () {
    Future<(SeatLayerController, _Channel)> running(
      SeatLayerConfiguration config,
    ) async {
      final controller = SeatLayerController();
      addTearDown(controller.dispose);
      final channel = _Channel();
      final ready = controller.beginHandshake(channel, config);
      _sendHello(controller);
      await pumpEventQueue();
      _event(
        controller,
        'sys.ready',
        <String, Object?>{
          'protocol': 1,
          'mode': 'test',
          'transport': 'flutter',
          'chart': <String, Object?>{'event': 'ev_staff'},
        },
        1,
      );
      await ready;
      return (controller, channel);
    }

    test('renews the grant through the provider, with its reason', () async {
      final reasons = <ManageAccessRefreshReason>[];
      final (controller, channel) = await running(SeatLayerConfiguration(
        event: 'ev_staff',
        manageAccessToken: _grant,
        manageAccessTokenProvider: (context) {
          reasons.add(context.reason);
          return const ManageAccessToken(token: 'mse_next', expiresAt: 12000);
        },
      ));
      _event(
        controller,
        'access.token.request',
        <String, Object?>{'requestId': 'access-1', 'reason': 'refresh'},
        2,
      );
      await pumpEventQueue();
      expect(reasons, [ManageAccessRefreshReason.refresh]);
      final provide = channel.commands('access.token.provide').single;
      expect(provide.payload, {
        'requestId': 'access-1',
        'token': 'mse_next',
        'expiresAt': 12000,
      });
    });

    test(
        'answers unavailable when the provider fails or returns a buyer bearer',
        () async {
      var calls = 0;
      final (controller, channel) = await running(SeatLayerConfiguration(
        event: 'ev_staff',
        manageAccessTokenProvider: (_) {
          calls += 1;
          if (calls == 1) throw StateError('signed out');
          return const ManageAccessToken(token: 'bse_buyer');
        },
      ));
      for (var i = 0; i < 2; i += 1) {
        _event(
          controller,
          'access.token.request',
          <String, Object?>{'requestId': 'access-$i', 'reason': 'refresh'},
          2 + i,
        );
        await pumpEventQueue();
      }
      expect(channel.commands('access.token.provide'), isEmpty);
      expect(channel.commands('access.token.unavailable').length, 2);
    });

    test('reports the selection and the live connection', () async {
      final (controller, _) = await running(
        SeatLayerConfiguration(event: 'ev_staff', manageAccessToken: _grant),
      );
      final selections = <List<SelectedSeat>>[];
      final connections = <StaffConnectionState>[];
      controller.onSelectionChanged.listen(selections.add);
      controller.onStaffConnectionChanged.listen(connections.add);
      _event(
        controller,
        'selection.changed',
        <String, Object?>{
          'seats': <Object?>[
            <String, Object?>{
              'id': 'row-a:1',
              'label': 'A-1',
              'objectId': 'row-a',
              'objectType': 'seat',
              'categoryKey': 'std',
            },
          ],
        },
        2,
      );
      _event(
        controller,
        'staff.connection',
        <String, Object?>{'status': 'reconnecting', 'lastMessageAt': 77},
        3,
      );
      await pumpEventQueue();
      expect(selections.single.single.label, 'A-1');
      expect(connections.single.status, 'reconnecting');
      expect(connections.single.lastMessageAt, 77);
      expect(connections.single.isLive, isFalse);
    });

    test('sends the staff commands', () async {
      final (controller, channel) = await running(
        SeatLayerConfiguration(event: 'ev_staff', manageAccessToken: _grant),
      );

      final found = controller.focusSection('Stalls');
      await pumpEventQueue();
      final focus = channel.commands('staff.focusSection').single;
      expect(focus.payload, {'label': 'Stalls'});
      _reply(controller, focus, <String, Object?>{'found': true});
      expect(await found, isTrue);

      final unavailable = controller.setUnavailableObjects(
        ['B-1'],
        reason: 'Kept for renewal',
      );
      await pumpEventQueue();
      final command = channel.commands('staff.setUnavailableObjects').single;
      expect(command.payload, {
        'objects': ['B-1'],
        'reason': 'Kept for renewal',
      });
      _reply(controller, command);
      await unavailable;

      final prices = controller.setCategoryPrices({
        'std': const StaffCategoryPrice.amount(40),
        'vip': const StaffCategoryPrice.range(min: 60, max: 80),
      });
      await pumpEventQueue();
      final priced = channel.commands('staff.setCategoryPrices').single;
      expect(priced.payload, {
        'prices': {
          'std': 40,
          'vip': {'min': 60, 'max': 80},
        },
      });
      _reply(controller, priced);
      await prices;
    });
  });
}
