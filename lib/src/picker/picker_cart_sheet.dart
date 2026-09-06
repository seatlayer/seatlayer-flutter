import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'picker_a11y.dart';
import 'picker_best_seats.dart';
import 'picker_cart_list.dart';
import 'picker_checkout_cta.dart';
import 'picker_header.dart';
import 'picker_hold_lapse.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_haptics.dart';
import 'picker_options.dart';
import 'picker_sheet_drag.dart';
import 'picker_states.dart';
import 'picker_styles.dart';
import 'picker_tokens.g.dart';
import 'picker_attribution.dart';
import 'picker_errors.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The buyer's cart, docked at the bottom of the phone.
///
/// ONE SURFACE, AND THE COLLAPSED SHEET IS THE FOOTER (owner call
/// 2026-09-06). It used to be three stacked blocks that had each been designed
/// well on its own and none of which agreed with the others: a chrome band
/// carrying a bespoke one-liner — `From €25 · Find seats` with nothing picked,
/// `2 tickets · Continue €60` once seats existed — then a bordered list on its
/// own ground, then a shadowed foot. Two summaries of one cart is two things
/// to keep in step, and they drifted: the hold clock moved as the sheet
/// opened, and a buyer with seats already held could not see the button that
/// takes their money, because the foot that carries it was hidden at peek.
///
/// So the collapsed sheet is the same block the open one has, top to bottom:
/// the handle, the cart itself — capped at three cards and a sliver of the
/// fourth, scrolling inside its own box — then the total line, the call to
/// action and the by-line. Opening it lifts the cap and adds the things there
/// is no room to read at peek: the closed-sales statement and the best-seats
/// form.
///
/// It never opens itself. A sheet that springs up when a seat is picked covers
/// the map the buyer is still choosing from.
///
/// It is a real sheet, not a panel that toggles. The head and the body follow
/// the finger point for point, the ends give rather than stop, and letting go
/// hands the sheet to a spring that carries the finger's own speed into the
/// nearest detent — [SeatLayerSheetDetent]. The tap and the short drag still
/// work exactly as they did, because a sheet whose only way to open is a
/// gesture is a sheet some buyers cannot open.
class SeatLayerCartSheet extends StatefulWidget {
  /// Creates a cart sheet.
  const SeatLayerCartSheet({
    super.key,
    required this.expanded,
    required this.onExpandedChanged,
    required this.onCheckout,
    this.cartList,
    this.bestSeats,
    this.checkoutBar,
    this.actionError,
    this.attribution = const SeatLayerPickerAttribution(compact: true),
    this.reserveBottomInset = true,
    this.style,
    this.continueButtonStyle,
  });

  /// Whether the sheet is open.
  final bool expanded;

  /// Asks the host to open or collapse the sheet.
  final ValueChanged<bool> onExpandedChanged;

  /// Receives the hold when the buyer continues to checkout.
  final SeatLayerCheckoutCallback onCheckout;

  /// Replaces the ticket list.
  final Widget? cartList;

  /// Replaces the best-available form the open sheet shows while the cart is
  /// empty.
  final Widget? bestSeats;

  /// Replaces the footer call to action.
  final Widget? checkoutBar;

  /// Replaces the inline action error.
  final Widget? actionError;

  /// Overrides [SeatLayerPickerStyles.sheetStyle] for this sheet.
  final SeatLayerSurfaceStyle? style;

  /// Overrides the footer button's style for this sheet.
  ///
  /// The sheet used to draw a second, smaller `Continue` on its collapsed bar
  /// and this named it. There is one button on the sheet now, so this reaches
  /// that one — above [SeatLayerPickerStyles.primaryButtonStyle], which it
  /// merges over.
  final ButtonStyle? continueButtonStyle;

  /// The required SeatLayer attribution.
  final Widget attribution;

  /// Whether to reserve the device's bottom inset below the sheet.
  final bool reserveBottomInset;

  @override
  State<SeatLayerCartSheet> createState() => _SeatLayerCartSheetState();
}

class _SeatLayerCartSheetState extends State<SeatLayerCartSheet>
    with SingleTickerProviderStateMixin {
  /// How much taller the cart region is than the collapsed sheet already
  /// shows, in logical points. Unbounded because a drag is allowed past both
  /// ends: the value leaves `[0, top]` only while a finger is holding it there.
  ///
  /// EXTRA, not total. The collapsed sheet already draws three cards and the
  /// whole foot, so peek is zero here exactly as it was when the collapsed
  /// sheet drew nothing but a bar — and every detent below stays a height of
  /// the part that actually changes size.
  late final AnimationController _extent =
      AnimationController.unbounded(vsync: this)..addListener(_onExtent);

  /// Where the finger has put the sheet, before the rubber band is applied.
  double _raw = 0;

  /// How far the current drag has travelled, so a short deliberate drag still
  /// answers even when the physics would have settled it back.
  double _travel = 0;
  bool _dragging = false;

  /// The spring's destination while one is in flight, so a cancelled spring
  /// cannot snap the sheet to a target that has since been replaced.
  double? _springingTo;

  /// What the cart, the open-only extras and the foot measured at.
  double _cartNatural = 0;
  double _extrasNatural = 0;
  double _footHeight = 0;

  /// What the collapsed sheet is already showing of the cart, so the detents
  /// below measure only the part the drag adds.
  double _collapsedCart = 0;

  PickerSheetDetents _detents = const PickerSheetDetents(content: 0, full: 0);

  SeatLayerSheetDetent _detent = SeatLayerSheetDetent.peek;

  /// How far a drag has to travel before it counts as opening or closing.
  ///
  /// The accessible floor under the physics: a buyer who moves the head by a
  /// deliberate but small amount has asked for the sheet to change, even
  /// though the nearest detent is still the one they started at.
  static const double _dragThreshold = 18;

  @override
  void initState() {
    super.initState();
    _detent = widget.expanded
        ? SeatLayerSheetDetent.content
        : SeatLayerSheetDetent.peek;
  }

  @override
  void didUpdateWidget(SeatLayerCartSheet old) {
    super.didUpdateWidget(old);
    if (widget.expanded == old.expanded) return;
    // Already there. The host is usually only echoing back the sheet's own
    // last answer, and restarting the spring on the echo would make every
    // opening tap stutter halfway.
    if (widget.expanded == (_detent != SeatLayerSheetDetent.peek)) return;
    // The host — or the map, which collapses the sheet when the buyer taps it
    // — has moved the sheet. Full is never entered this way: it is a place the
    // buyer's own finger reaches.
    _settle(
      widget.expanded
          ? SeatLayerSheetDetent.content
          : SeatLayerSheetDetent.peek,
      velocity: 0,
      publish: false,
    );
  }

  @override
  void dispose() {
    _extent.dispose();
    super.dispose();
  }

  void _onExtent() => setState(() {});

  /// A measured part changed height. Reported after layout, so acting on it
  /// here is safe.
  void _measured(double current, double next, ValueChanged<double> assign) {
    if (!mounted || (next - current).abs() < PickerSheetDetents.epsilon) return;
    setState(() => assign(next));
    // A cart that grew while the sheet was open moves the detent the sheet is
    // resting at with it, rather than leaving the sheet at the height of an
    // order it no longer holds.
    if (!_dragging && _springingTo == null) _snapToDetent();
  }

  double _heightOf(SeatLayerSheetDetent detent) => _detents.heightOf(detent);

  /// Put the sheet where its detent says, without a spring: this is a
  /// correction, not a movement the buyer asked for.
  void _snapToDetent() {
    final target = _heightOf(_detent);
    if ((_extent.value - target).abs() < PickerSheetDetents.epsilon) return;
    _extent.value = target;
    _raw = target;
  }

  /// Come to rest at [detent], carrying [velocity] into the spring.
  void _settle(
    SeatLayerSheetDetent detent, {
    required double velocity,
    bool publish = true,
  }) {
    _detent = detent;
    final target = _heightOf(detent);
    _raw = target;
    if (publish) _publish(detent);
    if (SeatLayerPickerMotion.reduced(context)) {
      _springingTo = null;
      _extent.value = target;
      return;
    }
    _springingTo = target;
    _extent
        .animateWith(
      SpringSimulation(pickerSheetSpring, _extent.value, target, velocity),
    )
        .whenComplete(() {
      if (!mounted || _springingTo != target) return;
      _springingTo = null;
      // The simulation stops within a tolerance of its target, and a sheet
      // that came to rest a third of a point short of its detent would make
      // every measurement of it a different number.
      _extent.value = target;
    });
  }

  /// Tell the controller — and the host — where the sheet came to rest.
  void _publish(SeatLayerSheetDetent detent) {
    SeatLayerPickerScope.controllerOf(context).setCartSheetDetent(detent);
    final expanded = detent != SeatLayerSheetDetent.peek;
    if (expanded != widget.expanded) widget.onExpandedChanged(expanded);
  }

  void _onDragStart(DragStartDetails details) {
    _extent.stop();
    _springingTo = null;
    _dragging = true;
    _travel = 0;
    _raw = _extent.value;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Up grows the sheet: the finger and the top edge move together.
    final delta = -details.delta.dy;
    _raw += delta;
    _travel += delta;
    _extent.value = pickerRubberBand(_raw, 0, _detents.top);
  }

  void _onDragEnd(DragEndDetails details) {
    _dragging = false;
    final velocity = -details.velocity.pixelsPerSecond.dy;
    var detent = _detents.settle(height: _extent.value, velocity: velocity);
    // The accessible floor: a deliberate short drag answers, even where the
    // spring would have carried the sheet back to where it started.
    if (detent == _detent && _travel.abs() >= _dragThreshold) {
      final order = _detents.offered;
      final at = order.indexOf(_detent);
      final next = _travel > 0 ? at + 1 : at - 1;
      if (next >= 0 && next < order.length) detent = order[next];
    }
    _settle(detent, velocity: velocity);
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    // The sheet caps the same surface the header and the legend do, so it
    // takes the same palette: white chrome docked under a dark venue scene
    // reads as a mistake, and the three were disagreeing in 3D.
    final theme = seatLayerMapChromeThemeOf(context);
    final layout = theme.layout;
    final bottomInset =
        widget.reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final hasTickets = controller.confirmedCartLines.isNotEmpty;
    final salesClosed = controller.state.event?.salesClosed == true;
    // The handle is a control, not type: it stays the size a thumb needs
    // whatever the platform's text setting is, and the head is exactly the
    // half of it that sits inside the panel.
    final overhang = layout.sheetHandleOverhang;
    final headHeight = layout.sheetHeadHeight;

    // Two ceilings, both a fraction of the screen capped at a fixed height: a
    // tall phone must not give three quarters of itself to a cart, and a short
    // one must not be told that seventy-two per cent is enough.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheet = hasTickets
        ? _atMost(
            screenHeight * layout.sheetMaxHeightFraction, layout.sheetMaxHeight)
        : _atMost(screenHeight * layout.emptyTrayMaxHeightFraction,
            layout.emptyTrayMaxHeight);
    // Everything that is not the cart region. The foot is measured rather than
    // assumed: it grows with the platform's text size, with a lapse notice and
    // with an inline error, and a cap derived from a guess would clip the
    // button rather than the list.
    final chrome = headHeight + _footHeight + bottomInset;
    final maxBody = (maxSheet - chrome).clamp(0.0, screenHeight);

    // THREE CARDS AND A SLIVER OF THE FOURTH. Ten tickets used to be a sheet
    // that grew until it owned the phone; the cart scrolls inside its own box
    // and the map keeps its room. On a short phone the fraction wins instead,
    // the region shrinks and scrolls, and the button is never what gets cut.
    // The collapsed sheet is the footer block alone — the total line and the
    // button. The cards wait behind the handle: a list that unrolled itself
    // every time a seat was added read as a panel the buyer had not opened.
    _collapsedCart = 0.0;
    // THREE CARDS AND A SLIVER OF THE FOURTH once open: the cart scrolls
    // inside its own box and the map keeps its room.
    final openNatural =
        _atMost(_cartNatural, layout.cartPeekMaxHeight) + _extrasNatural;
    final content =
        (_atMost(openNatural, maxBody) - _collapsedCart).clamp(0.0, maxBody);
    // The one height the web has no equivalent for: how far a FINGER may pull
    // the sheet past the ceiling the picker itself would stop at. Offered only
    // when the content is taller than the ceiling — see [PickerSheetDetents].
    final fullCeiling =
        (screenHeight * layout.sheetFullHeightFraction - chrome).clamp(
      0.0,
      screenHeight,
    );
    final full = (_atMost(openNatural, fullCeiling) - _collapsedCart)
        .clamp(0.0, screenHeight);
    _detents = PickerSheetDetents(content: content, full: full);
    _keepRestingHeight();

    final extent = _extent.value;
    // Below the collapsed sheet there is nowhere to shrink, so an overdrag
    // moves the whole surface off the bottom edge instead — the finger keeps
    // hold of it, and the spring puts it back.
    final belowPeek = extent < 0 ? -extent : 0.0;
    final body = _collapsedCart + (extent > 0 ? extent : 0.0);
    // The head answers to the FINGER, not to the last answer the host gave: a
    // sheet being dragged open is open, whatever the controller has been told.
    final open = _detent != SeatLayerSheetDetent.peek ||
        extent > PickerSheetDetents.epsilon;

    final surface = (theme.styles.sheetStyle ?? const SeatLayerSurfaceStyle())
        .merge(widget.style);
    return Transform.translate(
      offset: Offset(0, belowPeek),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // The sheet's own semantics are its buttons; a drag handle announced
        // over the whole surface would be one more thing to swipe past.
        excludeFromSemantics: true,
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: SeatLayerTypeScale.sheet(
          child: Stack(
            // THE HANDLE STRADDLES THE EDGE, so half of it is outside the
            // panel. The stack takes the overhang into its own height (the
            // padding below), which is what lets that half be drawn AND
            // pressed — a positioned child outside the stack's box is not hit
            // tested at all.
            clipBehavior: Clip.none,
            children: <Widget>[
              // The panel fills the box; the handle's upper half hangs over the
              // MAP above it rather than over a strip of page ground, which is
              // what a padded stack left between the venue and the edge.
              Padding(
                padding: EdgeInsets.zero,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    // A hairline and nothing else above it: the web's upward
                    // shadow read as a grey band over the map on a phone, a
                    // few points of nothing between the venue and the handle.
                    border: Border(top: BorderSide(color: theme.divider)),
                  ),
                  child: Material(
                    // The PANEL'S own ground, not the card's: the cards inside
                    // are on `surface`, and a sheet painted the same colour
                    // would leave them with nothing to sit on.
                    color: surface.color ?? theme.background,
                    elevation: surface.elevation ?? 0,
                    shape: surface.shape,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // The lower half of the handle, and nothing drawn
                          // under it: no divider, no band.
                          SizedBox(height: headHeight),
                          _CartRegion(
                            height: body,
                            open: open,
                            salesClosed: salesClosed,
                            hasTickets: hasTickets,
                            cartList: widget.cartList,
                            bestSeats: widget.bestSeats,
                            onCart: (value) =>
                                _measured(_cartNatural, value, (v) {
                              _cartNatural = v;
                            }),
                            onExtras: (value) =>
                                _measured(_extrasNatural, value, (v) {
                              _extrasNatural = v;
                            }),
                          ),
                          PickerMeasuredHeight(
                            onHeight: (value) =>
                                _measured(_footHeight, value, (v) {
                              _footHeight = v;
                            }),
                            child: _SheetFoot(
                              divider: open && hasTickets,
                              actionError: widget.actionError,
                              checkoutBar: widget.checkoutBar,
                              attribution: widget.attribution,
                              onCheckout: widget.onCheckout,
                              onFindBestSeats: () => _openBestSeatsForm(),
                              buttonStyle: widget.continueButtonStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: -overhang,
                start: 0,
                end: 0,
                child: _SheetHandle(
                  expanded: open,
                  height: overhang + headHeight,
                  onPressed: () => _ask(!open),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The empty cart's way in to the best-seats form.
  ///
  /// Still a FORM, not a verb: it reveals quantity, type and zone and picks
  /// nothing for anyone. The form only exists inside the open sheet, so the
  /// press opens the sheet on it.
  void _openBestSeatsForm() => _ask(true);

  /// The tap and the handle still speak in open/shut; the detent follows.
  void _ask(bool expanded) => _settle(
        expanded ? SeatLayerSheetDetent.content : SeatLayerSheetDetent.peek,
        velocity: 0,
      );

  /// Keep the sheet standing on its own detent when the detent itself moves —
  /// a rotated phone, a cart that grew, a keyboard that took the screen.
  void _keepRestingHeight() {
    if (_dragging || _springingTo != null) return;
    final resting = _detents.heightOf(_detent);
    if ((_extent.value - resting).abs() < PickerSheetDetents.epsilon) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_dragging && _springingTo == null) _snapToDetent();
    });
  }
}

/// The cart, and the things only the open sheet has room for.
///
/// A window onto its own content: the region is a scroll view at whatever
/// height the sheet is currently giving it, and the content inside is laid out
/// at the height it wants. Collapsed, that shows three cards and a sliver of
/// the fourth and scrolls; opened, the cap lifts and the extras appear under
/// the cards.
///
/// The extras stay in the tree while the sheet is shut — offstage, which still
/// LAYS THEM OUT — so the sheet always knows how tall it would open to, and
/// opens straight to it rather than springing to a guess and correcting.
class _CartRegion extends StatelessWidget {
  const _CartRegion({
    required this.height,
    required this.open,
    required this.salesClosed,
    required this.hasTickets,
    required this.cartList,
    required this.bestSeats,
    required this.onCart,
    required this.onExtras,
  });

  final double height;
  final bool open;
  final bool salesClosed;
  final bool hasTickets;
  final Widget? cartList;
  final Widget? bestSeats;
  final ValueChanged<double> onCart;
  final ValueChanged<double> onExtras;

  @override
  Widget build(BuildContext context) {
    final strings = SeatLayerPickerScope.stringsOf(context);
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        // The list scrolls inside its own box rather than pushing the sheet:
        // the map keeps its room whatever the cart holds.
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PickerMeasuredHeight(
              onHeight: onCart,
              child: hasTickets
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        SeatLayerSizeTokens.cartTrayPadX,
                        SeatLayerSizeTokens.cartTrayPadTop,
                        SeatLayerSizeTokens.cartTrayPadX,
                        SeatLayerSizeTokens.cartTrayPadBottom,
                      ),
                      child: cartList ?? const SeatLayerCartList(),
                    )
                  : const SizedBox.shrink(),
            ),
            Offstage(
              offstage: !open,
              child: PickerMeasuredHeight(
                onHeight: onExtras,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    SeatLayerSizeTokens.cartTrayPadX,
                    hasTickets ? 0 : SeatLayerSizeTokens.cartTrayPadTop,
                    SeatLayerSizeTokens.cartTrayPadX,
                    SeatLayerSizeTokens.cartTrayPadBottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // An event that has stopped selling is a state the tray
                      // states in its own words, not a set of controls that
                      // quietly go grey.
                      if (salesClosed)
                        const SeatLayerPickerSalesClosedStatement(),
                      if (!hasTickets) ...<Widget>[
                        // The hint is read out, never drawn. On a screen
                        // showing a seat map and a form for finding seats, a
                        // sentence explaining that you may tap a seat or use
                        // the form is the tray's tallest element saying the
                        // least.
                        Semantics(
                          label: strings.emptyTrayHint,
                          child: const SizedBox.shrink(),
                        ),
                        bestSeats ?? const SeatLayerBestSeatsForm(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The handle: a pill straddling the sheet's own top edge, the way a drawer
/// handle sits on a drawer.
///
/// It used to be a grab bar and, separately, a chevron in a corner — the state
/// and the control that changes it drawn as two different things. It is one
/// thing now: the chevron lives inside the pill and turns over when the sheet
/// opens. The whole band is the tap target, and the sheet's own drag runs
/// under it, because a ten-point strip is not something a thumb can grab.
class _SheetHandle extends StatelessWidget {
  const _SheetHandle({
    required this.expanded,
    required this.height,
    required this.onPressed,
  });

  final bool expanded;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final layout = theme.layout;
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Semantics(
      container: true,
      button: true,
      expanded: expanded,
      label: expanded ? strings.collapseCart : strings.expandCart,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onPressed,
          child: SizedBox(
            height: height,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: layout.sheetHandleWidth,
                height: layout.sheetHandleHeight,
                decoration: BoxDecoration(
                  // 62 per cent OF the hairline, not 62 per cent opacity: the
                  // divider token already carries its own alpha, and replacing
                  // it painted a dark slate lozenge where the web has a pale
                  // grey one.
                  color: Color.alphaBlend(
                    pickerAlpha(theme.divider, theme.divider.a * .62),
                    theme.background,
                  ),
                  border: Border.all(color: theme.divider),
                  borderRadius:
                      BorderRadius.circular(SeatLayerRadiusTokens.pill),
                ),
                child: AnimatedRotation(
                  duration: SeatLayerPickerMotion.of(
                    context,
                    SeatLayerPickerMotion.chevron,
                  ),
                  curve: SeatLayerPickerMotion.easeEnter,
                  turns: expanded ? .5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 16,
                    color: theme.mutedText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The foot: what the cart comes to, the way on, and the by-line.
///
/// The SAME block on every width, and the one the collapsed sheet shows. It is
/// not restyled on a phone at all — one set of tokens is one thing to get
/// right, and the only difference the phone has left is the WORD on the
/// button, which [seatLayerCheckoutCtaState] decides.
class _SheetFoot extends StatelessWidget {
  const _SheetFoot({
    required this.divider,
    required this.actionError,
    required this.checkoutBar,
    required this.attribution,
    required this.onCheckout,
    required this.onFindBestSeats,
    required this.buttonStyle,
  });

  final Widget? actionError;
  final Widget? checkoutBar;
  final Widget attribution;

  /// Whether a card list sits above the foot and wants a rule under it.
  ///
  /// The collapsed sheet has nothing above the foot but the panel's own top
  /// edge, and a second hairline a few points under the first read as two
  /// lines for one edge.
  final bool divider;
  final SeatLayerCheckoutCallback onCheckout;
  final VoidCallback onFindBestSeats;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(top: BorderSide(color: theme.divider))
            : const Border(),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SeatLayerSizeTokens.footPadX,
          SeatLayerSizeTokens.footPadTop,
          SeatLayerSizeTokens.footPadX,
          SeatLayerSizeTokens.footPadBottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // News about the buyer's own seats outranks the layout: a toast is
            // gone in four seconds, and the offer to take lapsed seats back has
            // to outlive it.
            const SeatLayerHoldLapseNotice(),
            const SeatLayerHoldEndingCue(),
            actionError ?? const SeatLayerPickerActionError(),
            const _TotalLine(),
            const SizedBox(height: SeatLayerSizeTokens.footTotalGap),
            checkoutBar ??
                SeatLayerBookButton(
                  onCheckout: onCheckout,
                  onFindBestSeats: onFindBestSeats,
                  style: buttonStyle,
                ),
            // Centred, not trailing: at the foot of a phone the trailing edge
            // is the display's rounded corner, and a credit tucked into it lost
            // its last letters behind the glass.
            Center(child: attribution),
          ],
        ),
      ),
    );
  }
}

/// What is in the cart, and what it comes to.
///
/// "No seats selected" on an empty cart, `3 tickets` and the total once there
/// is one. There is no `From €25` here any more: it stated a price and offered
/// nothing to do about it, on the one line the buyer reads to find out what
/// they are about to pay.
class _TotalLine extends StatefulWidget {
  const _TotalLine();

  @override
  State<_TotalLine> createState() => _TotalLineState();
}

class _TotalLineState extends State<_TotalLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.bump,
  );
  String _last = '';

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final state = controller.state;
    // What the buyer has AGREED to. A tapped seat is in the runtime's
    // selection — and so in the cart, the count and the total — from the
    // moment it is tapped, but a confirm card standing over the map is still
    // asking whether they want it.
    final count = controller.confirmedTicketCount;
    final currency = state.snapshot?.currency ?? 'USD';
    final summary =
        count == 0 ? strings.noSeatsSelected : strings.ticketCount(count);
    final total = count == 0
        ? ''
        : pickerMoney(context, controller.confirmedCartTotal, currency);
    if (summary != _last) {
      _last = summary;
      if (!SeatLayerPickerMotion.reduced(context)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _bump.forward(from: 0);
        });
      }
    }
    // Which seats, in one muted line under the count, while the cards are
    // folded away: "2 tickets" alone told the buyer they had bought something
    // and not what, and the chevron above was the only way to find out.
    final collapsed = !controller.cartSheetExpanded;
    final seats = collapsed && count > 0
        ? controller.confirmedCartLines
            .map((line) => line.label.replaceAll('-', ' · '))
            .join(',  ')
        : '';
    final line = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: _bumped(
                SeatLayerCrossFade(
                  token: summary,
                  child: Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // design/tokens.json › type.footTotalLabel.
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 13,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
            if (total.isNotEmpty)
              SeatLayerCrossFade(
                token: total,
                child: Text(
                  total,
                  softWrap: false,
                  // design/tokens.json › type.footTotalAmount.
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 17,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
                    fontFamily: theme.fontFamily,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
          ],
        );
    return Semantics(
      // The one line that says what the cart holds. It is announced on change
      // rather than on a timer: the sentence changes when the cart does, and
      // never otherwise, so the live region speaks exactly as often as
      // something happened.
      liveRegion: true,
      container: true,
      label: total.isEmpty ? summary : '$summary, $total',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: collapsed && count > 0
              ? () => controller.setCartSheetExpanded(true)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              line,
              if (seats.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          seats,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 12,
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w600),
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Not the handle's chevron: the handle stays the cart's
                      // one named toggle, and this is only a hint that the
                      // line opens.
                      Icon(
                        Icons.unfold_more_rounded,
                        size: 16,
                        color: theme.mutedText,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The one beat of movement a changed count earns: the only feedback a buyer
  /// gets that a tap on the map reached a collapsed sheet.
  Widget _bumped(Widget child) => AnimatedBuilder(
        animation: _bump,
        // Anchored on the leading edge, so the words grow out of the line
        // rather than sliding across it.
        builder: (context, inner) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Transform.scale(
            scale: 1 + (.15 * _bumpCurve(_bump.value)),
            alignment: AlignmentDirectional.centerStart,
            child: inner,
          ),
        ),
        child: child,
      );

  /// Out to the full swell at forty-five per cent, and back.
  static double _bumpCurve(double t) => t <= .45
      ? SeatLayerPickerMotion.easeEnter.transform(t / .45)
      : SeatLayerPickerMotion.easeEnter.transform((1 - t) / .55);
}

/// The one call to action that turns a cart into a hold.
///
/// Full width, and carrying nothing but its own label: the total is already on
/// the line above it, and stating it twice on one foot is how the button ended
/// up being read as a second, different price.
///
/// ONE BUTTON, TWO DOORS. With an empty cart on a phone it offers the
/// best-seats form instead of a disabled label — see [onFindBestSeats] and
/// [seatLayerCheckoutCtaState], which the wide layout's checkout bar resolves
/// too.
class SeatLayerBookButton extends StatelessWidget {
  /// Creates the checkout call to action.
  const SeatLayerBookButton({
    super.key,
    required this.onCheckout,
    this.onFindBestSeats,
    this.style,
  });

  /// Receives the hold once the runtime has created it.
  final SeatLayerCheckoutCallback onCheckout;

  /// Opens the best-seats form, where this button is the only thing on screen
  /// and an empty cart would otherwise leave it dead.
  ///
  /// Null on a width that shows the map beside the panel: there, "Select
  /// seats" is a fair instruction rather than a full-width button saying no.
  final VoidCallback? onFindBestSeats;

  /// Overrides [SeatLayerPickerStyles.primaryButtonStyle] for this button.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final options = SeatLayerPickerScope.optionsOf(context);
    final theme = seatLayerMapChromeThemeOf(context);
    // The same gate the tray's own card is under: a door into an empty room is
    // worse than none.
    final canOfferFind = onFindBestSeats != null &&
        options.enableBestAvailable &&
        !options.readOnly;
    return SeatLayerCheckoutCta(
      label: (context) =>
          SeatLayerPickerScope.stringsOf(context).holdAndCheckout,
      // The count is what tells the resolver a hold has already been created,
      // so the button can offer the till rather than offering to hold seats
      // that are already held.
      ticketCount: controller.confirmedTicketCount,
      canOfferFind: canOfferFind,
      onPressed: () => checkoutThroughHost(controller, onCheckout),
      builder: (context, cta, onPressed) => FilledButton(
        // The shape merges LAST so `primaryButtonStyle` — or this instance's
        // own `style:` — can still reshape the button.
        style: FilledButton.styleFrom(
          backgroundColor: theme.accent,
          foregroundColor: theme.onAccent,
          // A reason stated on a button that cannot be pressed still has to be
          // read, on the dark scene sheet as much as on the light one;
          // Material's own disabled greys vanish there.
          disabledBackgroundColor: pickerAlpha(theme.text, .08),
          disabledForegroundColor: pickerAlpha(theme.text, .55),
          minimumSize: Size.fromHeight(theme.layout.checkoutButtonHeight),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
            fontFamily: theme.fontFamily,
          ),
        )
            .merge(style ?? theme.styles.resolvedContinueButtonStyle)
            .merge(seatLayerButtonShape(theme.buttonRadius)),
        onPressed: cta.findsBestSeats ? onFindBestSeats : onPressed,
        child: SeatLayerCheckoutCtaLabel(cta: cta, color: theme.onAccent),
      ),
    );
  }
}

/// Create the hold, hand it over, and give it back if the host refuses it.
///
/// A host callback that throws has not taken the tickets, so leaving the hold
/// standing would strand real inventory until its TTL lapsed.
Future<void> checkoutThroughHost(
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
      // Rejection is best effort; the host's failure is the one that matters.
    }
    controller.reportActionError(error);
    Error.throwWithStackTrace(error, stack);
  }
}

/// [value], never above [ceiling].
///
/// The sheet's ceilings are a fraction of the screen AND a fixed height: the
/// fraction keeps a small phone usable, the fixed height stops a large one
/// from handing most of itself to a cart.
double _atMost(double value, double ceiling) =>
    value < ceiling ? value : ceiling;

/// The one cue that is not an answer to a touch: the hold has a minute left.
///
/// Draws nothing. It lives in the sheet because the sheet is the one piece of
/// phone chrome that is always mounted, and it fires on the same instant the
/// header's countdown turns from a fact into a warning — one event, felt and
/// seen at once.
///
/// A hold that is ALREADY inside its last minute the first time the picker
/// sees it — a resumed session, a buyer coming back from checkout — never
/// fires: nothing just happened, and a buzz on open teaches a buyer that the
/// buzz means nothing.
class SeatLayerHoldEndingCue extends StatefulWidget {
  /// Creates the hold-ending cue.
  const SeatLayerHoldEndingCue({super.key});

  @override
  State<SeatLayerHoldEndingCue> createState() => _SeatLayerHoldEndingCueState();
}

class _SeatLayerHoldEndingCueState extends State<SeatLayerHoldEndingCue> {
  Timer? _timer;

  /// The expiry the armed timer belongs to, so an extended hold rearms and an
  /// unchanged one does not.
  double? _armedFor;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _arm(SeatLayerPickerState state) {
    final expiry = state.hold?.expiresAt;
    if (expiry == _armedFor) return;
    _armedFor = expiry;
    _timer?.cancel();
    _timer = null;
    if (expiry == null) return;
    final lead = state.holdRemaining(seatLayerPickerNow()) -
        SeatLayerPickerHoldCountdown.expiring;
    if (lead <= Duration.zero) return;
    _timer = Timer(lead, () {
      if (!mounted) return;
      SeatLayerPickerScope.controllerOf(context)
          .emitHaptic(PickerHapticCue.holdEnding);
    });
  }

  @override
  Widget build(BuildContext context) {
    _arm(SeatLayerPickerScope.stateOf(context));
    return const SizedBox.shrink();
  }
}
