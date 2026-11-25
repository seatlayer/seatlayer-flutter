// A page that answers but brings no map: the failure view, not an empty picker.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/bridge/bridge_unloaded_map.dart';
import 'package:seatlayer/src/bridge/envelope.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';
import 'package:seatlayer/src/seat_layer_error.dart';
import 'package:seatlayer/src/seat_layer_prewarm.dart';
import 'package:seatlayer/src/seat_layer_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';

/// What the page reports when the event's map did not load.
Map<String, Object?> _unloaded({
  Map<String, Object?> access = const <String, Object?>{},
}) =>
    <String, Object?>{
      'schema': 'seatlayer.picker.snapshot/1',
      'sessionId': 'session-1',
      'revision': 1,
      'event': <String, Object?>{'key': 'ev_test', 'name': 'ev_test'},
      'catalog': <String, Object?>{
        'categories': <Object?>[],
        'gaAreas': <Object?>[],
      },
      'map': <String, Object?>{'floors': <Object?>[]},
      'access': access,
    };

final class _Channel implements BridgeChannel {
  @override
  Future<void> send(Envelope envelope) async {}
}

String _ready(Map<String, Object?> snapshot) => Envelope(
      kind: EnvelopeKind.evt,
      type: 'sys.ready',
      sequence: 1,
      payload: <String, Object?>{
        'protocol': 2,
        'mode': 'test',
        'snapshot': snapshot,
      },
    ).encode();

String _error() => const Envelope(
      kind: EnvelopeKind.evt,
      type: 'error',
      sequence: 1,
      payload: <String, Object?>{'code': 'event_not_found', 'message': 'gone'},
    ).encode();

void main() {
  setUp(SeatLayerRuntimePrewarm.resetForTesting);
  tearDown(SeatLayerRuntimePrewarm.resetForTesting);

  group('a ready page without a map', () {
    test('is told from one with a map', () {
      expect(seatLayerPickerMapDidNotLoad(_unloaded()), isTrue);
      expect(seatLayerPickerMapDidNotLoad(pickerSnapshot()), isFalse);
      expect(seatLayerPickerMapDidNotLoad(null), isFalse);
      // An event may be named like its key: it has levels and prices.
      expect(
        seatLayerPickerMapDidNotLoad(<String, Object?>{
          ..._unloaded(),
          'map': <String, Object?>{
            'floors': <Object?>[
              <String, Object?>{'id': 'ground'},
            ],
          },
        }),
        isFalse,
      );
    });

    test('leaves a refused session to its own telling', () {
      bool refused(String status, String reason) =>
          seatLayerPickerMapDidNotLoad(
            _unloaded(
              access: <String, Object?>{'status': status, 'reason': reason},
            ),
          );
      expect(refused('expired', 'expired'), isFalse);
      expect(refused('unavailable', 'paused'), isFalse);
      expect(refused('unavailable', 'provider_failed'), isTrue);
    });

    Future<(SeatLayerController, List<Object>, Future<Object?>)> boot({
      SeatLayerBridgeProfile? profile,
    }) async {
      final controller = SeatLayerController();
      addTearDown(controller.dispose);
      final errors = <Object>[];
      controller.onError.listen(errors.add);
      final outcome = controller
          .beginHandshake(
            _Channel(),
            SeatLayerConfiguration(event: 'ev_test'),
            profile: profile ?? SeatLayerBridgeProfile.picker(),
          )
          .then<Object?>((info) => info, onError: (Object error) => error);
      return (controller, errors, outcome);
    }

    test('did not load, and is told once', () async {
      final (controller, errors, outcome) = await boot();
      controller.ingestRaw(_ready(_unloaded()));
      expect(await outcome, isA<TransportFailure>());
      await pumpEventQueue();
      expect(errors, hasLength(1));
      expect(controller.isReady, isFalse);
    });

    test('keeps the reason the page gave, and says it once', () async {
      final (controller, errors, outcome) = await boot();
      controller
        ..ingestRaw(_error())
        ..ingestRaw(_ready(_unloaded()));
      final error = await outcome;
      expect((error! as SeatLayerError).code, 'event_not_found');
      await pumpEventQueue();
      expect(errors, <Object>[error]);
    });

    test('is the picker\'s rule alone', () async {
      final (controller, _, outcome) =
          await boot(profile: SeatLayerBridgeProfile.chart);
      controller.ingestRaw(_ready(_unloaded()));
      expect(await outcome, isNot(isA<SeatLayerError>()));
      expect(controller.isReady, isTrue);
    });
  });

  group('an HTTP error', () {
    final page = Uri.parse(SeatLayerConfiguration.defaultAssetPath);
    HttpResponseError answer({Uri? request}) => HttpResponseError(
          request: request == null ? null : WebResourceRequest(uri: request),
          response: const WebResourceResponse(uri: null, statusCode: 503),
        );

    Future<(FakeWebViewPlatform, List<SeatLayerError>)> open(
      WidgetTester tester,
    ) async {
      final fake = useFakeWebViewPlatform();
      final errors = <SeatLayerError>[];
      final controller = SeatLayerController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: SeatLayerView(
            controller: controller,
            configuration: SeatLayerConfiguration(event: 'ev_test'),
            onLoadError: errors.add,
          ),
        ),
      );
      await tester.pump();
      return (fake, errors);
    }

    testWidgets('of the page itself fails the load at once', (tester) async {
      for (final request in <Uri?>[page, null]) {
        final (fake, errors) = await open(tester);
        fake.httpErrors.single(answer(request: request));
        await tester.pump();
        expect(errors.single, isA<TransportFailure>());
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('of anything else the page asks for does not', (tester) async {
      final (fake, errors) = await open(tester);
      fake.httpErrors.single(answer(request: page.resolve('/favicon.ico')));
      await tester.pump();
      expect(errors, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('of a prewarmed page drops it', (tester) async {
      final fake = useFakeWebViewPlatform();
      SeatLayerRuntimePrewarm.start(SeatLayerConfiguration.defaultAssetPath);
      fake.httpErrors.single(answer(request: page.resolve('/favicon.ico')));
      expect(SeatLayerRuntimePrewarm.warmUrls, hasLength(1));
      fake.httpErrors.single(answer(request: page));
      expect(SeatLayerRuntimePrewarm.warmUrls, isEmpty);
    });
  });
}
