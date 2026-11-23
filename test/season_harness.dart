// season.html's part of the bridge, played by a test: what runtime 1.0.0
// sends, and the name and brand 1.0.1 adds.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

import 'fake_webview_platform.dart';

final seasonConfiguration = SeatLayerSeasonConfiguration(season: 'sea_test');

Map<String, Object?> seasonHandoff(String operationId) => <String, Object?>{
      'seasonKey': 'sea_test',
      'planActivationId': 'spa_1',
      'operationId': operationId,
      'holdId': 'hold_1',
      // Fifteen minutes after the pinned test clock.
      'expiresAt': SeatLayerPickerHoldCountdown.debugClock()
          .add(const Duration(minutes: 15))
          .millisecondsSinceEpoch,
      'policy': 'fixed_inclusion_same_seat',
      'pricingAuthority': 'host',
      'authoritativeAmountIncluded': false,
      'state': 'held',
      'allocations': <Object?>[],
    };

/// Plays season.html's part of the bridge.
class SeasonPage {
  SeasonPage(this.fake);

  final FakeWebViewPlatform fake;
  var _n = 0;

  /// The web view the page speaks from: a retry mounts a new one.
  var controller = 0;

  /// Speak from the newest web view, as a page that just booted does.
  void reloaded() {
    controller = fake.channels.length - 1;
    _n = 0;
  }

  void post(EnvelopeKind kind, String type, Object? payload, {String? id}) =>
      fake.postFromPage(
        Envelope(
          kind: kind,
          type: type,
          sequence: kind == EnvelopeKind.evt ? ++_n : null,
          id: id,
          payload: payload,
        ).encode(),
        controller: controller,
      );

  void evt(String type, Object? payload) =>
      post(EnvelopeKind.evt, type, payload);

  /// Everything the app sent the page, decoded.
  List<Envelope> get sent => <Envelope>[
        for (final script in fake.scripts)
          if (RegExp(r'recv\((.*)\);$').firstMatch(script) case final match?)
            Envelope.decode(jsonDecode(match.group(1)!))!,
      ];

  Envelope last(String type) => sent.lastWhere((e) => e.type == type);

  void answer(String type, Object? result) =>
      post(EnvelopeKind.res, type, result, id: last(type).id);

  Future<void> boot(WidgetTester tester) async {
    post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.0',
      'protocol': <String, Object?>{'min': 2, 'max': 2},
      'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
      'events': <String>[],
      'commands': <String>[],
    });
    await tester.pump();
    evt('season.status', <String, Object?>{
      'kind': 'ready',
      'message': 'Ready',
    });
    evt('sys.ready', <String, Object?>{
      'protocol': 2,
      'transport': 'flutter',
      'surface': <String, Object?>{'kind': 'season'},
      'season': <String, Object?>{'key': 'sea_test'},
    });
    await tester.pump();
    await tester.pump();
  }

  /// Runtime 1.0.1's `ready`: the Season's name and its club's brand.
  void named(String name, String brandName) => evt(
        'season.status',
        <String, Object?>{
          'kind': 'ready',
          'message': 'Ready',
          'season': <String, Object?>{'key': 'sea_test', 'name': name},
          'branding': <String, Object?>{'brandName': brandName},
        },
      );

  void held(String operationId) => evt(
        'season.hold',
        <String, Object?>{'handoff': seasonHandoff(operationId)},
      );
}
