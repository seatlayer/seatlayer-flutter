import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_connection.dart';
import 'package:seatlayer/src/picker/picker_connection_status.dart';
import 'package:seatlayer/src/picker/picker_header.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const _card = ValueKey<String>('seatlayer-connection-status');

/// The picker's wall clock, moved on with the test's own time.
DateTime _now = DateTime.utc(2026, 1, 1, 12);

void _useClock() {
  final original = SeatLayerPickerHoldCountdown.debugClock;
  _now = DateTime.utc(2026, 1, 1, 12);
  SeatLayerPickerHoldCountdown.debugClock = () => _now;
  addTearDown(() => SeatLayerPickerHoldCountdown.debugClock = original);
}

/// Lets [time] pass, then lets the status finish arriving.
Future<void> _wait(WidgetTester tester, Duration time) async {
  _now = _now.add(time);
  await tester.pump(time);
  _now = _now.add(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

const _place = PickerConnectionStatusPlace(
  top: 8,
  start: 12,
  end: 120,
  belowTop: 52,
  inset: 12,
);

FakePickerMap _map({bool connection = true}) => FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: <String>[
          'native-chrome-contract-v1',
          if (connection) seatLayerConnectionStateCapability,
        ],
      ),
    );

Map<String, Object?> _held({int secondsLeft = 600}) {
  final snapshot = pickerSnapshot(revision: 2);
  snapshot['hold'] = <String, Object?>{
    'active': true,
    'expiresAt': seatLayerPickerNow()
        .add(Duration(seconds: secondsLeft))
        .millisecondsSinceEpoch
        .toDouble(),
    'ownership': 'picker',
  };
  return snapshot;
}

Future<FakePickerMap> _pump(
  WidgetTester tester, {
  bool connection = true,
  PickerConnectionStatusPlace place = _place,
  double width = 390,
  double textScale = 1,
  Widget? child,
}) async {
  _useClock();
  final map = _map(connection: connection);
  addTearDown(map.dispose);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, 844),
        textScaler: TextScaler.linear(textScale),
      ),
      child: pickerHarness(
        map,
        Center(
          child: SizedBox(
            width: width,
            height: 400,
            child: child ??
                Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: SeatLayerPickerConnectionStatus(place: place),
                    ),
                  ],
                ),
          ),
        ),
      ),
    ),
  );
  map.emit(pickerSnapshot());
  await tester.pump();
  return map;
}

void main() {
  testWidgets('says nothing until the line has been gone three seconds',
      (tester) async {
    final map = await _pump(tester);
    map.emitEvent('connection.changed', {'state': 'offline'});
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(_card), findsNothing);
    await _wait(tester, const Duration(seconds: 1));
    expect(find.text('You’re offline'), findsOneWidget);
    expect(find.text('Your seats are still held.'), findsNothing);
    expect(tester.getSize(find.byKey(_card)).height, 36);
  });

  testWidgets('a held cart adds that the seats are still held, until 0:00',
      (tester) async {
    final map = await _pump(tester);
    map.emit(_held(secondsLeft: 20));
    await tester.pump();
    map.emitEvent('connection.changed', {'state': 'offline'});
    await _wait(tester, const Duration(seconds: 3));
    expect(find.text('Your seats are still held.'), findsOneWidget);
    expect(tester.getSize(find.byKey(_card)).height, 52);

    await _wait(tester, const Duration(seconds: 18));
    expect(find.text('You’re offline'), findsOneWidget);
    expect(find.text('Your seats are still held.'), findsNothing);
  });

  testWidgets('coming back says Updating, then Back online, then goes',
      (tester) async {
    final map = await _pump(tester);
    map.emitEvent('connection.changed', {'state': 'offline'});
    await tester.pump(const Duration(seconds: 3));
    map.emitEvent('connection.changed', {'state': 'reconnecting'}, sequence: 2);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Updating…'), findsOneWidget);
    map.emitEvent('connection.changed', {'state': 'live'}, sequence: 3);
    await tester.pump();
    map.emit(pickerSnapshot(revision: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Back online'), findsOneWidget);
    await _wait(tester, const Duration(milliseconds: 2500));
    expect(find.byKey(_card), findsNothing);
  });

  testWidgets('a page without the capability draws nothing', (tester) async {
    final map = await _pump(tester, connection: false);
    map.emitEvent('connection.changed', {'state': 'offline'});
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(_card), findsNothing);
  });

  testWidgets('stands after the badge, short of the switch', (tester) async {
    final map = await _pump(tester);
    map.emitEvent('connection.changed', {'state': 'offline'});
    await _wait(tester, const Duration(seconds: 4));
    final box = tester.getRect(find.byKey(_card));
    final area = tester.getRect(find.byType(SeatLayerPickerConnectionStatus));
    expect(box.top - area.top, 8);
    expect(box.left - area.left, 12);
    expect(box.right, lessThanOrEqualTo(area.right - 120));
  });

  testWidgets('too wide for the line, it takes the row under it, full width',
      (tester) async {
    final map = await _pump(tester, textScale: 2);
    map.emit(_held());
    await tester.pump();
    map.emitEvent('connection.changed', {'state': 'offline'});
    await _wait(tester, const Duration(seconds: 4));
    final box = tester.getRect(find.byKey(_card));
    final area = tester.getRect(find.byType(SeatLayerPickerConnectionStatus));
    expect(box.top - area.top, 52);
    expect(box.left - area.left, 12);
    expect(area.right - box.right, 12);
  });

  testWidgets('takes no touches', (tester) async {
    final map = await _pump(tester);
    map.emitEvent('connection.changed', {'state': 'offline'});
    await _wait(tester, const Duration(seconds: 4));
    final guard = tester.widget<IgnorePointer>(find
        .ancestor(of: find.byKey(_card), matching: find.byType(IgnorePointer))
        .first);
    expect(guard.ignoring, isTrue);
  });

  testWidgets('the hold clock stays at a grey 0:00 while the line is down',
      (tester) async {
    Color ink() =>
        tester.widget<Text>(find.textContaining('00:00')).style!.color!;
    final map = await _pump(
      tester,
      child: const Center(child: SeatLayerPickerHoldCountdown()),
    );
    map.emit(_held(secondsLeft: 1));
    await _wait(tester, const Duration(seconds: 2));
    final runOut = ink();

    map.emitEvent('connection.changed', {'state': 'offline'});
    await _wait(tester, const Duration(seconds: 4));
    final waiting = ink();
    expect(waiting, isNot(runOut));
    final muted =
        tester.widget<Text>(find.textContaining('00:00')).style!.color;
    expect(muted, waiting);
  });
}
