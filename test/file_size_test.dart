import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/check_file_sizes.dart';

void main() {
  test('no Dart file grows past the readability cap', () {
    final offenders = oversizedDartFiles(Directory.current);
    expect(
      offenders,
      isEmpty,
      reason: offenders
          .map((offender) => '${offender.path}: ${offender.lines} lines')
          .join('\n'),
    );
  });
}
