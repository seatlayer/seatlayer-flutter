// The connection status on every phone in the matrix: on the map's top line
// after the test badge and short of the Map/3D control, or under them across
// the map's whole width; never under the system's bars.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_connection_status.dart';

import 'phone_matrix_harness.dart';

const _card = ValueKey<String>('seatlayer-connection-status');

void _expectStatusPlaced(WidgetTester tester, Phone phone) {
  expect(find.byKey(_card), findsOneWidget);
  final card = tester.getRect(find.byKey(_card));
  final map = tester.getRect(find.byType(SeatLayerPickerConnectionStatus));
  final safe = phone.safe;
  expect(card.left, greaterThanOrEqualTo(safe.left - .5), reason: '$card');
  expect(card.right, lessThanOrEqualTo(safe.right + .5), reason: '$card');
  expect(card.top, greaterThanOrEqualTo(map.top), reason: '$card in $map');
  expect(card.bottom, lessThanOrEqualTo(map.bottom), reason: '$card in $map');

  for (final other in <Finder>[
    find.byType(SeatLayerPickerViewModeControl),
    find.byType(SeatLayerPickerTestModeIndicator),
  ]) {
    for (final element in other.evaluate()) {
      final box = element.renderObject! as RenderBox;
      if (!box.hasSize || box.size.isEmpty) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      expect(
        card.intersect(rect).isEmpty ||
            card.intersect(rect).width <= 0 ||
            card.intersect(rect).height <= 0,
        isTrue,
        reason: 'status $card covers ${element.widget.runtimeType} $rect',
      );
    }
  }

  // Under the top line it takes the map's whole width, inside its margins.
  final control = find.byType(SeatLayerPickerViewModeControl);
  if (control.evaluate().isNotEmpty) {
    final switchRect = tester.getRect(control);
    if (card.top >= switchRect.bottom) {
      expect(card.left - map.left, closeTo(12, .5));
      expect(map.right - card.right, closeTo(12, .5));
    } else {
      // Beside the switch only when every line fits whole on one line.
      final words = find.descendant(
        of: find.byKey(_card),
        matching: find.byType(RichText),
      );
      for (final element in words.evaluate()) {
        final text = element.widget as RichText;
        final oneLine = TextPainter(
          text: text.text,
          textDirection: TextDirection.ltr,
          textScaler: text.textScaler,
        )..layout();
        expect(
          (element.renderObject! as RenderBox).size.height,
          lessThan(oneLine.height * 1.5),
          reason: 'status beside the switch wraps: ${text.text.toPlainText()}',
        );
        oneLine.dispose();
      }
    }
  }
}

void main() {
  for (final connection in const <String>['offline', 'reconnecting']) {
    group('$connection, upright', () {
      for (final phone in uprightPhones) {
        for (final textScale in const <double>[1, 1.3, 2]) {
          for (final state in const <PhoneState>[
            PhoneState.ready,
            PhoneState.cart,
          ]) {
            testWidgets('$phone, text $textScale, ${state.name}',
                (tester) async {
              await pumpPhone(
                tester,
                phone,
                state,
                textScale: textScale,
                connection: connection,
              );
              if (connection == 'reconnecting') {
                // A line that only retries says so after ten seconds.
                await tester.pump(const Duration(seconds: 8));
                await tester.pump(const Duration(milliseconds: 500));
              }
              _expectStatusPlaced(tester, phone);
            });
          }
        }
      }
    });
  }

  group('offline, sideways', () {
    for (final phone in sidewaysPhones) {
      for (final textScale in const <double>[1, 1.3, 2]) {
        testWidgets('$phone, text $textScale', (tester) async {
          await pumpPhone(
            tester,
            phone,
            PhoneState.cart,
            textScale: textScale,
            connection: 'offline',
          );
          _expectStatusPlaced(tester, phone);
        });
      }
    }
  });

  group('offline, right to left', () {
    for (final phone in uprightPhones.where((phone) => phone.name == '390')) {
      for (final textScale in const <double>[1, 2]) {
        testWidgets('$phone, text $textScale', (tester) async {
          await pumpPhone(
            tester,
            phone,
            PhoneState.cart,
            textScale: textScale,
            locale: const Locale('ar'),
            connection: 'offline',
          );
          _expectStatusPlaced(tester, phone);
          final card = tester.getRect(find.byKey(_card));
          final map = tester
              .getRect(find.byType(SeatLayerPickerConnectionStatus));
          // The start side is the right.
          expect(map.right - card.right, closeTo(12, .5));
        });
      }
    }
  });
}
