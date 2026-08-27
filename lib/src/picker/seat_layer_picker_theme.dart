import 'package:flutter/material.dart';

import 'picker_layout.dart';
import 'picker_styles.dart';
import 'picker_models.dart';
import 'seat_layer_picker_scope.dart';

/// Which side of the theme the picker paints.
///
/// This is the one theme field that also crosses the bridge, as
/// `theme: { mode }` at init and `picker.setThemeMode` afterwards, so the drawn
/// map follows the native chrome instead of staying on the chart's own colours.
enum SeatLayerThemeMode {
  /// Follow the device, live: a system light/dark flip repaints without a
  /// reload and without losing the buyer's selection.
  auto,

  /// Always light, whatever the device is set to.
  light,

  /// Always dark, whatever the device is set to.
  dark;

  /// The wire value the runtime accepts for `theme.mode`.
  String get raw => name;
}

/// Colours for the drawn map inside the WebView.
@immutable
class SeatLayerMapThemeData {
  /// Creates a partial map palette; omitted roles keep the chart's own colour.
  const SeatLayerMapThemeData({
    this.background,
    this.rowLabelColor,
    this.textColor,
    this.selectionColor,
  });

  /// Light preset for the drawn seating map.
  ///
  /// The ground is recessed below the white chrome that docks on top of it, so
  /// the venue reads as a hole cut in the interface rather than as more of it.
  const SeatLayerMapThemeData.light({
    this.background = const Color(0xFFE9EDF4),
    this.rowLabelColor = const Color(0xFF334155),
    this.textColor = const Color(0xFF172033),
    this.selectionColor = const Color(0xFF5B4B8A),
  });

  /// High-contrast dark preset for the drawn seating map.
  const SeatLayerMapThemeData.dark({
    this.background = const Color(0xFF0F1522),
    this.rowLabelColor = const Color(0xFFD7DEEA),
    this.textColor = const Color(0xFFF4F7FB),
    this.selectionColor = const Color(0xFF9B8AFB),
  });

  /// Ground the venue is drawn on.
  final Color? background;

  /// Ink for row labels.
  final Color? rowLabelColor;

  /// Ink for section and stage labels.
  final Color? textColor;

  /// Ring drawn around a selected seat.
  final Color? selectionColor;

  /// The `mapTheme` object the runtime accepts in its init config.
  Map<String, Object?> toBridgeConfig() => <String, Object?>{
        if (background != null) 'background': _colorHex(background!),
        if (rowLabelColor != null) 'rowLabelColor': _colorHex(rowLabelColor!),
        if (textColor != null) 'textColor': _colorHex(textColor!),
        if (selectionColor != null)
          'selectionColor': _colorHex(selectionColor!),
      };

  @override
  bool operator ==(Object other) =>
      other is SeatLayerMapThemeData &&
      other.background == background &&
      other.rowLabelColor == rowLabelColor &&
      other.textColor == textColor &&
      other.selectionColor == selectionColor;

  @override
  int get hashCode =>
      Object.hash(background, rowLabelColor, textColor, selectionColor);
}

/// Colours, type, radius and layout tokens for the native picker chrome.
@immutable
class SeatLayerPickerThemeData
    extends ThemeExtension<SeatLayerPickerThemeData> {
  /// Creates a partial theme; omitted roles fall back to the resolved mode,
  /// then to the organizer's branding, then to the ambient [ColorScheme].
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
    this.layout,
    this.styles,
  });

  /// Light preset for native chrome and the drawn seat map.
  ///
  /// The ground roles mirror the web picker's light mode: chrome is white and
  /// the map ground is recessed beneath it. The accent stays host-configurable
  /// because a mode owns the ground, never the brand.
  const SeatLayerPickerThemeData.light({
    this.accent = const Color(0xFF5B4B8A),
    this.onAccent = Colors.white,
    this.fontFamily,
    this.radius = 14,
    this.logo,
    this.mapTheme = const SeatLayerMapThemeData.light(),
    this.layout,
    this.styles,
  })  : background = const Color(0xFFF6F7FB),
        surface = Colors.white,
        text = const Color(0xFF172033),
        mutedText = const Color(0xFF667085),
        divider = const Color(0x29172033),
        error = const Color(0xFFB42318),
        warning = const Color(0xFFF4B740);

  /// Dark preset for native chrome and the drawn seat map.
  ///
  /// The ground roles mirror the web picker's dark mode token for token.
  const SeatLayerPickerThemeData.dark({
    this.accent = const Color(0xFF9B8AFB),
    this.onAccent = const Color(0xFF110D20),
    this.fontFamily,
    this.radius = 14,
    this.logo,
    this.mapTheme = const SeatLayerMapThemeData.dark(),
    this.layout,
    this.styles,
  })  : background = const Color(0xFF0F1522),
        surface = const Color(0xFF1A2234),
        text = const Color(0xFFEEF1F8),
        mutedText = const Color(0xFFA5AEC2),
        divider = const Color(0x3DA5AEC2),
        error = const Color(0xFFFF6B6B),
        warning = const Color(0xFFF4B740);

  /// The preset for [brightness].
  factory SeatLayerPickerThemeData.forBrightness(Brightness brightness) =>
      brightness == Brightness.dark
          ? const SeatLayerPickerThemeData.dark()
          : const SeatLayerPickerThemeData.light();

  /// Brand colour for primary actions and active states.
  final Color? accent;

  /// Ink drawn on top of [accent].
  final Color? onAccent;

  /// Ground behind the whole picker.
  final Color? background;

  /// Ground for docked chrome: header, dock bar, sheet, cards.
  final Color? surface;

  /// Primary ink.
  final Color? text;

  /// Secondary ink for counts, captions and disabled states.
  final Color? mutedText;

  /// Hairline colour.
  final Color? divider;

  /// Ink for failures.
  final Color? error;

  /// Ink for advisories such as limited-view seats.
  final Color? warning;

  /// Typeface for every native picker surface.
  final String? fontFamily;

  /// Corner radius for cards, sheets and buttons.
  final double? radius;

  /// Brand mark shown in the header, replacing the organizer's logo URL.
  final ImageProvider? logo;

  /// Colours for the drawn map inside the WebView.
  final SeatLayerMapThemeData? mapTheme;

  /// Sizes the phone chrome is built from.
  final SeatLayerPickerLayout? layout;

  /// Per-element style slots, for restyling one control in place.
  final SeatLayerPickerStyles? styles;

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
    SeatLayerPickerLayout? layout,
    SeatLayerPickerStyles? styles,
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
        layout: layout ?? this.layout,
        styles: styles ?? this.styles,
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
      layout: t < .5 ? layout : other.layout,
      styles: t < .5 ? styles : other.styles,
    );
  }
}

/// A complete, non-nullable palette for one build of the native chrome.
@immutable
class SeatLayerResolvedPickerTheme {
  /// Creates a resolved palette. Produced by [resolveSeatLayerPickerTheme].
  const SeatLayerResolvedPickerTheme({
    required this.brightness,
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
    required this.layout,
    this.styles = const SeatLayerPickerStyles(),
    this.fontFamily,
    this.logo,
    this.mapBackground,
  });

  /// Which side of the theme this palette paints.
  final Brightness brightness;

  /// Brand colour for primary actions and active states.
  final Color accent;

  /// Ink drawn on top of [accent].
  final Color onAccent;

  /// Ground behind the whole picker.
  final Color background;

  /// Ground for docked chrome.
  final Color surface;

  /// Primary ink.
  final Color text;

  /// Secondary ink.
  final Color mutedText;

  /// Hairline colour.
  final Color divider;

  /// Ink for failures.
  final Color error;

  /// Ink for advisories.
  final Color warning;

  /// Corner radius for cards, sheets and buttons.
  final double radius;

  /// Sizes the phone chrome is built from.
  final SeatLayerPickerLayout layout;

  /// Per-element style slots, already merged from every layer.
  final SeatLayerPickerStyles styles;

  /// Typeface for every native picker surface.
  final String? fontFamily;

  /// Brand mark shown in the header.
  final ImageProvider? logo;

  /// Ground of the drawn map, when one is configured.
  final Color? mapBackground;

  /// The dark-scene palette used by immersive 3D chrome.
  ///
  /// White chrome over a dark venue scene reads as a mistake, so the 3D
  /// overlay adopts these tokens whatever the resolved [brightness] is.
  SeatLayerResolvedPickerTheme get immersive => brightness == Brightness.dark
      ? this
      : SeatLayerResolvedPickerTheme(
          brightness: Brightness.dark,
          accent: accent,
          onAccent: onAccent,
          background: const Color(0xFF0F1522),
          surface: const Color(0xFF1A2234),
          text: const Color(0xFFEEF1F8),
          mutedText: const Color(0xFFA5AEC2),
          divider: const Color(0x3DA5AEC2),
          error: const Color(0xFFFF6B6B),
          warning: warning,
          radius: radius,
          layout: layout,
          styles: styles,
          fontFamily: fontFamily,
          logo: logo,
          mapBackground: mapBackground,
        );
}

/// Turn [mode] into a real side, reading the device for
/// [SeatLayerThemeMode.auto].
///
/// Reading it through [MediaQuery.platformBrightnessOf] is what makes `auto`
/// live: the caller rebuilds when the device flips, with no reload.
Brightness resolveSeatLayerThemeBrightness(
  BuildContext context,
  SeatLayerThemeMode mode,
) =>
    switch (mode) {
      SeatLayerThemeMode.light => Brightness.light,
      SeatLayerThemeMode.dark => Brightness.dark,
      SeatLayerThemeMode.auto => MediaQuery.platformBrightnessOf(context),
    };

/// Resolve the palette for the picker chrome above [context].
///
/// Precedence for the ground roles — background, surface, ink, muted ink and
/// hairlines — is the host's explicit theme, then a theme extension on the
/// ambient [ThemeData], then the resolved mode's preset, then the organizer's
/// branding, then the ambient [ColorScheme]. The brand roles — accent, accent
/// ink, typeface, radius and logo — skip the mode preset entirely, because a
/// mode owns the ground and never the brand.
SeatLayerResolvedPickerTheme resolveSeatLayerPickerTheme(
  BuildContext context,
  SeatLayerPickerState state,
  SeatLayerPickerThemeData? explicit, {
  Brightness? brightness,
}) {
  final app = Theme.of(context).extension<SeatLayerPickerThemeData>();
  final organizer = state.branding;
  final scheme = Theme.of(context).colorScheme;
  final side = brightness ?? Theme.of(context).brightness;
  final preset = SeatLayerPickerThemeData.forBrightness(side);

  T? host<T>(T? Function(SeatLayerPickerThemeData theme) read) =>
      explicit == null
          ? (app == null ? null : read(app))
          : read(explicit) ?? (app == null ? null : read(app));

  T? ground<T>(T? Function(SeatLayerPickerThemeData theme) read) =>
      host(read) ?? read(preset);

  return SeatLayerResolvedPickerTheme(
    brightness: side,
    accent: host((theme) => theme.accent) ??
        _hex(organizer?.accent) ??
        preset.accent!,
    onAccent: host((theme) => theme.onAccent) ??
        _hex(organizer?.accentInk) ??
        preset.onAccent!,
    background: ground((theme) => theme.background) ??
        _hex(organizer?.background) ??
        scheme.surface,
    surface: ground((theme) => theme.surface) ??
        _hex(organizer?.surface) ??
        scheme.surfaceContainer,
    text: ground((theme) => theme.text) ??
        _hex(organizer?.text) ??
        scheme.onSurface,
    mutedText: ground((theme) => theme.mutedText) ??
        _hex(organizer?.muted) ??
        scheme.onSurfaceVariant,
    divider: ground((theme) => theme.divider) ??
        _hex(organizer?.line) ??
        scheme.outlineVariant,
    error: ground((theme) => theme.error) ?? scheme.error,
    warning: ground((theme) => theme.warning) ?? const Color(0xFFF4B740),
    radius: host((theme) => theme.radius) ?? organizer?.radius ?? 14,
    layout: host((theme) => theme.layout) ?? const SeatLayerPickerLayout(),
    // Slots stack: a theme extension on the app, then the picker's own theme.
    styles: (app?.styles ?? const SeatLayerPickerStyles())
        .merge(explicit?.styles),
    fontFamily: host((theme) => theme.fontFamily) ?? organizer?.fontFamily,
    logo: host((theme) => theme.logo),
    mapBackground: resolveSeatLayerMapTheme(context, explicit, brightness: side)
        ?.background,
  );
}

/// The palette for the picker chrome above [context], read from the scope.
///
/// One helper for every chrome widget, so a component placed by hand inside a
/// [SeatLayerPickerScope] resolves exactly what the drop-in resolves.
SeatLayerResolvedPickerTheme seatLayerPickerThemeOf(BuildContext context) =>
    resolveSeatLayerPickerTheme(
      context,
      SeatLayerPickerScope.stateOf(context),
      SeatLayerPickerScope.themeOf(context),
      brightness: SeatLayerPickerScope.brightnessOf(context),
    );

/// The palette for chrome that sits ON the map surface.
///
/// Identical to [seatLayerPickerThemeOf] except while the immersive scene is
/// up, when it returns the dark scene palette: white chrome over a dark venue
/// reads as a mistake, and the header, legend and 3D controls all cap the same
/// surface.
SeatLayerResolvedPickerTheme seatLayerMapChromeThemeOf(BuildContext context) {
  final base = seatLayerPickerThemeOf(context);
  final venue3D =
      SeatLayerPickerScope.stateOf(context).snapshot?.map.isVenue3D ?? false;
  return venue3D ? base.immersive : base;
}

/// Resolve the colours the drawn map is repainted with.
///
/// A host that set [SeatLayerPickerThemeData.mapTheme] always wins. Otherwise
/// the resolved mode supplies a ground, so the venue follows the chrome instead
/// of staying on whatever the chart was saved with.
SeatLayerMapThemeData? resolveSeatLayerMapTheme(
  BuildContext context,
  SeatLayerPickerThemeData? explicit, {
  Brightness? brightness,
}) {
  final authored = explicit?.mapTheme ??
      Theme.of(context).extension<SeatLayerPickerThemeData>()?.mapTheme;
  if (authored != null) return authored;
  if (brightness == null) return null;
  return SeatLayerPickerThemeData.forBrightness(brightness).mapTheme;
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

String _colorHex(Color color) {
  // `value` keeps this SDK source-compatible with Flutter 3.19. Newer Flutter
  // exposes toARGB32(), but the package still supports older stable channels.
  // ignore: deprecated_member_use
  final rgb = color.value & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
