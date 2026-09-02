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
}) {
  final raw = pickerSnapshot();
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
}
