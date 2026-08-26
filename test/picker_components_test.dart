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
import 'package:seatlayer/src/seat_layer_error.dart';

import 'picker_test_fixture.dart';

final class _FakeMapController extends SeatLayerController {
  _FakeMapController({this.handler});

  final Future<Object?> Function(String command, Object? payload)? handler;
  final events = StreamController<EventSignal>.broadcast();
  final calls = <(String, Object?)>[];
  Map<String, Object?> current = pickerSnapshot();

  @override
  Stream<EventSignal> get onBridgeEvent => events.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async {
    calls.add((command, payload));
    if (handler != null) return handler!(command, payload);
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

Widget _app(
  _FakeMapController map,
  Widget child, {
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
}) {
  final picker = SeatLayerPickerController(mapController: map);
  return MaterialApp(
    home: Scaffold(
      body: SeatLayerPickerScope(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        controller: picker,
        options: options,
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

  testWidgets('white-label entitlement hides only the attribution',
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
    final snapshot = pickerSnapshot();
    (snapshot['branding']! as Map<String, Object?>)['attributionRequired'] =
        false;
    map.emit(snapshot);
    await tester.pump();

    expect(find.text('TEST MODE · BOOKS NOTHING'), findsOneWidget);
    expect(find.text('Powered by SeatLayer'), findsNothing);
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

  testWidgets('read-only chrome disables inventory controls and prompts',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        const Column(
          children: <Widget>[
            SeatLayerPickerBestAvailable(),
            SeatLayerPickerSeatConfirmation(),
            SeatLayerPickerSelectionTray(),
            SeatLayerPickerCheckoutBar(onCheckout: _noopCheckout),
          ],
        ),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Find best seats'),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Confirm'), findsNothing);
    expect(tester.widget<InputChip>(find.byType(InputChip)).onDeleted, isNull);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Continue'),
          )
          .onPressed,
      isNull,
    );
    expect(map.calls, isEmpty);
  });

  testWidgets(
      'best available defaults to the focused section zone and active category',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final snapshot = _bestAvailableSnapshot();

    await tester.pumpWidget(
      _app(map, const SeatLayerPickerBestAvailable()),
    );
    map.emit(snapshot);
    await tester.pump();

    await tester.tap(find.text('Find best seats'));
    await tester.pumpAndSettle();

    expect(find.text('Across venue'), findsOneWidget);
    expect(find.text('Any category'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, 'Gallery'),
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, 'Standard'),
          )
          .selected,
      isTrue,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Find seats'));
    await tester.pumpAndSettle();

    expect(map.calls, hasLength(1));
    expect(map.calls.single.$1, 'picker.bestAvailable');
    expect(map.calls.single.$2, <String, Object?>{
      'qty': 2,
      'categoryKey': 'standard',
      'zoneId': 'gallery',
      'preferPremium': false,
    });
  });

  testWidgets(
      'best available can search across venue with an explicitly chosen category',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final snapshot = _bestAvailableSnapshot(
      categoryFilter: <Object?>['standard', 'premium'],
    );

    await tester.pumpWidget(
      _app(map, const SeatLayerPickerBestAvailable()),
    );
    map.emit(snapshot);
    await tester.pump();

    await tester.tap(find.text('Find best seats'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, 'Any category'),
          )
          .selected,
      isTrue,
    );
    expect(find.text('Internal'), findsNothing);

    await tester.tap(find.text('Across venue'));
    await tester.tap(find.text('Premium'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Find seats'));
    await tester.pumpAndSettle();

    expect(map.calls, hasLength(1));
    expect(map.calls.single.$1, 'picker.bestAvailable');
    expect(map.calls.single.$2, <String, Object?>{
      'qty': 2,
      'categoryKey': 'premium',
      'preferPremium': false,
    });
  });

  testWidgets('turnkey checkout rejects a failed host handoff', (tester) async {
    final map = _FakeMapController(
      handler: (command, payload) async {
        if (command == 'picker.continue') {
          return <String, Object?>{
            'revision': 2,
            'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
            'handoff': checkoutHandoff(),
          };
        }
        if (command == 'picker.rejectHandoff') {
          throw const SeatLayerError.transport('rejection unavailable');
        }
        fail('unexpected command $command');
      },
    );
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        Column(
          children: <Widget>[
            SeatLayerPickerCheckoutBar(
              onCheckout: (_) => throw StateError('checkout route failed'),
            ),
            const SeatLayerPickerActionError(),
          ],
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();

    expect(
      map.calls.map((call) => call.$1),
      <String>['picker.continue', 'picker.rejectHandoff'],
    );
    expect(
      map.calls.last.$2,
      <String, Object?>{'holdId': 'hold-1'},
    );
    expect(find.textContaining('checkout route failed'), findsOneWidget);
    expect(find.textContaining('rejection unavailable'), findsNothing);
  });
}

Future<void> _noopCheckout(_) async {}

Map<String, Object?> _bestAvailableSnapshot({
  List<Object?> categoryFilter = const <Object?>['standard'],
}) {
  final snapshot = pickerSnapshot(withSelection: false);
  final catalog = snapshot['catalog']! as Map<String, Object?>;
  catalog['sections'] = <Object?>[
    <String, Object?>{
      'id': 'gallery-a',
      'label': 'Gallery A',
      'zoneId': 'gallery',
    },
  ];
  catalog['bestAvailableZones'] = <Object?>[
    <String, Object?>{'id': 'gallery', 'label': 'Gallery'},
    <String, Object?>{'id': 'orchestra', 'label': 'Orchestra'},
  ];
  catalog['categories'] = <Object?>[
    ...catalog['categories']! as List<Object?>,
    <String, Object?>{
      'key': 'premium',
      'label': 'Premium',
      'color': '#D97706',
      'priceMin': 50.0,
      'priceMax': 50.0,
      'available': 12,
      'notForSale': false,
      'tiers': <Object?>[],
    },
    <String, Object?>{
      'key': 'internal',
      'label': 'Internal',
      'color': '#64748B',
      'priceMin': 0.0,
      'priceMax': 0.0,
      'available': 5,
      'notForSale': true,
      'tiers': <Object?>[],
    },
  ];
  final map = snapshot['map']! as Map<String, Object?>;
  map['focusedSectionId'] = 'gallery-a';
  map['categoryFilter'] = categoryFilter;
  return snapshot;
}
