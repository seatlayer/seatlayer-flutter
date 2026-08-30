import 'dart:async';

import 'bridge/bridge_protocol.dart';
import 'json.dart';
import 'open_enums.dart';

// Every type here decodes from a raw JSON graph via a `fromJson` that CANNOT
// throw on an unfamiliar or missing field: unknown fields are ignored and
// missing ones become null. The web bundle is updated independently of the app,
// so an app compiled today must keep working when a bundle a year from now adds
// a field or ships a new enum value. Open enums fold unknown values into their
// `Unknown` variant (see open_enums.dart).

/// Why private buyer access needs a fresh bearer.
class BuyerAccessRefreshReason {
  const BuyerAccessRefreshReason(this.raw);
  final String raw;

  static const initial = BuyerAccessRefreshReason('initial');
  static const expiring = BuyerAccessRefreshReason('expiring');
  static const expired = BuyerAccessRefreshReason('expired');
  static const unauthorized = BuyerAccessRefreshReason('unauthorized');
  static const reconnect = BuyerAccessRefreshReason('reconnect');
  static const manual = BuyerAccessRefreshReason('manual');

  factory BuyerAccessRefreshReason.fromRaw(String raw) => switch (raw) {
        'initial' => initial,
        'expiring' => expiring,
        'expired' => expired,
        'unauthorized' => unauthorized,
        'reconnect' => reconnect,
        'manual' => manual,
        _ => BuyerAccessRefreshReason(raw),
      };

  @override
  bool operator ==(Object other) =>
      other is BuyerAccessRefreshReason && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

class BuyerAccessUnavailableReason {
  const BuyerAccessUnavailableReason(this.raw);
  final String raw;

  static const revoked = BuyerAccessUnavailableReason('revoked');
  static const paused = BuyerAccessUnavailableReason('paused');
  static const invalid = BuyerAccessUnavailableReason('invalid');
  static const originMismatch = BuyerAccessUnavailableReason('origin_mismatch');
  static const eventMismatch = BuyerAccessUnavailableReason('event_mismatch');
  static const groupMismatch = BuyerAccessUnavailableReason('group_mismatch');
  static const modeMismatch = BuyerAccessUnavailableReason('mode_mismatch');
  static const channelDenied = BuyerAccessUnavailableReason('channel_denied');
  static const invalidScope = BuyerAccessUnavailableReason('invalid_scope');
  static const providerFailed = BuyerAccessUnavailableReason('provider_failed');
  static const noToken = BuyerAccessUnavailableReason('no_token');

  factory BuyerAccessUnavailableReason.fromRaw(String raw) =>
      BuyerAccessUnavailableReason(raw);
}

class SelectionViolation {
  const SelectionViolation(this.raw);
  final String raw;

  @override
  bool operator ==(Object other) =>
      other is SelectionViolation && other.raw == raw;
  @override
  int get hashCode => raw.hashCode;
}

class SelectedObjectUnavailableReason {
  const SelectedObjectUnavailableReason(this.raw);
  final String raw;
}

class BuyerAccessToken {
  const BuyerAccessToken({required this.token, this.expiresAt});
  final String token;

  /// Epoch milliseconds; omit to refresh reactively.
  final double? expiresAt;

  Map<String, Object?> toJson() => {
        'token': token,
        if (expiresAt != null) 'expiresAt': expiresAt,
      };
}

class BuyerAccessRequestContext {
  const BuyerAccessRequestContext({required this.reason});
  final BuyerAccessRefreshReason reason;
}

typedef BuyerAccessTokenProvider = FutureOr<BuyerAccessToken> Function(
  BuyerAccessRequestContext context,
);

sealed class SelectionValidator {
  const SelectionValidator();
  Map<String, Object?> toJson();
}

final class MinimumSelectedPlaces extends SelectionValidator {
  const MinimumSelectedPlaces(this.minimum);
  final int minimum;
  @override
  Map<String, Object?> toJson() => {
        'type': 'minimumSelectedPlaces',
        'minimum': minimum,
      };
}

final class ConsecutiveSeats extends SelectionValidator {
  const ConsecutiveSeats();
  @override
  Map<String, Object?> toJson() => const {'type': 'consecutiveSeats'};
}

final class NoOrphanSeats extends SelectionValidator {
  const NoOrphanSeats();
  @override
  Map<String, Object?> toJson() => const {'type': 'noOrphanSeats'};
}

/// A ticket tier a category offers (Adult / Child / …).
class CategoryTier {
  const CategoryTier({
    required this.id,
    required this.name,
    required this.price,
    this.currency,
    this.restriction,
    this.buyerMessage,
  });
  final String id;
  final String name;
  final double price;
  final String? currency;
  final String? restriction;
  final String? buyerMessage;

  static CategoryTier? fromJson(Object? v) {
    final id = jStr(jGet(v, 'id'));
    final name = jStr(jGet(v, 'name'));
    final price = jDouble(jGet(v, 'price'));
    if (id == null || name == null || price == null) return null;
    return CategoryTier(
      id: id,
      name: name,
      price: price,
      currency: jStr(jGet(v, 'currency')),
      restriction: jStr(jGet(v, 'restriction')),
      buyerMessage: jStr(jGet(v, 'buyerMessage')),
    );
  }
}

/// Commercial selling/view attributes resolved for a seat.
class SeatCommercialAttributes {
  const SeatCommercialAttributes({
    this.restrictedView,
    this.obstructedView,
    this.premium,
    this.note,
  });
  final bool? restrictedView;
  final bool? obstructedView;
  final bool? premium;
  final String? note;

  static SeatCommercialAttributes? fromJson(Object? v) {
    if (jObj(v) == null) return null;
    return SeatCommercialAttributes(
      restrictedView: jBool(jGet(v, 'restrictedView')),
      obstructedView: jBool(jGet(v, 'obstructedView')),
      premium: jBool(jGet(v, 'premium')),
      note: jStr(jGet(v, 'note')),
    );
  }
}

/// One selected seat.
class SelectedSeat {
  const SelectedSeat({
    required this.id,
    required this.label,
    this.displayLabel,
    this.displayType,
    this.rowType,
    this.objectId,
    this.objectType,
    this.sectionLabel,
    this.rowLabel,
    this.seatNumber,
    this.categoryKey,
    this.price,
    this.currency,
    this.tiers,
    this.tierId,
    this.commercial,
    this.quantity,
    this.bookingMode,
    this.capacity,
    this.minOccupancy,
    this.maxOccupancy,
    this.accessibility,
    this.wheelchairSpaceType,
  });

  final String id;
  final String label;

  /// Buyer-facing label (row `displayLabel` applied). Falls back to [label].
  /// NEVER use for booking — [label] is the inventory identity.
  final String? displayLabel;
  final String? displayType;

  /// Deprecated compatibility alias supplied by older chart documents.
  /// New integrations should use [displayType].
  final String? rowType;
  final String? objectId;
  final ObjectType? objectType;

  /// Buyer-facing spatial identity used by native confirmation and cart UI.
  /// These values are display-only; [label] remains the booking identity.
  final String? sectionLabel;
  final String? rowLabel;
  final String? seatNumber;
  final String? categoryKey;

  /// Price for the chosen tier when the category has tiers, else base price.
  final double? price;
  final String? currency;
  final List<CategoryTier>? tiers;

  /// The chosen tier's id; absent when the category has no tiers.
  final String? tierId;
  final SeatCommercialAttributes? commercial;
  final int? quantity;
  final String? bookingMode;
  final int? capacity;
  final int? minOccupancy;
  final int? maxOccupancy;
  final List<String>? accessibility;
  final String? wheelchairSpaceType;

  /// What to show the buyer. Booking still uses [label].
  String get buyerFacingLabel => displayLabel ?? label;

  static SelectedSeat? fromJson(Object? v) {
    final id = jStr(jGet(v, 'id'));
    final label = jStr(jGet(v, 'label'));
    if (id == null || label == null) return null;
    final tiers = jGet(v, 'tiers');
    return SelectedSeat(
      id: id,
      label: label,
      displayLabel: jStr(jGet(v, 'displayLabel')),
      displayType: jStr(jGet(v, 'displayType')),
      rowType: jStr(jGet(v, 'rowType')),
      objectId: jStr(jGet(v, 'objectId')),
      objectType: objectTypeOrNull(jGet(v, 'objectType')),
      sectionLabel: jStr(jGet(v, 'sectionLabel')),
      rowLabel: jStr(jGet(v, 'rowLabel')),
      seatNumber: jStr(jGet(v, 'seatNumber')),
      categoryKey: jStr(jGet(v, 'categoryKey')),
      price: jDouble(jGet(v, 'price')),
      currency: jStr(jGet(v, 'currency')),
      tiers: tiers == null ? null : jListOf(tiers, CategoryTier.fromJson),
      tierId: jStr(jGet(v, 'tierId')),
      commercial: SeatCommercialAttributes.fromJson(jGet(v, 'commercial')),
      quantity: jInt(jGet(v, 'quantity')),
      bookingMode: jStr(jGet(v, 'bookingMode')),
      capacity: jInt(jGet(v, 'capacity')),
      minOccupancy: jInt(jGet(v, 'minOccupancy')),
      maxOccupancy: jInt(jGet(v, 'maxOccupancy')),
      accessibility: jGet(v, 'accessibility') == null
          ? null
          : jListOf(jGet(v, 'accessibility'), (item) => jStr(item)),
      wheelchairSpaceType: jStr(jGet(v, 'wheelchairSpaceType')),
    );
  }
}

class SelectionValidity {
  const SelectionValidity({
    required this.isValid,
    required this.count,
    required this.required,
    required this.remaining,
    required this.seats,
    required this.violations,
  });

  final bool isValid;
  final int count;
  final int required;
  final int remaining;
  final List<SelectedSeat> seats;
  final List<SelectionViolation> violations;

  static SelectionValidity? fromJson(Object? value) {
    final isValid = jBool(jGet(value, 'isValid'));
    final count = jInt(jGet(value, 'count'));
    final required = jInt(jGet(value, 'required'));
    final remaining = jInt(jGet(value, 'remaining'));
    if (isValid == null ||
        count == null ||
        required == null ||
        remaining == null) {
      return null;
    }
    return SelectionValidity(
      isValid: isValid,
      count: count,
      required: required,
      remaining: remaining,
      seats: jListOf(jGet(value, 'seats'), SelectedSeat.fromJson),
      violations: jListOf(
        jGet(value, 'violations'),
        (item) => item is String ? SelectionViolation(item) : null,
      ),
    );
  }
}

class BuyerAccessExpiredEvent {
  const BuyerAccessExpiredEvent({
    required this.reason,
    required this.refreshed,
    this.code,
  });
  final BuyerAccessRefreshReason reason;
  final String? code;
  final bool refreshed;

  static BuyerAccessExpiredEvent? fromJson(Object? value) {
    final reason = jStr(jGet(value, 'reason'));
    final refreshed = jBool(jGet(value, 'refreshed'));
    if (reason == null || refreshed == null) return null;
    return BuyerAccessExpiredEvent(
      reason: BuyerAccessRefreshReason.fromRaw(reason),
      code: jStr(jGet(value, 'code')),
      refreshed: refreshed,
    );
  }
}

class BuyerAccessUnavailableEvent {
  const BuyerAccessUnavailableEvent({
    required this.reason,
    required this.retryable,
    this.code,
    this.status,
  });
  final BuyerAccessUnavailableReason reason;
  final String? code;
  final int? status;
  final bool retryable;

  static BuyerAccessUnavailableEvent? fromJson(Object? value) {
    final reason = jStr(jGet(value, 'reason'));
    final retryable = jBool(jGet(value, 'retryable'));
    if (reason == null || retryable == null) return null;
    return BuyerAccessUnavailableEvent(
      reason: BuyerAccessUnavailableReason.fromRaw(reason),
      code: jStr(jGet(value, 'code')),
      status: jInt(jGet(value, 'status')),
      retryable: retryable,
    );
  }
}

class SelectedObjectUnavailableEvent {
  const SelectedObjectUnavailableEvent({
    required this.labels,
    required this.reason,
    this.code,
  });
  final List<String> labels;
  final SelectedObjectUnavailableReason reason;
  final String? code;

  static SelectedObjectUnavailableEvent? fromJson(Object? value) {
    final reason = jStr(jGet(value, 'reason'));
    if (reason == null) return null;
    return SelectedObjectUnavailableEvent(
      labels: jListOf(jGet(value, 'labels'), (item) => jStr(item)),
      reason: SelectedObjectUnavailableReason(reason),
      code: jStr(jGet(value, 'code')),
    );
  }
}

/// One line of a hold.
class HoldLineItem {
  const HoldLineItem({
    required this.label,
    this.objectId,
    this.objectType,
    this.categoryKey,
    this.tierId,
    this.unitPrice,
    this.currency,
    this.quantity,
  });

  final String label;
  final String? objectId;
  final ObjectType? objectType;
  final String? categoryKey;
  final String? tierId;

  /// Price in major currency units (45 means $45.00).
  final double? unitPrice;
  final String? currency;
  final int? quantity;

  static HoldLineItem? fromJson(Object? v) {
    final label = jStr(jGet(v, 'label'));
    if (label == null) return null;
    return HoldLineItem(
      label: label,
      objectId: jStr(jGet(v, 'objectId')),
      objectType: objectTypeOrNull(jGet(v, 'objectType')),
      categoryKey: jStr(jGet(v, 'categoryKey')),
      tierId: jStr(jGet(v, 'tierId')),
      unitPrice: jDouble(jGet(v, 'unitPrice')),
      currency: jStr(jGet(v, 'currency')),
      quantity: jInt(jGet(v, 'quantity')),
    );
  }
}

/// An open hold.
class HoldResult {
  const HoldResult({
    required this.holdId,
    required this.expiresAt,
    this.seats,
    this.items,
  });

  final String holdId;

  /// Server expiry, in milliseconds since the epoch. A double: an integral JSON
  /// number (`1712…000`) still decodes here, thanks to [jDouble]'s tolerance —
  /// the double-vs-int guard.
  final double expiresAt;
  final List<SelectedSeat>? seats;
  final List<HoldLineItem>? items;

  DateTime get expiryDate =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt.round());
  Duration get timeRemaining {
    final remaining = expiryDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static HoldResult? fromJson(Object? v) {
    if (v == null) return null;
    final holdId = jStr(jGet(v, 'holdId'));
    final expiresAt = jDouble(jGet(v, 'expiresAt'));
    if (holdId == null || expiresAt == null) return null;
    final seats = jGet(v, 'seats');
    final items = jGet(v, 'items');
    return HoldResult(
      holdId: holdId,
      expiresAt: expiresAt,
      seats: seats == null ? null : jListOf(seats, SelectedSeat.fromJson),
      items: items == null ? null : jListOf(items, HoldLineItem.fromJson),
    );
  }
}

/// Best-available response — the server-picked seats plus the hold.
class BestAvailableResult {
  const BestAvailableResult({
    required this.holdId,
    required this.expiresAt,
    required this.labels,
    this.seats,
    this.items,
  });

  final String holdId;
  final double expiresAt;
  final List<String> labels;
  final List<SelectedSeat>? seats;
  final List<HoldLineItem>? items;

  DateTime get expiryDate =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt.round());

  static BestAvailableResult? fromJson(Object? v) {
    if (v == null) return null;
    final holdId = jStr(jGet(v, 'holdId'));
    final expiresAt = jDouble(jGet(v, 'expiresAt'));
    if (holdId == null || expiresAt == null) return null;
    final seats = jGet(v, 'seats');
    final items = jGet(v, 'items');
    return BestAvailableResult(
      holdId: holdId,
      expiresAt: expiresAt,
      labels: jListOf(jGet(v, 'labels'), (e) => jStr(e)),
      seats: seats == null ? null : jListOf(seats, SelectedSeat.fromJson),
      items: items == null ? null : jListOf(items, HoldLineItem.fromJson),
    );
  }
}

/// A general-admission area and its live availability.
class GAArea {
  const GAArea({
    required this.id,
    this.label,
    this.capacity,
    this.available,
    this.categoryKey,
    this.price,
    this.currency,
    this.tiers,
  });

  final String id;
  final String? label;
  final int? capacity;
  final int? available;
  final String? categoryKey;
  final double? price;
  final String? currency;
  final List<CategoryTier>? tiers;

  static GAArea? fromJson(Object? v) {
    final id = jStr(jGet(v, 'id'));
    if (id == null) return null;
    final tiers = jGet(v, 'tiers');
    return GAArea(
      id: id,
      label: jStr(jGet(v, 'label')),
      capacity: jInt(jGet(v, 'capacity')),
      available: jInt(jGet(v, 'available')),
      categoryKey: jStr(jGet(v, 'categoryKey')),
      price: jDouble(jGet(v, 'price')),
      currency: jStr(jGet(v, 'currency')),
      tiers: tiers == null ? null : jListOf(tiers, CategoryTier.fromJson),
    );
  }
}

/// One floor of a multi-floor venue.
class FloorInfo {
  const FloorInfo({required this.id, required this.name, this.level});
  final String id;
  final String name;

  /// Where this floor sits in the building, ground being zero.
  ///
  /// **The SeatLayer runtime does not send this** (confirmed against the
  /// native-chrome contract, 2026-08-28), so it is null in practice and the
  /// SDK orders nothing by it: the snapshot's own order is the venue's order,
  /// stage upward, and it is the order the strip draws. Read leniently anyway,
  /// so a chart that one day carries a level is not a decode failure.
  final int? level;

  static FloorInfo? fromJson(Object? v) {
    final id = jStr(jGet(v, 'id'));
    final name = jStr(jGet(v, 'name'));
    if (id == null || name == null) return null;
    return FloorInfo(id: id, name: name, level: jInt(jGet(v, 'level')));
  }
}

/// Rich hover payload — everything a seat popover needs.
class SeatHoverDetails {
  const SeatHoverDetails({
    this.id,
    this.label,
    this.displayLabel,
    this.categoryKey,
    this.categoryLabel,
    this.categoryColor,
    this.status,
    this.price,
    this.currency,
    this.sectionLabel,
    this.rowLabel,
    this.seatNumber,
    this.rowType,
    this.tiers,
    this.tierId,
    this.commercial,
  });

  final String? id;
  final String? label;
  final String? displayLabel;
  final String? categoryKey;
  final String? categoryLabel;
  final String? categoryColor;
  final SeatStatus? status;
  final double? price;
  final String? currency;
  final String? sectionLabel;
  final String? rowLabel;
  final String? seatNumber;

  /// Buyer-facing type word for the row/table; absent means "Row".
  final String? rowType;
  final List<CategoryTier>? tiers;
  final String? tierId;
  final SeatCommercialAttributes? commercial;

  static SeatHoverDetails? fromJson(Object? v) {
    if (jObj(v) == null) return null;
    final tiers = jGet(v, 'tiers');
    return SeatHoverDetails(
      id: jStr(jGet(v, 'id')),
      label: jStr(jGet(v, 'label')),
      displayLabel: jStr(jGet(v, 'displayLabel')),
      categoryKey: jStr(jGet(v, 'categoryKey')),
      categoryLabel: jStr(jGet(v, 'categoryLabel')),
      categoryColor: jStr(jGet(v, 'categoryColor')),
      status: seatStatusOrNull(jGet(v, 'status')),
      price: jDouble(jGet(v, 'price')),
      currency: jStr(jGet(v, 'currency')),
      sectionLabel: jStr(jGet(v, 'sectionLabel')),
      rowLabel: jStr(jGet(v, 'rowLabel')),
      seatNumber: jStr(jGet(v, 'seatNumber')),
      rowType: jStr(jGet(v, 'rowType')),
      tiers: tiers == null ? null : jListOf(tiers, CategoryTier.fromJson),
      tierId: jStr(jGet(v, 'tierId')),
      commercial: SeatCommercialAttributes.fromJson(jGet(v, 'commercial')),
    );
  }
}

/// What `sys.ready` reports once the chart exists.
class ReadyInfo {
  const ReadyInfo({
    required this.protocolRevision,
    required this.mode,
    required this.transport,
    this.eventKey,
    this.timeToHelloMs,
    this.timeToReadyMs,
  });

  /// The negotiated protocol revision.
  final int protocolRevision;

  /// Whether the served event books real inventory.
  final EventMode mode;

  /// Which shim the bundle actually selected — confirm this is
  /// [TransportName.flutter].
  final TransportName transport;

  /// The event key the chart was built for.
  final String? eventKey;

  /// Milliseconds from arming the handshake to the runtime's `hello`.
  ///
  /// This isolates WebView creation, document fetch and bundle evaluation from
  /// the event/API work after `init`. Subtract it from [timeToReadyMs] for the
  /// `hello` → ready span. Null outside a live handshake.
  final int? timeToHelloMs;

  /// Milliseconds from the view arming the handshake to `sys.ready`.
  ///
  /// The whole cold path, end to end, up to the chart's first render. It is
  /// the number that decides whether a buyer thinks the app is broken.
  ///
  /// Nothing is logged with it. Report it to your own analytics if you want it;
  /// an SDK that prints timings into a host's console is a nuisance, and one
  /// that ships them somewhere is worse.
  ///
  /// `null` for a [ReadyInfo] not produced by a live handshake.
  final int? timeToReadyMs;

  factory ReadyInfo.fromJson(
    Object? payload, {
    int? timeToHelloMs,
    int? timeToReadyMs,
  }) =>
      ReadyInfo(
        protocolRevision:
            jInt(jGet(payload, 'protocol')) ?? seatLayerProtocolMin,
        mode: eventModeOrNull(jGet(payload, 'mode')) ?? EventMode.live,
        transport: transportNameOrNull(jGet(payload, 'transport')) ??
            const TransportNameUnknown(''),
        eventKey: jStr(jGet(jGet(payload, 'chart'), 'event')),
        timeToHelloMs: timeToHelloMs,
        timeToReadyMs: timeToReadyMs,
      );
}

/// Advertised by a runtime that reports the 2D panorama's own words instead of
/// drawing them, so a native host can print them on its own chrome.
///
/// Named here rather than beside the picker because both sides of the bridge
/// need it: the handshake reads it to decide what to suppress, and the picker
/// reads it to decide whether to draw.
const String seatLayerSeatViewChromeCapability = 'native-seat-view-chrome-v1';

/// What the bundle advertises in `hello`.
class BundleInfo {
  const BundleInfo({
    required this.bundle,
    required this.protocolRange,
    required this.capabilities,
    required this.events,
    required this.commands,
  });

  final String bundle;
  final ProtocolRange protocolRange;
  final List<String> capabilities;
  final List<String> events;
  final List<String> commands;

  factory BundleInfo.fromJson(Object? payload) => BundleInfo(
        bundle: jStr(jGet(payload, 'bundle')) ?? 'unknown',
        protocolRange: ProtocolRange.from(jGet(payload, 'protocol')) ??
            ProtocolRange.native,
        capabilities: jListOf(jGet(payload, 'capabilities'), (e) => jStr(e)),
        events: jListOf(jGet(payload, 'events'), (e) => jStr(e)),
        commands: jListOf(jGet(payload, 'commands'), (e) => jStr(e)),
      );

  /// Whether the bundle accepts a command, so the app can hide UI for
  /// capabilities an older bundle lacks instead of discovering
  /// `unsupported_command` at tap time.
  bool supportsCommand(String command) => commands.contains(command);
  bool supportsCapability(String capability) =>
      capabilities.contains(capability);
}

/// An event this build does not model — a bundle newer than the app. Delivered
/// raw so it can be logged rather than silently lost.
class UnknownEvent {
  const UnknownEvent({required this.name, this.payload});
  final String name;
  final Object? payload;
}
