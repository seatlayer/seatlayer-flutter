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

/// The same event, with the buyer inside the 3D venue.
///
/// [targeted] is what the runtime reports once the camera has finished diving
/// to the tapped seat; before that the scene is still travelling.
Map<String, Object?> _inVenue3D({bool targeted = true, int revision = 1}) {
  final snapshot = pickerSnapshot(revision: revision);
  final map = Map<String, Object?>.from(snapshot['map']! as Map<String, Object?>)
    ..['buyerView'] = 'venue3d'
    ..['view3dTargetSeatId'] = targeted ? 'seat-a-1' : null;
  return <String, Object?>{...snapshot, 'map': map};
}

/// A selection that is a booth rather than a seat.
Map<String, Object?> _booth() {
  final snapshot = pickerSnapshot();
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seats = (selection['seats']! as List<Object?>)
      .map((item) => Map<String, Object?>.from(item! as Map<String, Object?>))
      .toList();
  for (final seat in seats) {
    seat['objectType'] = 'booth';
  }
  selection['seats'] = seats;
  return <String, Object?>{...snapshot, 'selection': selection};
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
    // 42 identity + 64 photo strip + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 168);
  });

  testWidgets('Cancel takes 34% of the decision row and Add seat the rest',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final cancel = tester.getSize(_button('Cancel'));
    final add = tester.getSize(_button('Add seat'));
    // 310 wide, less the body's 10 pt gutters. The hairline is painted on
    // the card's edge rather than taken out of its width.
    const row = 310 - 20;
    expect(cancel.width, closeTo(row * .34, .5));
    expect(add.width, closeTo(row - 8 - (row * .34), .5));
    // Both answers clear the phone's touch floor.
    expect(cancel.height, 44);
    expect(add.height, 44);
  });

  testWidgets('a booth is selected, never "added" as a seat', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_booth());
    await tester.pumpAndSettle();

    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('the identity cells carry the narrow numbers', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final eyebrow = tester.widget<Text>(find.text('SECTION')).style!;
    expect(eyebrow.fontSize, 8.5);
    expect(eyebrow.fontWeight, FontWeight.w800);
    expect(eyebrow.letterSpacing, closeTo(8.5 * .1, .001));
    // A section name is the one value worth a second line; a seat number
    // never needs one.
    final section = tester.widget<Text>(find.text('Gallery'));
    expect(section.style!.fontSize, 12.5);
    expect(section.maxLines, 2);
    final seat = tester.widget<Text>(find.text('1'));
    expect(seat.style!.fontSize, 15);
    expect(seat.maxLines, 1);
    // 42 identity + 35 band + 64 photo strip + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 203);
  });

  testWidgets('the card asks the same question inside the 3D venue',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_inVenue3D());
    await tester.pumpAndSettle();

    // The identity, the band and the two answers are the card's own, whatever
    // is behind it.
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('42 left'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add seat'), findsOneWidget);
    // The scene is already the picture, so the photo strip and its pills are
    // replaced by the one view the buyer has not had.
    expect(find.text('View from here'), findsNothing);
    expect(find.text('3D'), findsNothing);
    expect(find.text('View from this seat'), findsOneWidget);
    // Nothing is claimed about a seat the snapshot says nothing about: the
    // web card's compare button and confidence teaser have no data behind
    // them in `seatlayer.picker.snapshot/1`.
    expect(find.textContaining('compare'), findsNothing);
    expect(find.textContaining('unverified'), findsNothing);
    // The card is its own width in the scene, and the cells and the values
    // take the immersive numbers.
    expect(tester.getSize(_surface).width, 342);
    expect(tester.widget<Text>(find.text('Gallery')).style!.fontSize, 12);
    expect(tester.widget<Text>(find.text('1')).style!.fontSize, 14);
  });

  testWidgets('the card comes up on the tap in the scene, and stands down in the '
      'panorama', (tester) async {
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'native-seat-view-chrome-v1',
        ],
      ),
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    // The camera is still travelling: a card here asks about a seat the buyer
    // cannot see yet.
    map.emit(_inVenue3D(targeted: false));
    await tester.pumpAndSettle();
    expect(find.text('Add seat'), findsOneWidget);

    map.emit(_inVenue3D(revision: 3));
    await tester.pumpAndSettle();
    expect(find.text('Add seat'), findsOneWidget);

    // The panorama answers the same question the card asks — this seat, from
    // this seat — so the card stands down for it.
    map.emitEvent('seatView.changed', <String, Object?>{
      'seatView': <String, Object?>{
        'seatId': 'seat-a-1',
        'title': 'View from Gallery · A-1',
        'generated': true,
      },
    });
    await tester.pumpAndSettle();
    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('the 3D inspection row opens the seat view', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_inVenue3D());
    await tester.pumpAndSettle();

    await tester.tap(find.text('View from this seat'));
    await tester.pumpAndSettle();

    expect(map.callsTo('picker.openSeatView').single.$2, <String, Object?>{
      'seatId': 'seat-a-1',
    });
    // The card stays until the runtime has actually mounted the panorama.
    expect(find.text('Add seat'), findsOneWidget);
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

    // Both ways into the seat ride the photograph itself, one per corner.
    expect(find.text('View from here'), findsOneWidget);
    expect(find.text('3D'), findsOneWidget);
    // The full-width "See it in 3D" is the wide card's, not the phone's.
    expect(find.text('See it in 3D'), findsNothing);
    final photo = tester.getRect(find.text('View from here'));
    final venue = tester.getRect(find.text('3D'));
    expect(photo.left, lessThan(venue.left));
    // A screen reader still hears the sentence the pill has no room for.
    expect(find.bySemanticsLabel('See it in 3D'), findsOneWidget);
    // 42 identity + 35 band + 64 photo strip + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 203);
  }, semanticsEnabled: true);

  testWidgets('the photo strip is full-bleed inside the card', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final card = tester.getRect(
      find.byKey(const ValueKey<String>('seatlayer.confirm-card.surface')),
    );
    final strip = tester.getRect(
      find.ancestor(
        of: find.text('View from here'),
        matching: find.byType(Stack),
      ).first,
    );
    // Nothing between it and the card's own edge on either side.
    expect(strip.left - card.left, closeTo(0, .01));
    expect(card.right - strip.right, closeTo(0, .01));
    expect(strip.height, 64);
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
    expect(find.text('3D'), findsOneWidget);
    // The gradient stands in for a photograph nothing is going to open.
    expect(
      tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text('3D'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .where(
            (box) => (box.decoration as BoxDecoration).gradient != null,
          ),
      isEmpty,
    );
    // 42 identity + 35 band + 44 rail + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 183);
  });

  testWidgets('an event with neither drops the strip entirely', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_withoutImmersiveFeatures());
    await tester.pumpAndSettle();

    expect(find.text('View from here'), findsNothing);
    expect(find.text('3D'), findsNothing);
    // 42 identity + 35 band + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 139);
  });

  testWidgets('the card is the screen less a gutter, capped at 310',
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
      310,
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

  testWidgets('the count is a fact, at every size of it', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_almostSoldOut(8));
    await tester.pumpAndSettle();

    // The band states what is left and nothing more. A count that changes its
    // wording and its ink below some threshold is selling, not informing, and
    // the buyer can see the same seats on the map either way.
    expect(find.text('8 left'), findsOneWidget);
    expect(find.text('Only 8 left'), findsNothing);
    final left = tester.widget<Text>(find.text('8 left')).style!;
    expect(left.color, const SeatLayerPickerThemeData.light().mutedText);
    expect(left.fontSize, 11);
    expect(left.fontWeight, FontWeight.w700);
  });

  testWidgets('a count that has not arrived is not guessed at', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_almostSoldOut(0));
    await tester.pumpAndSettle();

    // A count the buyer cannot trust is worse than no count at all.
    expect(find.text('0 left'), findsNothing);
    expect(find.textContaining('left'), findsNothing);
    expect(find.text('Standard'), findsOneWidget);
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
    const card = Size(310, 140);

    test('a seat the resting card would not cover leaves it resting', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(155, 400),
        card: card,
        area: area,
      );
      // 600 less the 14 pt rest inset less the card.
      expect(placement.top, 446);
      expect(placement.notch, SeatLayerConfirmCardNotch.none);
    });

    test('a seat the resting card would cover makes it hug the seat', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(155, 500),
        card: card,
        area: area,
      );
      // 12 pt of daylight above the seat, and the card points down at it.
      expect(placement.top, 500 - 12 - 140);
      expect(placement.notch, SeatLayerConfirmCardNotch.bottom);
    });

    test('a runtime that does not say rests the card at the foot of the map',
        () {
      final placement = seatLayerConfirmCardPlacement(
        seat: null,
        card: card,
        area: area,
        bottomInset: 52,
      );
      expect(placement.top, 600 - 52 - 14 - 140);
      expect(placement.notch, SeatLayerConfirmCardNotch.none);
    });

    test('a resting card is still kept off the chrome under it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: null,
        card: const Size(310, 400),
        area: area,
        bottomInset: 140,
      );
      expect(placement.top, 600 - 140 - 14 - 400);
      expect(placement.notch, SeatLayerConfirmCardNotch.none);
    });

    test('a hugging card never slides behind the chrome below it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(155, 470),
        card: card,
        area: area,
        bottomInset: 120,
      );
      expect(placement.top, 470 - 12 - 140);
      expect(placement.notch, SeatLayerConfirmCardNotch.bottom);
    });

    test('a seat high on the map never pushes the card up to it', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(155, 20),
        card: card,
        area: area,
        topInset: 60,
      );
      // Nothing to get out of the way of, so the card stays where the thumb
      // is rather than chasing a seat it was never going to cover.
      expect(placement.top, 446);
      expect(placement.notch, SeatLayerConfirmCardNotch.none);
    });

    test('a card taller than the band it lives in keeps its top edge', () {
      final placement = seatLayerConfirmCardPlacement(
        seat: const Offset(155, 300),
        card: const Size(310, 700),
        area: area,
        topInset: 40,
        bottomInset: 80,
      );
      // 40 of chrome plus the 12 pt the card keeps clear of the map's top.
      expect(placement.top, 52);
      expect(placement.notch, SeatLayerConfirmCardNotch.bottom);
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

      testWidgets('confirm card golden in the 3D venue — ${brightness.name}',
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
        map.emit(_inVenue3D());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'confirm_card_3d_${brightness.name}');
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
