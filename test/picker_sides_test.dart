// A padding with one size on the left and another on the right is drawn on
// the same sides in Arabic and Hebrew, where the start is on the right. The
// picker's own paddings say start and end instead.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no padding of the picker has a left that differs from its right', () {
    final sided = RegExp(
      r'EdgeInsets\.fromLTRB\(\s*([^,]+),\s*[^,]+,\s*([^,]+),',
    );
    final only = RegExp(r'EdgeInsets\.only\(([^)]*)\)');
    String? side(String body, String name) =>
        RegExp('$name:\\s*([^,\\n]+)').firstMatch(body)?.group(1)?.trim();
    final found = <String>[];
    for (final file in Directory('lib/src').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      String at(int offset) =>
          '${file.path}:${'\n'.allMatches(source.substring(0, offset)).length + 1}';
      for (final match in sided.allMatches(source)) {
        if (match.group(1)!.trim() != match.group(2)!.trim()) {
          found.add(at(match.start));
        }
      }
      for (final match in only.allMatches(source)) {
        final body = match.group(1)!;
        final left = side(body, 'left');
        final right = side(body, 'right');
        if ((left != null || right != null) && left != right) {
          found.add(at(match.start));
        }
      }
    }
    expect(found, isEmpty);
  });
}
