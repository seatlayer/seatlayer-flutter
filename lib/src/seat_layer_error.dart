import 'bridge/bridge_protocol.dart';

/// Every failure this SDK surfaces.
///
/// A `sealed class` so callers can `switch` exhaustively, mirroring the iOS
/// `SeatLayerError` enum. A failed command completes its `Future` WITH one of
/// these (it does not merely fire a global stream) — the iOS SDK's key fix: a
/// `bestAvailable` conflict must surface `sold_out` / `not_enough_together` on
/// the awaited call, not only out of band.
sealed class SeatLayerError implements Exception {
  const SeatLayerError();

  /// The web side answered a command with `err`, or emitted `sys.error` /
  /// `error`. [BridgeErrorPayload.code] is an OPEN set: bridge codes
  /// (`bad_payload`, `not_ready`, …) and API codes (`sold_out`, …) both arrive
  /// here unchanged.
  const factory SeatLayerError.bridge(BridgeErrorPayload payload) = BridgeFailure;

  /// No `res`/`err` arrived for a command within the timeout.
  const factory SeatLayerError.timeout(String command, Duration duration) =
      TimeoutFailure;

  /// The two protocol ranges do not intersect — there is no revision both sides
  /// understand. The remedy is a version change, not a retry.
  const factory SeatLayerError.incompatible({
    required ProtocolRange native,
    required ProtocolRange web,
    required String reason,
  }) = IncompatibleFailure;

  /// The handshake did not complete within the configured window.
  const factory SeatLayerError.handshakeTimeout(Duration duration) =
      HandshakeTimeoutFailure;

  /// The view was torn down, or `destroy()` was called, before the command
  /// could complete.
  const factory SeatLayerError.destroyed() = DestroyedFailure;

  /// The WebView could not be driven (script evaluation failed, page load).
  const factory SeatLayerError.transport(String detail) = TransportFailure;

  /// A reply arrived but did not match the expected shape.
  const factory SeatLayerError.decoding(String detail) = DecodingFailure;

  /// The wire code, for callers that branch on the open code set.
  String get code;

  /// A human-readable description.
  String get message;

  /// True when the user needs a new build of the app — the one failure no
  /// amount of retrying will fix.
  bool get requiresAppUpdate => this is IncompatibleFailure;

  /// The seats an availability failure reported as already taken, when the error
  /// carries them (a `bestAvailable` / `hold` / `holdGA` 409); `null` otherwise.
  List<HoldConflict>? get conflicts =>
      this is BridgeFailure ? (this as BridgeFailure).payload.conflicts : null;

  @override
  String toString() => 'SeatLayerError[$code]: $message';
}

final class BridgeFailure extends SeatLayerError {
  const BridgeFailure(this.payload);
  final BridgeErrorPayload payload;

  @override
  String get code => payload.code;
  @override
  String get message => 'SeatLayer bridge error [${payload.code}]: ${payload.message}';
}

final class TimeoutFailure extends SeatLayerError {
  const TimeoutFailure(this.command, this.duration);
  final String command;
  final Duration duration;

  @override
  String get code => BridgeErrorCode.timeout;
  @override
  String get message =>
      'SeatLayer command `$command` timed out after ${duration.inSeconds}s '
      '(${BridgeErrorCode.timeout})';
}

final class IncompatibleFailure extends SeatLayerError {
  const IncompatibleFailure({
    required this.native,
    required this.web,
    required this.reason,
  });
  final ProtocolRange native;
  final ProtocolRange web;
  final String reason;

  @override
  String get code => 'sl_incompatible';
  @override
  String get message =>
      'SeatLayer is out of date and cannot run this seat map. This app speaks '
      'protocol ${native.min}-${native.max}; the seat map bundle speaks '
      '${web.min}-${web.max}. Please update the app. ($reason)';
}

final class HandshakeTimeoutFailure extends SeatLayerError {
  const HandshakeTimeoutFailure(this.duration);
  final Duration duration;

  @override
  String get code => 'sl_handshake_timeout';
  @override
  String get message =>
      'SeatLayer seat map did not start within ${duration.inSeconds}s';
}

final class DestroyedFailure extends SeatLayerError {
  const DestroyedFailure();
  @override
  String get code => BridgeErrorCode.destroyed;
  @override
  String get message => 'SeatLayer view has been destroyed';
}

final class TransportFailure extends SeatLayerError {
  const TransportFailure(this.detail);
  final String detail;
  @override
  String get code => 'sl_transport';
  @override
  String get message => 'SeatLayer transport failure: $detail';
}

final class DecodingFailure extends SeatLayerError {
  const DecodingFailure(this.detail);
  final String detail;
  @override
  String get code => 'sl_decoding';
  @override
  String get message => 'SeatLayer could not decode a bridge reply: $detail';
}
