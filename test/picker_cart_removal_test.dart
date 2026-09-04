import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_cart_removal.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_motion.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// Two consecutive Gallery seats, which the list folds into one run.
///
/// The pilot's own shape: `103 · A · 9–10` is one row standing for two
/// tickets, and pressing its × takes the seat at its head and leaves the row
/// behind with a shorter range.
Map<String, Object?> _runSnapshot({int revision = 1}) {
  final snapshot = pickerSnapshot(revision: revision);
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = <Object?>[seat, _secondSeat(seat)];
  selection['validity'] = <String, Object?>{
    'isValid': true,
    'count': 2,
    'required': 0,
    'remaining': 0,
  };
  final cart = Map<String, Object?>.from(
    snapshot['cart']! as Map<String, Object?>,
  );
  final line = Map<String, Object?>.from(
    (cart['items']! as List<Object?>).single! as Map<String, Object?>,
  );
  cart
    ..['items'] = <Object?>[line, _secondLine(line)]
    ..['quantity'] = 2
    ..['total'] = 50.0;
  return <String, Object?>{...snapshot, 'selection': selection, 'cart': cart};
}

/// The same cart once `A-1` has really gone: one ticket, seat 2.
Map<String, Object?> _afterRemovalSnapshot({int revision = 1}) {
  final snapshot = pickerSnapshot(revision: revision);
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = <Object?>[_secondSeat(seat)];
  final cart = Map<String, Object?>.from(
    snapshot['cart']! as Map<String, Object?>,
  );
  final line = Map<String, Object?>.from(
    (cart['items']! as List<Object?>).single! as Map<String, Object?>,
  );
  cart['items'] = <Object?>[_secondLine(line)];
  return <String, Object?>{...snapshot, 'selection': selection, 'cart': cart};
}

Map<String, Object?> _secondSeat(Map<String, Object?> seat) =>
    <String, Object?>{
      ...seat,
      'id': 'seat-a-2',
      'label': 'A-2',
      'displayLabel': 'Row A, Seat 2',
      'seatNumber': '2',
    };

Map<String, Object?> _secondLine(Map<String, Object?> line) =>
    <String, Object?>{
      ...line,
      'lineKey': 'seat:A-2:adult',
      'label': 'A-2',
      'displayLabel': 'Row A, Seat 2',
      'objectId': 'seat-a-2',
    };

Future<void> _noopCheckout(_) async {}

Widget _sheet() => SeatLayerCartSheet(
      expanded: true,
      onExpandedChanged: (_) {},
      onCheckout: _noopCheckout,
    );

/// Everything the cart list draws, restricted to one widget type.
Finder _inList(Type type) => find.descendant(
      of: find.byType(SeatLayerCartList),
      matching: find.byType(type),
    );

/// What the row is currently being drawn at.
double _rowOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(_inList(AnimatedOpacity).first).opacity;

/// Whether the row's × can still be pressed.
bool _removeEnabled(WidgetTester tester) =>
    tester.widget<IconButton>(_inList(IconButton).first).onPressed != null;

/// Every cell that would cross-fade, by the words it is stating.
List<String> _cellTokens(WidgetTester tester) => tester
    .widgetList<SeatLayerCrossFade>(_inList(SeatLayerCrossFade))
    .map((cell) => cell.token)
    .toList();

/// Press the × on the run at the head of the list.
Future<void> _pressRemove(WidgetTester tester) async {
  await tester.tap(_inList(IconButton).first);
  await tester.pump();
}

void main() {
  testWidgets('the press is answered by the row, not by the server', (
    tester,
  ) async {
    final gate = Completer<void>();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerCartList(), controller: controller),
    );
    map.emit(_runSnapshot());
    await tester.pumpAndSettle();

    expect(_rowOpacity(tester), 1);
    expect(_removeEnabled(tester), isTrue);

    map.gate('picker.removeCartLine', gate);
    await _pressRemove(tester);

    // Nothing has been answered yet — and the row has already said so.
    expect(map.callsTo('picker.removeCartLine'), hasLength(1));
    expect(_rowOpacity(tester), SeatLayerOpacityTokens.removing);
    expect(_removeEnabled(tester), isFalse);
    // The row IS the answer. Nothing is said on top of it: the line has gone
    // faded and inert under the finger, and a sentence naming what the buyer
    // just did — with an Undo that turns one tap into two against a timer —
    // was the old shape.
    expect(seatLayerPickerToasts(controller).current, isNull);
    expect(seatLayerCartRemovalsOf(controller).isRemoving('A-1'), isTrue);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('the sheet is not dead while a line is being removed', (
    tester,
  ) async {
    final gate = Completer<void>();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
        controller: controller,
      ),
    );
    map.emit(_runSnapshot());
    await tester.pumpAndSettle();

    map.gate('picker.removeCartLine', gate);
    await _pressRemove(tester);

    // The one button the buyer came for stays live through the wait.
    final book = find.descendant(
      of: find.byType(SeatLayerBookButton),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(book).onPressed, isNotNull);
    expect(controller.canCheckout, isTrue);

    // Pressing it during the removal is safe because the controller
    // serialises inventory mutations: the handoff is sent after the removal,
    // against the cart the buyer can see.
    await tester.tap(book);
    await tester.pump();
    expect(map.callsTo('picker.continue'), isEmpty);

    map.current = _afterRemovalSnapshot(revision: map.revision);
    gate.complete();
    await tester.pumpAndSettle();

    final order = map.calls
        .map((call) => call.$1)
        .where((name) =>
            name == 'picker.removeCartLine' || name == 'picker.continue')
        .toList();
    expect(order, <String>['picker.removeCartLine', 'picker.continue']);
  });

  testWidgets('a removal that fails puts the row back', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerCartList(), controller: controller),
    );
    map.emit(_runSnapshot());
    await tester.pumpAndSettle();

    map.failing.add('picker.removeCartLine');
    await _pressRemove(tester);
    await tester.pumpAndSettle();

    expect(_rowOpacity(tester), 1);
    expect(_removeEnabled(tester), isTrue);
    expect(seatLayerCartRemovalsOf(controller).isEmpty, isTrue);
    // The bar offered an undo for something that never happened.
    expect(seatLayerPickerToasts(controller).current, isNull);
    // And the failure is still the controller's to state.
    expect(controller.state.error, isNotNull);
  });

  testWidgets('the snapshot that drops the line clears the mark', (
    tester,
  ) async {
    final gate = Completer<void>();
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerCartList(), controller: controller),
    );
    map.emit(_runSnapshot());
    await tester.pumpAndSettle();

    map.gate('picker.removeCartLine', gate);
    await _pressRemove(tester);
    expect(seatLayerCartRemovalsOf(controller).isRemoving('A-1'), isTrue);

    map.current = _afterRemovalSnapshot(revision: map.revision);
    gate.complete();
    await tester.pumpAndSettle();

    expect(seatLayerCartRemovalsOf(controller).isEmpty, isTrue);
    expect(_rowOpacity(tester), 1);
    expect(_removeEnabled(tester), isTrue);
  });

  testWidgets('the cell whose words changed cross-fades them', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(map, const SeatLayerCartList(), controller: controller),
    );
    map.emit(_runSnapshot());
    await tester.pumpAndSettle();

    // `Gallery · A · 1–2`, and the run's `2 × €25`.
    expect(_cellTokens(tester), contains('Gallery · A · 1–2'));
    expect(_cellTokens(tester), contains('2 × €25'));
    expect(_inList(AnimatedSwitcher), findsWidgets);

    map.emit(_afterRemovalSnapshot(revision: 2));
    await tester.pumpAndSettle();

    // The same row, restating the same fact — so the cell is keyed on the
    // words rather than on the widget, and the swap is a cross-fade.
    expect(_cellTokens(tester), contains('Gallery · A · 2'));
    // The run's own `2 × €25` is not a fact about a single ticket; the cell
    // empties rather than the row jumping.
    expect(_cellTokens(tester), contains(''));
  });

  testWidgets('a viewer who asked for less movement gets no switcher', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    final controller = SeatLayerPickerController(mapController: map);
    addTearDown(controller.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const SeatLayerCartList(),
          ),
        ),
        controller: controller,
      ),
    );
    map.emit(_runSnapshot());
    await tester.pumpAndSettle();

    expect(_inList(SeatLayerCrossFade), findsWidgets);
    expect(_inList(AnimatedSwitcher), findsNothing);

    map.emit(_afterRemovalSnapshot(revision: 2));
    await tester.pumpAndSettle();
    expect(_inList(AnimatedSwitcher), findsNothing);
  });
}
