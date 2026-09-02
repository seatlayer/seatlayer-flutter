import 'package:flutter/material.dart';

import 'picker_best_seats.dart';
import 'picker_cart_list.dart';
import 'picker_hold_lapse.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
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
    final options = SeatLayerPickerScope.optionsOf(context);
    final bottomInset =
        reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final hasTickets = controller.confirmedCartLines.isNotEmpty;
    final maxSheet =
        MediaQuery.sizeOf(context).height * layout.sheetMaxHeightFraction;
    final maxBody = (maxSheet - layout.peekHeight - bottomInset).clamp(
      0.0,
      maxSheet,
    );

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
              hasTickets: hasTickets,
              onExpandedChanged: onExpandedChanged,
              onCheckout: onCheckout,
              showBestSeatsShortcut: hasTickets &&
                  options.enableBestAvailable &&
                  !options.readOnly,
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
                      constraints: BoxConstraints(
                        maxHeight: hasTickets
                            ? maxBody
                            : layout.emptyTrayMaxHeight.clamp(0.0, maxBody),
                      ),
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

class _PeekRow extends StatelessWidget {
  const _PeekRow({
    required this.expanded,
    required this.hasTickets,
    required this.onExpandedChanged,
    required this.onCheckout,
    required this.showBestSeatsShortcut,
    required this.continueStyle,
  });

  final bool expanded;
  final bool hasTickets;
  final ValueChanged<bool> onExpandedChanged;
  final SeatLayerCheckoutCallback onCheckout;
  final bool showBestSeatsShortcut;
  final ButtonStyle? continueStyle;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final currency = state.snapshot?.currency ?? 'USD';
    // What the buyer has AGREED to. A tapped seat is in the runtime's
    // selection — and so in the cart, the count and the total — from the
    // moment it is tapped, but a confirm card standing over the map is still
    // asking whether they want it. Counting it here showed `1 ticket · €40`
    // under a card the buyer had not answered.
    final ticketCount = controller.confirmedTicketCount;
    final total = controller.confirmedCartTotal;
    final cheapest = _cheapest(state);

    final label = hasTickets
        // The money is on the call to action either way — `Continue · €285`
        // collapsed, the checkout bar expanded — and it is a thumb away from
        // here in both. Saying it here too is the same number twice on one
        // screen, which reads as two amounts until the buyer checks.
        ? strings.ticketCount(ticketCount)
        : cheapest == null
            ? strings.chooseTickets
            : strings.fromPrice(pickerCompactMoney(cheapest, currency));

    // The empty bar's own way in. `From €42` states a price and offers nothing
    // to do about it, and the form that would is behind a sheet the buyer has
    // no reason to suspect. The pill is withheld wherever the form would be
    // refused anyway — closed sales, best-available turned off, a read-only
    // session — and once a hold exists, because seats are already reserved.
    final options = SeatLayerPickerScope.optionsOf(context);
    final offerFindSeats = !expanded &&
        !hasTickets &&
        options.enableBestAvailable &&
        !options.readOnly &&
        state.event?.salesClosed != true &&
        state.hold == null;

    // The grabber at the top of the row is a promise that the sheet can be
    // pulled, so the row keeps it: a swipe up opens the sheet and a swipe
    // down closes it, the way every native sheet on the platform moves.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity <= -_dragOpenVelocity && !expanded) {
          onExpandedChanged(true);
        } else if (velocity >= _dragOpenVelocity && expanded) {
          onExpandedChanged(false);
        }
      },
      child: InkWell(
        onTap: () => onExpandedChanged(!expanded),
        child: SizedBox(
          height: theme.layout.peekHeight,
          child: Stack(
            children: [
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: pickerAlpha(theme.mutedText, .5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const SizedBox(width: 32, height: 3),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 6, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                      ),
                      if (expanded && showBestSeatsShortcut)
                        IconButton(
                          tooltip: strings.bestSeats,
                          visualDensity: VisualDensity.compact,
                          color: theme.accent,
                          onPressed: () => _openBestSeats(context),
                          icon:
                              const Icon(Icons.auto_awesome_rounded, size: 18),
                        ),
                      if (!expanded && hasTickets) ...[
                        FilledButton(
                          // The shape merges LAST: `merge` fills this style's
                          // null fields, so a slot or an instance style that
                          // sets its own shape still wins.
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.accent,
                            foregroundColor: theme.onAccent,
                            // A full-size target: this is the one
                            // control the buyer came for, and it was
                            // reaching thirty-four points inside a bar
                            // the thumb reads as a button of its own.
                            minimumSize: const Size(
                              0,
                              SeatLayerSizeTokens.minimumHitTarget,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              fontFamily: theme.fontFamily,
                            ),
                          )
                              .merge(
                                continueStyle ??
                                    theme.styles.resolvedContinueButtonStyle,
                              )
                              .merge(
                                seatLayerButtonShape(theme.buttonRadius),
                              ),
                          onPressed: controller.canCheckout
                              ? () => ignorePickerAction(
                                    checkoutThroughHost(controller, onCheckout),
                                  )
                              : null,
                          child: Text(
                            strings.continueWithTotal(
                              pickerMoney(context, total, currency),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (offerFindSeats) ...[
                        _FindSeatsPill(
                            onPressed: () => onExpandedChanged(true)),
                        const SizedBox(width: 8),
                      ],
                      AnimatedRotation(
                        duration: SeatLayerPickerMotion.of(
                          context,
                          SeatLayerPickerMotion.sheet,
                        ),
                        turns: expanded ? .5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: theme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// How fast a vertical swipe on the peek row must be to count, in px/s.
  static const double _dragOpenVelocity = 250;

  static double? _cheapest(SeatLayerPickerState state) {
    final prices = <double>[
      for (final category in state.categories)
        if (!category.notForSale) category.priceMin,
    ];
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  /// Open the best-available form as a modal, still inside the picker.
  ///
  /// The builder of a pushed route runs under the Navigator overlay, which is
  /// an ancestor of the scope rather than a descendant, so the form's own
  /// scope lookups would assert. The scope is re-provided into the route, and
  /// the picker's surface and palette travel with it rather than the host's.
  Future<void> _openBestSeats(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final body = SeatLayerPickerScope.inherit(
      context,
      Builder(
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: SeatLayerBestSeatsForm(
              onFound: (_) => Navigator.of(sheetContext).pop(),
            ),
          ),
        ),
      ),
    );
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      builder: (_) => body,
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

  /// Height of the drawn pill, inside its larger target.
  static const double inkHeight = 36;

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
              height: inkHeight,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: ShapeDecoration(
                color: theme.accent,
                shape: const StadiumBorder(),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
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
    final strings = SeatLayerPickerScope.stringsOf(context);
    final busy =
        controller.state.busyAction == SeatLayerPickerBusyAction.creatingHold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: FilledButton(
        // The shape merges LAST so `primaryButtonStyle` — or this instance's
        // own `style:` — can still reshape the button.
        style: FilledButton.styleFrom(
          backgroundColor: theme.accent,
          foregroundColor: theme.onAccent,
          minimumSize: const Size.fromHeight(46),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFamily: theme.fontFamily,
          ),
        )
            .merge(style ?? theme.styles.primaryButtonStyle)
            .merge(seatLayerButtonShape(theme.buttonRadius)),
        onPressed: controller.canCheckout
            ? () => ignorePickerAction(
                  checkoutThroughHost(controller, onCheckout),
                )
            : null,
        child: busy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(strings.holdAndCheckout),
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
