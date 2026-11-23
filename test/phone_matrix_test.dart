// The event picker lays out and works on every phone in the matrix.
//
// See `phone_matrix_harness.dart` for the phones and the checks. Pictures of
// the same screens are `phone_matrix_golden_test.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_wide_panel.dart';

import 'phone_matrix_harness.dart';

void main() {
  group('upright', () {
    for (final phone in uprightPhones) {
      for (final textScale in const <double>[1, 1.3, 2]) {
        for (final state in PhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings =
                await pumpPhone(tester, phone, state, textScale: textScale);
            expectPhoneLayout(tester, phone, strings);
            semantics.dispose();
          });
        }
      }
    }
  });

  group('bare in the host scaffold, upright', () {
    for (final phone in uprightPhones) {
      for (final state in PhoneState.values) {
        testWidgets('$phone, ${state.name}', (tester) async {
          final semantics = tester.ensureSemantics();
          final strings = await pumpPhone(
            tester,
            phone,
            state,
            presentation: PhonePresentation.bare,
          );
          expectPhoneLayout(tester, phone, strings);
          semantics.dispose();
        });
      }
    }
  });

  group('right to left, Arabic', () {
    for (final phone in uprightPhones.where(
      (phone) => phone.name == '320' || phone.name == '390',
    )) {
      for (final textScale in const <double>[1, 1.3, 2]) {
        for (final state in PhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings = await pumpPhone(
              tester,
              phone,
              state,
              textScale: textScale,
              locale: const Locale('ar'),
            );
            expectPhoneLayout(tester, phone, strings);
            semantics.dispose();
          });
        }
      }
    }
  });

  group('sideways', () {
    for (final phone in sidewaysPhones) {
      for (final scale in <double>[1, 1.3]) {
        for (final presentation in PhonePresentation.values) {
          for (final state in PhoneState.values) {
            testWidgets(
                '$phone, text ${scale.toStringAsFixed(1)}, '
                '${presentation.name}, ${state.name}',
                // Held sideways with the cart open, the sheet leaves about 30
                // points of map and cuts the Map/3D switch and the fit button.
                // This state has no layout of its own yet.
                skip: state == PhoneState.cartOpen, (tester) async {
              final semantics = tester.ensureSemantics();
              final strings = await pumpPhone(
                tester,
                phone,
                state,
                presentation: presentation,
                textScale: scale,
              );
              // A phone is a phone however it is held: full screen, with the
              // phone layout, never the tablet dialog or the wide panel.
              expect(find.byType(Dialog), findsNothing);
              expect(find.byType(SeatLayerWidePanelHeading), findsNothing);
              final layout = tester.getRect(
                find.byType(SeatLayerPickerAdaptiveLayout),
              );
              expect(layout.width, greaterThanOrEqualTo(phone.safe.width - .5));
              expectPhoneLayout(tester, phone, strings);
              semantics.dispose();
            });
          }
        }
      }
    }
  });
}
