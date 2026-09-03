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
/// Collapsed it is one short bar: what is in the cart, and the way on. The bar
/// is tall enough to carry a full-size touch target, because the way on is the
/// control the whole picker exists to reach.
/// Expanded it grows to the height of its own content and stops at three fifths
/// of the screen — never a fixed fraction, so one ticket does not open four
/// hundred points of empty white.
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

  /// Replaces the dense ticket list.
  final Widget? cartList;

  /// Replaces the best-available form shown while the cart is empty.
  final Widget? bestSeats;

  /// Replaces the footer call to action.
  final Widget? checkoutBar;

  /// Replaces the inline action error.
  final Widget? actionError;

  /// Overrides [SeatLayerPickerStyles.sheetStyle] for this sheet.
  final SeatLayerSurfaceStyle? style;

  /// Overrides [SeatLayerPickerStyles.continueButtonStyle] for this peek bar.
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
  /// The height of the sheet's BODY — everything below the head — in logical
  /// points. Unbounded because a drag is allowed past both ends: the value
  /// leaves `[0, top]` only while a finger is holding it there.
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

  /// What the body measured at, and the detents that follow from it.
  double _natural = 0;
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

  /// The body's measured height. Reported after layout, so acting on it here
  /// is safe.
  void _onNatural(double height) {
    if (!mounted || (height - _natural).abs() < PickerSheetDetents.epsilon) {
      return;
    }
    setState(() => _natural = height);
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
    // The collapsed bar is fifty points of type: at the platform's largest
    // settings that type no longer fits fifty points, so the bar grows with
    // it rather than clipping the total. Capped at the peek surface's own
    // clamp, so a cart bar can never eat the map.
    final peekScale = seatLayerTypeScaleOf(
      context,
      max: SeatLayerTypeScaleTokens.peek,
    );
    // The bar's buttons are 44 points tall in a 50-point head, and the
    // grabber is painted in that head's top four points, so at rest the way
    // on would cover the way up. While collapsed the head lifts its row by
    // `peekClockLift`, whatever the button carries — it was first added for
    // the pill that grows a clock, and the taller buttons need it just as much.
    final peekLift = controller.cartSheetExpanded
        ? 0.0
        : SeatLayerSizeTokens.peekClockLift * peekScale;
    final peekHeight = layout.peekHeight * peekScale + peekLift;
    final openHeadHeight = layout.sheetOpenHeadHeight * peekScale;
    final hasTickets = controller.confirmedCartLines.isNotEmpty;
    final salesClosed = controller.state.event?.salesClosed == true;
    // Two ceilings, both a fraction of the screen capped at a fixed height:
    // a tall phone must not give three quarters of itself to a cart, and a
    // short one must not be told that seventy-two per cent is enough.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheet = hasTickets
        ? _atMost(
            screenHeight * layout.sheetMaxHeightFraction, layout.sheetMaxHeight)
        : _atMost(screenHeight * layout.emptyTrayMaxHeightFraction,
            layout.emptyTrayMaxHeight);
    final maxBody = (maxSheet - openHeadHeight).clamp(0.0, maxSheet);
    // The one height the web has no equivalent for: how far a FINGER may pull
    // the sheet past the ceiling the picker itself would stop at. Offered only
    // when the cart is taller than the ceiling — see [PickerSheetDetents].
    final fullBody = (screenHeight * layout.sheetFullHeightFraction -
            openHeadHeight -
            bottomInset)
        .clamp(maxBody, screenHeight);
    _detents = PickerSheetDetents(
      content: _natural < maxBody ? _natural : maxBody,
      full: _natural,
    );
    _keepRestingHeight();

    final extent = _extent.value;
    // Below the peek bar the sheet has nowhere to grow, so an overdrag moves
    // the whole surface off the bottom edge instead — the finger keeps hold of
    // it, and the spring puts it back.
    final belowPeek = extent < 0 ? -extent : 0.0;
    final body = extent > 0 ? extent : 0.0;
    final open = body > 0;

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
        child: Material(
          color: surface.color ?? theme.surface,
          elevation: surface.elevation ?? 12,
          shape: surface.shape,
          child: Padding(
            padding: EdgeInsets.only(bottom: open ? bottomInset : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Above the peek row, so it is read whether the sheet is open
                // or shut: a buyer coming back from checkout is looking at a
                // compact strip, and news about their seats cannot live inside
                // a panel they would have to open first.
                const SeatLayerHoldLapseNotice(),
                const SeatLayerHoldEndingCue(),
                SeatLayerTypeScale.peek(
                  child: _PeekRow(
                    // The head answers to the FINGER, not to the last answer the
                    // host gave: a sheet being dragged open is open, whatever the
                    // controller has been told so far.
                    expanded: open,
                    // Fifty points shut, thirty-six open, and every height
                    // between while the sheet is on its way: the head compresses
                    // into its open form as the body appears from under it, so
                    // the content the buyer is pulling on tracks their finger
                    // exactly and the sheet's own edge never jumps.
                    height: peekHeight -
                        _atMost(
                          body,
                          peekHeight - openHeadHeight,
                        ),
                    lift: peekLift,
                    onExpandedChanged: _ask,
                    onCheckout: widget.onCheckout,
                    continueStyle: widget.continueButtonStyle,
                  ),
                ),
                // A window onto the body, never a resize of it. The body is
                // laid out once at the height its content wants — up to the
                // full detent, where its own list takes over the scrolling —
                // and the sheet reveals it from under the head. Resizing it
                // per frame instead would reflow a ticket list sixty times a
                // second, and the buyer would watch their own order rewrap
                // while they dragged.
                ClipRect(
                  child: SeatLayerTypeScale.sheet(
                    child: SizedBox(
                      height: body,
                      width: double.infinity,
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minHeight: 0,
                        maxHeight: fullBody,
                        // Offstage rather than absent while the sheet is shut: it
                        // is still laid out, so the sheet always knows how tall
                        // its cart is and opens straight to it, but it is not
                        // painted, not touchable and not read out.
                        child: Offstage(
                          offstage: !open,
                          child: PickerMeasuredHeight(
                            onHeight: _onNatural,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // An event that has stopped selling is a state
                                // the tray states in its own words, not a set of
                                // controls that quietly go grey. It stands above
                                // the body either way: a cart the buyer can no
                                // longer check out with needs the sentence as
                                // much as an empty one does.
                                if (salesClosed)
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                                    child:
                                        SeatLayerPickerSalesClosedStatement(),
                                  ),
                                Flexible(
                                  child: hasTickets
                                      ? _FilledBody(
                                          cartList: widget.cartList,
                                          checkoutBar: widget.checkoutBar,
                                          actionError: widget.actionError,
                                          attribution: widget.attribution,
                                          onCheckout: widget.onCheckout,
                                        )
                                      : _EmptyBody(
                                          bestSeats: widget.bestSeats,
                                          actionError: widget.actionError,
                                          attribution: widget.attribution,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!open && bottomInset > 0)
                  SizedBox(
                    height: bottomInset,
                    child: _TrailingAttribution(child: widget.attribution),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The tap and the chevron still speak in open/shut; the detent follows.
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

/// The head of the sheet: the one bar the buyer sees before they open it.
///
/// It says what is in the cart and offers the way on, and it is the grab
/// handle for the sheet as well — the whole row toggles, and a short drag in
/// either direction opens or closes it.
///
/// What it says is not decided here. [seatLayerCheckoutCtaState] resolves the
/// footer button and this line together, so the two can never disagree about
/// what is happening: where the footer states a reason it cannot be pressed,
/// this line states the same situation as a sentence and drops the pill.
class _PeekRow extends StatelessWidget {
  const _PeekRow({
    required this.expanded,
    required this.height,
    this.lift = 0,
    required this.onExpandedChanged,
    required this.onCheckout,
    required this.continueStyle,
  });

  final bool expanded;
  final double height;

  /// Extra room above the bar so a pill carrying the clock clears the grabber.
  final double lift;
  final ValueChanged<bool> onExpandedChanged;
  final SeatLayerCheckoutCallback onCheckout;
  final ButtonStyle? continueStyle;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final options = SeatLayerPickerScope.optionsOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final currency = state.snapshot?.currency ?? 'USD';
    // What the buyer has AGREED to. A tapped seat is in the runtime's
    // selection — and so in the cart, the count and the total — from the
    // moment it is tapped, but a confirm card standing over the map is still
    // asking whether they want it. Counting it here showed `1 ticket · €40`
    // under a card the buyer had not answered.
    final ticketCount = controller.confirmedTicketCount;
    final cheapest = _cheapest(state);

    // The empty bar's own way in. `From €25` states a price and offers nothing
    // to do about it, and the form that would is behind a sheet the buyer has
    // no reason to suspect. The pill is withheld wherever the form would be
    // refused anyway — closed sales, best-available turned off, a read-only
    // session — and once a hold exists, because seats are already reserved.
    final canOfferFind = !expanded &&
        options.enableBestAvailable &&
        !options.readOnly &&
        state.event?.salesClosed != true &&
        state.hold == null;

    return SeatLayerCheckoutCta(
      label: (context) => strings.continueWord,
      ticketCount: ticketCount,
      totalText: pickerMoney(context, controller.confirmedCartTotal, currency),
      fromPriceText:
          cheapest == null ? null : pickerCompactMoney(cheapest, currency),
      canOfferFind: canOfferFind,
      onPressed: () => checkoutThroughHost(controller, onCheckout),
      builder: (context, cta, onPressed) => _PeekHead(
        expanded: expanded,
        height: height,
        lift: lift,
        cta: cta,
        onExpandedChanged: onExpandedChanged,
        onContinue: onPressed,
        continueStyle: continueStyle,
      ),
    );
  }

  static double? _cheapest(SeatLayerPickerState state) {
    final prices = <double>[
      for (final category in state.categories)
        if (!category.notForSale) category.priceMin,
    ];
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }
}

/// The head as it is drawn, once the line has been resolved.
class _PeekHead extends StatefulWidget {
  const _PeekHead({
    required this.expanded,
    required this.height,
    this.lift = 0,
    required this.cta,
    required this.onExpandedChanged,
    required this.onContinue,
    required this.continueStyle,
  });

  final bool expanded;
  final double height;

  /// Extra room above the bar so a pill carrying the clock clears the grabber.
  final double lift;
  final SeatLayerCheckoutCtaState cta;
  final ValueChanged<bool> onExpandedChanged;
  final VoidCallback? onContinue;
  final ButtonStyle? continueStyle;

  @override
  State<_PeekHead> createState() => _PeekHeadState();
}

class _PeekHeadState extends State<_PeekHead> {
  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final layout = theme.layout;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final line = widget.cta.peekLine;
    final expanded = widget.expanded;

    // The head is the grab handle, but the DRAG belongs to the sheet: the
    // whole surface follows the finger, so a gesture that starts on the head
    // is the same gesture as one that starts on the list. What stays here is
    // the tap, which is the way the sheet opens without a gesture at all.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.onExpandedChanged(!expanded),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Not a row of its own: the grabber overlaps into the same head,
            // which is what keeps the collapsed bar at fifty points.
            Positioned(
              top: layout.sheetGrabberInset,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: .5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.mutedText,
                      borderRadius:
                          BorderRadius.circular(SeatLayerRadiusTokens.pill),
                    ),
                    child: SizedBox(
                      width: layout.sheetGrabberWidth,
                      height: layout.sheetGrabberHeight,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(left: 12, right: 6, top: widget.lift),
                child: Row(
                  children: [
                    Expanded(
                      child: _PeekSummary(
                        text: line.sentence ?? line.summary ?? '',
                        amount: line.sentence == null ? line.fromAmount : null,
                        expanded: expanded,
                      ),
                    ),
                    // Every reading that owes the buyer a sentence has already
                    // taken the whole line; a bar this short cannot carry a
                    // sentence and a button at once.
                    if (!expanded && line.pillLabel != null) ...[
                      const SizedBox(width: 10),
                      // A reason is several times the width of
                      // `Continue €285`, and this row also carries the ticket
                      // count and the sheet's chevron. Capping the pill — and
                      // not letting it stretch to the cap — leaves the count
                      // its own space on every phone width.
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: _ContinuePill(
                          cta: widget.cta,
                          onPressed: widget.onContinue,
                          style: widget.continueStyle,
                        ),
                      ),
                    ],
                    if (!expanded && line.offerFind) ...[
                      const SizedBox(width: 10),
                      _FindSeatsPill(
                        onPressed: () => widget.onExpandedChanged(true),
                      ),
                    ],
                    const SizedBox(width: 10),
                    _SheetToggle(
                      expanded: expanded,
                      label:
                          expanded ? strings.collapseCart : strings.expandCart,
                      onPressed: () => widget.onExpandedChanged(!expanded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The line's own words, and the one beat of movement they are allowed.
///
/// A count that changes while the sheet is shut is the only feedback the
/// buyer gets that a tap on the map reached the cart, so it swells once
/// rather than simply becoming a different number.
class _PeekSummary extends StatefulWidget {
  const _PeekSummary({
    required this.text,
    required this.amount,
    required this.expanded,
  });

  final String text;

  /// The money inside [text] on the empty bar, printed large; null on every
  /// other reading, where the line is one weight throughout.
  final String? amount;

  final bool expanded;

  @override
  State<_PeekSummary> createState() => _PeekSummaryState();
}

class _PeekSummaryState extends State<_PeekSummary>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.bump,
  );

  @override
  void didUpdateWidget(_PeekSummary old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text &&
        !widget.expanded &&
        !SeatLayerPickerMotion.reduced(context)) {
      _bump.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    // THE PRICE IS THE LOUD PART. On the empty bar the amount is the fact and
    // the word around it is the caption, so `From` stays small and muted and
    // the money is printed at the size the buyer actually reads the bar for.
    // Every other reading of the line — a ticket count, a whole sentence —
    // is one weight throughout.
    final amount = widget.expanded ? null : widget.amount;
    final base = TextStyle(
      color: amount == null ? theme.text : theme.mutedText,
      // design/tokens.json › type.peekSummary / type.peekSummaryOpen.
      fontSize: widget.expanded ? 14 : 12,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
      fontFamily: theme.fontFamily,
    );
    final text = amount == null || !widget.text.contains(amount)
        ? Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: base,
          )
        : Text.rich(
            _withAmount(context, widget.text, amount, theme, base),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    return Semantics(
      // The one line that says what the cart holds, and the only feedback a
      // buyer gets when a tap on the map reaches a shut sheet. It is announced
      // on change rather than on a timer: the sentence changes when the cart
      // does, and never otherwise, so the live region speaks exactly as often
      // as something happened.
      liveRegion: true,
      container: true,
      label: widget.text,
      child: ExcludeSemantics(
        child: _bumped(text),
      ),
    );
  }

  /// The words, with the one beat of movement a changed count earns.
  Widget _bumped(Widget text) {
    return AnimatedBuilder(
      animation: _bump,
      // Anchored on the leading edge, so the words grow out of the bar rather
      // than sliding across it.
      builder: (context, child) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Transform.scale(
          scale: 1 + (.15 * _bumpCurve(_bump.value)),
          alignment: AlignmentDirectional.centerStart,
          child: child,
        ),
      ),
      child: text,
    );
  }

  /// [line] with [amount] lifted out of it, in the order the locale wrote it.
  static InlineSpan _withAmount(
    BuildContext context,
    String line,
    String amount,
    SeatLayerResolvedPickerTheme theme,
    TextStyle base,
  ) {
    final at = line.indexOf(amount);
    return TextSpan(
      style: base,
      children: <InlineSpan>[
        if (at > 0) TextSpan(text: line.substring(0, at)),
        TextSpan(
          text: amount,
          style: TextStyle(
            color: theme.text,
            // design/tokens.json › type.peekFromPrice.
            fontSize: 19,
            fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        if (at + amount.length < line.length)
          TextSpan(text: line.substring(at + amount.length)),
      ],
    );
  }

  /// Out to the full swell at forty-five per cent, and back.
  static double _bumpCurve(double t) => t <= .45
      ? SeatLayerPickerMotion.easeEnter.transform(t / .45)
      : SeatLayerPickerMotion.easeEnter.transform((1 - t) / .55);
}

/// The way on, with the money on it.
class _ContinuePill extends StatelessWidget {
  const _ContinuePill({
    required this.cta,
    required this.onPressed,
    required this.style,
  });

  final SeatLayerCheckoutCtaState cta;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final line = cta.peekLine;
    // A reason and a price will not sit on one 44 pt pill without wrapping,
    // so where a reason is owed the money goes and the sentence stays. The
    // count is still on the left of this same row either way. Not every reason
    // the footer states is owed here — see
    // [SeatLayerCheckoutCtaState.peekStatesReason].
    final statesReason = cta.peekStatesReason;
    return FilledButton(
      // The shape merges LAST: `merge` fills this style's null fields, so a
      // slot or an instance style that sets its own shape still wins.
      style: FilledButton.styleFrom(
        backgroundColor: theme.accent,
        foregroundColor: theme.onAccent,
        // A reason stated on a button that cannot be pressed still has to be
        // read, on the dark scene sheet as much as on the light one;
        // Material's own disabled greys vanish there.
        disabledBackgroundColor: pickerAlpha(theme.text, .08),
        disabledForegroundColor: pickerAlpha(theme.text, .55),
        // A full-size target: this is the one control the buyer came for, and
        // it was reaching thirty-four points inside a bar the thumb reads as
        // a button of its own.
        minimumSize: const Size(0, SeatLayerSizeTokens.minimumHitTarget),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // A ROUNDED RECTANGLE, not a lozenge (design/tokens.json ›
        // type.peekPill, radius.peekButton). The one door out of the bar
        // should look like the primary action it is.
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
          fontFamily: theme.fontFamily,
        ),
      )
          .merge(style ?? theme.styles.resolvedContinueButtonStyle)
          .merge(seatLayerButtonShape(SeatLayerRadiusTokens.peekButton)),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              statesReason ? cta.label : line.pillLabel!,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!statesReason && line.total != null) ...[
            const SizedBox(width: 6),
            Text(
              line.total!,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
          // The clock is the quietest thing on the pill: the buyer is being
          // reminded that the seats are theirs for now, not being hurried.
          if (!statesReason && line.showClock) ...[
            const SizedBox(width: 6),
            const _PeekClock(),
          ],
        ],
      ),
    );
  }
}

/// The remaining hold time, counted down in place on the pill.
class _PeekClock extends StatefulWidget {
  const _PeekClock();

  @override
  State<_PeekClock> createState() => _PeekClockState();
}

class _PeekClockState extends State<_PeekClock> {
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
    final strings = SeatLayerPickerScope.stringsOf(context);
    // The picker keeps one clock, on the header's countdown: two clocks
    // would disagree with each other mid-second, and the goldens would never
    // settle on a picture.
    // ignore: invalid_use_of_visible_for_testing_member
    final now = SeatLayerPickerHoldCountdown.debugClock();
    final remaining = state.holdRemaining(now);
    final minutes = remaining.inMinutes.remainder(60).toString();
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Opacity(
      opacity: .72,
      child: Text(
        strings.heldFor('$minutes:$seconds'),
        maxLines: 1,
        softWrap: false,
        // The same throttle the header pill uses: `m:ss` is not a sentence,
        // and a clock read once a second is a clock nobody can listen past.
        semanticsLabel: remaining <= SeatLayerPickerHoldCountdown.expiring
            ? strings.holdSecondsLeft(remaining.inSeconds)
            : strings.holdMinutesLeft((remaining.inSeconds + 59) ~/ 60),
        style: TextStyle(
          fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// The chevron that opens and shuts the sheet.
///
/// Full size while the sheet is shut, where it is one of two things on the
/// bar; a smaller mark inside the same target once the sheet is open, where
/// the sheet itself is the obvious thing to press.
class _SheetToggle extends StatelessWidget {
  const _SheetToggle({
    required this.expanded,
    required this.label,
    required this.onPressed,
  });

  final bool expanded;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final layout = theme.layout;
    final ink = expanded ? layout.sheetToggleOpenSize : layout.sheetToggleSize;
    return Semantics(
      button: true,
      expanded: expanded,
      label: label,
      child: SizedBox.square(
        dimension: layout.sheetToggleSize,
        child: Center(
          child: SizedBox.square(
            dimension: ink,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: AnimatedRotation(
                duration: SeatLayerPickerMotion.of(
                  context,
                  SeatLayerPickerMotion.chevron,
                ),
                curve: SeatLayerPickerMotion.easeEnter,
                turns: expanded ? .5 : 0,
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 21,
                  color: theme.mutedText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The empty peek bar's shortcut into the best-seats form.
///
/// Smaller than `Continue`, because it is an offer rather than the way on: the
/// ink is thirty-six points and the target around it is a full forty-four, so
/// the bar reads as one line and still answers a thumb.
class _FindSeatsPill extends StatelessWidget {
  const _FindSeatsPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Semantics(
      button: true,
      label: strings.findSeats,
      child: SizedBox(
        height: SeatLayerSizeTokens.minimumHitTarget,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Container(
              height: seatLayerScaledExtent(
                context,
                theme.layout.findPillHeight,
                max: SeatLayerTypeScaleTokens.peek,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              // A ROUNDED RECTANGLE at the full 44 (design/tokens.json ›
              // size.findPillHeight, radius.peekButton, type.findPill). The
              // small lozenge read as an aside; on an empty bar this is the
              // one thing there is to press. The word stays `Find seats` —
              // nothing is selected yet and the tap opens the best-available
              // form, so the button says what the tap does.
              decoration: ShapeDecoration(
                color: theme.accent,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SeatLayerRadiusTokens.peekButton),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: theme.onAccent,
                  ),
                  const SizedBox(width: 6),
                  ExcludeSemantics(
                    child: Text(
                      strings.findSeats,
                      style: TextStyle(
                        color: theme.onAccent,
                        fontSize: 14,
                        fontWeight:
                            seatLayerBoldWeight(context, FontWeight.w800),
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.bestSeats,
    required this.actionError,
    required this.attribution,
  });

  final Widget? bestSeats;
  final Widget? actionError;
  final Widget attribution;

  @override
  Widget build(BuildContext context) {
    final strings = SeatLayerPickerScope.stringsOf(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The hint is read out, never drawn. On a screen showing a seat map
          // and a form for finding seats, a sentence explaining that you may
          // tap a seat or use the form is the tray's tallest element saying
          // the least.
          Semantics(
            label: strings.emptyTrayHint,
            child: const SizedBox.shrink(),
          ),
          bestSeats ?? const SeatLayerBestSeatsForm(),
          actionError ?? const SeatLayerPickerActionError(),
          _TrailingAttribution(child: attribution),
        ],
      ),
    );
  }
}

class _FilledBody extends StatelessWidget {
  const _FilledBody({
    required this.cartList,
    required this.checkoutBar,
    required this.actionError,
    required this.attribution,
    required this.onCheckout,
  });

  final Widget? cartList;
  final Widget? checkoutBar;
  final Widget? actionError;
  final Widget attribution;
  final SeatLayerCheckoutCallback onCheckout;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: cartList ?? const SeatLayerCartList(),
            ),
          ),
          actionError ?? const SeatLayerPickerActionError(),
          checkoutBar ?? SeatLayerBookButton(onCheckout: onCheckout),
          _TrailingAttribution(child: attribution),
        ],
      );
}

class _TrailingAttribution extends StatelessWidget {
  const _TrailingAttribution({required this.child});

  final Widget child;

  // Centred, not trailing: at the foot of a phone the trailing edge is the
  // display's rounded corner, and a credit tucked into it lost its last
  // letters behind the glass. The middle of the strip is the one place every
  // phone shows whole.
  @override
  Widget build(BuildContext context) => Center(child: child);
}

/// The one call to action that turns a cart into a hold.
///
/// Full width, and carrying nothing but its own label: the total is already on
/// the peek bar a thumb away, and stating it twice on one sheet is how the
/// footer ended up being read as a second, different price.
///
/// When it cannot be pressed it says why — see [seatLayerCheckoutCtaState],
/// which the collapsed pill and the wide layout's checkout bar resolve too.
class SeatLayerBookButton extends StatelessWidget {
  /// Creates the checkout call to action.
  const SeatLayerBookButton({super.key, required this.onCheckout, this.style});

  /// Receives the hold once the runtime has created it.
  final SeatLayerCheckoutCallback onCheckout;

  /// Overrides [SeatLayerPickerStyles.primaryButtonStyle] for this button.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final theme = seatLayerMapChromeThemeOf(context);
    // The foot's own inset. Nothing below the button but the by-line, which
    // carries its own six points of air.
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: SeatLayerCheckoutCta(
        label: (context) =>
            SeatLayerPickerScope.stringsOf(context).holdAndCheckout,
        // The count is what tells the resolver a hold has already been
        // created, so the button can offer the till rather than offering to
        // hold seats that are already held.
        ticketCount: controller.confirmedTicketCount,
        onPressed: () => checkoutThroughHost(controller, onCheckout),
        builder: (context, cta, onPressed) => FilledButton(
          // The shape merges LAST so `primaryButtonStyle` — or this instance's
          // own `style:` — can still reshape the button.
          style: FilledButton.styleFrom(
            backgroundColor: theme.accent,
            foregroundColor: theme.onAccent,
            // A reason stated on a button that cannot be pressed still has to be
            // read, on the dark scene sheet as much as on the light one; Material's
            // own disabled greys vanish there.
            disabledBackgroundColor: pickerAlpha(theme.text, .08),
            disabledForegroundColor: pickerAlpha(theme.text, .55),
            minimumSize: Size.fromHeight(theme.layout.checkoutButtonHeight),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
              fontFamily: theme.fontFamily,
            ),
          )
              .merge(style ?? theme.styles.primaryButtonStyle)
              .merge(seatLayerButtonShape(theme.buttonRadius)),
          onPressed: onPressed,
          child: SeatLayerCheckoutCtaLabel(cta: cta, color: theme.onAccent),
        ),
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
