import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/seat_layer_error.dart';
import 'package:seatlayer/src/bridge/bridge_protocol.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_states.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

Future<void> _noopCheckout(_) async {}

Widget _sheet({bool expanded = true}) => SeatLayerCartSheet(
      expanded: expanded,
      onExpandedChanged: (_) {},
      onCheckout: _noopCheckout,
    );

double _sheetHeight(WidgetTester tester) =>
    tester.getSize(find.byType(SeatLayerCartSheet)).height;

/// The fixture snapshot with a second €25 seat in the selection and the cart.
///
/// Two seats are what it takes to see a confirm card AND a cart at the same
/// time: the picker asks about the last unanswered seat, so answering one
/// leaves a ticket in the cart with a card still up over the other.
Map<String, Object?> _twoSeatSnapshot() {
  final snapshot = pickerSnapshot();
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seat = Map<String, Object?>.from(
    (selection['seats']! as List<Object?>).single! as Map<String, Object?>,
  );
  selection['seats'] = <Object?>[
    seat,
    <String, Object?>{
      ...seat,
      'id': 'seat-b-2',
      'label': 'B-2',
      'displayLabel': 'Row B, Seat 2',
      'rowLabel': 'B',
      'seatNumber': '2',
    },
  ];
  final cart = Map<String, Object?>.from(
    snapshot['cart']! as Map<String, Object?>,
  );
  final line = Map<String, Object?>.from(
    (cart['items']! as List<Object?>).single! as Map<String, Object?>,
  );
  cart['items'] = <Object?>[
    line,
    <String, Object?>{
      ...line,
      'lineKey': 'seat:B-2:adult',
      'label': 'B-2',
      'displayLabel': 'Row B, Seat 2',
      'objectId': 'seat-b-2',
    },
  ];
  cart['quantity'] = 2;
  cart['total'] = 50.0;
  return <String, Object?>{...snapshot, 'selection': selection, 'cart': cart};
}

/// The fixture snapshot for an event that has stopped selling.
Map<String, Object?> _salesClosedSnapshot() {
  final snapshot = pickerSnapshot();
  final event = Map<String, Object?>.from(
    snapshot['event']! as Map<String, Object?>,
  )..['salesClosed'] = true;
  return <String, Object?>{...snapshot, 'event': event};
}

/// The bottom safe inset the collapsed-bar tests emulate.
const double _safeBottom = 34;

void main() {
  _identityJoinTests();
  _clockTests();

  testWidgets('the collapsed sheet IS the footer block', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    // The cart, the total line and the way on — the same block the open sheet
    // has, and the same one the desktop panel has.
    expect(find.byType(SeatLayerCartCard), findsOneWidget);
    expect(find.text('1 ticket'), findsOneWidget);
    expect(find.text('€25'), findsWidgets);
    expect(find.text('Hold seats & checkout'), findsOneWidget);
    // No second summary of one cart, and no price with nothing to do about it.
    expect(find.text('1 ticket · €25'), findsNothing);
    expect(find.textContaining('From '), findsNothing);
    // The open sheet's own contents stay behind the handle.
    expect(find.byType(SeatLayerBestSeatsForm), findsNothing);
  });

  testWidgets('an empty cart says so, and never a price it cannot act on', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    // `From €25` stated a price and offered nothing to do about it, on the one
    // line the buyer reads to find out what they are about to pay.
    expect(find.text('No seats selected'), findsOneWidget);
    expect(find.textContaining('From '), findsNothing);
    expect(find.textContaining('Continue'), findsNothing);
    // The door is the footer's own button, full width and live.
    expect(find.text('Find best seats'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Find best seats'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('the empty cart\'s button opens the finder', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    var expanded = false;
    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: false,
            onExpandedChanged: (value) => expanded = value,
            onCheckout: _noopCheckout,
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    // Full width and the full touch floor: on a phone the footer IS the sheet.
    final button = find.widgetWithText(FilledButton, 'Find best seats');
    expect(
        tester.getSize(button).width, 390 - (SeatLayerSizeTokens.footPadX * 2));
    expect(
      tester.getSize(button).height,
      greaterThanOrEqualTo(SeatLayerSizeTokens.checkoutButtonHeight),
    );

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    // And the form it opens on is now in the tree.
    expect(find.byType(SeatLayerBestSeatsForm), findsOneWidget);
  });

  testWidgets('the finder door is withheld where the form would be refused', (
    tester,
  ) async {
    Future<void> expectNoPill(
      WidgetTester tester,
      Map<String, Object?> snapshot, {
      SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
    }) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(
          map,
          Align(
            alignment: Alignment.bottomCenter,
            child: _sheet(expanded: false),
          ),
          options: options,
        ),
      );
      map.emit(snapshot);
      await tester.pumpAndSettle();
      expect(find.text('Find best seats'), findsNothing);
    }

    final closed = pickerSnapshot(withSelection: false);
    (closed['event']! as Map<String, Object?>)['salesClosed'] = true;
    await expectNoPill(tester, closed);

    await expectNoPill(
      tester,
      pickerSnapshot(withSelection: false),
      options: const SeatLayerPickerOptions(enableBestAvailable: false),
    );
    await expectNoPill(
      tester,
      pickerSnapshot(withSelection: false),
      options: const SeatLayerPickerOptions(readOnly: true),
    );
    // Seats already reserved: the finder would take them away again.
    await expectNoPill(
      tester,
      pickerSnapshot(withSelection: false, holdOwner: 'picker'),
    );
  });

  testWidgets(
      'the grabber keeps its promise: a swipe opens and closes the sheet',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    bool? asked;
    Widget sheet(bool expanded) => Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: expanded,
            onExpandedChanged: (value) => asked = value,
            onCheckout: _noopCheckout,
          ),
        );
    await tester.pumpWidget(pickerHarness(map, sheet(false)));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.fling(
        find.byType(SeatLayerCartSheet), const Offset(0, -80), 900);
    await tester.pumpAndSettle();
    expect(asked, isTrue);

    asked = null;
    await tester.pumpWidget(pickerHarness(map, sheet(true)));
    await tester.pumpAndSettle();
    await tester.fling(
        find.byType(SeatLayerCartSheet), const Offset(0, 80), 900);
    await tester.pumpAndSettle();
    expect(asked, isFalse);
  });

  testWidgets('the collapsed way on is a full-size target', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(
      tester
          .getSize(find.widgetWithText(FilledButton, 'Hold seats & checkout'))
          .height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('a held row wears a lock and its own hairline', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    // A wash of the accent behind the line, not a box around it: the rows are
    // one plate, and a boxed row inside it read as a different kind of thing.
    final row = tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(Icons.lock_rounded),
            matching: find.byType(Container),
          )
          .last,
    );
    expect((row.decoration! as BoxDecoration).color, isNotNull);
  });

  testWidgets(
      'a host-owned hold keeps its ×, and the press is a state with a way out',
      (tester) async {
    final map = FakePickerMap(
      handler: (command, payload) async {
        if (command != 'picker.removeCartLine') return null;
        throw const SeatLayerError.bridge(
          BridgeErrorPayload(
            code: 'hold_owned_by_host',
            message: 'the active hold belongs to the host',
          ),
        );
      },
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot(holdOwner: 'host'));
    await tester.pumpAndSettle();

    final remove = find.byTooltip(RegExp('^Remove '));
    expect(remove, findsOneWidget);
    await tester.tap(remove);
    await pumpToRest(tester);
    expect(find.text('Your seats are already in checkout'), findsOneWidget);
  });

  testWidgets('the remove control clears the touch floor', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    final remove = tester.getSize(
      find.widgetWithIcon(IconButton, Icons.close_rounded),
    );
    expect(remove.width, greaterThanOrEqualTo(44));
    expect(remove.height, greaterThanOrEqualTo(44));
  });

  testWidgets('the collapsed safe area carries required attribution only', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    Widget subject() => Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: const EdgeInsets.only(bottom: _safeBottom)),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _sheet(expanded: false),
            ),
          ),
        );
    await tester.pumpWidget(pickerHarness(map, subject()));
    map.emit(pickerSnapshot(withSelection: false));
    await tester.pumpAndSettle();

    expect(find.text('Powered by SeatLayer'), findsOneWidget);
    final withCredit = _sheetHeight(tester);
    final attributionRect = tester.getRect(find.text('Powered by SeatLayer'));
    final sheetRect = tester.getRect(find.byType(SeatLayerCartSheet));
    // Centred: a phone's rounded corner clips whatever hugs the trailing edge.
    expect(
      (attributionRect.center.dx - sheetRect.center.dx).abs(),
      lessThan(12),
    );

    final hidden = pickerSnapshot(revision: 2, withSelection: false);
    (hidden['branding']! as Map<String, Object?>)['attributionRequired'] =
        false;
    map.emit(hidden);
    await tester.pumpAndSettle();
    expect(find.text('Powered by SeatLayer'), findsNothing);
    // The credit is the only thing that goes: the sheet is shorter by exactly
    // the line it stopped drawing, and the safe area is still reserved.
    expect(_sheetHeight(tester), lessThan(withCredit));
    expect(
      tester.getRect(find.byType(SeatLayerCartSheet)).bottom -
          tester.getRect(find.byType(FilledButton)).bottom,
      greaterThanOrEqualTo(_safeBottom),
    );
  });

  testWidgets('the expanded header states the count once', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(snapshotWithTicketCount(6));
    await tester.pumpAndSettle();

    expect(find.text('6 tickets'), findsOneWidget);
    expect(find.textContaining('6 tickets · '), findsNothing);
    expect(find.text('Your tickets'), findsNothing);
  });

  testWidgets('the sheet follows its content and stops at three fifths', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();
    final oneTicket = _sheetHeight(tester);

    map.emit(_tenDistinctRows());
    await tester.pumpAndSettle();
    final tenRows = _sheetHeight(tester);

    expect(oneTicket, lessThan(tenRows));
    // Seventy-two per cent of the screen, and never more than 480 points.
    expect(tenRows, lessThanOrEqualTo(480));

    // Ten seats in one row are ten cards now, and they reach the same ceiling.
    map.emit(snapshotWithTicketCount(10, revision: 20));
    await tester.pumpAndSettle();
    expect(_sheetHeight(tester), greaterThan(oneTicket));
    expect(_sheetHeight(tester), lessThanOrEqualTo(480));
  });

  testWidgets('an empty tray stays short and hides its hint from the eye', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(bestAvailableSnapshot());
    await tester.pumpAndSettle();

    expect(_sheetHeight(tester), lessThanOrEqualTo(380));
    expect(
      find.text(
        'Tap a seat on the map, or let us pick the best available '
        'for you.',
      ),
      findsNothing,
    );
    expect(find.text('Find the best seats together'), findsNothing);
    expect(find.byType(SeatLayerBestSeatsForm), findsOneWidget);
    expect(find.text('Find 2 best seats'), findsOneWidget);
  });

  testWidgets('the footer carries one full-width call to action', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Hold seats & checkout'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    // The foot's own gutters, and nothing narrower: one block on both widths.
    expect(
      tester.getSize(find.byType(SeatLayerBookButton)).width,
      390 - (SeatLayerSizeTokens.footPadX * 2),
    );
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
  });

  testWidgets('the footer holds its button while a seat card is open',
      (tester) async {
    // ONE button on the sheet, so it is the surface that owes the reason: a
    // grey button still reading "Hold seats & checkout" tells the buyer only
    // that pressing it achieved nothing.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
        controller: picker,
      ),
    );
    map.emit(_twoSeatSnapshot());
    await tester.pumpAndSettle();

    // The sheet is being exercised on its own, so the card the layout would
    // put up is reported by hand: it is the layout that tells the controller
    // which seat is still being asked about.
    picker.setConfirmCardSeat(picker.unansweredSeat);
    // It is reported from the chrome's own build and deliberately does not
    // notify, so the sheet is rebuilt the way the layout would rebuild it.
    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
        controller: picker,
      ),
    );
    await tester.pumpAndSettle();

    expect(picker.seatAwaitingConfirmation, isNotNull);
    // The card is the question; the footer keeps the label it had and simply
    // cannot be pressed until the card is answered. A sentence-button read as
    // a second control the buyer was being asked to press.
    expect(find.text('Confirm or cancel this seat'), findsNothing);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('a closed event states itself in the open tray', (tester) async {
    // Sales closed is a designed state, not a set of controls that quietly
    // stop working: the tray says so in words, above the form it refuses.
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(_salesClosedSnapshot());
    await tester.pumpAndSettle();

    expect(find.byType(SeatLayerPickerSalesClosedStatement), findsOneWidget);
    expect(find.text('Sales are closed'), findsOneWidget);
    expect(
      find.text('Ticket sales for this event have ended.'),
      findsOneWidget,
    );
  });

  testWidgets('the collapsed footer says when the event has stopped selling', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(_salesClosedSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Sales closed'), findsOneWidget);
    // The cart is still drawn — a buyer whose seats are in it has to see them
    // — but nothing on the foot offers a way on.
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Sales closed'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('six seats are six cards, and the sixth is scrolled to', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    map.emit(snapshotWithTicketCount(6));
    await tester.pumpAndSettle();

    // One card per ticket — no folding, no `6 × €25` multiplier — and the
    // total is said once, on the foot's own line.
    expect(find.byType(SeatLayerCartCard), findsNWidgets(6));
    expect(find.text('6 × €25'), findsNothing);
    expect(find.text('€150'), findsOneWidget);
  });

  testWidgets('removing a ticket is immediate and silent', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Stack(
          children: <Widget>[
            Align(alignment: Alignment.bottomCenter, child: _sheet()),
            // The undo bar rides the picker's own toast band.
            const Positioned.fill(child: SeatLayerPickerToastLayer()),
          ],
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump();

    expect(map.callsTo('picker.removeCartLine'), hasLength(1));
    // NOTHING IS SAID. The line is gone from the tray, the total has moved
    // and the checkout action has recounted; announcing it as well is telling
    // the buyer what they just did. The Undo it used to carry made a one-tap
    // action into a two-tap one and put a timer on the second tap.
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Undo'), findsNothing);
    expect(find.byType(SeatLayerPickerToastCard), findsNothing);
    // And never the host's Material messenger either.
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a read-only cart offers no removals', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
        options: const SeatLayerPickerOptions(readOnly: true),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byType(SeatLayerBestSeatsForm), findsNothing);
  });

  testWidgets('the collapsed sheet keeps its cards behind the handle',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: false),
        ),
      ),
    );
    map.emit(_tenDistinctRows());
    await tester.pumpAndSettle();

    // Collapsed is the footer block alone — total and button. A list that
    // unrolled itself every time a seat was added read as a panel the buyer
    // had not opened.
    final region = tester.getRect(
      find.ancestor(
        of: find.byType(SeatLayerCartList),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(region.height, 0);
    expect(find.text('10 tickets'), findsOneWidget);
  });

  testWidgets('the open cart shows three cards and a sliver of a fourth',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: true),
        ),
      ),
    );
    map.emit(_tenDistinctRows());
    await tester.pumpAndSettle();

    // Ten tickets used to be a sheet that grew until it owned the phone. The
    // cards are all in the tree; the box is what caps them.
    expect(find.byType(SeatLayerCartCard), findsNWidgets(10));
    final region = tester.getRect(
      find.ancestor(
        of: find.byType(SeatLayerCartList),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    // The box is the list's cap plus the tray's own foot under it: never a
    // whole extra card, so the fourth card is always cut.
    expect(
      region.height,
      greaterThanOrEqualTo(SeatLayerSizeTokens.cartPeekMaxHeight),
    );
    expect(
      region.height,
      lessThan(
        SeatLayerSizeTokens.cartPeekMaxHeight +
            SeatLayerSizeTokens.cartCardMinHeight,
      ),
    );

    // Three whole cards inside it, and the fourth cut by the box's own edge —
    // a sliver, so the list reads as scrollable rather than finished.
    final cards = tester
        .widgetList<SeatLayerCartCard>(find.byType(SeatLayerCartCard))
        .toList();
    Rect rect(int index) => tester.getRect(find.byWidget(cards[index]));
    expect(rect(2).bottom, lessThanOrEqualTo(region.bottom));
    expect(rect(3).top, lessThan(region.bottom));
    expect(rect(3).bottom, greaterThan(region.bottom));

    // And it really scrolls: the box used to clip its rows with nowhere to go.
    await tester.dragFrom(region.center, const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(rect(0).top, lessThan(region.top));
  });

  testWidgets('the handle is one pill on the sheet\'s own edge', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    Widget subject(bool expanded) => Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: expanded),
        );
    await tester.pumpWidget(pickerHarness(map, subject(false)));
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    // A 40 x 22 pill, half of it above the panel's top edge — a drawer's
    // handle, not a disc floating in a band of chrome.
    final handle = tester.getRect(_handle);
    expect(handle.width, SeatLayerSizeTokens.sheetHandleWidth);
    expect(handle.height, SeatLayerSizeTokens.sheetHandleHeight);
    final sheet = tester.getRect(find.byType(SeatLayerCartSheet));
    // The pill straddles the edge: its top half hangs over the map, above the
    // sheet's own box, so there is no strip of page ground under it.
    expect(handle.top, sheet.top - SeatLayerSizeTokens.sheetHandleOverhang);
    // The chevron is INSIDE it, in both states — one thing, not two.
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

    await tester.pumpWidget(pickerHarness(map, subject(true)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    expect(
        tester.getRect(_handle).height, SeatLayerSizeTokens.sheetHandleHeight);
  });

  testWidgets('the pill never carries the clock: the header does', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    Widget subject(bool expanded) => Align(
          alignment: Alignment.bottomCenter,
          child: _sheet(expanded: expanded),
        );
    await tester.pumpWidget(pickerHarness(map, subject(false)));
    map.emit(pickerSnapshot(holdOwner: 'picker'));
    await tester.pump();

    // Shut or open, no `m:ss` on the bar: the
    // header's hold pill is the picker's one clock, and the Continue pill
    // stays a button.
    expect(find.textContaining(RegExp(r'\d:\d\d')), findsNothing);
    await tester.pumpWidget(pickerHarness(map, subject(true)));
    await tester.pump();
    expect(find.textContaining(RegExp(r'\d:\d\d')), findsNothing);
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      for (final entry in <(String, Map<String, Object?>, bool)>[
        ('empty', bestAvailableSnapshot(), true),
        // The collapsed sheet is a designed state of its own now, so it is
        // recorded at both ends of the cart: nothing picked, and enough
        // tickets to reach the cap.
        ('empty_peek', bestAvailableSnapshot(), false),
        ('one', pickerSnapshot(), true),
        ('three', snapshotWithTicketCount(3), true),
        ('three_peek', snapshotWithTicketCount(3), false),
        ('six', snapshotWithTicketCount(6), true),
        ('many', _tenDistinctRows(), true),
        ('peek', pickerSnapshot(), false),
      ]) {
        testWidgets('cart sheet golden ${entry.$1} — ${brightness.name}', (
          tester,
        ) async {
          final map = FakePickerMap();
          addTearDown(map.dispose);
          usePhoneSurface(tester);

          await tester.pumpWidget(
            pickerHarness(
              map,
              Align(
                alignment: Alignment.bottomCenter,
                child: goldenSubject(_sheet(expanded: entry.$3)),
              ),
              platformBrightness: brightness,
            ),
          );
          map.emit(entry.$2);
          await tester.pumpAndSettle();

          await expectGolden(
            tester,
            'cart_sheet_${entry.$1}_${brightness.name}',
          );
        }, tags: goldenTag);
      }
    }
  }, skip: goldenSkip);
}

/// Ten tickets that share nothing, so each is its own run.
Map<String, Object?> _tenDistinctRows({int revision = 10}) {
  final snapshot = snapshotWithTicketCount(10, revision: revision);
  final cart = snapshot['cart']! as Map<String, Object?>;
  final selection = snapshot['selection']! as Map<String, Object?>;
  cart['items'] = <Object?>[
    for (var index = 0; index < 10; index++)
      <String, Object?>{
        ...(cart['items']! as List<Object?>)[index]! as Map<String, Object?>,
      },
  ];
  selection['seats'] = <Object?>[
    for (var index = 0; index < 10; index++)
      <String, Object?>{
        ...(selection['seats']! as List<Object?>)[index]!
            as Map<String, Object?>,
        'rowLabel': String.fromCharCode(65 + index),
      },
  ];
  return snapshot;
}

void _identityJoinTests() {
  testWidgets('a sectionless seat is named by its ticket type, once', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    // A chart with no sections: neither the line nor the seat behind it can
    // say where the seat is, so the ticket type has to.
    final snapshot = pickerSnapshot();
    final seats = (snapshot['selection']! as Map<String, Object?>)['seats']!
        as List<Object?>;
    for (final seat in seats.cast<Map<String, Object?>>()) {
      seat['sectionLabel'] = null;
    }
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(find.textContaining('Standard'), findsOneWidget);
    // And said once: the type that named the line is not read out again in
    // front of it.
    expect(
      tester
          .getSemantics(find.textContaining('Standard'))
          .label
          .contains('Standard, Standard'),
      isFalse,
    );
  });

  testWidgets('a line whose label differs still finds its seat', (
    tester,
  ) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(alignment: Alignment.bottomCenter, child: _sheet()),
      ),
    );
    final snapshot = pickerSnapshot();
    // A Best Available result arrives as a line the buyer never tapped: the
    // cart's inventory label and the seat's own label need not agree, but the
    // object id does.
    final cart = snapshot['cart']! as Map<String, Object?>;
    final items = (cart['items']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((item) => <String, Object?>{...item, 'label': 'West Gallery A-1'})
        .toList();
    cart['items'] = items;
    map.emit(snapshot);
    await tester.pumpAndSettle();

    expect(find.textContaining('Gallery'), findsWidgets);
    expect(find.textContaining('West Gallery A-1'), findsNothing);
  });
}

/// The handle pill, reached the way the buyer's eye reaches it: the box the
/// chevron sits inside.
final Finder _handle = find
    .ancestor(
      of: find.byIcon(Icons.keyboard_arrow_up_rounded),
      matching: find.byType(Container),
    )
    .first;

void _clockTests() {
  testWidgets('the collapsed sheet is its own content, and clips none of it',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(bottom: _safeBottom),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _sheet(expanded: false),
            ),
          ),
        ),
      ),
    );
    map.emit(pickerSnapshot(holdOwner: 'picker'));
    await pumpToRest(tester);

    // The collapsed height is the height of the card the phone actually draws
    // — the handle, the cart, the foot — plus whatever the platform reserves
    // at the bottom. Not a fixed peek that a taller block then overflows: the
    // web shipped a 50 px clip under a 58 px head and lost the lower edge of
    // every button on it.
    final sheet = tester.getRect(find.byType(SeatLayerCartSheet));
    final button = tester.getRect(find.byType(FilledButton));
    expect(button.top, greaterThan(sheet.top));
    expect(button.bottom, lessThanOrEqualTo(sheet.bottom - _safeBottom + .01));
    // And no `m:ss` anywhere on it: the header's hold
    // pill is the picker's one clock.
    expect(find.textContaining(RegExp(r'\d:\d\d')), findsNothing);
  });

  testWidgets('the handle is the cart\'s one named toggle, in both states',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    var expanded = false;
    await tester.pumpWidget(
      pickerHarness(
        map,
        StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: SeatLayerCartSheet(
                expanded: expanded,
                onExpandedChanged: (value) => setState(() => expanded = value),
                onCheckout: _noopCheckout,
              ),
            );
          },
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    // ONE named toggle, and the chevron that shows the state lives inside it:
    // two controls over one action read as two different things to press.
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    expect(find.bySemanticsLabel(SeatLayerStringTokens.expandCart),
        findsOneWidget);
    // Through the semantics ACTION, not a pixel: the head's own centre is
    // over the Continue button, and a rotor activates the node it just read.
    tester.semantics.performAction(
      find.semantics.byLabel(SeatLayerStringTokens.expandCart),
      SemanticsAction.tap,
    );
    await pumpToRest(tester);
    expect(expanded, isTrue);

    // Open, the same handle carries the other name and the chevron turns over.
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    expect(find.bySemanticsLabel(SeatLayerStringTokens.collapseCart),
        findsOneWidget);
    expect(
      find.bySemanticsLabel(SeatLayerStringTokens.expandCart),
      findsNothing,
    );
  }, semanticsEnabled: true);
}
