import 'dart:async';

import 'package:flutter/foundation.dart';

/// The capability under which a page tells the app its line to the server.
const seatLayerConnectionStateCapability = 'connection-state-v1';

/// The page's line to the server, as `connection.changed` and the snapshot's
/// `map.connection` name it.
enum SeatLayerConnectionState {
  /// The live line is open.
  live,

  /// The live line closed and a retry is set.
  reconnecting,

  /// Seats come by the page's regular poll.
  polling,

  /// The device says it has no network.
  offline;

  /// The state [value] names, or null for a value this SDK does not know.
  static SeatLayerConnectionState? fromJson(Object? value) => switch (value) {
        'live' => live,
        'reconnecting' => reconnecting,
        'polling' => polling,
        'offline' => offline,
        _ => null,
      };
}

/// What the picker's connection status says.
enum SeatLayerConnectionShown {
  /// Nothing: the line is fine, or nothing has been wrong long enough.
  none,

  /// "You're offline".
  offline,

  /// "Updating…": coming back, or no seat news for a while.
  updating,

  /// "Back online", for a moment after an outage the buyer was told about.
  back,
}

/// Turns the page's line into what the buyer is told, and when.
///
/// "You're offline" waits [offlineAfter], so a blink of the network says
/// nothing. A line that is merely retrying says "Updating…" after
/// [updatingAfter]. "Back online" follows only an outage the buyer was told
/// about, and only once the seats have been read again; it stays [backFor].
class SeatLayerConnectionWatch extends ValueNotifier<SeatLayerConnectionShown> {
  SeatLayerConnectionWatch({
    this.offlineAfter = const Duration(seconds: 3),
    this.updatingAfter = const Duration(seconds: 10),
    this.backFor = const Duration(milliseconds: 2500),
  }) : super(SeatLayerConnectionShown.none);

  final Duration offlineAfter;
  final Duration updatingAfter;
  final Duration backFor;

  SeatLayerConnectionState? _state;
  bool _saidOffline = false;
  bool _waitingForSeats = false;
  Timer? _timer;
  bool _disposed = false;

  /// The page's latest state, or null when it has said none.
  SeatLayerConnectionState? get state => _state;

  /// Whether the buyer has been told they are offline and is not yet back.
  bool get saidOffline => _saidOffline;

  /// The page reported [next]. Null (a value this SDK does not know) and a
  /// repeat change nothing.
  void heard(SeatLayerConnectionState? next) {
    if (_disposed || next == null || next == _state) return;
    _state = next;
    _timer?.cancel();
    _timer = null;
    switch (next) {
      case SeatLayerConnectionState.offline:
        _waitingForSeats = false;
        if (_saidOffline) {
          _show(SeatLayerConnectionShown.offline);
        } else {
          _timer = Timer(offlineAfter, () {
            _saidOffline = true;
            _show(SeatLayerConnectionShown.offline);
          });
        }
      case SeatLayerConnectionState.reconnecting:
        _waitingForSeats = false;
        if (_saidOffline) {
          _show(SeatLayerConnectionShown.updating);
        } else if (value != SeatLayerConnectionShown.updating) {
          _timer = Timer(
            updatingAfter,
            () => _show(SeatLayerConnectionShown.updating),
          );
        }
      case SeatLayerConnectionState.live:
      case SeatLayerConnectionState.polling:
        if (_saidOffline) {
          // Back: say so once the seats have been read again.
          _waitingForSeats = true;
          _show(SeatLayerConnectionShown.updating);
        } else {
          _show(SeatLayerConnectionShown.none);
        }
    }
  }

  /// The page's seats were read: a snapshot arrived.
  void seatsRead() {
    if (_disposed || !_waitingForSeats) return;
    _waitingForSeats = false;
    _saidOffline = false;
    _show(SeatLayerConnectionShown.back);
    _timer?.cancel();
    _timer = Timer(backFor, () => _show(SeatLayerConnectionShown.none));
  }

  /// A new page: nothing it has not said yet is known.
  void reset() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    _state = null;
    _saidOffline = false;
    _waitingForSeats = false;
    _show(SeatLayerConnectionShown.none);
  }

  void _show(SeatLayerConnectionShown shown) {
    if (!_disposed) value = shown;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
