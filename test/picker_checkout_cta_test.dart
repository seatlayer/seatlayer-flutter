// The checkout call to action says why it cannot be pressed.
//
// Three widgets draw that button — the collapsed peek pill, the sheet footer
// and the wide layout's checkout bar — and before this they all did the same
// unhelpful thing when the cart could not be handed over: went grey and kept
// their label. These tests pin the ONE rule they now share, and above all its
// precedence: two reasons are true at once far more often than not, and the
// buyer must be told the one they can act on first.
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_checkout_cta.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import 'picker_test_fixture.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();

/// A ready picker state built from the shared snapshot fixture.
///
/// [validity] replaces `selection.validity`, and [salesClosed] flips the one
/// event flag; everything else is the fixture's own one-seat cart.
SeatLayerPickerState _state({
  bool salesClosed = false,
  Map<String, Object?>? validity,
  SeatLayerPickerBusyAction busy = SeatLayerPickerBusyAction.none,
  GAArea? generalAdmissionCandidate,
  bool holdActive = false,
}) {
  final raw = pickerSnapshot(holdOwner: holdActive ? 'picker' : null);
  final event = Map<String, Object?>.from(raw['event']! as Map<String, Object?>)
    ..['salesClosed'] = salesClosed;
  final selection = Map<String, Object?>.from(
    raw['selection']! as Map<String, Object?>,
  );
  if (validity != null) selection['validity'] = validity;
  final snapshot = SeatLayerPickerSnapshot.fromJson(<String, Object?>{
    ...raw,
    'event': event,
    'selection': selection,
  })!;
  var state = const SeatLayerPickerState.initializing().applying(snapshot);
  if (generalAdmissionCandidate != null) {
    state = state.withGeneralAdmissionCandidate(generalAdmissionCandidate);
  }
  if (busy != SeatLayerPickerBusyAction.none) state = state.withBusy(busy);
  return state;
}

SeatLayerCheckoutCtaState _cta(
  SeatLayerPickerState state, {
  bool canCheckout = true,
  bool seatCardOpen = false,
  bool handoffInFlight = false,
}) =>
    seatLayerCheckoutCtaState(
      state: state,
      strings: _strings,
      label: 'Continue · €25',
      canCheckout: canCheckout,
      seatCardOpen: seatCardOpen,
      handoffInFlight: handoffInFlight,
    );

Map<String, Object?> _validity({
  required bool isValid,
  required int count,
  required int required,
  required int remaining,
}) =>
    <String, Object?>{
      'isValid': isValid,
      'count': count,
      'required': required,
      'remaining': remaining,
    };

void main() {
  test('nothing in the way: the caller keeps its own label, live', () {
    final cta = _cta(_state());
    expect(cta.label, 'Continue · €25');
    expect(cta.enabled, isTrue);
    expect(cta.busy, isFalse);
    expect(cta.statesReason, isFalse);
  });

  test('an empty cart keeps the label and loses the press', () {
    // `canCheckout` is the controller's composite: ready, not busy, not
    // read-only, and something in the cart. With nothing in it there is no
    // reason to state — the buyer has not done anything wrong yet.
    final cta = _cta(_state(), canCheckout: false);
    expect(cta.label, 'Continue · €25');
    expect(cta.enabled, isFalse);
    expect(cta.statesReason, isFalse);
  });

  test('sales closed says so', () {
    final cta = _cta(_state(salesClosed: true));
    expect(cta.label, 'Sales closed');
    expect(cta.enabled, isFalse);
    expect(cta.busy, isFalse);
    expect(cta.statesReason, isTrue);
  });

  test('an open seat card says what to do about it', () {
    final cta = _cta(_state(), seatCardOpen: true);
    expect(cta.label, 'Confirm or cancel this seat');
    expect(cta.enabled, isFalse);
    expect(cta.statesReason, isTrue);
  });

  test('a quantity prompt asks for tickets, not for a seat', () {
    final state = _state(
      generalAdmissionCandidate: const GAArea(
        id: 'ga-1',
        label: 'Standing',
        capacity: 100,
        available: 100,
      ),
    );
    expect(_cta(state).label, 'Confirm your tickets');
    // Even with a seat card open underneath, the prompt in front wins.
    expect(_cta(state, seatCardOpen: true).label, 'Confirm your tickets');
  });

  test('creating the hold narrates itself, with a spinner', () {
    final cta = _cta(_state(busy: SeatLayerPickerBusyAction.creatingHold));
    expect(cta.label, 'Securing your seats…');
    expect(cta.busy, isTrue);
    expect(cta.enabled, isFalse);
  });

  test('the host opening its checkout narrates itself too', () {
    final cta = _cta(_state(), handoffInFlight: true);
    expect(cta.label, 'Opening secure checkout…');
    expect(cta.busy, isTrue);
    expect(cta.enabled, isFalse);
  });

  test('a selection short of the required count asks for the difference', () {
    final cta = _cta(
      _state(
        validity: _validity(
          isValid: false,
          count: 1,
          required: 3,
          remaining: 2,
        ),
      ),
      canCheckout: false,
    );
    expect(cta.label, 'Choose 2 more');
    expect(cta.enabled, isFalse);
    expect(cta.statesReason, isTrue);
  });

  test(
      'a selection over the cap asks for the tickets to give up, not the '
      'ones to keep', () {
    final cta = _cta(
      _state(
        validity: _validity(
          isValid: false,
          count: 5,
          required: 2,
          remaining: 0,
        ),
      ),
      canCheckout: false,
    );
    expect(cta.label, 'Remove 3 tickets');
  });

  test('one ticket over the cap is one ticket, singular', () {
    final cta = _cta(
      _state(
        validity: _validity(
          isValid: false,
          count: 3,
          required: 2,
          remaining: 0,
        ),
      ),
      canCheckout: false,
    );
    expect(cta.label, 'Remove 1 ticket');
  });

  test('a rule about the SHAPE of a selection asks for no number', () {
    // `required` is 0 for an orphan-seat or consecutive-seats violation. The
    // count is still above it, and "Remove 1 ticket" would be a wrong
    // instruction — removing one is exactly what leaves the orphan.
    final cta = _cta(
      _state(
        validity: _validity(
          isValid: false,
          count: 1,
          required: 0,
          remaining: 0,
        ),
      ),
      canCheckout: false,
    );
    expect(cta.label, 'Adjust your selection');
    expect(cta.statesReason, isTrue);
  });

  group('precedence', () {
    test('closed sales outrank every other reason', () {
      final cta = _cta(
        _state(
          salesClosed: true,
          busy: SeatLayerPickerBusyAction.creatingHold,
          validity: _validity(
            isValid: false,
            count: 1,
            required: 3,
            remaining: 2,
          ),
        ),
        canCheckout: false,
        seatCardOpen: true,
        handoffInFlight: true,
      );
      expect(cta.label, 'Sales closed');
      expect(cta.busy, isFalse);
    });

    test('an unanswered prompt outranks the hold a press would create', () {
      final cta = _cta(
        _state(busy: SeatLayerPickerBusyAction.creatingHold),
        canCheckout: false,
        seatCardOpen: true,
        handoffInFlight: true,
      );
      expect(cta.label, 'Confirm or cancel this seat');
    });

    test('the hold outranks the handoff it has to precede', () {
      final cta = _cta(
        _state(busy: SeatLayerPickerBusyAction.creatingHold),
        canCheckout: false,
        handoffInFlight: true,
      );
      expect(cta.label, 'Securing your seats…');
    });

    test('work in flight outranks an invalid selection', () {
      final cta = _cta(
        _state(
          busy: SeatLayerPickerBusyAction.creatingHold,
          validity: _validity(
            isValid: false,
            count: 1,
            required: 3,
            remaining: 2,
          ),
        ),
        canCheckout: false,
      );
      expect(cta.label, 'Securing your seats…');
    });

    test('a valid selection never states a reason', () {
      final cta = _cta(
        _state(
          validity: _validity(
            isValid: true,
            count: 1,
            required: 0,
            remaining: 0,
          ),
        ),
      );
      expect(cta.statesReason, isFalse);
      expect(cta.enabled, isTrue);
    });
  });

  group('the peek line', () {
    // The collapsed bar and the footer button are two readings of one
    // situation. These pin the readings that differ — a bar fifty points tall
    // cannot carry a disabled button AND a sentence, so wherever the footer
    // states a reason the bar states the whole line instead.
    SeatLayerPeekLine peek(
      SeatLayerPickerState state, {
      int ticketCount = 1,
      String? totalText = '€25',
      String? fromPriceText,
      bool canOfferFind = false,
      bool handoffInFlight = false,
      bool showPrices = true,
    }) =>
        seatLayerCheckoutCtaState(
          state: state,
          strings: _strings,
          label: 'Continue',
          canCheckout: true,
          seatCardOpen: false,
          handoffInFlight: handoffInFlight,
          ticketCount: ticketCount,
          totalText: totalText,
          fromPriceText: fromPriceText,
          showPrices: showPrices,
          canOfferFind: canOfferFind,
        ).peekLine;

    test('a cart states its count, and the money rides the pill', () {
      final line = peek(_state());
      expect(line.summary, '1 ticket');
      expect(line.pillLabel, 'Continue');
      expect(line.total, '€25');
      expect(line.sentence, isNull);
    });

    test('an empty bar quotes the cheapest ticket and offers the finder', () {
      final line = peek(
        _state(),
        ticketCount: 0,
        fromPriceText: '€25',
        canOfferFind: true,
      );
      expect(line.summary, 'From €25');
      expect(line.pillLabel, isNull);
      expect(line.offerFind, isTrue);
    });

    test('an empty bar with no price still names the one thing to do', () {
      final line = peek(_state(), ticketCount: 0);
      expect(line.summary, 'Pick your seats');
      expect(line.offerFind, isFalse);
    });

    test('closed sales take the whole line, and there is no pill', () {
      final line = peek(_state(salesClosed: true), ticketCount: 0);
      expect(line.sentence, 'Sales are closed');
      expect(line.summary, isNull);
      expect(line.pillLabel, isNull);
    });

    test('a hold being created replaces the pill with the news', () {
      final line = peek(_state(busy: SeatLayerPickerBusyAction.creatingHold));
      expect(line.sentence, 'Securing your seats…');
      expect(line.pillLabel, isNull);
    });

    test('a secured cart says the money is safe before checkout appears', () {
      final line = peek(_state(), handoffInFlight: true);
      expect(
        line.sentence,
        "✓ 1 secured · €25 — you won't be charged yet",
      );
    });

    test('a session that hides prices says it without one', () {
      final line = peek(_state(), handoffInFlight: true, showPrices: false);
      expect(line.sentence, 'Seats secured. Opening checkout…');
    });

    test('the footer says what a hold changes about the button', () {
      // Not the peek line, but resolved by the same call: once a hold exists
      // the footer is offering the till rather than offering to hold again.
      final held = seatLayerCheckoutCtaState(
        state: _state(holdActive: true),
        strings: _strings,
        label: 'Hold seats & checkout',
        canCheckout: true,
        seatCardOpen: false,
        ticketCount: 1,
      );
      expect(held.label, 'Continue to checkout');
      expect(held.enabled, isTrue);
      expect(held.peekLine.showClock, isTrue);
    });

    test('an empty cart is the one thing left to do, and cannot be pressed',
        () {
      final empty = seatLayerCheckoutCtaState(
        state: _state(),
        strings: _strings,
        label: 'Hold seats & checkout',
        canCheckout: false,
        seatCardOpen: false,
        ticketCount: 0,
      );
      expect(empty.label, 'Select seats');
      expect(empty.enabled, isFalse);
    });
  });
}
