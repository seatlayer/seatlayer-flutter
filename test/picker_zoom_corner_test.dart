/// WHAT THE PHONE'S MAP CORNER CONTAINS, AND WHEN EACH DISC IS DONE.
///
/// The corner carried one disc. `+` was left out because pinch already zooms
/// in, and the whole-venue disc had been dropped earlier as a second round
/// button beside `−` with nothing on either saying which was which. So a buyer
/// who pinched to a camera between the whole-venue fit and the seats — section
/// blocks on screen, no seats, the venue not framed — had one control, and
/// that control read "no seats visible" as "you are already home" and dimmed
/// itself. Nothing left to press.
///
/// Three discs now, each saying a different thing, and the two that back the
/// camera out dim from one reading: the runtime's own fit pose.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// A runtime that offers the colourblind palette, so the ♿ control has
/// something to open even on a chart that authors no provisions.
BundleInfo _colorblindBundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'colorblind-safe',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setColorblindSafe',
      ],
    );

/// The pressable button inside one of the corner discs.
IconButton _disc(WidgetTester tester, Type control) =>
    tester.widget<IconButton>(
      find.descendant(
          of: find.byType(control), matching: find.byType(IconButton)),
    );

bool _enabled(WidgetTester tester, Type control) =>
    _disc(tester, control).onPressed != null;

/// How far back a disc is drawn, or null where it is drawn at full strength.
/// Whether the disc is drawn dimmed: no shadow lifting it off the map.
///
/// A disabled disc keeps its ground in both themes; the glyph and the ring
/// step back and the shadow goes. Returns null when the disc is lifted.
double? _dim(WidgetTester tester, Type control) {
  final boxes = tester.widgetList<AnimatedContainer>(
    find.descendant(
      of: find.byType(control),
      matching: find.byType(AnimatedContainer),
    ),
  );
  if (boxes.isEmpty) return null;
  final decoration = boxes.first.decoration as BoxDecoration?;
  final shadows = decoration?.boxShadow ?? const <BoxShadow>[];
  return shadows.isEmpty ? SeatLayerOpacityTokens.mapControlDisabled : null;
}

/// Mount the phone corner and stand the camera where [snapshot] says.
Future<FakePickerMap> _corner(
  WidgetTester tester, {
  required Map<String, Object?> snapshot,
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
}) async {
  final map = FakePickerMap();
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      const SeatLayerPickerMapControls(compact: true),
      options: options,
    ),
  );
  map.emit(snapshot);
  await tester.pumpAndSettle();
  return map;
}

void main() {
  testWidgets('the phone corner carries + and the whole venue',
      (tester) async {
    await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false),
    );

    expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    // No "−" on the phone (owner, 2026-09-06): pinch steps out, the disc goes home.
    expect(find.byType(SeatLayerPickerZoomOutButton), findsNothing);
    expect(find.byType(SeatLayerPickerShowWholeVenueButton), findsOneWidget);
  });

  testWidgets('at the whole venue the home disc stays live',
      (tester) async {
    await _corner(
      tester,
      snapshot: pickerSnapshot(
        withSelection: false,
        rung: 'overview',
        atVenueFit: true,
      ),
    );

    // DIMMED, NOT GONE. A control that disappears moves the target under a
    // thumb already reaching for it; one that stays put and plainly cannot be
    // pressed says "you are already looking at everything".
    expect(find.byType(SeatLayerPickerShowWholeVenueButton), findsOneWidget);
    // The whole-venue disc is ALWAYS live: the camera facts in the snapshot
    // are only as fresh as the last state change, and a pinch changes none,
    // so a dimmed escape hatch stranded buyers on a stale reading.
    expect(_enabled(tester, SeatLayerPickerShowWholeVenueButton), isTrue);
    // The buyer looking at everything wants in, and `+` is what answers that.
    expect(_enabled(tester, SeatLayerPickerZoomInButton), isTrue);

    // And it has to LOOK dimmed, or "cannot be pressed" is a fact the buyer
    // only discovers by pressing it.
    expect(_dim(tester, SeatLayerPickerShowWholeVenueButton), isNull);
    expect(_dim(tester, SeatLayerPickerZoomInButton), isNull);
  });

  testWidgets('inside a section the home disc is live', (tester) async {
    // Even standing at the fit pose: leaving the section is a rung of its own,
    // with a card and a dim to clear.
    await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false, atVenueFit: true),
    );

    expect(_enabled(tester, SeatLayerPickerShowWholeVenueButton), isTrue);
  });

  testWidgets('a pinched camera between the venue and the seats is not home',
      (tester) async {
    // Section blocks on screen, no seats, the venue NOT framed. This is the
    // camera the old reading called home.
    await _corner(
      tester,
      snapshot: pickerSnapshot(
        withSelection: false,
        rung: 'overview',
        canZoomOut: false,
        atVenueFit: false,
      ),
    );

    expect(_enabled(tester, SeatLayerPickerShowWholeVenueButton), isTrue);
  });

  testWidgets('an older runtime falls back to its own coarser answer',
      (tester) async {
    // No fit pose on the wire. The SDK reads `canZoomOut` rather than treating
    // the missing field as a pose, so an older runtime keeps working exactly
    // as it did.
    await _corner(
      tester,
      snapshot: pickerSnapshot(
        withSelection: false,
        rung: 'overview',
        canZoomOut: false,
      ),
    );

    // The whole-venue disc is ALWAYS live: the camera facts in the snapshot
    // are only as fresh as the last state change, and a pinch changes none,
    // so a dimmed escape hatch stranded buyers on a stale reading.
    expect(_enabled(tester, SeatLayerPickerShowWholeVenueButton), isTrue);
  });

  testWidgets('+ dims at the far end of the zoom, and stays', (tester) async {
    await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false, canZoomIn: false),
    );

    expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    expect(_enabled(tester, SeatLayerPickerZoomInButton), isFalse);
    // The other two are a different question and are unaffected by it.
  });

  testWidgets('the whole-venue disc leaves the section as it fits',
      (tester) async {
    final map = await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false),
    );

    await tester.tap(find.byType(SeatLayerPickerShowWholeVenueButton));
    await tester.pumpAndSettle();

    // `picker.overview`, not `picker.zoomToFit`: the disc and `−`'s last rung
    // have to land on the same camera, card and dim included, or the two
    // controls disagree about where the whole venue is.
    expect(
      map.calls.map((call) => call.$1),
      contains('picker.overview'),
    );
  });

  testWidgets('the wide rail keeps `+` and `−` and frames nothing itself',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerMapControls()),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    // THE WIDE FIT-TO-SCREEN CONTROL WENT (2026-09-06). Two ways to frame the
    // same flat venue on one layout is one too many, and the one that went is
    // the one pinch already does. The immersive scene keeps its own Fit chip,
    // which frames a camera rather than a map.
    expect(find.byType(SeatLayerPickerZoomToFitButton), findsNothing);
    // The phone's whole-venue disc belongs to the phone corner.
    expect(find.byType(SeatLayerPickerShowWholeVenueButton), findsNothing);
    expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    expect(find.byType(SeatLayerPickerZoomOutButton), findsOneWidget);
  });

  group('the ♿ disc heads the column', () {
    // Owner call 2026-09-06. It stood alone in the map's bottom-left corner —
    // one control facing a stack of them, in the corner the floor selector
    // owns — and read as something the layout had forgotten. It is the top
    // disc of the right-hand column now, on BOTH layouts, because who can sit
    // where is an earlier question than how close the camera is.
    testWidgets('on the phone, above `+` and off the opposite corner',
        (tester) async {
      final map = FakePickerMap(bundle: _colorblindBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerMapControls(compact: true)),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      final screen = tester.getRect(find.byType(SeatLayerPickerMapControls));
      final access =
          tester.getRect(find.byType(SeatLayerPickerAccessibilityFilters));
      final stepIn = tester.getRect(find.byType(SeatLayerPickerZoomInButton));
      expect(
        access.right,
        closeTo(screen.right - SeatLayerSizeTokens.mapAnchorInset, .5),
      );
      expect(access.bottom, lessThan(stepIn.top + .5));
    });

    testWidgets('on the wide rail too, above the discs', (tester) async {
      final map = FakePickerMap(bundle: _colorblindBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerMapControls()),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      final access =
          tester.getRect(find.byType(SeatLayerPickerAccessibilityFilters));
      final stepIn = tester.getRect(find.byType(SeatLayerPickerZoomInButton));
      expect(access.bottom, lessThan(stepIn.top + .5));
      // The same 44-point disc as the phone's, not the panel's labelled
      // button: it floats on the map on both widths.
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('and the drop-in layout draws exactly one, at either width',
        (tester) async {
      // The wide composition used to draw TWO: one lifted off the map's
      // bottom-left corner, one repeated under the best-seats card in the
      // side panel. One control, in the map's column.
      for (final wide in <bool>[false, true]) {
        final map = FakePickerMap(bundle: _colorblindBundle());
        addTearDown(map.dispose);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize =
            wide ? const Size(1280, 900) : const Size(390, 844);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          pickerHarness(
            map,
            SeatLayerPickerAdaptiveLayout(
              onCheckout: (_) async {},
              builders: SeatLayerPickerBuilders(
                map: (context, part) => const SizedBox.expand(),
              ),
            ),
          ),
        );
        map.emit(pickerSnapshot(withSelection: false));
        await pumpToRest(tester);

        expect(
          find.byType(SeatLayerPickerAccessibilityFilters),
          findsOneWidget,
          reason: 'wide=$wide',
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('a host can put its own control at that head', (tester) async {
      final map = FakePickerMap(bundle: _colorblindBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerMapControls(
            compact: true,
            accessibilityControl: Text('mine'),
          ),
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(find.text('mine'), findsOneWidget);
      expect(find.byType(SeatLayerPickerAccessibilityFilters), findsNothing);
    });

    testWidgets('and can take it away entirely', (tester) async {
      final map = FakePickerMap(bundle: _colorblindBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerMapControls(compact: true),
          options: const SeatLayerPickerOptions(
            chrome:
                SeatLayerPickerChromeOptions(showAccessibilityControl: false),
          ),
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(find.byType(SeatLayerPickerAccessibilityFilters), findsNothing);
      expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    });
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('zoom corner — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerPickerMapControls(compact: true)),
            platformBrightness: brightness,
          ),
        );
        // The camera at the venue fit, so the golden carries the dimmed pair
        // as well as the live `+`.
        map.emit(
          pickerSnapshot(
            withSelection: false,
            rung: 'overview',
            atVenueFit: true,
          ),
        );
        await tester.pumpAndSettle();

        await expectGolden(tester, 'zoom_corner_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
