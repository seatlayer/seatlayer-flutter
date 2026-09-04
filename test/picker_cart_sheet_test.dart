import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_cart_list.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_states.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

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

  testWidgets('the peek states the cart and the way on, and nothing else', (
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

    // The count on the left, the money on the button — never the same number
    // twice on one screen.
    expect(find.text('1 ticket'), findsOneWidget);
    expect(find.text('1 ticket · €25'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('€25'), findsOneWidget);
    // The tray form is the only way into best seats.
    expect(find.text('Best seats'), findsNothing);
    expect(
      _sheetHeight(tester),
      SeatLayerSizeTokens.peekHeight + SeatLayerSizeTokens.peekClockLift,
    );
  });

  testWidgets('an empty peek offers the cheapest ticket, not a button', (
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

    expect(find.text('From €25'), findsOneWidget);
    expect(find.textContaining('Continue'), findsNothing);
    // A price with nothing to do about it is not an offer; the button is.
    expect(find.text('Find seats'), findsOneWidget);

    // The AMOUNT is the fact and the word around it is the caption, so the
    // money is printed large in the text ink and `From` small and muted.
    final line = tester.widget<Text>(find.text('From €25')).textSpan!;
    final sizes = <String, double?>{};
    final colours = <String, Color?>{};
    line.visitChildren((span) {
      if (span is TextSpan && span.text != null) {
        sizes[span.text!] = span.style?.fontSize;
        colours[span.text!] = span.style?.color;
      }
      return true;
    });
    expect(sizes['€25'], 19);
    expect(sizes['From '], isNull, reason: 'the caption keeps the base style');
    expect(line.style!.fontSize, 12);
    expect(
      line.style!.color,
      const SeatLayerPickerThemeData.light().mutedText,
    );
    expect(colours['€25'], const SeatLayerPickerThemeData.light().text);
  });

  testWidgets('the empty peek offers a full-size way into the finder', (
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

    final pill = find.ancestor(
      of: find.text('Find seats'),
      matching: find.byType(InkWell),
    );
    expect(
      tester.getSize(pill.first).height,
      SeatLayerSizeTokens.peekButtonHeight,
    );

    await tester.tap(find.text('Find seats'));
    await tester.pump();
    expect(expanded, isTrue);
  });

  testWidgets('the finder pill is withheld where the form would be refused', (
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
      expect(find.text('Find seats'), findsNothing);
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
      tester.getSize(find.widgetWithText(FilledButton, 'Continue')).height,
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
    expect(
      _sheetHeight(tester),
      SeatLayerSizeTokens.peekHeight +
          SeatLayerSizeTokens.peekClockLift +
          _safeBottom,
    );
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
    // The safe area stays reserved; only the words in it go.
    expect(
      _sheetHeight(tester),
      SeatLayerSizeTokens.peekHeight +
          SeatLayerSizeTokens.peekClockLift +
          _safeBottom,
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

    // Ten seats in one row are one run, so the sheet does not grow for them.
    map.emit(snapshotWithTicketCount(10, revision: 20));
    await tester.pumpAndSettle();
    expect(_sheetHeight(tester), oneTicket);
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
    expect(tester.getSize(find.byType(SeatLayerBookButton)).width, 390);
    expect(find.text('Powered by SeatLayer'), findsOneWidget);
  });

  testWidgets('the collapsed pill says why it cannot be pressed', (
    tester,
  ) async {
    // The card standing over the map is the reason, and the whole sheet is
    // dimmed and inert behind it, so the pill is left as the buyer last read
    // it — `Continue · €25`, down — exactly as the web picker leaves it. The
    // footer button, which is the surface that owes a reason, states one.
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerAdaptiveLayout(onCheckout: _noopCheckout),
        controller: picker,
      ),
    );
    map.emit(_twoSeatSnapshot());
    // A confirm card is on screen throughout, and its invitation breathes
    // until it is answered, so these waits are bounded rather than settles.
    await pumpToRest(tester);

    // One seat answered for, one still being asked about: the cart has
    // something in it, so the pill is drawn — and it cannot be pressed.
    await tester.tap(find.text('Add seat'));
    await pumpToRest(tester);
    expect(picker.seatAwaitingConfirmation?.label, 'A-1');
    expect(find.text('1 ticket'), findsOneWidget);

    // The peek keeps its own line, money and all.
    final pill = find
        .ancestor(
            of: find.text('Continue'), matching: find.byType(FilledButton))
        .first;
    expect(pill, findsOneWidget);
    expect(
      find.descendant(of: pill, matching: find.text('€25')),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(pill).onPressed, isNull);
    // And it does not repeat the reason the footer is stating.
    expect(find.text('Confirm or cancel this seat'), findsNothing);
  });

  testWidgets('the footer states the card the peek does not', (tester) async {
    // The same situation, read from the open sheet: here the button IS the
    // thing the buyer would press, so it says why it will not answer.
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
    expect(find.text('Confirm or cancel this seat'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm or cancel this seat'),
          )
          .onPressed,
      isNull,
    );
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

  testWidgets('the collapsed pill says when the event has stopped selling', (
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
    expect(find.text('€25'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Sales closed'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('six seats in one row collapse to one line', (tester) async {
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

    expect(find.textContaining('1–6'), findsOneWidget);
    expect(find.text('6 × €25'), findsOneWidget);
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

  testWidgets('a long list collapses behind one more control', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
          alignment: Alignment.bottomCenter,
          child: SeatLayerCartSheet(
            expanded: true,
            onExpandedChanged: (_) {},
            onCheckout: _noopCheckout,
            // One run per line, so the collapse rule is what is under test.
            cartList: const SeatLayerCartList(),
          ),
        ),
      ),
    );
    map.emit(_tenDistinctRows());
    await tester.pumpAndSettle();

    expect(find.text('+6 more'), findsOneWidget);
    await tester.tap(find.text('+6 more'));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('the head is fifty-eight points shut and thirty-six open', (
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

    // The grabber overlaps into the head rather than taking a row of its own,
    // which is what keeps the collapsed bar to one row of chrome.
    expect(_grabber(tester), isTrue);
    expect(
      _sheetHeight(tester),
      SeatLayerSizeTokens.peekHeight + SeatLayerSizeTokens.peekClockLift,
    );

    await tester.pumpWidget(pickerHarness(map, subject(true)));
    await tester.pumpAndSettle();
    // Open, the head gives its height back to the tickets underneath.
    expect(
      tester.getSize(find.byIcon(Icons.keyboard_arrow_up_rounded)).height,
      lessThanOrEqualTo(50),
    );
  });

  testWidgets('a running hold counts down on the pill, and only when shut', (
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

    expect(find.textContaining(':'), findsOneWidget);

    // Open, the clock goes: the header carries it, and the sheet below
    // carries the money. Saying it three times is three chances to disagree.
    await tester.pumpWidget(pickerHarness(map, subject(true)));
    await tester.pump();
    expect(find.textContaining(':'), findsNothing);
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      for (final entry in <(String, Map<String, Object?>, bool)>[
        ('empty', bestAvailableSnapshot(), true),
        ('one', pickerSnapshot(), true),
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

/// Whether the head is drawing the 35 x 4 grabber.
///
/// It is a private widget, so the test reaches it the way the buyer's eye
/// does: by its measured size.
bool _grabber(WidgetTester tester) => tester
    .widgetList<SizedBox>(find.byType(SizedBox))
    .any((box) => box.width == 35 && box.height == 4);

void _clockTests() {
  testWidgets('a pill carrying the clock gets room under the grabber',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        Align(
            alignment: Alignment.bottomCenter, child: _sheet(expanded: false)),
      ),
    );
    map.emit(pickerSnapshot(holdOwner: 'picker'));
    await pumpToRest(tester);

    // The head's own height, plus the lift that keeps the way on off the
    // way up.
    expect(
      _sheetHeight(tester),
      SeatLayerSizeTokens.peekHeight + SeatLayerSizeTokens.peekClockLift,
    );
    final pill = tester.getRect(find.widgetWithText(FilledButton, 'Continue'));
    final sheet = tester.getRect(find.byType(SeatLayerCartSheet));
    expect(pill.top - sheet.top, greaterThanOrEqualTo(8));
    // AND ITS WHOLE HEIGHT IS INSIDE THE BAR. The web shipped a bar whose
    // clip was shorter than its head, which cut the bottom off the very
    // button the bar exists for. Here the head IS the collapsed height, so
    // there is one number and nothing to disagree with — this pins it.
    expect(pill.height, SeatLayerSizeTokens.peekButtonHeight);
    expect(pill.bottom, lessThanOrEqualTo(sheet.bottom + .01));
  });

  testWidgets('the collapsed bar is exactly its head plus the safe area',
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
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    // One number: the head's own height plus the lift, plus whatever the
    // platform reserves at the bottom. Nothing clips it to something shorter.
    final sheet = tester.getRect(find.byType(SeatLayerCartSheet));
    expect(
      sheet.height,
      SeatLayerSizeTokens.peekHeight +
          SeatLayerSizeTokens.peekClockLift +
          _safeBottom,
    );
    // And the way on is wholly inside it, top and bottom.
    final pill = tester.getRect(find.widgetWithText(FilledButton, 'Continue'));
    expect(pill.top, greaterThanOrEqualTo(sheet.top));
    expect(pill.bottom, lessThanOrEqualTo(sheet.bottom + .01));
  });

  testWidgets('the collapsed bar drops the chevron and answers as the toggle',
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
                onExpandedChanged: (value) =>
                    setState(() => expanded = value),
                onCheckout: _noopCheckout,
              ),
            );
          },
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await pumpToRest(tester);

    // The arrow only took width from the one button the bar exists for.
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNothing);
    // The head still answers, and a screen reader still finds it: hiding the
    // chevron would otherwise have taken the cart's only named toggle with it.
    expect(find.bySemanticsLabel(SeatLayerStringTokens.expandCart), findsOneWidget);
    // Through the semantics ACTION, not a pixel: the head's own centre is
    // over the Continue button, and a rotor activates the node it just read.
    tester.semantics.performAction(
      find.semantics.byLabel(SeatLayerStringTokens.expandCart),
      SemanticsAction.tap,
    );
    await pumpToRest(tester);
    expect(expanded, isTrue);

    // Open, the chevron is back and it is the one that carries the name.
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    expect(find.bySemanticsLabel(SeatLayerStringTokens.collapseCart), findsOneWidget);
    expect(
      find.bySemanticsLabel(SeatLayerStringTokens.expandCart),
      findsNothing,
    );
  }, semanticsEnabled: true);
}
