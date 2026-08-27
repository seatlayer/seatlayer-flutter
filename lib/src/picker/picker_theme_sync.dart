import 'dart:async';

import 'package:flutter/widgets.dart';

import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// Everything about the theme that the runtime's init config is allowed to
/// carry.
///
/// Frozen per reload generation as one value, because the rule is the same for
/// every field: what goes into the init config is part of the bridge profile,
/// and a profile that changes is a reload.
@immutable
class PickerBootTheme {
  /// Creates the frozen boot-time theme.
  const PickerBootTheme({required this.mode, required this.mapTheme});

  /// The resolved side the runtime booted on.
  final SeatLayerThemeMode mode;

  /// The map colours handed to the runtime at boot.
  ///
  /// Frozen on the side the picker booted on. The runtime pins its map ground
  /// to whatever the init config supplied, and there is no bridge command to
  /// change it afterwards — so re-deriving this on a flip would only reach the
  /// map by rebooting the picker, which is the bug this freeze exists to stop.
  final SeatLayerMapThemeData? mapTheme;
}

/// Keeps the runtime's theme mode in step with the side the scope resolved.
///
/// The mode is handed to [builder] frozen per reload generation on purpose: the
/// bridge profile is part of what makes a [SeatLayerView] rebuild its WebView,
/// so folding a later theme flip into the init config would tear the runtime
/// down and take the buyer's selection with it. Every change after boot travels
/// as `picker.setThemeMode` instead, which repaints in place.
///
/// `auto` is resolved here rather than handed over as `auto`:
/// [MediaQuery.platformBrightnessOf] is authoritative for the app, while
/// `prefers-color-scheme` inside a WebView is not reliably the same answer.
class PickerThemeModeSync extends StatefulWidget {
  /// Creates a synchronizer that builds its child with the boot-time mode.
  const PickerThemeModeSync({super.key, required this.builder});

  /// Builds the subtree with the theme currently folded into the init config.
  final Widget Function(BuildContext context, PickerBootTheme boot) builder;

  @override
  State<PickerThemeModeSync> createState() => _PickerThemeModeSyncState();
}

class _PickerThemeModeSyncState extends State<PickerThemeModeSync> {
  PickerBootTheme? _boot;
  SeatLayerThemeMode? _liveMode;
  int? _bootGeneration;

  @override
  Widget build(BuildContext context) {
    final picker = SeatLayerPickerScope.controllerOf(context);
    final mode = SeatLayerPickerScope.brightnessOf(context) == Brightness.dark
        ? SeatLayerThemeMode.dark
        : SeatLayerThemeMode.light;
    // Read once per build so the frozen value below is never a stale closure.
    final mapTheme = resolveSeatLayerMapTheme(
      context,
      SeatLayerPickerScope.themeOf(context),
      brightness: SeatLayerPickerScope.brightnessOf(context),
    );
    _sync(picker, mode, mapTheme);
    return widget.builder(context, _boot!);
  }

  void _sync(
    SeatLayerPickerController picker,
    SeatLayerThemeMode mode,
    SeatLayerMapThemeData? mapTheme,
  ) {
    if (_bootGeneration != picker.reloadGeneration) {
      _bootGeneration = picker.reloadGeneration;
      _boot = PickerBootTheme(mode: mode, mapTheme: mapTheme);
      _liveMode = mode;
      return;
    }
    if (_liveMode == mode) return;
    _liveMode = mode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _liveMode != mode) return;
      unawaited(picker.setThemeMode(mode).catchError((Object _) {}));
    });
  }
}
