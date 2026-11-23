import 'package:flutter/foundation.dart';

import '../payloads.dart';
import '../seat_layer_surface_configuration.dart';
import 'bridge_protocol.dart';

/// Internal handshake profile: the raw chart, the high-level picker and the
/// Season page.
///
/// The raw [SeatLayerView] keeps its original profile. The additive picker
/// profile fails closed when the renderer cannot provide the state/action
/// contract that native picker chrome needs.
@immutable
class SeatLayerBridgeProfile {
  const SeatLayerBridgeProfile._({
    required this.surface,
    required this.protocolRange,
    this.requiredCapabilities = const <String>[],
    this.destroyCommand,
    this.surfaceInit,
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
        destroyCommand: 'picker.destroy',
        surfaceInit: const <String, Object?>{
          'kind': 'picker',
          'stateContract': 1,
          'chromeOwner': 'native',
        },
        requiredCapabilities: <String>[
          'picker-session-v2',
          'picker-snapshot-v1',
          'picker-actions-v1',
          'native-picker-chrome-v1',
          'checkout-handoff-v1',
          'checkout-handoff-reject-v1',
          'hold-ownership-v1',
          'cart-line-remove-v1',
          'table-quantity-v1',
          if (config['enable3D'] != false) ...<String>[
            'venue-3d-v1',
            'venue-3d-controls-v1',
          ],
          if (config['enableSeatView'] != false) 'seat-view-v1',
        ],
        config: Map<String, Object?>.unmodifiable(config),
        chrome: const <String, Object?>{
          'owner': 'native',
          'seatTooltip': false,
          'testModeIndicator': false,
          'attribution': false,
        },
      );

  /// The Season page (`season.html`): a fixed package of dates, sold as the
  /// same seat for every date, with the app's own checkout.
  ///
  /// [config] is folded into `init.config`: what a reload must boot with, as
  /// the picker's is.
  factory SeatLayerBridgeProfile.season({
    Map<String, Object?> config = const <String, Object?>{},
  }) =>
      SeatLayerBridgeProfile._(
        surface: 'season',
        protocolRange: const ProtocolRange(min: 2, max: 2),
        destroyCommand: 'season.destroy',
        surfaceInit: const <String, Object?>{'kind': 'season'},
        requiredCapabilities: const <String>[
          'season-surface-v1',
          'season-app-shell-v1',
        ],
        config: Map<String, Object?>.unmodifiable(config),
      );

  final String surface;
  final ProtocolRange protocolRange;
  final List<String> requiredCapabilities;
  final Map<String, Object?> config;
  final Map<String, Object?> chrome;

  /// The command that lets the page release what it owns before a reload
  /// replaces it, and acknowledges. Null for the raw chart, which is detached
  /// without one.
  final String? destroyCommand;

  /// The `surface` block of the page's `init`, or null when the page takes
  /// none.
  final Map<String, Object?>? surfaceInit;

  bool get isPicker => surface == 'picker';

  /// The `init` reply for [configuration], as answered to [bundle]'s `hello`.
  ///
  /// [bundle] is what the runtime just advertised. It is read only to suppress
  /// chrome the runtime has told us it can hand over instead of drawing — never
  /// to change the surface, the profile's identity or anything a reload turns
  /// on, because [equivalentTo] does not see it and a difference it caused
  /// would not reboot the runtime.
  Map<String, Object?> initPayload(
    SeatLayerSurfaceConfiguration configuration, {
    BundleInfo? bundle,
  }) {
    final payload = configuration.initPayload(protocolRange: protocolRange);
    final surface = surfaceInit;
    if (surface == null) return payload;

    final currentConfig = Map<String, Object?>.from(
      payload['config']! as Map<String, Object?>,
    )..addAll(config);
    if (!isPicker) {
      return <String, Object?>{
        ...payload,
        'surface': surface,
        'config': currentConfig,
      };
    }
    final currentChrome = Map<String, Object?>.from(
      payload['chrome']! as Map<String, Object?>,
    )..addAll(chrome);
    // The 2D panorama's own header, caption and badge. Suppressed only on a
    // runtime that has said it will report those words on `seatView.changed`
    // instead — asking an older one to drop them would take the disclosure off
    // the screen entirely, leaving a buyer looking at a drawn illustration with
    // nothing saying so. The CLOSE button is deliberately not in this list: the
    // panorama is full screen and native chrome does not reach into it.
    if (bundle != null &&
        bundle.supportsCapability(seatLayerSeatViewChromeCapability)) {
      currentChrome.addAll(const <String, Object?>{
        'seatViewTitle': false,
        'seatViewCaption': false,
        'seatViewBadge': false,
      });
    }

    return <String, Object?>{
      ...payload,
      'surface': surface,
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
