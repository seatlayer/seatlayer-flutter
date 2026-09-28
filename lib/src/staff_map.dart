import 'dart:async';

/// The renderer capability that runs the staff map.
///
/// The view checks it during the handshake; a renderer without it fails the
/// load with `SeatLayerError.incompatible` rather than showing a buyer map.
const String seatLayerStaffMapCapability = 'staff-map-v1';

/// An event-scoped manage grant for the staff map.
///
/// Your backend mints it for one event with the `event:view` capability and
/// `seatLayerMobileOrigin` (`https://cdn.seatlayer.io`) as its allowed origin,
/// the origin the map runs on.
/// A grant is short-lived: supply a [ManageAccessTokenProvider] so the map
/// can renew it without reloading.
class ManageAccessToken {
  const ManageAccessToken({required this.token, this.expiresAt});

  /// The grant, `mse_…`.
  final String token;

  /// Epoch milliseconds. Omit to renew reactively.
  final double? expiresAt;

  /// Whether this looks like a manage grant: an `mse_` prefix and a finite
  /// expiry when one is given.
  bool get isWellFormed =>
      RegExp(r'^mse_[A-Za-z0-9]+$').hasMatch(token) &&
      (expiresAt == null || expiresAt!.isFinite);

  Map<String, Object?> toJson() => {
        'token': token,
        if (expiresAt != null) 'expiresAt': expiresAt,
      };
}

/// Why the staff map needs a manage grant.
class ManageAccessRefreshReason {
  const ManageAccessRefreshReason(this.raw);
  final String raw;

  /// The map is starting and no [ManageAccessToken] was configured.
  static const initial = ManageAccessRefreshReason('initial');

  /// The current grant is about to expire, or was refused.
  static const refresh = ManageAccessRefreshReason('refresh');

  factory ManageAccessRefreshReason.fromRaw(String raw) => switch (raw) {
        'initial' => initial,
        'refresh' => refresh,
        _ => ManageAccessRefreshReason(raw),
      };

  @override
  bool operator ==(Object other) =>
      other is ManageAccessRefreshReason && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;
}

class ManageAccessRequestContext {
  const ManageAccessRequestContext({required this.reason});
  final ManageAccessRefreshReason reason;
}

/// Mints or renews the staff map's manage grant, in memory.
typedef ManageAccessTokenProvider = FutureOr<ManageAccessToken> Function(
  ManageAccessRequestContext context,
);

/// The staff map's live connection, as reported by
/// `SeatLayerController.onStaffConnectionChanged`.
class StaffConnectionState {
  const StaffConnectionState({required this.status, this.lastMessageAt});

  /// `live`, `reconnecting`, or `ended` once the grant could not be renewed.
  /// An open set: treat anything else like `reconnecting`.
  final String status;

  /// When the map last received an update, epoch milliseconds; `null` before
  /// the first one. The honest "as of" for what the map is showing.
  final int? lastMessageAt;

  bool get isLive => status == 'live';
  bool get hasEnded => status == 'ended';

  static StaffConnectionState? fromJson(Object? value) {
    if (value is! Map) return null;
    final status = value['status'];
    if (status is! String) return null;
    final at = value['lastMessageAt'];
    return StaffConnectionState(
      status: status,
      lastMessageAt: at is num ? at.toInt() : null,
    );
  }
}

/// The price the staff map's hover shows for one ticket category: an amount,
/// or a from–to range. Display only.
class StaffCategoryPrice {
  const StaffCategoryPrice.amount(num this.amount)
      : min = null,
        max = null;
  const StaffCategoryPrice.range({required num this.min, required num this.max})
      : amount = null;

  final num? amount;
  final num? min;
  final num? max;

  Object toJson() => amount ?? {'min': min, 'max': max};
}
