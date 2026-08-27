import 'dart:async';

import 'package:flutter/widgets.dart';

import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

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

  /// Builds the subtree with the mode currently folded into the init config.
  final Widget Function(BuildContext context, SeatLayerThemeMode bootMode)
      builder;

  @override
  State<PickerThemeModeSync> createState() => _PickerThemeModeSyncState();
}

class _PickerThemeModeSyncState extends State<PickerThemeModeSync> {
  SeatLayerThemeMode? _bootMode;
  SeatLayerThemeMode? _liveMode;
  int? _bootGeneration;

  @override
  Widget build(BuildContext context) {
    final picker = SeatLayerPickerScope.controllerOf(context);
    final mode = SeatLayerPickerScope.brightnessOf(context) == Brightness.dark
        ? SeatLayerThemeMode.dark
        : SeatLayerThemeMode.light;
    _sync(picker, mode);
    return widget.builder(context, _bootMode!);
  }

  void _sync(SeatLayerPickerController picker, SeatLayerThemeMode mode) {
    if (_bootGeneration != picker.reloadGeneration) {
      _bootGeneration = picker.reloadGeneration;
      _bootMode = mode;
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
