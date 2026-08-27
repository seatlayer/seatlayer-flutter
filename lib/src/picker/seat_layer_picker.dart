import 'dart:async';

import 'package:flutter/material.dart';

import '../bridge/bridge_profile.dart';
import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_error.dart';
import '../seat_layer_view.dart';
import 'picker_builders.dart';
import 'picker_best_seats.dart';
import 'picker_cart_list.dart';
import 'picker_cart_sheet.dart';
import 'picker_confirm_card.dart';
import 'picker_dock_bar.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
import 'picker_theme_sync.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_components.dart';
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

  @override
  Widget build(BuildContext context) => SeatLayerPickerScope(
        configuration: configuration,
        controller: controller,
        options: options,
        theme: theme,
        themeMode: themeMode,
        callbacks: callbacks,
        child: SeatLayerPickerAdaptiveLayout(
          onCheckout: onCheckout,
          onClose: onClose,
          builders: builders,
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
    final brightness = SeatLayerPickerScope.brightnessOf(context);
    final resolved = seatLayerPickerThemeOf(context);
    final mapTheme = resolveSeatLayerMapTheme(
      context,
      SeatLayerPickerScope.themeOf(context),
      brightness: brightness,
    );
    return ColoredBox(
      color: widget.backgroundColor ??
          resolved.mapBackground ??
          resolved.background,
      child: PickerThemeModeSync(
        builder: (context, bootMode) => SeatLayerView(
          key: ValueKey<int>(picker.reloadGeneration),
          controller: picker.mapController,
          configuration: configuration,
          bridgeProfile: SeatLayerBridgeProfile.picker(
            config: <String, Object?>{
              ...options.toBridgeConfig(),
              'theme': <String, Object?>{'mode': bootMode.raw},
              if (mapTheme != null) 'mapTheme': mapTheme.toBridgeConfig(),
            },
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

class SeatLayerPickerHeader extends StatelessWidget {
  const SeatLayerPickerHeader({
    super.key,
    this.onClose,
    this.showEventDetails = true,
    this.compact = false,
  });

  final VoidCallback? onClose;
  final bool showEventDetails;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final event = state.event;
    final options = SeatLayerPickerScope.optionsOf(context);
    return Material(
      color: theme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 16,
            compact ? 6 : 10,
            compact ? 4 : 10,
            compact ? 6 : 10,
          ),
          child: Row(
            children: [
              _PickerBrandMark(
                theme: theme,
                state: state,
                size: compact ? 22 : 36,
              ),
              SizedBox(width: compact ? 8 : 12),
              Expanded(
                child: showEventDetails && !options.hideEventDetails
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event?.name ?? 'Choose your seats',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.text,
                              fontSize: compact ? 13 : 16,
                              fontWeight: FontWeight.w800,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                          if (!compact && event?.venue != null)
                            Text(
                              event!.venue!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.mutedText,
                                fontSize: 12,
                                fontFamily: theme.fontFamily,
                              ),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              if (onClose != null)
                IconButton(
                  tooltip: 'Close seat selection',
                  onPressed: onClose,
                  color: theme.text,
                  visualDensity:
                      compact ? VisualDensity.compact : VisualDensity.standard,
                  constraints: compact
                      ? const BoxConstraints.tightFor(width: 26, height: 26)
                      : null,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close_rounded, size: compact ? 19 : 24),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerBrandMark extends StatelessWidget {
  const _PickerBrandMark({
    required this.theme,
    required this.state,
    required this.size,
  });
  final SeatLayerResolvedPickerTheme theme;
  final SeatLayerPickerState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final provider = theme.logo;
    final url = state.branding?.logoUrl;
    if (provider != null || url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size < 30 ? 6 : 10),
        child: Image(
          image: provider ?? NetworkImage(url!),
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.accent,
          borderRadius: BorderRadius.circular(size < 30 ? 6 : 10),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.event_seat_rounded,
            size: size * .56,
            color: theme.onAccent,
          ),
        ),
      );
}

class SeatLayerPickerTestModeIndicator extends StatelessWidget {
  const SeatLayerPickerTestModeIndicator({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (!state.isTestEvent) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    return Semantics(
      label: 'Test event. No real inventory will be booked.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.warning,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 8),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 4 : 6,
          ),
          child: Text(
            compact ? 'TEST MODE' : 'TEST MODE · BOOKS NOTHING',
            style: const TextStyle(
              color: Color(0xFF1A1200),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ),
      ),
    );
  }
}

class SeatLayerPickerPriceRail extends StatelessWidget {
  const SeatLayerPickerPriceRail({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final categories = state.categories
        .where((category) => !category.notForSale)
        .toList(growable: false);
    if (categories.isEmpty) return const SizedBox.shrink();
    return Material(
      color: theme.surface,
      child: SizedBox(
        height: compact ? 40 : 64,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 5 : 9,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            final selected =
                state.snapshot?.map.categoryFilter.contains(category.key) ??
                    false;
            return FilterChip(
              selected: selected,
              showCheckmark: false,
              visualDensity:
                  compact ? VisualDensity.compact : VisualDensity.standard,
              materialTapTargetSize: compact
                  ? MaterialTapTargetSize.shrinkWrap
                  : MaterialTapTargetSize.padded,
              side: BorderSide(
                color: selected ? theme.accent : theme.divider,
              ),
              backgroundColor: theme.surface,
              selectedColor: theme.accent,
              avatar: DecoratedBox(
                decoration: BoxDecoration(
                  color: _parseColor(category.color) ?? theme.accent,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 10, height: 10),
              ),
              label: Text(
                compact
                    ? _compactMoney(
                        category.priceMin,
                        state.snapshot?.currency ?? 'USD',
                      )
                    : '${category.label} · ${_money(context, category.priceMin, state.snapshot?.currency ?? 'USD')}',
                style: TextStyle(
                  color: selected ? theme.onAccent : theme.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              onSelected: (_) {
                final active =
                    selected ? const <String>{} : <String>{category.key};
                _ignoreAction(
                  controller.setCategoryFilter(
                    active,
                    focus: !selected,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SeatLayerPickerFloorSelector extends StatelessWidget {
  const SeatLayerPickerFloorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final floors = state.snapshot?.floors ?? const [];
    if (floors.length < 2) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _alpha(theme.surface, .94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: state.snapshot?.map.floorId,
            hint: const Text('Floor'),
            items: floors
                .map(
                  (floor) => DropdownMenuItem<String>(
                    value: floor.id,
                    child: Text(floor.name),
                  ),
                )
                .toList(),
            onChanged: (floorId) {
              if (floorId != null) {
                _ignoreAction(controller.setFloor(floorId));
              }
            },
          ),
        ),
      ),
    );
  }
}

class SeatLayerPickerMapControls extends StatelessWidget {
  const SeatLayerPickerMapControls({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final map = state.snapshot?.map;
    final options = SeatLayerPickerScope.optionsOf(context);
    final chrome = options.chrome;
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chrome.overviewControlFor(phone: compact) &&
              map?.focusedSection != null)
            const SeatLayerPickerOverviewButton(),
          if (chrome.zoomControlsFor(phone: compact)) ...[
            const SeatLayerPickerZoomInButton(),
            const SeatLayerPickerZoomOutButton(),
          ],
          if (chrome.showZoomToFitControl)
            const SeatLayerPickerZoomToFitButton(),
          if (chrome.showViewModeControl &&
              options.enable3D &&
              state.snapshot?.capabilities.contains('venue3d') == true)
            const SeatLayerPickerViewModeButton(),
          if (state.snapshot?.map.isVenue3D == true)
            const SeatLayerPicker3DNavigationModeButton(),
          if (chrome.colorblindControlFor(phone: compact))
            const SeatLayerPickerColorblindButton(),
        ]
            .map(
              (control) => Padding(
                padding: EdgeInsets.only(bottom: compact ? 6 : 7),
                child: control,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

/// A standalone back-to-venue control for custom picker compositions.
class SeatLayerPickerOverviewButton extends StatelessWidget {
  const SeatLayerPickerOverviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    return _ControlButton(
      icon: Icons.arrow_back_rounded,
      tooltip: 'Back to venue',
      onPressed: controller.overview,
    );
  }
}

/// A standalone zoom-in control for custom picker compositions.
class SeatLayerPickerZoomInButton extends StatelessWidget {
  const SeatLayerPickerZoomInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final map = controller.state.snapshot?.map;
    return _ControlButton(
      icon: Icons.add_rounded,
      tooltip: 'Zoom in',
      onPressed: map?.canZoomIn == false ? null : controller.zoomIn,
    );
  }
}

/// A standalone zoom-out control for custom picker compositions.
class SeatLayerPickerZoomOutButton extends StatelessWidget {
  const SeatLayerPickerZoomOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final map = controller.state.snapshot?.map;
    return _ControlButton(
      icon: Icons.remove_rounded,
      tooltip: 'Zoom out',
      onPressed: map?.canZoomOut == false ? null : controller.zoomOut,
    );
  }
}

/// A standalone fit-to-venue control for custom picker compositions.
class SeatLayerPickerZoomToFitButton extends StatelessWidget {
  const SeatLayerPickerZoomToFitButton({super.key});

  @override
  Widget build(BuildContext context) => _ControlButton(
        icon: Icons.center_focus_strong_rounded,
        tooltip: 'Fit venue',
        onPressed: SeatLayerPickerScope.controllerOf(context).zoomToFit,
      );
}

/// A standalone Map / real venue-3D toggle for custom picker compositions.
///
/// The old implementation changed only the canvas projection. This control now
/// drives the same lazy WebGL venue scene and gesture system as the web picker.
class SeatLayerPickerViewModeButton extends StatelessWidget {
  const SeatLayerPickerViewModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final is3D = controller.state.snapshot?.map.isVenue3D ?? false;
    final available =
        controller.state.snapshot?.capabilities.contains('venue3d') == true;
    if (!available) return const SizedBox.shrink();
    return _ControlButton(
      icon: is3D ? Icons.map_outlined : Icons.view_in_ar_rounded,
      tooltip: is3D ? 'Back to seat map' : 'Open interactive 3D venue',
      active: is3D,
      onPressed: controller.state.isBusy
          ? null
          : () => controller.setBuyerView(
                is3D ? SeatLayerBuyerView.map : SeatLayerBuyerView.venue3D,
              ),
    );
  }
}

/// Rotate / Move toggle for the active real venue-3D camera.
///
/// Pinch-to-zoom and two-finger movement remain available in both modes; this
/// explicit control makes the primary one-finger gesture discoverable and can
/// be placed anywhere by a custom composition.
class SeatLayerPicker3DNavigationModeButton extends StatelessWidget {
  const SeatLayerPicker3DNavigationModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final map = controller.state.snapshot?.map;
    if (map?.isVenue3D != true) return const SizedBox.shrink();
    final moving = map!.view3DNavigationMode == SeatLayer3DNavigationMode.move;
    return _ControlButton(
      icon: moving ? Icons.open_with_rounded : Icons.threesixty_rounded,
      tooltip: moving ? 'Drag to move venue' : 'Drag to rotate venue',
      active: true,
      onPressed: controller.state.isBusy
          ? null
          : () => controller.set3DNavigationMode(
                moving
                    ? SeatLayer3DNavigationMode.rotate
                    : SeatLayer3DNavigationMode.move,
              ),
    );
  }
}

/// A standalone colorblind-safe map toggle for custom picker compositions.
class SeatLayerPickerColorblindButton extends StatelessWidget {
  const SeatLayerPickerColorblindButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final active = controller.state.snapshot?.map.colorblindSafe ?? false;
    return _ControlButton(
      icon: Icons.visibility_rounded,
      tooltip: 'Colorblind-safe colors',
      active: active,
      onPressed: () => controller.setColorblindSafe(!active),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function()? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedContainer(
      duration:
          reducedMotion ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Color.alphaBlend(_alpha(theme.accent, .13), theme.surface)
            : _alpha(theme.surface, .94),
        border: Border.all(
          color: active ? _alpha(theme.accent, .52) : theme.divider,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          padding: EdgeInsets.zero,
          onPressed:
              onPressed == null ? null : () => _ignoreAction(onPressed!()),
          icon: AnimatedSwitcher(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 170),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: .82, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: Icon(
              icon,
              key: ValueKey<String>('${icon.codePoint}:$active'),
              size: 20,
              color: active ? theme.accent : theme.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// The dense ticket list, under its dev.4 name.
@Deprecated('Renamed to SeatLayerCartList; the alias goes away at 0.4.')
typedef SeatLayerPickerSelectionTray = SeatLayerCartList;

/// The best-available form, under its dev.4 name.
@Deprecated('Renamed to SeatLayerBestSeatsForm; the alias goes away at 0.4.')
typedef SeatLayerPickerBestAvailablePanel = SeatLayerBestSeatsForm;

/// How long the buyer's seats stay held.
class SeatLayerPickerHoldCountdown extends StatefulWidget {
  const SeatLayerPickerHoldCountdown({super.key});

  @override
  State<SeatLayerPickerHoldCountdown> createState() =>
      _SeatLayerPickerHoldCountdownState();
}

class _SeatLayerPickerHoldCountdownState
    extends State<SeatLayerPickerHoldCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (state.hold == null) return const SizedBox.shrink();
    final remaining = state.holdRemaining(DateTime.now());
    final minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      semanticsLabel:
          '${remaining.inMinutes} minutes $seconds seconds remaining',
      style: const TextStyle(fontWeight: FontWeight.w800),
    );
  }
}

class SeatLayerPickerCheckoutBar extends StatelessWidget {
  const SeatLayerPickerCheckoutBar({
    super.key,
    required this.onCheckout,
  });

  final SeatLayerCheckoutCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    return Material(
      color: theme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: theme.mutedText, fontSize: 11),
                    ),
                    Text(
                      _money(
                        context,
                        state.snapshot?.cartTotal ?? 0,
                        state.snapshot?.currency ?? 'USD',
                      ),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.accent,
                  foregroundColor: theme.onAccent,
                  minimumSize: const Size(156, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(theme.radius),
                  ),
                ),
                onPressed: controller.canCheckout
                    ? () => _ignoreAction(
                          _checkoutWithRejection(controller, onCheckout),
                        )
                    : null,
                child:
                    state.busyAction == SeatLayerPickerBusyAction.creatingHold
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SeatLayerPickerLoadingView extends StatelessWidget {
  const SeatLayerPickerLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading seat map…'),
          ],
        ),
      );
}

class SeatLayerPickerErrorView extends StatelessWidget {
  const SeatLayerPickerErrorView({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final error = controller.state.error;
    final message = error is SeatLayerError
        ? error.message
        : 'The seat map could not be loaded.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry ?? () => _ignoreAction(controller.retry()),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class SeatLayerPickerEmptyView extends StatelessWidget {
  const SeatLayerPickerEmptyView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No selectable seats are currently available.'),
        ),
      );
}

class SeatLayerPickerAdaptiveLayout extends StatefulWidget {
  const SeatLayerPickerAdaptiveLayout({
    super.key,
    required this.onCheckout,
    this.onClose,
    this.builders = const SeatLayerPickerBuilders(),
  });

  final SeatLayerCheckoutCallback onCheckout;
  final VoidCallback? onClose;
  final SeatLayerPickerBuilders builders;

  @override
  State<SeatLayerPickerAdaptiveLayout> createState() =>
      _SeatLayerPickerAdaptiveLayoutState();
}

class _SeatLayerPickerAdaptiveLayoutState
    extends State<SeatLayerPickerAdaptiveLayout> {
  final GlobalKey _mapKey = GlobalKey(debugLabel: 'seatlayer-picker-map');
  final Set<String> _confirmedLabels = <String>{};
  bool _mobilePanelExpanded = false;
  bool _mobilePanelInitialized = false;
  bool _mapInteractionEnabled = true;
  int _mapInteractionGeneration = 0;
  String? _previousRung;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mobilePanelInitialized) return;
    _mobilePanelExpanded =
        !SeatLayerPickerScope.optionsOf(context).panelInitiallyCollapsed;
    _mobilePanelInitialized = true;
  }

  Widget _part(
    BuildContext context,
    SeatLayerPickerPartBuilder? builder,
    Widget child,
  ) {
    if (builder == null) return child;
    final controller = SeatLayerPickerScope.controllerOf(context);
    return builder(
      context,
      SeatLayerPickerPartContext(
        state: controller.state,
        controller: controller,
        defaultChild: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final resolved = seatLayerPickerThemeOf(context);
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final requested = SeatLayerPickerScope.optionsOf(context).layout;
        final wide = requested == SeatLayerPickerLayoutMode.wide ||
            (requested == SeatLayerPickerLayoutMode.adaptive &&
                constraints.maxWidth >= 840);
        final options = SeatLayerPickerScope.optionsOf(context);
        final chrome = options.chrome;
        final map = _part(
          context,
          widget.builders.map,
          SeatLayerPickerMap(key: _mapKey),
        );
        final header = _part(
          context,
          widget.builders.header,
          chrome.showHeader
              ? SeatLayerPickerHeader(
                  onClose: widget.onClose,
                  compact: !wide,
                )
              : const SizedBox.shrink(),
        );
        final prices = _part(
          context,
          widget.builders.legend ?? widget.builders.priceRail,
          chrome.showPriceRail
              ? SeatLayerPickerPriceRail(compact: !wide)
              : const SizedBox.shrink(),
        );
        final sections = _part(
          context,
          widget.builders.sectionNavigator,
          const SeatLayerPickerSectionNavigator(),
        );
        final dock = _part(
          context,
          widget.builders.dockBar,
          SeatLayerDockBar(
            onSectionChanged: SeatLayerPickerScope.callbacksOf(context)
                .onSectionFocused,
            // The cart sheet below already reserves the device inset.
            reserveBottomInset: !chrome.showTicketPanel,
          ),
        );
        final accessibility = _part(
          context,
          widget.builders.accessibilityFilters,
          chrome.showAccessibilityControl
              ? SeatLayerPickerAccessibilityFilters(compact: !wide)
              : const SizedBox.shrink(),
        );
        final tray = _part(
          context,
          widget.builders.selectionTray,
          SeatLayerCartList(compact: !wide),
        );
        final checkout = _part(
          context,
          widget.builders.checkoutBar,
          wide
              ? SeatLayerPickerCheckoutBar(onCheckout: widget.onCheckout)
              : SeatLayerBookButton(onCheckout: widget.onCheckout),
        );
        final sheet = _part(
          context,
          widget.builders.cartSheet,
          SeatLayerCartSheet(
            expanded: _mobilePanelExpanded,
            onExpandedChanged: (expanded) {
              if (_mobilePanelExpanded == expanded) return;
              setState(() => _mobilePanelExpanded = expanded);
            },
            onCheckout: _checkoutAndAnnounce,
            bestSeats: null,
            cartList: null,
            checkoutBar: null,
            actionError: null,
          ),
        );
        final testBadge = SeatLayerPickerTestModeIndicator(compact: !wide);
        final controls = _part(
          context,
          widget.builders.mapControls,
          chrome.showMapControls
              ? SeatLayerPickerMapControls(compact: !wide)
              : const SizedBox.shrink(),
        );
        final best = _part(
          context,
          widget.builders.bestAvailable,
          const SeatLayerBestSeatsForm(),
        );
        const attribution = SeatLayerPickerAttribution();
        final actionError = _part(
          context,
          widget.builders.actionError,
          const SeatLayerPickerActionError(),
        );

        final selectedLabels =
            state.selection.map((seat) => seat.label).toSet();
        _confirmedLabels.removeWhere(
          (label) => !selectedLabels.contains(label),
        );
        final pendingSeat =
            !options.readOnly && state.hold == null && options.confirmSelection
                ? state.selection.reversed
                    .where((seat) => !_confirmedLabels.contains(seat.label))
                    .firstOrNull
                : null;
        // The sheet never opens itself: a sheet that springs up on every pick
        // covers the map the buyer is still choosing from. It does collapse
        // itself when a seat card opens over the map, which is the tap the
        // runtime does report to native chrome.
        if (pendingSeat != null && _mobilePanelExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _mobilePanelExpanded) {
              setState(() => _mobilePanelExpanded = false);
            }
          });
        }
        _followRungToPeek(state);
        final Widget? buyerPrompt;
        if (!options.readOnly && state.generalAdmissionCandidate != null) {
          buyerPrompt = _part(
            context,
            widget.builders.generalAdmissionPrompt,
            const SeatLayerPickerGeneralAdmissionPrompt(),
          );
        } else if (pendingSeat?.objectType == ObjectType.table &&
            pendingSeat?.bookingMode == 'variable') {
          buyerPrompt = _part(
            context,
            widget.builders.tablePrompt,
            SeatLayerPickerTablePrompt(
              key: ValueKey<String>(pendingSeat!.label),
              table: pendingSeat,
              onConfirm: _confirmSeat,
              onCancel: (seat) => _removeSeat(controller, seat.label),
            ),
          );
        } else if (pendingSeat != null && chrome.showConfirmCard) {
          final capabilities = state.snapshot?.capabilities ?? const <String>{};
          final onViewFromSeat =
              options.enableSeatView && capabilities.contains('seatView')
                  ? (SelectedSeat seat) => _inspectSeat(
                        seat,
                        () => controller.openSeatView(seat),
                      )
                  : null;
          final onShow3D =
              options.enable3D && capabilities.contains('venue3d')
                  ? (SelectedSeat seat) => _inspectSeat(
                        seat,
                        () => controller.showSeatIn3D(seat),
                      )
                  : null;
          // The phone gets the one-line card; the wide layout keeps the
          // identity grid, which has the room for it.
          buyerPrompt = wide
              ? _part(
                  context,
                  widget.builders.seatConfirmation,
                  SeatLayerPickerSeatConfirmation(
                    key: ValueKey<String>(pendingSeat.label),
                    seat: pendingSeat,
                    onConfirm: _confirmSeat,
                    onCancel: (seat) => _removeSeat(controller, seat.label),
                    onViewFromSeat: onViewFromSeat,
                    onShow3D: onShow3D,
                  ),
                )
              : _part(
                  context,
                  widget.builders.confirmCard ??
                      widget.builders.seatConfirmation,
                  SeatLayerConfirmCard(
                    key: ValueKey<String>(pendingSeat.label),
                    seat: pendingSeat,
                    onConfirm: _confirmSeat,
                    onCancel: (seat) => _removeSeat(controller, seat.label),
                    onViewFromSeat: onViewFromSeat,
                    onShow3D: onShow3D,
                  ),
                );
        } else {
          buyerPrompt = null;
        }
        final Widget? statusOverlay = switch (state.phase) {
          SeatLayerPickerPhase.initializing => ColoredBox(
              color: _alpha(resolved.background, .84),
              child: _part(
                context,
                widget.builders.loading,
                const SeatLayerPickerLoadingView(),
              ),
            ),
          SeatLayerPickerPhase.failed ||
          SeatLayerPickerPhase.unavailable =>
            ColoredBox(
              color: _alpha(resolved.background, .94),
              child: _part(
                context,
                widget.builders.error,
                const SeatLayerPickerErrorView(),
              ),
            ),
          _ => null,
        };
        final mapSurface = IgnorePointer(
          // Platform views participate in iOS gesture recognition before the
          // Flutter overlay's onPressed callback runs. Explicitly remove the
          // WebView from hit testing while any native decision surface owns
          // the map; visual stacking alone does not prevent tap-through.
          ignoring: buyerPrompt != null || statusOverlay != null,
          child: map,
        );
        _syncMapInteraction(
          controller,
          enabled: buyerPrompt == null && statusOverlay == null,
          unlockDelay: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 190),
        );

        if (wide) {
          return Column(
            children: [
              header,
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(child: mapSurface),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: testBadge,
                          ),
                          Positioned(top: 12, right: 12, child: controls),
                          if (chrome.showFloorSelector)
                            const Positioned(
                              left: 12,
                              bottom: 12,
                              child: SeatLayerPickerFloorSelector(),
                            ),
                          Positioned(
                            left: 12,
                            bottom: 58,
                            child: accessibility,
                          ),
                          Positioned.fill(
                            child: _PickerPromptTransition(
                              scrimColor: _alpha(resolved.background, .64),
                              child: buyerPrompt,
                            ),
                          ),
                          if (statusOverlay != null)
                            Positioned.fill(child: statusOverlay),
                        ],
                      ),
                    ),
                    Container(
                      width: 360,
                      decoration: BoxDecoration(
                        color: resolved.surface,
                        border:
                            Border(left: BorderSide(color: resolved.divider)),
                      ),
                      child: Column(
                        children: [
                          prices,
                          sections,
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                best,
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: accessibility,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(child: tray),
                          ),
                          actionError,
                          attribution,
                          checkout,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // The corner controls ride above the dock so neither covers the
        // other; the dock itself is edge-to-edge at the map's own bottom.
        final dockLift = _dockVisible(state)
            ? resolved.layout.dockBarHeight
            : 0.0;
        return Column(
          children: [
            header,
            prices,
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: mapSurface),
                  Positioned(top: 10, left: 10, child: testBadge),
                  if (chrome.showFloorSelector)
                    Positioned(
                      left: 10,
                      bottom: 10 + dockLift,
                      child: const SeatLayerPickerFloorSelector(),
                    ),
                  Positioned(right: 10, bottom: 10 + dockLift, child: controls),
                  Positioned(
                    left: 10,
                    bottom: 56 + dockLift,
                    child: accessibility,
                  ),
                  if (chrome.showDockBar)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: dock,
                    ),
                  Positioned.fill(
                    child: _PickerPromptTransition(
                      scrimColor: _alpha(resolved.background, .64),
                      child: buyerPrompt,
                    ),
                  ),
                  if (statusOverlay != null)
                    Positioned.fill(child: statusOverlay),
                ],
              ),
            ),
            if (chrome.showTicketPanel) sheet,
          ],
        );
      },
    );

    final canPop = !_ownsBackGesture(state);
    final themed = Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: resolved.accent,
              onPrimary: resolved.onAccent,
              surface: resolved.surface,
              onSurface: resolved.text,
            ),
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: resolved.fontFamily,
              bodyColor: resolved.text,
              displayColor: resolved.text,
            ),
      ),
      child: ColoredBox(color: resolved.background, child: body),
    );
    // The rung ladder. Android predictive back and the iOS edge swipe both
    // arrive here, so one gesture walks seat card → section → overview →
    // dismiss instead of leaving the picker on the buyer's first try out.
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _climbDown(controller, state);
      },
      child: themed,
    );
  }

  /// Whether the picker still has a rung of its own to descend.
  bool _ownsBackGesture(SeatLayerPickerState state) =>
      _mobilePanelExpanded ||
      _hasOpenPrompt(state) ||
      state.snapshot?.map.rung == 'seats';

  bool _hasOpenPrompt(SeatLayerPickerState state) {
    if (SeatLayerPickerScope.optionsOf(context).readOnly) return false;
    if (state.generalAdmissionCandidate != null) return true;
    if (!SeatLayerPickerScope.optionsOf(context).confirmSelection) return false;
    if (state.hold != null) return false;
    return state.selection
        .any((seat) => !_confirmedLabels.contains(seat.label));
  }

  /// One rung down, in the order the buyer built them up.
  void _climbDown(
    SeatLayerPickerController controller,
    SeatLayerPickerState state,
  ) {
    if (_mobilePanelExpanded) {
      setState(() => _mobilePanelExpanded = false);
      return;
    }
    if (_hasOpenPrompt(state)) {
      final pending = state.selection.reversed
          .where((seat) => !_confirmedLabels.contains(seat.label))
          .firstOrNull;
      if (state.generalAdmissionCandidate != null) {
        controller.dismissGeneralAdmissionCandidate();
        return;
      }
      if (pending != null) {
        _ignoreAction(_removeSeat(controller, pending.label));
        return;
      }
    }
    if (state.snapshot?.map.rung == 'seats') {
      _ignoreAction(controller.overview());
    }
  }

  bool _dockVisible(SeatLayerPickerState state) =>
      state.snapshot?.map.rung == 'seats' &&
      state.snapshot?.map.focusedSectionId != null;

  /// A return to the overview collapses the sheet with it.
  ///
  /// The runtime owns the backdrop tap — tapping the dimmed map outside the
  /// focused section is what produces the rung change — so watching the rung
  /// is how the native chrome hears about it without a new snapshot field.
  void _followRungToPeek(SeatLayerPickerState state) {
    final rung = state.snapshot?.map.rung;
    if (rung == null || rung == _previousRung) return;
    final descended = _previousRung == 'seats' && rung != 'seats';
    _previousRung = rung;
    if (!descended || !_mobilePanelExpanded) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _mobilePanelExpanded) {
        setState(() => _mobilePanelExpanded = false);
      }
    });
  }

  Future<void> _confirmSeat(SelectedSeat seat) async {
    if (!mounted) return;
    setState(() => _confirmedLabels.add(seat.label));
  }

  Future<void> _checkoutAndAnnounce(SeatLayerCheckoutHandoff handoff) async {
    SeatLayerPickerScope.callbacksOf(context).onContinue?.call(handoff);
    await widget.onCheckout(handoff);
  }

  void _syncMapInteraction(
    SeatLayerPickerController controller, {
    required bool enabled,
    required Duration unlockDelay,
  }) {
    if (_mapInteractionEnabled == enabled) return;
    _mapInteractionEnabled = enabled;
    final generation = ++_mapInteractionGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(() async {
        // Keep the runtime inert while the old card completes its exit. This
        // prevents a fast second tap from landing on the WebView through the
        // fading native surface. Locking is immediate; only unlocking waits.
        if (enabled && unlockDelay > Duration.zero) {
          await Future<void>.delayed(unlockDelay);
        }
        if (!mounted ||
            generation != _mapInteractionGeneration ||
            _mapInteractionEnabled != enabled) {
          return;
        }
        try {
          await controller.setMapInteractionEnabled(enabled);
        } catch (_) {
          // The existing Flutter hit-test gate remains the fallback for a
          // transport that disappears during route teardown.
        }
      }());
    });
  }

  Future<void> _inspectSeat(
    SelectedSeat seat,
    Future<void> Function() action,
  ) async {
    if (!mounted) return;
    try {
      await action();
      // Do not uncover the embedded platform view until the runtime confirms
      // its immersive surface is mounted. This also makes the card-to-view
      // animation a handoff instead of a flash through the raw map.
      if (mounted) setState(() => _confirmedLabels.add(seat.label));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _removeSeat(
    SeatLayerPickerController controller,
    String label,
  ) async {
    try {
      await controller.removeObject(label);
    } finally {
      if (mounted) setState(() => _confirmedLabels.add(label));
    }
  }
}

/// One motion language for every native decision surface: scrim, seat card,
/// GA/table prompts and their exit. The canvas remains mounted underneath, so
/// opening a card never resets camera state or causes a WebView flash.
class _PickerPromptTransition extends StatelessWidget {
  const _PickerPromptTransition({
    required this.scrimColor,
    required this.child,
  });

  final Color scrimColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final prompt = child;
    return IgnorePointer(
      ignoring: prompt == null,
      child: AnimatedSwitcher(
        duration: SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.enter),
        reverseDuration:
            SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.exit),
        switchInCurve: SeatLayerPickerMotion.easeEnter,
        switchOutCurve: SeatLayerPickerMotion.easeExit,
        transitionBuilder: (current, animation) {
          if (reducedMotion) return current;
          final eased = CurvedAnimation(
            parent: animation,
            curve: SeatLayerPickerMotion.easeEnter,
            reverseCurve: SeatLayerPickerMotion.easeExit,
          );
          return FadeTransition(
            opacity: eased,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(eased),
              child: ScaleTransition(
                scale: Tween<double>(begin: .965, end: 1).animate(eased),
                child: current,
              ),
            ),
          );
        },
        child: prompt == null
            ? const SizedBox.expand(key: ValueKey<String>('picker-prompt-none'))
            : ColoredBox(
                key: ValueKey<Object>(
                  (prompt.runtimeType, prompt.key ?? prompt.runtimeType),
                ),
                color: scrimColor,
                // Each prompt owns its own insets: the phone confirm card is
                // specified as the screen less one 16pt gutter, and a shared
                // outer padding would quietly narrow it.
                child: Center(child: prompt),
              ),
      ),
    );
  }
}

String _money(BuildContext context, double amount, String currency) {
  final formatter = SeatLayerPickerScope.optionsOf(context).pricing?.formatter;
  if (formatter != null) return formatter(amount, currency);
  return _compactMoney(amount, currency);
}

String _compactMoney(double amount, String currency) {
  const symbols = <String, String>{
    'EUR': '€',
    'USD': r'$',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'KRW': '₩',
  };
  final decimals = amount == amount.roundToDouble() ? 0 : 2;
  final value = amount.toStringAsFixed(decimals);
  final symbol = symbols[currency.toUpperCase()];
  return symbol == null ? '${currency.toUpperCase()} $value' : '$symbol$value';
}

Color? _parseColor(String raw) {
  final value = raw.replaceFirst('#', '');
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}

Color _alpha(Color color, double opacity) =>
    color.withAlpha((opacity.clamp(0, 1) * 255).round());

void _ignoreAction(Future<void> action) {
  unawaited(action.catchError((Object _) {}));
}

Future<void> _checkoutWithRejection(
  SeatLayerPickerController controller,
  SeatLayerCheckoutCallback onCheckout,
) async {
  final handoff = await controller.checkout();
  try {
    await onCheckout(handoff);
  } catch (error, stack) {
    try {
      await controller.rejectCheckoutHandoff(handoff);
    } catch (_) {
      // Preserve the host callback failure; rejection is best effort and its
      // own typed failure remains available to explicit controller callers.
    }
    controller.reportActionError(error);
    Error.throwWithStackTrace(error, stack);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
