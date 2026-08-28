/// The device's own status and navigation bars, dressed for the picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The system overlay style a picker standing on [theme] needs.
///
/// The bars are the host operating system's, but the surface behind them is
/// the picker's, so the picker is the only thing that can know what colour
/// the clock has to be. A dark picker with the platform's default dark icons
/// is what the owner reported: a clock, a wifi glyph and a battery drawn in
/// near-black on a near-black header, invisible until the buyer tilts the
/// phone into the light.
///
/// The two platforms name the same decision from opposite ends and both are
/// filled in, because a package cannot know which one it is running on at the
/// moment its palette resolves:
///
/// * `statusBarBrightness` is iOS's, and describes the BACKGROUND — a dark
///   surface is `Brightness.dark`, and UIKit answers with light glyphs.
/// * `statusBarIconBrightness` is Android's, and describes the ICONS — a dark
///   surface wants `Brightness.light`, which is the opposite value.
///
/// The navigation bar is given the same surface it is docked against, so the
/// gesture pill or the three-button row reads as the bottom edge of the
/// picker rather than as a black strip under it.
SystemUiOverlayStyle seatLayerPickerOverlayStyle(
  SeatLayerResolvedPickerTheme theme,
) {
  final onDark = theme.brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: theme.surface,
    // The ground behind the bar (iOS).
    statusBarBrightness: onDark ? Brightness.dark : Brightness.light,
    // The glyphs drawn on it (Android) — deliberately the other way round.
    statusBarIconBrightness: onDark ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: theme.surface,
    systemNavigationBarDividerColor: theme.divider,
    systemNavigationBarIconBrightness:
        onDark ? Brightness.light : Brightness.dark,
  );
}

/// The style for a picker whose scene may be up, read from the scope.
///
/// While the immersive 3D scene is drawn the whole surface is the dark venue,
/// whatever side the picker resolved to, so the bars follow the scene and not
/// the theme mode. [seatLayerMapChromeThemeOf] is the same palette the map's
/// own chrome uses, so the clock, the price rail and `‹ Back to venue` all
/// change together.
SystemUiOverlayStyle seatLayerPickerOverlayStyleOf(BuildContext context) =>
    seatLayerPickerOverlayStyle(seatLayerMapChromeThemeOf(context));

/// Hands the system bars to the picker's resolved palette while it is mounted.
///
/// Placed inside the scope, so it re-evaluates on everything the palette
/// does — an `auto` theme mode following a device flip, the organizer's
/// branding arriving with the first snapshot, and the immersive scene coming
/// up or going down.
///
/// Opt out with `SeatLayerPickerChromeOptions(manageSystemOverlays: false)`
/// when the host application owns the bars itself.
class PickerSystemOverlay extends StatelessWidget {
  /// Dresses the bars for the picker above [child].
  const PickerSystemOverlay({super.key, required this.child});

  /// The composition the bars are standing on.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!SeatLayerPickerScope.optionsOf(context).chrome.manageSystemOverlays) {
      return child;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: seatLayerPickerOverlayStyleOf(context),
      child: child,
    );
  }
}
