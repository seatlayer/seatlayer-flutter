/// Loss-tolerant JSON accessors.
///
/// The bridge payload (`p`) is schema-free by design: the web bundle may add
/// fields at any time and this SDK must carry them across unchanged rather than
/// fail to decode. Everything decoded off the wire is a plain Dart JSON graph
/// (`Map<String, dynamic>` / `List` / `num` / `String` / `bool` / `null`). These
/// helpers project that graph onto typed values and NEVER throw on a missing,
/// null, or wrongly-typed field — they return `null` and let the caller decide.
///
/// The number helpers are the single most important part of this file. JSON has
/// one number type, so a value the server thinks of as an integer (`123`) and
/// one it thinks of as a double (`123.0`) are indistinguishable on the wire and
/// Dart's `jsonDecode` may hand back either an `int` or a `double`. Decoding a
/// hold's `expiresAt` (a double) or an event's `n` (an int) must accept BOTH —
/// the class of bug (double-vs-int) that a real device run once caught in the
/// iOS SDK. `jInt` accepts an integral double; `jDouble` accepts any `num`.
library;

/// The string at [v], or `null` if it is not a string.
String? jStr(Object? v) => v is String ? v : null;

/// The bool at [v], or `null` if it is not a bool.
bool? jBool(Object? v) => v is bool ? v : null;

/// The integer at [v]. Accepts an integral, finite `double` — a JSON `1` may
/// reach us as `1.0`, and demanding a strict `int` would silently reject it.
int? jInt(Object? v) {
  if (v is int) return v;
  if (v is double && v.isFinite && v == v.roundToDouble()) return v.toInt();
  return null;
}

/// The double at [v]. Accepts any `num`, so an integral JSON number (`123`,
/// decoded as `int`) still reads as `123.0` — the double-vs-int tolerance.
double? jDouble(Object? v) => v is num ? v.toDouble() : null;

/// The list at [v], or `null` if it is not a list.
List<Object?>? jList(Object? v) => v is List ? v : null;

/// The object at [v] as a `String`-keyed map, or `null` if it is not an object.
Map<String, Object?>? jObj(Object? v) =>
    v is Map ? v.cast<String, Object?>() : null;

/// The value under [key] of the object at [v], or `null` when [v] is not an
/// object or has no such key.
Object? jGet(Object? v, String key) => jObj(v)?[key];

/// Decode a JSON array into a list of [T], dropping (not throwing on) any entry
/// that fails to decode — one malformed element must never discard the rest.
List<T> jListOf<T>(Object? v, T? Function(Object?) decode) {
  final items = jList(v);
  if (items == null) return <T>[];
  final out = <T>[];
  for (final item in items) {
    final decoded = decode(item);
    if (decoded != null) out.add(decoded);
  }
  return out;
}
