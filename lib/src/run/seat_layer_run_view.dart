import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../bridge/bridge_profile.dart';
import '../payloads.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import '../seat_layer_runtime_host.dart';
import 'run_configuration.dart';
import 'run_models.dart';
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
  })  : again = false,
        resumed = null;

  /// A page of the picker's. [again]: it takes the place of one that was up, so
  /// it opens on [resumed], not on the hold [configuration] opens on.
  @internal
  const SeatLayerRunView.inPicker({
    super.key,
    required this.controller,
    required this.configuration,
    required this.again,
    required this.resumed,
    this.bootThemeMode,
    this.onLoadError,
    this.backgroundColor,
  }) : onReady = null;

  @override
  final SeatLayerRunController controller;

  @override
  final SeatLayerRunConfiguration configuration;

  /// The side the page boots on. A change reloads the page: runtime 1.0.0's
  /// run page has no command to repaint in place.
  final SeatLayerThemeMode? bootThemeMode;

  @internal
  final bool again;

  @internal
  final SeatLayerRunHandoff? resumed;

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
          if (again || resumed != null) ...<String, Object?>{
            'initialHoldId': resumed?.holdId,
            'initialOperationId': resumed?.operationId,
          },
        },
      );
}
