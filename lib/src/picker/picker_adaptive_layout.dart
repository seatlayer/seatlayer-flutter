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
import 'picker_floor_strip.dart';
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

/// Where the phone's map chrome starts, below the top rail of prices.
const double _mapChromeTop = 44;

/// The breathing room between two stacked pieces of map chrome.
const double _badgeGap = 8;

/// Where the top rail itself begins.
const double _railTop = 8;

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
        final dockUp = !panoramaUp && !venue3DUp && _dockVisible(state);
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
            onSectionChanged:
                SeatLayerPickerScope.callbacksOf(context).onSectionFocused,
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
        final venue3DTopInset =
            chrome.showPriceRail && !panoramaUp ? 46.0 : 10.0;
        final venue3D = panoramaUp
            ? const SizedBox.shrink()
            : _part(
                context,
                widget.builders.venue3D,
                SeatLayerVenue3D(
                  // Clear the legend, which stays on screen in the scene's palette.
                  topInset: venue3DTopInset,
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
                  topInset: wide ? 12 : venue3DTopInset,
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
                        bottomInset:
                            !wide && dockUp ? resolved.layout.dockBarHeight : 0,
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
                  ? (SelectedSeat seat) => _inspectSeat(
                        () => controller.openSeatView(seat),
                      )
                  : null;
          final onShow3D = options.enable3D && capabilities.contains('venue3d')
              ? (SelectedSeat seat) => _inspectSeat(
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
                          Positioned.fill(child: seatViewChrome),
                          if (!immersiveUp)
                            Positioned.fill(
                              key: const ValueKey<String>(
                                'seatlayer-picker-prompt-transition',
                              ),
                              child: _PickerPromptTransition(
                                scrimColor:
                                    pickerAlpha(resolved.background, .64),
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
        final dockLift = dockUp ? resolved.layout.dockBarHeight : 0.0;
        // What of the map this composition is standing on. Only chrome drawn
        // OVER the map counts: the header and the cart sheet are rows of the
        // same Column, so the map surface begins and ends where they do and
        // the runtime already frames inside them. The rail and the dock are
        // not — they are stacked on the map — so a section framed to the whole
        // surface lands partly underneath them unless the runtime is told.
        _reportViewportInsets(
          SeatLayerViewportInsets(
            top: _topBand(
              chrome: chrome,
              panorama: panoramaUp,
              testBadge: state.isTestEvent,
              venue3D: venue3DUp,
              venue3DTopInset: venue3DTopInset,
              floorStrip: floorStripUp,
              floorStripHeight: floorStripHeight,
            ),
            bottom: _bottomBand(
              chrome: chrome,
              state: state,
              dockLift: dockLift,
              venue3D: venue3DUp,
            ),
          ),
        );
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
                        // The rail stops short of the control: its soft edge
                        // then finishes in clear space rather than against the
                        // control's own edge, which reads as a cut.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: prices,
                          ),
                        ),
                        if (chrome.showMapControls && !panoramaUp)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SeatLayerPickerViewModeControl(),
                          ),
                      ],
                    ),
                  ),
                  // The floors sit directly under the prices: both answer
                  // "which of these seats am I looking at", and stacking them
                  // keeps one band of map chrome rather than two.
                  if (floorStripUp && !venue3DUp)
                    Positioned(
                      top: _mapChromeTop,
                      left: 0,
                      right: 0,
                      child: floorStrip,
                    ),
                  // The immersive scene puts `‹ Back to venue` in this
                  // corner; the badge steps below that pill rather than under
                  // it, measured from the same inset the pill is given.
                  Positioned(
                    top: _testBadgeTop(
                      chrome: chrome,
                      venue3D: venue3DUp,
                      venue3DTopInset: venue3DTopInset,
                      floorStrip: floorStripUp,
                      floorStripHeight: floorStripHeight,
                    ),
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
                  Positioned.fill(child: seatViewChrome),
                  if (chrome.showDockBar && dockUp)
                    Positioned(left: 0, right: 0, bottom: 0, child: dock),
                  if (!immersiveUp)
                    Positioned.fill(
                      key: const ValueKey<String>(
                        'seatlayer-picker-prompt-transition',
                      ),
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
  /// The rail is one band the runtime must frame inside; the test badge is a
  /// second, stacked under it, and a test event is not a rare case — it is
  /// what every integration sees first. In the immersive scene the rail is
  /// gone and `‹ Back to venue` takes its place, at its own inset.
  static double _topBand({
    required SeatLayerPickerChromeOptions chrome,
    required bool panorama,
    required bool testBadge,
    required bool venue3D,
    required double venue3DTopInset,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    if (panorama) return 0;
    final rail = _topRailBand(
      chrome: chrome,
      venue3D: venue3D,
      venue3DTopInset: venue3DTopInset,
      floorStrip: floorStrip,
      floorStripHeight: floorStripHeight,
    );
    if (!testBadge) return rail;
    return _testBadgeTop(
          chrome: chrome,
          venue3D: venue3D,
          venue3DTopInset: venue3DTopInset,
          floorStrip: floorStrip,
          floorStripHeight: floorStripHeight,
        ) +
        SeatLayerPickerTestModeIndicator.compactHeight;
  }

  /// The band the rail, or the scene's way back, occupies on its own.
  static double _topRailBand({
    required SeatLayerPickerChromeOptions chrome,
    required bool venue3D,
    required double venue3DTopInset,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    if (venue3D) {
      return chrome.showVenue3DChrome
          ? venue3DTopInset + SeatLayerVenue3D.backPillHeight
          : 0;
    }
    // The floor chips are stacked directly under the rail, so the band the
    // runtime must frame inside runs to the bottom of them.
    if (floorStrip) return _mapChromeTop + floorStripHeight;
    return chrome.showPriceRail || chrome.showMapControls ? _mapChromeTop : 0;
  }

  /// Where the test-mode badge sits, which is one line under whatever is
  /// above it — or at the rail's own start when nothing is.
  static double _testBadgeTop({
    required SeatLayerPickerChromeOptions chrome,
    required bool venue3D,
    required double venue3DTopInset,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    final rail = _topRailBand(
      chrome: chrome,
      venue3D: venue3D,
      venue3DTopInset: venue3DTopInset,
      floorStrip: floorStrip,
      floorStripHeight: floorStripHeight,
    );
    return rail == 0 ? _railTop : rail + _badgeGap;
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

  /// Hand the runtime the current chrome bands.
  ///
  /// Called from `build`, which is where the numbers are known. The controller
  /// defers delivery until after the frame, drops repeats and coalesces a
  /// frame's calls into one command.
  void _reportViewportInsets(SeatLayerViewportInsets insets) {
    if (_reportedInsets == insets) return;
    _reportedInsets = insets;
    final controller = SeatLayerPickerScope.controllerOf(context);
    ignorePickerAction(controller.setViewportInsets(insets));
  }

  @override
  void dispose() {
    _mapUnlockTimer?.cancel();
    // The runtime outlives this layout during a route swap, and chrome that is
    // gone must not keep cropping the venue.
    if (_reportedInsets != null &&
        _reportedInsets != SeatLayerViewportInsets.zero) {
      ignorePickerAction(
          _picker?.setViewportInsets(null) ?? Future<void>.value());
    }
    super.dispose();
  }

  Future<void> _inspectSeat(
    Future<void> Function() action,
  ) async {
    if (!mounted) return;
    // The controller only completes after the command is accepted. The
    // runtime's panorama/3D state then hides the card without answering it,
    // so returning to the map restores the same Select/Cancel decision.
    await action();
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
