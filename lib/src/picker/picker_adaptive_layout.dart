/// The composition root: how the phone and wide layouts put the parts together.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_map_chrome.dart';
import 'picker_internal.dart';
import 'picker_builders.dart';
import 'picker_cart_list.dart';
import 'seat_layer_picker.dart';
import 'picker_seat_confirmation.dart';
import 'picker_states.dart';
import 'picker_status_views.dart';
import 'picker_toast.dart';
import 'picker_best_seats.dart';
import 'picker_cart_sheet.dart';
import 'picker_confirm_card.dart';
import 'picker_header.dart';
import 'picker_legend.dart';
import 'picker_map_controls.dart';
import 'picker_venue_3d.dart';
import 'picker_dock_bar.dart';
import 'picker_floor_strip.dart';
import 'picker_haptics.dart';
import 'picker_layout.dart';
import 'picker_camera_actions.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'picker_a11y.dart';
import 'picker_accessibility.dart';
import 'picker_attribution.dart';
import 'picker_errors.dart';
import 'picker_prompt_presentation.dart';
import 'picker_prompts.dart';
import 'picker_seat_view_chrome.dart';
import 'picker_section_navigator.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The gap between two stacked pieces of map chrome, and how far a floating
/// control stands off the map's edge — one pair for every anchor region.
const double _badgeGap = SeatLayerSizeTokens.mapAnchorGap;
const double _mapInset = SeatLayerSizeTokens.mapAnchorInset;

/// Where the phone's map chrome starts, below the map's own top edge.
const double _railTop = 8;

/// How much of the map the immersive scene's own chrome is given when
/// nothing else stands in the map's top corners.
///
/// The prices are a row above the map rather than on it; only the Map/3D
/// control shares the map's top edge, and when it does the scene's chrome
/// steps below it — see `_immersiveTopInset`.
const double _venue3DRestingInset = _mapInset;

/// How much closer to the foot the card rests in 3D: ten, not fourteen.
const double _cardLift3D = seatLayerConfirmCardRestInset -
    SeatLayerSizeTokens.confirmCardImmersiveRestInset;

/// How long the map may be held back waiting to be framed.
///
/// The insets normally settle on the frame after the first snapshot. This is
/// the backstop for a runtime that never answers: a buyer must never be left
/// on a loading screen by a refinement.
const Duration _mapFramingGrace = Duration(milliseconds: 700);

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

  /// Where focus goes when a decision surface hands the screen back.
  ///
  /// A card that answers and leaves takes the focused button with it, and
  /// focus with nowhere to go falls to the top of the tree — which puts a
  /// screen-reader buyer back at the header after every seat. The map is
  /// where they were, so the map is where they are put back. Out of the tab
  /// order on purpose: it is a destination, not a control.
  final FocusNode _mapFocus = FocusNode(
    debugLabel: 'seatlayer-picker-map-region',
    skipTraversal: true,
  );

  /// Shared with the map surface so the platform view can resign the touches
  /// the chrome standing on it has taken. See `seat_layer_map_chrome.dart`.
  final SeatLayerMapChromeLatch _mapChromeLatch = SeatLayerMapChromeLatch();
  bool _mapInteractionEnabled = true;
  int _mapInteractionGeneration = 0;
  Timer? _mapUnlockTimer;
  String? _previousRung;
  SeatLayerViewportInsets? _reportedInsets;
  SeatLayerPickerController? _picker;
  Timer? _framingGraceTimer;
  bool _framingGraceLapsed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kept so `dispose` can clear the insets: the tree is already gone by then
    // and the scope can no longer be looked up.
    _picker = SeatLayerPickerScope.controllerOf(context);
  }

  /// Whether the buyer has the cart sheet open.
  ///
  /// Read from the controller, never from this State: a theme flip or a host
  /// rebuilding its route can hand the layout a fresh State, and a sheet that
  /// snaps shut takes the buyer's place in their own cart with it.
  bool get _sheetExpanded => _picker?.cartSheetExpanded ?? false;

  void _setSheetExpanded(bool expanded) =>
      _picker?.setCartSheetExpanded(expanded);

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
    final panoramaUp = controller.seatView?.hasContent == true;
    final resolved = seatLayerPickerThemeOf(context);
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final requested = SeatLayerPickerScope.optionsOf(context).layout;
        final wide = requested == SeatLayerPickerLayoutMode.wide ||
            (requested == SeatLayerPickerLayoutMode.adaptive &&
                constraints.maxWidth >= 840);
        final options = SeatLayerPickerScope.optionsOf(context);
        final chrome = options.chrome;
        final venue3DUp =
            !panoramaUp && (state.snapshot?.map.isVenue3D ?? false);
        final immersiveUp = panoramaUp || venue3DUp;
        // Whether the scene has finished diving to a seat.
        final targeted = state.snapshot?.map.view3DTargetSeatId != null;
        // NO DOCK ON THE PHONE by default (owner call, 2026-09-04). The bar
        // is auto-resolved wide-only, and the drop-in mounts it only in the
        // narrow branch, so by default nothing docks anywhere and a phone's
        // bottom-corner controls sit at the map's own edge. A host that asks
        // for it explicitly gets it back, on the phone, exactly as before.
        final dockUp = !panoramaUp &&
            !venue3DUp &&
            chrome.dockBarFor(phone: !wide) &&
            _dockVisible(state);
        // The Map/3D control keeps the map's top-right corner, on its own
        // line under the prices: two lines cost the map thirty points and
        // give back a rail that is never clipped under the control.
        final viewModeControlUp =
            !wide && chrome.showMapControls && !panoramaUp;
        final immersiveTopInset = _immersiveTopInset(
          viewModeControl: viewModeControlUp,
        );
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
        final prices = panoramaUp
            ? const SizedBox.shrink()
            : _part(
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
        final floorStrip = panoramaUp
            ? const SizedBox.shrink()
            : _part(
                context,
                widget.builders.floorStrip,
                chrome.showFloorStrip
                    ? SeatLayerFloorStrip(compact: !wide)
                    : const SizedBox.shrink(),
              );
        // Nothing is drawn on a venue with one floor, so nothing is reserved
        // either: the band is reported only when the strip is really there.
        final floorStripUp = !panoramaUp &&
            chrome.showFloorStrip &&
            (state.snapshot?.map.floors.length ?? 0) > 1;
        final floorStripHeight = SeatLayerFloorStrip.heightFor(compact: !wide);
        final dock = _part(
          context,
          widget.builders.dockBar,
          SeatLayerDockBar(
            onSectionChanged: SeatLayerPickerScope.callbacksOf(
              context,
            ).onSectionFocused,
            // The cart sheet below already reserves the device inset.
            reserveBottomInset: !chrome.showTicketPanel,
          ),
        );
        final accessibility = panoramaUp
            ? const SizedBox.shrink()
            : _part(
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
            expanded: _sheetExpanded,
            onExpandedChanged: _setSheetExpanded,
            onCheckout: _checkoutAndAnnounce,
            bestSeats: null,
            cartList: null,
            checkoutBar: null,
            actionError: null,
          ),
        );
        // What chrome standing on the map's bottom edge has to clear.
        final mapChromeBottom =
            _mapInset + (dockUp ? SeatLayerDockBar.heightFor(context) : 0.0);
        final venue3D = panoramaUp
            ? const SizedBox.shrink()
            : _part(
                context,
                widget.builders.venue3D,
                SeatLayerVenue3D(
                  // The scene's chrome starts at the map's edge: the prices
                  // are a row above the map, not a band on it.
                  topInset: immersiveTopInset,
                  bottomInset: mapChromeBottom,
                ),
              );
        // The panorama is full-screen web content inside the map surface, so
        // its words are drawn over the same box the picture fills.
        final seatViewChrome = _part(
          context,
          widget.builders.seatViewChrome,
          chrome.showSeatViewChrome
              ? SeatLayerSeatViewChrome(
                  topInset: wide ? _mapInset : immersiveTopInset,
                  bottomInset: wide ? _mapInset : mapChromeBottom,
                )
              : const SizedBox.shrink(),
        );
        final testBadge = panoramaUp
            ? const SizedBox.shrink()
            : SeatLayerPickerTestModeIndicator(compact: !wide);
        final controls = panoramaUp
            ? const SizedBox.shrink()
            : _part(
                context,
                widget.builders.mapControls,
                chrome.showMapControls
                    ? SeatLayerPickerMapControls(
                        compact: !wide,
                        bottomInset: !wide && dockUp
                            ? SeatLayerDockBar.heightFor(context)
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

        // The controller owns which seat is still being asked about, so the
        // cart sheet and the checkout gate answer the same question this
        // layout does.
        final pendingSeat = controller.unansweredSeat;
        // A seat the buyer has tapped a SECOND time. A runtime that speaks
        // `seat.retap` keeps the seat selected and reports the tap instead of
        // dropping it, so the card can ask before the seat goes — and the cart
        // keeps counting it while the card is up, because it IS still in the
        // cart until the buyer answers.
        final removalSeat =
            pendingSeat == null ? controller.seatAwaitingRemoval : null;
        final cardSeat = pendingSeat ?? removalSeat;
        final removing = removalSeat != null;
        // The sheet never opens itself: a sheet that springs up on every pick
        // covers the map the buyer is still choosing from. It does collapse
        // itself when a seat card opens over the map, which is the tap the
        // runtime does report to native chrome.
        if (cardSeat != null && _sheetExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _sheetExpanded) _setSheetExpanded(false);
          });
        }
        _followRungToPeek(state);
        // Whether the prompt below is the phone's seat card, which is the one
        // prompt that arrives as a moment of its own rather than as a dialog.
        var seatCardUp = false;
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
        } else if (!panoramaUp && cardSeat != null && chrome.showConfirmCard) {
          final capabilities = state.snapshot?.capabilities ?? const <String>{};
          final onViewFromSeat =
              options.enableSeatView && capabilities.contains('seatView')
                  ? (SelectedSeat seat) =>
                      _inspectSeat(() => controller.openSeatView(seat))
                  : null;
          final onShow3D = options.enable3D && capabilities.contains('venue3d')
              ? (SelectedSeat seat) =>
                  _inspectSeat(() => controller.showSeatIn3D(seat))
              : null;
          // The phone gets the one-line card; the wide layout keeps the
          // identity grid, which has the room for it.
          seatCardUp = !wide;
          // The primary answer is whichever answer the card is asking for, and
          // Cancel is always "leave it as it was": for an add that drops the
          // candidate, for a remove that keeps the seat.
          final onPrimary = removing
              ? (SelectedSeat seat) => _removeSeat(controller, seat.label)
              : _confirmSeat;
          final onSecondary = removing
              ? (SelectedSeat seat) => controller.dismissSeatRemoval()
              : (SelectedSeat seat) => _removeSeat(controller, seat.label);
          // The identity grid is the wide layout's way of asking, but only the
          // card carries the second question, so a retap raises the card in
          // either width.
          buyerPrompt = wide && !removing
              ? _part(
                  context,
                  widget.builders.seatConfirmation,
                  SeatLayerPickerSeatConfirmation(
                    key: ValueKey<String>(cardSeat.label),
                    seat: cardSeat,
                    onConfirm: onPrimary,
                    onCancel: onSecondary,
                    onViewFromSeat: onViewFromSeat,
                    onShow3D: onShow3D,
                  ),
                )
              : _part(
                  context,
                  widget.builders.confirmCard ??
                      widget.builders.seatConfirmation,
                  SeatLayerConfirmCard(
                    // An add and a remove about the same seat are two
                    // different questions, so they are two different cards.
                    key: ValueKey<String>(
                      '${removing ? 'remove' : 'add'}:${cardSeat.label}',
                    ),
                    seat: cardSeat,
                    mode: removing
                        ? SeatLayerConfirmCardMode.remove
                        : SeatLayerConfirmCardMode.add,
                    onConfirm: onPrimary,
                    onCancel: onSecondary,
                    onViewFromSeat: onViewFromSeat,
                    onShow3D: onShow3D,
                  ),
                );
        } else {
          buyerPrompt = null;
        }
        // The same card over the scene, in its own dimensions.
        final seatCard3D = seatCardUp && venue3DUp;
        // An immersive inspection temporarily takes the card off the picture,
        // but it does not answer the buyer's Select/Cancel question. Keep that
        // exact seat out of cart totals until they explicitly decide.
        controller.setConfirmCardSeat(
          pendingSeat != null &&
                  chrome.showConfirmCard &&
                  state.generalAdmissionCandidate == null &&
                  pendingSeat.bookingMode != 'variable'
              ? pendingSeat
              : null,
        );
        // Ready, but the runtime has not been told what the chrome covers yet:
        // revealing the map now shows it at one framing and then re-fits it in
        // front of the buyer. Held for the moment that takes, and never longer
        // than [_mapFramingGrace] — a runtime that never answers must not be
        // able to hang the picker on a loading screen.
        _syncFramingGrace(state);
        final framing = state.phase == SeatLayerPickerPhase.ready &&
            !state.mapFramed &&
            !_framingGraceLapsed;
        final Widget? statusOverlay =
            state.phase == SeatLayerPickerPhase.initializing || framing
                ? ColoredBox(
                    color: pickerAlpha(resolved.background, .84),
                    child: _part(
                      context,
                      widget.builders.loading,
                      const SeatLayerPickerLoadingView(),
                    ),
                  )
                : switch (state.phase) {
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
        final strings = SeatLayerPickerScope.stringsOf(context);
        final mapSurface = Semantics(
          // One node, and it says so. The seats are drawn on a canvas inside
          // the web view, which exposes nothing to assistive technology: a
          // buyer listening to this screen cannot explore the venue, and the
          // honest thing is to name the region and say where the controls
          // that DO pick a seat are, rather than leave a silent rectangle
          // filling most of the screen. Per-seat nodes are a runtime gap —
          // see `design/picker-spec.md` 4.9.
          container: true,
          label: strings.venueMap(
            state.event?.venue ?? state.event?.name ?? strings.venueView,
          ),
          hint: strings.venueMapHint,
          child: Focus(
            focusNode: _mapFocus,
            child: IgnorePointer(
              // Platform views participate in iOS gesture recognition before the
              // Flutter overlay's onPressed callback runs. Explicitly remove the
              // WebView from hit testing while any native decision surface owns
              // the map; visual stacking alone does not prevent tap-through.
              ignoring: buyerPrompt != null || statusOverlay != null,
              child: map,
            ),
          ),
        );
        _syncMapInteraction(
          controller,
          enabled: buyerPrompt == null && statusOverlay == null,
          unlockDelay: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.exit,
          ),
        );

        if (wide) {
          // The wide composition puts its chrome beside the map rather than
          // on it, so the runtime frames against the whole surface again.
          _reportViewportInsets(SeatLayerViewportInsets.zero);
          return Column(
            children: [
              header,
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SeatLayerMapChromeStack(
                        latch: _mapChromeLatch,
                        children: [
                          Positioned.fill(child: mapSurface),
                          Positioned(
                              top: _mapInset,
                              left: _mapInset,
                              child: testBadge),
                          Positioned(
                              top: _mapInset,
                              right: _mapInset,
                              child: controls),
                          if (chrome.showFloorSelector)
                            const Positioned(
                              left: _mapInset,
                              bottom: _mapInset,
                              child: SeatLayerPickerFloorSelector(),
                            ),
                          Positioned(
                            left: _mapInset,
                            bottom: _bottomLeftLift(resolved.layout),
                            child: accessibility,
                          ),
                          Positioned.fill(child: seatViewChrome),
                          if (!immersiveUp)
                            Positioned.fill(
                              key: const ValueKey<String>(
                                'seatlayer-picker-prompt-transition',
                              ),
                              child: PickerPromptTransition(
                                scrimColor: pickerAlpha(
                                  resolved.background,
                                  .64,
                                ),
                                child: buyerPrompt,
                              ),
                            ),
                          // --- toasts and buyer-facing states (P4) ---
                          const Positioned.fill(
                            child: SeatLayerPickerToastLayer(),
                          ),
                          Positioned.fill(
                            child: SeatLayerPickerStateLayer(
                              showExtendHoldPrompt:
                                  chrome.extendHoldPromptFor(phone: !wide),
                            ),
                          ),
                          // --- end toasts and buyer-facing states ---
                          Positioned.fill(
                            child: PickerStatusOverlay(overlay: statusOverlay),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 360,
                      decoration: BoxDecoration(
                        color: resolved.surface,
                        border: Border(
                          left: BorderSide(color: resolved.divider),
                        ),
                      ),
                      child: Column(
                        children: [
                          prices,
                          // Beside the map rather than on it, so the wide
                          // layout reports no band for it.
                          if (floorStripUp)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: floorStrip,
                            ),
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
                          Expanded(child: SingleChildScrollView(child: tray)),
                          actionError,
                          const Padding(
                            padding: EdgeInsetsDirectional.only(end: 8),
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: attribution,
                            ),
                          ),
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
        final dockLift = dockUp ? SeatLayerDockBar.heightFor(context) : 0.0;
        // `‹ Back to venue` is drawn only once the scene is aimed at a seat,
        // so only then does anything stand in the badge's corner.
        final backPillUp = venue3DUp && chrome.showVenue3DChrome && targeted;
        // One chrome row, not map chrome: the prices and the Map/3D control
        // are a band of their own between the header and the map, so the last
        // chip is never clipped under the control and no seat number is read
        // through either of them.
        //
        // The immersive scene has no rail: a price is a fact about a seat, and
        // in 3D the buyer is choosing where to stand, not what to spend. The
        // band would also cost the scene forty-four points of sky.
        final railUp = !panoramaUp && !venue3DUp && chrome.showPriceRail;
        // The band caps the map the way the header does, so it takes the map
        // chrome palette and goes dark with the immersive scene.
        final railTheme = seatLayerMapChromeThemeOf(context);
        final topRail = Material(
          color: railTheme.surface,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: railTheme.divider)),
            ),
            child: SizedBox(
              // The band grows with the chips inside it, to the rail's clamp.
              height: seatLayerScaledExtent(
                context,
                resolved.layout.topRailHeight,
                max: SeatLayerTypeScaleTokens.rail,
              ),
              child: prices,
            ),
          ),
        );
        // What of the map this composition is standing on. Only chrome drawn
        // OVER the map counts: the header, the top rail and the cart sheet are
        // rows of the same Column, so the map surface begins and ends where
        // they do and the runtime already frames inside them. The floor strip,
        // the test badge and the dock are not — they are stacked on the map —
        // so a section framed to the whole surface lands partly underneath
        // them unless the runtime is told.
        final topBand = _topBand(
          panorama: panoramaUp,
          testBadge: state.isTestEvent,
          venue3D: venue3DUp,
          backPill: backPillUp,
          backPillInset: immersiveTopInset,
          viewModeControl: viewModeControlUp,
          floorStrip: floorStripUp,
          floorStripHeight: floorStripHeight,
        );
        final bottomBand = _bottomBand(
          chrome: chrome,
          seated: targeted,
          dockLift: dockLift,
          venue3D: venue3DUp,
        );
        _reportViewportInsets(
          SeatLayerViewportInsets(top: topBand, bottom: bottomBand),
        );
        // One reading order for the whole phone picker. The Column already
        // reads top to bottom, but the Stack in the middle does not: its paint
        // order puts the dock between two halves of the map's own chrome and
        // the seat card after the toast that answers it. Every surface says
        // where it belongs instead — see [SeatLayerPickerReadingOrder].
        return Column(
          children: [
            seatLayerReadingOrder(SeatLayerPickerReadingOrder.header, header),
            if (railUp)
              seatLayerReadingOrder(
                SeatLayerPickerReadingOrder.rail,
                SeatLayerTypeScale.rail(child: topRail),
              ),
            Expanded(
              // The whole map band takes its own place in the order, so the
              // Column's four rows are all keyed: a group with some keys and
              // some without falls back to geometry for the unkeyed ones,
              // which is how the map came to be read before the prices.
              child: seatLayerReadingOrder(
                SeatLayerPickerReadingOrder.map,
                SeatLayerMapChromeStack(
                  latch: _mapChromeLatch,
                  children: [
                    Positioned.fill(
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.map,
                        mapSurface,
                      ),
                    ),
                    // The floors are the one piece of "which seats am I looking
                    // at" chrome that stays on the map, so they start at the
                    // map's own edge.
                    if (floorStripUp && !venue3DUp)
                      Positioned(
                        top: _floorStripTop(viewModeControl: viewModeControlUp),
                        left: 0,
                        right: 0,
                        child: seatLayerReadingOrder(
                          SeatLayerPickerReadingOrder.mapChrome,
                          floorStrip,
                        ),
                      ),
                    // The immersive scene puts `‹ Back to venue` in this
                    // corner; the badge steps below that pill rather than under
                    // it, and only while the pill is actually drawn.
                    Positioned(
                      top: _testBadgeTop(
                        venue3D: venue3DUp,
                        backPill: backPillUp,
                        backPillInset: immersiveTopInset,
                        viewModeControl: viewModeControlUp,
                        floorStrip: floorStripUp,
                        floorStripHeight: floorStripHeight,
                      ),
                      left: _mapInset,
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.mapChrome,
                        testBadge,
                      ),
                    ),
                    if (viewModeControlUp)
                      Positioned(
                        top: _railTop,
                        right: _mapInset,
                        child: seatLayerReadingOrder(
                          // It shares the rail's band, so it is read with the
                          // prices rather than with the map's own corners.
                          SeatLayerPickerReadingOrder.rail,
                          const SizedBox(
                            height: SeatLayerPickerViewModeControl.height,
                            child: SeatLayerPickerViewModeControl(),
                          ),
                        ),
                      ),
                    if (chrome.showFloorSelector)
                      Positioned(
                        left: _mapInset,
                        bottom: dockLift + _bottomLeftLift(resolved.layout),
                        child: seatLayerReadingOrder(
                          SeatLayerPickerReadingOrder.mapChrome,
                          const SeatLayerPickerFloorSelector(),
                        ),
                      ),
                    Positioned.fill(
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.mapChrome,
                        controls,
                      ),
                    ),
                    if (chrome.showVenue3DChrome)
                      Positioned.fill(
                        child: seatLayerReadingOrder(
                          SeatLayerPickerReadingOrder.mapChrome,
                          venue3D,
                        ),
                      ),
                    Positioned.fill(
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.mapChrome,
                        seatViewChrome,
                      ),
                    ),
                    if (dockUp)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: seatLayerReadingOrder(
                          SeatLayerPickerReadingOrder.dock,
                          SeatLayerTypeScale.dock(child: dock),
                        ),
                      ),
                    if (!immersiveUp || seatCard3D)
                      Positioned.fill(
                        key: const ValueKey<String>(
                          'seatlayer-picker-prompt-transition',
                        ),
                        child: PickerPromptTransition(
                          readingOrder: SeatLayerPickerReadingOrder.prompt,
                          // No wash by default: the runtime itself pales the
                          // venue outside the focused seat's section while a
                          // card asks, and the neighbours keep their ink and
                          // numbers, as on the web. A host that wants a wash
                          // over the whole map sets the slot.
                          scrimColor: seatCard3D
                              ? const Color(0x00000000)
                              : resolved.styles.scrimColor ??
                                  const Color(0x00000000),
                          // The card arrives from the seat's direction and points
                          // back at it. In the scene the seat IS the picture, so
                          // nothing points at it and the card rests over it.
                          seatCard: seatCardUp,
                          anchor: seatCard3D ? null : cardSeat?.screenPoint,
                          topInset: topBand,
                          // With no anchor in 3D this band only sets where the
                          // card rests, so the lift is spent here.
                          bottomInset:
                              bottomBand - (seatCard3D ? _cardLift3D : 0),
                          onDismiss: seatCardUp && cardSeat != null
                              ? () => _dismissSeatCard(
                                    controller,
                                    cardSeat,
                                    removing: removing,
                                  )
                              : null,
                          child: buyerPrompt,
                        ),
                      ),
                    // --- toasts and buyer-facing states (P4) ---
                    // Above the card, never over it: the message is the reply to
                    // the tap that opened the card, and a reply printed across
                    // Cancel / Add seat is a reply the buyer has to move to read.
                    Positioned.fill(
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.notice,
                        SeatLayerTypeScale.state(
                          child: SeatLayerPickerToastLayer(
                            bottomInset: bottomBand,
                            lifted: seatCardUp,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.notice,
                        SeatLayerTypeScale.state(
                          child: SeatLayerPickerStateLayer(
                            bottomInset: bottomBand,
                            showExtendHoldPrompt:
                                chrome.extendHoldPromptFor(phone: !wide),
                          ),
                        ),
                      ),
                    ),
                    // --- end toasts and buyer-facing states ---
                    Positioned.fill(
                      child: seatLayerReadingOrder(
                        SeatLayerPickerReadingOrder.notice,
                        SeatLayerTypeScale.state(
                          child: PickerStatusOverlay(overlay: statusOverlay),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (chrome.showTicketPanel)
              seatLayerReadingOrder(
                SeatLayerPickerReadingOrder.sheet,
                PickerPausedWhileConfirming(
                  key: const ValueKey<String>('seatlayer-picker-sheet-pause'),
                  confirming: seatCardUp,
                  child: sheet,
                ),
              ),
          ],
        );
      },
    );

    final canPop = !_ownsBackGesture(state);
    final themed = Theme(
      // One function themes every native surface, this composition and any
      // route it pushes alike; see seatLayerPickerMaterialTheme.
      data: seatLayerPickerMaterialTheme(context, resolved),
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
      child: SeatLayerMapChromeScope(
        latch: _mapChromeLatch,
        child: themed,
      ),
    );
  }

  /// How much of the map's top the phone's chrome is standing on.
  ///
  /// The rail of prices is a row above the map rather than a band on it, so it
  /// is deliberately not counted. What is left standing on the map is the
  /// floor strip and, under it, the test badge — and a test event is not a
  /// rare case, it is what every integration sees first. In the immersive
  /// scene `‹ Back to venue` takes the strip's place, and only while the scene
  /// is aimed at a seat.
  static double _topBand({
    required bool panorama,
    required bool testBadge,
    required bool venue3D,
    required bool backPill,
    required double backPillInset,
    required bool viewModeControl,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    if (panorama) return 0;
    // The Map/3D control shares the map's top line with the badge, so the
    // band is whichever of the two reaches lower.
    final control = viewModeControl
        ? _railTop + SeatLayerPickerViewModeControl.height
        : 0.0;
    final above = _aboveBadgeBand(
      venue3D: venue3D,
      backPill: backPill,
      backPillInset: backPillInset,
      viewModeControl: viewModeControl,
      floorStrip: floorStrip,
      floorStripHeight: floorStripHeight,
    );
    if (!testBadge) return above > control ? above : control;
    final badge = _testBadgeTop(
          venue3D: venue3D,
          backPill: backPill,
          backPillInset: backPillInset,
          viewModeControl: viewModeControl,
          floorStrip: floorStrip,
          floorStripHeight: floorStripHeight,
        ) +
        SeatLayerPickerTestModeIndicator.compactHeight;
    return badge > control ? badge : control;
  }

  /// Where the immersive scene's own chrome starts.
  ///
  /// The scene's rotate control and its way back both sit on the map's top
  /// line; when the Map/3D control is already there they step under it.
  static double _immersiveTopInset({required bool viewModeControl}) =>
      viewModeControl
          ? _railTop + SeatLayerPickerViewModeControl.height + _badgeGap
          : _venue3DRestingInset;

  /// The band the floor strip, or the scene's way back, occupies on its own.
  static double _aboveBadgeBand({
    required bool venue3D,
    required bool backPill,
    required double backPillInset,
    required bool viewModeControl,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    if (venue3D) {
      return backPill ? backPillInset + SeatLayerVenue3D.backPillHeight : 0;
    }
    if (floorStrip) {
      return _floorStripTop(viewModeControl: viewModeControl) +
          floorStripHeight;
    }
    return 0;
  }

  /// Where the floor strip starts: the map's top line, or under the Map/3D
  /// control when that is on the same line — the strip runs the map's full
  /// width and the two would otherwise be drawn over each other.
  static double _floorStripTop({required bool viewModeControl}) =>
      viewModeControl
          ? _railTop + SeatLayerPickerViewModeControl.height + _badgeGap
          : _railTop;

  /// Where the test-mode badge sits, which is one line under whatever is
  /// above it — or at the map's own top corner when nothing is.
  static double _testBadgeTop({
    required bool venue3D,
    required bool backPill,
    required double backPillInset,
    required bool viewModeControl,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    final above = _aboveBadgeBand(
      venue3D: venue3D,
      backPill: backPill,
      backPillInset: backPillInset,
      viewModeControl: viewModeControl,
      floorStrip: floorStrip,
      floorStripHeight: floorStripHeight,
    );
    return above == 0 ? _railTop : above + _badgeGap;
  }

  /// How much of the map's bottom the phone's chrome is standing on.
  ///
  /// The dock on the map — zero unless a host asked for one, since the phone
  /// mounts none — and in the scene the seat deck above it, which is taller
  /// once the buyer is sitting somewhere because it grows a caption. The
  /// header and the cart sheet are rows of the same Column as the map, so the
  /// map surface already ends where they begin and they are correctly not
  /// reported.
  static double _bottomBand({
    required SeatLayerPickerChromeOptions chrome,
    required bool seated,
    required double dockLift,
    required bool venue3D,
  }) {
    // `dockLift` is already zero unless a dock is really drawn.
    final dock = dockLift;
    if (!venue3D || !chrome.showVenue3DChrome) return dock;
    final deck =
        _mapInset + dockLift + SeatLayerVenue3D.seatDeckHeight(seated: seated);
    return deck > dock ? deck : dock;
  }

  /// One gap above whatever else shares the map's bottom-left corner.
  static double _bottomLeftLift(SeatLayerPickerLayout layout) =>
      _mapInset + layout.accessibilityControlSize + _badgeGap;

  /// Whether the picker still has a rung of its own to descend.
  bool _ownsBackGesture(SeatLayerPickerState state) =>
      _sheetExpanded ||
      _hasOpenPrompt(state) ||
      state.snapshot?.map.rung == 'seats';

  bool _hasOpenPrompt(SeatLayerPickerState state) {
    if (SeatLayerPickerScope.optionsOf(context).readOnly) return false;
    if (state.generalAdmissionCandidate != null) return true;
    return _picker?.seatAwaitingConfirmation != null ||
        _picker?.seatAwaitingRemoval != null;
  }

  /// One rung down, in the order the buyer built them up.
  void _climbDown(
    SeatLayerPickerController controller,
    SeatLayerPickerState state,
  ) {
    if (_sheetExpanded) {
      _setSheetExpanded(false);
      return;
    }
    if (_hasOpenPrompt(state)) {
      final pending = controller.seatAwaitingConfirmation;
      if (state.generalAdmissionCandidate != null) {
        controller.dismissGeneralAdmissionCandidate();
        return;
      }
      if (pending != null) {
        ignorePickerAction(_removeSeat(controller, pending.label));
        return;
      }
      // Backing out of the remove question keeps the seat, exactly as Cancel
      // does: Back is a way out of the card, not an answer to it.
      if (controller.seatAwaitingRemoval != null) {
        controller.dismissSeatRemoval();
        return;
      }
    }
    if (state.snapshot?.map.rung == 'seats') {
      // Keep the web rung ladder: seats -> section -> venue, one Back gesture
      // at a time. The next snapshot decides whether another rung remains.
      ignorePickerAction(controller.zoomOut());
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
    if (!descended || !_sheetExpanded) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sheetExpanded) _setSheetExpanded(false);
    });
  }

  Future<void> _confirmSeat(SelectedSeat seat) async {
    if (!mounted) return;
    _picker?.markSeatAnswered(seat.label);
    _returnFocusToMap();
  }

  /// Put the buyer back on the map once the card that took the screen is done.
  ///
  /// After the frame that unmounts the card: requesting focus while the node
  /// that has it is still mounted is a request the framework immediately
  /// overrides.
  void _returnFocusToMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _mapFocus.canRequestFocus) _mapFocus.requestFocus();
    });
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

  /// Start, or retire, the wait for the map to be framed.
  ///
  /// Called from `build`. The clock starts when the picker becomes ready and
  /// is thrown away the moment the map is framed — or the runtime is reloaded
  /// and the phase leaves ready, which is when the next wait may begin.
  void _syncFramingGrace(SeatLayerPickerState state) {
    final waiting =
        state.phase == SeatLayerPickerPhase.ready && !state.mapFramed;
    if (!waiting) {
      _framingGraceTimer?.cancel();
      _framingGraceTimer = null;
      if (state.phase != SeatLayerPickerPhase.ready) {
        _framingGraceLapsed = false;
      }
      return;
    }
    if (_framingGraceLapsed || _framingGraceTimer != null) return;
    _framingGraceTimer = Timer(_mapFramingGrace, () {
      _framingGraceTimer = null;
      if (!mounted) return;
      setState(() => _framingGraceLapsed = true);
    });
  }

  /// Hand the runtime the current chrome bands.
  ///
  /// Called from `build`, which is where the numbers are known. The controller
  /// defers delivery until after the frame, drops repeats and coalesces a
  /// frame's calls into one command.
  ///
  /// Deliberately reported on every build rather than only when the numbers
  /// move: an unchanged report costs nothing past the controller's own
  /// de-duplication, and it is what tells the picker the map has been framed
  /// once the runtime is ready — see [SeatLayerPickerState.mapFramed].
  void _reportViewportInsets(SeatLayerViewportInsets insets) {
    _reportedInsets = insets;
    final controller = SeatLayerPickerScope.controllerOf(context);
    ignorePickerAction(controller.setViewportInsets(insets));
  }

  @override
  void dispose() {
    _mapFocus.dispose();
    _mapUnlockTimer?.cancel();
    _framingGraceTimer?.cancel();
    // The runtime outlives this layout during a route swap, and chrome that is
    // gone must not keep cropping the venue.
    if (_reportedInsets != null &&
        _reportedInsets != SeatLayerViewportInsets.zero) {
      ignorePickerAction(
        _picker?.setViewportInsets(null) ?? Future<void>.value(),
      );
    }
    super.dispose();
  }

  Future<void> _inspectSeat(Future<void> Function() action) async {
    if (!mounted) return;
    // The controller only completes after the command is accepted. The
    // runtime's panorama/3D state then hides the card without answering it,
    // so returning to the map restores the same Select/Cancel decision.
    await action();
  }

  /// Give a seat back because the buyer tapped the map around its card.
  ///
  /// The scrim is not decoration: it is the rest of the venue, and tapping it
  /// means "not this one" as plainly as the button does. It answers the same
  /// way the button does, cue included.
  Future<void> _dismissSeatCard(
    SeatLayerPickerController controller,
    SelectedSeat seat, {
    bool removing = false,
  }) async {
    controller.emitHaptic(PickerHapticCue.cardCancelled);
    // Only where the seat was a candidate. Tapping around a REMOVE card is the
    // buyer not answering it, and the seat they already have stays theirs — a
    // stray press on the map must never be the thing that empties a cart.
    if (removing) {
      controller.dismissSeatRemoval();
      return;
    }
    await _removeSeat(controller, seat.label);
  }

  Future<void> _removeSeat(
    SeatLayerPickerController controller,
    String label,
  ) async {
    try {
      await controller.removeObject(label);
    } finally {
      if (mounted) {
        controller.markSeatAnswered(label);
        // Giving a seat back ends the same dialog accepting one does, so the
        // buyer is put back in the same place either way.
        _returnFocusToMap();
      }
    }
  }
}
