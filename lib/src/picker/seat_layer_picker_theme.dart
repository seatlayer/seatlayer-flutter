import 'package:flutter/material.dart';

import 'picker_models.dart';

@immutable
class SeatLayerMapThemeData {
  const SeatLayerMapThemeData({this.background});
  final Color? background;
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
