import 'package:flutter/widgets.dart';

import '../bridge/bridge_profile.dart';
import '../payloads.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import '../seat_layer_runtime_host.dart';
import 'season_configuration.dart';
import 'seat_layer_season_controller.dart';

/// The Season page in a web view: its package step, map and cart.
///
/// Give it a definite size, as the seat map. [SeatLayerSeasonPicker] places it
/// under the app's header; use this directly only for a layout of your own.
class SeatLayerSeasonView
    extends SeatLayerRuntimeHost<SeatLayerSeasonConfiguration> {
  const SeatLayerSeasonView({
    super.key,
    required this.controller,
    required this.configuration,
    this.bootThemeMode,
    this.onReady,
    this.onLoadError,
    this.backgroundColor,
  });

  @override
  final SeatLayerSeasonController controller;

  @override
  final SeatLayerSeasonConfiguration configuration;

  /// The side the page boots on. A change reloads the page, so follow a later
  /// flip with [SeatLayerSeasonController.setThemeMode] instead.
  final SeatLayerThemeMode? bootThemeMode;

  @override
  final void Function(ReadyInfo info)? onReady;

  @override
  final void Function(SeatLayerError error)? onLoadError;

  @override
  final Color? backgroundColor;

  @override
  SeatLayerBridgeProfile get bridgeProfile => SeatLayerBridgeProfile.season(
        config: <String, Object?>{
          if (bootThemeMode != null) 'theme': bootThemeMode!.raw,
        },
      );
}
