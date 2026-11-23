import 'package:meta/meta.dart';

import 'bridge/bridge_protocol.dart';
import 'payloads.dart';

/// What the shared shell reads from any SeatLayer page's configuration: the
/// page to load, the `init` it is answered with, the deadlines, and who renews
/// private buyer access.
///
/// [SeatLayerConfiguration] is the event's. Everything else a page needs stays
/// on its own configuration.
abstract class SeatLayerSurfaceConfiguration {
  /// The pinned page the web view loads.
  String get assetPath;

  /// The page's `init`, for a session that agreed on [protocolRange].
  Map<String, Object?> initPayload({required ProtocolRange protocolRange});

  /// Native-side deadline for a single command before it fails `sl_timeout`.
  Duration get commandTimeout;

  /// How long to wait for `sys.ready` before failing the load.
  Duration get handshakeTimeout;

  /// Renews private buyer access when the page asks, or null when the app
  /// gives none.
  BuyerAccessTokenProvider? get buyerAccessTokenProvider;

  /// Whether [other] boots the same page the same way, so a rebuilt widget
  /// keeps its page instead of reloading it.
  bool semanticallyEquals(covariant SeatLayerSurfaceConfiguration other);
}

/// Whether two configuration values are the same: lists and maps by content,
/// everything else by `==`.
@internal
bool seatLayerSameValue(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (!seatLayerSameValue(left[i], right[i])) return false;
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final key in left.keys) {
      if (!right.containsKey(key) || !seatLayerSameValue(left[key], right[key])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}
