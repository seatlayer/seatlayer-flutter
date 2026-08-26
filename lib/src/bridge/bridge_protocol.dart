import 'dart:math' as math;

import '../json.dart';

/// Oldest protocol revision this SDK can speak.
const int seatLayerProtocolMin = 1;

/// Newest protocol revision this SDK can speak.
const int seatLayerProtocolMax = 2;

/// Protocol range as advertised by either side of the handshake.
class ProtocolRange {
  const ProtocolRange({required this.min, required this.max});

  final int min;
  final int max;

  /// This SDK's own range.
  static const ProtocolRange native = ProtocolRange(
    min: seatLayerProtocolMin,
    max: seatLayerProtocolMax,
  );

  /// Normalise a `protocol` field that may be a bare number OR a `{min,max}`.
  static ProtocolRange? from(Object? value) {
    if (value == null) return null;
    final revision = jInt(value);
    if (revision != null) return ProtocolRange(min: revision, max: revision);
    final min = jInt(jGet(value, 'min'));
    final max = jInt(jGet(value, 'max'));
    if (min != null && max != null && min <= max) {
      return ProtocolRange(min: min, max: max);
    }
    return null;
  }

  Map<String, Object?> toJson() => {'min': min, 'max': max};

  @override
  bool operator ==(Object other) =>
      other is ProtocolRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => '$min..$max';
}

/// Result of intersecting the two sides' protocol ranges.
sealed class Negotiation {
  const Negotiation();
}

final class NegotiationAgreed extends Negotiation {
  const NegotiationAgreed(this.protocol);
  final int protocol;
}

final class NegotiationIncompatible extends Negotiation {
  const NegotiationIncompatible(this.reason);
  final String reason;
}

/// Version negotiation by RANGE INTERSECTION.
///
/// The agreed revision is the highest both sides can speak — `min(aMax, bMax)`.
/// If that falls below EITHER side's minimum the ranges do not overlap and there
/// is no revision both understand, so the bridge refuses to render rather than
/// half-speaking a protocol.
///
/// Both upgrade directions are therefore safe:
///   - old app (max 1) + new bundle (1..3) -> agreed 1, the bundle speaks down.
///   - new app (2..4) + old bundle (max 1) -> agreed 1 < appMin 2 -> incompatible.
Negotiation negotiate({
  ProtocolRange native = ProtocolRange.native,
  required ProtocolRange web,
}) {
  final agreed = math.min(native.max, web.max);
  if (agreed < native.min || agreed < web.min) {
    return NegotiationIncompatible(
      'no shared protocol revision '
      '(native ${native.min}..${native.max}, web ${web.min}..${web.max})',
    );
  }
  return NegotiationAgreed(agreed);
}

/// Bridge-level error codes.
///
/// Anything the underlying API returns (`sold_out`, …) passes through
/// unchanged, so this is an OPEN string set: only special-case the codes below.
abstract final class BridgeErrorCode {
  /// `t` is not in the bundle's command table.
  static const String unsupportedCommand = 'unsupported_command';

  /// `p` failed the command's argument validation.
  static const String badPayload = 'bad_payload';

  /// A command arrived before `sys.ready`.
  static const String notReady = 'not_ready';

  /// A command arrived after the `destroy` command.
  static const String destroyed = 'destroyed';

  /// Native-only: no reply arrived within the command timeout. This code has no
  /// web-side counterpart — the web bridge answers every `cmd`, so a missing
  /// reply means the WebView itself stalled or was torn down.
  static const String timeout = 'sl_timeout';
}

/// One seat the server reported as no longer holdable — the `conflicts` an
/// availability failure (a 409) carries. Decoded leniently: the server's
/// vocabulary grows, and a missing or unfamiliar field must never turn a real
/// conflict into a decode failure.
class HoldConflict {
  const HoldConflict({this.label, this.status});

  /// The inventory label of the seat that conflicted (e.g. `A-1`).
  final String? label;

  /// Why it conflicted, as the server named it (`booked`, `held`, …).
  final String? status;

  static HoldConflict? fromJson(Object? v) {
    if (jObj(v) == null) return null;
    return HoldConflict(
      label: jStr(jGet(v, 'label')),
      status: jStr(jGet(v, 'status')),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HoldConflict && other.label == label && other.status == status;

  @override
  int get hashCode => Object.hash(label, status);

  @override
  String toString() => 'HoldConflict($label, $status)';
}

/// Payload of an `err` envelope, and of the `sys.error` / `error` event.
class BridgeErrorPayload {
  const BridgeErrorPayload({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;

  /// Optional extra context (API conflicts, validation detail). A raw JSON graph.
  final Object? details;

  factory BridgeErrorPayload.fromJson(Object? value) => BridgeErrorPayload(
        code: jStr(jGet(value, 'code')) ?? 'unknown_error',
        message: jStr(jGet(value, 'message')) ?? '',
        details: jGet(value, 'details'),
      );

  /// The seats an availability failure (`sold_out`, `not_enough_together`, a
  /// hold 409) reported as already gone, or `null` when the error carries none.
  ///
  /// The API nests these under `details.conflicts`; decoding is best-effort so
  /// one malformed entry never masks the rest.
  List<HoldConflict>? get conflicts {
    final raw = jList(jGet(details, 'conflicts'));
    if (raw == null || raw.isEmpty) return null;
    final decoded = jListOf(raw, HoldConflict.fromJson);
    return decoded.isEmpty ? null : decoded;
  }

  @override
  String toString() => 'BridgeErrorPayload($code: $message)';
}
