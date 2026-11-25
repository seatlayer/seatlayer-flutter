import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

BundleInfo _venueBundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'venue-3d-controls-v1',
        'seat-view-v1',
        'native-seat-view-chrome-v1',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setBuyerView',
        'picker.setVenue3DNavigationMode',
        'picker.openSeatView',
        'picker.zoomIn',
        'picker.zoomOut',
        'picker.zoomToFit',
      ],
    );

/// Three selected seats, with the scene sitting in one of them.
Map<String, Object?> _seated({String at = 'seat-a-2', int revision = 3}) {
  final snapshot = snapshotWithTicketCount(3, revision: revision);
  final map = snapshot['map']! as Map<String, Object?>;
  final selection = snapshot['selection']! as Map<String, Object?>;
  final seats =
      (selection['seats']! as List<Object?>).cast<Map<String, Object?>>();
  final index = seats.indexWhere((seat) => seat['id'] == at);
  map['buyerView'] = 'venue3d';
  map['view3dTargetSeatId'] = at;
  map['view3dTargetSeat'] = index < 0 ? null : seats[index];
  map['view3dPreviousSeatId'] = index > 0 ? seats[index - 1]['id'] : null;
  map['view3dNextSeatId'] =
      index >= 0 && index < seats.length - 1 ? seats[index + 1]['id'] : null;
  map['view3dFocusedSectionId'] = 'section-a';
  map['categoryFilter'] = <Object?>[];
  return snapshot;
}

/// The same scene, in a venue whose row names repeat their section.
///
/// A real chart writes `Stalls D` as the section and `Stalls D C` as the row.
Map<String, Object?> _seatedInQualifiedRow() {
  final snapshot = _seated(at: 'seat-a-1');
  final selection = snapshot['selection']! as Map<String, Object?>;
  selection['seats'] = (selection['seats']! as List<Object?>)
      .map((seat) => <String, Object?>{
            ...seat! as Map<String, Object?>,
            'sectionLabel': 'Stalls D',
            'rowLabel': 'Stalls D C',
          })
      .toList(growable: false);
  final map = snapshot['map']! as Map<String, Object?>;
  map['view3dTargetSeat'] = (selection['seats']! as List<Object?>).first;
  return snapshot;
}

/// The older touch gestures, under which the Rotate / Move pair is drawn.
const SeatLayerPickerOptions _classic = SeatLayerPickerOptions(
  touchNavigation3D: SeatLayer3DTouchNavigation.classic,
);

void main() {
  testWidgets('the chrome stays away until the scene is up', (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Venue'), findsNothing);
    expect(find.text('Back to venue'), findsNothing);
  });

  testWidgets('the caption says where the buyer is sitting', (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    expect(
      find.text('Gallery · Row A · Seat 2 · view from your seat'),
      findsOneWidget,
    );
    expect(find.text('Back to venue'), findsOneWidget);
    expect(find.text('View from here'), findsOneWidget);
    // The runtime's map gestures never read Rotate / Move: no pair is drawn.
    expect(find.text('Rotate venue'), findsNothing);
    expect(find.text('Move venue'), findsNothing);
  });

  testWidgets('the older gestures bring the rotate and move pair back',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerVenue3D(), options: _classic),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    expect(find.text('Rotate venue'), findsOneWidget);
    expect(find.text('Move venue'), findsOneWidget);
  });

  testWidgets('the phone exposes the exact-gated rotate and move mode',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerVenue3D(), options: _classic),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    // The selected half is the gesture already in use: pressing it again
    // sends nothing.
    await tester.tap(find.text('Rotate venue'));
    await tester.pump();
    expect(map.callsTo('picker.setVenue3DNavigationMode'), isEmpty);

    await tester.tap(find.text('Move venue'));
    await tester.pump();

    expect(
      map.callsTo('picker.setVenue3DNavigationMode').single.$2,
      <String, Object?>{'mode': 'pan'},
    );
  });

  group('the rotate / move pair', () {
    Finder half(String hint) => find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.hint == hint,
        );

    testWidgets('gives each half a full touch reach, even with short words',
        (tester) async {
      final map = FakePickerMap(bundle: _venueBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerVenue3D(),
          options: const SeatLayerPickerOptions(
            touchNavigation3D: SeatLayer3DTouchNavigation.classic,
            strings: SeatLayerPickerStrings(orbitMode: 'R', panMode: 'M'),
          ),
        ),
      );
      map.emit(_seated());
      await tester.pumpAndSettle();
      const strings = SeatLayerPickerStrings();
      for (final hint in <String>[strings.rotateVenue, strings.moveVenue]) {
        final size = tester.getSize(half(hint).first);
        expect(size.width, greaterThanOrEqualTo(44), reason: hint);
        expect(size.height, greaterThanOrEqualTo(44), reason: hint);
      }
    });

    testWidgets('grows with large text instead of clipping', (tester) async {
      final map = FakePickerMap(bundle: _venueBundle());
      addTearDown(map.dispose);
      // Wide enough for both halves side by side at this size: this is about
      // each half's height.
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        pickerHarness(
          map,
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(3),
              ),
              child: const Center(
                child: SeatLayerPicker3DNavigationModeButton(),
              ),
            ),
          ),
          options: _classic,
        ),
      );
      map.emit(_seated());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final label = find.text('Rotate venue');
      final pill = find.ancestor(
        of: label,
        matching: find.byType(AnimatedContainer),
      );
      // Three times the label's size, with nothing cut off its top or foot.
      const tall = SeatLayerSizeTokens.immersiveNavChipFontSize * 3;
      expect(tester.getSize(label).height, greaterThanOrEqualTo(tall));
      expect(tester.getSize(pill.first).height, greaterThanOrEqualTo(tall));
    });

    testWidgets('says it is disabled while the picker is busy', (tester) async {
      final semantics = tester.ensureSemantics();
      final map = FakePickerMap(bundle: _venueBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerVenue3D(), options: _classic),
      );
      map.emit(_seated());
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Move venue')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: true),
      );

      final gate = Completer<void>();
      map.gate('picker.setVenue3DNavigationMode', gate);
      await tester.tap(find.text('Move venue'));
      await tester.pump();
      for (final label in <String>['Rotate venue', 'Move venue']) {
        expect(
          tester.getSemantics(find.text(label)),
          isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
          reason: label,
        );
      }
      gate.complete();
      await tester.pumpAndSettle();
      semantics.dispose();
    });
  });

  testWidgets('the caption drops the section the row name repeats',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seatedInQualifiedRow());
    await tester.pumpAndSettle();

    expect(
      find.text('Stalls D · Row C · Seat 1 · view from your seat'),
      findsOneWidget,
    );
    expect(find.textContaining('Row Stalls D C'), findsNothing);
  });

  testWidgets('the caption names the row and the seat in the buyer\'s words',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final strings = SeatLayerPickerStrings.forLocale(const Locale('ar'));

    await tester.pumpWidget(
      pickerHarness(
        map,
        const Directionality(
          textDirection: TextDirection.rtl,
          child: SeatLayerVenue3D(),
        ),
        options: SeatLayerPickerOptions(strings: strings),
      ),
    );
    map.emit(_seatedInQualifiedRow());
    await tester.pumpAndSettle();

    expect(
      find.text(
        strings.seatIdentity(<String>[
          'Stalls D',
          // The chart's own name for its rows stays, as on the seat card.
          'Row C',
          '${strings.seatWord} 1',
          strings.viewFromYourSeat,
        ]),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Seat'), findsNothing);
  });

  testWidgets('stepping retargets the scene rather than rebuilding it',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next seat'));
    await tester.pump();

    expect(map.callsTo('picker.setBuyerView').single.$2, <String, Object?>{
      'view': 'venue3d',
      'flyToSeatId': 'seat-a-3',
    });
  });

  testWidgets('the 3D target and row neighbour need not be in the cart',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    final snapshot = _seated();
    final mapState = snapshot['map']! as Map<String, Object?>;
    mapState['view3dTargetSeatId'] = 'orchestra-e-29';
    mapState['view3dTargetSeat'] = <String, Object?>{
      'id': 'orchestra-e-29',
      'label': 'E-29',
      'sectionLabel': 'Orchestra',
      'rowLabel': 'E',
      'seatNumber': '29',
    };
    mapState['view3dPreviousSeatId'] = 'orchestra-e-28';
    mapState['view3dNextSeatId'] = 'orchestra-e-30';
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(
      find.text('Orchestra · Row E · Seat 29 · view from your seat'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Next seat'));
    await tester.pump();
    expect(map.callsTo('picker.setBuyerView').single.$2, <String, Object?>{
      'view': 'venue3d',
      'flyToSeatId': 'orchestra-e-30',
    });
  });

  testWidgets('stepping stops at the ends', (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated(at: 'seat-a-1'));
    await tester.pumpAndSettle();

    expect(_iconEnabled(tester, 'Previous seat'), isFalse);
    expect(_iconEnabled(tester, 'Next seat'), isTrue);
  });

  testWidgets('the target opens its lazy panorama and recentres the camera',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    await tester.tap(find.text('View from here'));
    await tester.pump();
    expect(map.callsTo('picker.openSeatView').single.$2, <String, Object?>{
      'seatId': 'seat-a-2',
    });

    await tester.tap(find.byTooltip('Recentre the view'));
    await tester.pump();
    expect(map.callsTo('picker.setBuyerView').last.$2, <String, Object?>{
      'view': 'venue3d',
      'flyToSeatId': 'seat-a-2',
      'resetView': true,
    });
  });

  testWidgets('an open panorama suppresses the venue controls', (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    map.emitEvent('seatView.changed', <String, Object?>{
      'seatView': <String, Object?>{
        'seatId': 'seat-a-2',
        'title': 'View from Gallery · A-2',
        'real': true,
        'generated': false,
      },
    });
    await tester.pumpAndSettle();

    expect(find.text('Back to venue'), findsNothing);
    expect(find.text('View from here'), findsNothing);
    expect(find.byTooltip('Next seat'), findsNothing);
  });

  testWidgets(
      'back walks a seat target to 3D without duplicating the map toggle',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    map.emit(_seated());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to venue'));
    await tester.pump();

    expect(
      map.callsTo('picker.setBuyerView').single.$2,
      <String, Object?>{'view': 'venue3d', 'resetView': true},
    );

    // The preceding command response already advances the fake to revision 4.
    final overview = _seated(revision: 5);
    final overviewMap = overview['map']! as Map<String, Object?>;
    overviewMap['view3dTargetSeatId'] = null;
    overviewMap['view3dTargetSeat'] = null;
    overviewMap['view3dPreviousSeatId'] = null;
    overviewMap['view3dNextSeatId'] = null;
    overviewMap['view3dFocusedSectionId'] = null;
    overviewMap['focusedSectionId'] = null;
    overviewMap['focusedSection'] = null;
    overviewMap['rung'] = 'overview';
    map.emit(overview);
    await tester.pumpAndSettle();

    expect(find.text('Back to venue'), findsNothing);
    expect(find.text('Seat map'), findsNothing);
    expect(find.text('Show whole venue'), findsOneWidget);
  });

  testWidgets('the 3D overview exposes zoom and fit camera controls',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerVenue3D()));
    final overview = _seated();
    final overviewMap = overview['map']! as Map<String, Object?>;
    overviewMap['view3dTargetSeatId'] = null;
    overviewMap['view3dTargetSeat'] = null;
    overviewMap['view3dPreviousSeatId'] = null;
    overviewMap['view3dNextSeatId'] = null;
    overviewMap['view3dFocusedSectionId'] = null;
    map.emit(overview);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Zoom out'), findsOneWidget);
    expect(find.text('Show whole venue'), findsOneWidget);
    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.text('Back to venue'), findsNothing);

    await tester.tap(find.text('Show whole venue'));
    await tester.pump();
    expect(map.callsTo('picker.zoomToFit'), hasLength(1));
  });

  testWidgets('the chrome is dark over a light picker', (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerVenue3D(),
        platformBrightness: Brightness.light,
      ),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    final caption = tester.widget<Text>(
      find.text('Gallery · Row A · Seat 2 · view from your seat'),
    );
    // The scene's own caption ink, not the picker's text colour: this floats
    // over a rendered venue and is the same in either palette.
    expect(caption.style!.color, SeatLayerDarkTokens.immersiveCaptionInk);
  });

  testWidgets('the map-only controls stand down while the scene is up',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerMapControls(compact: true)),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    // There is no flat map to fit or filter, and the 3D chrome owns that
    // corner.
    expect(find.byType(SeatLayerPickerZoomToFitButton), findsNothing);
    expect(find.byType(SeatLayerPickerAccessibilityFilters), findsNothing);
    // The way back out stays.
    expect(find.byType(SeatLayerPickerViewModeControl), findsOneWidget);
  });

  testWidgets('the legend over the scene takes the scene palette',
      (tester) async {
    final map = FakePickerMap(bundle: _venueBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPriceLegend(compact: true),
        platformBrightness: Brightness.light,
      ),
    );
    map.emit(_seated());
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('€25')).style!.color,
      const Color(0xFFEEF1F8),
    );
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('venue 3D golden — ${brightness.name}', (tester) async {
        final map = FakePickerMap(bundle: _venueBundle());
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              // The scene is the WebView; the golden is the chrome over a stand-in.
              const ColoredBox(
                color: Color(0xFF10151F),
                child: SizedBox.expand(child: SeatLayerVenue3D()),
              ),
            ),
            platformBrightness: brightness,
          ),
        );
        map.emit(_seated());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'venue_3d_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}

bool _iconEnabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;
