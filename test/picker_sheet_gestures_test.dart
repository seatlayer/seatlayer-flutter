import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_haptics.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_sheet_drag.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Future<void> _noopCheckout(_) async {}

/// [child], for a viewer who has asked for less movement — with everything
/// else about the surrounding MediaQuery left alone, so the phone is still a
/// phone.
Widget _stilled(Widget child) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child,
      ),
    );

/// Flutter hands the first slice of a drag to the touch slop and reports
/// nothing for it, so a measured drag primes past the slop first.
Future<void> _prime(WidgetTester tester, TestGesture gesture) async {
  await gesture.moveBy(const Offset(0, -kTouchSlop - 1));
  await tester.pump();
}

/// The sheet wired the way the phone layout wires it: the controller owns where
/// it rests, and the sheet is rebuilt from that.
Widget _wired(SeatLayerPickerController picker) => AnimatedBuilder(
      animation: picker,
      builder: (context, _) => Align(
        alignment: Alignment.bottomCenter,
        child: SeatLayerCartSheet(
          expanded: picker.cartSheetExpanded,
          onExpandedChanged: picker.setCartSheetExpanded,
          onCheckout: _noopCheckout,
        ),
      ),
    );

double _height(WidgetTester tester) =>
    tester.getSize(find.byType(SeatLayerCartSheet)).height;

/// A point on the sheet's head — the grab handle, and the one place a drag can
/// never be taken by the ticket list underneath it.
Offset _head(WidgetTester tester) {
  final rect = tester.getRect(find.byType(SeatLayerCartSheet));
  return Offset(rect.center.dx, rect.top + 8);
}

/// The head is fifty points shut and thirty-six open, so the first fourteen
/// points of a drag are spent compressing it.
const double _headGive = 50 - 36;

void main() {
  group('the sheet drags', () {
    testWidgets('the surface follows the finger, point for point',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();
      expect(_height(tester), 50 + SeatLayerSizeTokens.peekClockLift);

      final drag = await tester.startGesture(_head(tester));
      await _prime(tester, drag);
      await drag.moveBy(const Offset(0, -30));
      await tester.pump();
      expect(_height(tester), 50 + 30 - _headGive);

      await drag.moveBy(const Offset(0, -30));
      await tester.pump();
      expect(_height(tester), 50 + 60 - _headGive);

      await drag.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a drag settles at a detent, and the controller says which',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SeatLayerCartSheet), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(picker.cartSheetDetent, SeatLayerSheetDetent.content);
      expect(picker.cartSheetExpanded, isTrue);
      // Its own content height, not the ceiling: one ticket does not open four
      // hundred points of white.
      final opened = _height(tester);
      expect(opened, greaterThan(50));
      expect(opened, lessThan(390 * .72));

      // And the sheet stands exactly on the detent — a spring that stopped a
      // third of a point short would make this a different number every run.
      await tester.pumpAndSettle();
      expect(_height(tester), opened);
    });

    testWidgets('the ends give rather than stop, and let go back',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();
      final resting = _height(tester);

      final drag = await tester.startGesture(_head(tester));
      await _prime(tester, drag);
      await drag.moveBy(const Offset(0, -160));
      await tester.pump();
      final stretched = _height(tester);
      // It moved — a hard stop would tell the buyer their finger stopped
      // working — but nothing like the finger's own distance.
      expect(stretched, greaterThan(resting));
      expect(stretched - resting, lessThan(160 * .5));

      await drag.up();
      await tester.pumpAndSettle();
      expect(_height(tester), resting);
      expect(picker.cartSheetDetent, SeatLayerSheetDetent.content);
    });

    testWidgets('a short deliberate drag still answers', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();

      // Twenty points past the slop, slowly: nowhere near the content detent,
      // and no fling to carry it there. The accessible floor answers it.
      final drag = await tester.startGesture(_head(tester));
      await _prime(tester, drag);
      for (var step = 0; step < 10; step++) {
        await drag.moveBy(const Offset(0, -2));
        await tester.pump(const Duration(milliseconds: 40));
      }
      await drag.up();
      await tester.pumpAndSettle();

      expect(picker.cartSheetDetent, SeatLayerSheetDetent.content);
    });

    testWidgets('a fling picks the detent it was thrown at', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();

      await tester.fling(
          find.byType(SeatLayerCartSheet), const Offset(0, -80), 1200);
      await tester.pumpAndSettle();
      expect(picker.cartSheetDetent, SeatLayerSheetDetent.content);

      await tester.fling(
          find.byType(SeatLayerCartSheet), const Offset(0, 80), 1200);
      await tester.pumpAndSettle();
      expect(picker.cartSheetDetent, SeatLayerSheetDetent.peek);
    });

    testWidgets('a cart taller than the ceiling opens a place above it',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(_tenDistinctRows());
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();
      // Ten separate rows, all of them shown: the cart is now taller than the
      // web picker's ceiling, so the sheet rests ON the ceiling.
      await tester.tap(find.textContaining('more'));
      await tester.pumpAndSettle();
      final ceiling = _height(tester);
      expect(ceiling, 480);

      final drag = await tester.startGesture(_head(tester));
      await _prime(tester, drag);
      await drag.moveBy(const Offset(0, -240));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      // A place the picker never puts the sheet itself, and only offered
      // because there was more cart to see.
      expect(picker.cartSheetDetent, SeatLayerSheetDetent.full);
      expect(_height(tester), greaterThan(ceiling));
      expect(picker.cartSheetExpanded, isTrue);

      // And back down to the ceiling, which is still where a tap rests it.
      picker.setCartSheetExpanded(false);
      await tester.pumpAndSettle();
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();
      expect(_height(tester), ceiling);
    });

    testWidgets('the map still collapses it', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();
      expect(_height(tester), greaterThan(50));

      // What a tap on the map does to the sheet.
      picker.setCartSheetExpanded(false);
      await tester.pumpAndSettle();
      expect(picker.cartSheetDetent, SeatLayerSheetDetent.peek);
      expect(_height(tester), 50 + SeatLayerSizeTokens.peekClockLift);
    });

    testWidgets('reduced motion arrives without a spring', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          _stilled(_wired(picker)),
          controller: picker,
        ),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();
      final shut = _height(tester);

      picker.setCartSheetExpanded(true);
      // One frame, not a settle: there is nothing left to animate.
      await tester.pump();
      final open = _height(tester);
      expect(open, greaterThan(shut));
      await tester.pump(const Duration(milliseconds: 16));
      expect(_height(tester), open);
    });
  });

  group('a swipe removes a ticket', () {
    testWidgets('past the commit point, with the undo the × offers',
        (tester) async {
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
          Stack(
            children: <Widget>[
              _wired(picker),
              const Positioned.fill(child: SeatLayerPickerToastLayer()),
            ],
          ),
          controller: picker,
        ),
      );
      map.emit(pickerSnapshot());
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();

      final row = find.textContaining('Gallery');
      expect(row, findsWidgets);
      await tester.drag(row.first, const Offset(-260, 0));
      await tester.pumpAndSettle();

      expect(map.callsTo('picker.removeCartLine'), hasLength(1));
      expect(find.text('Undo'), findsOneWidget);
      expect(felt, contains(PickerHapticCue.ticketRemoved));
      expect(pickerHapticStrength(PickerHapticCue.ticketRemoved), 'light');
    });

    testWidgets('and not before it: a short push snaps back', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();

      final row = find.textContaining('Gallery').first;
      final before = tester.getRect(row);
      // Well under two fifths of the row, and slowly enough not to be a throw.
      final drag = await tester.startGesture(tester.getCenter(row));
      await drag.moveBy(const Offset(-kTouchSlop - 1, 0));
      await tester.pump();
      for (var step = 0; step < 5; step++) {
        await drag.moveBy(const Offset(-8, 0));
        await tester.pump(const Duration(milliseconds: 40));
      }
      expect(tester.getRect(row).left, lessThan(before.left));
      await drag.up();
      await tester.pumpAndSettle();

      expect(map.callsTo('picker.removeCartLine'), isEmpty);
      expect(tester.getRect(row).left, closeTo(before.left, .01));
    });

    testWidgets('a held row does not move', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      // A hold the HOST owns: those seats are the server's now, and nothing in
      // the cart may take them back.
      map.emit(pickerSnapshot(holdOwner: 'host'));
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();

      final row = find.textContaining('Gallery').first;
      final before = tester.getRect(row);
      await tester.drag(row, const Offset(-260, 0));
      await tester.pumpAndSettle();

      expect(map.callsTo('picker.removeCartLine'), isEmpty);
      expect(tester.getRect(row).left, closeTo(before.left, .01));
    });

    testWidgets('reduced motion removes without sliding', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          _stilled(_wired(picker)),
          controller: picker,
        ),
      );
      map.emit(pickerSnapshot());
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();

      await tester.drag(
        find.textContaining('Gallery').first,
        const Offset(-260, 0),
      );
      // One frame: the row leaves on the release, with nothing to watch.
      await tester.pump();
      expect(map.callsTo('picker.removeCartLine'), hasLength(1));
    });
  });

  group('haptics', () {
    testWidgets('the hold warns once, a minute before it lapses',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      final felt = <PickerHapticCue>[];
      picker.playHaptic = felt.add;
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(_holdEndingIn(const Duration(seconds: 61)));
      await tester.pumpAndSettle();
      expect(felt, isNot(contains(PickerHapticCue.holdEnding)));

      await tester.pump(const Duration(seconds: 2));
      expect(felt, contains(PickerHapticCue.holdEnding));
      // Distinct from every impact in the set: it has to be recognisable
      // through a pocket.
      expect(pickerHapticStrength(PickerHapticCue.holdEnding), 'warning');
    });

    testWidgets('a hold already inside its last minute says nothing',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      final felt = <PickerHapticCue>[];
      picker.playHaptic = felt.add;
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(_holdEndingIn(const Duration(seconds: 40)));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 45));

      expect(felt, isNot(contains(PickerHapticCue.holdEnding)));
    });

    testWidgets('a host that turned haptics off feels none of it',
        (tester) async {
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
          _wired(picker),
          controller: picker,
          options: const SeatLayerPickerOptions(haptics: false),
        ),
      );
      map.emit(_holdEndingIn(const Duration(seconds: 61)));
      picker.setCartSheetExpanded(true);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      await tester.drag(
        find.textContaining('Gallery').first,
        const Offset(-260, 0),
      );
      await tester.pumpAndSettle();

      expect(map.callsTo('picker.removeCartLine'), hasLength(1));
      expect(felt, isEmpty);
    });

    test('arriving in a section is a tick, and a secured hold a thump', () {
      // Navigation that thumps is navigation a buyer stops doing; a hold is
      // the one moment in the flow with consequences.
      expect(pickerHapticStrength(PickerHapticCue.sectionFocused), 'selection');
      expect(pickerHapticStrength(PickerHapticCue.holdCreated), 'medium');
    });

    testWidgets('a hold that becomes real is felt', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      final picker = SeatLayerPickerController(mapController: map);
      addTearDown(picker.dispose);
      final felt = <PickerHapticCue>[];
      picker.playHaptic = felt.add;
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _wired(picker), controller: picker),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();
      felt.clear();

      // The checkout handoff's own snapshot: the seats are held now.
      map.emit(pickerSnapshot(revision: 2, holdOwner: 'picker'));
      await tester.pumpAndSettle();
      expect(felt, contains(PickerHapticCue.holdCreated));
    });
  });
}

/// The fixture cart, held, with the hold running out in [remaining].
Map<String, Object?> _holdEndingIn(Duration remaining) {
  final snapshot = pickerSnapshot(holdOwner: 'picker');
  (snapshot['hold']! as Map<String, Object?>)['expiresAt'] =
      seatLayerPickerNow().add(remaining).millisecondsSinceEpoch.toDouble();
  return snapshot;
}

/// Ten separate rows: one run each, and a cart taller than the sheet's own
/// ceiling. The same shape `picker_cart_sheet_test.dart` measures the ceiling
/// with.
Map<String, Object?> _tenDistinctRows() {
  final snapshot = snapshotWithTicketCount(10, revision: 10);
  final cart = snapshot['cart']! as Map<String, Object?>;
  final selection = snapshot['selection']! as Map<String, Object?>;
  selection['seats'] = <Object?>[
    for (var index = 0; index < 10; index++)
      <String, Object?>{
        ...(selection['seats']! as List<Object?>)[index]!
            as Map<String, Object?>,
        'rowLabel': String.fromCharCode(65 + index),
      },
  ];
  cart['items'] = <Object?>[
    for (var index = 0; index < 10; index++)
      <String, Object?>{
        ...(cart['items']! as List<Object?>)[index]! as Map<String, Object?>,
      },
  ];
  return snapshot;
}
