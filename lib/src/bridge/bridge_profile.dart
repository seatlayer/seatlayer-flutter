import 'package:flutter/foundation.dart';

import '../seat_layer_configuration.dart';
import 'bridge_protocol.dart';

/// Internal handshake profile shared by the raw chart and high-level picker.
///
/// The raw [SeatLayerView] deliberately remains on protocol 1. The additive
/// picker profile requests protocol 2 and fails closed when the hosted runtime
/// cannot provide the state/action contract needed by native picker chrome.
@immutable
class SeatLayerBridgeProfile {
  const SeatLayerBridgeProfile._({
    required this.surface,
    required this.protocolRange,
    this.requiredCapabilities = const <String>[],
    this.config = const <String, Object?>{},
    this.chrome = const <String, Object?>{},
  });

  static const SeatLayerBridgeProfile chart = SeatLayerBridgeProfile._(
    surface: 'chart',
    protocolRange: ProtocolRange(min: 1, max: 1),
  );

  factory SeatLayerBridgeProfile.picker({
    Map<String, Object?> config = const <String, Object?>{},
  }) =>
      SeatLayerBridgeProfile._(
        surface: 'picker',
        protocolRange: const ProtocolRange(min: 2, max: 2),
        requiredCapabilities: const <String>[
          'picker-session-v2',
          'picker-snapshot-v1',
          'picker-actions-v1',
          'native-picker-chrome-v1',
          'checkout-handoff-v1',
          'checkout-handoff-reject-v1',
          'hold-ownership-v1',
          'cart-line-remove-v1',
          'table-quantity-v1',
        ],
        config: Map<String, Object?>.unmodifiable(config),
        chrome: const <String, Object?>{
          'owner': 'native',
          'seatTooltip': false,
          'testModeIndicator': false,
          'attribution': false,
        },
      );

  final String surface;
  final ProtocolRange protocolRange;
  final List<String> requiredCapabilities;
  final Map<String, Object?> config;
  final Map<String, Object?> chrome;

  bool get isPicker => surface == 'picker';

  Map<String, Object?> initPayload(SeatLayerConfiguration configuration) {
    final payload = configuration.initPayload(protocolRange: protocolRange);
    if (!isPicker) return payload;

    final currentConfig = Map<String, Object?>.from(
      payload['config']! as Map<String, Object?>,
    )..addAll(config);
    final currentChrome = Map<String, Object?>.from(
      payload['chrome']! as Map<String, Object?>,
    )..addAll(chrome);

    return <String, Object?>{
      ...payload,
      'surface': const <String, Object?>{
        'kind': 'picker',
        'stateContract': 1,
        'chromeOwner': 'native',
      },
      'requirements': <String, Object?>{'capabilities': requiredCapabilities},
      'chrome': currentChrome,
      'config': currentConfig,
    };
  }

  bool equivalentTo(SeatLayerBridgeProfile other) =>
      surface == other.surface &&
      protocolRange == other.protocolRange &&
      listEquals(requiredCapabilities, other.requiredCapabilities) &&
      _deepEquals(config, other.config) &&
      _deepEquals(chrome, other.chrome);
}

bool _deepEquals(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is List && right is List) {
    return left.length == right.length &&
        List<bool>.generate(
          left.length,
          (index) => _deepEquals(left[index], right[index]),
        ).every((same) => same);
  }
  if (left is Map && right is Map) {
    return left.length == right.length &&
        left.keys.every(
          (key) => right.containsKey(key) && _deepEquals(left[key], right[key]),
        );
  }
  return left == right;
}
