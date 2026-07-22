import 'dart:convert';

import '../json.dart';

/// Envelope kind.
///
/// [unknown] exists because a bundle newer than this app may introduce a kind
/// this build has never heard of. Decoding must yield a value, never throw —
/// the router then ignores what it cannot act on. Mirrors the iOS SDK's
/// `EnvelopeKind.unknown(String)` case.
sealed class EnvelopeKind {
  const EnvelopeKind();

  /// web→native: handshake opener.
  static const EnvelopeKind hello = _KindHello();

  /// native→web: handshake reply. (`init` is a reserved word in Dart.)
  static const EnvelopeKind init = _KindInit();

  /// native→web: a correlated command.
  static const EnvelopeKind cmd = _KindCmd();

  /// web→native: the success reply to one `cmd`.
  static const EnvelopeKind res = _KindRes();

  /// web→native: the failure reply to one `cmd`.
  static const EnvelopeKind err = _KindErr();

  /// web→native: an unsolicited event carrying a monotonic sequence.
  static const EnvelopeKind evt = _KindEvt();

  factory EnvelopeKind.fromRaw(String raw) => switch (raw) {
        'hello' => hello,
        'init' => init,
        'cmd' => cmd,
        'res' => res,
        'err' => err,
        'evt' => evt,
        _ => EnvelopeKindUnknown(raw),
      };

  String get raw;

  @override
  String toString() => raw;
}

final class _KindHello extends EnvelopeKind {
  const _KindHello();
  @override
  String get raw => 'hello';
}

final class _KindInit extends EnvelopeKind {
  const _KindInit();
  @override
  String get raw => 'init';
}

final class _KindCmd extends EnvelopeKind {
  const _KindCmd();
  @override
  String get raw => 'cmd';
}

final class _KindRes extends EnvelopeKind {
  const _KindRes();
  @override
  String get raw => 'res';
}

final class _KindErr extends EnvelopeKind {
  const _KindErr();
  @override
  String get raw => 'err';
}

final class _KindEvt extends EnvelopeKind {
  const _KindEvt();
  @override
  String get raw => 'evt';
}

/// A kind a bundle newer than this app introduced.
final class EnvelopeKindUnknown extends EnvelopeKind {
  const EnvelopeKindUnknown(this.raw);
  @override
  final String raw;

  @override
  bool operator ==(Object other) =>
      other is EnvelopeKindUnknown && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// One bridge frame: `{ sl, k, id, n, t, p }`.
class Envelope {
  /// Envelope marker + envelope version. Always 1 for this protocol.
  static const int marker = 1;

  const Envelope({
    required this.kind,
    required this.type,
    this.id,
    this.sequence,
    this.payload,
  });

  final EnvelopeKind kind;

  /// Correlation id — set on `cmd`, echoed on the matching `res`/`err`.
  final String? id;

  /// Monotonic sequence — set on `evt` only.
  final int? sequence;

  /// Command or event name.
  final String type;

  /// Payload; a plain JSON graph. Its shape depends on [type].
  final Object? payload;

  /// Parse + validate an inbound frame, mirroring the web side's `decode()`.
  ///
  /// Accepts a JSON string (the shape the Flutter `JavaScriptChannel` delivers)
  /// or an already-structured object. Returns `null` for anything that is not a
  /// well-formed envelope — the bridge ignores those silently rather than
  /// throwing, because a WebView can receive messages it does not own.
  ///
  /// One deliberate divergence from the web `decode`: the web side rejects a
  /// frame whose `k` is unknown, because a page may receive unrelated
  /// `postMessage` traffic. Our only writer is our own bundle, so an unknown `k`
  /// means a NEWER bundle, not foreign traffic — we decode it as [unknown] and
  /// let the router drop it, keeping an old app forward-compatible.
  static Envelope? decode(Object? input) {
    Object? raw = input;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    final fields = jObj(raw);
    if (fields == null) return null;
    if (jInt(fields['sl']) != marker) return null;

    final kindRaw = jStr(fields['k']);
    if (kindRaw == null) return null;

    final type = jStr(fields['t']);
    if (type == null || type.isEmpty) return null;

    // `id` and `n`, when present and non-null, must be the right primitive — a
    // frame that gets these wrong is malformed, not merely unfamiliar.
    String? id;
    final rawId = fields['id'];
    if (rawId != null) {
      final str = jStr(rawId);
      if (str == null) return null;
      id = str;
    }

    int? sequence;
    final rawSeq = fields['n'];
    if (rawSeq != null) {
      // JS has one number type, so `n: 1` can reach us as `1.0`. Matching the
      // web side's `isFiniteInt` means accepting any finite, integral number;
      // demanding a strict int here would silently reject every `evt`.
      final seq = jInt(rawSeq);
      if (seq == null) return null;
      sequence = seq;
    }

    return Envelope(
      kind: EnvelopeKind.fromRaw(kindRaw),
      type: type,
      id: id,
      sequence: sequence,
      payload: fields.containsKey('p') ? fields['p'] : null,
    );
  }

  /// Lower to the wire object, omitting fields the web side treats as absent.
  Map<String, Object?> toJson() {
    final fields = <String, Object?>{
      'sl': marker,
      'k': kind.raw,
      't': type,
    };
    if (id != null) fields['id'] = id;
    if (sequence != null) fields['n'] = sequence;
    if (payload != null) fields['p'] = payload;
    return fields;
  }

  /// Serialise for the string-based Flutter transport.
  String encode() => jsonEncode(toJson());

  @override
  String toString() => 'Envelope(${kind.raw} t=$type id=$id n=$sequence)';
}
