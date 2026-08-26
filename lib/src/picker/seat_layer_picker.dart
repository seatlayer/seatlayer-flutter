import 'dart:async';

import 'package:flutter/material.dart';

import '../bridge/bridge_profile.dart';
import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_configuration.dart';
import '../seat_layer_error.dart';
import '../seat_layer_view.dart';
import 'picker_builders.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_components.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPicker extends StatelessWidget {
  const SeatLayerPicker({
    super.key,
    required this.configuration,
    required this.onCheckout,
    this.controller,
    this.options = const SeatLayerPickerOptions(),
    this.theme,
    this.builders = const SeatLayerPickerBuilders(),
    this.callbacks = const SeatLayerPickerCallbacks(),
    this.onClose,
  });

  final SeatLayerConfiguration configuration;
  final SeatLayerCheckoutCallback onCheckout;
  final SeatLayerPickerController? controller;
  final SeatLayerPickerOptions options;
  final SeatLayerPickerThemeData? theme;
  final SeatLayerPickerBuilders builders;
  final SeatLayerPickerCallbacks callbacks;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => SeatLayerPickerScope(
        configuration: configuration,
        controller: controller,
        options: options,
        theme: theme,
        callbacks: callbacks,
        child: SeatLayerPickerAdaptiveLayout(
          onCheckout: onCheckout,
          onClose: onClose,
          builders: builders,
        ),
      );
}

class SeatLayerPickerMap extends StatefulWidget {
  const SeatLayerPickerMap({super.key, this.backgroundColor});
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
    final resolved = resolveSeatLayerPickerTheme(
      context,
      picker.state,
      SeatLayerPickerScope.themeOf(context),
    );
    return ColoredBox(
      color: widget.backgroundColor ??
          resolved.mapBackground ??
          resolved.background,
      child: SeatLayerView(
        key: ValueKey<int>(picker.reloadGeneration),
        controller: picker.mapController,
        configuration: configuration,
        bridgeProfile: SeatLayerBridgeProfile.picker(
          config: options.toBridgeConfig(),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class SeatLayerPickerHeader extends StatelessWidget {
  const SeatLayerPickerHeader({
    super.key,
    this.onClose,
    this.showEventDetails = true,
  });

  final VoidCallback? onClose;
  final bool showEventDetails;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = _theme(context, state);
    final event = state.event;
    final options = SeatLayerPickerScope.optionsOf(context);
    return Material(
      color: theme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          child: Row(
            children: [
              _PickerBrandMark(theme: theme, state: state),
              const SizedBox(width: 12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                          if (event?.venue != null)
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
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerBrandMark extends StatelessWidget {
  const _PickerBrandMark({required this.theme, required this.state});
  final SeatLayerResolvedPickerTheme theme;
  final SeatLayerPickerState state;

  @override
  Widget build(BuildContext context) {
    final provider = theme.logo;
    final url = state.branding?.logoUrl;
    if (provider != null || url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image(
          image: provider ?? NetworkImage(url!),
          width: 36,
          height: 36,
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.event_seat_rounded,
            size: 20,
            color: theme.onAccent,
          ),
        ),
      );
}

class SeatLayerPickerTestModeIndicator extends StatelessWidget {
  const SeatLayerPickerTestModeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (!state.isTestEvent) return const SizedBox.shrink();
    final theme = _theme(context, state);
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
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            'TEST MODE · BOOKS NOTHING',
            style: TextStyle(
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
  const SeatLayerPickerPriceRail({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = _theme(context, state);
    final categories = state.categories
        .where((category) => !category.notForSale)
        .toList(growable: false);
    if (categories.isEmpty) return const SizedBox.shrink();
    return Material(
      color: theme.surface,
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
              side: BorderSide(
                color: selected ? theme.accent : theme.divider,
              ),
              backgroundColor: theme.background,
              selectedColor: _alpha(theme.accent, .14),
              avatar: DecoratedBox(
                decoration: BoxDecoration(
                  color: _parseColor(category.color) ?? theme.accent,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 10, height: 10),
              ),
              label: Text(
                '${category.label} · ${_money(context, category.priceMin, state.snapshot?.currency ?? 'USD')}',
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              onSelected: (_) {
                final active = <String>{
                  ...?state.snapshot?.map.categoryFilter,
                };
                selected
                    ? active.remove(category.key)
                    : active.add(category.key);
                _ignoreAction(controller.setCategoryFilter(active));
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
    final theme = _theme(context, state);
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
  const SeatLayerPickerMapControls({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final map = state.snapshot?.map;
    final theme = _theme(context, state);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _alpha(theme.surface, .94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (map?.focusedSection != null)
            _ControlButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back to venue',
              onPressed: controller.overview,
            ),
          _ControlButton(
            icon: Icons.add_rounded,
            tooltip: 'Zoom in',
            onPressed: map?.canZoomIn == false ? null : controller.zoomIn,
          ),
          _ControlButton(
            icon: Icons.remove_rounded,
            tooltip: 'Zoom out',
            onPressed: map?.canZoomOut == false ? null : controller.zoomOut,
          ),
          _ControlButton(
            icon: Icons.center_focus_strong_rounded,
            tooltip: 'Fit venue',
            onPressed: controller.zoomToFit,
          ),
          _ControlButton(
            icon: Icons.visibility_rounded,
            tooltip: 'Colorblind-safe colors',
            active: map?.colorblindSafe ?? false,
            onPressed: () => controller.setColorblindSafe(
              !(map?.colorblindSafe ?? false),
            ),
          ),
        ],
      ),
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
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = _theme(context, state);
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      color: active ? theme.accent : theme.text,
      onPressed: onPressed == null ? null : () => _ignoreAction(onPressed!()),
      icon: Icon(icon, size: 21),
    );
  }
}

class SeatLayerPickerBestAvailable extends StatelessWidget {
  const SeatLayerPickerBestAvailable({
    super.key,
    this.initialQuantity = 2,
  });

  final int initialQuantity;

  @override
  Widget build(BuildContext context) {
    final options = SeatLayerPickerScope.optionsOf(context);
    if (!options.enableBestAvailable) return const SizedBox.shrink();
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final enabled = state.isReady &&
        !state.isBusy &&
        !options.readOnly &&
        state.canMutateInventory;
    return OutlinedButton.icon(
      onPressed: enabled
          ? () => _ignoreAction(
                _showBestAvailableSheet(context, controller, initialQuantity),
              )
          : null,
      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
      label: const Text('Find best seats'),
    );
  }
}

Future<void> _showBestAvailableSheet(
  BuildContext context,
  SeatLayerPickerController controller,
  int initialQuantity,
) async {
  var quantity =
      initialQuantity.clamp(1, controller.state.snapshot?.maxSelection ?? 10);
  final chosen = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Find seats together',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                  'We will hold the best available seats together for checkout.'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: quantity > 1
                        ? () => setSheetState(() => quantity -= 1)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  SizedBox(
                    width: 84,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: quantity <
                            (controller.state.snapshot?.maxSelection ?? 10)
                        ? () => setSheetState(() => quantity += 1)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(quantity),
                child: const Text('Find seats'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (chosen != null) await controller.bestAvailable(quantity: chosen);
}

class SeatLayerPickerSelectionTray extends StatelessWidget {
  const SeatLayerPickerSelectionTray({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final options = SeatLayerPickerScope.optionsOf(context);
    final theme = _theme(context, state);
    final lines = state.cartLines;
    return Material(
      color: theme.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, compact ? 10 : 16, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lines.isEmpty
                        ? 'Tap a section, then choose your seats'
                        : '${state.snapshot?.ticketCount ?? lines.length} ticket${(state.snapshot?.ticketCount ?? lines.length) == 1 ? '' : 's'} selected',
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SeatLayerPickerHoldCountdown(),
              ],
            ),
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 9),
              SizedBox(
                height: compact ? 38 : 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return InputChip(
                      label: Text(
                        '${line.buyerFacingLabel} · ${_money(context, line.total, line.currency)}',
                      ),
                      onDeleted: options.readOnly ||
                              state.holdOwner == SeatLayerHoldOwner.host
                          ? null
                          : () => _ignoreAction(
                                controller.removeObject(line.label),
                              ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
    final theme = _theme(context, state);
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
    final explicitTheme = SeatLayerPickerScope.themeOf(context);
    final resolved = resolveSeatLayerPickerTheme(context, state, explicitTheme);
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final requested = SeatLayerPickerScope.optionsOf(context).layout;
        final wide = requested == SeatLayerPickerLayoutMode.wide ||
            (requested == SeatLayerPickerLayoutMode.adaptive &&
                constraints.maxWidth >= 840);
        final map = _part(
          context,
          widget.builders.map,
          SeatLayerPickerMap(key: _mapKey),
        );
        final header = _part(
          context,
          widget.builders.header,
          SeatLayerPickerHeader(onClose: widget.onClose),
        );
        final prices = _part(
          context,
          widget.builders.priceRail,
          const SeatLayerPickerPriceRail(),
        );
        final sections = _part(
          context,
          widget.builders.sectionNavigator,
          const SeatLayerPickerSectionNavigator(),
        );
        final accessibility = _part(
          context,
          widget.builders.accessibilityFilters,
          const SeatLayerPickerAccessibilityFilters(),
        );
        final tray = _part(
          context,
          widget.builders.selectionTray,
          SeatLayerPickerSelectionTray(compact: !wide),
        );
        final checkout = _part(
          context,
          widget.builders.checkoutBar,
          SeatLayerPickerCheckoutBar(onCheckout: widget.onCheckout),
        );
        const testBadge = SeatLayerPickerTestModeIndicator();
        final controls = _part(
          context,
          widget.builders.mapControls,
          const SeatLayerPickerMapControls(),
        );
        final best = _part(
          context,
          widget.builders.bestAvailable,
          const SeatLayerPickerBestAvailable(),
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
        final options = SeatLayerPickerScope.optionsOf(context);
        final pendingSeat =
            !options.readOnly && state.hold == null && options.confirmSelection
                ? state.selection.reversed
                    .where((seat) => !_confirmedLabels.contains(seat.label))
                    .firstOrNull
                : null;
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
        } else if (pendingSeat != null) {
          buyerPrompt = _part(
            context,
            widget.builders.seatConfirmation,
            SeatLayerPickerSeatConfirmation(
              key: ValueKey<String>(pendingSeat.label),
              seat: pendingSeat,
              onConfirm: _confirmSeat,
              onCancel: (seat) => _removeSeat(controller, seat.label),
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
                          Positioned.fill(child: map),
                          const Positioned(
                            top: 12,
                            left: 12,
                            child: testBadge,
                          ),
                          Positioned(top: 12, right: 12, child: controls),
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
                          if (buyerPrompt != null)
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: buyerPrompt,
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
                            child: Row(
                              children: [
                                Expanded(child: best),
                                const SizedBox(width: 8),
                                Expanded(child: accessibility),
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

        return Column(
          children: [
            header,
            prices,
            sections,
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: map),
                  const Positioned(top: 10, left: 10, child: testBadge),
                  Positioned(top: 10, right: 10, child: controls),
                  const Positioned(
                    left: 10,
                    bottom: 10,
                    child: SeatLayerPickerFloorSelector(),
                  ),
                  Positioned(right: 10, bottom: 10, child: best),
                  Positioned(left: 10, bottom: 56, child: accessibility),
                  if (buyerPrompt != null)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: buyerPrompt,
                    ),
                  if (statusOverlay != null)
                    Positioned.fill(child: statusOverlay),
                ],
              ),
            ),
            actionError,
            tray,
            attribution,
            checkout,
          ],
        );
      },
    );

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
    return themed;
  }

  Future<void> _confirmSeat(SelectedSeat seat) async {
    if (!mounted) return;
    setState(() => _confirmedLabels.add(seat.label));
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

SeatLayerResolvedPickerTheme _theme(
  BuildContext context,
  SeatLayerPickerState state,
) =>
    resolveSeatLayerPickerTheme(
      context,
      state,
      SeatLayerPickerScope.themeOf(context),
    );

String _money(BuildContext context, double amount, String currency) {
  final formatter = SeatLayerPickerScope.optionsOf(context).pricing?.formatter;
  if (formatter != null) return formatter(amount, currency);
  final decimals = amount == amount.roundToDouble() ? 0 : 2;
  return '$currency ${amount.toStringAsFixed(decimals)}';
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
