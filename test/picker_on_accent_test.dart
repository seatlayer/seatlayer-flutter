// A host brands the picker with one colour. The ink on it has to be readable,
// and it has to be the ink the brand itself would use.
//
// Pairing a host-supplied accent with a FIXED ink fails silently: the button
// renders, nothing throws, and the label is simply unreadable on a pale brand.
// Picking whichever of black and white scores higher fails differently and
// just as visibly: a brand red scores higher on black, so every accented
// surface came back with black text on it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

/// The WCAG 2.x contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Resolve the picker palette for a host theme, with no organizer branding.
Future<SeatLayerResolvedPickerTheme> _resolve(
  WidgetTester tester,
  SeatLayerPickerThemeData? theme, {
  Brightness brightness = Brightness.light,
}) async {
  late SeatLayerResolvedPickerTheme resolved;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          resolved = resolveSeatLayerPickerTheme(
            context,
            const SeatLayerPickerState.initializing(),
            theme,
            brightness: brightness,
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return resolved;
}

void main() {
  testWidgets('a pale host accent gets dark ink, not the preset white',
      (tester) async {
    // #FFD400 is a real brand yellow. White on it is 1.3:1 — invisible.
    const brand = Color(0xFFFFD400);
    final resolved =
        await _resolve(tester, const SeatLayerPickerThemeData(accent: brand));

    expect(resolved.accent, brand);
    expect(resolved.onAccent, const Color(0xFF000000));
    expect(_contrast(resolved.accent, resolved.onAccent),
        greaterThanOrEqualTo(4.5));
  });

  testWidgets('a deep host accent keeps white ink', (tester) async {
    const brand = Color(0xFF0B2E6F);
    final resolved =
        await _resolve(tester, const SeatLayerPickerThemeData(accent: brand));

    expect(resolved.onAccent, const Color(0xFFFFFFFF));
    expect(_contrast(resolved.accent, resolved.onAccent),
        greaterThanOrEqualTo(4.5));
  });

  testWidgets('a brand red keeps white ink, the colour it wears everywhere',
      (tester) async {
    // The defect this guards: black scores higher on this red, so the
    // higher-ratio rule handed every accented surface black text.
    const brand = Color(0xFFE54558);
    final resolved =
        await _resolve(tester, const SeatLayerPickerThemeData(accent: brand));

    expect(resolved.onAccent, const Color(0xFFFFFFFF));
    expect(_contrast(resolved.accent, resolved.onAccent),
        greaterThanOrEqualTo(3.0));
  });

  testWidgets('an explicit onAccent is still obeyed, however it reads',
      (tester) async {
    final resolved = await _resolve(
      tester,
      const SeatLayerPickerThemeData(
        accent: Color(0xFFFFD400),
        onAccent: Color(0xFFFFFFFF),
      ),
    );
    expect(resolved.onAccent, const Color(0xFFFFFFFF));
  });

  testWidgets('the presets keep the ink they were designed with',
      (tester) async {
    // A preset's accent ships with its own paired ink; only a colour the host
    // chose has no ink of its own.
    expect(
      (await _resolve(tester, null)).onAccent,
      SeatLayerLightTokens.onAccent,
    );
    expect(
      (await _resolve(tester, null, brightness: Brightness.dark)).onAccent,
      SeatLayerDarkTokens.onAccent,
    );
  });

  group('the ink a brand accent gets', () {
    // White is what a brand puts on its own colour, so white is the answer
    // wherever white can be read. Black is for the accents where black is the
    // obvious reading anyway — a yellow, a mint, a near-white tint.
    //
    // `alsoAA` records which of these additionally clear 4.5:1, the floor for
    // normal-weight body text. The picker's accented labels are bold at 15sp
    // and larger, which WCAG sizes as large text at 3:1, so a row without it
    // is correct rather than borderline.
    const cases = <(String, Color, Color, bool)>[
      ('brand red', Color(0xFFE54558), Color(0xFFFFFFFF), false),
      ('deep red', Color(0xFFD6001C), Color(0xFFFFFFFF), true),
      ('brand blue', Color(0xFF1D4ED8), Color(0xFFFFFFFF), true),
      ('navy', Color(0xFF0B2E6F), Color(0xFFFFFFFF), true),
      ('purple', Color(0xFF6D28D9), Color(0xFFFFFFFF), true),
      ('teal', Color(0xFF0F766E), Color(0xFFFFFFFF), true),
      ('forest green', Color(0xFF128A45), Color(0xFFFFFFFF), false),
      ('near-black', Color(0xFF111827), Color(0xFFFFFFFF), true),
      // Pale enough that white genuinely cannot be read on them.
      ('bright green', Color(0xFF22C55E), Color(0xFF000000), true),
      ('orange', Color(0xFFFF6A00), Color(0xFF000000), true),
      ('yellow', Color(0xFFFFD400), Color(0xFF000000), true),
      ('white', Color(0xFFFFFFFF), Color(0xFF000000), true),
      ('near-white tint', Color(0xFFF1F5F9), Color(0xFF000000), true),
      ('mint', Color(0xFFA7F3D0), Color(0xFF000000), true),
    ];

    for (final (name, accent, expected, alsoAA) in cases) {
      test(name, () {
        final ink = seatLayerOnAccentFor(accent);
        expect(ink, expected, reason: name);
        expect(_contrast(accent, ink), greaterThanOrEqualTo(3.0), reason: name);
        if (alsoAA) {
          expect(_contrast(accent, ink), greaterThanOrEqualTo(4.5),
              reason: name);
        }
      });
    }
  });

  test('no accent can produce ink below the large-text floor', () {
    // White fails only above the luminance where black clears 7:1, so the
    // handover is safe in both directions — swept rather than asserted on a
    // handful of colours.
    for (var red = 0; red < 256; red += 17) {
      for (var green = 0; green < 256; green += 17) {
        for (var blue = 0; blue < 256; blue += 17) {
          final accent = Color.fromARGB(255, red, green, blue);
          expect(
            _contrast(accent, seatLayerOnAccentFor(accent)),
            greaterThanOrEqualTo(3.0),
            reason: 'accent $red,$green,$blue',
          );
        }
      }
    }
  });
}
