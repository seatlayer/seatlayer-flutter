// Pictures of the event picker on the phones in the matrix.
//
// Full screens: the page, its safe areas and every piece of chrome, with the
// map as a plain placeholder. The layout checks for the same screens are
// `phone_matrix_test.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_matrix_harness.dart';
import 'picker_widget_harness.dart';

String _scale(double textScale) =>
    textScale == 1 ? '' : '_t${(textScale * 10).round()}';

void main() {
  Future<void> shoot(
    WidgetTester tester,
    String name,
    Phone phone,
    PhoneState state, {
    Brightness brightness = Brightness.light,
    double textScale = 1,
    Locale locale = const Locale('en'),
  }) async {
    await pumpPhone(
      tester,
      phone,
      state,
      brightness: brightness,
      textScale: textScale,
      locale: locale,
      golden: true,
    );
    await expectGolden(tester, name);
  }

  group('phone matrix', () {
    for (final phone in uprightPhones) {
      for (final state in const <PhoneState>[
        PhoneState.card,
        PhoneState.cart
      ]) {
        for (final brightness in Brightness.values) {
          for (final textScale in const <double>[1, 1.3]) {
            final name = 'phone_${phone.name}_${state.name}_'
                '${brightness.name}${_scale(textScale)}';
            testWidgets(name, tags: goldenTag, (tester) async {
              await shoot(
                tester,
                name,
                phone,
                state,
                brightness: brightness,
                textScale: textScale,
              );
            });
          }
        }
      }
    }

    // The main buttons at double text: Add seat, the dock bar, the cart's foot.
    final phone390 = uprightPhones.firstWhere((phone) => phone.name == '390');
    for (final state in const <PhoneState>[
      PhoneState.card,
      PhoneState.cart,
      PhoneState.cartOpen,
    ]) {
      for (final brightness in Brightness.values) {
        final name = 'phone_390_${state.name}_${brightness.name}_t20';
        testWidgets(name, tags: goldenTag, (tester) async {
          await shoot(
            tester,
            name,
            phone390,
            state,
            brightness: brightness,
            textScale: 2,
          );
        });
      }
    }

    for (final state in const <PhoneState>[PhoneState.card, PhoneState.cart]) {
      for (final brightness in Brightness.values) {
        final name = 'phone_390_ar_${state.name}_${brightness.name}';
        testWidgets(name, tags: goldenTag, (tester) async {
          await shoot(
            tester,
            name,
            phone390,
            state,
            brightness: brightness,
            locale: const Locale('ar'),
          );
        });
      }
    }

    for (final phone in sidewaysPhones) {
      for (final state in const <PhoneState>[
        PhoneState.ready,
        PhoneState.cart
      ]) {
        final name = 'phone_${phone.name}_${state.name}_light';
        testWidgets(name, tags: goldenTag, (tester) async {
          await shoot(tester, name, phone, state);
        });
      }
    }
  }, skip: goldenSkip);
}
