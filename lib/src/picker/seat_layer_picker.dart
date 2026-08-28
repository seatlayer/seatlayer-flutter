/// The drop-in picker and the drawn map it hosts.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../bridge/bridge_profile.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_prewarm.dart';
import '../seat_layer_view.dart';
import 'picker_adaptive_layout.dart';
import 'picker_availability.dart';
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

  /// Register this on your `MaterialApp` so the picker notices a route coming
  /// back:
  ///
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: <NavigatorObserver>[SeatLayerPicker.routeObserver],
  ///   home: const MyHome(),
  /// )
  /// ```
  ///
  /// Pushing a checkout screen over the picker leaves it mounted and alive but
  /// no longer looking: the application never backgrounded, so no lifecycle
  /// event fires, and a buyer who backs out of checkout returns to a map that
  /// was last true when they left it. With this observer registered the picker
  /// re-reads availability on `didPopNext`, which is the exact moment it is in
  /// front again.
  ///
  /// Entirely optional. Without it the picker simply never receives the route
  /// callbacks — no exception, no assertion, and the lifecycle trigger still
  /// covers the buyer leaving the application. Turn both off with
  /// [SeatLayerPickerOptions.refreshOnResume].
  ///
  /// One observer for the whole application: a `RouteObserver` may be attached
  /// to only one Navigator, and every picker in the app subscribes to this one.
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();

  /// Start the runtime page now, so a picker opened later mounts onto it.
  ///
  /// **Call this from the screen the buyer is already on** — the event details
  /// page, the moment it appears — so the picker opens without a delay. There
  /// is no event and no buyer token involved: only the immutable page is
  /// loaded, and everything about the session still travels at `init` when the
  /// picker opens.
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
  /// Pass [configuration] only if you have pointed the SDK somewhere of your
  /// own with `assetPath`; the default is the renderer this SDK release is
  /// pinned to. A bundled asset fixture is ignored, having nothing to gain.
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
          child: _PickerRouteResume(
            child: SeatLayerPickerAdaptiveLayout(
              onCheckout: onCheckout,
              onClose: onClose,
              builders: builders,
            ),
          ),
        ),
      );
}

/// Refreshes availability when a route pushed over the picker pops back.
///
/// Deliberately a separate widget rather than more work inside
/// [SeatLayerPickerMap]: the map owns the application lifecycle, this owns the
/// navigator, and the two triggers fire in different circumstances — a payment
/// sheet pushed in-app never backgrounds anything.
class _PickerRouteResume extends StatefulWidget {
  const _PickerRouteResume({required this.child});

  final Widget child;

  @override
  State<_PickerRouteResume> createState() => _PickerRouteResumeState();
}

class _PickerRouteResumeState extends State<_PickerRouteResume>
    with RouteAware {
  ModalRoute<dynamic>? _subscribedTo;
  SeatLayerPickerController? _picker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read here rather than from the callback: `didPopNext` runs outside a
    // build, and taking an inherited dependency there is how a widget ends up
    // subscribed to a scope it is no longer under.
    _picker = SeatLayerPickerScope.controllerOf(context);
    final route = ModalRoute.of(context);
    if (identical(route, _subscribedTo)) return;
    if (_subscribedTo != null) SeatLayerPicker.routeObserver.unsubscribe(this);
    _subscribedTo = null;
    // Only a PageRoute: the observer is typed to those, and a picker inside a
    // dialog or a bottom sheet has no "came back" moment of this kind.
    if (route is PageRoute<dynamic>) {
      SeatLayerPicker.routeObserver.subscribe(this, route);
      _subscribedTo = route;
    }
  }

  @override
  void didPopNext() {
    // Reached only when the host registered `SeatLayerPicker.routeObserver`;
    // an unregistered observer never calls back, which is the silent degrade.
    final picker = _picker;
    if (!mounted || picker == null) return;
    if (!picker.options.refreshOnResume) return;
    unawaited(picker.refreshAvailability().catchError(
          (Object _) => const SeatLayerAvailabilityRefresh.unsupported(),
        ));
  }

  @override
  void dispose() {
    if (_subscribedTo != null) SeatLayerPicker.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
    unawaited(
      _announceLifecycle(
        picker,
        lifecycle,
        resumed: state == AppLifecycleState.resumed,
      ),
    );
  }

  /// Tell the runtime where the application went, and catch up if it did not.
  ///
  /// Strictly sequential, and that is the point. A foreground
  /// `picker.lifecycle` re-reads availability inside the runtime and CONSUMES
  /// what it finds — it is the call that clears a hold which ran out while the
  /// application was away. Firing an independent `picker.refreshAvailability`
  /// alongside it would race: whichever landed second would be told the hold
  /// was fine, and the buyer would come back to seats that were simply gone
  /// with nothing offered back. The lifecycle reply is therefore read first,
  /// and a second read happens only when that reply carried none — an older
  /// runtime, which answers with its state and nothing else.
  Future<void> _announceLifecycle(
    SeatLayerPickerController picker,
    String lifecycle, {
    required bool resumed,
  }) async {
    var outcome = const SeatLayerAvailabilityRefresh.unsupported();
    try {
      outcome = await picker.setLifecycle(lifecycle);
    } catch (_) {
      // Reporting the lifecycle is best effort; the catch-up below still runs.
    }
    if (!resumed || outcome.refreshed) return;
    try {
      // A refresh already answers with a snapshot, so on a runtime that can do
      // one there is nothing left for `picker.getSnapshot` to fetch. Sending
      // both would be two round trips and two revisions for one answer, and
      // the refresh is the one that also reports what the buyer lost.
      if (picker.options.refreshOnResume &&
          picker.supportsAvailabilityRefresh) {
        await picker.refreshAvailability();
      } else {
        await picker.synchronize();
      }
    } catch (_) {
      // Catching up is housekeeping. A buyer mid-session is not shown a red
      // panel because a background poll missed.
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
