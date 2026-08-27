import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_components.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerLayout _layout = SeatLayerPickerLayout();

void main() {
  group('header', () {
    testWidgets('the phone header is one 56-point line', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          SeatLayerPickerHeader(compact: true, onClose: () {}),
        ),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(SeatLayerPickerHeader)).height,
        _layout.headerHeight,
      );
      expect(find.text('Mobile Test Event'), findsOneWidget);
      // The venue is the second line the phone header does not have.
      expect(find.text('Riverside Auditorium'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('the hold countdown is in the header and nowhere else',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerHeader(compact: true)),
      );
      map.emit(pickerSnapshot(holdOwner: 'picker'));
      await tester.pumpAndSettle();

      expect(find.byType(SeatLayerPickerHoldCountdown), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('no hold means no pill', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerHeader(compact: true)),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer_outlined), findsNothing);
    });

    testWidgets('the pill can be turned off', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerHeader(compact: true, showHoldPill: false),
        ),
      );
      map.emit(pickerSnapshot(holdOwner: 'picker'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer_outlined), findsNothing);
    });
  });

  group('price legend', () {
    testWidgets('compact chips carry a dot and a price only', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPriceLegend(compact: true)),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(find.text('€25'), findsOneWidget);
      expect(find.text('Standard · €25'), findsNothing);
      expect(tester.getSize(find.byType(SeatLayerPriceLegend)).height, 30);
    });

    testWidgets('a chip filters the map to its category and frames it',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPriceLegend(compact: true)),
      );
      map.emit(
        bestAvailableSnapshot(categoryFilter: <Object?>[]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('€25'));
      await tester.pump();

      expect(map.callsTo('picker.setCategoryFilter').single.$2, <String, Object?>{
        'categoryKeys': <String>['standard'],
        'focus': true,
      });
    });

    testWidgets('tapping the active chip clears the filter', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPriceLegend(compact: true)),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('€25'));
      await tester.pump();

      expect(map.callsTo('picker.setCategoryFilter').single.$2, <String, Object?>{
        'categoryKeys': null,
      });
    });

    testWidgets('a not-for-sale category never appears', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPriceLegend(compact: true)),
      );
      map.emit(bestAvailableSnapshot());
      await tester.pumpAndSettle();

      expect(find.text('€0'), findsNothing);
    });
  });

  group('map controls', () {
    testWidgets('the phone puts three controls in three corners',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerMapControls(compact: true)),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      final screen = tester.getRect(find.byType(SeatLayerPickerMapControls));
      final segmented =
          tester.getRect(find.byType(SeatLayerPickerViewModeControl));
      final access =
          tester.getRect(find.byType(SeatLayerPickerAccessibilityFilters));
      final fit = tester.getRect(find.byType(SeatLayerPickerZoomToFitButton));

      expect(segmented.right, closeTo(screen.right - 10, .5));
      expect(segmented.top, closeTo(screen.top + 10, .5));
      expect(access.left, closeTo(screen.left + 10, .5));
      expect(access.bottom, closeTo(screen.bottom - 10, .5));
      expect(fit.right, closeTo(screen.right - 10, .5));
      expect(fit.bottom, closeTo(screen.bottom - 10, .5));

      // Pinch already zooms, and the colourblind palette lives in the
      // accessibility sheet.
      expect(find.byType(SeatLayerPickerZoomInButton), findsNothing);
      expect(find.byType(SeatLayerPickerColorblindButton), findsNothing);
    });

    testWidgets('the accessibility control is a 44-point target',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerMapControls(compact: true)),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(
        tester
            .getSize(find.byType(SeatLayerPickerAccessibilityFilters))
            .height,
        _layout.accessibilityControlSize,
      );
    });

    testWidgets('the segmented control names both sides', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerPickerViewModeControl()),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(find.text('Seat map'), findsOneWidget);
      expect(find.text('3D'), findsOneWidget);

      await tester.tap(find.text('3D'));
      await tester.pump();
      expect(
        map.callsTo('picker.setBuyerView').single.$2,
        <String, Object?>{'view': 'venue3d'},
      );
    });

    testWidgets('controls lift above the dock bar', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerMapControls(compact: true, bottomInset: 52),
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      final screen = tester.getRect(find.byType(SeatLayerPickerMapControls));
      final fit = tester.getRect(find.byType(SeatLayerPickerZoomToFitButton));
      expect(fit.bottom, closeTo(screen.bottom - 62, .5));
    });

    testWidgets('a host can ask for the zoom pair back', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerMapControls(compact: true),
          options: const SeatLayerPickerOptions(
            chrome: SeatLayerPickerChromeOptions(showZoomControls: true),
          ),
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(find.byType(SeatLayerPickerZoomInButton), findsOneWidget);
    });

    testWidgets('chrome options can empty the map entirely', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerMapControls(compact: true),
          options: const SeatLayerPickerOptions(
            chrome: SeatLayerPickerChromeOptions(
              showZoomToFitControl: false,
              showViewModeControl: false,
              showAccessibilityControl: false,
            ),
          ),
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      expect(find.byType(SeatLayerPickerZoomToFitButton), findsNothing);
      expect(find.byType(SeatLayerPickerViewModeControl), findsNothing);
      expect(find.byType(SeatLayerPickerAccessibilityFilters), findsNothing);
    });

    testWidgets('the colourblind palette is inside the accessibility sheet',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerPickerAccessibilityFilters(compact: true),
        ),
      );
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Colorblind-safe colors'), findsOneWidget);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('header golden — ${brightness.name}', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Align(
            alignment: Alignment.topCenter,
            child: goldenSubject(
              SeatLayerPickerHeader(compact: true, onClose: () {}),
            ),
          ),
          platformBrightness: brightness,
        ),
      );
      map.emit(pickerSnapshot(holdOwner: 'picker'));
      await tester.pumpAndSettle();

      await expectGolden(tester, 'header_${brightness.name}');
    });

    testWidgets('price legend golden — ${brightness.name}', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Align(
            alignment: Alignment.topCenter,
            child: goldenSubject(const SeatLayerPriceLegend(compact: true)),
          ),
          platformBrightness: brightness,
        ),
      );
      map.emit(bestAvailableSnapshot());
      await tester.pumpAndSettle();

      await expectGolden(tester, 'price_legend_${brightness.name}');
    });

    testWidgets('map controls golden — ${brightness.name}', (tester) async {
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
      map.emit(pickerSnapshot(withSelection: false));
      await tester.pumpAndSettle();

      await expectGolden(tester, 'map_controls_${brightness.name}');
    });
  }
}
