/// What the checkout call to action says, and whether it can be pressed.
///
/// The picker draws that one button in three places — the collapsed cart's
/// `Continue · €190` pill, the expanded sheet's book button and the wide
/// layout's checkout bar — and all three used to do the same thing when the
/// cart could not be handed over: go grey, keep their label, and say nothing
/// about why. A grey button that still reads "Hold seats & checkout" tells the
/// buyer only that pressing it achieved nothing; it does not tell them a
/// confirm card is open behind their thumb, that two more seats are needed, or
/// that the hold is already on its way.
///
/// [seatLayerCheckoutCtaState] is the single rule the three share, in the same
/// precedence the web picker resolves, so they cannot disagree with each other
/// or with the web. [SeatLayerCheckoutCta] wraps it with the one fact the
/// picker state cannot supply — whether this button's own handoff is still
/// running inside the host.
library;

import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_strings.dart';
import 'seat_layer_picker_scope.dart';

/// What the collapsed peek bar draws instead of a button.
///
/// The peek line and the footer button are two readings of one situation, so
/// they are resolved together by [seatLayerCheckoutCtaState] rather than by two
/// rule sets that could disagree. Where the footer says why it cannot be
/// pressed, the collapsed bar says what is happening: a bar fifty points tall
/// has no room for a disabled button AND a sentence, so whenever a sentence is
/// owed the pill is not drawn at all.
@immutable
class SeatLayerPeekLine {
  /// Creates one resolved peek line.
  const SeatLayerPeekLine({
    this.summary,
    this.sentence,
    this.pillLabel,
    this.total,
    this.showClock = false,
    this.offerFind = false,
  });

  /// The leading summary — `3 tickets`, `From €25` — or null when [sentence]
  /// has taken the whole line.
  final String? summary;

  /// A whole-line statement that replaces the pill: seats being secured,
  /// seats secured, sales closed.
  final String? sentence;

  /// The words on the pill — `Continue`, `Secure more` — or null for no pill.
  final String? pillLabel;

  /// The money that follows [pillLabel] on the pill, or null when this
  /// session hides prices.
  final String? total;

  /// Whether the live `m:ss` of a running hold follows the total.
  final bool showClock;

  /// Whether the empty bar offers its way into the best-seats form.
  final bool offerFind;
}

/// One resolved reading of the checkout call to action.
@immutable
class SeatLayerCheckoutCtaState {
  /// Creates a resolved call-to-action reading.
  ///
  /// [peekStatesReason] defaults to [statesReason]: a reason worth stating on
  /// the footer is normally worth stating on the pill too.
  const SeatLayerCheckoutCtaState({
    required this.label,
    required this.enabled,
    required this.busy,
    required this.statesReason,
    bool? peekStatesReason,
    this.peekLine = const SeatLayerPeekLine(),
  }) : peekStatesReason = peekStatesReason ?? statesReason;

  /// The words on the button.
  final String label;

  /// Whether the buyer may press it.
  final bool enabled;

  /// Whether the button should carry a spinner beside [label].
  ///
  /// Only ever true while something the buyer already asked for is in flight —
  /// the hold being created, or the host's checkout opening.
  final bool busy;

  /// Whether [label] is a reason the button cannot be pressed, rather than the
  /// caller's own label.
  ///
  /// The collapsed peek pill reads this: its own label carries the money
  /// (`Continue · €190`), and a reason and a price together would wrap on a
  /// 44 pt pill, so it drops the money whenever a reason is being stated.
  final bool statesReason;

  /// Whether the collapsed pill is the surface that should state [label].
  ///
  /// Almost always the same as [statesReason]. It parts from it for the one
  /// situation the buyer is already looking at: a seat's confirm card, which
  /// stands over the map with the whole sheet dimmed and inert behind it. The
  /// web picker leaves its pill reading `Continue · €190` there, because the
  /// card itself is the reason and the sheet under it is plainly out of play;
  /// swapping the pill for a sentence rewrote a line the buyer could not
  /// reach anyway, and it flickered back on the way out.
  final bool peekStatesReason;

  /// The same situation as the collapsed cart sheet renders it.
  ///
  /// Empty on every call that did not supply the peek's own facts, so a
  /// surface that only draws a button pays nothing for it.
  final SeatLayerPeekLine peekLine;
}

/// Resolve the checkout call to action for [state].
///
/// [label] is the caller's own wording for the ordinary case — the pill's
/// `Continue · €190`, the sheet footer's "Hold seats & checkout", the wide
/// bar's "Continue" — and is returned unchanged whenever nothing is in the
/// buyer's way. [canCheckout] is the controller's composite permission, which
/// already accounts for the session being ready, not busy, not read-only and
/// holding at least one ticket. [seatCardOpen] is whether a seat's confirm
/// card is still unanswered, and [handoffInFlight] whether the host's own
/// checkout callback is still running; both are passed in rather than read
/// here so this function stays pure and testable on its own.
///
/// The order is the web picker's, and it matters: sales closing outranks an
/// open prompt, an open prompt outranks the hold that a press behind it would
/// create, and a selection the event's rules reject is only worth mentioning
/// once nothing is in flight.
SeatLayerCheckoutCtaState seatLayerCheckoutCtaState({
  required SeatLayerPickerState state,
  required SeatLayerPickerStrings strings,
  required String label,
  required bool canCheckout,
  required bool seatCardOpen,
  bool handoffInFlight = false,
  int? ticketCount,
  int pendingCount = 0,
  String? totalText,
  String? fromPriceText,
  bool showPrices = true,
  bool canOfferFind = false,
}) {
  final count = ticketCount ?? 0;
  final holdActive = state.hold != null;
  final peek = _peekLine(
    state: state,
    strings: strings,
    count: count,
    pendingCount: pendingCount,
    totalText: totalText,
    fromPriceText: fromPriceText,
    showPrices: showPrices,
    canOfferFind: canOfferFind,
    holdActive: holdActive,
    handoffInFlight: handoffInFlight,
  );

  // `onPeek: false` leaves the collapsed pill saying what it was saying; see
  // [SeatLayerCheckoutCtaState.peekStatesReason].
  SeatLayerCheckoutCtaState reason(
    String words, {
    bool busy = false,
    bool onPeek = true,
  }) =>
      SeatLayerCheckoutCtaState(
        label: words,
        enabled: false,
        busy: busy,
        statesReason: true,
        peekStatesReason: onPeek,
        peekLine: peek,
      );

  // 1. Nothing else is worth saying about an event that has stopped selling.
  if (state.event?.salesClosed == true) return reason(strings.salesClosedCta);

  // 2. A prompt the buyer has not answered. The places under it are already in
  //    the runtime's selection, so without this the button reads as live.
  if (state.generalAdmissionCandidate != null) {
    return reason(strings.confirmYourTickets);
  }
  // The footer says why it is down; the pill behind the card does not, because
  // the card IS the answer to it and the sheet is dimmed and inert underneath.
  if (seatCardOpen) {
    return reason(strings.confirmOrCancelSeat, onPeek: false);
  }

  // 3. and 4. Work the buyer has already asked for. The hold comes first
  //    because the handoff cannot exist until it succeeds — which is also why
  //    the remaining in-flight window is exactly the host's own callback, and
  //    the button stays down through it: a second press buys nothing and
  //    reads as a failure.
  if (state.busyAction == SeatLayerPickerBusyAction.creatingHold) {
    return reason(strings.securingSeats, busy: true);
  }
  if (handoffInFlight) return reason(strings.openingCheckout, busy: true);

  // 5. A selection the event's own rules reject. Say what would fix it where
  //    the runtime gave a number to say it with, and fall back to the general
  //    sentence where it did not: `required` is 0 for a rule about the SHAPE
  //    of a selection rather than its size (a seat left stranded, a row broken
  //    up), and "Remove 1 ticket" would be a wrong instruction there.
  final validity = state.snapshot?.selectionValidity;
  if (validity != null && !validity.isValid) {
    if (validity.remaining > 0) {
      return reason(strings.chooseMore(validity.remaining));
    }
    if (validity.required > 0 && validity.count > validity.required) {
      return reason(strings.removeTickets(validity.count - validity.required));
    }
    return reason(strings.adjustSelection);
  }

  // 6. A hold that already exists changes what the button is offering: the
  //    seats are secured, so it offers the till — or offers to take the seats
  //    picked since into the same hold first.
  if (ticketCount != null && holdActive) {
    return SeatLayerCheckoutCtaState(
      label: pendingCount > 0
          ? strings.secureMoreAndCheckout(pendingCount)
          : strings.continueToCheckout,
      enabled: canCheckout,
      busy: false,
      statesReason: false,
      peekLine: peek,
    );
  }

  // 7. An empty cart. Not a reason the button failed — there is simply
  //    nothing in it yet — but it is still the one thing left to do.
  if (ticketCount != null && count == 0) {
    return SeatLayerCheckoutCtaState(
      label: strings.selectSeats,
      enabled: false,
      busy: false,
      statesReason: true,
      peekLine: peek,
    );
  }

  // 8. Nothing in the way: the caller's own label, live if there is anything
  //    to check out with.
  return SeatLayerCheckoutCtaState(
    label: label,
    enabled: canCheckout,
    busy: false,
    statesReason: false,
    peekLine: peek,
  );
}

/// The collapsed bar's reading of the same situation.
///
/// Follows the web picker's own table in the same order, which is NOT the
/// footer's: work already in flight outranks an event that has stopped
/// selling, because a buyer whose hold is landing is being told about their
/// own press rather than about the event.
SeatLayerPeekLine _peekLine({
  required SeatLayerPickerState state,
  required SeatLayerPickerStrings strings,
  required int count,
  required int pendingCount,
  required String? totalText,
  required String? fromPriceText,
  required bool showPrices,
  required bool canOfferFind,
  required bool holdActive,
  required bool handoffInFlight,
}) {
  if (count > 0) {
    if (state.busyAction == SeatLayerPickerBusyAction.creatingHold) {
      return SeatLayerPeekLine(sentence: strings.securingSeats);
    }
    if (handoffInFlight) {
      return SeatLayerPeekLine(
        sentence: showPrices && totalText != null
            ? strings.peekSecured(count, totalText)
            : strings.seatsSecuredOpeningCheckout,
      );
    }
    return SeatLayerPeekLine(
      summary: strings.ticketCount(count),
      pillLabel: holdActive && pendingCount > 0
          ? strings.secureMore
          : strings.continueWord,
      total: showPrices ? totalText : null,
      showClock: holdActive,
    );
  }
  if (state.event?.salesClosed == true) {
    return SeatLayerPeekLine(sentence: strings.salesClosedPill);
  }
  return SeatLayerPeekLine(
    summary: fromPriceText == null
        ? strings.pickYourSeats
        : strings.fromPrice(fromPriceText),
    offerFind: canOfferFind,
  );
}

/// The checkout call to action, resolved and wired, in whatever shape the
/// caller draws it.
///
/// Owns one fact and nothing else: whether the handoff this button started is
/// still running inside the host. The picker state cannot answer that —
/// `checkoutHandoff` is set the moment the hold exists and stays set until the
/// host refuses it, so it outlives the moment the buyer is waiting through —
/// and the button that started the work is the honest owner of it.
class SeatLayerCheckoutCta extends StatefulWidget {
  /// Creates a wired checkout call to action.
  const SeatLayerCheckoutCta({
    super.key,
    required this.label,
    required this.onPressed,
    required this.builder,
    this.ticketCount,
    this.pendingCount = 0,
    this.totalText,
    this.fromPriceText,
    this.showPrices = true,
    this.canOfferFind = false,
  });

  /// How many tickets the buyer has agreed to, when the caller knows.
  ///
  /// Supplying it turns on the two readings that depend on the size of the
  /// cart — the hold's own wording, and an empty cart's — and builds the
  /// [SeatLayerCheckoutCtaState.peekLine]. A caller that leaves it null gets
  /// exactly the resolution it got before there was a peek line.
  final int? ticketCount;

  /// How many of those tickets are not yet inside the hold.
  ///
  /// Zero unless the session can tell a held seat from a freshly picked one.
  final int pendingCount;

  /// The cart's total, already rendered as money.
  final String? totalText;

  /// The cheapest ticket on the chart, already rendered as money.
  final String? fromPriceText;

  /// Whether this session shows prices at all.
  final bool showPrices;

  /// Whether the empty peek line may offer the best-seats form.
  final bool canOfferFind;

  /// The caller's own wording for the ordinary case, resolved against the
  /// current context because it may carry money.
  final String Function(BuildContext context) label;

  /// The work a press starts — creating the hold and handing it to the host.
  final Future<void> Function() onPressed;

  /// Draws the button. Receives the resolved reading and the press handler,
  /// which is null whenever the button may not be pressed.
  final Widget Function(
    BuildContext context,
    SeatLayerCheckoutCtaState cta,
    VoidCallback? onPressed,
  ) builder;

  @override
  State<SeatLayerCheckoutCta> createState() => _SeatLayerCheckoutCtaState();
}

class _SeatLayerCheckoutCtaState extends State<SeatLayerCheckoutCta> {
  bool _handingOff = false;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final cta = seatLayerCheckoutCtaState(
      state: controller.state,
      strings: SeatLayerPickerScope.stringsOf(context),
      label: widget.label(context),
      canCheckout: controller.canCheckout,
      seatCardOpen: controller.seatAwaitingConfirmation != null,
      handoffInFlight: _handingOff,
      ticketCount: widget.ticketCount,
      pendingCount: widget.pendingCount,
      totalText: widget.totalText,
      fromPriceText: widget.fromPriceText,
      showPrices: widget.showPrices,
      canOfferFind: widget.canOfferFind,
    );
    return widget.builder(context, cta, cta.enabled ? _press : null);
  }

  void _press() {
    if (_handingOff) return;
    setState(() => _handingOff = true);
    ignorePickerAction(
      widget.onPressed().whenComplete(() {
        if (mounted) setState(() => _handingOff = false);
      }),
    );
  }
}

/// The label, with a spinner beside it while the picker is working.
///
/// Shared so the three buttons narrate a hold the same way. The spinner takes
/// the button's own foreground colour, and the label ellipsizes rather than
/// wrapping: a reason is longer than "Continue", and a call to action that
/// grows a second line moves everything under it.
class SeatLayerCheckoutCtaLabel extends StatelessWidget {
  /// Creates the label for a resolved call to action.
  const SeatLayerCheckoutCtaLabel({super.key, required this.cta, this.color});

  /// The resolved reading being drawn.
  final SeatLayerCheckoutCtaState cta;

  /// The spinner's colour; defaults to the surrounding icon theme.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Deliberately not `Flexible`: two of the three buttons are laid out with
    // an unbounded width, where a flexible child cannot be measured at all.
    // A one-line label ellipsizes wherever it IS bounded and sizes to its
    // words wherever it is not, which is what each of the three wants.
    final text = Text(
      cta.label,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
    if (!cta.busy) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
        const SizedBox(width: 8),
        text,
      ],
    );
  }
}
