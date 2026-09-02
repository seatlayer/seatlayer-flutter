import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_haptics.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// A category with almost nothing left in it.
Map<String, Object?> _almostSoldOut(int available) {
  final snapshot = pickerSnapshot();
  final catalog = Map<String, Object?>.from(
    snapshot['catalog']! as Map<String, Object?>,
  );
  final categories = (catalog['categories']! as List<Object?>)
      .map((item) => Map<String, Object?>.from(item! as Map<String, Object?>))
      .toList();
  categories.first['available'] = available;
  catalog['categories'] = categories;
  return <String, Object?>{...snapshot, 'catalog': catalog};
}

/// The card's own surface, which is what a swipe grabs.
Finder get _surface =>
    find.byKey(const ValueKey<String>('seatlayer.confirm-card.surface'));

Map<String, Object?> _withoutImmersiveFeatures() {
  final snapshot = pickerSnapshot();
  return <String, Object?>{
    ...snapshot,
    'features': <String, Object?>{'bestAvailable': true},
  };
}

/// An event with the 3D venue but no seat photograph.
Map<String, Object?> _only3D() {
  final snapshot = pickerSnapshot();
  return <String, Object?>{
    ...snapshot,
    'features': <String, Object?>{'bestAvailable': true, 'venue3d': true},
  };
}

/// A snapshot whose catalogue never mentions the selected seat's category.
Map<String, Object?> _withoutCategory() {
  final snapshot = pickerSnapshot();
  final catalog = Map<String, Object?>.from(
    snapshot['catalog']! as Map<String, Object?>,
  )..['categories'] = <Object?>[];
  return <String, Object?>{...snapshot, 'catalog': catalog};
}

/// The card with animations turned off for this subtree only.
Widget _reducedMotion(Widget child) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child,
      ),
    );

/// The [Material] one labelled action is painted on.
Finder _button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(Material)).first;

void main() {
  testWidgets('the identity grid labels the section, the row and the seat',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('SECTION'), findsOneWidget);
    expect(find.text('ROW'), findsOneWidget);
    expect(find.text('SEAT'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // The sentence is what a screen reader hears, not what the card draws.
    expect(find.text('Gallery · Row A · Seat 1'), findsNothing);
    expect(find.bySemanticsLabel('Gallery · Row A · Seat 1'), findsOneWidget);
  }, semanticsEnabled: true);

  testWidgets('the category band carries the name, what is left, and the price',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('42 left'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    // The money lives above the actions, never on them: the cart is about to
    // say the same number, and one screen says a total once.
    expect(
      tester.getCenter(find.text('€25')).dy,
      lessThan(tester.getCenter(find.text('Add seat')).dy),
    );
    expect(
      find.descendant(of: _button('Add seat'), matching: find.text('€25')),
      findsNothing,
    );
  });

  testWidgets('an uncatalogued category leaves the band out', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_withoutCategory());
    await tester.pumpAndSettle();

    expect(find.text('Standard'), findsNothing);
    expect(find.text('42 left'), findsNothing);
    expect(find.text('Gallery'), findsOneWidget);
    // 56 identity + 10 + 64 photo + 10 + 44 3D + 10 + 44 decision row.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 238);
  });

  testWidgets('Add seat takes two thirds of the row and Cancel one',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final cancel = tester.getSize(_button('Cancel'));
    final add = tester.getSize(_button('Add seat'));
    expect(add.width, closeTo(cancel.width * 2, 1));
    // Every control on the card clears the phone's touch floor.
    expect(cancel.height, 44);
    expect(add.height, 44);
    expect(tester.getSize(_button('See it in 3D')).height, 44);
  });

  testWidgets('the phone card selects a tier and updates its headline price',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(tieredSeatSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Adult'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
    expect(find.text('For children aged 12 and under.'), findsOneWidget);
    expect(find.text('€100'), findsNWidgets(2));
    expect(find.text('€60'), findsOneWidget);

    await tester.tap(find.text('Child'));
    await tester.pump();

    expect(find.text('€100'), findsOneWidget);
    expect(find.text('€60'), findsNWidgets(2));

    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.setSeatTier').single.$2,
      <String, Object?>{'seatId': 'seat-a-1', 'tierId': 'child'},
    );
  });

  testWidgets('the strip carries the photo pill and 3D its own action',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('View from here'), findsOneWidget);
    expect(find.text('See it in 3D'), findsOneWidget);
    // 56 identity + 34 band + 10 + 64 photo + 10 + 44 3D + 10 + 44 decision.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 272);
  });

  testWidgets('3D alone gets a plain action row, not an empty picture',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_only3D());
    await tester.pumpAndSettle();

    expect(find.text('View from here'), findsNothing);
    expect(find.text('See it in 3D'), findsOneWidget);
    // The gradient stands in for a photograph nothing is going to open.
    expect(
      tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text('See it in 3D'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .where(
            (box) => (box.decoration as BoxDecoration).gradient != null,
          ),
      isEmpty,
    );
    // 56 identity + 34 band + 10 + 44 3D + 10 + 44 decision row.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 198);
  });

  testWidgets('an event with neither drops the strip entirely', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_withoutImmersiveFeatures());
    await tester.pumpAndSettle();

    expect(find.text('View from here'), findsNothing);
    expect(find.text('See it in 3D'), findsNothing);
    // 56 identity + 34 band + 5 + 44 decision row.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 139);
  });

  testWidgets('the card is the screen less a gutter, capped at 360',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey<String>('seatlayer.confirm-card.surface'),
            ),
          )
          .width,
      358,
    );
  });

  testWidgets('Cancel removes the seat and Add seat tells the host',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    var selected = 0;

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerConfirmCard(onConfirm: (_) async => selected++),
        callbacks: SeatLayerPickerCallbacks(onSeatSelected: (_) => selected++),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();
    expect(selected, 2);
  });

  testWidgets('the ticket is counted before the button says so',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final order = <String>[];

    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerConfirmCard(onConfirm: (_) async => order.add('committed')),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add seat'));
    await tester.pump();
    await tester.pump();

    // The word changes only after the commit the buyer is being told about.
    order.add('said "${(tester.widget(find.descendant(
      of: _button('Added'),
      matching: find.byType(Text),
    )) as Text).data}"');
    expect(order, <String>['committed', 'said "Added"']);

    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('seatlayer.confirm-card.surface')),
      findsNothing,
    );
  });

  testWidgets('reduced motion commits with no animation to wait through',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _reducedMotion(const SeatLayerConfirmCard())),
    );
    map.emit(pickerSnapshot());
    await tester.pump();

    await tester.tap(find.text('Add seat'));
    await tester.pump();
    await tester.pump();

    // No sweep, no flying dot, no "Added" the buyer has to sit through: the
    // card is simply gone, and nothing is left ticking.
    expect(find.text('Added'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('seatlayer.confirm-card.surface')),
      findsNothing,
    );
  });

  testWidgets('Cancel gives the seat back', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.removeCartLine').single.$2,
      <String, Object?>{'label': 'A-1'},
    );
  });

  testWidgets('read-only sessions never offer a decision', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('a nearly sold-out category says so, in the warning ink', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_almostSoldOut(8));
    await tester.pumpAndSettle();

    expect(find.text('Only 8 left'), findsOneWidget);
    expect(find.text('8 left'), findsNothing);
    final ink = tester.widget<Text>(find.text('Only 8 left')).style!.color;
    expect(ink, const SeatLayerPickerThemeData.light().warning);
  });

  testWidgets('a category with room left states the count plainly', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    // One more than the threshold: scarcity has to be a line, not a slope.
    map.emit(_almostSoldOut(13));
    await tester.pumpAndSettle();

    expect(find.text('13 left'), findsOneWidget);
    expect(find.text('Only 13 left'), findsNothing);
  });

  testWidgets('pushing the card down gives the seat back, once', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.drag(_surface, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.removeCartLine').map((call) => call.$2),
      <Object?>[
        <String, Object?>{'label': 'A-1'},
      ],
    );
    expect(_surface, findsNothing);
  });

  testWidgets('a push the card springs back from keeps the seat', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    final resting = tester.getTopLeft(_surface);

    // Short of the threshold: the card follows the finger and then returns.
    await tester.drag(_surface, const Offset(0, 40));
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.removeCartLine'), isEmpty);
    expect(_surface, findsOneWidget);
    expect(tester.getTopLeft(_surface), resting);
  });

  testWidgets('each answer is felt at its own weight', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    final felt = <PickerHapticCue>[];
    picker.playHaptic = felt.add;
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerConfirmCard(), controller: picker),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    // Arriving over the seat is the lightest thing the card does.
    expect(felt, <PickerHapticCue>[PickerHapticCue.cardArrived]);
    expect(pickerHapticStrength(PickerHapticCue.cardArrived), 'light');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(felt.last, PickerHapticCue.cardCancelled);
    expect(pickerHapticStrength(PickerHapticCue.cardCancelled), 'selection');
  });

  testWidgets('Add seat is the firmest cue in the picking loop', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    final felt = <PickerHapticCue>[];
    picker.playHaptic = felt.add;
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerConfirmCard(), controller: picker),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    expect(felt.last, PickerHapticCue.seatConfirmed);
    expect(pickerHapticStrength(PickerHapticCue.seatConfirmed), 'medium');
  });

  testWidgets('a host that turned haptics off feels none of it', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    final felt = <PickerHapticCue>[];
    picker.playHaptic = felt.add;
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        controller: picker,
        options: const SeatLayerPickerOptions(haptics: false),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    expect(felt, isEmpty);
  });

  testWidgets('reduced motion leaves nothing ticking behind the card', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _reducedMotion(const SeatLayerConfirmCard())),
    );
    map.emit(pickerSnapshot());
    await tester.pump();
    await tester.pump();

    expect(_surface, findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  group('placement', () {
    const area = Size(390, 600);
    const card = Size(358, 140);

    test('a seat with room above it gets the card above it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(195, 400),
        card: card,
        area: area,
      );
      expect(placement.top, 400 - 12 - 140);
      expect(placement.notch, SeatLayerConfirmCardNotch.bottom);
    });

    test('a seat too high for the card gets it below, pointing up', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(195, 100),
        card: card,
        area: area,
        topInset: 40,
      );
      expect(placement.top, 100 + 12);
      expect(placement.notch, SeatLayerConfirmCardNotch.top);
    });

    test('a runtime that does not say rests the card at the foot of the map',
        () {
      final placement = seatLayerConfirmCardPlacement(
        seat: null,
        card: card,
        area: area,
        bottomInset: 52,
      );
      expect(placement.top, 600 - 52 - 140);
      expect(placement.notch, SeatLayerConfirmCardNotch.none);
    });

    test('a resting card is still kept off the chrome under it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: null,
        card: const Size(358, 400),
        area: area,
        bottomInset: 140,
      );
      expect(placement.top, 600 - 140 - 400);
      expect(placement.notch, SeatLayerConfirmCardNotch.none);
    });

    test('the card never slides behind the chrome below it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(195, 590),
        card: card,
        area: area,
        bottomInset: 120,
      );
      expect(placement.top, 600 - 120 - 140);
      expect(placement.notch, SeatLayerConfirmCardNotch.bottom);
    });

    test('the card never slides under the chrome above it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(195, 20),
        card: card,
        area: area,
        topInset: 60,
      );
      expect(placement.top, 60);
      expect(placement.notch, SeatLayerConfirmCardNotch.top);
    });

    test('a card taller than the band it lives in keeps its top edge', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(195, 300),
        card: const Size(358, 700),
        area: area,
        topInset: 40,
        bottomInset: 80,
      );
      expect(placement.top, 40);
      expect(placement.notch, SeatLayerConfirmCardNotch.top);
    });
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('confirm card golden with strip — ${brightness.name}',
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
        map.emit(pickerSnapshot());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'confirm_card_strip_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('confirm card golden with 3D only — ${brightness.name}',
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
        map.emit(_only3D());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'confirm_card_action_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('confirm card golden without strip — ${brightness.name}',
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
        map.emit(_withoutImmersiveFeatures());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'confirm_card_plain_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
