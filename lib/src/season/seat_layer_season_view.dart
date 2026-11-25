import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../bridge/bridge_profile.dart';
import '../payloads.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import '../seat_layer_runtime_host.dart';
import 'season_configuration.dart';
import 'season_models.dart';
import 'seat_layer_season_controller.dart';

/// The Season page in a web view: its package step, map and cart.
///
/// Give it a definite size, as the seat map. [SeatLayerSeasonPicker] places it
/// under the app's header; use this directly only for a layout of your own. The
/// page leaves the Season's name and the hold clock to the app: draw them from
/// [SeatLayerSeasonController.status] and [SeatLayerSeasonController.hold].
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
  })  : again = false,
        resumed = null;

  /// A page of the picker's. [again]: it takes the place of one that was up, so
  /// it opens on [resumed], not on the hold [configuration] opens on.
  @internal
  const SeatLayerSeasonView.inPicker({
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
  final SeatLayerSeasonController controller;

  @override
  final SeatLayerSeasonConfiguration configuration;

  /// The side the page boots on. A change reloads the page, so follow a later
  /// flip with [SeatLayerSeasonController.setThemeMode] instead.
  final SeatLayerThemeMode? bootThemeMode;

  @internal
  final bool again;

  @internal
  final SeatLayerSeasonHandoff? resumed;

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
          if (again || resumed != null)
            'initialOperationId': resumed?.operationId,
        },
      );
}
