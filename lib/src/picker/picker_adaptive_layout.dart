/// The composition root: how the phone and wide layouts put the parts together.
library;

import 'dart:async';
import 'dart:math' as math;

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
import 'picker_floor_strip.dart';
import 'picker_haptics.dart';
import 'picker_layout.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
import 'seat_layer_picker_controller.dart';
import 'picker_accessibility.dart';
import 'picker_attribution.dart';
import 'picker_errors.dart';
import 'picker_prompts.dart';
import 'picker_seat_view_chrome.dart';
import 'picker_section_navigator.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The breathing room between two stacked pieces of map chrome.
const double _badgeGap = 8;

/// Where the phone's map chrome starts, below the map's own top edge.
const double _railTop = 8;

/// How much of the map the immersive scene's own chrome is given when
/// nothing else stands in the map's top corners.
///
/// The prices are a row above the map rather than on it; only the Map/3D
/// control shares the map's top edge, and when it does the scene's chrome
/// steps below it — see `_immersiveTopInset`.
const double _venue3DRestingInset = 10;

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
        final wide =
            requested == SeatLayerPickerLayoutMode.wide ||
            (requested == SeatLayerPickerLayoutMode.adaptive &&
                constraints.maxWidth >= 840);
        final options = SeatLayerPickerScope.optionsOf(context);
        final chrome = options.chrome;
        final venue3DUp =
            !panoramaUp && (state.snapshot?.map.isVenue3D ?? false);
        final immersiveUp = panoramaUp || venue3DUp;
        final dockUp = !panoramaUp && !venue3DUp && _dockVisible(state);
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
        final floorStripUp =
            !panoramaUp &&
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
        final venue3D = panoramaUp
            ? const SizedBox.shrink()
            : _part(
                context,
                widget.builders.venue3D,
                SeatLayerVenue3D(
                  // The scene's own chrome starts at the map's edge: the
                  // prices are a row above the map, not a band on it.
                  topInset: immersiveTopInset,
                  bottomInset:
                      10 + (dockUp ? resolved.layout.dockBarHeight : 0.0),
                ),
              );
        // The panorama is full-screen web content inside the map surface, so
        // its words are drawn over the same box the picture fills.
        final seatViewChrome = _part(
          context,
          widget.builders.seatViewChrome,
          chrome.showSeatViewChrome
              ? SeatLayerSeatViewChrome(
                  topInset: wide ? 12 : immersiveTopInset,
                  bottomInset: wide
                      ? 12
                      : 10 + (dockUp ? resolved.layout.dockBarHeight : 0.0),
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

        // The controller owns which seat is still being asked about, so the
        // cart sheet and the checkout gate answer the same question this
        // layout does.
        final pendingSeat = controller.unansweredSeat;
        // The sheet never opens itself: a sheet that springs up on every pick
        // covers the map the buyer is still choosing from. It does collapse
        // itself when a seat card opens over the map, which is the tap the
        // runtime does report to native chrome.
        if (pendingSeat != null && _sheetExpanded) {
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
        } else if (!immersiveUp &&
            pendingSeat != null &&
            chrome.showConfirmCard) {
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
                SeatLayerPickerPhase.unavailable => ColoredBox(
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
                      child: Stack(
                        children: [
                          Positioned.fill(child: mapSurface),
                          Positioned(top: 12, left: 12, child: testBadge),
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
                          Positioned.fill(child: seatViewChrome),
                          if (!immersiveUp)
                            Positioned.fill(
                              key: const ValueKey<String>(
                                'seatlayer-picker-prompt-transition',
                              ),
                              child: _PickerPromptTransition(
                                scrimColor: pickerAlpha(
                                  resolved.background,
                                  .64,
                                ),
                                child: buyerPrompt,
                              ),
                            ),
                          Positioned.fill(
                            child: _PickerStatusOverlay(overlay: statusOverlay),
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
        final dockLift = dockUp ? resolved.layout.dockBarHeight : 0.0;
        // `‹ Back to venue` is drawn only once the scene is aimed at a seat,
        // so only then does anything stand in the badge's corner.
        final backPillUp =
            venue3DUp &&
            chrome.showVenue3DChrome &&
            state.snapshot?.map.view3DTargetSeatId != null;
        // One chrome row, not map chrome: the prices and the Map/3D control
        // are a band of their own between the header and the map, so the last
        // chip is never clipped under the control and no seat number is read
        // through either of them.
        final railUp = !panoramaUp && chrome.showPriceRail;
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
              height: resolved.layout.topRailHeight,
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
          state: state,
          dockLift: dockLift,
          venue3D: venue3DUp,
        );
        _reportViewportInsets(
          SeatLayerViewportInsets(top: topBand, bottom: bottomBand),
        );
        return Column(
          children: [
            header,
            if (railUp) topRail,
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: mapSurface),
                  // The floors are the one piece of "which seats am I looking
                  // at" chrome that stays on the map, so they start at the
                  // map's own edge.
                  if (floorStripUp && !venue3DUp)
                    Positioned(
                      top: _floorStripTop(viewModeControl: viewModeControlUp),
                      left: 0,
                      right: 0,
                      child: floorStrip,
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
                    left: 10,
                    child: testBadge,
                  ),
                  if (viewModeControlUp)
                    const Positioned(
                      top: _railTop,
                      right: 10,
                      child: SizedBox(
                        height: SeatLayerPickerViewModeControl.height,
                        child: SeatLayerPickerViewModeControl(),
                      ),
                    ),
                  if (chrome.showFloorSelector)
                    Positioned(
                      left: 10,
                      bottom: 62 + dockLift,
                      child: const SeatLayerPickerFloorSelector(),
                    ),
                  Positioned.fill(child: controls),
                  if (chrome.showVenue3DChrome) Positioned.fill(child: venue3D),
                  Positioned.fill(child: seatViewChrome),
                  if (chrome.showDockBar && dockUp)
                    Positioned(left: 0, right: 0, bottom: 0, child: dock),
                  if (!immersiveUp)
                    Positioned.fill(
                      key: const ValueKey<String>(
                        'seatlayer-picker-prompt-transition',
                      ),
                      child: _PickerPromptTransition(
                        // Ink, not ground: a pale wash left the map as loud
                        // as the card; a dark one makes the card the thing lit.
                        scrimColor: resolved.styles.scrimColor ??
                            pickerAlpha(resolved.text, .42),
                        // The phone's seat card is the product's one moment:
                        // the map goes soft behind it, it arrives from the
                        // seat's direction and points back at it, and the map
                        // it is covering is still the way out.
                        seatCard: seatCardUp,
                        anchor: seatCardUp ? pendingSeat?.screenPoint : null,
                        topInset: topBand,
                        bottomInset: bottomBand,
                        onDismiss: seatCardUp && pendingSeat != null
                            ? () => _dismissSeatCard(controller, pendingSeat)
                            : null,
                        child: buyerPrompt,
                      ),
                    ),
                  Positioned.fill(
                    child: _PickerStatusOverlay(overlay: statusOverlay),
                  ),
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
      child: themed,
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
    final control =
        viewModeControl ? _railTop + SeatLayerPickerViewModeControl.height : 0.0;
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
      return _floorStripTop(viewModeControl: viewModeControl) + floorStripHeight;
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
  /// The dock on the map, and in the scene the seat deck above it — which is
  /// taller once the buyer is sitting somewhere, because it grows a caption.
  /// The header and the cart sheet are rows of the same Column as the map, so
  /// the map surface already ends where they begin and they are correctly not
  /// reported.
  static double _bottomBand({
    required SeatLayerPickerChromeOptions chrome,
    required SeatLayerPickerState state,
    required double dockLift,
    required bool venue3D,
  }) {
    final dock = chrome.showDockBar ? dockLift : 0.0;
    if (!venue3D || !chrome.showVenue3DChrome) return dock;
    final seated = state.snapshot?.map.view3DTargetSeatId != null;
    final deck =
        10 + dockLift + SeatLayerVenue3D.seatDeckHeight(seated: seated);
    return deck > dock ? deck : dock;
  }

  /// Whether the picker still has a rung of its own to descend.
  bool _ownsBackGesture(SeatLayerPickerState state) =>
      _sheetExpanded ||
      _hasOpenPrompt(state) ||
      state.snapshot?.map.rung == 'seats';

  bool _hasOpenPrompt(SeatLayerPickerState state) {
    if (SeatLayerPickerScope.optionsOf(context).readOnly) return false;
    if (state.generalAdmissionCandidate != null) return true;
    return _picker?.seatAwaitingConfirmation != null;
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
    SelectedSeat seat,
  ) async {
    controller.emitHaptic(PickerHapticCue.cardCancelled);
    await _removeSeat(controller, seat.label);
  }

  Future<void> _removeSeat(
    SeatLayerPickerController controller,
    String label,
  ) async {
    try {
      await controller.removeObject(label);
    } finally {
      if (mounted) controller.markSeatAnswered(label);
    }
  }
}

/// One motion language for every native decision surface: scrim, seat card,
/// GA/table prompts and their exit. The canvas remains mounted underneath, so
/// opening a card never resets camera state or causes a map flash.
/// The loading/failure overlay, fading out rather than popping.
///
/// The map is revealed by lifting this, so a hard cut is the one thing that
/// makes a finished load look like a second one starting.
class _PickerStatusOverlay extends StatelessWidget {
  const _PickerStatusOverlay({required this.overlay});

  /// What to cover the map with, or null to reveal it.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: overlay == null,
        child: AnimatedSwitcher(
          // Arriving is not animated: the overlay is up before the buyer sees
          // the route at all. Only its departure is watched.
          duration: Duration.zero,
          reverseDuration: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.exit,
          ),
          switchOutCurve: SeatLayerPickerMotion.easeExit,
          child: overlay ?? const SizedBox.shrink(),
        ),
      );
}

class _PickerPromptTransition extends StatelessWidget {
  const _PickerPromptTransition({
    required this.scrimColor,
    required this.child,
    this.seatCard = false,
    this.anchor,
    this.topInset = 0,
    this.bottomInset = 0,
    this.onDismiss,
  });

  final Color scrimColor;
  final Widget? child;

  /// Whether the prompt is the phone's seat card.
  ///
  /// The card is the only prompt that behaves like a native moment rather than
  /// a dialog: a blurred backdrop, a spring from the seat's direction, a
  /// pointer back at the seat, and a way out by tapping the map behind it. The
  /// wide layout's dialog and the GA/table prompts keep the flat scrim.
  final bool seatCard;


  /// Where on the map the seat was drawn, if the runtime said.
  final Offset? anchor;

  /// The band of map the picker's own chrome is standing on, at the top.
  final double topInset;

  /// The same, at the bottom.
  final double bottomInset;

  /// Called when the buyer taps the map around the card.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => _build(context, constraints.biggest),
      );

  Widget _build(BuildContext context, Size area) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final prompt = child;
    final springy = seatCard && !reducedMotion;
    return IgnorePointer(
      ignoring: prompt == null,
      child: AnimatedSwitcher(
        duration: SeatLayerPickerMotion.of(
          context,
          seatCard
              ? SeatLayerPickerMotion.cardEnter
              : SeatLayerPickerMotion.enter,
        ),
        reverseDuration: SeatLayerPickerMotion.of(
          context,
          SeatLayerPickerMotion.exit,
        ),
        switchInCurve: SeatLayerPickerMotion.easeEnter,
        switchOutCurve: SeatLayerPickerMotion.easeExit,
        transitionBuilder: (current, animation) {
          if (reducedMotion) return current;
          final eased = CurvedAnimation(
            parent: animation,
            curve: SeatLayerPickerMotion.easeEnter,
            reverseCurve: SeatLayerPickerMotion.easeExit,
          );
          if (springy) {
            // The card comes from where the seat is: up from under the seat
            // when the seat is high on the map, down onto it when it is low.
            // Points, not a fraction of the card's own height — the distance
            // is a property of the gesture, not of how tall the card is.
            final dy = _arrivesFromBelow(area) ? _cardTravel : -_cardTravel;
            // The overshoot drives geometry only. Opacity stays on the eased
            // animation: a spring past 1 is a card that is briefly more than
            // opaque, which is not a thing, and the framework says so.
            final sprung = CurvedAnimation(
              parent: animation,
              curve: SeatLayerPickerMotion.spring,
              reverseCurve: SeatLayerPickerMotion.easeExit,
            );
            return FadeTransition(
              opacity: eased,
              child: AnimatedBuilder(
                animation: sprung,
                builder: (context, inner) => Transform.translate(
                  offset: Offset(0, dy * (1 - sprung.value)),
                  child: inner,
                ),
                // Leaving is a shrink towards the peek bar the ticket just
                // went to, so the card exits smaller than it entered.
                child: ScaleTransition(
                  scale: Tween<double>(begin: .96, end: 1).animate(sprung),
                  child: current,
                ),
              ),
            );
          }
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
            : _PromptBackdrop(
                key: ValueKey<Object>((
                  prompt.runtimeType,
                  prompt.key ?? prompt.runtimeType,
                )),
                scrimColor: scrimColor,
                onDismiss: onDismiss,
                // Each prompt owns its own insets: the phone confirm card is
                // specified as the screen less one 16pt gutter, and a shared
                // outer padding would quietly narrow it.
                child: seatCard
                    ? _SeatCardFrame(
                        anchor: anchor,
                        topInset: topInset,
                        bottomInset: bottomInset,
                        child: prompt,
                      )
                    : Center(child: prompt),
              ),
      ),
    );
  }

  /// Whether the card rises into place rather than settling down onto it.
  ///
  /// Measured against the card's resting middle — halfway down whatever the
  /// chrome has left of the map — rather than against where this particular
  /// card ends up, which is not known until it has been laid out. A seat above
  /// that line is a seat the card comes up from under. Without an anchor the
  /// card rises: a surface arriving from the bottom of a phone is the one
  /// entrance every buyer already knows.
  bool _arrivesFromBelow(Size area) {
    final seat = anchor;
    if (seat == null) return true;
    return seat.dy <= (topInset + (area.height - bottomInset)) / 2;
  }
}

/// How far the seat card travels on arrival, in logical points.
const double _cardTravel = 16;

/// The map behind a prompt: blurred and tinted for the seat card, flat for
/// everything else, and a way out either way.
///
/// The map is never unmounted for this. Blurring what is already drawn keeps
/// the venue present behind the decision — the buyer can still see the shape
/// of where they are — where a flat scrim only hides it.
class _PromptBackdrop extends StatelessWidget {
  const _PromptBackdrop({
    super.key,
    required this.scrimColor,
    required this.onDismiss,
    required this.child,
  });

  final Color scrimColor;


  final VoidCallback? onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A flat dim, never a blur: the seat the card is asking about has to stay
    // legible behind it, ring and all, or the question has no referent.
    final backdrop = ColoredBox(color: scrimColor);
    return Stack(
      children: [
        // The dismissing tap belongs to the backdrop, not to the whole area:
        // a detector wrapping both would take taps the card itself wanted.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: backdrop,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}


/// Puts the seat card where the seat is, and points it back at the seat.
///
/// The pointer is drawn here rather than inside the card because which edge
/// carries it is a fact about the placement, not about the card. Both edges
/// are reserved whatever happens, so the card's own box never changes size
/// when the pointer moves from one edge to the other.
class _SeatCardFrame extends StatefulWidget {
  const _SeatCardFrame({
    required this.anchor,
    required this.topInset,
    required this.bottomInset,
    required this.child,
  });

  final Offset? anchor;
  final double topInset;
  final double bottomInset;
  final Widget child;

  @override
  State<_SeatCardFrame> createState() => _SeatCardFrameState();
}

class _SeatCardFrameState extends State<_SeatCardFrame> {
  /// Which edge points at the seat, once the card's height is known.
  ///
  /// Null until the first layout has measured the card. The position itself is
  /// right from the first frame — the layout delegate knows the card's size
  /// when it places it — so all this lags by one frame is which 8 pt strip the
  /// pointer is painted in, inside a 320 ms arrival.
  SeatLayerConfirmCardNotch? _notch;

  void _report(SeatLayerConfirmCardNotch notch) {
    if (_notch == notch) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _notch != notch) setState(() => _notch = notch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notch = widget.anchor == null
        ? SeatLayerConfirmCardNotch.none
        : _notch ?? SeatLayerConfirmCardNotch.none;
    final theme = seatLayerPickerThemeOf(context);
    final layout = theme.layout;
    return LayoutBuilder(
      builder: (context, constraints) => CustomSingleChildLayout(
        delegate: _SeatCardLayout(
          anchor: widget.anchor,
          topInset: widget.topInset,
          bottomInset: widget.bottomInset,
          onPlacement: _report,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pointer(
              constraints.maxWidth,
              layout,
              theme.radius + 4,
              up: true,
              drawn: notch == SeatLayerConfirmCardNotch.top,
            ),
            widget.child,
            _pointer(
              constraints.maxWidth,
              layout,
              theme.radius + 4,
              up: false,
              drawn: notch == SeatLayerConfirmCardNotch.bottom,
            ),
          ],
        ),
      ),
    );
  }

  /// One reserved pointer strip, drawn only on the edge facing the seat.
  ///
  /// Held inside the card's own rounded corners: a pointer growing out of a
  /// corner reads as a torn edge rather than as an arrow, and it would be
  /// pointing at a seat the card's radius has already moved away from.
  Widget _pointer(
    double width,
    SeatLayerPickerLayout layout,
    double radius, {
    required bool up,
    required bool drawn,
  }) {
    const height = _pointerHeight;
    if (!drawn || !width.isFinite) {
      return const SizedBox(height: height);
    }
    final cardWidth = math.min(
      layout.confirmCardMaxWidth,
      width - (layout.confirmCardGutter * 2),
    );
    final left = (width - cardWidth) / 2;
    final x = widget.anchor!.dx.clamp(
      left + radius + _pointerWidth,
      left + cardWidth - radius - _pointerWidth,
    );
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: x - (_pointerWidth / 2),
            top: 0,
            child: SeatLayerConfirmCardPointer(
              up: up,
              height: height,
              width: _pointerWidth,
            ),
          ),
        ],
      ),
    );
  }
}

/// How far the pointer reaches out of the card, and how wide its base is.
const double _pointerHeight = 8;
const double _pointerWidth = 18;

/// Places the card+pointer box from [seatLayerConfirmCardPlacement].
class _SeatCardLayout extends SingleChildLayoutDelegate {
  const _SeatCardLayout({
    required this.anchor,
    required this.topInset,
    required this.bottomInset,
    required this.onPlacement,
  });

  final Offset? anchor;
  final double topInset;
  final double bottomInset;
  final void Function(SeatLayerConfirmCardNotch notch) onPlacement;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // The child is the card with one reserved pointer strip above and below,
    // so the card itself is that much shorter than the box being placed.
    final card = Size(childSize.width, childSize.height - (_pointerHeight * 2));
    final placement = seatLayerConfirmCardPlacement(
      seat: anchor,
      card: card,
      area: size,
      topInset: topInset,
      bottomInset: bottomInset,
    );
    onPlacement(placement.notch);
    return Offset(0, placement.top - _pointerHeight);
  }

  @override
  bool shouldRelayout(_SeatCardLayout oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.topInset != topInset ||
      oldDelegate.bottomInset != bottomInset;
}
