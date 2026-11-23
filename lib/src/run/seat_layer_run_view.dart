import 'package:flutter/widgets.dart';

import '../bridge/bridge_profile.dart';
import '../payloads.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import '../seat_layer_runtime_host.dart';
import 'run_configuration.dart';
import 'seat_layer_run_controller.dart';

/// The run page in a web view: its map, performances and cart, with its own header off.
///
/// Give it a definite size, as the seat map. [SeatLayerRunPicker] places it
/// under the app's header; use this directly only for a layout of your own.
class SeatLayerRunView
    extends SeatLayerRuntimeHost<SeatLayerRunConfiguration> {
  const SeatLayerRunView({
    super.key,
    required this.controller,
    required this.configuration,
    this.bootThemeMode,
    this.onReady,
    this.onLoadError,
    this.backgroundColor,
  });

  @override
  final SeatLayerRunController controller;

  @override
  final SeatLayerRunConfiguration configuration;

  /// The side the page boots on. A change reloads the page: runtime 1.0.0's
  /// run page has no command to repaint in place.
  final SeatLayerThemeMode? bootThemeMode;

  @override
  final void Function(ReadyInfo info)? onReady;

  @override
  final void Function(SeatLayerError error)? onLoadError;

  @override
  final Color? backgroundColor;

  @override
  SeatLayerBridgeProfile get bridgeProfile => SeatLayerBridgeProfile.group(
        config: <String, Object?>{
          if (bootThemeMode != null) 'theme': bootThemeMode!.raw,
        },
      );
}
