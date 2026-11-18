import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The locale extraction tool's app strings checks, run on their fixtures.
void main() {
  final hasNode = () {
    try {
      return Process.runSync('node', <String>['--version'], runInShell: true)
              .exitCode ==
          0;
    } on ProcessException {
      return false;
    }
  }();
  test(
    'the app strings checks fail on gaps',
    () {
      final result = Process.runSync(
        'node',
        <String>['--test', 'tool/test/app_strings_checks.test.mjs'],
        runInShell: true,
      );
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    },
    skip: hasNode ? false : 'node is not installed',
  );
}
