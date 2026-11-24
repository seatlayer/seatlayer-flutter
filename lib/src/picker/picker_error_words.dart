/// What a refused action says to the buyer, in the web picker's own sentences.
///
/// The machine code and the server's message stay with the host's `onError`.
/// Which sentence a code gets follows the web picker: the code decides where it
/// names its own sentence, and otherwise the action the buyer asked for does.
library;

import 'package:flutter/foundation.dart';

import '../json.dart';
import '../seat_layer_error.dart';
import 'picker_models.dart';
import 'picker_strings.dart';

/// The action a failure answered, as far as its sentence needs it.
class PickerActionFailure {
  const PickerActionFailure(this.command, {this.quantity, this.label});

  final String command;

  /// How many seats Best Available was asked for.
  final int? quantity;

  /// The cart line a removal named, as the buyer reads it.
  final String? label;
}

/// Remembers which action each failure answered: what a refusal says depends
/// on what the buyer asked for.
@internal
mixin PickerFailureLog on ValueNotifier<SeatLayerPickerState> {
  final Expando<PickerActionFailure> _failures =
      Expando<PickerActionFailure>('picker action failures');

  /// The state with [error], the answer to [command] with [payload].
  @internal
  SeatLayerPickerState failed(Object error, String command, [Object? payload]) {
    if (error is SeatLayerError) {
      final label = jStr(jGet(payload, 'label'));
      final line = value.cartLines
          .where((item) => label != null && item.label == label)
          .firstOrNull;
      _failures[error] = PickerActionFailure(
        command,
        quantity: jInt(jGet(payload, 'qty')),
        label: line?.buyerFacingLabel ?? label,
      );
    }
    return value.withActionError(error);
  }

  /// The action [error] answered, when it answered one.
  @internal
  PickerActionFailure? failureFor(SeatLayerError error) => _failures[error];
}

/// One buyer sentence, with the line under it where the picker has one.
typedef PickerErrorWords = ({String message, String? detail});

/// Commands that secure seats, where any refusal means the seats were not
/// secured.
const Set<String> _holdCommands = <String>{
  'hold',
  'picker.continue',
  'picker.holdGA',
  'picker.holdSelection',
  'picker.resumeHold',
  'picker.setTableQuantity',
};

/// Failures of the app, the page or the call itself rather than an answer to
/// the buyer. They have no buyer sentence.
const Set<String> _notAnAnswer = <String>{
  'bad_payload',
  'command_failed',
  'destroyed',
  'handoff_not_owned',
  'holdId_required',
  'idempotency_key_conflict',
  'idempotency_key_reused',
  'internal_error',
  'invalid_channel_scope',
  'invalid_expect_extends',
  'invalid_idempotency_key',
  'invalid_referral',
  'labels_and_holdId_required',
  'not_ready',
  'picker_error',
  'picker_requires_protocol_2',
  'read_only',
  'render_failed',
  'selections_required',
  'sl_decoding',
  'sl_handshake_timeout',
  'sl_incompatible',
  'sl_transport',
  'table_quantity_rejected',
  'unknown_error',
  'unsupported_command',
  'unsupported_state_contract',
};

/// What a web view calls a request that reached no server. Such a failure has
/// no code of its own: it arrives under the page's fallback code with only the
/// browser's message.
final RegExp _noConnection = RegExp(
  'failed to fetch|load failed|network ?error|network connection was lost|'
  'internet connection appears to be offline|could not connect to the server|'
  'request timed out|hostname could not be found',
  caseSensitive: false,
);

/// The buyer's sentence for [error], or null when there is none for it.
PickerErrorWords? pickerErrorWords(
  SeatLayerError error,
  SeatLayerPickerStrings strings, {
  PickerActionFailure? failure,
}) {
  PickerErrorWords line(String message, [String? detail]) =>
      (message: message, detail: detail);

  final payload = error is BridgeFailure ? error.payload : null;
  final details = payload?.details;
  final status = jInt(jGet(details, 'status'));
  final command = failure?.command;
  final code = error.code;
  // The page's fallback codes carry an HTTP status when the server did answer,
  // with nothing more to say about it.
  final answered = !_notAnAnswer.contains(code) ||
      (status != null && (code == 'command_failed' || code == 'picker_error'));

  switch (code) {
    case 'maintenance_mode':
      final notice = jStr(jGet(details, 'notice'))?.trim() ?? '';
      if (notice.isNotEmpty) return line(notice);
      final seconds = jDouble(jGet(details, 'retryAfterS'));
      if (seconds == null || seconds < 0) {
        return line(strings.maintenancePausedShortly);
      }
      final minutes = (seconds / 60).ceil();
      return line(strings.maintenancePaused(minutes < 1 ? 1 : minutes));
    case 'sl_timeout' || 'host_timeout':
      return line(strings.checkConnection);
    case 'rate_limited':
      return line(strings.tooManyAttempts);
    case 'guests_only':
      return line(strings.guestsOnly);
    case 'guest_choice_closed':
      return line(strings.guestChoiceClosed);
    case 'event_closed':
      return line(strings.salesClosedToast);
    case 'companion_pair_required':
      return line(strings.companionPairRequired);
    case 'ticket_option_not_applicable':
      return line(strings.ticketOptionNotApplicable);
    case 'cannot_extend':
      return line(strings.couldNotAddMoreTime);
    case 'channel_paused':
      return line(strings.accessPausedTitle, strings.accessPausedCopy);
    case 'buyer_access_revoked':
      return line(strings.accessRevokedTitle, strings.accessRevokedCopy);
    case 'buyer_access_invalid' ||
          'buyer_access_expired' ||
          'access_provider_timeout' ||
          'access_provider_closed' ||
          'provider_failed' ||
          'no_token':
      return line(strings.accessExpiredTitle, strings.accessExpiredCopy);
    case 'access_provider_unavailable':
      return line(strings.accessUnverifiedTitle, strings.accessUnverifiedCopy);
  }
  if (code.startsWith('buyer_access_') && code.endsWith('_mismatch')) {
    return line(strings.accessUnverifiedTitle, strings.accessUnverifiedCopy);
  }

  final message = payload?.message ?? '';
  if (status == null
      ? _noConnection.hasMatch(message)
      : status == 503 ||
          (status >= 500 && message.startsWith('request_failed'))) {
    return line(strings.checkConnection);
  }
  if (message.contains('seat sales are closed')) {
    return line(strings.salesClosedToast);
  }

  // A removal and more time have their own sentence for every refusal; what
  // else was asked for is refused for a reason the code names.
  if (command != 'picker.removeCartLine' && command != 'picker.extendHold') {
    switch (code) {
      case 'seat_held_for_renewal':
        return line(strings.seatHeldForRenewal);
      case 'channel_access_denied':
        return line(strings.accessUnverifiedCopy);
      case 'hold_not_active':
        return line(strings.holdExpired);
      case 'hold_not_found' || 'legacy_hold_requires_restart':
        return line(strings.savedSeatsNotRestored);
      case 'order_edit_in_progress' ||
            'event_not_found' ||
            'key_not_found' ||
            'key_revoked' ||
            'mode_mismatch' ||
            'org_mismatch' ||
            'credit_limit_reached':
        return line(strings.eventUnavailable);
      case 'forbidden' || 'not_found'
          when command == 'picker.bestAvailable' ||
              _holdCommands.contains(command):
        return line(strings.eventUnavailable);
    }
  }

  if (command == 'picker.bestAvailable') {
    if (!answered) return null;
    return line(switch (code) {
      'not_enough_together' when failure?.quantity != null =>
        strings.couldNotFindSeatsTogether(failure!.quantity!),
      'sold_out' => strings.ticketTypeSoldOut,
      _ => strings.seatsNoLongerAvailableTryAnother,
    });
  }
  if (command == 'picker.removeCartLine') {
    final label = failure?.label;
    if (label == null || !answered) return null;
    return line(
      strings.couldNotRemoveLabel(
        label.startsWith('__sl_ga__') ? strings.generalAdmission : label,
      ),
    );
  }
  if (command == 'picker.extendHold' && answered) {
    return line(strings.couldNotAddMoreTime);
  }

  // A standing place has no name of its own to lose, and its area may well
  // have more: only seats are named.
  final named = (error.conflicts ?? const [])
      .map((conflict) => conflict.label ?? '')
      .where((label) => label.isNotEmpty)
      .take(3)
      .where((label) => !label.startsWith('__sl_ga__'))
      .toList(growable: false);
  if (named.isNotEmpty) {
    return line(
      named.length == 1
          ? strings.labelNoLongerAvailable(named.single)
          : strings.labelsNoLongerAvailable(named.join(', ')),
    );
  }
  if (code == 'sold_out') return line(strings.ticketTypeSoldOut);
  if (code == 'not_for_sale') return line(strings.seatUnavailable);
  if (_takenCodes.contains(code) ||
      (answered && _holdCommands.contains(command))) {
    return line(strings.seatsJustTaken);
  }
  return null;
}

/// Refusals that are about the seats whichever action met them.
const Set<String> _takenCodes = <String>{
  'allocation_exhausted',
  'conflict',
  'hold_unavailable',
  'invalid_selection',
  'not_enough_together',
  'release_closed',
  'release_exhausted',
};
