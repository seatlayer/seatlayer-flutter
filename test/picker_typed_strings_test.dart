// Every word a buyer reads comes from SeatLayerPickerStrings.
//
// A sentence typed straight into a widget has no translation and no host
// override: it stays English inside a translated picker, and no strings file
// can reach it. This guard reads the package's own source and fails on a
// capitalised literal handed to a place a buyer sees or hears.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A capitalised literal at a call site that renders or speaks it.
final RegExp _buyerFacing = RegExp(
  r"(?:\bText\(\s*|\b(?:label|tooltip|hint|message|semanticsLabel|hintText|title|key):\s*|[?:]\s+)'[A-Z][a-z][^'$]*'",
  multiLine: true,
);

/// The source to read: everything hand-written under lib/.
Iterable<File> _sources() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .where((file) => !file.path.endsWith('.g.dart'));

/// Hits in [source], each as `line: text`, comments skipped.
List<String> typedBuyerStrings(String source) {
  final hits = <String>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trimLeft().startsWith('//')) continue;
    // Read the line with the next one, so a literal on the line after its
    // `Text(` is still seen.
    final next = i + 1 < lines.length ? lines[i + 1] : '';
    final window = '$line\n$next ';
    for (final match in _buyerFacing.allMatches(window)) {
      if (match.start > line.length) continue;
      hits.add('${i + 1}: ${line.trim()}');
    }
  }
  return hits;
}

void main() {
  test('the guard sees the shapes it is meant to catch', () {
    expect(typedBuyerStrings("child: const Text('Cancel'),"), hasLength(1));
    expect(typedBuyerStrings("Text(\n  'Total',\n)"), hasLength(1));
    expect(typedBuyerStrings("tooltip: 'Dismiss error',"), hasLength(1));
    expect(typedBuyerStrings("label: 'Powered by SeatLayer',"), hasLength(1));
    expect(typedBuyerStrings("        : 'Row',"), hasLength(1));
    expect(typedBuyerStrings("(key: 'Section', value: x),"), hasLength(1));
    // Not buyer-facing: comments, codes and strings read from a table.
    expect(typedBuyerStrings("// Text('Cancel')"), isEmpty);
    expect(typedBuyerStrings("currency ?? 'USD'"), isEmpty);
    expect(typedBuyerStrings('child: Text(strings.cancel),'), isEmpty);
  });

  test('no buyer-facing English is typed into the picker', () {
    final hits = <String>[
      for (final file in _sources())
        for (final hit in typedBuyerStrings(file.readAsStringSync()))
          '${file.path}:$hit',
    ];
    expect(
      hits,
      isEmpty,
      reason: 'Move each into SeatLayerPickerStrings (and design/tokens.json):'
          '\n${hits.join('\n')}',
    );
  });
}
