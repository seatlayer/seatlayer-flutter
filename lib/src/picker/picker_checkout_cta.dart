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

/// One resolved reading of the checkout call to action.
@immutable
class SeatLayerCheckoutCtaState {
  /// Creates a resolved call-to-action reading.
  const SeatLayerCheckoutCtaState({
    required this.label,
    required this.enabled,
    required this.busy,
    required this.statesReason,
  });

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
}) {
  SeatLayerCheckoutCtaState reason(String words, {bool busy = false}) =>
      SeatLayerCheckoutCtaState(
        label: words,
        enabled: false,
        busy: busy,
        statesReason: true,
      );

  // 1. Nothing else is worth saying about an event that has stopped selling.
  if (state.event?.salesClosed == true) return reason(strings.salesClosedCta);

  // 2. A prompt the buyer has not answered. The places under it are already in
  //    the runtime's selection, so without this the button reads as live.
  if (state.generalAdmissionCandidate != null) {
    return reason(strings.confirmYourTickets);
  }
  if (seatCardOpen) return reason(strings.confirmOrCancelSeat);

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

  // 6. Nothing in the way: the caller's own label, live if there is anything
  //    to check out with.
  return SeatLayerCheckoutCtaState(
    label: label,
    enabled: canCheckout,
    busy: false,
    statesReason: false,
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
  });

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
