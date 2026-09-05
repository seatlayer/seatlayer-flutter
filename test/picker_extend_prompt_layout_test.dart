// Where the "Need more time?" card is offered, and where it is not.
//
// Decision of 2026-09-04: the phone shows ONE timer, the header's hold
// countdown. A card that arrives over the map inside the last minute is a
// second decision at the worst moment, and a countdown that can always be
// pushed back is not a deadline. The card stays a public component and a host
// opt-in, and the wide layout keeps it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_states.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// The layout with the WebView replaced, so the composition can be tested
/// without a platform view.
Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(),
      ),
    );

/// [pickerSnapshot] holding a cart that runs out in [seconds].
Map<String, Object?> _expiringSnapshot(int seconds) {
  final snapshot = pickerSnapshot(holdOwner: 'picker');
  return <String, Object?>{
    ...snapshot,
    'hold': <String, Object?>{
      'active': true,
      'expiresAt': seatLayerPickerNow()
          .add(Duration(seconds: seconds))
          .millisecondsSinceEpoch
          .toDouble(),
      'ownership': 'picker',
    },
  };
}

void _useWideSurface(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 900);
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the phone leaves the last minute to the header clock',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_expiringSnapshot(48));
    await pumpToRest(tester);

    expect(find.byType(SeatLayerPickerExtendHoldPrompt), findsNothing);
    // The one timer the buyer is given is still running.
    expect(find.byType(SeatLayerPickerHoldCountdown), findsOneWidget);
  });

  testWidgets('a host can ask for the card back on the phone', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        _layout(),
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(showExtendHoldPrompt: true),
        ),
      ),
    );
    map.emit(_expiringSnapshot(48));
    await pumpToRest(tester);

    expect(find.byType(SeatLayerPickerExtendHoldPrompt), findsOneWidget);
    expect(find.text('+5 min'), findsOneWidget);
  });

  testWidgets('the wide layout keeps it', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    _useWideSurface(tester);

    await tester.pumpWidget(pickerHarness(map, _layout()));
    map.emit(_expiringSnapshot(48));
    await pumpToRest(tester);

    expect(find.byType(SeatLayerPickerExtendHoldPrompt), findsOneWidget);
    expect(find.text('+5 min'), findsOneWidget);
  });

  test('the resolved default is off on the phone and on when wide', () {
    const auto = SeatLayerPickerChromeOptions();
    expect(auto.extendHoldPromptFor(phone: true), isFalse);
    expect(auto.extendHoldPromptFor(phone: false), isTrue);
    const forced = SeatLayerPickerChromeOptions(showExtendHoldPrompt: true);
    expect(forced.extendHoldPromptFor(phone: true), isTrue);
    const off = SeatLayerPickerChromeOptions(showExtendHoldPrompt: false);
    expect(off.extendHoldPromptFor(phone: false), isFalse);
  });
}
