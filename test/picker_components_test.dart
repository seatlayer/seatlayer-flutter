import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_components.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';

import 'picker_test_fixture.dart';

final class _FakeMapController extends SeatLayerController {
  final events = StreamController<EventSignal>.broadcast();
  final calls = <(String, Object?)>[];
  Map<String, Object?> current = pickerSnapshot();

  @override
  Stream<EventSignal> get onBridgeEvent => events.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async {
    calls.add((command, payload));
    current = <String, Object?>{...current, 'revision': 2};
    return <String, Object?>{'revision': 2, 'snapshot': current};
  }

  void emit(Map<String, Object?> snapshot) {
    current = snapshot;
    events.add(
      EventSignal(name: 'picker.snapshot', payload: snapshot, sequence: 1),
    );
  }

  @override
  void dispose() {
    unawaited(events.close());
    super.dispose();
  }
}

Widget _app(_FakeMapController map, Widget child) {
  final picker = SeatLayerPickerController(mapController: map);
  return MaterialApp(
    home: Scaffold(
      body: SeatLayerPickerScope(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        controller: picker,
        options: const SeatLayerPickerOptions(),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('native chrome shows one test badge and required attribution',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        const Column(
          children: <Widget>[
            SeatLayerPickerTestModeIndicator(),
            SeatLayerPickerAttribution(),
          ],
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    expect(find.text('TEST MODE · BOOKS NOTHING'), findsOneWidget);
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
  });

  testWidgets('section navigator exposes a reliable native focus action',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final snapshot = pickerSnapshot();
    (snapshot['map']! as Map<String, Object?>)['rung'] = 'sections';
    (snapshot['catalog']! as Map<String, Object?>)['sections'] = <Object?>[
      <String, Object?>{
        'id': 'section-a',
        'label': 'Section A',
        'displayLabel': 'Front section',
      },
    ];

    await tester.pumpWidget(
      _app(map, const SeatLayerPickerSectionNavigator()),
    );
    map.emit(snapshot);
    await tester.pump();
    await tester.tap(find.text('Front section'));
    await tester.pump();

    expect(map.calls, hasLength(1));
    expect(map.calls.single.$1, 'picker.focusSection');
    expect(map.calls.single.$2, <String, Object?>{'sectionId': 'section-a'});
  });
}
