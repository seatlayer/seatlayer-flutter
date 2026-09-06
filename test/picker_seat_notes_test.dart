import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_seat_icons.dart';
import 'package:seatlayer/src/picker/picker_seat_notes.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();

List<String> _titles({
  List<String>? accessibility,
  String? wheelchairSpaceType,
  SeatCommercialAttributes? commercial,
}) =>
    seatLayerSeatNoteRows(
      strings: _strings,
      accessibility: accessibility,
      wheelchairSpaceType: wheelchairSpaceType,
      commercial: commercial,
    ).map((row) => row.title).toList(growable: false);

/// The fixture seat, wearing whatever the organizer marked on it.
Map<String, Object?> _seatWith({
  List<String>? accessibility,
  String? wheelchairSpaceType,
  Map<String, Object?>? commercial,
}) {
  final snapshot = pickerSnapshot(seatViewThumb: null);
  final selection = snapshot['selection']! as Map<String, Object?>;
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = <Object?>[
    <String, Object?>{
      ...seat,
      if (accessibility != null) 'accessibility': accessibility,
      if (wheelchairSpaceType != null)
        'wheelchairSpaceType': wheelchairSpaceType,
      if (commercial != null) 'commercial': commercial,
    },
  ];
  return <String, Object?>{
    ...snapshot,
    // No 3D and no photograph: the notes are what this card is about.
    'features': <String, Object?>{'bestAvailable': true},
  };
}

/// WCAG relative contrast, the same formula the theme's own inks are held to.
double _contrast(Color a, Color b) {
  final first = a.computeLuminance() + 0.05;
  final second = b.computeLuminance() + 0.05;
  return first > second ? first / second : second / first;
}

void main() {
  group('which rows a seat earns', () {
    test('a seat with nothing to say says nothing', () {
      expect(_titles(), isEmpty);
      expect(_titles(commercial: const SeatCommercialAttributes()), isEmpty);
    });

    test('every attribute, in one fixed reading order', () {
      expect(
        _titles(
          accessibility: <String>['companion', 'hearing'],
          wheelchairSpaceType: 'no-seat',
          commercial: const SeatCommercialAttributes(
            restrictedView: true,
            obstructedView: true,
            premium: true,
          ),
        ),
        <String>[
          // What the seat provides…
          'Companion',
          'Hearing support',
          'Empty wheelchair space',
          // …then what the buyer should know before paying.
          'Restricted view',
          'Obstructed view',
          'Premium seat',
        ],
      );
    });

    test('gives restricted and obstructed a row EACH', () {
      // The defect this replaced: one collapsed line in which restricted won,
      // so a seat behind both a rail and a pillar reported only the rail.
      expect(
        _titles(
          commercial: const SeatCommercialAttributes(
            restrictedView: true,
            obstructedView: true,
          ),
        ),
        <String>['Restricted view', 'Obstructed view'],
      );
    });

    test('names the provision instead of repeating the accommodation', () {
      expect(
        _titles(
          accessibility: <String>['wheelchair'],
          wheelchairSpaceType: 'no-seat',
        ),
        <String>['Empty wheelchair space'],
      );
      expect(
        _titles(
          accessibility: <String>['wheelchair'],
          wheelchairSpaceType: 'seat-present',
        ),
        <String>['Accessible physical seat'],
      );
      // With no provision reported, the accommodation is all there is.
      expect(_titles(accessibility: <String>['wheelchair']),
          <String>['Wheelchair']);
    });

    test('drops a key this build has no name for, and keeps the rest', () {
      expect(
        _titles(accessibility: <String>[
          'an-accommodation-from-the-future',
          'cart'
        ]),
        <String>['Mobility cart'],
      );
    });

    test("hangs the organizer's sentence on the mark it explains", () {
      final rows = seatLayerSeatNoteRows(
        strings: _strings,
        commercial: const SeatCommercialAttributes(
          restrictedView: true,
          premium: true,
          note: '  Handrail at the aisle end  ',
        ),
      );
      expect(rows.map((row) => row.title),
          <String>['Restricted view', 'Premium seat']);
      expect(rows.first.note, 'Handrail at the aisle end');
      expect(rows.last.note, isNull);
    });

    test('gives it a row of its own when there is no mark to explain', () {
      final rows = seatLayerSeatNoteRows(
        strings: _strings,
        commercial: const SeatCommercialAttributes(note: 'Facing the pillar'),
      );
      expect(rows.single.title, 'Organizer note');
      expect(rows.single.iconKey, 'note');
      expect(rows.single.tone, SeatLayerSeatNoteTone.note);
    });

    test('every row names a drawing this build actually has', () {
      final rows = seatLayerSeatNoteRows(
        strings: _strings,
        accessibility: SeatLayerPickerStrings.defaultAccessNeeds.keys
            .toList(growable: false),
        commercial: const SeatCommercialAttributes(
          restrictedView: true,
          obstructedView: true,
          premium: true,
        ),
      );
      expect(rows, hasLength(15));
      for (final row in rows) {
        expect(seatLayerSeatIconPath(row.iconKey), isNotNull,
            reason: row.iconKey);
      }
    });
  });

  group('the tones read in both themes', () {
    for (final brightness in Brightness.values) {
      test('every title clears 4.5:1 on its own band — ${brightness.name}', () {
        final theme = resolveSeatLayerPickerThemePreset(brightness);
        for (final tone in SeatLayerSeatNoteTone.values) {
          final colors = seatLayerSeatNoteToneColors(theme, tone);
          expect(
            _contrast(colors.ink, colors.ground),
            greaterThanOrEqualTo(4.5),
            reason: '${tone.name} title on its band',
          );
          expect(
            _contrast(colors.bodyInk, colors.ground),
            greaterThanOrEqualTo(4.5),
            reason: '${tone.name} organizer line on its band',
          );
        }
      });

      test(
          'a caution band is not the surface it is mixed from — '
          '${brightness.name}', () {
        final theme = resolveSeatLayerPickerThemePreset(brightness);
        final warn =
            seatLayerSeatNoteToneColors(theme, SeatLayerSeatNoteTone.warn);
        expect(warn.ground, isNot(theme.surface));
        // The raw amber is the thing this replaced: it is not the ink.
        expect(warn.ink, isNot(theme.warning));
      });
    }
  });

  group('the bands on the seat card', () {
    testWidgets('draw one band per attribute, under the category band',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerConfirmCard()),
      );
      map.emit(_seatWith(
        accessibility: <String>['companion'],
        commercial: <String, Object?>{
          'restrictedView': true,
          'premium': true,
          'note': 'Handrail at the aisle end',
        },
      ));
      await pumpToRest(tester);

      expect(find.text('Companion'), findsOneWidget);
      expect(find.text('Restricted view'), findsOneWidget);
      expect(find.text('Premium seat'), findsOneWidget);
      expect(find.text('Handrail at the aisle end'), findsOneWidget);

      // Under the category band, and above everything the card asks for.
      final category = tester.getRect(find.text('Standard'));
      final first = tester.getRect(find.text('Companion'));
      final action = tester.getRect(find.text('Add seat'));
      expect(first.top, greaterThan(category.bottom));
      expect(first.bottom, lessThan(action.top));
    });

    testWidgets('are full-bleed bands, not plates inside the card',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerConfirmCard()),
      );
      map.emit(_seatWith(accessibility: <String>['companion', 'hearing']));
      await pumpToRest(tester);

      final bands = tester.widgetList<SeatLayerSeatNotes>(
        find.byType(SeatLayerSeatNotes),
      );
      expect(bands.single.rows, hasLength(2));
      final block = tester.getRect(find.byType(SeatLayerSeatNotes));
      final card = tester.getRect(find.byKey(
        const ValueKey<String>('seatlayer.confirm-card.surface'),
      ));
      // Edge to edge: a band that stops short of the card's own width is a
      // plate again.
      expect(block.left, closeTo(card.left, 0.5));
      expect(block.right, closeTo(card.right, 0.5));
    });

    testWidgets('wear the shared drawings, never a platform icon',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerConfirmCard()),
      );
      map.emit(_seatWith(commercial: <String, Object?>{'premium': true}));
      await pumpToRest(tester);

      final icon = tester.widget<SeatLayerSeatIcon>(
        find.byType(SeatLayerSeatIcon),
      );
      expect(icon.iconKey, 'premium');
      // The filled Material star this replaced is gone, not merely hidden.
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('a seat with nothing marked draws no block at all',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerConfirmCard()),
      );
      map.emit(_seatWith());
      await pumpToRest(tester);

      expect(find.byType(SeatLayerSeatIcon), findsNothing);
    });

    for (final brightness in Brightness.values) {
      testWidgets('seat card with notes golden — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerConfirmCard()),
            platformBrightness: brightness,
          ),
        );
        map.emit(_seatWith(
          accessibility: <String>['companion'],
          wheelchairSpaceType: 'no-seat',
          commercial: <String, Object?>{
            'restrictedView': true,
            'premium': true,
            'note': 'Handrail at the aisle end',
          },
        ));
        await pumpToRest(tester);

        await expectGolden(tester, 'confirm_card_notes_${brightness.name}');
      }, tags: goldenTag, skip: goldenSkip != null);
    }
  });
}

/// The package's own light or dark palette, resolved without a widget tree.
SeatLayerResolvedPickerTheme resolveSeatLayerPickerThemePreset(
  Brightness brightness,
) {
  final preset = brightness == Brightness.dark
      ? const SeatLayerPickerThemeData.dark()
      : const SeatLayerPickerThemeData.light();
  return SeatLayerResolvedPickerTheme(
    brightness: brightness,
    accent: preset.accent!,
    onAccent: preset.onAccent!,
    background: preset.background!,
    surface: preset.surface!,
    text: preset.text!,
    mutedText: preset.mutedText!,
    divider: preset.divider!,
    error: preset.error!,
    warning: preset.warning!,
    radius: preset.radius!,
    buttonRadius: preset.buttonRadius!,
    layout: const SeatLayerPickerLayout(),
  );
}
