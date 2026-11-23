// The app-only sentences are what the widgets actually draw, per language.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_checkout_cta.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

final Map<String, Object?> _table = (jsonDecode(
  File('design/locale_strings.json').readAsStringSync(),
) as Map<String, Object?>)['strings']! as Map<String, Object?>;

String _word(String locale, String key) =>
    (_table[locale]! as Map<String, Object?>)[key]! as String;

SeatLayerPickerStrings _strings(String locale) =>
    SeatLayerPickerStrings.forLocale(Locale(locale));

SeatLayerPickerOptions _options(String locale) =>
    SeatLayerPickerOptions(strings: _strings(locale));

void main() {
  testWidgets('the hand-off state draws its own sentence per language',
      (tester) async {
    final snapshot = SeatLayerPickerSnapshot.fromJson(pickerSnapshot())!;
    final state = const SeatLayerPickerState.initializing().applying(snapshot);
    for (final locale in <String>['de', 'pl', 'ar', 'ja']) {
      final cta = seatLayerCheckoutCtaState(
        state: state,
        strings: _strings(locale),
        label: 'Continue',
        canCheckout: true,
        seatCardOpen: false,
        handoffInFlight: true,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: SeatLayerCheckoutCtaLabel(cta: cta)),
        ),
      );
      final sentence = _word(locale, 'seatsSecuredOpeningCheckout');
      expect(sentence, isNot('Seats secured. Opening checkout…'));
      expect(find.text(sentence), findsOneWidget, reason: locale);
    }
  });

  testWidgets('the 3D rotate and move pair draws translated words',
      (tester) async {
    usePhoneSurface(tester);
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'venue-3d-controls-v1',
        ],
        commands: const <String>[
          'picker.setThemeMode',
          'picker.setVenue3DNavigationMode',
        ],
      ),
    );
    addTearDown(map.dispose);
    final snapshot = pickerSnapshot();
    (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
    await tester.pumpWidget(
      pickerHarness(
        map,
        const Center(child: SeatLayerPicker3DNavigationModeButton()),
        // The pair is drawn only under the older touch gestures.
        options: SeatLayerPickerOptions(
          strings: _strings('de'),
          touchNavigation3D: SeatLayer3DTouchNavigation.classic,
        ),
      ),
    );
    map.emit(snapshot);
    await tester.pumpAndSettle();
    expect(find.text(_word('de', 'orbitMode')), findsOneWidget);
    expect(find.text(_word('de', 'panMode')), findsOneWidget);
    expect(find.text('Rotate venue'), findsNothing);
  });

  Future<void> openSheet(
    WidgetTester tester,
    String locale, {
    bool compact = true,
    List<String> filter = const <String>[],
  }) async {
    usePhoneSurface(tester);
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'access-needs-v1',
          'colorblind-safe',
        ],
        commands: const <String>[
          'picker.setThemeMode',
          'picker.setAccessibilityFilter',
          'picker.setColorblindSafe',
        ],
      ),
    );
    addTearDown(map.dispose);
    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomLeft,
          child: SeatLayerPickerAccessibilityFilters(compact: compact),
        ),
        options: _options(locale),
      ),
    );
    map.emit(
      pickerSnapshot(
        accessNeeds: <Object?>[accessNeed('wheelchair', 4)],
        accessibilityFilter: filter,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the provisions heading is drawn as written, not upper-cased',
      (tester) async {
    await openSheet(tester, 'tr');
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('KOLTUKLARI GÖSTER:'), findsOneWidget);
  });

  testWidgets('the heading a host writes in lower case stays as written',
      (tester) async {
    usePhoneSurface(tester);
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'access-needs-v1',
        ],
        commands: const <String>[
          'picker.setThemeMode',
          'picker.setAccessibilityFilter',
        ],
      ),
    );
    addTearDown(map.dispose);
    await tester.pumpWidget(
      pickerHarness(
        map,
        const Align(
          alignment: Alignment.bottomLeft,
          child: SeatLayerPickerAccessibilityFilters(compact: true),
        ),
        options: const SeatLayerPickerOptions(
          strings: SeatLayerPickerStrings(showSeatsFor: 'seats for'),
        ),
      ),
    );
    map.emit(
      pickerSnapshot(accessNeeds: <Object?>[accessNeed('wheelchair', 4)]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('seats for'), findsOneWidget);
  });

  testWidgets('the wide control counts its filters with a plural form',
      (tester) async {
    await openSheet(tester, 'en',
        compact: false, filter: <String>['wheelchair']);
    expect(find.text('1 filter'), findsOneWidget);
    expect(find.text('1 filters'), findsNothing);
  });

  testWidgets('the seat card says a booth\'s place word in normal case',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerConfirmCard(), options: _options('en')),
    );
    final snapshot = pickerSnapshot();
    final selection = Map<String, Object?>.from(
      snapshot['selection']! as Map<String, Object?>,
    );
    selection['seats'] = (selection['seats']! as List<Object?>)
        .map((item) => <String, Object?>{
              ...item! as Map<String, Object?>,
              'objectType': 'booth',
            })
        .toList();
    map.emit(<String, Object?>{...snapshot, 'selection': selection});
    await pumpToRest(tester);
    expect(_strings('en').placeWord, 'PLACE');
    // Drawn as the locale writes it...
    expect(find.text('PLACE'), findsOneWidget);
    // ...and spoken in normal case.
    expect(find.bySemanticsLabel(RegExp(r'\bPlace 1\b')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('PLACE')), findsNothing);
    semantics.dispose();
  });

  testWidgets('the round control names its filters with a plural form',
      (tester) async {
    await openSheet(tester, 'en', filter: <String>['wheelchair']);
    expect(find.byTooltip('1 accessibility filter active'), findsOneWidget);
    expect(find.byTooltip('1 accessibility filters active'), findsNothing);
    expect(
      const SeatLayerPickerStrings().accessibilityFiltersActive(2),
      '2 accessibility filters active',
    );
  });

  testWidgets('the filters sentences are drawn in the buyer\'s language',
      (tester) async {
    await openSheet(tester, 'pl', filter: <String>['wheelchair']);
    expect(find.byTooltip('1 aktywny filtr dostępności'), findsOneWidget);
    await openSheet(tester, 'pl',
        compact: false, filter: <String>['wheelchair']);
    expect(find.text('1 filtr'), findsOneWidget);
  });
}
