// The two documented full-screen entry points must forward every option.
//
// `SeatLayerPickerPage` and `showSeatLayerPicker` are wrappers, and a wrapper
// that silently drops a parameter is invisible: the host's code compiles, the
// picker renders, and the setting simply never arrives. That is exactly how
// `themeMode` was lost — a host on the documented route could not pin light or
// dark, and always got `auto`.
//
// The audit below is a source-level parity check rather than a per-parameter
// widget test, because the failure mode is *omission*: only reading the real
// parameter lists can notice a NEW option that was never forwarded.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_presentation.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';
import 'package:seatlayer/src/seat_layer_configuration.dart';

import 'fake_webview_platform.dart';
import 'picker_widget_harness.dart';

/// The named parameters of the declaration starting at [signature].
Set<String> _namedParameters(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNot(-1), reason: 'no declaration matching $signature');
  final open = source.indexOf('{', start + signature.length - 1);
  final close = source.indexOf('})', open);
  expect(close, isNot(-1), reason: 'unterminated parameter list: $signature');
  final body = source.substring(open + 1, close);
  return body
      .split(',')
      .map((line) => line.split('=').first.trim())
      .map((line) => line.split(RegExp(r'\s+')).last.replaceAll('this.', ''))
      .where((name) => RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(name))
      .toSet();
}

String _read(String name) =>
    File('lib/src/picker/$name').readAsStringSync().replaceAll('\n', ' ');

void main() {
  test('SeatLayerPickerPage forwards every SeatLayerPicker option', () {
    final picker = _namedParameters(
      _read('seat_layer_picker.dart'),
      'const SeatLayerPicker(',
    );
    final page = _namedParameters(
      _read('seat_layer_picker_presentation.dart'),
      'const SeatLayerPickerPage(',
    );
    expect(picker, contains('themeMode'));
    expect(picker.difference(page), isEmpty);
  });

  test('showSeatLayerPicker forwards every SeatLayerPickerPage option', () {
    final source = _read('seat_layer_picker_presentation.dart');
    final page = _namedParameters(source, 'const SeatLayerPickerPage(');
    final show = _namedParameters(
      source,
      'Future<SeatLayerCheckoutHandoff?> showSeatLayerPicker(',
    );
    // The route owns these two; a caller of the helper never sets them.
    expect(
      page.difference(show).difference(<String>{'useScaffold', 'popOnCheckout'}),
      isEmpty,
    );
  });

  test('every forwarded option is actually passed on, not just accepted', () {
    final source = File('lib/src/picker/seat_layer_picker_presentation.dart')
        .readAsStringSync();
    // Two call sites in showSeatLayerPicker, one in the page's build.
    expect('themeMode: themeMode,'.allMatches(source).length, 2);
    expect(source, contains('themeMode: widget.themeMode,'));
  });

  testWidgets('SeatLayerPickerPage(themeMode: dark) paints dark in a light host',
      (tester) async {
    useFakeWebViewPlatform();
    usePhoneSurface(tester);

    Brightness? resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: SeatLayerPickerPage(
          configuration: SeatLayerConfiguration(event: 'ev_test'),
          themeMode: SeatLayerThemeMode.dark,
          callbacks: SeatLayerPickerCallbacks(
            onThemeResolved: (brightness) => resolved = brightness,
          ),
          onCheckout: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(resolved, Brightness.dark);
  });
}
