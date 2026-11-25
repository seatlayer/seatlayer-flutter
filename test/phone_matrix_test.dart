// The event picker lays out and works on every phone in the matrix.
//
// See `phone_matrix_harness.dart` for the phones and the checks. Pictures of
// the same screens are `phone_matrix_golden_test.dart`.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
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

  // The longest thing the error bar says: a title and the line under it. Held
  // sideways with the cart open has no layout of its own yet (below).
  group('a refused action', () {
    const refusal = SeatLayerError.bridge(
      BridgeErrorPayload(
        code: 'buyer_access_origin_mismatch',
        message: 'buyer_access_origin_mismatch',
        details: <String, Object?>{'status': 403},
      ),
    );
    const states = <PhoneState>[
      PhoneState.ready,
      PhoneState.cart,
      PhoneState.cartOpen,
    ];
    for (final phone in <Phone>[...uprightPhones, ...sidewaysPhones]) {
      final sideways = sidewaysPhones.contains(phone);
      for (final textScale in <double>[1, 1.3, if (!sideways) 2]) {
        for (final state in states) {
          if (sideways && state == PhoneState.cartOpen) continue;
          for (final tag in const <String>['en', 'el', 'ar']) {
            testWidgets('$phone, text $textScale, ${state.name}, $tag',
                (tester) async {
              final semantics = tester.ensureSemantics();
              final strings = await pumpPhone(
                tester,
                phone,
                state,
                textScale: textScale,
                locale: Locale(tag),
                actionError: refusal,
              );
              expectPhoneLayout(tester, phone, strings);
              for (final sentence in <String>[
                strings.accessUnverifiedTitle,
                strings.accessUnverifiedCopy,
              ]) {
                final text = tester.renderObject<RenderParagraph>(
                  find.descendant(
                    of: find.text(sentence),
                    matching: find.byType(RichText),
                  ),
                );
                expect(text.didExceedMaxLines, isFalse, reason: sentence);
              }
              expect(find.textContaining('mismatch'), findsNothing);
              semantics.dispose();
            });
          }
        }
      }
    }
  });

  // Back from checkout with a seat to change: the words, and the way out.
  group('a refused action with a way out', () {
    const refusal = SeatLayerError.bridge(
      BridgeErrorPayload(
        code: 'hold_owned_by_host',
        message: 'the active hold belongs to the host',
      ),
    );
    for (final phone in <Phone>[...uprightPhones, ...sidewaysPhones]) {
      final sideways = sidewaysPhones.contains(phone);
      for (final textScale in <double>[1, 1.3, if (!sideways) 2]) {
        for (final state in <PhoneState>[
          PhoneState.cart,
          if (!sideways) PhoneState.cartOpen,
        ]) {
          for (final tag in const <String>['en', 'el', 'ar']) {
            testWidgets('$phone, text $textScale, ${state.name}, $tag',
                (tester) async {
              final semantics = tester.ensureSemantics();
              final strings = await pumpPhone(
                tester,
                phone,
                state,
                textScale: textScale,
                locale: Locale(tag),
                actionError: refusal,
                inCheckout: true,
              );
              expectPhoneLayout(tester, phone, strings);
              expect(find.text(strings.holdInCheckoutTitle), findsOneWidget);
              expect(find.text(strings.holdInCheckoutBody), findsOneWidget);
              final button = find.widgetWithText(
                OutlinedButton,
                strings.releaseAndChangeSeats,
              );
              // The whole of it, where a press reaches it.
              final rect = tester.getRect(button);
              final render = tester.renderObject(button);
              for (final at in <Offset>[
                rect.center,
                rect.topCenter + const Offset(0, 5),
                rect.bottomCenter - const Offset(0, 5),
              ]) {
                final path = tester.hitTestOnBinding(at).path;
                expect(
                  path.any((entry) => identical(entry.target, render)),
                  isTrue,
                  reason: 'a press at $at, the button is at $rect',
                );
              }
              final label = tester.renderObject<RenderParagraph>(
                find.descendant(
                  of: find.text(strings.releaseAndChangeSeats),
                  matching: find.byType(RichText),
                ),
              );
              expect(label.didExceedMaxLines, isFalse);
              semantics.dispose();
            });
          }
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
                // Held sideways with the cart open, the sheet leaves little of
                // the map and cuts the Map/3D switch. This state has no layout
                // of its own yet.
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
