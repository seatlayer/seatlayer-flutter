// A second tap on a seat already in the cart asks before it takes it back.
//
// It used to drop the seat in silence: the ring went, the cart emptied, the
// total moved, and nothing said so or offered the seat back.
// A buyer checking which seat they had picked lost it by looking at it.
//
// The runtime now KEEPS the seat and reports the tap as `seat.retap` instead,
// and the native chrome raises the same confirm card over it with Remove where
// Add seat was. Cancel, Back, Escape and the tap outside all keep the seat;
// only the primary button takes it, and it takes it down the same path the
// cart's own ✕ uses.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_prompt_presentation.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// The seat as the runtime reports it back on a retap.
///
/// Lifted out of the fixture's own selection rather than written again here:
/// the payload the runtime sends is one `selection[]` entry, and a test that
/// hand-rolled a second shape would stop testing the one that arrives.
Map<String, Object?> _retapPayload() {
  final selection =
      pickerSnapshot()['selection']! as Map<String, Object?>;
  final seat = (selection['seats']! as List<Object?>).first!;
  return <String, Object?>{'seat': seat};
}

/// A picker with A-1 in the cart and answered for, and no card up.
Future<SeatLayerPickerController> _cartWithSeat(
  WidgetTester tester,
  FakePickerMap map,
) async {
  final picker = SeatLayerPickerController(mapController: map);
  addTearDown(picker.dispose);
  useFakeWebViewPlatform();
  usePhoneSurface(tester);
  await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
  map.emit(pickerSnapshot(sections: pickerSections()));
  await pumpToRest(tester);

  // The buyer answers the ADD card, which is what puts the seat in the cart
  // for good; everything below is about the tap after that.
  await tester.tap(find.text(_strings.addSeat));
  await pumpToRest(tester);
  expect(find.byType(SeatLayerConfirmCard), findsNothing);
  expect(picker.confirmedTicketCount, 1);
  map.calls.clear();
  return picker;
}

/// Every command except the sheet's own viewport-inset reporting.
Iterable<(String, Object?)> _inventoryCalls(FakePickerMap map) =>
    map.calls.where((call) => call.$1 != 'picker.setViewportInsets');

void main() {
  testWidgets('a retap raises the card asking to remove, and keeps the seat',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cartWithSeat(tester, map);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);

    expect(picker.seatAwaitingRemoval?.label, 'A-1');
    expect(find.byType(SeatLayerConfirmCard), findsOneWidget);
    expect(find.text(_strings.removeSeat), findsOneWidget);
    expect(find.text(_strings.addSeat), findsNothing);
    // Still in the cart while the card asks. It is not a candidate — the
    // buyer already owns it — so it keeps its ticket and its money until the
    // question is actually answered.
    expect(picker.state.selection.single.label, 'A-1');
    expect(picker.confirmedTicketCount, 1);
    expect(picker.confirmedCartLines, hasLength(1));
    expect(picker.confirmedCartTotal, 25.0);
    // Asking is not doing: nothing has been sent to the runtime.
    // Inventory must be untouched. Inset reporting is not inventory: the fixed
    // sheet tells the runtime its band on open and takes it back on close.
    expect(_inventoryCalls(map), isEmpty);
  });

  testWidgets('Cancel keeps the seat and sends nothing', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cartWithSeat(tester, map);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    await tester.tap(find.text(_strings.cancel));
    await pumpToRest(tester);

    expect(find.byType(SeatLayerConfirmCard), findsNothing);
    expect(picker.seatAwaitingRemoval, isNull);
    expect(picker.state.selection.single.label, 'A-1');
    expect(picker.confirmedTicketCount, 1);
    // Inventory must be untouched. Inset reporting is not inventory: the fixed
    // sheet tells the runtime its band on open and takes it back on close.
    expect(_inventoryCalls(map), isEmpty);
  });

  testWidgets('the tap outside keeps the seat too', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cartWithSeat(tester, map);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    // The scrim's press and Escape are one seam, and it is the seam that is
    // interesting here rather than where on the map the finger landed: a stray
    // press must never be the thing that empties someone's cart.
    tester
        .widget<PickerPromptTransition>(find.byType(PickerPromptTransition))
        .onDismiss!();
    await pumpToRest(tester);

    expect(find.byType(SeatLayerConfirmCard), findsNothing);
    expect(picker.seatAwaitingRemoval, isNull);
    expect(picker.state.selection.single.label, 'A-1');
    // Inventory must be untouched. Inset reporting is not inventory: the fixed
    // sheet tells the runtime its band on open and takes it back on close.
    expect(_inventoryCalls(map), isEmpty);
  });

  testWidgets('Remove takes the seat back out, the way the cart ✕ does',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cartWithSeat(tester, map);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    await tester.tap(find.text(_strings.removeSeat));
    await pumpToRest(tester);

    expect(
      map.callsTo('picker.removeCartLine').single.$2,
      <String, Object?>{'label': 'A-1'},
    );
    expect(picker.seatAwaitingRemoval, isNull);
    expect(find.byType(SeatLayerConfirmCard), findsNothing);
  });

  testWidgets('a cancelled question can be asked again', (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cartWithSeat(tester, map);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    await tester.tap(find.text(_strings.cancel));
    await pumpToRest(tester);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    expect(picker.seatAwaitingRemoval?.label, 'A-1');
    expect(find.text(_strings.removeSeat), findsOneWidget);
  });

  testWidgets('a seat that leaves the selection takes its question with it',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cartWithSeat(tester, map);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    expect(picker.seatAwaitingRemoval, isNotNull);

    // Another device took it, or the buyer removed it from the tray.
    map.emit(pickerSnapshot(
      sections: pickerSections(),
      revision: 2,
      withSelection: false,
    ));
    await pumpToRest(tester);
    expect(picker.seatAwaitingRemoval, isNull);
    expect(find.byType(SeatLayerConfirmCard), findsNothing);
  });

  testWidgets('a read-only picker is never asked the question',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        controller: picker,
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    expect(picker.seatAwaitingRemoval, isNull);
    expect(find.byType(SeatLayerConfirmCard), findsNothing);
  });
}
