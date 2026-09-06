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
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The pressable button inside one of the corner discs.
IconButton _disc(WidgetTester tester, Type control) =>
    tester.widget<IconButton>(
      find.descendant(
          of: find.byType(control), matching: find.byType(IconButton)),
    );

bool _enabled(WidgetTester tester, Type control) =>
    _disc(tester, control).onPressed != null;

/// How far back a disc is drawn, or null where it is drawn at full strength.
double? _dim(WidgetTester tester, Type control) {
  final opacities = tester.widgetList<Opacity>(
    find.descendant(of: find.byType(control), matching: find.byType(Opacity)),
  );
  return opacities.isEmpty ? null : opacities.first.opacity;
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
  testWidgets('the phone corner carries +, − and the whole venue',
      (tester) async {
    await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false),
    );

    expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    expect(find.byType(SeatLayerPickerZoomOutButton), findsOneWidget);
    expect(find.byType(SeatLayerPickerShowWholeVenueButton), findsOneWidget);
  });

  testWidgets('at the whole venue the two back-out discs dim, and stay',
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
    expect(find.byType(SeatLayerPickerZoomOutButton), findsOneWidget);
    expect(find.byType(SeatLayerPickerShowWholeVenueButton), findsOneWidget);
    expect(_enabled(tester, SeatLayerPickerZoomOutButton), isFalse);
    expect(_enabled(tester, SeatLayerPickerShowWholeVenueButton), isFalse);
    // The buyer looking at everything wants in, and `+` is what answers that.
    expect(_enabled(tester, SeatLayerPickerZoomInButton), isTrue);

    // And it has to LOOK dimmed, or "cannot be pressed" is a fact the buyer
    // only discovers by pressing it.
    expect(
      _dim(tester, SeatLayerPickerShowWholeVenueButton),
      SeatLayerOpacityTokens.mapControlDisabled,
    );
    expect(
      _dim(tester, SeatLayerPickerZoomOutButton),
      SeatLayerOpacityTokens.mapControlDisabled,
    );
    expect(_dim(tester, SeatLayerPickerZoomInButton), isNull);
  });

  testWidgets('inside a section both back-out discs are live', (tester) async {
    // Even standing at the fit pose: leaving the section is a rung of its own,
    // with a card and a dim to clear.
    await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false, atVenueFit: true),
    );

    expect(_enabled(tester, SeatLayerPickerZoomOutButton), isTrue);
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

    expect(_enabled(tester, SeatLayerPickerZoomOutButton), isTrue);
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

    expect(_enabled(tester, SeatLayerPickerZoomOutButton), isFalse);
    expect(_enabled(tester, SeatLayerPickerShowWholeVenueButton), isFalse);
  });

  testWidgets('+ dims at the far end of the zoom, and stays', (tester) async {
    await _corner(
      tester,
      snapshot: pickerSnapshot(withSelection: false, canZoomIn: false),
    );

    expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    expect(_enabled(tester, SeatLayerPickerZoomInButton), isFalse);
    // The other two are a different question and are unaffected by it.
    expect(_enabled(tester, SeatLayerPickerZoomOutButton), isTrue);
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

  testWidgets('the wide rail is untouched', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerMapControls()),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    // Wide keeps the fit-to-screen control it has always had; the phone's
    // whole-venue disc belongs to the corner.
    expect(find.byType(SeatLayerPickerZoomToFitButton), findsOneWidget);
    expect(find.byType(SeatLayerPickerShowWholeVenueButton), findsNothing);
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
