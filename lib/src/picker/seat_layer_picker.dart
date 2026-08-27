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
import 'picker_header.dart';
import 'picker_legend.dart';
import 'picker_map_controls.dart';
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

/// The dense ticket list, under its dev.4 name.
@Deprecated('Renamed to SeatLayerCartList; the alias goes away at 0.4.')
typedef SeatLayerPickerSelectionTray = SeatLayerCartList;

/// The best-available form, under its dev.4 name.
@Deprecated('Renamed to SeatLayerBestSeatsForm; the alias goes away at 0.4.')
typedef SeatLayerPickerBestAvailablePanel = SeatLayerBestSeatsForm;

/// The wide layout's checkout bar: a total and a button.
///
/// The phone uses [SeatLayerBookButton] instead, because the peek bar already
/// carries the total a thumb away from the call to action.
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
  Timer? _mapUnlockTimer;
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
                  showHoldPill: chrome.showHoldPill,
                )
              : const SizedBox.shrink(),
        );
        final prices = _part(
          context,
          widget.builders.legend ?? widget.builders.priceRail,
          chrome.showPriceRail
              ? SeatLayerPriceLegend(compact: !wide)
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
              ? SeatLayerPickerMapControls(
                  compact: !wide,
                  bottomInset: !wide && _dockVisible(state)
                      ? resolved.layout.dockBarHeight
                      : 0,
                )
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

        // The controls ride above the dock so neither covers the other; the
        // dock itself is edge-to-edge at the map's own bottom.
        final dockLift =
            _dockVisible(state) ? resolved.layout.dockBarHeight : 0.0;
        return Column(
          children: [
            header,
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: mapSurface),
                  // The legend is pushed off the venue, in the corner the
                  // map's own controls leave free.
                  Positioned(top: 8, left: 0, right: 56, child: prices),
                  Positioned(top: 44, left: 10, child: testBadge),
                  if (chrome.showFloorSelector)
                    Positioned(
                      left: 10,
                      bottom: 62 + dockLift,
                      child: const SeatLayerPickerFloorSelector(),
                    ),
                  Positioned.fill(child: controls),
                  if (chrome.showDockBar)
                    Positioned(left: 0, right: 0, bottom: 0, child: dock),
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
    _mapUnlockTimer?.cancel();
    _mapUnlockTimer = null;
    final generation = ++_mapInteractionGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _mapInteractionGeneration) return;
      // Keep the runtime inert while the old card completes its exit. A fast
      // second tap would otherwise land on the WebView through the fading
      // native surface. Locking is immediate; only unlocking waits — and the
      // wait is a real timer so route teardown can cancel it.
      if (enabled && unlockDelay > Duration.zero) {
        _mapUnlockTimer = Timer(unlockDelay, () {
          _mapUnlockTimer = null;
          _pushMapInteraction(controller, enabled, generation);
        });
        return;
      }
      _pushMapInteraction(controller, enabled, generation);
    });
  }

  void _pushMapInteraction(
    SeatLayerPickerController controller,
    bool enabled,
    int generation,
  ) {
    if (!mounted ||
        generation != _mapInteractionGeneration ||
        _mapInteractionEnabled != enabled) {
      return;
    }
    // The Flutter hit-test gate remains the fallback for a transport that
    // disappears during route teardown, so a failure here is not an error.
    _ignoreAction(controller.setMapInteractionEnabled(enabled));
  }

  @override
  void dispose() {
    _mapUnlockTimer?.cancel();
    super.dispose();
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
