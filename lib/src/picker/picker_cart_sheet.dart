import 'package:flutter/material.dart';

import 'picker_best_seats.dart';
import 'picker_cart_list.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
import 'picker_attribution.dart';
import 'picker_errors.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The buyer's cart, docked at the bottom of the phone.
///
/// Collapsed it is one 50-point line: what is in the cart, and the way on.
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

  /// The required SeatLayer attribution.
  final Widget attribution;

  /// Whether to reserve the device's bottom inset below the sheet.
  final bool reserveBottomInset;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final layout = theme.layout;
    final options = SeatLayerPickerScope.optionsOf(context);
    final bottomInset =
        reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final hasTickets = state.cartLines.isNotEmpty;
    final maxSheet =
        MediaQuery.sizeOf(context).height * layout.sheetMaxHeightFraction;
    final maxBody =
        (maxSheet - layout.peekHeight - bottomInset).clamp(0.0, maxSheet);

    return Material(
      color: theme.surface,
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PeekRow(
              expanded: expanded,
              hasTickets: hasTickets,
              onExpandedChanged: onExpandedChanged,
              onCheckout: onCheckout,
              showBestSeatsShortcut: hasTickets &&
                  options.enableBestAvailable &&
                  !options.readOnly,
            ),
            AnimatedSize(
              duration: SeatLayerPickerMotion.of(
                  context, SeatLayerPickerMotion.sheet),
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
  });

  final bool expanded;
  final bool hasTickets;
  final ValueChanged<bool> onExpandedChanged;
  final SeatLayerCheckoutCallback onCheckout;
  final bool showBestSeatsShortcut;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final currency = state.snapshot?.currency ?? 'USD';
    final ticketCount = state.snapshot?.ticketCount ?? state.cartLines.length;
    final total = state.snapshot?.cartTotal ??
        state.cartLines.fold<double>(0, (sum, line) => sum + line.total);
    final cheapest = _cheapest(state);

    final label = hasTickets
        ? expanded
            // Expanded, the total is on the call to action a thumb away; saying
            // it again here is the same number three times on one screen.
            ? strings.ticketCount(ticketCount)
            : '${strings.ticketCount(ticketCount)} · ${pickerMoney(context, total, currency)}'
        : cheapest == null
            ? strings.chooseTickets
            : strings.fromPrice(pickerCompactMoney(cheapest, currency));

    return InkWell(
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
                padding: const EdgeInsets.fromLTRB(14, 6, 4, 0),
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
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      ),
                    if (!expanded && hasTickets) ...[
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.accent,
                          foregroundColor: theme.onAccent,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          visualDensity: VisualDensity.compact,
                          textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFamily: theme.fontFamily,
                          ),
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
                      const SizedBox(width: 4),
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

  Future<void> _openBestSeats(BuildContext context) => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: SeatLayerBestSeatsForm(
              onFound: (_) => Navigator.of(sheetContext).pop(),
            ),
          ),
        ),
      );
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
          Center(child: attribution),
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
          Center(child: attribution),
        ],
      );
}

/// The one call to action that turns a cart into a hold.
///
/// Full width, and carrying nothing but its own label: the total is already on
/// the peek bar a thumb away, and stating it twice on one sheet is how the
/// footer ended up being read as a second, different price.
class SeatLayerBookButton extends StatelessWidget {
  /// Creates the checkout call to action.
  const SeatLayerBookButton({super.key, required this.onCheckout});

  /// Receives the hold once the runtime has created it.
  final SeatLayerCheckoutCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final busy =
        controller.state.busyAction == SeatLayerPickerBusyAction.creatingHold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: theme.accent,
          foregroundColor: theme.onAccent,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.radius - 2),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFamily: theme.fontFamily,
          ),
        ),
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
