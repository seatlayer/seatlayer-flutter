import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_cart_bar.dart';
import 'package:seatlayer/src/picker/picker_cart_bar_rule.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  late FakePickerMap map;
  late SeatLayerPickerController picker;

  /// The sheet alone at the foot of a phone of [width], over a strip of
  /// [strip] points.
  Future<void> pump(
    WidgetTester tester,
    Map<String, Object?> snapshot, {
    double width = 393,
    double strip = 34,
    double text = 1,
    bool expanded = false,
    ValueChanged<bool>? onExpandedChanged,
    Widget? checkoutBar,
  }) async {
    tester.view.physicalSize = Size(width, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    await tester.pumpWidget(
      pickerHarness(
        map,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.only(bottom: strip),
              textScaler: TextScaler.linear(text),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SeatLayerCartSheet(
                expanded: expanded,
                onExpandedChanged: onExpandedChanged ?? (_) {},
                onCheckout: (_) async {},
                checkoutBar: checkoutBar,
              ),
            ),
          ),
        ),
        controller: picker,
        theme: const SeatLayerPickerThemeData(fontFamily: 'Roboto'),
      ),
    );
    map.emit(snapshot);
    await tester.pumpAndSettle();
  }

  Rect sheet(WidgetTester tester) =>
      tester.getRect(find.byType(SeatLayerCartSheet));
  final button = find.byType(FilledButton);

  for (final (width, strip, height) in <(double, double, double)>[
    (393, 34, 89),
    (360, 24, 79),
    (430, 34, 89),
    (393, 48, 103),
    (360, 0, 65),
  ]) {
    testWidgets('is one row of $height at $width over a strip of $strip',
        (tester) async {
      await pump(tester, pickerSnapshot(), width: width, strip: strip);
      expect(sheet(tester).height, height);
      expect(
        tester.getSize(button).width,
        lessThanOrEqualTo((width - 24) * PickerCartBarSize.buttonMaxShare + .01),
      );
      expect(
        sheet(tester).bottom - tester.getRect(button).bottom,
        strip > 10 ? strip : 10,
      );
      expect(tester.getRect(button).right, width - 12);
    });
  }

  testWidgets('puts the button under the words where its own do not fit',
      (tester) async {
    await pump(tester, pickerSnapshot(), width: 320, strip: 0, text: 2);
    final disc = tester.getRect(find.byType(PickerCartBarDisc));
    expect(tester.getRect(button).top, greaterThanOrEqualTo(disc.bottom));
    expect(tester.getSize(button).width, 296);
  });

  testWidgets('draws the circle at 28 and is pressed over 44', (tester) async {
    bool? asked;
    await pump(
      tester,
      pickerSnapshot(),
      onExpandedChanged: (value) => asked = value,
    );
    final disc = tester.getRect(find.byType(PickerCartBarDisc));
    expect(disc.size, const Size.square(44));
    expect(disc.left, 4);
    await tester.tapAt(disc.topLeft + const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(asked, isTrue);
  });

  testWidgets('the words open the list too', (tester) async {
    bool? asked;
    await pump(
      tester,
      pickerSnapshot(),
      onExpandedChanged: (value) => asked = value,
    );
    await tester.tap(find.byType(PickerCartBarWords));
    await tester.pumpAndSettle();
    expect(asked, isTrue);
  });

  testWidgets('a new seat closes the list, a new session does not',
      (tester) async {
    bool? asked;
    await pump(
      tester,
      pickerSnapshot(),
      expanded: true,
      onExpandedChanged: (value) => asked = value,
    );
    expect(asked, isNull);
    map.emit(snapshotWithTicketCount(3, revision: 5));
    await tester.pumpAndSettle();
    expect(asked, isFalse);
    expect(sheet(tester).height, 89);
  });

  testWidgets('says sales are closed, with the date and no button',
      (tester) async {
    final snapshot = pickerSnapshot();
    await pump(tester, <String, Object?>{
      ...snapshot,
      'event': <String, Object?>{
        ...snapshot['event']! as Map<String, Object?>,
        'salesClosed': true,
        'startsAtLabel': 'Sat 12 Dec, 19:30',
      },
    });
    expect(find.text('Sales are closed'), findsOneWidget);
    expect(find.text('Sat 12 Dec, 19:30'), findsOneWidget);
    expect(button, findsNothing);
    expect(sheet(tester).height, 89);
  });

  testWidgets('held seats can still be paid for after sales close',
      (tester) async {
    final snapshot = pickerSnapshot(holdOwner: 'picker');
    await pump(tester, <String, Object?>{
      ...snapshot,
      'event': <String, Object?>{
        ...snapshot['event']! as Map<String, Object?>,
        'salesClosed': true,
      },
    });
    final cta = find.widgetWithText(FilledButton, 'Continue to checkout');
    expect(tester.widget<FilledButton>(cta).onPressed, isNotNull);
    expect(find.text('Sales are closed'), findsNothing);
  });

  testWidgets('says Select seats, off, when nothing is left', (tester) async {
    final snapshot = bestAvailableSnapshot();
    final catalog = Map<String, Object?>.from(
      snapshot['catalog']! as Map<String, Object?>,
    );
    catalog['gaAreas'] = <Object?>[];
    catalog['categories'] = <Object?>[
      for (final category in catalog['categories']! as List<Object?>)
        <String, Object?>{
          ...category! as Map<String, Object?>,
          'available': 0,
          'free': 0,
        },
    ];
    await pump(tester, <String, Object?>{...snapshot, 'catalog': catalog});
    final cta = find.widgetWithText(FilledButton, 'Select seats');
    expect(tester.widget<FilledButton>(cta).onPressed, isNull);
  });

  testWidgets('nothing in it can be pressed while a seat card is asking',
      (tester) async {
    await pump(tester, pickerSnapshot());
    picker.setConfirmCardSeat(picker.unansweredSeat);
    map.emit(pickerSnapshot(revision: 2));
    await tester.pumpAndSettle();
    expect(picker.seatAwaitingConfirmation, isNotNull);
    expect(sheet(tester).height, 89);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: button, matching: find.byType(Opacity)).first,
          )
          .opacity,
      PickerCartBarSize.askingOpacity,
    );
  });

  testWidgets('an app\'s own button keeps the full width, under the words',
      (tester) async {
    await pump(
      tester,
      pickerSnapshot(),
      checkoutBar: const SizedBox(key: ValueKey<String>('own'), height: 50),
    );
    final own = tester.getRect(find.byKey(const ValueKey<String>('own')));
    expect(own.width, 393 - 24);
    expect(
      own.top,
      tester.getRect(find.byType(PickerCartBarDisc)).bottom +
          PickerCartBarSize.underGap,
    );
  });
}
