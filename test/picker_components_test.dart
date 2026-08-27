import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_components.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_scope.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
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

  testWidgets('compact price rail preserves map space and concise money labels',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerPriceRail(compact: true)),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pump();

    expect(
      tester.getSize(find.byType(SeatLayerPickerPriceRail)).height,
      40,
    );
    expect(find.text('€25'), findsOneWidget);
    expect(find.textContaining('Standard ·'), findsNothing);
  });

  testWidgets('price rail keeps unselected chips readable over a dark map',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final snapshot = pickerSnapshot(withSelection: false);
    (snapshot['map']! as Map<String, Object?>)['categoryFilter'] = <Object?>[];
    await tester.pumpWidget(
      _app(
        map,
        const SeatLayerPickerPriceRail(compact: true),
        pickerTheme: const SeatLayerPickerThemeData(
          accent: Color(0xFFE54558),
          onAccent: Colors.white,
          background: Colors.black,
          surface: Colors.white,
          text: Colors.black,
        ),
      ),
    );
    map.emit(snapshot);
    await tester.pump();

    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.selected, isFalse);
    expect(chip.backgroundColor, Colors.white);
    expect((chip.label as Text).style?.color, Colors.black);
  });

  testWidgets('price chip filters and frames one category like the web picker',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final snapshot = pickerSnapshot(withSelection: false);
    (snapshot['map']! as Map<String, Object?>)['categoryFilter'] = <Object?>[];
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerPriceRail(compact: true)),
    );
    map.emit(snapshot);
    await tester.pump();

    await tester.tap(find.text('€25'));
    await tester.pump();

    expect(map.calls.single.$1, 'picker.setCategoryFilter');
    expect(map.calls.single.$2, <String, Object?>{
      'categoryKeys': <String>['standard'],
      'focus': true,
    });
  });

  testWidgets('standalone zoom control can be placed in a custom layout',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerZoomInButton()),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pump();

    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();

    expect(map.calls.single.$1, 'picker.zoomIn');
  });

  testWidgets('compact map controls drop the zoom pair and keep Map/3D',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerMapControls(compact: true)),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Pinch already zooms on a touch screen, so the phone rail spends its
    // space on the controls a finger cannot replace.
    expect(find.byTooltip('Zoom in'), findsNothing);
    expect(find.byTooltip('Zoom out'), findsNothing);
    expect(find.byTooltip('Fit venue'), findsOneWidget);
    expect(find.byTooltip('Open interactive 3D venue'), findsOneWidget);

    await tester.tap(find.byTooltip('Open interactive 3D venue'));
    await tester.pump();
    expect(map.calls.single.$1, 'picker.setBuyerView');
    expect(map.calls.single.$2, <String, Object?>{'view': 'venue3d'});
  });

  testWidgets('chrome options can hide built-in controls without app changes',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        const SeatLayerPickerMapControls(compact: true),
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(
            showZoomControls: false,
            showViewModeControl: false,
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pump();

    expect(find.byTooltip('Zoom in'), findsNothing);
    expect(find.byTooltip('Zoom out'), findsNothing);
    expect(find.byTooltip('Open interactive 3D venue'), findsNothing);
    expect(find.byTooltip('Fit venue'), findsOneWidget);
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

  testWidgets('seat confirmation stays mounted until immersive view is ready',
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

    expect(find.text('Select'), findsNothing);
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

    expect(find.text('Select'), findsOneWidget);
    expect(mapGate().ignoring, isTrue);
    await tester.pump();
    final locks = map.calls
        .where((call) => call.$1 == 'picker.setInteractionEnabled')
        .toList();
    expect(locks, hasLength(1));
    expect(locks.single.$2, <String, Object?>{'enabled': false});

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('Select'), findsNothing);
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
