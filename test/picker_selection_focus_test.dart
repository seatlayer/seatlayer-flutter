// The seat a card is asking about is the seat the runtime paints.
//
// A tapped seat joins `selection` immediately, and every selected seat is
// drawn alike, so the one the card is standing over used to be a plain ring
// among however many the buyer had already settled. The web picker has always
// told the runtime which seat is the candidate — it rings that one and pales
// its neighbours — and this is the same instruction over the bridge.
//
// Paint only: it never selects, holds or moves a camera, so an older runtime
// that cannot draw a candidate simply is not asked, and one that answers
// `unsupported_command` anyway leaves nothing on screen for a buyer to read.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_selection_focus.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/seat_layer_error.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();

/// The runtime's own id for the fixture's one selected seat.
const String _seatId = 'seat-a-1';

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

/// The seat as the runtime reports it back on a retap: one `selection[]` entry.
Map<String, Object?> _retapPayload() {
  final selection = pickerSnapshot()['selection']! as Map<String, Object?>;
  return <String, Object?>{'seat': (selection['seats']! as List<Object?>).first};
}

/// A mounted picker with the ADD card up over A-1.
Future<SeatLayerPickerController> _cardUp(
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
  return picker;
}

/// The `seatId` of every focus command the picker sent, in order.
List<Object?> _focusIds(FakePickerMap map) => map
    .callsTo(seatLayerSelectionFocusCommand)
    .map((call) => (call.$2! as Map<String, Object?>)['seatId'])
    .toList();

void main() {
  testWidgets('the card names its seat to the runtime, once', (tester) async {
    final map = FakePickerMap(bundle: selectionFocusBundle());
    addTearDown(map.dispose);
    await _cardUp(tester, map);

    // Once, not once a frame: the seat is reported from the chrome's build.
    expect(_focusIds(map), <Object?>[_seatId]);

    await tester.pump(const Duration(seconds: 1));
    expect(_focusIds(map), <Object?>[_seatId]);
  });

  testWidgets('answering the card clears the candidate', (tester) async {
    final map = FakePickerMap(bundle: selectionFocusBundle());
    addTearDown(map.dispose);
    await _cardUp(tester, map);

    await tester.tap(find.text(_strings.addSeat));
    await pumpToRest(tester);

    expect(_focusIds(map), <Object?>[_seatId, null]);
  });

  testWidgets('cancelling the card clears it too', (tester) async {
    final map = FakePickerMap(bundle: selectionFocusBundle());
    addTearDown(map.dispose);
    await _cardUp(tester, map);

    await tester.tap(find.text(_strings.cancel));
    await pumpToRest(tester);

    expect(_focusIds(map), <Object?>[_seatId, null]);
  });

  testWidgets('the remove card names its seat as well', (tester) async {
    final map = FakePickerMap(bundle: selectionFocusBundle());
    addTearDown(map.dispose);
    final picker = await _cardUp(tester, map);

    // Answer the ADD question first, so what follows is a second tap on a seat
    // the buyer already owns rather than the card they had open.
    await tester.tap(find.text(_strings.addSeat));
    await pumpToRest(tester);
    map.calls.clear();

    map.emitEvent('seat.retap', _retapPayload());
    await pumpToRest(tester);
    expect(picker.seatAwaitingRemoval?.label, 'A-1');
    expect(_focusIds(map), <Object?>[_seatId]);

    // Cancelling a remove keeps the seat, and hands the paint back with it.
    await tester.tap(find.text(_strings.cancel));
    await pumpToRest(tester);
    expect(_focusIds(map), <Object?>[_seatId, null]);
  });

  testWidgets('a runtime that does not advertise it is never asked',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = await _cardUp(tester, map);

    await tester.tap(find.text(_strings.addSeat));
    await pumpToRest(tester);

    expect(map.callsTo(seatLayerSelectionFocusCommand), isEmpty);
    expect(picker.state.error, isNull);
  });

  testWidgets('an unsupported_command reply leaves nothing on screen',
      (tester) async {
    final map = FakePickerMap(
      bundle: selectionFocusBundle(),
      handler: (command, payload) async {
        if (command != seatLayerSelectionFocusCommand) return null;
        throw const SeatLayerError.bridge(
          BridgeErrorPayload(
            code: BridgeErrorCode.unsupportedCommand,
            message: 'picker.setSelectionFocus',
          ),
        );
      },
    );
    addTearDown(map.dispose);
    final picker = await _cardUp(tester, map);

    expect(_focusIds(map), <Object?>[_seatId]);
    // The buyer asked for none of this and can do nothing about it: the seat
    // is simply painted the way it was before.
    expect(picker.state.error, isNull);
  });
}
