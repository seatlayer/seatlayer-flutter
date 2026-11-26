// The header's mark: the event's first letter on the accent square, where the
// organizer has no logo.
//
// The letter is drawn to the square's size. At a large text size it grew with
// the text while the square did not, and ran out of the square's bottom.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

const SeatLayerResolvedPickerTheme _theme = SeatLayerResolvedPickerTheme(
  brightness: Brightness.light,
  background: SeatLayerLightTokens.background,
  surface: SeatLayerLightTokens.surface,
  text: SeatLayerLightTokens.text,
  mutedText: SeatLayerLightTokens.mutedText,
  accent: SeatLayerLightTokens.accent,
  onAccent: SeatLayerLightTokens.onAccent,
  divider: SeatLayerLightTokens.divider,
  error: SeatLayerLightTokens.error,
  warning: SeatLayerLightTokens.warning,
  radius: SeatLayerRadiusTokens.base,
  buttonRadius: SeatLayerRadiusTokens.button,
  layout: SeatLayerPickerLayout(),
);

void main() {
  for (final scale in const <double>[1, 1.3, 2, 3]) {
    for (final compact in const <bool>[true, false]) {
      testWidgets(
          'the letter stays inside its square at text $scale'
          '${compact ? ' on a phone' : ''}', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(scale),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topCenter,
                child: SeatLayerHeaderBar(
                  theme: _theme,
                  strings: const SeatLayerPickerStrings(),
                  markName: 'Opening Night',
                  title: 'Opening Night',
                  compact: compact,
                ),
              ),
            ),
          ),
        );
        final letter = find.text('O');
        expect(letter, findsOneWidget);
        final square = tester.getRect(
          find
              .ancestor(of: letter, matching: find.byType(DecoratedBox))
              .first,
        );
        // The paragraph's own box is held to the square, so measure the
        // letter as it is set, at the size the text scaler gives it.
        final glyphs = tester.renderObject<RenderParagraph>(letter);
        final set = TextPainter(
          text: glyphs.text,
          textScaler: glyphs.textScaler,
          textDirection: TextDirection.ltr,
        )..layout();
        addTearDown(set.dispose);
        expect(
          set.height,
          lessThanOrEqualTo(square.height),
          reason: 'the letter is ${set.size}, its square ${square.size}',
        );
        expect(set.width, lessThanOrEqualTo(square.width));
      });
    }
  }
}
