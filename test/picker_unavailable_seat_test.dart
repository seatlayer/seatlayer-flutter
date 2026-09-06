// A SEAT THE BUYER CANNOT TAKE IS INERT.
//
// The engine stopped reporting taps on a sold, blocked or someone-else's-held
// seat at all: no pinned card with a reason, no state card inside the scene.
// These pin the same rule on this side of the bridge, for the case an older
// runtime still reports such a tap. A card asking "add this seat?" over a seat
// that is already gone is a question with no true answer, and telling the buyer
// a reason they can do nothing about is worse than leaving them on the map.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_seat_confirmation.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The fixture's selected seat, reported with [status].
Map<String, Object?> _selected(String? status, {String? holdOwner}) {
  final snapshot = pickerSnapshot(holdOwner: holdOwner, seatViewThumb: null);
  final selection = snapshot['selection']! as Map<String, Object?>;
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = <Object?>[
    <String, Object?>{...seat, if (status != null) 'status': status},
  ];
  return snapshot;
}

Future<void> _pumpCard(WidgetTester tester, FakePickerMap map,
    Map<String, Object?> snapshot) async {
  usePhoneSurface(tester);
  await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
  map.emit(snapshot);
  await pumpToRest(tester);
}

void main() {
  testWidgets('a free seat still asks, exactly as before', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected('free'));
    expect(find.text('Add seat'), findsOneWidget);
  });

  testWidgets('a seat with no status reported still asks', (tester) async {
    // Every runtime shipped before the field omits it, and "not reported" is
    // not "unavailable".
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected(null));
    expect(find.text('Add seat'), findsOneWidget);
  });

  testWidgets('a booked seat raises no card', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected('booked'));
    expect(find.text('Add seat'), findsNothing);
    // And no card explaining why, either — that is the whole of the change.
    expect(find.textContaining('booked'), findsNothing);
    expect(find.textContaining('another buyer'), findsNothing);
  });

  testWidgets('a blocked seat raises no card', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected('blocked'));
    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets("a seat in someone else's hold raises no card", (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected('held'));
    expect(find.text('Add seat'), findsNothing);
  });

  testWidgets('a seat held by the picker itself keeps its card',
      (tester) async {
    // Once the picker holds, the buyer's OWN seats report as held. The card
    // over them is the one that offers them back.
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected('held', holdOwner: 'picker'));
    expect(find.text('Add seat'), findsOneWidget);
  });

  testWidgets('a status this build does not know is not swallowed',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    await _pumpCard(tester, map, _selected('reserved-for-members'));
    expect(find.text('Add seat'), findsOneWidget);
  });

  testWidgets('the wide layout follows the same rule', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerPickerSeatConfirmation()),
    );
    map.emit(_selected('booked'));
    await pumpToRest(tester);

    expect(find.byType(SeatLayerPickerSeatConfirmation), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
  });
}
