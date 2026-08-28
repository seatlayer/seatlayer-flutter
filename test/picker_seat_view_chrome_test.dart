// The 2D "View from here" panorama used to draw its own header line, caption
// and PREVIEW badge, and on a phone all three landed under the native price
// rail. The runtime now suppresses those three and reports the words on
// `evt seatView.changed` instead, so the disclosure is drawn once — natively,
// in the picker's palette, clear of the rail.
//
// Two gates, both on the runtime's own word: the suppression is only asked for
// of a runtime advertising `native-seat-view-chrome-v1`, and the native strip
// is only drawn by one. Neither side may guess.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_seat_view_chrome.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// What `evt seatView.changed` carries for a generated view, per the contract.
Map<String, Object?> _seatView({
  bool real = false,
  String? badge = 'Preview',
  String? title = 'View from Stalls D · C-6',
  String? caption = 'Illustration · about 18 m from stage',
  String? dragHint = 'Drag to look around · pinch or scroll to zoom',
}) =>
    <String, Object?>{
      'seatId': 'row-a:5',
      'title': title,
      'caption': caption,
      'badge': badge,
      'real': real,
      'generated': !real,
      'dragHint': dragHint,
    };

BundleInfo _seatViewBundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'native-seat-view-chrome-v1',
      ],
    );

Future<FakePickerMap> _pumpChrome(
  WidgetTester tester, {
  Map<String, Object?>? seatView,
  BundleInfo? bundle,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  final map = FakePickerMap(bundle: bundle ?? _seatViewBundle());
  addTearDown(map.dispose);
  usePhoneSurface(tester);
  const chrome = SeatLayerSeatViewChrome();
  await tester.pumpWidget(
    pickerHarness(
      map,
      golden
          ? goldenSubject(
              const SizedBox(height: 150, child: chrome),
            )
          : chrome,
      platformBrightness: brightness,
    ),
  );
  map.emit(pickerSnapshot());
  map.emitEvent(
    'seatView.changed',
    <String, Object?>{'seatView': seatView},
  );
  await tester.pumpAndSettle();
  return map;
}

void main() {
  group('the payload', () {
    test('every documented field is read', () {
      final view = SeatLayerSeatView.fromJson(_seatView())!;

      expect(view.seatId, 'row-a:5');
      expect(view.title, 'View from Stalls D · C-6');
      expect(view.caption, 'Illustration · about 18 m from stage');
      expect(view.badge, 'Preview');
      expect(view.real, isFalse);
      expect(view.generated, isTrue);
      expect(view.dragHint, isNotNull);
      expect(view.hasContent, isTrue);
    });

    test('a closed panorama is null, and so is anything that is not an object',
        () {
      expect(SeatLayerSeatView.fromJson(null), isNull);
      expect(SeatLayerSeatView.fromJson('closed'), isNull);
    });

    test('a payload with no words is not worth drawing chrome for', () {
      final view = SeatLayerSeatView.fromJson(
        <String, Object?>{'seatId': 'row-a:5'},
      )!;

      expect(view.hasContent, isFalse);
    });
  });

  group('the init suppression', () {
    test('a runtime that reports the words is asked to stop drawing them', () {
      final payload = SeatLayerBridgeProfile.picker().initPayload(
        SeatLayerConfiguration(event: 'ev_test'),
        bundle: _seatViewBundle(),
      );
      final chrome = payload['chrome']! as Map<String, Object?>;

      expect(chrome['seatViewTitle'], isFalse);
      expect(chrome['seatViewCaption'], isFalse);
      expect(chrome['seatViewBadge'], isFalse);
    });

    test('a runtime that does not is left drawing them', () {
      // Otherwise the disclosure leaves the screen entirely and the buyer is
      // looking at a drawn illustration with nothing saying so.
      final payload = SeatLayerBridgeProfile.picker().initPayload(
        SeatLayerConfiguration(event: 'ev_test'),
        bundle: nativeChromeBundle(),
      );
      final chrome = payload['chrome']! as Map<String, Object?>;

      expect(chrome.containsKey('seatViewTitle'), isFalse);
      expect(chrome.containsKey('seatViewCaption'), isFalse);
      expect(chrome.containsKey('seatViewBadge'), isFalse);
    });

    test('and neither is a runtime that has not handshook at all', () {
      final payload = SeatLayerBridgeProfile.picker().initPayload(
        SeatLayerConfiguration(event: 'ev_test'),
      );
      final chrome = payload['chrome']! as Map<String, Object?>;

      expect(chrome.containsKey('seatViewBadge'), isFalse);
      // The pieces this SDK always owns are still suppressed.
      expect(chrome['seatTooltip'], isFalse);
      expect(chrome['owner'], 'native');
    });

    test('the CLOSE button is never suppressed', () {
      final payload = SeatLayerBridgeProfile.picker().initPayload(
        SeatLayerConfiguration(event: 'ev_test'),
        bundle: _seatViewBundle(),
      );
      final chrome = payload['chrome']! as Map<String, Object?>;

      // A full-screen picture with no way out is a trap, and native chrome
      // does not reach inside the panorama to offer one.
      expect(chrome.keys.where((key) => key.toLowerCase().contains('close')),
          isEmpty);
    });
  });

  group('the strip', () {
    testWidgets('prints the runtime words and nothing of its own',
        (tester) async {
      await _pumpChrome(tester, seatView: _seatView());

      expect(find.text('View from Stalls D · C-6'), findsOneWidget);
      expect(find.text('Illustration · about 18 m from stage'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(
        find.text('Drag to look around · pinch or scroll to zoom'),
        findsOneWidget,
      );
    });

    testWidgets('an authored capture says so in the runtime\'s own word',
        (tester) async {
      await _pumpChrome(
        tester,
        seatView: _seatView(real: true, badge: 'Real 360°'),
      );

      // Which badge it is comes off `real`, never off matching a translated
      // word; the word itself is printed exactly as it arrived.
      expect(find.text('Real 360°'), findsOneWidget);
    });

    testWidgets('a closed panorama takes the strip with it', (tester) async {
      final map = await _pumpChrome(tester, seatView: _seatView());
      expect(find.text('Preview'), findsOneWidget);

      map.emitEvent(
        'seatView.changed',
        <String, Object?>{'seatView': null},
        sequence: 2,
      );
      await tester.pumpAndSettle();

      expect(find.text('Preview'), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('a runtime that never said it hands the words over draws none',
        (tester) async {
      // It is still drawing its own; a native strip here would double them.
      await _pumpChrome(
        tester,
        seatView: _seatView(),
        bundle: nativeChromeBundle(),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('and neither does a runtime that never handshook',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      await tester.pumpWidget(
        pickerHarness(map, const SeatLayerSeatViewChrome()),
      );
      map.emitEvent(
        'seatView.changed',
        <String, Object?>{'seatView': _seatView()},
      );
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('the strip never takes a touch away from the picture',
        (tester) async {
      await _pumpChrome(tester, seatView: _seatView());

      // Every gesture over the panorama is the panorama's; a strip that ate a
      // drag would freeze the picture under the buyer's finger.
      final ignoring = tester.widgetList<IgnorePointer>(
        find.descendant(
          of: find.byType(SeatLayerSeatViewChrome),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignoring.any((widget) => widget.ignoring), isTrue);
    });

    testWidgets('a title alone is a strip; nothing at all is not',
        (tester) async {
      await _pumpChrome(
        tester,
        seatView: _seatView(caption: null, badge: null, dragHint: null),
      );

      expect(find.text('View from Stalls D · C-6'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });

  // Both sides are recorded, and both are expected to be the SAME picture:
  // this chrome stands over a photograph of unknown brightness and takes the
  // immersive palette whichever side the picker is painted on, exactly as the
  // 3D scene's chrome does. The pair is what would catch a day the light one
  // started following the resolved theme instead.
  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('seat view chrome golden — ${brightness.name}',
          (tester) async {
        await _pumpChrome(
          tester,
          seatView: _seatView(),
          brightness: brightness,
          golden: true,
        );

        await expectGolden(tester, 'seat_view_chrome_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}
