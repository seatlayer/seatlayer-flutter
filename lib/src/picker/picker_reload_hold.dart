/// The hold a page that takes another's place is asked to take up again.
library;

import 'dart:async';

import '../json.dart';
import '../seat_layer_error.dart';

/// Asks a new page for the hold the one before it had.
///
/// The hold may be gone by then, which is why it is not put in the page's
/// start, where it would fail the page.
final class PickerReloadHold {
  PickerReloadHold({
    required this.holdIsActive,
    required this.resume,
    required this.gone,
  });

  /// How long after a resume nobody answered it is asked once more.
  static const Duration retryAfter = Duration(seconds: 2);

  /// Whether the page has a hold now.
  final bool Function() holdIsActive;

  /// Asks the page for this hold; whether it has it again.
  final Future<bool> Function(String holdId) resume;

  /// The answer is final: this hold is not coming back.
  final void Function(String holdId) gone;

  String? _holdId;
  Timer? _timer;

  /// Remembers what the page that is going away had. Null: it had no hold.
  void remember(String? holdId) {
    forget();
    _holdId = holdId;
  }

  void forget() {
    _timer?.cancel();
    _timer = null;
    _holdId = null;
  }

  /// A page is up: asks it for the hold, if one was remembered.
  void pageReady() {
    _timer?.cancel();
    _timer = null;
    final holdId = _holdId;
    if (holdId != null) unawaited(_attempt(holdId, last: false));
  }

  Future<void> _attempt(String holdId, {required bool last}) async {
    // A hold the buyer made while this one waited is the buyer's.
    if (holdIsActive()) return forget();
    var restored = false;
    Object? failure;
    try {
      restored = await resume(holdId);
    } catch (error) {
      failure = error;
    }
    if (_holdId != holdId) return;
    // A page that is gone leaves the hold to the page that takes its place.
    if (failure is TransportFailure || failure is DestroyedFailure) return;
    if (!last && failure != null && _unanswered(failure)) {
      _timer = Timer(retryAfter, () {
        if (_holdId == holdId) unawaited(_attempt(holdId, last: true));
      });
      return;
    }
    forget();
    if (!restored) gone(holdId);
  }

  /// A failure the server did not answer: no network, a time-out.
  static bool _unanswered(Object error) =>
      error is TimeoutFailure ||
      (error is BridgeFailure &&
          error.code == 'command_failed' &&
          jInt(jGet(jGet(error.payload.details, 'meta'), 'status')) == null);
}
