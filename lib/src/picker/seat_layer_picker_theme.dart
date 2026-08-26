import 'package:flutter/material.dart';

import 'picker_models.dart';

@immutable
class SeatLayerMapThemeData {
  const SeatLayerMapThemeData({
    this.background,
    this.rowLabelColor,
    this.textColor,
    this.selectionColor,
  });

  const SeatLayerMapThemeData.light({
    this.background = const Color(0xFFF7F8FA),
    this.rowLabelColor = const Color(0xFF334155),
    this.textColor = const Color(0xFF172033),
    this.selectionColor = const Color(0xFF5B4B8A),
  });

  /// High-contrast dark preset for the drawn seating map.
  const SeatLayerMapThemeData.dark({
    this.background = const Color(0xFF090D15),
    this.rowLabelColor = const Color(0xFFD7DEEA),
    this.textColor = const Color(0xFFF4F7FB),
    this.selectionColor = const Color(0xFF9B8AFB),
  });

  final Color? background;
  final Color? rowLabelColor;
  final Color? textColor;
  final Color? selectionColor;

  Map<String, Object?> toBridgeConfig() => <String, Object?>{
        if (background != null) 'background': _colorHex(background!),
        if (rowLabelColor != null) 'rowLabelColor': _colorHex(rowLabelColor!),
        if (textColor != null) 'textColor': _colorHex(textColor!),
        if (selectionColor != null)
          'selectionColor': _colorHex(selectionColor!),
      };
}

@immutable
class SeatLayerPickerThemeData
    extends ThemeExtension<SeatLayerPickerThemeData> {
  const SeatLayerPickerThemeData({
    this.accent,
    this.onAccent,
    this.background,
    this.surface,
    this.text,
    this.mutedText,
    this.divider,
    this.error,
    this.warning,
    this.fontFamily,
    this.radius,
    this.logo,
    this.mapTheme,
  });

  /// Professional light preset for native chrome and the drawn seat map.
  ///
  /// The accent remains host-configurable, while all neutral roles are paired
  /// for readable light-surface contrast.
  const SeatLayerPickerThemeData.light({
    this.accent = const Color(0xFF5B4B8A),
    this.onAccent = Colors.white,
    this.fontFamily,
    this.radius = 14,
    this.logo,
    this.mapTheme = const SeatLayerMapThemeData.light(),
  })  : background = const Color(0xFFF7F8FA),
        surface = Colors.white,
        text = const Color(0xFF172033),
        mutedText = const Color(0xFF667085),
        divider = const Color(0xFFD7DCE5),
        error = const Color(0xFFB42318),
        warning = const Color(0xFFF4B740);

  /// Professional dark preset for every native picker component and map.
  ///
  /// Hosts can still replace the accent, typeface, radius, logo or complete
  /// map palette without rebuilding the default picker composition.
  const SeatLayerPickerThemeData.dark({
    this.accent = const Color(0xFF9B8AFB),
    this.onAccent = const Color(0xFF110D20),
    this.fontFamily,
    this.radius = 14,
    this.logo,
    this.mapTheme = const SeatLayerMapThemeData.dark(),
  })  : background = const Color(0xFF090D15),
        surface = const Color(0xFF141A24),
        text = const Color(0xFFF4F7FB),
        mutedText = const Color(0xFFA9B4C5),
        divider = const Color(0xFF343E4D),
        error = const Color(0xFFFF6B6B),
        warning = const Color(0xFFF4B740);

  final Color? accent;
  final Color? onAccent;
  final Color? background;
  final Color? surface;
  final Color? text;
  final Color? mutedText;
  final Color? divider;
  final Color? error;
  final Color? warning;
  final String? fontFamily;
  final double? radius;
  final ImageProvider? logo;
  final SeatLayerMapThemeData? mapTheme;

  @override
  SeatLayerPickerThemeData copyWith({
    Color? accent,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? text,
    Color? mutedText,
    Color? divider,
    Color? error,
    Color? warning,
    String? fontFamily,
    double? radius,
    ImageProvider? logo,
    SeatLayerMapThemeData? mapTheme,
  }) =>
      SeatLayerPickerThemeData(
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        text: text ?? this.text,
        mutedText: mutedText ?? this.mutedText,
        divider: divider ?? this.divider,
        error: error ?? this.error,
        warning: warning ?? this.warning,
        fontFamily: fontFamily ?? this.fontFamily,
        radius: radius ?? this.radius,
        logo: logo ?? this.logo,
        mapTheme: mapTheme ?? this.mapTheme,
      );

  @override
  SeatLayerPickerThemeData lerp(
    covariant SeatLayerPickerThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return SeatLayerPickerThemeData(
      accent: Color.lerp(accent, other.accent, t),
      onAccent: Color.lerp(onAccent, other.onAccent, t),
      background: Color.lerp(background, other.background, t),
      surface: Color.lerp(surface, other.surface, t),
      text: Color.lerp(text, other.text, t),
      mutedText: Color.lerp(mutedText, other.mutedText, t),
      divider: Color.lerp(divider, other.divider, t),
      error: Color.lerp(error, other.error, t),
      warning: Color.lerp(warning, other.warning, t),
      fontFamily: t < .5 ? fontFamily : other.fontFamily,
      radius: _lerpDouble(radius, other.radius, t),
      logo: t < .5 ? logo : other.logo,
      mapTheme: t < .5 ? mapTheme : other.mapTheme,
    );
  }
}

@immutable
class SeatLayerResolvedPickerTheme {
  const SeatLayerResolvedPickerTheme({
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.text,
    required this.mutedText,
    required this.divider,
    required this.error,
    required this.warning,
    required this.radius,
    this.fontFamily,
    this.logo,
    this.mapBackground,
  });

  final Color accent;
  final Color onAccent;
  final Color background;
  final Color surface;
  final Color text;
  final Color mutedText;
  final Color divider;
  final Color error;
  final Color warning;
  final double radius;
  final String? fontFamily;
  final ImageProvider? logo;
  final Color? mapBackground;
}

SeatLayerResolvedPickerTheme resolveSeatLayerPickerTheme(
  BuildContext context,
  SeatLayerPickerState state,
  SeatLayerPickerThemeData? explicit,
) {
  final app = Theme.of(context).extension<SeatLayerPickerThemeData>();
  final organizer = state.branding;
  final scheme = Theme.of(context).colorScheme;

  T? choose<T>(T? Function(SeatLayerPickerThemeData theme) read) =>
      explicit == null
          ? (app == null ? null : read(app))
          : read(explicit) ?? (app == null ? null : read(app));

  return SeatLayerResolvedPickerTheme(
    accent: choose((theme) => theme.accent) ??
        _hex(organizer?.accent) ??
        scheme.primary,
    onAccent: choose((theme) => theme.onAccent) ??
        _hex(organizer?.accentInk) ??
        scheme.onPrimary,
    background: choose((theme) => theme.background) ??
        _hex(organizer?.background) ??
        scheme.surface,
    surface: choose((theme) => theme.surface) ??
        _hex(organizer?.surface) ??
        scheme.surfaceContainer,
    text: choose((theme) => theme.text) ??
        _hex(organizer?.text) ??
        scheme.onSurface,
    mutedText: choose((theme) => theme.mutedText) ??
        _hex(organizer?.muted) ??
        scheme.onSurfaceVariant,
    divider: choose((theme) => theme.divider) ??
        _hex(organizer?.line) ??
        scheme.outlineVariant,
    error: choose((theme) => theme.error) ?? scheme.error,
    warning: choose((theme) => theme.warning) ?? const Color(0xFFF4B740),
    radius: choose((theme) => theme.radius) ?? organizer?.radius ?? 16,
    fontFamily: choose((theme) => theme.fontFamily) ?? organizer?.fontFamily,
    logo: choose((theme) => theme.logo),
    mapBackground: choose((theme) => theme.mapTheme)?.background,
  );
}

SeatLayerMapThemeData? resolveSeatLayerMapTheme(
  BuildContext context,
  SeatLayerPickerThemeData? explicit,
) =>
    explicit?.mapTheme ??
    Theme.of(context).extension<SeatLayerPickerThemeData>()?.mapTheme;

Color? _hex(String? value) {
  if (value == null) return null;
  final raw = value.trim().replaceFirst('#', '');
  if (raw.length != 6 && raw.length != 8) return null;
  final parsed = int.tryParse(raw, radix: 16);
  if (parsed == null) return null;
  return Color(raw.length == 6 ? 0xFF000000 | parsed : parsed);
}

double? _lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  return (a ?? b)! + ((b ?? a)! - (a ?? b)!) * t;
}

String _colorHex(Color color) {
  // `value` keeps this SDK source-compatible with Flutter 3.19. Newer Flutter
  // exposes toARGB32(), but the package still supports older stable channels.
  // ignore: deprecated_member_use
  final rgb = color.value & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
