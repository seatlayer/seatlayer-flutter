import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_attribution.dart';
import 'package:seatlayer/src/picker/picker_errors.dart';
import 'package:seatlayer/src/picker/picker_motion.dart';
import 'package:seatlayer/src/picker/picker_seat_confirmation.dart';
import 'package:seatlayer/src/picker/picker_section_navigator.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';
import 'package:seatlayer/src/seat_layer_controller.dart';
import 'package:seatlayer/src/seat_layer_error.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart' show nativeChromeBundle;

final class _FakeMapController extends SeatLayerController {
  _FakeMapController({this.handler, this.bundle});

  final Future<Object?> Function(String command, Object? payload)? handler;
  final BundleInfo? bundle;
  final events = StreamController<EventSignal>.broadcast();
  final calls = <(String, Object?)>[];
  Map<String, Object?> current = pickerSnapshot();
  int _sequence = 0;

  @override
  BundleInfo? get bundleInfo => bundle;

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
      EventSignal(
        name: 'picker.snapshot',
        payload: snapshot,
        sequence: ++_sequence,
      ),
    );
  }

  void emitEvent(String name, Object? payload) {
    events
        .add(EventSignal(name: name, payload: payload, sequence: ++_sequence));
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
  SeatLayerPickerThemeData? pickerTheme,
  MediaQueryData? mediaQueryData,
  SeatLayerPickerController? pickerController,
}) {
  final picker =
      pickerController ?? SeatLayerPickerController(mapController: map);
  return MaterialApp(
    builder: mediaQueryData == null
        ? null
        : (context, child) => MediaQuery(
              data: mediaQueryData,
              child: child!,
            ),
    home: Scaffold(
      body: SeatLayerPickerScope(
        configuration: SeatLayerConfiguration(event: 'ev_test'),
        controller: picker,
        options: options,
        theme: pickerTheme,
        child: child,
      ),
    ),
  );
}

void main() {
  test('light theme serializes the complete renderer map palette', () {
    expect(
      const SeatLayerMapThemeData.light().toBridgeConfig(),
      <String, Object?>{
        'background': '#e9edf4',
        'rowLabelColor': '#334155',
        'textColor': '#172033',
        'selectionColor': '#5b4b8a',
      },
    );
  });

  test('dark theme serializes the complete renderer map palette', () {
    expect(
      const SeatLayerMapThemeData.dark().toBridgeConfig(),
      <String, Object?>{
        'background': '#0f1522',
        'rowLabelColor': '#d7deea',
        'textColor': '#f4f7fb',
        'selectionColor': '#9b8afb',
      },
    );
  });

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
    expect(find.text('Test mode · books nothing'), findsOneWidget);
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

    expect(find.text('Test mode · books nothing'), findsOneWidget);
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

  testWidgets('seat confirmation mirrors the web identity and price hierarchy',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    var confirmed = false;
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerSeatConfirmation(
          onConfirm: (_) => confirmed = true,
        ),
        pickerTheme: const SeatLayerPickerThemeData.light(
          accent: Color(0xFFE54558),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    expect(find.text('SECTION'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('ROW'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('SEAT'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('View from here'), findsOneWidget);
    expect(find.text('See it in 3D'), findsOneWidget);

    final seatViewButton = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byType(SeatLayerPickerSeatViewButton),
        matching: find.byType(OutlinedButton),
      ),
    );
    final seat3DButton = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byType(SeatLayerPickerSeat3DButton),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(SeatLayerPickerSeat3DButton),
        matching: find.byType(FilledButton),
      ),
      findsNothing,
    );
    expect(
      seat3DButton.style?.backgroundColor?.resolve(<WidgetState>{}),
      seatViewButton.style?.backgroundColor?.resolve(<WidgetState>{}),
    );
    expect(
      seat3DButton.style?.foregroundColor?.resolve(<WidgetState>{}),
      const Color(0xFF172033),
    );
    expect(
      tester.getCenter(find.text('View from here')).dy,
      tester.getCenter(find.text('See it in 3D')).dy,
    );

    final cancelButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Cancel'),
    );
    final selectButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Select'),
    );
    expect(
      cancelButton.style?.foregroundColor?.resolve(<WidgetState>{}),
      const Color(0xFF172033),
    );
    expect(
      selectButton.style?.backgroundColor?.resolve(<WidgetState>{}),
      const Color(0xFFE54558),
    );

    await tester.tap(find.text('Select'));
    await tester.pump();
    expect(confirmed, isTrue);
  });

  testWidgets('wide confirmation price follows the pending ticket tier',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerSeatConfirmation()),
    );
    map.emit(tieredSeatSnapshot());
    await tester.pump();

    expect(find.text('€100'), findsNWidgets(2));
    expect(find.text('€60'), findsOneWidget);

    await tester.tap(find.text('Child'));
    await tester.pump();

    expect(find.text('€100'), findsOneWidget);
    expect(find.text('€60'), findsNWidgets(2));

    await tester.tap(find.text('Select'));
    await tester.pump();
    expect(
      map.calls.where((call) => call.$1 == 'picker.setSeatTier').single.$2,
      <String, Object?>{'seatId': 'seat-a-1', 'tierId': 'child'},
    );
  });

  testWidgets('seat inspection actions stack on a narrow confirmation card',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        map,
        const SeatLayerPickerSeatConfirmation(),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    expect(
      tester.getCenter(find.text('View from here')).dy,
      isNot(tester.getCenter(find.text('See it in 3D')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'seat inspection widgets self-wire and remain individually hideable',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        const SeatLayerPickerSeatConfirmation(show3D: false),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    expect(find.text('View from here'), findsOneWidget);
    expect(find.text('See it in 3D'), findsNothing);
    await tester.tap(find.text('View from here'));
    await tester.pump();

    expect(map.calls.single.$1, 'picker.openSeatView');
    expect(map.calls.single.$2, <String, Object?>{'seatId': 'seat-a-1'});
  });

  testWidgets('seat confirmation waits for reported immersive state',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final ready = Completer<void>();
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerSeatConfirmation(
          onViewFromSeat: (_) => ready.future,
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    await tester.tap(find.text('View from here'));
    await tester.pump();

    // The card continues to absorb the originating iOS gesture while the
    // WebView mounts its modal; otherwise that tap can select another seat.
    expect(find.text('Select'), findsOneWidget);

    ready.complete();
    await tester.pumpAndSettle();

    // A completed custom callback is not proof that an immersive surface is
    // mounted; the card only stands down for runtime-reported panorama/3D.
    expect(find.text('Select'), findsOneWidget);
  });

  testWidgets(
      'turnkey inspection stays pending through panorama and 3D, then restores',
      (tester) async {
    final map = _FakeMapController(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'viewport-insets-v1',
          'native-seat-view-chrome-v1',
        ],
        commands: const <String>[
          'picker.setThemeMode',
          'picker.setViewportInsets',
          'picker.setInteractionEnabled',
        ],
      ),
    );
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(map.dispose);
    addTearDown(picker.dispose);
    const mapKey = ValueKey<String>('inspection-map-platform-view-double');
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerAdaptiveLayout(
          onCheckout: _noopCheckout,
          builders: SeatLayerPickerBuilders(
            map: (context, part) => const SizedBox.expand(key: mapKey),
          ),
        ),
        pickerController: picker,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    IgnorePointer mapGate() => tester.widget<IgnorePointer>(
          find.byWidgetPredicate(
            (widget) => widget is IgnorePointer && widget.child?.key == mapKey,
          ),
        );

    expect(find.text('Add seat'), findsOneWidget);
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');

    map.emit(pickerSnapshot(revision: 2, holdOwner: 'picker'));
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsOneWidget);
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');

    map.emitEvent('seatView.changed', <String, Object?>{
      'seatView': <String, Object?>{
        'seatId': 'seat-a-1',
        'title': 'View from Gallery · A-1',
        'real': true,
        'generated': false,
      },
    });
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsNothing);
    expect(mapGate().ignoring, isFalse);
    expect(
      find.byKey(
        const ValueKey<String>('seatlayer-picker-prompt-transition'),
      ),
      findsNothing,
    );
    // Unlocking waits one exit duration on a real timer, so that the tail of
    // the tap that closed the card cannot reach the WebView underneath it.
    await tester.pump(SeatLayerPickerMotion.exit);
    expect(
      map.calls
          .where((call) => call.$1 == 'picker.setInteractionEnabled')
          .last
          .$2,
      <String, Object?>{'enabled': true},
    );
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');

    map.emitEvent(
      'seatView.changed',
      <String, Object?>{'seatView': null},
    );
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('seatlayer-picker-prompt-transition'),
      ),
      findsOneWidget,
    );
    expect(picker.confirmedTicketCount, 0);

    final in3D = pickerSnapshot(revision: 4, holdOwner: 'picker');
    final mapState = in3D['map']! as Map<String, Object?>;
    mapState['buyerView'] = 'venue3d';
    mapState['view3dTargetSeatId'] = 'seat-a-1';
    map.emit(in3D);
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsNothing);
    expect(mapGate().ignoring, isFalse);
    expect(
      find.byKey(
        const ValueKey<String>('seatlayer-picker-prompt-transition'),
      ),
      findsNothing,
    );
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');

    map.emit(pickerSnapshot(revision: 5, holdOwner: 'picker'));
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsOneWidget);
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');
  });

  testWidgets('turnkey prompt removes the map platform view from hit testing',
      (tester) async {
    final map = _FakeMapController();
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(map.dispose);
    addTearDown(picker.dispose);
    const mapKey = ValueKey<String>('map-platform-view-double');
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerAdaptiveLayout(
          onCheckout: _noopCheckout,
          builders: SeatLayerPickerBuilders(
            map: (context, part) => const SizedBox.expand(key: mapKey),
          ),
        ),
        pickerController: picker,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    IgnorePointer mapGate() => tester.widget<IgnorePointer>(
          find.byWidgetPredicate(
            (widget) => widget is IgnorePointer && widget.child?.key == mapKey,
          ),
        );

    expect(find.text('Add seat'), findsOneWidget);
    expect(mapGate().ignoring, isTrue);
    await tester.pump();
    final locks = map.calls
        .where((call) => call.$1 == 'picker.setInteractionEnabled')
        .toList();
    expect(locks, hasLength(1));
    expect(locks.single.$2, <String, Object?>{'enabled': false});

    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsNothing);
    expect(mapGate().ignoring, isFalse);
    final interactionCalls = map.calls
        .where((call) => call.$1 == 'picker.setInteractionEnabled')
        .toList();
    expect(interactionCalls, hasLength(2));
    expect(interactionCalls.last.$2, <String, Object?>{'enabled': true});
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
