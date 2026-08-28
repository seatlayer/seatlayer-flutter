import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

/// The offline fixture ships with the example app, not with the package.
///
/// A 1.18 MB runtime in the published archive is a cost every consumer pays
/// for a path production never takes: production loads the immutable hosted
/// page. These checks follow the bytes to where they now live.
void main() {
  test('vendored runtime bytes match immutable provenance', () {
    final runtimeBytes = File('example/assets/seatlayer.js').readAsBytesSync();
    final metadata = jsonDecode(
      File('example/assets/seatlayer.runtime.json').readAsStringSync(),
    ) as Map<String, Object?>;

    expect(runtimeBytes, hasLength(seatLayerBundledRuntimeByteLength));
    expect(
      sha256.convert(runtimeBytes).toString(),
      seatLayerBundledRuntimeSha256,
    );
    expect(
      metadata['runtime'],
      'seatlayer-js@$seatLayerLegacyFixtureWebVersion',
    );
    expect(
      metadata['sourceCommit'],
      seatLayerBundledRuntimeSourceCommit,
    );
    expect(metadata['sha256'], seatLayerBundledRuntimeSha256);
    expect(metadata['bytes'], seatLayerBundledRuntimeByteLength);
  });

  test('vendored runtime supports public bootstrap and picker handshake', () {
    final runtime = File('example/assets/seatlayer.js').readAsStringSync();
    final metadata = jsonDecode(
      File('example/assets/seatlayer.runtime.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final requiredCapabilities =
        SeatLayerBridgeProfile.picker().requiredCapabilities;

    expect(runtime, contains(metadata['publicBootstrapPath'] as String));
    expect(
      metadata['requiredPickerCapabilities'],
      requiredCapabilities,
    );
    for (final capability in requiredCapabilities) {
      expect(runtime, contains(capability), reason: capability);
    }
  });
}
