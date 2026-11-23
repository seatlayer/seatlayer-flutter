import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bridge/bridge_profile.dart';
import 'payloads.dart';
import 'seat_layer_configuration.dart';
import 'seat_layer_controller.dart';
import 'seat_layer_error.dart';
import 'seat_layer_runtime_host.dart';

export 'seat_layer_runtime_host.dart' show prepareSeatLayerRuntimeReload;

/// A seat map.
///
/// Renders the SeatLayer venue map and drives the chart through the supplied
/// [SeatLayerController].
///
/// ## Known constraint (v0.1)
///
/// The map must be a FIXED-HEIGHT or full-screen box. Do NOT place it inside a
/// scrolling container ([ListView], [SingleChildScrollView], …). The canvas
/// consumes pan and pinch to drive its own zoom, so an enclosing scroll view and
/// the map fight over every gesture and neither behaves. Give it a definite
/// size and let the map own the space it occupies. The map claims a touch on
/// press, so it — not Flutter — wins those gestures; inside the turnkey picker
/// it resigns the presses that landed on the native chrome standing over it.
class SeatLayerView extends SeatLayerRuntimeHost {
  const SeatLayerView({
    super.key,
    required this.controller,
    required this.configuration,
    this.onReady,
    this.onLoadError,
    this.backgroundColor,
    this.bridgeProfile = SeatLayerBridgeProfile.chart,
  });

  /// The controller that exposes the chart's commands and event streams. Create
  /// it in your `State`, keep it, and `dispose()` it.
  @override
  final SeatLayerController controller;

  /// What chart to load and how.
  @override
  final SeatLayerConfiguration configuration;

  /// Called once `sys.ready` arrives. The same value is delivered on
  /// [SeatLayerController.onReady].
  @override
  final void Function(ReadyInfo info)? onReady;

  /// Called if the map cannot start — an incompatible renderer, a timeout, or
  /// a failure to reach it.
  @override
  final void Function(SeatLayerError error)? onLoadError;

  /// Fill color behind the (transparent) web content.
  @override
  final Color? backgroundColor;

  /// Internal surface contract. Ordinary integrations should leave this at the
  /// raw chart default; [SeatLayerPickerMap] supplies the picker-v2 profile.
  @internal
  @override
  final SeatLayerBridgeProfile bridgeProfile;
}
