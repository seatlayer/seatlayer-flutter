import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_client.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_components.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_presentation.dart';
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
        'background': '#f7f8fa',
        'rowLabelColor': '#334155',
        'textColor': '#172033',
        'selectionColor': '#5b4b8a',
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

  testWidgets('compact map controls keep zoom and view mode available',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerMapControls(compact: true)),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.byTooltip('Zoom out'), findsOneWidget);
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

  testWidgets('mobile ticket dock stays compact until its controls are opened',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    bool? requestedExpansion;
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerMobileTicketPanel(
          expanded: false,
          onExpandedChanged: (expanded) => requestedExpansion = expanded,
          onCheckout: _noopCheckout,
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pump();

    expect(
      tester.getSize(find.byType(SeatLayerPickerMobileTicketPanel)).height,
      50,
    );
    expect(find.text('From €25'), findsOneWidget);
    expect(find.text('Find the best seats together'), findsNothing);
    expect(find.text('Powered by SeatLayer'), findsNothing);

    await tester.tap(find.text('Best seats'));
    expect(requestedExpansion, isTrue);
  });

  testWidgets(
      'selected mobile ticket dock replaces minimum price with total and review',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    bool? requestedExpansion;
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerMobileTicketPanel(
          expanded: false,
          onExpandedChanged: (expanded) => requestedExpansion = expanded,
          onCheckout: _noopCheckout,
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();
    // Let the action crossfade finish: AnimatedSwitcher intentionally keeps
    // the outgoing Best seats button mounted while Review enters.
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump();

    expect(find.text('1 ticket · €25'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('From €25'), findsNothing);
    expect(find.text('Best seats'), findsNothing);

    await tester.tap(find.text('Review'));
    expect(requestedExpansion, isTrue);
  });

  testWidgets('held mobile ticket dock continues directly to checkout',
      (tester) async {
    final map = _FakeMapController(
      handler: (command, payload) async {
        if (command != 'picker.continue') fail('unexpected command $command');
        return <String, Object?>{
          'revision': 2,
          'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
          'handoff': checkoutHandoff(),
        };
      },
    );
    addTearDown(map.dispose);
    SeatLayerCheckoutHandoff? checkout;
    await tester.pumpWidget(
      _app(
        map,
        SeatLayerPickerMobileTicketPanel(
          expanded: false,
          onExpandedChanged: _ignoreExpanded,
          onCheckout: (handoff) => checkout = handoff,
        ),
      ),
    );
    map.emit(pickerSnapshot(holdOwner: 'picker'));
    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Review'), findsNothing);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();

    expect(map.calls.single.$1, 'picker.continue');
    expect(checkout?.holdId, 'hold-1');
  });

  testWidgets('ticket tray renders a readable vertical buyer cart',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(map, const SeatLayerPickerSelectionTray(compact: true)),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    expect(find.text('Your tickets'), findsOneWidget);
    expect(find.text('1 ticket · €25'), findsOneWidget);
    expect(find.text('Row A · Seat 1'), findsOneWidget);
    expect(find.text('Gallery · Standard · Adult'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    expect(find.byType(InputChip), findsNothing);
    expect(find.byType(SeatLayerPickerTicketCard), findsOneWidget);
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

    await tester.tap(find.text('Select'));
    await tester.pump();
    expect(confirmed, isTrue);
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

  testWidgets('mobile ticket dock adapts to each device bottom inset',
      (tester) async {
    final map = _FakeMapController();
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(map.dispose);
    addTearDown(picker.dispose);
    const phoneMedia = MediaQueryData(
      size: Size(390, 844),
      padding: EdgeInsets.only(bottom: 34),
      viewPadding: EdgeInsets.only(bottom: 34),
    );

    Future<double> panelHeight({
      required bool expanded,
      required SeatLayerPickerMobilePanelSafeArea safeArea,
      MediaQueryData media = phoneMedia,
    }) async {
      await tester.pumpWidget(
        _app(
          map,
          SeatLayerPickerMobileTicketPanel(
            expanded: expanded,
            onExpandedChanged: _ignoreExpanded,
            onCheckout: _noopCheckout,
            bottomSafeArea: safeArea,
          ),
          mediaQueryData: media,
          pickerController: picker,
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();
      return tester
          .getSize(find.byType(SeatLayerPickerMobileTicketPanel))
          .height;
    }

    expect(
      await panelHeight(
        expanded: false,
        safeArea: SeatLayerPickerMobilePanelSafeArea.adaptive,
      ),
      62,
    );
    expect(
      await panelHeight(
        expanded: false,
        safeArea: SeatLayerPickerMobilePanelSafeArea.full,
      ),
      84,
    );
    expect(
      await panelHeight(
        expanded: false,
        safeArea: SeatLayerPickerMobilePanelSafeArea.none,
      ),
      50,
    );

    const navigationBarMedia = MediaQueryData(
      size: Size(390, 844),
      padding: EdgeInsets.only(bottom: 48),
      viewPadding: EdgeInsets.only(bottom: 48),
    );
    expect(
      await panelHeight(
        expanded: false,
        safeArea: SeatLayerPickerMobilePanelSafeArea.adaptive,
        media: navigationBarMedia,
      ),
      98,
    );

    final expandedWithoutInset = await panelHeight(
      expanded: true,
      safeArea: SeatLayerPickerMobilePanelSafeArea.none,
    );
    final expandedWithInset = await panelHeight(
      expanded: true,
      safeArea: SeatLayerPickerMobilePanelSafeArea.adaptive,
    );
    expect(expandedWithInset - expandedWithoutInset, 12);
  });

  testWidgets(
      'expanded mobile footer releases attribution space when branding hides it',
      (tester) async {
    Future<double> expandedHeight({required bool attributionRequired}) async {
      final map = _FakeMapController();
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(map.dispose);
      addTearDown(picker.dispose);
      await tester.pumpWidget(
        _app(
          map,
          const SeatLayerPickerMobileTicketPanel(
            expanded: true,
            onExpandedChanged: _ignoreExpanded,
            onCheckout: _noopCheckout,
          ),
          mediaQueryData: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(bottom: 34),
            viewPadding: EdgeInsets.only(bottom: 34),
          ),
          pickerController: picker,
        ),
      );
      final snapshot = pickerSnapshot(withSelection: false);
      (snapshot['branding']! as Map<String, Object?>)['attributionRequired'] =
          attributionRequired;
      map.emit(snapshot);
      await tester.pumpAndSettle();
      return tester
          .getSize(find.byType(SeatLayerPickerMobileTicketPanel))
          .height;
    }

    final brandedHeight = await expandedHeight(attributionRequired: true);
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
    final whiteLabelHeight = await expandedHeight(attributionRequired: false);
    expect(find.text('Powered by SeatLayer'), findsNothing);
    expect(whiteLabelHeight, lessThan(brandedHeight));
  });

  testWidgets('full-screen picker delegates its bottom inset to the dock',
      (tester) async {
    final map = _FakeMapController();
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(map.dispose);
    addTearDown(picker.dispose);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(bottom: 34),
            viewPadding: EdgeInsets.only(bottom: 34),
          ),
          child: child!,
        ),
        home: SeatLayerPickerPage(
          configuration: SeatLayerConfiguration(event: 'ev_test'),
          controller: picker,
          builders: const SeatLayerPickerBuilders(
            map: _emptyPickerPart,
          ),
          onCheckout: _noopCheckout,
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    final pageSafeArea = find.ancestor(
      of: find.byType(SeatLayerPicker),
      matching: find.byType(SafeArea),
    );
    expect(pageSafeArea, findsOneWidget);
    expect(tester.widget<SafeArea>(pageSafeArea).bottom, isFalse);
    expect(
      tester.getSize(find.byType(SeatLayerPickerMobileTicketPanel)).height,
      62,
    );
  });

  testWidgets(
      'expanded mobile ticket panel exposes the reusable best-seat form',
      (tester) async {
    final map = _FakeMapController();
    addTearDown(map.dispose);
    await tester.pumpWidget(
      _app(
        map,
        const SeatLayerPickerMobileTicketPanel(
          expanded: true,
          onExpandedChanged: _ignoreExpanded,
          onCheckout: _noopCheckout,
        ),
      ),
    );
    map.emit(_bestAvailableSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Find the best seats together'), findsOneWidget);
    expect(find.text('Ticket type'), findsOneWidget);
    expect(find.text('Venue zone'), findsOneWidget);
    expect(find.text('Find 2 best seats'), findsOneWidget);
    expect(find.text('Best seats'), findsNothing);
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
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
            find.widgetWithText(OutlinedButton, 'Best seats'),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Select'), findsNothing);
    expect(find.byType(SeatLayerPickerTicketCard), findsOneWidget);
    expect(find.byTooltip('Remove Row A · Seat 1'), findsNothing);
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

    await tester.tap(find.text('Best seats'));
    await tester.pumpAndSettle();

    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Find 2 best seats'));
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

    await tester.tap(find.text('Best seats'));
    await tester.pumpAndSettle();

    expect(find.text('Any ticket type'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Internal'), findsNothing);

    await tester.tap(find.text('Ticket type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Premium').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Venue zone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any venue zone').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Find 2 best seats'));
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

Widget _emptyPickerPart(
  BuildContext context,
  SeatLayerPickerPartContext part,
) =>
    const SizedBox.shrink();

Future<void> _noopCheckout(_) async {}

void _ignoreExpanded(bool _) {}

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
