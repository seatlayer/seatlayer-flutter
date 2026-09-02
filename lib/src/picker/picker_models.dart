import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../json.dart';
import '../open_enums.dart';
import '../payloads.dart';

/// The floor id that means "every floor at once".
///
/// Not a floor in the chart — the runtime's own sentinel for
/// `picker.setFloor`, named here so nothing has to spell it twice.
const String seatLayerAllFloors = 'all';

enum SeatLayerHoldOwner { picker, host }

enum SeatLayerPickerPhase { initializing, ready, unavailable, failed, closed }

enum SeatLayerPickerBusyAction {
  none,
  synchronizing,
  updatingSelection,
  findingBestAvailable,
  creatingHold,
  releasingHold,
  refreshingAccess,
  changingView,
}

enum SeatLayerPickerCloseReason {
  closeButton,
  systemBack,
  barrier,
  programmatic,
}

enum SeatLayerPickerLayoutMode { adaptive, compact, wide }

enum SeatLayerPickerPresentation { adaptive, fullScreen, dialog }

@immutable
class SeatLayerPickerEventDetails {
  const SeatLayerPickerEventDetails({
    required this.key,
    required this.name,
    required this.mode,
    required this.currency,
    this.venue,
    this.startsAt,
    this.timezone,
    this.locale,
    this.posterUrl,
    this.salesClosed = false,
  });

  final String key;
  final String name;
  final EventMode mode;
  final String currency;
  final String? venue;
  final double? startsAt;
  final String? timezone;
  final String? locale;
  final String? posterUrl;
  final bool salesClosed;

  static SeatLayerPickerEventDetails? fromJson(Object? value) {
    final key = jStr(jGet(value, 'key'));
    if (key == null) return null;
    return SeatLayerPickerEventDetails(
      key: key,
      name: jStr(jGet(value, 'name')) ?? key,
      mode: EventMode.fromRaw(jStr(jGet(value, 'mode')) ?? 'live'),
      currency: jStr(jGet(value, 'currency')) ?? 'USD',
      venue: jStr(jGet(value, 'venue')),
      startsAt: jDouble(jGet(value, 'startsAt')),
      timezone: jStr(jGet(value, 'timezone')),
      locale: jStr(jGet(value, 'locale')),
      posterUrl: jStr(jGet(value, 'posterUrl')),
      salesClosed: jBool(jGet(value, 'salesClosed')) ?? false,
    );
  }
}

@immutable
class SeatLayerPickerBranding {
  const SeatLayerPickerBranding({
    this.brandName,
    this.logoUrl,
    this.attributionRequired = true,
    this.accent,
    this.accentInk,
    this.background,
    this.surface,
    this.text,
    this.muted,
    this.line,
    this.fontFamily,
    this.radius,
  });

  final String? brandName;
  final String? logoUrl;
  final bool attributionRequired;
  final String? accent;
  final String? accentInk;
  final String? background;
  final String? surface;
  final String? text;
  final String? muted;
  final String? line;
  final String? fontFamily;
  final double? radius;

  factory SeatLayerPickerBranding.fromJson(Object? value) {
    final tokens = jGet(value, 'tokens');
    return SeatLayerPickerBranding(
      brandName: jStr(jGet(value, 'brandName')),
      logoUrl: jStr(jGet(value, 'logoUrl')),
      attributionRequired: jBool(jGet(value, 'attributionRequired')) ?? true,
      accent: jStr(jGet(value, 'accent')) ?? jStr(jGet(tokens, 'accent')),
      accentInk:
          jStr(jGet(value, 'accentInk')) ?? jStr(jGet(tokens, 'accentInk')),
      background:
          jStr(jGet(value, 'background')) ?? jStr(jGet(tokens, 'background')),
      surface: jStr(jGet(tokens, 'surface')),
      text: jStr(jGet(value, 'textColor')) ?? jStr(jGet(tokens, 'text')),
      muted: jStr(jGet(tokens, 'muted')),
      line: jStr(jGet(tokens, 'line')),
      fontFamily: jStr(jGet(tokens, 'fontFamily')),
      radius: jDouble(jGet(tokens, 'radius')),
    );
  }
}

@immutable
class SeatLayerPickerCategory {
  const SeatLayerPickerCategory({
    required this.key,
    required this.label,
    required this.color,
    required this.priceMin,
    required this.priceMax,
    required this.available,
    required this.notForSale,
    required this.tiers,
    this.free,
  });

  final String key;
  final String label;
  final String color;
  final double priceMin;
  final double priceMax;
  final int available;
  final bool notForSale;
  final List<CategoryTier> tiers;

  /// Seats still free in this category on live inventory, or null when the
  /// runtime has not said.
  ///
  /// Sent by a runtime that advertises `category-availability-v1`, and
  /// refreshed on every availability push. Unlike [available], which reads
  /// zero before counts arrive, an absent value here means unknown and a
  /// zero means sold out — so this is the number to print.
  final int? free;

  static SeatLayerPickerCategory? fromJson(Object? value) {
    final key = jStr(jGet(value, 'key'));
    if (key == null) return null;
    final tiers = List<CategoryTier>.unmodifiable(
      jListOf(jGet(value, 'tiers'), CategoryTier.fromJson),
    );
    final base = jDouble(jGet(value, 'price')) ??
        (tiers.isEmpty ? 0 : tiers.first.price);
    return SeatLayerPickerCategory(
      key: key,
      label: jStr(jGet(value, 'label')) ?? key,
      color: jStr(jGet(value, 'color')) ?? '#6e7bff',
      priceMin: jDouble(jGet(value, 'priceMin')) ??
          (tiers.isEmpty
              ? base
              : tiers
                  .map((tier) => tier.price)
                  .reduce((a, b) => a < b ? a : b)),
      priceMax: jDouble(jGet(value, 'priceMax')) ??
          (tiers.isEmpty
              ? base
              : tiers
                  .map((tier) => tier.price)
                  .reduce((a, b) => a > b ? a : b)),
      available: jInt(jGet(value, 'available')) ?? 0,
      notForSale: jBool(jGet(value, 'notForSale')) ?? false,
      tiers: tiers,
      free: jInt(jGet(value, 'free')),
    );
  }
}

@immutable
class SeatLayerPickerSectionSummary {
  const SeatLayerPickerSectionSummary({
    required this.id,
    required this.label,
    this.displayLabel,
    this.zoneId,
    this.zoneLabel,
    this.entrance,
    this.color,
    this.dominantCategoryKey,
    this.seatsLeft,
    this.priceMin,
    this.priceMax,
  });

  final String id;
  final String label;
  final String? displayLabel;
  final String? zoneId;
  final String? zoneLabel;
  final String? entrance;
  final String? color;

  /// The category most of this section's free seats belong to.
  ///
  /// Prefer it over [color] when the host paints its own dot: the key survives
  /// a colourblind-safe palette, a category recolour and a legend that has
  /// already resolved the same colour, where a copied hex does not. Absent on
  /// a section with nothing free to be dominant.
  final String? dominantCategoryKey;

  final int? seatsLeft;
  final double? priceMin;
  final double? priceMax;

  static SeatLayerPickerSectionSummary? fromJson(Object? value) {
    final id = jStr(jGet(value, 'id'));
    if (id == null) return null;
    return SeatLayerPickerSectionSummary(
      id: id,
      label: jStr(jGet(value, 'label')) ?? id,
      displayLabel: jStr(jGet(value, 'displayLabel')),
      zoneId: jStr(jGet(value, 'zoneId')),
      zoneLabel: jStr(jGet(value, 'zoneLabel')),
      entrance: jStr(jGet(value, 'entrance')),
      color: jStr(jGet(value, 'color')),
      dominantCategoryKey: jStr(jGet(value, 'dominantCategoryKey')),
      seatsLeft: jInt(jGet(value, 'seatsLeft')),
      priceMin: jDouble(jGet(value, 'priceMin')),
      priceMax: jDouble(jGet(value, 'priceMax')),
    );
  }
}

@immutable
class SeatLayerPickerZone {
  const SeatLayerPickerZone({
    required this.id,
    required this.label,
    this.color,
  });

  final String id;
  final String label;
  final String? color;

  static SeatLayerPickerZone? fromJson(Object? value) {
    final id = jStr(jGet(value, 'id'));
    if (id == null) return null;
    return SeatLayerPickerZone(
      id: id,
      label: jStr(jGet(value, 'label')) ?? id,
      color: jStr(jGet(value, 'color')),
    );
  }
}

@immutable
class SeatLayerCheckoutLineItem {
  const SeatLayerCheckoutLineItem({
    required this.lineKey,
    required this.label,
    required this.objectId,
    required this.objectType,
    required this.categoryKey,
    required this.unitPrice,
    required this.currency,
    required this.quantity,
    this.displayLabel,
    this.displayType,
    this.tierId,
    this.seatId,
    this.sectionLabel,
    this.rowLabel,
    this.seatNumber,
  });

  final String lineKey;
  final String label;
  final String? displayLabel;
  final String? displayType;
  final String objectId;
  final ObjectType objectType;
  final String categoryKey;
  final String? tierId;
  final double unitPrice;
  final String currency;
  final int quantity;

  /// The renderer's own id for the seat this line stands for.
  ///
  /// Present whenever the runtime knew which seat the line is, which is the
  /// reliable way to join a line back to the selection: an inventory label is
  /// the primary key but it is not always what the line arrived under.
  final String? seatId;

  /// Where the seat is — `Stalls D`. Absent for a general-admission unit,
  /// which has no seat.
  final String? sectionLabel;

  /// The seat's row — `C`. May be authored fully qualified (`Stalls D C`);
  /// print it through `pickerRowLabel` rather than raw.
  final String? rowLabel;

  /// The seat's number in its row — `6`.
  final String? seatNumber;

  /// Whether the runtime named this line's seat on the line itself.
  ///
  /// Best Available clears the renderer selection before it holds, and a
  /// resumed hold was never in one, so joining back to `selection` finds
  /// nothing for exactly the two paths where the buyer did not tap the seat.
  /// The address travels on the line for those.
  bool get hasSeatIdentity =>
      (sectionLabel?.trim().isNotEmpty ?? false) ||
      (rowLabel?.trim().isNotEmpty ?? false) ||
      (seatNumber?.trim().isNotEmpty ?? false);

  String get buyerFacingLabel => displayLabel ?? label;
  double get total => unitPrice * quantity;

  static SeatLayerCheckoutLineItem? fromJson(Object? value) {
    final label = jStr(jGet(value, 'label'));
    if (label == null) return null;
    return SeatLayerCheckoutLineItem(
      lineKey: jStr(jGet(value, 'lineKey')) ??
          jStr(jGet(value, 'key')) ??
          jStr(jGet(value, 'objectId')) ??
          label,
      label: label,
      displayLabel: jStr(jGet(value, 'displayLabel')),
      displayType: jStr(jGet(value, 'displayType')),
      objectId: jStr(jGet(value, 'objectId')) ?? label,
      objectType: ObjectType.fromRaw(jStr(jGet(value, 'objectType')) ?? 'seat'),
      categoryKey: jStr(jGet(value, 'categoryKey')) ?? '',
      tierId: jStr(jGet(value, 'tierId')),
      unitPrice: jDouble(jGet(value, 'unitPrice')) ?? 0,
      currency: jStr(jGet(value, 'currency')) ?? 'USD',
      quantity: jInt(jGet(value, 'quantity')) ?? 1,
      seatId: jStr(jGet(value, 'seatId')),
      sectionLabel: jStr(jGet(value, 'sectionLabel')),
      rowLabel: jStr(jGet(value, 'rowLabel')),
      seatNumber: jStr(jGet(value, 'seatNumber')),
    );
  }

  HoldLineItem toHoldLineItem() => HoldLineItem(
        label: label,
        objectId: objectId,
        objectType: objectType,
        categoryKey: categoryKey,
        tierId: tierId,
        unitPrice: unitPrice,
        currency: currency,
        quantity: quantity,
      );
}

@immutable
class SeatLayerCheckoutHandoff {
  const SeatLayerCheckoutHandoff({
    required this.holdId,
    required this.expiresAt,
    required this.currency,
    required this.lineItems,
    required this.total,
  });

  final String holdId;
  final double expiresAt;
  final String currency;
  final List<SeatLayerCheckoutLineItem> lineItems;
  final double total;

  DateTime get expiryDate =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt.round());

  static SeatLayerCheckoutHandoff? fromJson(Object? value) {
    final holdId = jStr(jGet(value, 'holdId'));
    final expiresAt = jDouble(jGet(value, 'expiresAt'));
    if (holdId == null || expiresAt == null) return null;
    final lines = List<SeatLayerCheckoutLineItem>.unmodifiable(
      jListOf(jGet(value, 'lineItems'), SeatLayerCheckoutLineItem.fromJson),
    );
    return SeatLayerCheckoutHandoff(
      holdId: holdId,
      expiresAt: expiresAt,
      currency: jStr(jGet(value, 'currency')) ??
          (lines.isEmpty ? 'USD' : lines.first.currency),
      lineItems: lines,
      total: jDouble(jGet(value, 'total')) ??
          lines.fold<double>(0, (sum, line) => sum + line.total),
    );
  }
}

/// Token-free hold state exposed while the buyer remains inside the picker.
///
/// The hold id is intentionally delivered only by [SeatLayerCheckoutHandoff]
/// at the checkout ownership boundary; ordinary snapshots never expose that
/// booking capability.
@immutable
class SeatLayerPickerHold {
  const SeatLayerPickerHold({
    required this.active,
    required this.owner,
    this.expiresAt,
  });

  final bool active;
  final double? expiresAt;
  final SeatLayerHoldOwner? owner;

  DateTime? get expiryDate => expiresAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(expiresAt!.round());

  factory SeatLayerPickerHold.fromJson(Object? value) {
    final ownership = jStr(jGet(value, 'ownership'));
    return SeatLayerPickerHold(
      active: jBool(jGet(value, 'active')) ?? false,
      expiresAt: jDouble(jGet(value, 'expiresAt')),
      owner: ownership == 'picker'
          ? SeatLayerHoldOwner.picker
          : ownership == 'host'
              ? SeatLayerHoldOwner.host
              : null,
    );
  }
}

/// How much of the map surface the host's own chrome is covering.
///
/// The runtime frames the venue — `zoomToFit`, a focused section, the glide
/// that follows a tap, a best-available result — against the whole map
/// rectangle. Native chrome drawn over that rectangle therefore covers a
/// perfectly framed venue. These insets shrink the rectangle the camera aims
/// at without clipping anything: the map still draws and pans underneath the
/// chrome, so nothing is hidden that the buyer cannot reach.
///
/// Every side is in the same logical points Flutter lays out in, which is what
/// the venue map reads as a CSS pixel.
@immutable
class SeatLayerViewportInsets {
  /// Creates a set of insets; every omitted side is zero.
  const SeatLayerViewportInsets({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  /// No chrome over the map.
  static const SeatLayerViewportInsets zero = SeatLayerViewportInsets();

  /// Height of the chrome covering the top of the map.
  final double top;

  /// Width of the chrome covering the right of the map.
  final double right;

  /// Height of the chrome covering the bottom of the map.
  final double bottom;

  /// Width of the chrome covering the left of the map.
  final double left;

  /// Whether every side is zero.
  bool get isEmpty => top == 0 && right == 0 && bottom == 0 && left == 0;

  /// The payload `picker.setViewportInsets` accepts.
  ///
  /// Negative and non-finite sides are floored to zero rather than sent: the
  /// runtime answers `bad_payload` for them, and a mis-measured piece of
  /// chrome must not fail an action the buyer started.
  Map<String, Object?> toBridgePayload() => <String, Object?>{
        'top': _wire(top),
        'right': _wire(right),
        'bottom': _wire(bottom),
        'left': _wire(left),
      };

  static double _wire(double value) =>
      value.isFinite && value > 0 ? value : 0.0;

  static SeatLayerViewportInsets? fromJson(Object? value) {
    if (jObj(value) == null) return null;
    double side(String key) => _wire(jDouble(jGet(value, key)) ?? 0);
    return SeatLayerViewportInsets(
      top: side('top'),
      right: side('right'),
      bottom: side('bottom'),
      left: side('left'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SeatLayerViewportInsets &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom &&
      other.left == left;

  @override
  int get hashCode => Object.hash(top, right, bottom, left);

  @override
  String toString() =>
      'SeatLayerViewportInsets(top: $top, right: $right, bottom: $bottom, '
      'left: $left)';
}

/// One access need this event's chart actually offers, and how many free seats
/// currently match it.
///
/// Reported only by a runtime advertising `access-needs-v1`. A need whose seats
/// are all taken is still listed, with a [count] of zero — "this venue has no
/// step-free seats" and "its step-free seats are gone" are different facts, and
/// a filter chip that simply vanished would tell the buyer the first when the
/// truth was the second.
@immutable
class SeatLayerAccessNeed {
  /// Creates one offered access need.
  const SeatLayerAccessNeed({required this.key, required this.count});

  /// The runtime's wire key, for example `wheelchair` or `step-free`.
  ///
  /// Named through [SeatLayerPickerStrings.accessNeeds]; a key that table has
  /// no name for is drawn under this key rather than dropped.
  final String key;

  /// How many free seats match this need right now.
  final int count;

  /// Whether any seat is still available under this need.
  bool get isAvailable => count > 0;

  /// Decode one `{ key, count }` entry, or null if it names nothing.
  static SeatLayerAccessNeed? fromJson(Object? value) {
    final key = jStr(jGet(value, 'key'));
    if (key == null || key.isEmpty) return null;
    final count = jInt(jGet(value, 'count')) ?? 0;
    return SeatLayerAccessNeed(key: key, count: count < 0 ? 0 : count);
  }

  @override
  bool operator ==(Object other) =>
      other is SeatLayerAccessNeed && other.key == key && other.count == count;

  @override
  int get hashCode => Object.hash(key, count);

  @override
  String toString() => 'SeatLayerAccessNeed($key: $count)';
}

@immutable
class SeatLayerPickerMapState {
  const SeatLayerPickerMapState({
    required this.rung,
    required this.viewMode,
    required this.buyerView,
    required this.view3DNavigationMode,
    required this.colorblindSafe,
    required this.hideLimitedView,
    required this.canZoomIn,
    required this.canZoomOut,
    required this.categoryFilter,
    required this.accessibilityFilter,
    required this.floors,
    this.accessNeeds = const <SeatLayerAccessNeed>[],
    this.activeFloorId,
    this.floorMode,
    this.floorLabelStyle,
    this.focusedSectionId,
    this.focusedSection,
    this.view3DTargetSeatId,
    this.view3DTargetSeat,
    this.view3DPreviousSeatId,
    this.view3DNextSeatId,
    this.view3DFocusedSectionId,
    this.reportsView3DPosition = false,
    this.viewportInsets,
  });

  final String rung;
  final String viewMode;
  final SeatLayerBuyerView buyerView;
  final SeatLayer3DNavigationMode view3DNavigationMode;
  final String? view3DTargetSeatId;

  /// Buyer-display identity for the seat under the 3D camera, selected or not.
  final SelectedSeat? view3DTargetSeat;

  /// Same-row neighbours in authored inventory order.
  final String? view3DPreviousSeatId;
  final String? view3DNextSeatId;

  /// The section framed by the 3D scene, separate from the 2D map focus.
  final String? view3DFocusedSectionId;

  /// Whether the runtime reports the explicit 3D target/neighbour contract.
  ///
  /// Null is a valid boundary value for a neighbour, so the SDK must retain
  /// the difference between an old runtime that omitted the fields and a new
  /// runtime saying there is no seat in that direction.
  final bool reportsView3DPosition;
  final String? activeFloorId;
  final String? focusedSectionId;
  final SeatLayerPickerSectionSummary? focusedSection;
  final bool colorblindSafe;
  final bool hideLimitedView;
  final bool canZoomIn;
  final bool canZoomOut;
  final Set<String> categoryFilter;
  final Set<String> accessibilityFilter;
  final List<FloorInfo> floors;

  /// The access needs this event's chart offers, in the runtime's own order.
  ///
  /// Empty when the runtime reports that this chart offers no access need, or
  /// when an older runtime does not advertise `access-needs-v1`. Chrome fails
  /// closed in both cases instead of inventing filters that empty the map.
  final List<SeatLayerAccessNeed> accessNeeds;

  /// Whether the runtime is drawing every floor or just [activeFloorId].
  ///
  /// `'all'` or `'single'`, and null on a runtime that does not report it —
  /// which is how the floor chrome knows whether an "all floors" choice
  /// exists at all rather than guessing one into being.
  final String? floorMode;

  /// What the runtime is currently framing against, echoed back.
  ///
  /// Null on a runtime that predates the command, which frames against the
  /// whole surface. A host can compare this with what it last sent to tell a
  /// dropped command from an applied one without a round trip.
  final SeatLayerViewportInsets? viewportInsets;

  String get projection => viewMode;
  String? get floorId => activeFloorId;

  /// Whether every floor is drawn at once.
  bool get showsAllFloors => floorMode == 'all';

  /// How the runtime marks a level in the stacked whole-venue view.
  ///
  /// `'number'` (the default) prints a `G` / `1` / `2` badge; `'name'` prints
  /// the authored floor name. Null on a runtime that does not report it. The
  /// native strip always prints names — this is here so a host drawing its own
  /// can match what the map is showing.
  final String? floorLabelStyle;

  /// Whether this runtime lets the buyer choose between one floor and all.
  ///
  /// The mode alone; `SeatLayerPickerController.supportsFloorStack` is the
  /// other half of the gate, and chrome offering the choice needs both.
  bool get hasFloorModes => floorMode != null;
  bool get isVenue3D => buyerView == SeatLayerBuyerView.venue3D;

  factory SeatLayerPickerMapState.fromJson(Object? value) =>
      SeatLayerPickerMapState(
        rung: jStr(jGet(value, 'rung')) ?? 'overview',
        viewMode: jStr(jGet(value, 'viewMode')) ??
            jStr(jGet(value, 'projection')) ??
            'flat',
        buyerView: SeatLayerBuyerView.fromRaw(
          jStr(jGet(value, 'buyerView')) ?? 'map',
        ),
        view3DNavigationMode: SeatLayer3DNavigationMode.fromRaw(
          jStr(jGet(value, 'view3dNavigationMode')) ?? 'orbit',
        ),
        view3DTargetSeatId: jStr(jGet(value, 'view3dTargetSeatId')),
        view3DTargetSeat: SelectedSeat.fromJson(
          jGet(value, 'view3dTargetSeat'),
        ),
        view3DPreviousSeatId: jStr(jGet(value, 'view3dPreviousSeatId')),
        view3DNextSeatId: jStr(jGet(value, 'view3dNextSeatId')),
        view3DFocusedSectionId: jStr(jGet(value, 'view3dFocusedSectionId')),
        reportsView3DPosition: <String>[
          'view3dPreviousSeatId',
          'view3dNextSeatId',
          'view3dFocusedSectionId',
        ].any((key) => jObj(value)?.containsKey(key) ?? false),
        activeFloorId:
            jStr(jGet(value, 'activeFloorId')) ?? jStr(jGet(value, 'floorId')),
        focusedSectionId: jStr(jGet(value, 'focusedSectionId')),
        focusedSection: SeatLayerPickerSectionSummary.fromJson(
          jGet(value, 'focusedSection'),
        ),
        colorblindSafe: jBool(jGet(value, 'colorblindSafe')) ?? false,
        hideLimitedView: jBool(jGet(value, 'hideLimitedView')) ?? false,
        canZoomIn: jBool(jGet(value, 'canZoomIn')) ?? true,
        canZoomOut: jBool(jGet(value, 'canZoomOut')) ?? true,
        categoryFilter: Set<String>.unmodifiable(
          jListOf(jGet(value, 'categoryFilter'), (item) => jStr(item)),
        ),
        accessibilityFilter: Set<String>.unmodifiable(
          jListOf(jGet(value, 'accessibilityFilter'), (item) => jStr(item)),
        ),
        floors: List<FloorInfo>.unmodifiable(
          jListOf(jGet(value, 'floors'), FloorInfo.fromJson),
        ),
        accessNeeds: List<SeatLayerAccessNeed>.unmodifiable(
          jListOf(jGet(value, 'accessNeeds'), SeatLayerAccessNeed.fromJson),
        ),
        floorMode: jStr(jGet(value, 'floorMode')),
        floorLabelStyle: jStr(jGet(value, 'floorLabelStyle')),
        viewportInsets: SeatLayerViewportInsets.fromJson(
          jGet(value, 'viewportInsets'),
        ),
      );
}

@immutable
class SeatLayerPickerSnapshot {
  static const String currentSchema = 'seatlayer.picker.snapshot/1';

  const SeatLayerPickerSnapshot({
    required this.schema,
    required this.sessionId,
    required this.revision,
    required this.event,
    required this.branding,
    required this.categories,
    required this.zones,
    required this.sections,
    required this.generalAdmissionAreas,
    required this.bestAvailableZones,
    required this.map,
    required this.selection,
    required this.selectionValidity,
    required this.maxSelection,
    required this.ticketCount,
    required this.cartLines,
    required this.cartTotal,
    required this.currency,
    required this.hold,
    required this.accessConfigured,
    required this.accessStatus,
    required this.capabilities,
    this.accessReason,
  });

  final String schema;
  final String sessionId;
  final int revision;
  final SeatLayerPickerEventDetails event;
  final SeatLayerPickerBranding branding;
  final List<SeatLayerPickerCategory> categories;
  final List<SeatLayerPickerZone> zones;
  final List<SeatLayerPickerSectionSummary> sections;
  final List<GAArea> generalAdmissionAreas;
  final List<SeatLayerPickerZone> bestAvailableZones;
  final SeatLayerPickerMapState map;
  final List<SelectedSeat> selection;
  final SelectionValidity? selectionValidity;
  final int maxSelection;
  final int ticketCount;
  final List<SeatLayerCheckoutLineItem> cartLines;
  final double cartTotal;
  final String currency;
  final SeatLayerPickerHold hold;
  final bool accessConfigured;
  final String accessStatus;
  final String? accessReason;
  final Set<String> capabilities;

  List<FloorInfo> get floors => map.floors;
  SeatLayerHoldOwner? get holdOwner => hold.owner;

  static SeatLayerPickerSnapshot? fromJson(Object? value) {
    final schema = jStr(jGet(value, 'schema'));
    final sessionId = jStr(jGet(value, 'sessionId'));
    final revision = jInt(jGet(value, 'revision'));
    final event = SeatLayerPickerEventDetails.fromJson(jGet(value, 'event'));
    if (schema != currentSchema ||
        sessionId == null ||
        revision == null ||
        event == null) {
      return null;
    }

    final catalog = jGet(value, 'catalog');
    final selectionNode = jGet(value, 'selection');
    final cart = jGet(value, 'cart');
    final holdNode = jGet(value, 'hold');
    final access = jGet(value, 'access');
    final lines = List<SeatLayerCheckoutLineItem>.unmodifiable(
      jListOf(
        jGet(cart, 'items') ?? jGet(cart, 'lines'),
        SeatLayerCheckoutLineItem.fromJson,
      ),
    );
    final selected = List<SelectedSeat>.unmodifiable(
      jListOf(jGet(selectionNode, 'seats'), SelectedSeat.fromJson),
    );

    return SeatLayerPickerSnapshot(
      schema: schema!,
      sessionId: sessionId,
      revision: revision,
      event: event,
      branding: SeatLayerPickerBranding.fromJson(jGet(value, 'branding')),
      categories: List<SeatLayerPickerCategory>.unmodifiable(
        jListOf(jGet(catalog, 'categories'), SeatLayerPickerCategory.fromJson),
      ),
      zones: List<SeatLayerPickerZone>.unmodifiable(
        jListOf(jGet(catalog, 'zones'), SeatLayerPickerZone.fromJson),
      ),
      sections: List<SeatLayerPickerSectionSummary>.unmodifiable(
        jListOf(
          jGet(catalog, 'sections'),
          SeatLayerPickerSectionSummary.fromJson,
        ),
      ),
      generalAdmissionAreas: List<GAArea>.unmodifiable(
        jListOf(jGet(catalog, 'gaAreas'), GAArea.fromJson),
      ),
      bestAvailableZones: List<SeatLayerPickerZone>.unmodifiable(
        jListOf(
          jGet(catalog, 'bestAvailableZones'),
          SeatLayerPickerZone.fromJson,
        ),
      ),
      map: SeatLayerPickerMapState.fromJson(jGet(value, 'map')),
      selection: selected,
      selectionValidity: SelectionValidity.fromJson(
        jGet(selectionNode, 'validity'),
      ),
      maxSelection: jInt(jGet(selectionNode, 'maxSelection')) ?? 10,
      ticketCount: jInt(jGet(cart, 'quantity')) ?? selected.length,
      cartLines: lines,
      cartTotal: jDouble(jGet(cart, 'total')) ??
          lines.fold<double>(0, (sum, line) => sum + line.total),
      currency: jStr(jGet(cart, 'currency')) ?? event.currency,
      hold: SeatLayerPickerHold.fromJson(holdNode),
      accessConfigured: jBool(jGet(access, 'configured')) ?? false,
      accessStatus: jStr(jGet(access, 'status')) ?? 'public',
      accessReason: jStr(jGet(access, 'reason')),
      capabilities: Set<String>.unmodifiable(
        _enabledCapabilities(jGet(value, 'features')),
      ),
    );
  }
}

Set<String> _enabledCapabilities(Object? value) {
  final fields = jObj(value);
  if (fields == null) return const <String>{};
  final out = <String>{};
  for (final entry in fields.entries) {
    if (entry.value == true) out.add(entry.key);
    if (entry.value is List && (entry.value as List).isNotEmpty) {
      out.add(entry.key);
    }
  }
  return out;
}

@immutable
class SeatLayerPickerState {
  const SeatLayerPickerState({
    required this.phase,
    required this.busyAction,
    this.snapshot,
    this.checkoutHandoff,
    this.generalAdmissionCandidate,
    this.error,
    this.holdLapsed = false,
    this.mapFramed = false,
  });

  const SeatLayerPickerState.initializing()
      : phase = SeatLayerPickerPhase.initializing,
        busyAction = SeatLayerPickerBusyAction.none,
        snapshot = null,
        checkoutHandoff = null,
        generalAdmissionCandidate = null,
        error = null,
        holdLapsed = false,
        mapFramed = false;

  final SeatLayerPickerPhase phase;
  final SeatLayerPickerBusyAction busyAction;
  final SeatLayerPickerSnapshot? snapshot;
  final SeatLayerCheckoutHandoff? checkoutHandoff;
  final GAArea? generalAdmissionCandidate;
  final Object? error;

  /// Whether the last availability read found the buyer's own hold gone.
  ///
  /// The snapshot in hand may still describe a live hold — it was read before
  /// the reconciliation that condemned it, or the runtime has not pushed the
  /// cleared one yet — and a countdown running off THAT is the whole defect
  /// this flag closes: a dead hold with a live clock, discovered at checkout.
  /// While it is set [hold] answers null, so nothing downstream can tick.
  final bool holdLapsed;

  /// Whether the runtime has framed the map inside the chrome standing on it.
  ///
  /// False until the first viewport-inset report lands after the picker is
  /// ready. The first snapshot arrives before the renderer has been told what
  /// the native chrome covers, so a map revealed on that snapshot alone is
  /// shown in one frame and re-fitted in the next — which a buyer reads as the
  /// screen loading twice. Presentation only: nothing waits on this, and the
  /// picker is fully ready and callable while it is still false.
  final bool mapFramed;

  int get revision => snapshot?.revision ?? 0;
  String? get sessionId => snapshot?.sessionId;
  SeatLayerPickerEventDetails? get event => snapshot?.event;
  SeatLayerPickerBranding? get branding => snapshot?.branding;
  List<SeatLayerPickerCategory> get categories =>
      snapshot?.categories ?? const <SeatLayerPickerCategory>[];
  List<SelectedSeat> get selection =>
      snapshot?.selection ?? const <SelectedSeat>[];
  List<SeatLayerCheckoutLineItem> get cartLines =>
      snapshot?.cartLines ?? const <SeatLayerCheckoutLineItem>[];
  SeatLayerPickerHold? get hold =>
      !holdLapsed && snapshot?.hold.active == true ? snapshot!.hold : null;
  SeatLayerHoldOwner? get holdOwner => snapshot?.holdOwner;
  bool get isReady => phase == SeatLayerPickerPhase.ready;
  bool get isBusy => busyAction != SeatLayerPickerBusyAction.none;
  bool get isTestEvent => event?.mode == EventMode.test;
  bool get hasPickerOwnedHold =>
      hold != null && holdOwner == SeatLayerHoldOwner.picker;
  bool get hasHostOwnedHold =>
      hold != null && holdOwner == SeatLayerHoldOwner.host;
  bool get canMutateInventory => !hasHostOwnedHold;
  bool get canCheckout =>
      isReady &&
      !isBusy &&
      event?.salesClosed != true &&
      (snapshot?.ticketCount ?? 0) > 0 &&
      (snapshot?.selectionValidity?.isValid ?? true);

  Duration holdRemaining(DateTime now) {
    final current = hold;
    if (current == null) return Duration.zero;
    final expiry = current.expiryDate;
    if (expiry == null) return Duration.zero;
    final remaining = expiry.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  SeatLayerPickerState applying(SeatLayerPickerSnapshot next) =>
      SeatLayerPickerState(
        phase:
            next.accessStatus == 'unavailable' || next.accessStatus == 'expired'
                ? SeatLayerPickerPhase.unavailable
                : SeatLayerPickerPhase.ready,
        busyAction: SeatLayerPickerBusyAction.none,
        snapshot: next,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
      );

  SeatLayerPickerState withBusy(SeatLayerPickerBusyAction action) =>
      SeatLayerPickerState(
        phase: phase,
        busyAction: action,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        holdLapsed: holdLapsed,
      );

  SeatLayerPickerState withError(Object next) => SeatLayerPickerState(
        phase: SeatLayerPickerPhase.failed,
        busyAction: SeatLayerPickerBusyAction.none,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        error: next,
        holdLapsed: holdLapsed,
      );

  SeatLayerPickerState withActionError(Object next) => SeatLayerPickerState(
        phase: snapshot == null ? SeatLayerPickerPhase.failed : phase,
        busyAction: SeatLayerPickerBusyAction.none,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        error: next,
        holdLapsed: holdLapsed,
      );

  SeatLayerPickerState withGeneralAdmissionCandidate(GAArea? area) =>
      SeatLayerPickerState(
        phase: phase,
        busyAction: busyAction,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: area,
        mapFramed: mapFramed,
        error: error,
        holdLapsed: holdLapsed,
      );

  SeatLayerPickerState withoutError() => SeatLayerPickerState(
        phase: phase,
        busyAction: busyAction,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        holdLapsed: holdLapsed,
      );

  SeatLayerPickerState withHandoff(SeatLayerCheckoutHandoff handoff) =>
      SeatLayerPickerState(
        phase: phase,
        busyAction: SeatLayerPickerBusyAction.none,
        snapshot: snapshot,
        checkoutHandoff: handoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        holdLapsed: holdLapsed,
      );

  SeatLayerPickerState withoutHandoff() => SeatLayerPickerState(
        phase: phase,
        busyAction: SeatLayerPickerBusyAction.none,
        snapshot: snapshot,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        error: error,
        holdLapsed: holdLapsed,
      );

  /// The same state with the buyer's hold condemned.
  ///
  /// Applied the moment a refresh reports `holdLapsed`, so the countdown pill
  /// stops on the same frame the buyer is told — rather than on whenever the
  /// runtime's next snapshot happens to arrive.
  SeatLayerPickerState withLapsedHold() => SeatLayerPickerState(
        phase: phase,
        busyAction: busyAction,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        error: error,
        holdLapsed: true,
      );

  /// The same state, with the map now framed inside the native chrome.
  ///
  /// One way only, until the runtime is reloaded and the state starts again
  /// from [SeatLayerPickerState.initializing].
  SeatLayerPickerState withMapFramed() => SeatLayerPickerState(
        phase: phase,
        busyAction: busyAction,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        error: error,
        holdLapsed: holdLapsed,
        mapFramed: true,
      );

  SeatLayerPickerState closed() => SeatLayerPickerState(
        phase: SeatLayerPickerPhase.closed,
        busyAction: SeatLayerPickerBusyAction.none,
        snapshot: snapshot,
        checkoutHandoff: checkoutHandoff,
        generalAdmissionCandidate: generalAdmissionCandidate,
        mapFramed: mapFramed,
        holdLapsed: holdLapsed,
      );
}

/// Read-only convenience view for hosts that prefer map semantics.
UnmodifiableListView<SeatLayerCheckoutLineItem> checkoutLinesOf(
  SeatLayerPickerState state,
) =>
    UnmodifiableListView(state.cartLines);

/// What the runtime's 2D "View from here" panorama is currently showing.
///
/// Arrives as `evt seatView.changed`, and arrives **whether or not the web is
/// drawing those words**: suppressing the panorama's own header, caption and
/// badge would otherwise leave a host with a rule to re-derive rather than a
/// string to print, and the disclosure rules are not something two codebases
/// should each keep a copy of.
///
/// Every string is already in the picker's active language, and arrives again
/// after a live language switch.
@immutable
class SeatLayerSeatView {
  /// Creates a seat-view description.
  const SeatLayerSeatView({
    this.seatId,
    this.title,
    this.caption,
    this.badge,
    this.real = false,
    this.generated = false,
    this.dragHint,
  });

  /// The renderer's seat id the panorama was opened for.
  final String? seatId;

  /// The header line — "View from Stalls D · C-6".
  final String? title;

  /// The disclosure caption — "Illustration · about 18 m from stage".
  final String? caption;

  /// The already-localized disclosure word — "Real 360°" or "Preview".
  final String? badge;

  /// Whether this is an AUTHORED capture of the actual seat.
  ///
  /// False for a view the engine drew out of the venue's geometry. This is the
  /// distinction [badge] puts into words; read it rather than matching on the
  /// word, which is translated.
  final bool real;

  /// Whether the image was synthesised rather than fetched.
  final bool generated;

  /// How to move the picture — "Drag to look around · pinch or scroll to zoom".
  final String? dragHint;

  /// Whether there is anything here worth drawing chrome for.
  bool get hasContent =>
      (title?.trim().isNotEmpty ?? false) ||
      (caption?.trim().isNotEmpty ?? false) ||
      (badge?.trim().isNotEmpty ?? false);

  /// Decode `p.seatView`; null both for a closed panorama and for a payload
  /// that is not an object, which are the same thing to a host.
  static SeatLayerSeatView? fromJson(Object? value) {
    if (jObj(value) == null) return null;
    return SeatLayerSeatView(
      seatId: jStr(jGet(value, 'seatId')),
      title: jStr(jGet(value, 'title')),
      caption: jStr(jGet(value, 'caption')),
      badge: jStr(jGet(value, 'badge')),
      real: jBool(jGet(value, 'real')) ?? false,
      generated: jBool(jGet(value, 'generated')) ?? false,
      dragHint: jStr(jGet(value, 'dragHint')),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SeatLayerSeatView &&
      other.seatId == seatId &&
      other.title == title &&
      other.caption == caption &&
      other.badge == badge &&
      other.real == real &&
      other.generated == generated &&
      other.dragHint == dragHint;

  @override
  int get hashCode =>
      Object.hash(seatId, title, caption, badge, real, generated, dragHint);

  @override
  String toString() => 'SeatLayerSeatView($seatId, $badge)';
}

/// Whether two selections name the same seats on the same tiers.
///
/// Identity and tier only: a snapshot repeats the whole selection on every
/// revision, and comparing the objects would report a change every time the
/// runtime re-serialised seats nothing had happened to.
bool pickerSameSelection(List<SelectedSeat> left, List<SelectedSeat> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i].id != right[i].id || left[i].tierId != right[i].tierId) {
      return false;
    }
  }
  return true;
}

/// Whether two validity reports say the same thing.
bool pickerSameValidity(SelectionValidity? left, SelectionValidity? right) =>
    left?.isValid == right?.isValid &&
    left?.count == right?.count &&
    left?.required == right?.required &&
    left?.remaining == right?.remaining;
