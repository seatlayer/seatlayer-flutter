import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_haptics.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

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
  final map =
      Map<String, Object?>.from(snapshot['map']! as Map<String, Object?>)
        ..['buyerView'] = 'venue3d'
        ..['view3dTargetSeatId'] = targeted ? 'seat-a-1' : null;
  return <String, Object?>{...snapshot, 'map': map};
}

/// The 3D card for a seat the runtime is willing to explain.
Map<String, Object?> _inVenue3DWithConfidence({int revision = 1}) {
  final snapshot = pickerSnapshot(
    revision: revision,
    seatViewConfidence: const <String, Object?>{
      'headline': 'Modelled from a survey',
      'model': 'Photogrammetry',
      'reality': 'Matched to the room',
      'coverage': 'Whole bowl',
      'provenance': 'Venue survey',
      'freshness': 'This season',
      'limitations': <Object?>['Lighting differs'],
    },
  );
  final map =
      Map<String, Object?>.from(snapshot['map']! as Map<String, Object?>)
        ..['buyerView'] = 'venue3d'
        ..['view3dTargetSeatId'] = 'seat-a-1';
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

/// The same event with a different seat under the card.
Map<String, Object?> _secondSeat() {
  final snapshot = pickerSnapshot(revision: 2);
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seats = (selection['seats']! as List<Object?>)
      .map((item) => Map<String, Object?>.from(item! as Map<String, Object?>))
      .toList();
  for (final seat in seats) {
    seat['id'] = 'seat-a-2';
    seat['label'] = 'A-2';
    seat['seatNumber'] = '2';
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

/// The photograph the fake loader answers with.
///
/// Painted once, OUTSIDE a widget test: `toImage` needs the real event loop,
/// and inside `testWidgets` the fake clock never advances to its completion.
late final Uint8List photoBytes;

void main() {
  setUpAll(() async => photoBytes = await tinyPng());

  testWidgets('the identity grid labels the section, the row and the seat',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

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

  testWidgets('the category band carries the name and the price, and no count',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    // NO REMAINING COUNT. It said nothing a buyer choosing one seat could act
    // on and it pushed the price into the card's edge; the legend keeps it.
    expect(find.text('42 left'), findsNothing);
    expect(find.textContaining('left'), findsNothing);
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
    // Name 15, price 18, and the price kept off the card's trailing edge.
    expect(tester.widget<Text>(find.text('Standard')).style!.fontSize, 15);
    expect(tester.widget<Text>(find.text('€25')).style!.fontSize, 18);
    final card = tester.getRect(_surface);
    final money = tester.getRect(find.text('€25'));
    expect(card.right - money.right, greaterThanOrEqualTo(16));
  });

  testWidgets('an uncatalogued category leaves the band out', (tester) async {
    final map = FakePickerMap(bundle: thumbnailBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        assetLoader: pendingAssetLoader(),
      ),
    );
    map.emit(_withoutCategory());
    await pumpToRest(tester);

    expect(find.text('Standard'), findsNothing);
    expect(find.text('42 left'), findsNothing);
    expect(find.text('Gallery'), findsOneWidget);
    // 48 identity + 64 photo strip + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 174);
  });

  testWidgets('Cancel takes 34% of the decision row and Add seat the rest',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    final cancel = tester.getSize(_button('Cancel'));
    final add = tester.getSize(_button('Add seat'));
    // 310 wide, less the body's 10 pt gutters. The hairline is painted on
    // the card's edge rather than taken out of its width.
    const row = 310 - 20;
    expect(cancel.width, closeTo(row * .34, .5));
    // Cancel keeps its third of the WHOLE row; the 44 pt 3D square and its
    // gap come out of what `Add seat` had.
    expect(add.width, closeTo(row - 8 - (row * .34) - 44 - 8, .5));
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
    await pumpToRest(tester);

    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('the identity cells carry the narrow numbers', (tester) async {
    final map = FakePickerMap(bundle: thumbnailBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        assetLoader: pendingAssetLoader(),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    final eyebrow = tester.widget<Text>(find.text('SECTION')).style!;
    expect(eyebrow.fontSize, 9);
    expect(eyebrow.fontWeight, FontWeight.w800);
    expect(eyebrow.letterSpacing, closeTo(9 * .1, .001));
    // `Gallery` is eight characters, so it is the one value that drops to the
    // small wrapping type; the seat number keeps the big centred size.
    final section = tester.widget<Text>(find.text('Gallery'));
    expect(section.style!.fontSize, 12.5);
    expect(section.maxLines, 2);
    final seat = tester.widget<Text>(find.text('1'));
    expect(seat.style!.fontSize, 18);
    expect(seat.maxLines, 1);
    // 48 identity + 48 band + 64 photo strip + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 222);
  });

  testWidgets('the card asks the same question inside the 3D venue',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_inVenue3D());
    await pumpToRest(tester);

    // The identity, the band and the two answers are the card's own, whatever
    // is behind it.
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add seat'), findsOneWidget);
    // The scene is already the picture, so the photo strip and its pills are
    // replaced by the one view the buyer has not had — as a compact chip
    // whose visible word is the short one and whose spoken name is not.
    expect(find.text('3D'), findsNothing);
    expect(find.text('View from here'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('View from here')).semanticsLabel,
      'View from this seat',
    );
    // Nothing is claimed about a seat the snapshot says nothing about: the
    // web card's compare button and confidence teaser have no data behind
    // them in `seatlayer.picker.snapshot/1`.
    expect(find.textContaining('compare'), findsNothing);
    expect(find.textContaining('unverified'), findsNothing);
    // The card is its own width in the scene, and the cells and the values
    // take the immersive numbers.
    expect(tester.getSize(_surface).width, 342);
    expect(tester.widget<Text>(find.text('Gallery')).style!.fontSize, 12);
    expect(tester.widget<Text>(find.text('1')).style!.fontSize, 17);
  }, semanticsEnabled: true);

  testWidgets(
      'the card comes up on the tap in the scene, and stands down in the '
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
    await pumpToRest(tester);
    expect(find.text('Add seat'), findsOneWidget);

    map.emit(_inVenue3D(revision: 3));
    await pumpToRest(tester);
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
    await pumpToRest(tester);
    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('the 3D inspection row opens the seat view', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_inVenue3D());
    await pumpToRest(tester);

    await tester.tap(find.text('View from here'));
    await pumpToRest(tester);

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
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    expect(
      map.callsTo('picker.setSeatTier').single.$2,
      <String, Object?>{'seatId': 'seat-a-1', 'tierId': 'child'},
    );
  });

  testWidgets('the strip carries the photo pill and 3D its own action',
      (tester) async {
    final map = FakePickerMap(bundle: thumbnailBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        assetLoader: pendingAssetLoader(),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

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
    // 48 identity + 48 band + 64 photo strip + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 222);
  }, semanticsEnabled: true);

  testWidgets('a seat without a real photograph is not offered a view from it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    final snapshot = pickerSnapshot();
    final seat = (snapshot['selection']! as Map<String, Object?>)['seats'];
    ((seat! as List<Object?>).first as Map<String, Object?>)['seatViewKind'] =
        'generated';
    map.emit(snapshot);
    await pumpToRest(tester);

    // The stand-in the runtime can draw for any seat is never offered from
    // the card; only the 3D pill stays, on the plain rail.
    expect(find.text('View from here'), findsNothing);
    expect(find.text('3D'), findsOneWidget);
  }, semanticsEnabled: true);

  testWidgets('the photo strip is full-bleed inside the card', (tester) async {
    final map = FakePickerMap(bundle: thumbnailBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerConfirmCard(),
        assetLoader: pendingAssetLoader(),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    final card = tester.getRect(
      find.byKey(const ValueKey<String>('seatlayer.confirm-card.surface')),
    );
    final strip = tester.getRect(
      find
          .ancestor(
            of: find.text('View from here'),
            matching: find.byType(Stack),
          )
          .first,
    );
    // Nothing between it and the card's own edge on either side.
    expect(strip.left - card.left, closeTo(0, .01));
    expect(card.right - strip.right, closeTo(0, .01));
    expect(strip.height, 64);
  });

  testWidgets('3D alone takes the decision row, not a rail of its own',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_only3D());
    await pumpToRest(tester);

    expect(find.text('View from here'), findsNothing);
    expect(find.text('3D'), findsOneWidget);
    // No rail: the square sits in the decision row, in front of Cancel, and
    // the card spends no height on a bar holding one control.
    final square = tester.getRect(
      find.ancestor(of: find.text('3D'), matching: find.byType(SizedBox)).first,
    );
    final cancel = tester.getRect(_button('Cancel'));
    expect(square.center.dy, closeTo(cancel.center.dy, .5));
    expect(square.left, lessThan(cancel.left));
    expect(square.width, 44);
    expect(square.height, 44);
    // 48 identity + 48 band + 8 + 44 decision row + 10 — the same card as one
    // with no 3D at all, because the action costs it no row.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 158);
  });

  testWidgets('an event with neither drops the strip entirely', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_withoutImmersiveFeatures());
    await pumpToRest(tester);

    expect(find.text('View from here'), findsNothing);
    expect(find.text('3D'), findsNothing);
    // 48 identity + 48 band + 8 + 44 decision row + 10.
    expect(tester.getSize(find.byType(SeatLayerConfirmCard)).height, 158);
  });

  testWidgets('the card is the screen less a gutter, capped at 310',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    await tester.tap(find.text('Add seat'));
    await pumpToRest(tester);
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
    await pumpToRest(tester);

    await tester.tap(find.text('Add seat'));
    await tester.pump();
    await tester.pump();

    // The word changes only after the commit the buyer is being told about.
    order.add('said "${(tester.widget(find.descendant(
      of: _button('Added'),
      matching: find.byType(Text),
    )) as Text).data}"');
    expect(order, <String>['committed', 'said "Added"']);

    await pumpToRest(tester);
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
    await pumpToRest(tester);

    await tester.tap(find.text('Cancel'));
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('the band never prints a remaining count', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_almostSoldOut(8));
    await pumpToRest(tester);

    // The band never counts, however few are left. A scarcity line on the
    // one card a buyer reads to confirm one seat is selling, not informing —
    // and the number belongs to the legend, where categories are compared.
    expect(find.text('8 left'), findsNothing);
    expect(find.text('Only 8 left'), findsNothing);
    expect(find.textContaining('left'), findsNothing);
    expect(find.text('Standard'), findsOneWidget);
  });

  testWidgets('a count that has not arrived is not guessed at either', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
    map.emit(_almostSoldOut(0));
    await pumpToRest(tester);

    // Nor when the runtime has not said yet — the band has nowhere to print
    // a count at all now, which is the same answer for every arrival order.
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
    await pumpToRest(tester);

    await tester.drag(_surface, const Offset(0, 120));
    await pumpToRest(tester);

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
    await pumpToRest(tester);
    final resting = tester.getTopLeft(_surface);

    // Short of the threshold: the card follows the finger and then returns.
    await tester.drag(_surface, const Offset(0, 40));
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    // Arriving over the seat is the lightest thing the card does.
    expect(felt, <PickerHapticCue>[PickerHapticCue.cardArrived]);
    expect(pickerHapticStrength(PickerHapticCue.cardArrived), 'light');

    await tester.tap(find.text('Cancel'));
    await pumpToRest(tester);

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
    await pumpToRest(tester);

    await tester.tap(find.text('Add seat'));
    await pumpToRest(tester);

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
    await pumpToRest(tester);
    await tester.tap(find.text('Add seat'));
    await pumpToRest(tester);

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

  group('the invitation', () {
    // The breath is one `Transform.scale` around `Add seat` and one halo
    // painted outside it, both driven off the same number. The scale is the
    // half a test can read, and reading it is enough: a halo at rest and a
    // button at rest are the same frame.

    /// How far `Add seat` has swelled out of its resting size.
    double swell(WidgetTester tester, [String label = 'Add seat']) => tester
        .widget<Transform>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Transform))
              .first,
        )
        .transform
        .getMaxScaleOnAxis();

    /// Put a card on screen and leave it at the instant the breath starts.
    Future<void> card(WidgetTester tester, {bool reduced = false}) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(
          map,
          reduced
              ? _reducedMotion(const SeatLayerConfirmCard())
              : const SeatLayerConfirmCard(),
        ),
      );
      map.emit(pickerSnapshot());
      await pumpToRest(tester);
    }

    testWidgets('breathes for as long as the buyer hesitates', (tester) async {
      await card(tester);
      expect(swell(tester), 1);

      // Ten seconds of nothing — four breaths past where a bounded invitation
      // would have given up.
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // One more breath, sampled: it has to reach the top of it and come back.
      var peak = 1.0;
      var trough = 2.0;
      for (var i = 0; i < 24; i++) {
        peak = math.max(peak, swell(tester));
        trough = math.min(trough, swell(tester));
        await tester.pump(const Duration(milliseconds: 100));
      }
      // 1.02 at the top of the breath and 1 at the bottom, as the web's
      // `slAddBreathe` keyframes have it.
      expect(peak, closeTo(1.02, .001));
      expect(trough, closeTo(1, .002));
    });

    testWidgets('stops on the first touch anywhere on the card, in one frame',
        (tester) async {
      await card(tester);
      // 1200 ms into the breath is the top of it: the largest the button ever
      // gets, and so the frame a stop is most visible on.
      await tester.pump(const Duration(milliseconds: 1200));
      expect(swell(tester), closeTo(1.02, .001));

      final gesture = await tester.startGesture(tester.getCenter(_surface));
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Not eased back down: the card is being touched, and the invitation is
      // over as of this frame.
      expect(swell(tester), 1);
      await gesture.up();
      await tester.pump();
      expect(swell(tester), 1);
    });

    testWidgets('stops when the button takes focus', (tester) async {
      await card(tester);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(swell(tester), closeTo(1.02, .001));

      // A buyer who reached `Add seat` by keyboard has found it as surely as
      // one who put a thumb on it.
      final button = tester.widget<InkWell>(
        find.ancestor(
            of: find.text('Add seat'), matching: find.byType(InkWell)),
      );
      button.onFocusChange!(true);
      await tester.pump();

      expect(swell(tester), 1);
    });

    testWidgets('a card asking about a second seat invites again',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
      map.emit(pickerSnapshot());
      await pumpToRest(tester);

      // Answered by touching it: this card's invitation is over.
      final gesture = await tester.startGesture(tester.getCenter(_surface));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(swell(tester), 1);

      // A different seat is now being asked about, on the same button.
      map.emit(_secondSeat());
      await pumpToRest(tester);
      await tester.pump(const Duration(milliseconds: 1200));

      expect(swell(tester), closeTo(1.02, .001));
    });

    testWidgets('never starts under reduced motion', (tester) async {
      await card(tester, reduced: true);

      for (var i = 0; i < 40; i++) {
        expect(swell(tester), 1);
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a press at the top of a breath still commits on the press',
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
      await pumpToRest(tester);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(swell(tester), closeTo(1.02, .001));

      await tester.tap(find.text('Add seat'));
      await tester.pump();
      await tester.pump();

      // The seat is in the cart on the press, the button is back at its
      // resting size, and it now says so.
      expect(order, <String>['committed']);
      expect(swell(tester, 'Added'), 1);
      expect(find.text('Added'), findsOneWidget);

      // The receipt is played out over the sweep, and only then does the card
      // leave: a frame before the end of it the card is still on screen.
      await tester.pump(const Duration(milliseconds: 300));
      expect(_surface, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();
      expect(_surface, findsNothing);
    });

    testWidgets('a plain tap on Add seat is not stolen by the card swipe',
        (tester) async {
      // The whole card is a vertical-drag target — pushing it down is the
      // third answer — and `Add seat` sits inside that target. A tap with no
      // movement in it has to reach the button rather than open a drag the
      // buyer never made.
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      var confirmed = 0;

      await tester.pumpWidget(
        pickerHarness(
          map,
          SeatLayerConfirmCard(onConfirm: (_) async => confirmed++),
        ),
      );
      map.emit(pickerSnapshot());
      await pumpToRest(tester);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Add seat')));
      await tester.pump(const Duration(milliseconds: 40));
      await gesture.up();
      await tester.pump();

      expect(confirmed, 1);
      expect(find.text('Added'), findsOneWidget);

      // Let the receipt play out rather than leaving its timer behind.
      await pumpToRest(tester);
      expect(_surface, findsNothing);
    });
  });

  group('placement', () {
    const area = Size(390, 600);
    const card = Size(310, 140);

    test('the card rests at the foot of the map, whatever was tapped', () {
      // 600 less the 14 pt rest inset less the card, and nothing about the
      // seat is read: the sheet has one home and the map is framed above it.
      expect(seatLayerConfirmCardTop(card: card, area: area), 446);
    });

    test('the chrome under the card is not somewhere it may rest', () {
      expect(
        seatLayerConfirmCardTop(card: card, area: area, bottomInset: 52),
        600 - 52 - 14 - 140,
      );
    });

    test('a card taller than the band it lives in keeps its top edge', () {
      expect(
        seatLayerConfirmCardTop(
          card: const Size(310, 700),
          area: area,
          topInset: 40,
          bottomInset: 80,
        ),
        // 40 of chrome plus the 12 pt the card keeps clear of the map's top.
        52,
      );
    });

    test('the band reported to the runtime clears the card and its daylight',
        () {
      // The runtime frames inside the insets the host reports, so the sheet
      // has to be one of them: from the foot of the map to 12 pt above the
      // card's top edge.
      expect(
        seatLayerConfirmSheetBand(cardTop: 446, area: area),
        600 - 446 + 12,
      );
    });

    test('a host with no band left to frame into is left alone', () {
      // A compact embed whose card fills it has nowhere to put the seat, and
      // an inset taller than the viewport would ask the runtime to frame into
      // nothing. Same guard the web widget keeps on the same number.
      expect(
        seatLayerConfirmSheetBand(cardTop: 52, area: area, topInset: 560),
        0,
      );
    });
  });

  group('seat-view thumbnail', () {
    testWidgets('a runtime that does not advertise it changes nothing',
        (tester) async {
      // Every field present, and no capability: the card is the card it was
      // before this existed.
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      final asked = <Uri>[];
      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerConfirmCard(),
          assetLoader: photoAssetLoader(
            photoBytes,
            requested: asked,
          ),
        ),
      );
      map.emit(pickerSnapshot(sightlineMetres: 7));
      await pumpToRest(tester);

      expect(find.text('View from here'), findsNothing);
      expect(find.textContaining('to stage'), findsNothing);
      expect(asked, isEmpty);
      // The 3D pill is still offered, on the plain rail.
      expect(find.text('3D'), findsOneWidget);
    });

    testWidgets('the photograph is fetched once and drawn', (tester) async {
      final map = FakePickerMap(bundle: thumbnailBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      final asked = <Uri>[];
      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerConfirmCard(),
          assetLoader: photoAssetLoader(photoBytes, requested: asked),
        ),
      );
      map.emit(pickerSnapshot());
      await pumpToRest(tester);

      expect(asked, hasLength(1));
      expect(
        asked.single.path,
        '/pub/events/ev_test/assets/seat-a-1.jpg',
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('View from here'), findsOneWidget);
    });

    testWidgets('a photograph that never arrives takes the strip with it',
        (tester) async {
      final map = FakePickerMap(bundle: thumbnailBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerConfirmCard(),
          assetLoader: missingAssetLoader(),
        ),
      );
      map.emit(pickerSnapshot());
      await pumpToRest(tester);

      expect(find.byType(Image), findsNothing);
      expect(find.text('View from here'), findsNothing);
      // The strip collapses and the 3D action lands in the decision row, one
      // row further down, without the card jumping under a reaching thumb.
      expect(find.text('3D'), findsOneWidget);
      final square = tester.getRect(
        find
            .ancestor(of: find.text('3D'), matching: find.byType(SizedBox))
            .first,
      );
      expect(square.center.dy,
          closeTo(tester.getRect(_button('Cancel')).center.dy, .5));
    });

    testWidgets('the sight line rides the photograph as a pill',
        (tester) async {
      final map = FakePickerMap(bundle: thumbnailBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerConfirmCard(),
          assetLoader: pendingAssetLoader(),
        ),
      );
      map.emit(pickerSnapshot(sightlineMetres: 7));
      await pumpToRest(tester);

      expect(find.text('≈ 7 m to stage'), findsOneWidget);
      final caption = tester.widget<Text>(find.text('≈ 7 m to stage'));
      expect(caption.style!.fontSize, 10);
      expect(caption.style!.color, const Color(0xFFFFFFFF));
      // Top-right of the strip, above the pills.
      final pill = tester.getRect(find.text('≈ 7 m to stage'));
      final view = tester.getRect(find.text('View from here'));
      expect(pill.top, lessThan(view.top));
      expect(pill.left, greaterThan(view.left));
    });

    testWidgets('with no photograph the sight line has no strip to ride',
        (tester) async {
      final map = FakePickerMap(bundle: thumbnailBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerConfirmCard()),
      );
      map.emit(
        pickerSnapshot(seatViewThumb: null, sightlineMetres: 7.4),
      );
      await pumpToRest(tester);

      // The figure rides the photograph, and with no photograph the whole
      // strip leaves the phone card rather than becoming a bar of its own.
      expect(find.text('≈ 7.4 m to stage'), findsNothing);
      expect(find.text('View from here'), findsNothing);
      // The way into 3D is still one tap away, in the decision row.
      expect(find.text('3D'), findsOneWidget);
    });

    testWidgets('the confidence teaser is 3D only, and static without a host',
        (tester) async {
      final map = FakePickerMap(bundle: thumbnailBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerConfirmCard()),
      );
      // On the map there is no model on screen to be honest about.
      map.emit(
        pickerSnapshot(
          seatViewConfidence: const <String, Object?>{
            'headline': 'Modelled from a survey',
            'reality': 'Matched to the room',
          },
        ),
      );
      await pumpToRest(tester);
      expect(find.text('Passport'), findsNothing);

      map.emit(_inVenue3DWithConfidence(revision: 2));
      await pumpToRest(tester);
      // With nowhere to open, the disclosure stays the teaser it has always
      // been: the headline and the detail ARE the information, and a chip
      // saying only `Passport` would say nothing and do nothing.
      expect(find.text('Passport'), findsOneWidget);
      expect(find.text('Modelled from a survey'), findsOneWidget);
      expect(find.text('Matched to the room'), findsOneWidget);
      // Nothing behind it, so it is not a button.
      expect(
        find.ancestor(
          of: find.text('Passport'),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });

    testWidgets('a host that can open the passport gets a button',
        (tester) async {
      final map = FakePickerMap(bundle: thumbnailBundle());
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      SelectedSeat? seat;
      SeatConfidenceDisclosure? disclosure;
      await tester.pumpWidget(
        pickerHarness(
          map,
          const SeatLayerConfirmCard(),
          callbacks: SeatLayerPickerCallbacks(
            onSeatConfidence: (value, shown) {
              seat = value;
              disclosure = shown;
            },
          ),
        ),
      );
      map.emit(_inVenue3DWithConfidence());
      await pumpToRest(tester);

      // A host that can open it gets the chip, on one row with the view from
      // the seat rather than a full-width bar of its own above it.
      expect(find.text('Modelled from a survey'), findsNothing);
      final passport = tester.getRect(find.text('Passport'));
      final view = tester.getRect(find.text('View from here'));
      expect(passport.center.dy, closeTo(view.center.dy, 2));
      expect(passport.left, lessThan(view.left));

      await tester.tap(find.text('Passport'));
      await pumpToRest(tester);
      expect(seat!.label, 'A-1');
      expect(disclosure!.headline, 'Modelled from a survey');
    });
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('confirm card golden with strip — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap(bundle: thumbnailBundle());
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerConfirmCard()),
            platformBrightness: brightness,
            assetLoader: pendingAssetLoader(),
          ),
        );
        map.emit(pickerSnapshot());
        await pumpToRest(tester);

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
        await pumpToRest(tester);

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
        await pumpToRest(tester);

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
        await pumpToRest(tester);

        await expectGolden(tester, 'confirm_card_plain_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('confirm card golden with a photograph — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap(bundle: thumbnailBundle());
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(const SeatLayerConfirmCard()),
            platformBrightness: brightness,
            // Painted in the test rather than checked in: a repository is not
            // a photograph archive.
            assetLoader: photoAssetLoader(photoBytes),
          ),
        );
        map.emit(pickerSnapshot(sightlineMetres: 7));
        await pumpToRest(tester);
        // Decoding is real work on a real event loop. Without this the first
        // golden of a run captures the gradient and the second captures the
        // photograph, because the second one hits the image cache.
        await tester.runAsync(
          () => precacheImage(
            MemoryImage(photoBytes),
            tester.element(find.byType(SeatLayerConfirmCard)),
          ),
        );
        await tester.pump();

        await expectGolden(tester, 'confirm_card_photo_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
