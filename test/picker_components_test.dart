import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/picker_toast_explainer.dart';
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
import 'picker_widget_harness.dart' show nativeChromeBundle, pumpToRest;

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
  test('a seat selected after the hold joins the cart from the selection', () {
    // A runtime with a live hold (≤ 0.84.0) reports the hold's lines as the
    // cart and drops a seat selected since; the parser completes the cart from
    // the selection and recounts.
    final snapshot = pickerSnapshot(holdOwner: 'host');
    final selection = snapshot['selection']! as Map<String, Object?>;
    final seats = selection['seats']! as List<Object?>;
    final held = seats.single! as Map<String, Object?>;
    seats.add(<String, Object?>{
      ...held,
      'id': 'seat-a-2',
      'label': 'A-2',
      'seatNumber': '2',
      'price': 30.0,
      'currency': 'EUR',
    });
    final parsed = SeatLayerPickerSnapshot.fromJson(snapshot)!;
    expect(parsed.cartLines.map((line) => line.label), <String>['A-1', 'A-2']);
    expect(parsed.ticketCount, 2);
    expect(parsed.cartTotal, 55.0);
    expect(parsed.cartLines.last.seatId, 'seat-a-2');
  });

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

  testWidgets('native chrome shows one test badge and no SeatLayer credit',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        const Column(
          children: <Widget>[
            SeatLayerPickerTestModeIndicator(),
            // ignore: deprecated_member_use_from_same_package
            SeatLayerPickerAttribution(),
          ],
        ),
      ),
    );
    // Even for a server that still asks for one.
    map.emit(pickerSnapshot());
    await tester.pump();
    expect(find.text('Test mode · books nothing'), findsOneWidget);
    expect(find.textContaining('SeatLayer'), findsNothing);
  });

  group('a tap on the test badge', () {
    const explained = 'Bookings here are not real and no card is charged';
    const surface = Size(390, 700);

    Future<_FakeMapController> pumpBadge(WidgetTester tester) async {
      final map = _FakeMapController();
      addTearDown(map.dispose);
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          map,
          const Stack(
            children: <Widget>[
              Positioned(
                left: 12,
                top: 12,
                child: SeatLayerPickerTestModeIndicator(compact: true),
              ),
              Positioned.fill(child: SeatLayerPickerToastLayer()),
            ],
          ),
        ),
      );
      map.emit(pickerSnapshot());
      await tester.pump();
      return map;
    }

    testWidgets('says what test mode means on a full-width band at the foot',
        (tester) async {
      await pumpBadge(tester);
      expect(find.text(explained), findsNothing);

      await tester.tap(find.byType(SeatLayerPickerTestModeIndicator));
      await tester.pumpAndSettle();
      // Once, and on the band: no tooltip beside it.
      expect(find.text(explained), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PickerExplainerToastCard),
          matching: find.text(explained),
        ),
        findsOneWidget,
      );

      final band = find.byType(PickerExplainerToastCard);
      expect(band, findsOneWidget);
      final rect = tester.getRect(band);
      expect(rect.left, 12);
      expect(rect.right, surface.width - 12);
      expect(rect.bottom, surface.height - 14 - 22,
          reason: 'clear of the cart handle standing over the map foot');
      final box = tester.widget<Container>(
        find.descendant(of: band, matching: find.byType(Container)).first,
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(14));
      final text = tester.widget<Text>(find.text(explained));
      expect(text.style!.fontSize, 13.5);
      expect(text.style!.fontWeight, FontWeight.w500);
      // Ink band: the ground is the map's text colour.
      expect(decoration.color, isNot(text.style!.color));

      // It leaves on its own after the toast dwell.
      await tester.pump(seatLayerToastDwell);
      await tester.pumpAndSettle();
      expect(find.text(explained), findsNothing);
    });

    testWidgets('falls back to a tooltip in a layout without the toast layer',
        (tester) async {
      final map = _FakeMapController();
      addTearDown(map.dispose);
      await tester.pumpWidget(
        _app(
          map,
          const Stack(
            children: <Widget>[
              Positioned(
                left: 12,
                top: 12,
                child: SeatLayerPickerTestModeIndicator(compact: true),
              ),
            ],
          ),
        ),
      );
      map.emit(pickerSnapshot());
      await tester.pump();
      expect(find.text(explained), findsNothing);

      await tester.tap(find.byType(SeatLayerPickerTestModeIndicator));
      await tester.pumpAndSettle();
      expect(find.text(explained), findsOneWidget);
      expect(find.byType(PickerExplainerToastCard), findsNothing);
    });

    testWidgets('clears the sheet handle above a dock band', (tester) async {
      final map = _FakeMapController();
      addTearDown(map.dispose);
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          map,
          const Stack(
            children: <Widget>[
              Positioned(
                left: 12,
                top: 12,
                child: SeatLayerPickerTestModeIndicator(compact: true),
              ),
              Positioned.fill(
                child: SeatLayerPickerToastLayer(bottomInset: 120),
              ),
            ],
          ),
        ),
      );
      map.emit(pickerSnapshot());
      await tester.pump();
      await tester.tap(find.byType(SeatLayerPickerTestModeIndicator));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(PickerExplainerToastCard)).bottom,
        surface.height - 120 - 22 - 14,
      );
    });

    testWidgets('leaves on a tap, and follows reading direction',
        (tester) async {
      await pumpBadge(tester);
      await tester.tap(find.byType(SeatLayerPickerTestModeIndicator));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(explained), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(explained)).textAlign,
        isNull,
        reason: 'start-aligned, so it follows the ambient direction',
      );

      await tester.tap(find.byType(PickerExplainerToastCard));
      await tester.pumpAndSettle();
      expect(find.text(explained), findsNothing);
    });

    testWidgets('is a button, and the band is a live region', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpBadge(tester);
      expect(
        tester.getSemantics(find.byType(SeatLayerPickerTestModeIndicator)),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(find.byType(SeatLayerPickerTestModeIndicator));
      await tester.pumpAndSettle();
      final node = tester.getSemantics(find.text(explained));
      expect(
        node.getSemanticsData().flagsCollection.isLiveRegion,
        isTrue,
      );
      semantics.dispose();
    });
  });

  testWidgets('the test badge is named by its long sentence', (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(map, const Center(child: SeatLayerPickerTestModeIndicator())),
    );
    map.emit(pickerSnapshot());
    await tester.pump();
    expect(
      find.bySemanticsLabel(RegExp('Test mode · books nothing')),
      findsWidgets,
    );
    expect(find.bySemanticsLabel(RegExp('No real inventory')), findsNothing);
    semantics.dispose();
  });

  for (final compact in <bool>[true, false]) {
    testWidgets(
        'the ${compact ? 'compact' : 'wide'} test badge says its name once, '
        'with the explanation as its tooltip', (tester) async {
      final map = _FakeMapController();
      addTearDown(map.dispose);
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          map,
          Center(child: SeatLayerPickerTestModeIndicator(compact: compact)),
        ),
      );
      map.emit(pickerSnapshot());
      await tester.pump();
      final badge = find.byType(SeatLayerPickerTestModeIndicator);
      final strings = SeatLayerPickerScope.stringsOf(tester.element(badge));
      final data = tester.getSemantics(badge).getSemanticsData();
      expect(data.label, strings.testModeLong);
      expect(data.tooltip, strings.testModeExplained);
      expect(data.hint, isEmpty);
      semantics.dispose();
    });
  }

  group('the explanation band', () {
    const toast = PickerExplainerToast('Bookings here are not real');

    testWidgets('sizes to its sentence inside a host row', (tester) async {
      final map = _FakeMapController();
      addTearDown(map.dispose);
      await tester.pumpWidget(
        _app(
          map,
          const Row(
            children: <Widget>[SeatLayerPickerToastCard(toast: toast)],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final card = find.byType(PickerExplainerToastCard);
      expect(card, findsOneWidget);
      expect(
        tester.getSize(card).width,
        lessThan(tester.getSize(find.byType(Row)).width),
      );
    });

    testWidgets('fills a width it is given', (tester) async {
      final map = _FakeMapController();
      addTearDown(map.dispose);
      await tester.pumpWidget(
        _app(
          map,
          const Center(
            child: SizedBox(
              width: 300,
              child: SeatLayerPickerToastCard(toast: toast),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(PickerExplainerToastCard)).width, 300);
    });
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

    expect(find.text('Section'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Row'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Seat'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add seat'), findsOneWidget);
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
      find.widgetWithText(FilledButton, 'Add seat'),
    );
    expect(
      cancelButton.style?.foregroundColor?.resolve(<WidgetState>{}),
      const Color(0xFF172033),
    );
    expect(
      selectButton.style?.backgroundColor?.resolve(<WidgetState>{}),
      const Color(0xFFE54558),
    );

    await tester.tap(find.text('Add seat'));
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

    await tester.tap(find.text('Add seat'));
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
    expect(find.text('Add seat'), findsOneWidget);

    ready.complete();
    await pumpToRest(tester);

    // A completed custom callback is not proof that an immersive surface is
    // mounted; the card only stands down for runtime-reported panorama/3D.
    expect(find.text('Add seat'), findsOneWidget);
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
    await pumpToRest(tester);

    IgnorePointer mapGate() => tester.widget<IgnorePointer>(
          find.byWidgetPredicate(
            (widget) => widget is IgnorePointer && widget.child?.key == mapKey,
          ),
        );

    expect(find.text('Add seat'), findsOneWidget);
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');

    map.emit(pickerSnapshot(revision: 2, holdOwner: 'picker'));
    await pumpToRest(tester);

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
    await pumpToRest(tester);

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
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    // The scene is not an answer to the card's question — the buyer is still
    // outside the seat looking at it — so the card comes with it, and owns
    // the tap while it is asking.
    expect(find.text('Add seat'), findsOneWidget);
    expect(mapGate().ignoring, isTrue);
    expect(
      find.byKey(
        const ValueKey<String>('seatlayer-picker-prompt-transition'),
      ),
      findsOneWidget,
    );
    expect(picker.confirmedTicketCount, 0);
    expect(picker.seatAwaitingConfirmation?.id, 'seat-a-1');

    map.emit(pickerSnapshot(revision: 5, holdOwner: 'picker'));
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    expect(find.text('Add seat'), findsNothing);
    expect(mapGate().ignoring, isFalse);
    final interactionCalls = map.calls
        .where((call) => call.$1 == 'picker.setInteractionEnabled')
        .toList();
    expect(interactionCalls, hasLength(2));
    expect(interactionCalls.last.$2, <String, Object?>{'enabled': true});
  });

  // §3.13.13: a buyer back from checkout who
  // tries to change their seats meets a state with a way out, in their own
  // words, not the bridge's `hold_owned_by_host` sentence.
  testWidgets('a hold the host owns is a state with a way out, not an error',
      (tester) async {
    final map = _FakeMapController(
      handler: (command, payload) async {
        if (command == 'picker.continue') {
          return <String, Object?>{
            'revision': 2,
            'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
            'handoff': checkoutHandoff(),
          };
        }
        if (command == 'picker.holdSelection') {
          throw const SeatLayerError.bridge(
            BridgeErrorPayload(
              code: 'hold_owned_by_host',
              message: 'the active hold belongs to the host and cannot be '
                  'changed by picker cart controls',
            ),
          );
        }
        if (command == 'picker.rejectHandoff') {
          return <String, Object?>{
            'revision': 3,
            'snapshot': pickerSnapshot(revision: 3),
          };
        }
        fail('unexpected command $command');
      },
    );
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    await tester.pumpWidget(
      _app(
        map,
        Column(
          children: <Widget>[
            SeatLayerPickerCheckoutBar(onCheckout: (_) async {}),
            const SeatLayerPickerActionError(),
          ],
        ),
        pickerController: picker,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();
    expect(picker.state.checkoutHandoff?.holdId, 'hold-1');

    // Back from checkout, the buyer asks for a hold the host already owns.
    await expectLater(picker.holdSelection(), throwsA(isA<SeatLayerError>()));
    await tester.pump();
    expect(find.text('Your seats are already in checkout'), findsOneWidget);
    expect(find.textContaining('belongs to the host'), findsNothing);
    expect(find.text('Release and change seats'), findsOneWidget);

    // The way out gives the held seats back and clears the notice.
    await tester.tap(find.text('Release and change seats'));
    await tester.pump();
    await tester.pump();
    expect(map.calls.last.$1, 'picker.rejectHandoff');
    expect(map.calls.last.$2, <String, Object?>{'holdId': 'hold-1'});
    expect(picker.state.error, isNull);
    expect(picker.state.checkoutHandoff, isNull);
    expect(find.text('Your seats are already in checkout'), findsNothing);
  });

  testWidgets('a hold the picker already has is said as such', (tester) async {
    final map = _FakeMapController(
      handler: (command, payload) async {
        if (command == 'picker.holdSelection') {
          throw const SeatLayerError.bridge(
            BridgeErrorPayload(
              code: 'hold_already_active',
              message: 'a hold is already open for this picker',
            ),
          );
        }
        fail('unexpected command $command');
      },
    );
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerActionError(), pickerController: picker),
    );
    map.emit(pickerSnapshot());
    await tester.pump();
    await expectLater(picker.holdSelection(), throwsA(isA<SeatLayerError>()));
    await tester.pump();
    expect(find.text('Your seats are already held'), findsOneWidget);
    expect(find.text('Release and change seats'), findsNothing);
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
