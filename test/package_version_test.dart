import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

void main() {
  test('the runtime-reported SDK version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final packageVersion = RegExp(
      r'^version:\s*([^\s]+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec)?.group(1);

    expect(packageVersion, isNotNull);
    expect(seatLayerSdkVersion, packageVersion);
  });
}
