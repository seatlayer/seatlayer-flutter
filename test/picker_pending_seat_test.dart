// A seat under an open confirm card is not yet in the buyer's cart.
//
// The runtime has no notion of an unconfirmed selection. `cart.items` in
// `seatlayer.picker.snapshot/1` is built straight from `selection.seats`, so a
// tapped seat is in the cart, the ticket count and the total from the moment
// it is tapped — while the native confirm card is still asking whether the
// buyer wants it. On a real device that read as `1 ticket · €40` on the peek bar
// under the card, with a live Continue behind the scrim.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// The same snapshot, with the runtime reporting where it drew the seat.
///
/// `screenPoint` arrives with `seat-screen-point-v1`; every runtime before it
/// omits the field, which is what [pickerSnapshot] itself still models.
Map<String, Object?> _seatDrawnAt(double x, double y) {
  final snapshot = pickerSnapshot(sections: pickerSections());
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seats = (selection['seats']! as List<Object?>)
      .map((seat) => Map<String, Object?>.from(seat! as Map<String, Object?>))
      .toList();
  seats.first['screenPoint'] = <String, Object?>{'x': x, 'y': y};
  selection['seats'] = seats;
  return <String, Object?>{...snapshot, 'selection': selection};
}

/// The same event with the buyer inside the 3D venue.
///
/// [targeted] is what the runtime reports once the camera has arrived at the
/// tapped seat; before that the scene is still diving towards it.
Map<String, Object?> _inVenue3D({bool targeted = true, int revision = 1}) {
  final snapshot = pickerSnapshot(sections: pickerSections(), revision: revision);
  final map = Map<String, Object?>.from(snapshot['map']! as Map<String, Object?>)
    ..['buyerView'] = 'venue3d'
    ..['view3dTargetSeatId'] = targeted ? 'seat-a-1' : null;
  return <String, Object?>{...snapshot, 'map': map};
}

/// A runtime that draws the scene and reports what the chrome covers.
BundleInfo _venue3DBundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'venue-3d-controls-v1',
        'seat-view-v1',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setBuyerView',
        'picker.openSeatView',
      ],
    );

/// Where the map surface starts, in the test surface's own coordinates.
Offset _mapOrigin(WidgetTester tester) => tester.getTopLeft(
      find.byKey(const ValueKey<String>('seatlayer-picker-prompt-transition')),
    );

/// The wrapper that pauses the cart sheet while a seat card is up.
final Finder _sheetPause =
    find.byKey(const ValueKey<String>('seatlayer-picker-sheet-pause'));

AnimatedOpacity _pausedSheet(WidgetTester tester) => tester.widget<AnimatedOpacity>(
      find.descendant(of: _sheetPause, matching: find.byType(AnimatedOpacity)).first,
    );

/// The peek bar's Continue button, or null when it is not offered at all.
///
/// The pill draws its label and its money as two spans — `Continue` beside a
/// tabular `€25` — so it is found by its own word and then read for the total
/// standing next to it.
FilledButton? _continueButton(WidgetTester tester) {
  final found = find.ancestor(
    of: find.text('Continue'),
    matching: find.byType(FilledButton),
  );
  if (found.evaluate().isEmpty) return null;
  expect(
    find.descendant(of: found.first, matching: find.text('€25')),
    findsOneWidget,
    reason: 'the pill carries the cart total beside its label',
  );
  return tester.widget<FilledButton>(found.first);
}

void main() {
  testWidgets('the peek does not count a seat whose card is still open',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: picker),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    // The card is up, over the seat the buyer just tapped.
    expect(find.byType(SeatLayerConfirmCard), findsOneWidget);
    expect(picker.seatAwaitingConfirmation?.label, 'A-1');

    expect(find.text('1 ticket'), findsNothing);
    expect(picker.confirmedTicketCount, 0);
    expect(picker.confirmedCartTotal, 0);
    expect(picker.confirmedCartLines, isEmpty);
  });

  testWidgets('Continue cannot be pressed from behind the card',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: picker),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(picker.canCheckout, isFalse);
    // Either withheld entirely, or offered and disabled — never live.
    expect(_continueButton(tester)?.onPressed, isNull);
  });

  testWidgets('answering the card puts the seat in the cart', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: picker),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    expect(picker.seatAwaitingConfirmation, isNull);
    expect(picker.confirmedTicketCount, 1);
    expect(picker.confirmedCartTotal, 25);
    expect(find.text('1 ticket'), findsOneWidget);
    expect(picker.canCheckout, isTrue);
    expect(_continueButton(tester)?.onPressed, isNotNull);
  });

  testWidgets('a second seat under a card leaves the first one counted',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, _layout(), controller: picker),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    // The buyer taps a second seat: one agreed to, one still being asked.
    map.emit(snapshotWithTicketCount(2, revision: 5));
    await tester.pumpAndSettle();

    expect(picker.seatAwaitingConfirmation?.label, 'A-2');
    expect(picker.confirmedTicketCount, 1);
    expect(picker.confirmedCartTotal, 25);
    expect(
      picker.confirmedCartLines.single.label,
      'A-1',
      reason: 'the pending line is matched off, not the whole cart',
    );
  });

  testWidgets('tapping the map around the card gives the seat back', (
    tester,
  ) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    // Beside the card, inside its gutter: still the venue, still a way out.
    await tester.tapAt(Offset(6, _mapOrigin(tester).dy + 200));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.removeCartLine').map((call) => call.$2),
      <Object?>[
        <String, Object?>{'label': 'A-1'},
      ],
    );
    expect(find.byType(SeatLayerConfirmCard), findsNothing);
  });

  testWidgets('a seat low on the map gets the card above it, pointing down', (
    tester,
  ) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(_seatDrawnAt(195, 520));
    await tester.pumpAndSettle();

    final pointer = find.byType(SeatLayerConfirmCardPointer);
    expect(pointer, findsOneWidget);
    expect(tester.widget<SeatLayerConfirmCardPointer>(pointer).up, isFalse);
    // The card clears the seat rather than covering it.
    final card = find.byKey(
      const ValueKey<String>('seatlayer.confirm-card.surface'),
    );
    expect(
      tester.getBottomLeft(card).dy - _mapOrigin(tester).dy,
      lessThanOrEqualTo(520 - 12),
    );
  });

  testWidgets('a seat high on the map leaves the card resting', (
    tester,
  ) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(_seatDrawnAt(195, 40));
    await tester.pumpAndSettle();

    // The card only leaves its resting place to get off a seat it would have
    // covered. A seat this high was never in its way, so it stays where the
    // thumb is and points at nothing.
    expect(find.byType(SeatLayerConfirmCard), findsOneWidget);
    expect(find.byType(SeatLayerConfirmCardPointer), findsNothing);
  });

  testWidgets('the cart sheet is paused while the card is asking', (
    tester,
  ) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    // Faded rather than hidden — what is already in the cart is context for
    // the seat being decided on — and out of reach, so nothing under the card
    // can answer the question the card is asking.
    expect(_pausedSheet(tester).opacity, .58);
    expect(
      tester
          .widget<IgnorePointer>(
            find
                .descendant(of: _sheetPause, matching: find.byType(IgnorePointer))
                .first,
          )
          .ignoring,
      isTrue,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_pausedSheet(tester).opacity, 1);
  });

  testWidgets('a runtime that never says where the seat is points at nothing', (
    tester,
  ) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(pickerSnapshot(sections: pickerSections()));
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerConfirmCard), findsOneWidget);
    expect(find.byType(SeatLayerConfirmCardPointer), findsNothing);
  });

  testWidgets('the scene gets the card on the tap, before and after the dive',
      (tester) async {
    final map = FakePickerMap(bundle: _venue3DBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    // Still travelling: nothing to ask about yet.
    map.emit(_inVenue3D(targeted: false));
    await tester.pumpAndSettle();
    expect(find.byType(SeatLayerConfirmCard), findsOneWidget);

    map.emit(_inVenue3D(revision: 3));
    await tester.pumpAndSettle();
    expect(find.byType(SeatLayerConfirmCard), findsOneWidget);
    // Its own action, and no pointer: in the scene the seat is the picture.
    expect(find.text('View from this seat'), findsOneWidget);
    expect(find.byType(SeatLayerConfirmCardPointer), findsNothing);

    // The way between seats stays clear of the card.
    final deck = tester.getRect(
      find.descendant(
        of: find.byType(SeatLayerVenue3D),
        matching: find.byIcon(Icons.filter_center_focus_rounded),
      ),
    );
    final card = tester.getRect(
      find.byKey(const ValueKey<String>('seatlayer.confirm-card.surface')),
    );
    expect(card.bottom, lessThanOrEqualTo(deck.top));
    // Ten points above the deck band exactly: the band is the map's own inset
    // plus the deck, which is taller once the buyer is sitting somewhere.
    final area = tester.getRect(
      find.byKey(const ValueKey<String>('seatlayer-picker-prompt-transition')),
    );
    expect(
      card.bottom,
      closeTo(
        area.bottom -
            SeatLayerSizeTokens.mapAnchorInset -
            SeatLayerVenue3D.seatDeckHeight(seated: true) -
            SeatLayerSizeTokens.confirmCardImmersiveRestInset,
        .01,
      ),
    );
  });

  testWidgets('the card never moves the band the runtime frames against',
      (tester) async {
    final map = FakePickerMap(bundle: _venue3DBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
    map.emit(_inVenue3D());
    await tester.pumpAndSettle();
    final withCard = map.callsTo('picker.setViewportInsets').last.$2;

    // The card is transient chrome: answering it leaves the scene's own bands
    // exactly where the runtime already framed against them.
    await tester.tap(find.text('Add seat'));
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerConfirmCard), findsNothing);
    expect(map.callsTo('picker.setViewportInsets').last.$2, withCard);
  });

  testWidgets('a composed layout that asks nothing keeps the seat counted',
      (tester) async {
    // The suppression belongs to whichever chrome is actually asking. A host
    // that places the cart sheet with no confirm card must not lose the seat.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SizedBox.shrink(), controller: picker),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(picker.seatAwaitingConfirmation, isNull);
    expect(picker.confirmedTicketCount, 1);
    expect(picker.canCheckout, isTrue);
  });
}
