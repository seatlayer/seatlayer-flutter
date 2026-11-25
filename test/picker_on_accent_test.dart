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

/// The ink a brand accent gets where white cannot be read: the web picker's.
const _nearBlack = Color(0xFF1A1200);

/// Resolve the palette for a page whose organizer sends [branding].
Future<SeatLayerResolvedPickerTheme> _resolveOrganizer(
  WidgetTester tester,
  SeatLayerPickerBranding branding, {
  SeatLayerPickerThemeData? theme,
}) async {
  late SeatLayerResolvedPickerTheme resolved;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          resolved = resolveSeatLayerPalette(
            context,
            branding,
            theme,
            brightness: Brightness.light,
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return resolved;
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
  testWidgets('a pale host accent gets near-black ink, not the preset white',
      (tester) async {
    // #FFD400 is a real brand yellow. White on it is 1.3:1 — invisible.
    const brand = Color(0xFFFFD400);
    final resolved =
        await _resolve(tester, const SeatLayerPickerThemeData(accent: brand));

    expect(resolved.accent, brand);
    expect(resolved.onAccent, _nearBlack);
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
      ('bright green', Color(0xFF22C55E), _nearBlack, true),
      ('orange', Color(0xFFFF6A00), _nearBlack, true),
      ('yellow', Color(0xFFFFD400), _nearBlack, true),
      ('white', Color(0xFFFFFFFF), _nearBlack, true),
      ('near-white tint', Color(0xFFF1F5F9), _nearBlack, true),
      ('mint', Color(0xFFA7F3D0), _nearBlack, true),
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

  group('the ink table the web picker uses', () {
    // The accents the web runtime's rule was checked on, with the ink it
    // gives: the same ink here, so the page's chips and the app's badge agree.
    const white = Color(0xFFFFFFFF);
    const rows = <(String, Color, Color)>[
      ('SeatLayer amber (default)', Color(0xFFF4B740), _nearBlack),
      ('periwinkle', Color(0xFF536DFE), white),
      ('royal blue', Color(0xFF4F6BFF), white),
      ('cornflower', Color(0xFF5468FF), white),
      ('indigo-500', Color(0xFF6366F1), white),
      ('blue-600', Color(0xFF2563EB), white),
      ('violet-600', Color(0xFF7C3AED), white),
      ('red-600', Color(0xFFDC2626), white),
      ('red-500', Color(0xFFEF4444), white),
      ('green-600', Color(0xFF16A34A), white),
      ('emerald-500', Color(0xFF10B981), _nearBlack),
      ('cyan-600', Color(0xFF0891B2), white),
      ('sky-500', Color(0xFF0EA5E9), _nearBlack),
      ('amber-500', Color(0xFFF59E0B), _nearBlack),
      ('orange-500', Color(0xFFF97316), _nearBlack),
      ('pink-500', Color(0xFFEC4899), white),
      ('burnt orange', Color(0xFFE8632B), white),
      ('deep teal', Color(0xFF12504F), white),
      ('maroon', Color(0xFF7A1F2B), white),
      ('navy', Color(0xFF1E3A8A), white),
      ('coral', Color(0xFFFF4D6D), white),
      ('yellow-400', Color(0xFFFACC15), _nearBlack),
      ('light green-400', Color(0xFF4ADE80), _nearBlack),
      ('cyan-400', Color(0xFF22D3EE), _nearBlack),
      ('near-black', Color(0xFF111827), white),
      ('white', Color(0xFFFFFFFF), _nearBlack),
    ];
    for (final (name, accent, ink) in rows) {
      test(name, () => expect(seatLayerOnAccentFor(accent), ink, reason: name));
    }
  });

  testWidgets('the organizer\'s ink is kept where it reads at 3:1',
      (tester) async {
    // A coral with its own dark ink: 6.7:1.
    final resolved = await _resolveOrganizer(
      tester,
      const SeatLayerPickerBranding(accent: '#ff4d6d', accentInk: '#0b0f17'),
    );
    expect(resolved.onAccent, const Color(0xFF0B0F17));
  });

  testWidgets('the organizer\'s ink under 3:1 gives way to the rule',
      (tester) async {
    // Near-black on a mid blue reads 4.4:1 and passes; white on amber reads
    // 1.8:1 and does not.
    final blue = await _resolveOrganizer(
      tester,
      const SeatLayerPickerBranding(accent: '#536dfe', accentInk: '#1a1200'),
    );
    expect(blue.onAccent, _nearBlack);

    final amber = await _resolveOrganizer(
      tester,
      const SeatLayerPickerBranding(accent: '#f4b740', accentInk: '#ffffff'),
    );
    expect(amber.onAccent, _nearBlack);

    final navy = await _resolveOrganizer(
      tester,
      const SeatLayerPickerBranding(accent: '#1e3a8a', accentInk: '#12504f'),
    );
    expect(navy.onAccent, const Color(0xFFFFFFFF));
  });

  testWidgets('a host accent judges the organizer\'s ink against itself',
      (tester) async {
    // The organizer's white was chosen for its navy; the host's yellow
    // replaces the navy, and white on yellow cannot be read.
    final resolved = await _resolveOrganizer(
      tester,
      const SeatLayerPickerBranding(accent: '#1e3a8a', accentInk: '#ffffff'),
      theme: const SeatLayerPickerThemeData(accent: Color(0xFFFACC15)),
    );
    expect(resolved.onAccent, _nearBlack);
  });

  testWidgets('the host\'s onAccent still wins over the organizer\'s ink',
      (tester) async {
    final resolved = await _resolveOrganizer(
      tester,
      const SeatLayerPickerBranding(accent: '#f4b740', accentInk: '#1a1200'),
      theme: const SeatLayerPickerThemeData(onAccent: Color(0xFFFFFFFF)),
    );
    expect(resolved.onAccent, const Color(0xFFFFFFFF));
  });

  test('no accent can produce ink below the large-text floor', () {
    // White fails only above the luminance where near-black clears 6:1, so the
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
