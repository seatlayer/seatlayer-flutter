/// The composition root: how the phone and wide layouts put the parts together.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_builders.dart';
import 'picker_cart_list.dart';
import 'seat_layer_picker.dart';
import 'picker_seat_confirmation.dart';
import 'picker_status_views.dart';
import 'picker_best_seats.dart';
import 'picker_cart_sheet.dart';
import 'picker_confirm_card.dart';
import 'picker_header.dart';
import 'picker_legend.dart';
import 'picker_map_controls.dart';
import 'picker_venue_3d.dart';
import 'picker_dock_bar.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
import 'seat_layer_picker_controller.dart';
import 'picker_accessibility.dart';
import 'picker_attribution.dart';
import 'picker_errors.dart';
import 'picker_prompts.dart';
import 'picker_section_navigator.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The complete buyer seat picker, ready to place on a route.
///
/// Everything below it is composable: each part is a public widget that works
/// standalone inside a [SeatLayerPickerScope], [options] hides any part, and
/// [builders] replaces one part while keeping the rest.
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
            onSectionChanged:
                SeatLayerPickerScope.callbacksOf(context).onSectionFocused,
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
        final venue3D = _part(
          context,
          widget.builders.venue3D,
          SeatLayerVenue3D(
            // Clear the legend, which stays on screen in the scene's palette.
            topInset: chrome.showPriceRail ? 46 : 10,
            bottomInset: 10 +
                (_dockVisible(state) ? resolved.layout.dockBarHeight : 0.0),
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
                  // On a phone the top rail below owns the Map/3D control.
                  includeViewModeControl: wide,
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
          final onShow3D = options.enable3D && capabilities.contains('venue3d')
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
              color: pickerAlpha(resolved.background, .84),
              child: _part(
                context,
                widget.builders.loading,
                const SeatLayerPickerLoadingView(),
              ),
            ),
          SeatLayerPickerPhase.failed ||
          SeatLayerPickerPhase.unavailable =>
            ColoredBox(
              color: pickerAlpha(resolved.background, .94),
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
          unlockDelay:
              SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.exit),
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
                              scrimColor: pickerAlpha(resolved.background, .64),
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
                  // One top rail: the prices scroll, the Map/3D control keeps
                  // the width its own labels need, and neither is drawn over
                  // the other in any language.
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: prices),
                        if (chrome.showMapControls)
                          const Padding(
                            // The legend already keeps its fade width clear,
                            // so the control needs no second gap on its left.
                            padding: EdgeInsets.only(right: 10),
                            child: SeatLayerPickerViewModeControl(),
                          ),
                      ],
                    ),
                  ),
                  // The immersive scene puts its own way back in this
                  // corner; the badge steps down rather than under it.
                  Positioned(
                    top: (state.snapshot?.map.isVenue3D ?? false) ? 84 : 44,
                    left: 10,
                    child: testBadge,
                  ),
                  if (chrome.showFloorSelector)
                    Positioned(
                      left: 10,
                      bottom: 62 + dockLift,
                      child: const SeatLayerPickerFloorSelector(),
                    ),
                  Positioned.fill(child: controls),
                  if (chrome.showVenue3DChrome) Positioned.fill(child: venue3D),
                  if (chrome.showDockBar)
                    Positioned(left: 0, right: 0, bottom: 0, child: dock),
                  Positioned.fill(
                    child: _PickerPromptTransition(
                      scrimColor: pickerAlpha(resolved.background, .64),
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
        ignorePickerAction(_removeSeat(controller, pending.label));
        return;
      }
    }
    if (state.snapshot?.map.rung == 'seats') {
      ignorePickerAction(controller.overview());
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
    ignorePickerAction(controller.setMapInteractionEnabled(enabled));
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
        duration:
            SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.enter),
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

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
