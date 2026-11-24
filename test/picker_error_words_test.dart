// The inline error: what a refused action says to the buyer after the map has
// loaded. The machine code and the server's message stay with the host.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_error_words.dart';
import 'package:seatlayer/src/picker/picker_strings_locales.g.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _english = SeatLayerPickerStrings();

SeatLayerError _refused(
  String code, {
  String? message,
  int? status = 409,
  Map<String, Object?> details = const <String, Object?>{},
}) =>
    SeatLayerError.bridge(
      BridgeErrorPayload(
        code: code,
        message: message ?? code,
        details: <String, Object?>{
          if (status != null) 'status': status,
          ...details,
        },
      ),
    );

String? _said(
  SeatLayerError error, {
  String command = 'picker.holdSelection',
  int? quantity,
  String? label,
  SeatLayerPickerStrings strings = _english,
}) =>
    pickerErrorWords(
      error,
      strings,
      failure: PickerActionFailure(command, quantity: quantity, label: label),
    )?.message;

void main() {
  group('a refused hold', () {
    test('says the seats were taken, and names one or several', () {
      expect(_said(_refused('conflict')), _english.seatsJustTaken);
      expect(
        _said(_refused('conflict', details: <String, Object?>{
          'conflicts': <Object?>[
            <String, Object?>{'label': 'A-12'},
          ],
        })),
        'A-12 is no longer available. Choose another seat.',
      );
      expect(
        _said(_refused('conflict', details: <String, Object?>{
          'conflicts': <Object?>[
            <String, Object?>{'label': 'A-12'},
            <String, Object?>{'label': 'A-13'},
          ],
        })),
        'A-12, A-13 are no longer available. Choose another group.',
      );
      // A standing place has no name of its own.
      expect(
        _said(_refused('conflict', details: <String, Object?>{
          'conflicts': <Object?>[
            <String, Object?>{'label': '__sl_ga__floor__3'},
          ],
        })),
        _english.seatsJustTaken,
      );
    });

    test('any other answer is the same general line', () {
      for (final code in <String>[
        'hold_unavailable',
        'invalid_selection',
        'release_exhausted',
        'seat_held_for_renewal',
        'not_for_sale',
        'hold_quantity_exceeded',
        'rate_limited',
        'hold_not_found',
        'a_code_from_next_year',
      ]) {
        expect(_said(_refused(code)), _english.seatsJustTaken, reason: code);
      }
      expect(_said(_refused('command_failed', status: 404)),
          _english.seatsJustTaken);
    });

    test('a code with a sentence of its own uses it', () {
      expect(_said(_refused('event_closed')), _english.salesClosedToast);
      expect(
        _said(_refused('command_failed',
            status: null, message: 'seatlayer: seat sales are closed')),
        _english.salesClosedToast,
      );
      expect(_said(_refused('guests_only', status: 403)),
          'This event is for invited guests.');
      expect(_said(_refused('guest_choice_closed')),
          'Seat choice isn’t open right now.');
      expect(_said(_refused('companion_pair_required')),
          'Select the adjacent wheelchair place with each companion ticket.');
      expect(_said(_refused('ticket_option_not_applicable')),
          'That ticket choice is not available for the selected seat.');
    });
  });

  test('no answer from the server asks to check the connection', () {
    for (final message in <String>[
      'Failed to fetch', // Android
      'Load failed', // iOS
      'The Internet connection appears to be offline.',
    ]) {
      expect(
        _said(_refused('command_failed', status: null, message: message)),
        _english.checkConnection,
        reason: message,
      );
    }
    expect(
      _said(_refused('command_failed',
          status: 502, message: 'request_failed_502')),
      _english.checkConnection,
    );
    expect(_said(_refused('temporarily_unavailable', status: 503)),
        _english.checkConnection);
    expect(
      _said(const SeatLayerError.timeout(
          'picker.holdSelection', Duration(seconds: 30))),
      _english.checkConnection,
    );
  });

  test('a maintenance pause says how long', () {
    SeatLayerError paused(Map<String, Object?> details) =>
        _refused('maintenance_mode', status: 503, details: details);
    expect(_said(paused(<String, Object?>{})),
        _english.maintenancePausedShortly);
    expect(
      _said(paused(<String, Object?>{'retryAfterS': 30})),
      'Booking is paused for maintenance. Please try again in about 1 minute.',
    );
    expect(
      _said(paused(<String, Object?>{'retryAfterS': 301})),
      'Booking is paused for maintenance. Please try again in about 6 minutes.',
    );
    expect(
      _said(paused(<String, Object?>{'notice': ' Back at 14:00. '})),
      'Back at 14:00.',
    );
  });

  test('Best Available has its own sentences', () {
    String? said(String code) => _said(
          _refused(code),
          command: 'picker.bestAvailable',
          quantity: 4,
        );
    expect(
      said('not_enough_together'),
      'We couldn’t find 4 seats together. Try fewer seats or another ticket '
      'type.',
    );
    expect(said('sold_out'),
        'That ticket type is sold out. Try another ticket type.');
    expect(said('conflict'), _english.seatsNoLongerAvailableTryAnother);
    expect(said('event_closed'), _english.salesClosedToast);
  });

  test('a removal names the line, and an extension the time', () {
    expect(
      _said(_refused('cart_line_release_failed', status: null),
          command: 'picker.removeCartLine', label: 'A-12'),
      'Couldn’t remove A-12. Your hold is unchanged.',
    );
    expect(
      _said(_refused('cart_line_release_failed', status: null),
          command: 'picker.removeCartLine', label: '__sl_ga__floor__1'),
      'Couldn’t remove General admission. Your hold is unchanged.',
    );
    expect(_said(_refused('cannot_extend'), command: 'picker.extendHold'),
        _english.couldNotAddMoreTime);
  });

  test('access refusals are the access panel’s words', () {
    for (final (code, title, copy) in <(String, String, String)>[
      ('channel_paused', _english.accessPausedTitle, _english.accessPausedCopy),
      (
        'buyer_access_revoked',
        _english.accessRevokedTitle,
        _english.accessRevokedCopy
      ),
      (
        'buyer_access_expired',
        _english.accessExpiredTitle,
        _english.accessExpiredCopy
      ),
      (
        'buyer_access_origin_mismatch',
        _english.accessUnverifiedTitle,
        _english.accessUnverifiedCopy
      ),
    ]) {
      final words = pickerErrorWords(_refused(code, status: 403), _english);
      expect(words?.message, title, reason: code);
      expect(words?.detail, copy, reason: code);
    }
  });

  test('a failure of the app or the page has no buyer sentence', () {
    for (final code in <String>[
      'bad_payload',
      'not_ready',
      'handoff_not_owned',
      'idempotency_key_conflict',
      'selections_required',
      'table_quantity_rejected',
    ]) {
      expect(_said(_refused(code, status: null)), isNull, reason: code);
    }
    expect(_said(const SeatLayerError.readOnly('hold')), isNull);
    expect(_said(const SeatLayerError.decoding('x')), isNull);
  });

  test('every language says each sentence in its own words', () {
    final table = (jsonDecode(
      File('design/locale_strings.json').readAsStringSync(),
    ) as Map<String, Object?>)['strings']! as Map<String, Object?>;
    final english = table['en']! as Map<String, Object?>;
    expect(table, hasLength(43));
    for (final MapEntry(key: tag, value: raw) in table.entries) {
      final entry = raw! as Map<String, Object?>;
      for (final key in <String>[
        'checkConnection',
        'salesClosedToast',
        'seatsJustTaken',
        'labelNoLongerAvailable',
        'labelsNoLongerAvailable',
        'couldNotFindSeatsTogether',
        'ticketTypeSoldOut',
        'seatsNoLongerAvailableTryAnother',
        'companionPairRequired',
        'ticketOptionNotApplicable',
        'couldNotRemoveLabel',
        'couldNotAddMoreTime',
        'maintenancePaused.other',
        'maintenancePausedShortly',
        'guestsOnly',
        'guestChoiceClosed',
      ]) {
        expect(entry[key], isA<String>(), reason: '$key in $tag');
        if (tag != 'en') {
          expect(entry[key], isNot(english[key]), reason: '$key in $tag');
        }
      }
      final strings = seatLayerPickerStringsByLocale[tag]!;
      for (final sentence in <String>[
        strings.labelNoLongerAvailable('A-12'),
        strings.labelsNoLongerAvailable('A-12'),
        strings.couldNotRemoveLabel('A-12'),
      ]) {
        expect(sentence, contains('A-12'), reason: tag);
        expect(sentence, isNot(contains('{')), reason: tag);
      }
      for (final sentence in <String>[
        strings.couldNotFindSeatsTogether(4),
        strings.maintenancePaused(5),
      ]) {
        expect(sentence, isNot(contains('{')), reason: tag);
      }
    }
  });

  testWidgets('the bar draws the sentence; the host keeps the error',
      (tester) async {
    const error = SeatLayerError.bridge(
      BridgeErrorPayload(
        code: 'conflict',
        message: 'conflict',
        details: <String, Object?>{'status': 409},
      ),
    );
    final map = FakePickerMap(
      handler: (command, payload) async => throw error,
    );
    addTearDown(map.dispose);
    final picker = SeatLayerPickerController(mapController: map);
    addTearDown(picker.dispose);
    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerActionError(),
        controller: picker,
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pump();
    await expectLater(picker.holdSelection(), throwsA(error));
    await tester.pump();
    expect(find.text(_english.seatsJustTaken), findsOneWidget);
    expect(find.textContaining('conflict'), findsNothing);
    expect(find.textContaining('SeatLayer'), findsNothing);
    expect(picker.state.error, same(error));

    // Best Available's refusal of the same code says what it was about.
    await expectLater(
      picker.bestAvailable(quantity: 2),
      throwsA(isA<SeatLayerError>()),
    );
    await tester.pump();
    expect(
      find.text(_english.seatsNoLongerAvailableTryAnother),
      findsOneWidget,
    );
  });
}
