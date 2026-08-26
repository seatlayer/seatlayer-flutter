/// String-backed enums that never fail to decode.
///
/// Dart enums are CLOSED: a plain `enum` throws (or forces a fallback) the
/// moment the wire carries a value it does not list. The web bundle is updated
/// INDEPENDENTLY of the app, so an app compiled today must keep working when a
/// bundle a year from now ships a new seat status, transport name, or object
/// type. Every bridged enum is therefore a `sealed class` with a dedicated
/// `Unknown(raw)` variant: `fromRaw` maps a known string to its case and folds
/// everything else into `Unknown`, preserving the raw string. Decoders can then
/// exhaustively `switch` on the known cases while an unfamiliar value survives
/// intact instead of taking the seat map down.
///
/// This mirrors the iOS SDK's `OpenEnum` protocol (`.unknown(String)` cases),
/// which is exactly what let an old iOS app talk to a newer bundle.
library;

/// Whether the SERVED event books real inventory.
///
/// A test event looks and behaves exactly like a live one but books nothing, so
/// an app that cannot tell them apart can ship a build that appears to work and
/// sells no tickets. Always badge [test] in the UI.
sealed class EventMode {
  const EventMode();

  static const EventMode live = _EventModeLive();
  static const EventMode test = _EventModeTest();

  factory EventMode.fromRaw(String raw) => switch (raw) {
        'live' => live,
        'test' => test,
        _ => EventModeUnknown(raw),
      };

  String get raw;
  bool get isUnknown => this is EventModeUnknown;

  @override
  String toString() => raw;
}

final class _EventModeLive extends EventMode {
  const _EventModeLive();
  @override
  String get raw => 'live';
}

final class _EventModeTest extends EventMode {
  const _EventModeTest();
  @override
  String get raw => 'test';
}

/// A mode a bundle newer than this app introduced.
final class EventModeUnknown extends EventMode {
  const EventModeUnknown(this.raw);
  @override
  final String raw;

  @override
  bool operator ==(Object other) =>
      other is EventModeUnknown && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// Which web→native shim the bundle selected. [flutter] is the expected value
/// in this SDK; anything else means the bundle fell back to another channel.
sealed class TransportName {
  const TransportName();

  static const TransportName ios = _TransportIos();
  static const TransportName android = _TransportAndroid();
  static const TransportName flutter = _TransportFlutter();
  static const TransportName reactNative = _TransportRn();
  static const TransportName frame = _TransportFrame();
  static const TransportName none = _TransportNone();

  factory TransportName.fromRaw(String raw) => switch (raw) {
        'ios' => ios,
        'android' => android,
        'flutter' => flutter,
        'rn' => reactNative,
        'frame' => frame,
        'none' => none,
        _ => TransportNameUnknown(raw),
      };

  String get raw;
  bool get isUnknown => this is TransportNameUnknown;

  @override
  String toString() => raw;
}

final class _TransportIos extends TransportName {
  const _TransportIos();
  @override
  String get raw => 'ios';
}

final class _TransportAndroid extends TransportName {
  const _TransportAndroid();
  @override
  String get raw => 'android';
}

final class _TransportFlutter extends TransportName {
  const _TransportFlutter();
  @override
  String get raw => 'flutter';
}

final class _TransportRn extends TransportName {
  const _TransportRn();
  @override
  String get raw => 'rn';
}

final class _TransportFrame extends TransportName {
  const _TransportFrame();
  @override
  String get raw => 'frame';
}

final class _TransportNone extends TransportName {
  const _TransportNone();
  @override
  String get raw => 'none';
}

/// A transport name a bundle newer than this app introduced.
final class TransportNameUnknown extends TransportName {
  const TransportNameUnknown(this.raw);
  @override
  final String raw;

  @override
  bool operator ==(Object other) =>
      other is TransportNameUnknown && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// What kind of sellable object a hold line item covers.
sealed class ObjectType {
  const ObjectType();

  static const ObjectType seat = _ObjectSeat();
  static const ObjectType booth = _ObjectBooth();
  static const ObjectType ga = _ObjectGa();
  static const ObjectType table = _ObjectTable();

  factory ObjectType.fromRaw(String raw) => switch (raw) {
        'seat' => seat,
        'booth' => booth,
        'ga' => ga,
        'table' => table,
        _ => ObjectTypeUnknown(raw),
      };

  String get raw;
  bool get isUnknown => this is ObjectTypeUnknown;

  @override
  String toString() => raw;
}

final class _ObjectSeat extends ObjectType {
  const _ObjectSeat();
  @override
  String get raw => 'seat';
}

final class _ObjectBooth extends ObjectType {
  const _ObjectBooth();
  @override
  String get raw => 'booth';
}

final class _ObjectGa extends ObjectType {
  const _ObjectGa();
  @override
  String get raw => 'ga';
}

final class _ObjectTable extends ObjectType {
  const _ObjectTable();
  @override
  String get raw => 'table';
}

/// An object type a bundle newer than this app introduced.
final class ObjectTypeUnknown extends ObjectType {
  const ObjectTypeUnknown(this.raw);
  @override
  final String raw;

  @override
  bool operator ==(Object other) =>
      other is ObjectTypeUnknown && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// Live status of a seat. The server's status vocabulary grows over time.
sealed class SeatStatus {
  const SeatStatus();

  static const SeatStatus free = _SeatFree();
  static const SeatStatus held = _SeatHeld();
  static const SeatStatus booked = _SeatBooked();
  static const SeatStatus blocked = _SeatBlocked();

  factory SeatStatus.fromRaw(String raw) => switch (raw) {
        'free' => free,
        'held' => held,
        'booked' => booked,
        'blocked' => blocked,
        _ => SeatStatusUnknown(raw),
      };

  String get raw;
  bool get isUnknown => this is SeatStatusUnknown;

  @override
  String toString() => raw;
}

final class _SeatFree extends SeatStatus {
  const _SeatFree();
  @override
  String get raw => 'free';
}

final class _SeatHeld extends SeatStatus {
  const _SeatHeld();
  @override
  String get raw => 'held';
}

final class _SeatBooked extends SeatStatus {
  const _SeatBooked();
  @override
  String get raw => 'booked';
}

final class _SeatBlocked extends SeatStatus {
  const _SeatBlocked();
  @override
  String get raw => 'blocked';
}

/// A status a bundle newer than this app introduced.
final class SeatStatusUnknown extends SeatStatus {
  const SeatStatusUnknown(this.raw);
  @override
  final String raw;

  @override
  bool operator ==(Object other) =>
      other is SeatStatusUnknown && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// Buyer canvas projection used by the shared picker.
class SeatLayerViewMode {
  const SeatLayerViewMode(this.raw);
  final String raw;

  static const flat = SeatLayerViewMode('flat');
  static const isometric = SeatLayerViewMode('iso');
  static const perspective = SeatLayerViewMode('perspective');

  factory SeatLayerViewMode.fromRaw(String raw) => switch (raw) {
        'flat' => flat,
        'iso' => isometric,
        'perspective' => perspective,
        _ => SeatLayerViewMode(raw),
      };

  @override
  bool operator ==(Object other) =>
      other is SeatLayerViewMode && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// Buyer-facing surface: the flat map or SeatLayer's real WebGL venue view.
///
/// This is intentionally separate from [SeatLayerViewMode], whose isometric
/// value is a legacy 2D canvas projection and is not immersive 3D.
class SeatLayerBuyerView {
  const SeatLayerBuyerView(this.raw);
  final String raw;

  static const map = SeatLayerBuyerView('map');
  static const venue3D = SeatLayerBuyerView('venue3d');

  factory SeatLayerBuyerView.fromRaw(String raw) => switch (raw) {
        'map' => map,
        'venue3d' => venue3D,
        _ => SeatLayerBuyerView(raw),
      };

  @override
  bool operator ==(Object other) =>
      other is SeatLayerBuyerView && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// What a primary drag does inside the real venue-3D surface.
class SeatLayer3DNavigationMode {
  const SeatLayer3DNavigationMode(this.raw);
  final String raw;

  static const rotate = SeatLayer3DNavigationMode('orbit');
  static const move = SeatLayer3DNavigationMode('pan');

  factory SeatLayer3DNavigationMode.fromRaw(String raw) => switch (raw) {
        'orbit' => rotate,
        'pan' => move,
        _ => SeatLayer3DNavigationMode(raw),
      };

  @override
  bool operator ==(Object other) =>
      other is SeatLayer3DNavigationMode && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

/// Decode an optional open-enum string, tolerating null and non-strings.
EventMode? eventModeOrNull(Object? v) =>
    v is String ? EventMode.fromRaw(v) : null;
TransportName? transportNameOrNull(Object? v) =>
    v is String ? TransportName.fromRaw(v) : null;
ObjectType? objectTypeOrNull(Object? v) =>
    v is String ? ObjectType.fromRaw(v) : null;
SeatStatus? seatStatusOrNull(Object? v) =>
    v is String ? SeatStatus.fromRaw(v) : null;
