/// The drop-in picker and the drawn map it hosts.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../bridge/bridge_profile.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_prewarm.dart';
import '../seat_layer_view.dart';
import 'picker_adaptive_layout.dart';
import 'picker_best_seats.dart';
import 'picker_builders.dart';
import 'picker_cart_list.dart';
import 'picker_options.dart';
import 'picker_system_overlay.dart';
import 'picker_theme_sync.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The complete buyer seat picker, ready to place on a route.
///
/// Everything below it is composable: each part is a public widget that works
/// standalone inside a [SeatLayerPickerScope], [options] hides any part, and
/// [builders] replaces one part while keeping the rest.
class SeatLayerPicker extends StatelessWidget {
  /// Creates a picker for [configuration], handing finished holds to
  /// [onCheckout].
  const SeatLayerPicker({
    super.key,
    required this.configuration,
    required this.onCheckout,
    this.controller,
    this.options = const SeatLayerPickerOptions(),
    this.theme,
    this.themeMode = SeatLayerThemeMode.auto,
    this.builders = const SeatLayerPickerBuilders(),
    this.callbacks = const SeatLayerPickerCallbacks(),
    this.onClose,
  });

  /// What event to load and how.
  final SeatLayerConfiguration configuration;

  /// Receives the hold when the buyer continues to checkout.
  final SeatLayerCheckoutCallback onCheckout;

  /// The session driver, or null to let the picker own one.
  final SeatLayerPickerController? controller;

  /// Behaviour switches for the session and its chrome.
  final SeatLayerPickerOptions options;

  /// Explicit colours; these win over the resolved [themeMode].
  final SeatLayerPickerThemeData? theme;

  /// Which side of the theme to paint.
  ///
  /// [SeatLayerThemeMode.auto] follows the device live: a system light/dark
  /// flip repaints the chrome and the drawn map with no reload and no lost
  /// selection. The resolved side is also what crosses the bridge.
  final SeatLayerThemeMode themeMode;

  /// Replacements for individual parts of the default composition.
  final SeatLayerPickerBuilders builders;

  /// Session lifecycle callbacks.
  final SeatLayerPickerCallbacks callbacks;

  /// Called when the buyer dismisses the picker; omit to hide the control.
  final VoidCallback? onClose;

  /// Start the runtime page now, so a picker opened later mounts onto it.
  ///
  /// **Call this from the screen the buyer is already on** — the event
  /// details page, the moment it appears. Opening the picker costs a WebView
  /// process start and a document fetch before the runtime has said a word;
  /// measured on the Reference app pilot that is most of the wait, and all of it
  /// can happen while the buyer is still reading. There is no event and no
  /// buyer token involved: only the immutable page is loaded, and everything
  /// about the session still travels at `init` when the picker opens.
  ///
  /// Idempotent, and safe to call from `initState` or a build. Calling it
  /// again for a page that is already warm only refreshes how long it is
  /// kept.
  ///
  /// The page is thrown away if nothing claims it within [ttl], and
  /// immediately if the platform reports memory pressure — a convenience must
  /// never be what gets the host application killed. Nothing is left behind
  /// if the buyer never opens the picker.
  ///
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   SeatLayerPicker.prewarm();
  /// }
  /// ```
  ///
  /// Pass [configuration] only if you point the SDK at a document of your own;
  /// the default is the hosted runtime page every production view loads. A
  /// bundled asset fixture is ignored, having nothing to gain.
  static void prewarm({
    SeatLayerConfiguration? configuration,
    Duration ttl = seatLayerPrewarmDefaultTtl,
  }) =>
      SeatLayerRuntimePrewarm.start(
        configuration?.assetPath ?? SeatLayerConfiguration.defaultAssetPath,
        ttl: ttl,
      );

  /// Throw away any page [prewarm] started that nothing has claimed.
  ///
  /// Rarely needed — a warm page expires on its own and is dropped under
  /// memory pressure. Reach for it when the buyer has demonstrably left, for
  /// example on the way out of a whole event flow.
  static void cancelPrewarm({SeatLayerConfiguration? configuration}) =>
      SeatLayerRuntimePrewarm.discard(
        configuration?.assetPath ?? SeatLayerConfiguration.defaultAssetPath,
      );

  @override
  Widget build(BuildContext context) => SeatLayerPickerScope(
        configuration: configuration,
        controller: controller,
        options: options,
        theme: theme,
        themeMode: themeMode,
        callbacks: callbacks,
        // The bars are dressed from inside the scope, so the style follows
        // everything the palette does: an `auto` device flip, the organizer's
        // branding arriving, and the immersive scene coming up.
        child: PickerSystemOverlay(
          child: SeatLayerPickerAdaptiveLayout(
            onCheckout: onCheckout,
            onClose: onClose,
            builders: builders,
          ),
        ),
      );
}

/// The drawn seat map: geometry, seats, labels, hit testing and the 3D scene.
///
/// This is the only part of the picker that is not native chrome. Place it
/// inside a [SeatLayerPickerScope] to compose a layout of your own.
class SeatLayerPickerMap extends StatefulWidget {
  /// Creates the map surface.
  const SeatLayerPickerMap({super.key, this.backgroundColor});

  /// Fill behind the transparent canvas; defaults to the resolved map ground.
  final Color? backgroundColor;

  @override
  State<SeatLayerPickerMap> createState() => _SeatLayerPickerMapState();
}

class _SeatLayerPickerMapState extends State<SeatLayerPickerMap>
    with WidgetsBindingObserver {
  SeatLayerPickerController? _picker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _picker = SeatLayerPickerScope.controllerOf(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final picker = _picker;
    if (picker == null || !picker.state.isReady) return;
    final lifecycle = switch (state) {
      AppLifecycleState.resumed => 'resumed',
      AppLifecycleState.inactive => 'inactive',
      AppLifecycleState.paused => 'paused',
      AppLifecycleState.detached => 'detached',
      AppLifecycleState.hidden => 'hidden',
    };
    unawaited(picker.setLifecycle(lifecycle).catchError((_) {}));
    if (state == AppLifecycleState.resumed) {
      unawaited(picker.synchronize().catchError((_) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picker = SeatLayerPickerScope.controllerOf(context);
    final configuration = SeatLayerPickerScope.configurationOf(context);
    final options = SeatLayerPickerScope.optionsOf(context);
    final resolved = seatLayerPickerThemeOf(context);
    return ColoredBox(
      color: widget.backgroundColor ??
          resolved.mapBackground ??
          resolved.background,
      child: PickerThemeModeSync(
        // Everything in this config is part of the bridge profile, and a
        // changed profile reboots the runtime. Nothing here may follow the
        // device's appearance: the boot theme is frozen per reload generation
        // and a flip travels as `picker.setThemeMode`.
        builder: (context, boot) => SeatLayerView(
          key: ValueKey<int>(picker.reloadGeneration),
          controller: picker.mapController,
          configuration: configuration,
          bridgeProfile: SeatLayerBridgeProfile.picker(
            config: <String, Object?>{
              ...options.toBridgeConfig(),
              'theme': <String, Object?>{'mode': boot.mode.raw},
              if (boot.mapTheme != null)
                'mapTheme': boot.mapTheme!.toBridgeConfig(),
            },
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

/// The drawn seat map, under the documented composable name.
///
/// [SeatLayerPickerMap] and [SeatLayerChart] are the same widget; the short
/// name is the one the composable recipe uses.
typedef SeatLayerChart = SeatLayerPickerMap;

/// The dense ticket list, under its dev.4 name.
@Deprecated('Renamed to SeatLayerCartList; the alias goes away at 0.4.')
typedef SeatLayerPickerSelectionTray = SeatLayerCartList;

/// The best-available form, under its dev.4 name.
@Deprecated('Renamed to SeatLayerBestSeatsForm; the alias goes away at 0.4.')
typedef SeatLayerPickerBestAvailablePanel = SeatLayerBestSeatsForm;
