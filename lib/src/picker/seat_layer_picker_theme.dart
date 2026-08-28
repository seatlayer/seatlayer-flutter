import 'package:flutter/cupertino.dart' show CupertinoTheme;
import 'package:flutter/material.dart';

import 'picker_layout.dart';
import 'picker_tokens.g.dart';
import 'picker_styles.dart';
import 'picker_models.dart';
import 'seat_layer_picker_scope.dart';

/// Which side of the theme the picker paints.
///
/// This is the one theme field that also crosses the bridge, as
/// `theme: { mode }` at init and `picker.setThemeMode` afterwards, so the drawn
/// map follows the native chrome instead of staying on the chart's own colours.
enum SeatLayerThemeMode {
  /// Follow the host application, live.
  ///
  /// Resolved from `Theme.of(context).brightness` — the switch inside the app
  /// the buyer actually chose — falling back to the device's appearance when
  /// there is no Material or Cupertino theme to ask. Either one flipping
  /// repaints the chrome and the drawn map without a reload and without
  /// losing the buyer's selection.
  auto,

  /// Always light, whatever the app and the device are set to.
  light,

  /// Always dark, whatever the app and the device are set to.
  dark;

  /// The wire value the runtime accepts for `theme.mode`.
  String get raw => name;
}

/// Colours for the drawn venue map.
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
    this.background = SeatLayerLightTokens.mapBackground,
    this.rowLabelColor = SeatLayerLightTokens.mapRowLabel,
    this.textColor = SeatLayerLightTokens.mapText,
    this.selectionColor = SeatLayerLightTokens.mapSelection,
  });

  /// High-contrast dark preset for the drawn seating map.
  const SeatLayerMapThemeData.dark({
    this.background = SeatLayerDarkTokens.mapBackground,
    this.rowLabelColor = SeatLayerDarkTokens.mapRowLabel,
    this.textColor = SeatLayerDarkTokens.mapText,
    this.selectionColor = SeatLayerDarkTokens.mapSelection,
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
  ///
  /// This is the constructor to brand with. `SeatLayerPickerThemeData(accent:
  /// myBrand)` leaves every ground role unset, so the picker still follows
  /// [SeatLayerThemeMode] — including [SeatLayerThemeMode.auto], which tracks
  /// the device live. The `.light()` and `.dark()` presets each supply a whole
  /// ground palette and therefore pin the picker to one side.
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
    this.buttonRadius,
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
  ///
  /// **This preset pins the picker to light.** It supplies a complete explicit
  /// ground palette, and explicit roles win over the resolved
  /// [SeatLayerThemeMode] — so `themeMode: auto` with `.light()` never follows
  /// the device. That is the point of a preset. A host that wants its brand
  /// accent AND a picker that follows the device uses the default constructor
  /// instead: `SeatLayerPickerThemeData(accent: myBrand)`.
  const SeatLayerPickerThemeData.light({
    this.accent = SeatLayerLightTokens.accent,
    this.onAccent = SeatLayerLightTokens.onAccent,
    this.fontFamily,
    this.radius = SeatLayerRadiusTokens.base,
    this.buttonRadius = SeatLayerRadiusTokens.button,
    this.logo,
    this.mapTheme = const SeatLayerMapThemeData.light(),
    this.layout,
    this.styles,
  })  : background = SeatLayerLightTokens.background,
        surface = SeatLayerLightTokens.surface,
        text = SeatLayerLightTokens.text,
        mutedText = SeatLayerLightTokens.mutedText,
        divider = SeatLayerLightTokens.divider,
        error = SeatLayerLightTokens.error,
        warning = SeatLayerLightTokens.warning;

  /// Dark preset for native chrome and the drawn seat map.
  ///
  /// The ground roles mirror the web picker's dark mode token for token.
  ///
  /// **This preset pins the picker to dark**, for the same reason
  /// [SeatLayerPickerThemeData.light] pins it to light.
  const SeatLayerPickerThemeData.dark({
    this.accent = SeatLayerDarkTokens.accent,
    this.onAccent = SeatLayerDarkTokens.onAccent,
    this.fontFamily,
    this.radius = SeatLayerRadiusTokens.base,
    this.buttonRadius = SeatLayerRadiusTokens.button,
    this.logo,
    this.mapTheme = const SeatLayerMapThemeData.dark(),
    this.layout,
    this.styles,
  })  : background = SeatLayerDarkTokens.background,
        surface = SeatLayerDarkTokens.surface,
        text = SeatLayerDarkTokens.text,
        mutedText = SeatLayerDarkTokens.mutedText,
        divider = SeatLayerDarkTokens.divider,
        error = SeatLayerDarkTokens.error,
        warning = SeatLayerDarkTokens.warning;

  /// The picker painted in an application's own Material palette.
  ///
  /// One call applies a whole brand: the accent every action, active state and
  /// selected control uses comes from [ColorScheme.primary], the ink on it
  /// from `onPrimary`, and the grounds, ink and hairlines from the surface
  /// roles — so a red-primary app gets a red `Continue`, a red `Select`, a red
  /// `Find N best seats`, a red hold pill and a red Map/3D control, with no
  /// per-widget styling and nothing left on the SDK's own indigo.
  ///
  /// Category colours are deliberately NOT touched. The price legend, the
  /// section dots and the seats themselves carry the organizer's ticket
  /// categories, which mean something; recolouring them to the brand would
  /// make the dock's dot disagree with the price it stands for.
  ///
  /// | picker role | `ColorScheme` |
  /// | --- | --- |
  /// | `accent` / `onAccent` | `primary` / `onPrimary` |
  /// | `surface` — header, dock, sheet, cards | `surface` |
  /// | `background` — the page under them | `surface`, stepped toward black |
  /// | `text` / `mutedText` | `onSurface` / `onSurfaceVariant` |
  /// | `divider` | `outlineVariant` |
  /// | `error` | `error` |
  ///
  /// A `ColorScheme` has no recessed-page role that works in both modes, so
  /// [background] is derived: the picker's chrome docks on a page one small
  /// tonal step darker than itself, which reads as depth on a light palette
  /// and on a dark one alike. Pass `background:` to say it yourself.
  ///
  /// **This pins the picker to the scheme's side**, exactly as
  /// [SeatLayerPickerThemeData.light] and `.dark()` do, because it supplies a
  /// complete explicit ground palette. That is what you want here: the scheme
  /// came from the host's own theme, which is already on the side the host
  /// chose. Use [SeatLayerPickerThemeData.of] to take that theme's scheme —
  /// and its typeface — straight from the context.
  ///
  /// Every named argument overrides the mapping for one role.
  factory SeatLayerPickerThemeData.fromColorScheme(
    ColorScheme scheme, {
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
    double? buttonRadius,
    ImageProvider? logo,
    SeatLayerMapThemeData? mapTheme,
    SeatLayerPickerLayout? layout,
    SeatLayerPickerStyles? styles,
  }) {
    final ground = surface ?? scheme.surface;
    return SeatLayerPickerThemeData(
      accent: accent ?? scheme.primary,
      onAccent: onAccent ?? scheme.onPrimary,
      background: background ?? _recessed(ground),
      surface: ground,
      text: text ?? scheme.onSurface,
      mutedText: mutedText ?? scheme.onSurfaceVariant,
      divider: divider ?? scheme.outlineVariant,
      error: error ?? scheme.error,
      warning: warning,
      fontFamily: fontFamily,
      radius: radius,
      buttonRadius: buttonRadius,
      logo: logo,
      mapTheme: mapTheme,
      layout: layout,
      styles: styles,
    );
  }

  /// The picker painted in the palette and typeface of the ambient [Theme].
  ///
  /// The one-liner for an app that already has a brand:
  ///
  /// ```dart
  /// SeatLayerPicker(
  ///   configuration: configuration,
  ///   theme: SeatLayerPickerThemeData.of(context),
  ///   onCheckout: openCheckout,
  /// )
  /// ```
  ///
  /// Takes the host theme's [ColorScheme] through
  /// [SeatLayerPickerThemeData.fromColorScheme] and its body typeface with it,
  /// so the picker reads as a screen of the same application. Because the
  /// scheme already carries the side the host is on, this follows an in-app
  /// dark-mode switch as long as the widget calling it rebuilds — which it
  /// does, since [Theme.of] registers the dependency.
  factory SeatLayerPickerThemeData.of(
    BuildContext context, {
    Color? accent,
    Color? onAccent,
    double? radius,
    double? buttonRadius,
    ImageProvider? logo,
    SeatLayerPickerStyles? styles,
  }) {
    final theme = Theme.of(context);
    return SeatLayerPickerThemeData.fromColorScheme(
      theme.colorScheme,
      accent: accent,
      onAccent: onAccent,
      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
      radius: radius,
      buttonRadius: buttonRadius,
      logo: logo,
      styles: styles,
    );
  }

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

  /// Corner radius for cards, sheets and other containers.
  final double? radius;

  /// Corner radius for the picker's buttons.
  ///
  /// Buttons are deliberately squarer than the surfaces they sit on — the web
  /// picker's own actions round to ~8 pt — so this is its own role rather than
  /// a fraction of [radius]. Set it to a large number for pills.
  final double? buttonRadius;

  /// Brand mark shown in the header, replacing the organizer's logo URL.
  final ImageProvider? logo;

  /// Colours for the drawn venue map.
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
    double? buttonRadius,
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
        buttonRadius: buttonRadius ?? this.buttonRadius,
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
      buttonRadius: _lerpDouble(buttonRadius, other.buttonRadius, t),
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
    required this.buttonRadius,
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

  /// Corner radius for cards, sheets and other containers.
  final double radius;

  /// Corner radius for the picker's buttons.
  final double buttonRadius;

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
          background: SeatLayerDarkTokens.background,
          surface: SeatLayerDarkTokens.surface,
          text: SeatLayerDarkTokens.text,
          mutedText: SeatLayerDarkTokens.mutedText,
          divider: SeatLayerDarkTokens.divider,
          error: SeatLayerDarkTokens.error,
          warning: warning,
          radius: radius,
          buttonRadius: buttonRadius,
          layout: layout,
          styles: styles,
          fontFamily: fontFamily,
          logo: logo,
          mapBackground: mapBackground,
        );
}

/// The page a picker's chrome docks on, one tonal step under [surface].
///
/// A `ColorScheme` names no recessed ground that works on both sides: the
/// container roles step lighter in dark mode and darker in light, so neither
/// reads as "under" in both. A small step toward black does, and it keeps the
/// picker's own spatial model — chrome raised above a page, with the drawn map
/// cut into it — on any palette a host hands over.
Color _recessed(Color surface) =>
    Color.lerp(surface, const Color(0xFF000000), .05)!;

/// Black or white, whichever is legible on [accent].
///
/// A host brands the picker by handing it one colour. Pairing that colour with
/// a FIXED ink is how a pale brand accent ends up carrying white text: the
/// button renders, nobody's code fails, and the label is simply unreadable.
///
/// The choice is WCAG relative luminance, the same measure the contrast ratio
/// is defined on, so the winner is the higher of the two ratios. That is never
/// below 4.58:1 — the two curves cross above the 4.5:1 floor — so an accent of
/// any colour gets ink that passes AA for normal text.
Color seatLayerOnAccentFor(Color accent) {
  final luminance = accent.computeLuminance();
  final onWhite = 1.05 / (luminance + 0.05);
  final onBlack = (luminance + 0.05) / 0.05;
  return onWhite >= onBlack ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
}

/// Turn [mode] into a real side, following the host for
/// [SeatLayerThemeMode.auto].
///
/// The precedence is **explicit [mode] > the host's own theme > the device**:
///
///  * [SeatLayerThemeMode.light] and [SeatLayerThemeMode.dark] are answers,
///    not questions, and win over everything.
///  * `auto` asks the host application first, through
///    `Theme.of(context).brightness`. That is what an app's own dark-mode
///    switch moves — `MaterialApp(themeMode: ...)`, or a Cupertino theme —
///    and it is the setting the buyer actually chose. Reading the device
///    instead left the picker light inside an app the buyer had put in dark
///    mode, with the system still set to light.
///  * With no Material or Cupertino theme above [context] there is nothing to
///    ask, and `auto` falls back to [MediaQuery.platformBrightnessOf].
///
/// Both readings register a dependency, so `auto` is live either way: the
/// caller rebuilds when the host flips its theme or the device flips its
/// appearance, with no reload and no lost selection.
Brightness resolveSeatLayerThemeBrightness(
  BuildContext context,
  SeatLayerThemeMode mode,
) =>
    switch (mode) {
      SeatLayerThemeMode.light => Brightness.light,
      SeatLayerThemeMode.dark => Brightness.dark,
      SeatLayerThemeMode.auto => _hostBrightness(context),
    };

/// What the host application is painted in, or the device if it has no say.
///
/// `Theme.of` answers with a light fallback when nothing supplied a theme,
/// which would read as "the host chose light" rather than as "the host did
/// not choose". The ancestor is looked for explicitly so the two are told
/// apart. `MaterialApp` and `CupertinoApp` both install one, so the fallback
/// is reached only by a bare `WidgetsApp`.
Brightness _hostBrightness(BuildContext context) => _hasHostTheme(context)
    ? Theme.of(context).brightness
    : MediaQuery.platformBrightnessOf(context);

bool _hasHostTheme(BuildContext context) =>
    context.findAncestorWidgetOfExactType<Theme>() != null ||
    context.findAncestorWidgetOfExactType<CupertinoTheme>() != null;

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

  // Told apart because their ink is: a preset's accent ships with the ink it
  // was designed against, while a colour the host or the organizer chose has
  // no ink of its own and must be given one that can be read on it.
  final brandAccent = host((theme) => theme.accent) ?? _hex(organizer?.accent);

  return SeatLayerResolvedPickerTheme(
    brightness: side,
    accent: brandAccent ?? preset.accent!,
    onAccent: host((theme) => theme.onAccent) ??
        _hex(organizer?.accentInk) ??
        (brandAccent == null
            ? preset.onAccent!
            : seatLayerOnAccentFor(brandAccent)),
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
    warning: ground((theme) => theme.warning) ?? SeatLayerLightTokens.warning,
    radius: host((theme) => theme.radius) ??
        organizer?.radius ??
        SeatLayerRadiusTokens.base,
    // Not derived from `radius`: the organizer's branding radius describes its
    // cards, and inheriting it would make a rounded brand grow pill buttons.
    buttonRadius:
        host((theme) => theme.buttonRadius) ?? SeatLayerRadiusTokens.button,
    layout: host((theme) => theme.layout) ?? const SeatLayerPickerLayout(),
    // Slots stack: a theme extension on the app, then the picker's own theme.
    styles:
        (app?.styles ?? const SeatLayerPickerStyles()).merge(explicit?.styles),
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

/// The Material theme the picker's own palette implies.
///
/// Every native surface the picker pushes — the drop-in composition, and any
/// modal route opened from it — is themed through this one function, so a
/// `FilterChip` inside a pushed sheet and a `FilledButton` on the map read as
/// one interface. Without it a pushed route resolves `Theme.of` against the
/// HOST application, which is how a dark picker ended up with light Material
/// chrome inside its own bottom sheets.
ThemeData seatLayerPickerMaterialTheme(
  BuildContext context,
  SeatLayerResolvedPickerTheme resolved,
) {
  final ambient = Theme.of(context);
  final shape = seatLayerButtonShape(resolved.buttonRadius);
  return ambient.copyWith(
    brightness: resolved.brightness,
    colorScheme: ambient.colorScheme.copyWith(
      brightness: resolved.brightness,
      primary: resolved.accent,
      onPrimary: resolved.onAccent,
      surface: resolved.surface,
      onSurface: resolved.text,
      surfaceContainerLow: resolved.surface,
      surfaceContainerHigh: resolved.surface,
      outlineVariant: resolved.divider,
    ),
    canvasColor: resolved.surface,
    dividerColor: resolved.divider,
    textTheme: ambient.textTheme.apply(
      fontFamily: resolved.fontFamily,
      bodyColor: resolved.text,
      displayColor: resolved.text,
    ),
    // Material 3 rounds every button to a stadium. The picker's actions are
    // not pills: `Continue`, `Apply filters` and the rest carry the web
    // picker's own `radius.button`. A button that sets its own shape — or a
    // host that sets one through a style slot — still wins, because a widget's
    // `style:` resolves ahead of the theme.
    filledButtonTheme: FilledButtonThemeData(style: shape),
    outlinedButtonTheme: OutlinedButtonThemeData(style: shape),
    textButtonTheme: TextButtonThemeData(style: shape),
    elevatedButtonTheme: ElevatedButtonThemeData(style: shape),
  );
}

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
  final authored = seatLayerAuthoredMapTheme(context, explicit);
  if (authored != null) return authored;
  if (brightness == null) return null;
  return SeatLayerPickerThemeData.forBrightness(brightness).mapTheme;
}

/// The map colours the HOST authored, with no mode-derived fallback.
///
/// Told apart from [resolveSeatLayerMapTheme] because only one of the two is
/// safe to re-derive while the picker is open: an authored value is the host's
/// own constant, while the mode-derived fallback follows the device's
/// appearance. Anything that follows the appearance must never reach the
/// runtime's init config — the config is part of the bridge profile, and a
/// changed profile is what a `SeatLayerView` treats as a reload, which
/// destroys the picker and takes the buyer's section, selection and 3D scene
/// with it.
SeatLayerMapThemeData? seatLayerAuthoredMapTheme(
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
