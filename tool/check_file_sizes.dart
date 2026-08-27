// Keeps every Dart file in this package readable at a glance.
//
// A public repository's first impression is its longest file. The cap is a
// ratchet, not a style rule: a file that grows past it has almost always
// acquired a second concern, and splitting it is cheaper the earlier it is
// noticed.
//
// Run directly (`dart run tool/check_file_sizes.dart`) or through
// `test/file_size_test.dart`, which is what CI exercises.
import 'dart:io';

/// No Dart file in `lib/` or `test/` may exceed this many lines.
const int seatLayerFileLineCap = 1500;

/// Directories the cap applies to, relative to the package root.
const List<String> seatLayerCheckedRoots = <String>['lib', 'test', 'tool'];

/// Every file over the cap, as `path: lines`, worst first.
List<({String path, int lines})> oversizedDartFiles(Directory root) {
  final offenders = <({String path, int lines})>[];
  for (final name in seatLayerCheckedRoots) {
    final directory = Directory('${root.path}/$name');
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync().length;
      if (lines > seatLayerFileLineCap) {
        offenders.add((path: entity.path, lines: lines));
      }
    }
  }
  offenders.sort((a, b) => b.lines.compareTo(a.lines));
  return offenders;
}

void main() {
  final offenders = oversizedDartFiles(Directory.current);
  if (offenders.isEmpty) {
    stdout.writeln(
        'file sizes: every Dart file is under $seatLayerFileLineCap lines');
    return;
  }
  for (final offender in offenders) {
    stderr.writeln('${offender.path}: ${offender.lines} lines');
  }
  stderr.writeln(
    'Files above $seatLayerFileLineCap lines have to be split by concern.',
  );
  exitCode = 1;
}
