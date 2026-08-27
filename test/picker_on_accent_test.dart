// A host brands the picker with one colour. The ink on it has to be readable.
//
// Pairing a host-supplied accent with a FIXED ink fails silently: the button
// renders, nothing throws, and the label is simply unreadable on a pale brand.
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

  test('no accent can produce ink below the AA floor', () {
    // The two curves cross above 4.5:1, so the better of black and white
    // always passes — swept rather than asserted on a handful of colours.
    for (var red = 0; red < 256; red += 17) {
      for (var green = 0; green < 256; green += 17) {
        for (var blue = 0; blue < 256; blue += 17) {
          final accent = Color.fromARGB(255, red, green, blue);
          expect(
            _contrast(accent, seatLayerOnAccentFor(accent)),
            greaterThanOrEqualTo(4.5),
            reason: 'accent $red,$green,$blue',
          );
        }
      }
    }
  });
}
