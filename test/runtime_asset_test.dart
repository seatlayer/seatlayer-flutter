import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/bridge/bridge_profile.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

void main() {
  test('vendored runtime bytes match immutable provenance', () {
    final runtimeBytes = File('assets/seatlayer.js').readAsBytesSync();
    final metadata = jsonDecode(
      File('assets/seatlayer.runtime.json').readAsStringSync(),
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
    final runtime = File('assets/seatlayer.js').readAsStringSync();
    final metadata = jsonDecode(
      File('assets/seatlayer.runtime.json').readAsStringSync(),
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
