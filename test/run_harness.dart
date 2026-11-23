// group.html's part of the bridge, played by a test: what runtime 1.0.0
// sends.
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

import 'season_harness.dart';

final runConfiguration = SeatLayerRunConfiguration(run: 'pg_test');

const runHello = <String, Object?>{
  'bundle': '1.0.0',
  'protocol': <String, Object?>{'min': 2, 'max': 2},
  'capabilities': <String>['group-surface-v1', 'group-app-shell-v1'],
  'events': <String>[],
  'commands': <String>[],
};

/// A page that honours `appBar`: it fits the web view and runs its
/// cart bar under the home indicator.
final runHelloAppBar = <String, Object?>{
  ...runHello,
  'capabilities': <String>[
    'group-surface-v1',
    'group-app-shell-v1',
    'group-app-shell-v2',
  ],
};

/// A page that also takes the app's insets (#15): it keeps its cart clear of
/// the home indicator itself.
final runHelloInsets = <String, Object?>{
  ...runHelloAppBar,
  'commands': <String>['group.setViewportInsets'],
};

Map<String, Object?> runReady(String name) => <String, Object?>{
      'performanceGroup': <String, Object?>{
        'key': 'pg_test',
        'name': name,
        'state': 'active',
        'mode': 'test',
        'currency': 'EUR',
        'venue': 'Riverside Hall',
        'timezone': 'Europe/London',
        'performanceCount': 2,
        'performances': <Object?>[
          <String, Object?>{
            'position': 1,
            'eventKey': 'ev_1',
            'name': name,
            'startsAt': 1899898200000,
            'startsAtLabel': 'Sat 9 Mar · 14:30',
            'endsAt': null,
            'venue': 'Riverside Hall',
            'timezone': 'Europe/London',
            'salesState': 'on_sale',
          },
          <String, Object?>{
            'position': 2,
            'eventKey': 'ev_2',
            'name': name,
            'startsAt': 1900358400000,
            'startsAtLabel': 'Thu 14 Mar · 19:30',
            'endsAt': null,
            'venue': 'Riverside Hall',
            'timezone': 'Europe/London',
            'salesState': 'on_sale',
          },
        ],
      },
      'selectionMode': 'same_seat',
    };

Map<String, Object?> runHandoff(String operationId, {bool booked = false}) =>
    <String, Object?>{
      'operationId': operationId,
      'holdId': 'hold_1',
      // Fifteen minutes after the pinned test clock.
      'expiresAt': SeatLayerPickerHoldCountdown.debugClock()
          .add(const Duration(minutes: 15))
          .millisecondsSinceEpoch,
      'performanceGroup': runReady('Run')['performanceGroup'],
      'selectionMode': 'same_seat',
      'performanceKeys': <String>['ev_1', 'ev_2'],
      'seatLabels': <String>['A-1', 'A-2'],
      'bookingState': booked ? 'booked' : 'held',
    };

/// Plays group.html's part of the bridge.
class RunPage extends SeasonPage {
  RunPage(super.fake, {this.hello = runHello});

  /// What the page says it can do: runtime 1.0.0's by default.
  final Map<String, Object?> hello;

  @override
  Future<void> boot(WidgetTester tester) async {
    post(EnvelopeKind.hello, 'hello', hello);
    await tester.pump();
    evt('sys.ready', <String, Object?>{
      'protocol': 2,
      'transport': 'flutter',
      'surface': <String, Object?>{'kind': 'group'},
      'group': <String, Object?>{'key': 'pg_test'},
    });
    await tester.pump();
    await tester.pump();
  }

  /// `group.ready`, right after `sys.ready`: the run's name.
  void ready(String name) => evt('group.ready', runReady(name));

  @override
  void held(String operationId) => evt(
        'group.hold',
        <String, Object?>{'handoff': runHandoff(operationId)},
      );

  /// What the page sends for a run it cannot show.
  Future<void> fail(WidgetTester tester) async {
    post(EnvelopeKind.hello, 'hello', hello);
    await tester.pump();
    evt('sys.error', <String, Object?>{'code': 'render_failed'});
  }
}
