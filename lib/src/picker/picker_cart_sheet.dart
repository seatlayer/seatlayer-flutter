import 'dart:async';
import 'package:flutter/material.dart';

import 'picker_best_seats.dart';
import 'picker_cart_list.dart';
import 'picker_checkout_cta.dart';
import 'picker_header.dart';
import 'picker_hold_lapse.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
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
class SeatLayerCartSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    // The sheet caps the same surface the header and the legend do, so it
    // takes the same palette: white chrome docked under a dark venue scene
    // reads as a mistake, and the three were disagreeing in 3D.
    final theme = seatLayerMapChromeThemeOf(context);
    final layout = theme.layout;
    final bottomInset =
        reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final hasTickets = controller.confirmedCartLines.isNotEmpty;
    final salesClosed = controller.state.event?.salesClosed == true;
    // Two ceilings, both a fraction of the screen capped at a fixed height:
    // a tall phone must not give three quarters of itself to a cart, and a
    // short one must not be told that seventy-two per cent is enough.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheet = hasTickets
        ? _atMost(screenHeight * layout.sheetMaxHeightFraction,
            layout.sheetMaxHeight)
        : _atMost(screenHeight * layout.emptyTrayMaxHeightFraction,
            layout.emptyTrayMaxHeight);
    final maxBody =
        (maxSheet - layout.sheetOpenHeadHeight).clamp(0.0, maxSheet);

    final surface =
        (theme.styles.sheetStyle ?? const SeatLayerSurfaceStyle()).merge(style);
    return Material(
      color: surface.color ?? theme.surface,
      elevation: surface.elevation ?? 12,
      shape: surface.shape,
      child: Padding(
        padding: EdgeInsets.only(bottom: expanded ? bottomInset : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Above the peek row, so it is read whether the sheet is open or
            // shut: a buyer coming back from checkout is looking at a compact
            // strip, and news about their seats cannot live inside a
            // panel they would have to open first.
            const SeatLayerHoldLapseNotice(),
            _PeekRow(
              expanded: expanded,
              onExpandedChanged: onExpandedChanged,
              onCheckout: onCheckout,
              continueStyle: continueButtonStyle,
            ),
            AnimatedSize(
              duration: SeatLayerPickerMotion.of(
                context,
                SeatLayerPickerMotion.sheet,
              ),
              curve: SeatLayerPickerMotion.easeEnter,
              alignment: Alignment.topCenter,
              child: !expanded
                  ? const SizedBox(width: double.infinity)
                  : ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxBody),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // An event that has stopped selling is a state the
                          // tray states in its own words, not a set of
                          // controls that quietly go grey. It stands above the
                          // body either way: a cart the buyer can no longer
                          // check out with needs the sentence as much as an
                          // empty one does.
                          if (salesClosed)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                              child: SeatLayerPickerSalesClosedStatement(),
                            ),
                          Flexible(
                            child: hasTickets
                                ? _FilledBody(
                                    cartList: cartList,
                                    checkoutBar: checkoutBar,
                                    actionError: actionError,
                                    attribution: attribution,
                                    onCheckout: onCheckout,
                                  )
                                : _EmptyBody(
                                    bestSeats: bestSeats,
                                    actionError: actionError,
                                    attribution: attribution,
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!expanded && bottomInset > 0)
              SizedBox(
                height: bottomInset,
                child: _TrailingAttribution(child: attribution),
              ),
          ],
        ),
      ),
    );
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
    required this.onExpandedChanged,
    required this.onCheckout,
    required this.continueStyle,
  });

  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final SeatLayerCheckoutCallback onCheckout;
  final ButtonStyle? continueStyle;

  /// How far a drag has to travel before it counts as opening or closing.
  static const double _dragThreshold = 18;

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
        cta: cta,
        onExpandedChanged: onExpandedChanged,
        onContinue: onPressed,
        continueStyle: continueStyle,
        dragThreshold: _dragThreshold,
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
    required this.cta,
    required this.onExpandedChanged,
    required this.onContinue,
    required this.continueStyle,
    required this.dragThreshold,
  });

  final bool expanded;
  final SeatLayerCheckoutCtaState cta;
  final ValueChanged<bool> onExpandedChanged;
  final VoidCallback? onContinue;
  final ButtonStyle? continueStyle;
  final double dragThreshold;

  @override
  State<_PeekHead> createState() => _PeekHeadState();
}

class _PeekHeadState extends State<_PeekHead> {
  /// How far the current drag has travelled, and whether it has already
  /// spent itself. A drag answers once: a buyer who keeps moving after the
  /// sheet has opened is not asking for it to close again.
  double _dragged = 0;
  bool _dragSpent = false;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final layout = theme.layout;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final line = widget.cta.peekLine;
    final expanded = widget.expanded;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) {
        _dragged = 0;
        _dragSpent = false;
      },
      onVerticalDragUpdate: (details) {
        if (_dragSpent) return;
        _dragged += details.delta.dy;
        if (_dragged <= -widget.dragThreshold) {
          _dragSpent = true;
          if (!expanded) widget.onExpandedChanged(true);
        } else if (_dragged >= widget.dragThreshold) {
          _dragSpent = true;
          if (expanded) widget.onExpandedChanged(false);
        }
      },
      onTap: () => widget.onExpandedChanged(!expanded),
      child: SizedBox(
        height: expanded ? layout.sheetOpenHeadHeight : layout.peekHeight,
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
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _PeekSummary(
                        text: line.sentence ?? line.summary ?? '',
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
                      label: expanded
                          ? strings.collapseCart
                          : strings.expandCart,
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
  const _PeekSummary({required this.text, required this.expanded});

  final String text;
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
    final text = Text(
      widget.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: theme.text,
        fontSize: widget.expanded ? 14 : 12.5,
        fontWeight: FontWeight.w700,
        fontFamily: theme.fontFamily,
      ),
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          fontFamily: theme.fontFamily,
        ),
      )
          .merge(style ?? theme.styles.resolvedContinueButtonStyle)
          .merge(seatLayerButtonShape(SeatLayerRadiusTokens.pill)),
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
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Opacity(
      opacity: .72,
      child: Text(
        strings.heldFor('$minutes:$seconds'),
        maxLines: 1,
        softWrap: false,
        semanticsLabel:
            '${remaining.inMinutes} minutes $seconds seconds remaining',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
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
              height: theme.layout.findPillHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: ShapeDecoration(
                color: theme.accent,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 12,
                    color: theme.onAccent,
                  ),
                  const SizedBox(width: 5),
                  ExcludeSemantics(
                    child: Text(
                      strings.findSeats,
                      style: TextStyle(
                        color: theme.onAccent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
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
              fontWeight: FontWeight.w800,
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
