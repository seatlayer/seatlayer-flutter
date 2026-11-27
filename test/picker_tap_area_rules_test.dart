// The rules a small control's extra area keeps: it takes presses only near
// the control, never from a control or from something drawn over it, never
// for a control that does nothing, and it moves nothing on screen.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_tap_area.dart';

/// A 30-point button at [left], [top] that counts its presses in [log].
Widget _button(String name, List<String> log, double left, double top,
        {bool enabled = true}) =>
    Positioned(
      left: left,
      top: top,
      width: 30,
      height: 30,
      child: PickerTapArea(
        enabled: enabled,
        child: GestureDetector(
          key: ValueKey<String>(name),
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => log.add(name) : null,
          child: const SizedBox.expand(),
        ),
      ),
    );

Future<List<String>> _pump(
  WidgetTester tester,
  List<Widget> Function(List<String> log) children, {
  bool root = true,
}) async {
  final log = <String>[];
  final stack = Stack(children: children(log));
  await tester.pumpWidget(Directionality(
    textDirection: TextDirection.ltr,
    child: root ? PickerTapAreaRoot(child: stack) : stack,
  ));
  return log;
}

Widget _ground(List<String> log) => Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => log.add('map'),
      ),
    );

void main() {
  testWidgets('a press beside a small control is its, up to 44 across',
      (tester) async {
    final log = await _pump(
        tester, (log) => <Widget>[_ground(log), _button('a', log, 100, 100)]);
    // 30 drawn, so 7 more each side: 93 to 137.
    await tester.tapAt(const Offset(94, 115));
    await tester.tapAt(const Offset(136, 115));
    await tester.tapAt(const Offset(115, 94));
    await tester.tapAt(const Offset(115, 136));
    expect(log, <String>['a', 'a', 'a', 'a']);
    log.clear();
    await tester.tapAt(const Offset(92, 115));
    await tester.tapAt(const Offset(115, 138));
    expect(log, <String>['map', 'map']);
  });

  testWidgets('it moves nothing', (tester) async {
    await _pump(tester, (log) => <Widget>[_button('a', log, 100, 100)],
        root: false);
    final before = tester.getRect(find.byKey(const ValueKey<String>('a')));
    await _pump(tester, (log) => <Widget>[_button('a', log, 100, 100)]);
    expect(tester.getRect(find.byKey(const ValueKey<String>('a'))), before);
  });

  testWidgets('a control that does nothing leaves its presses to the map',
      (tester) async {
    final log = await _pump(
      tester,
      (log) => <Widget>[
        _ground(log),
        _button('a', log, 100, 100, enabled: false),
      ],
    );
    await tester.tapAt(const Offset(95, 115));
    expect(log, <String>['map']);
  });

  testWidgets(
      'two near each other split the room and reach out on the far side',
      (tester) async {
    // 30 tall, 6 apart: centre to centre 36, less than 44.
    final log = await _pump(
      tester,
      (log) => <Widget>[
        _ground(log),
        _button('a', log, 100, 100),
        _button('b', log, 100, 136),
      ],
    );
    // a: free above, so its square moves up to end where b's begins.
    await tester.tapAt(const Offset(115, 87));
    await tester.tapAt(const Offset(115, 132));
    // b: free below.
    await tester.tapAt(const Offset(115, 134));
    await tester.tapAt(const Offset(115, 179));
    expect(log, <String>['a', 'a', 'b', 'b']);
  });

  testWidgets(
      'what is drawn over a control and answers a tap keeps its presses',
      (tester) async {
    final log = await _pump(
      tester,
      (log) => <Widget>[
        _ground(log),
        _button('a', log, 100, 100),
        Positioned(
          left: 132,
          top: 100,
          width: 40,
          height: 30,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => log.add('card'),
          ),
        ),
      ],
    );
    await tester.tapAt(const Offset(134, 115));
    expect(log, <String>['card']);
  });

  testWidgets('a control under a sheet takes nothing through it',
      (tester) async {
    final log = await _pump(
      tester,
      (log) => <Widget>[
        _ground(log),
        _button('a', log, 100, 100),
        Positioned(
          left: 0,
          top: 120,
          right: 0,
          height: 200,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => log.add('sheet'),
          ),
        ),
      ],
    );
    await tester.tapAt(const Offset(95, 125));
    await tester.tapAt(const Offset(115, 125));
    expect(log, <String>['sheet', 'sheet']);
  });
}
