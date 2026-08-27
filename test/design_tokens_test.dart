import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_haptics.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/picker_motion.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

Map<String, Object?> _section(String key) {
  final raw = jsonDecode(File('design/tokens.json').readAsStringSync())
      as Map<String, Object?>;
  return raw[key]! as Map<String, Object?>;
}

Color _color(Object? value) {
  final hex = (value! as String).replaceFirst('#', '');
  return Color(int.parse(hex.length == 6 ? 'ff$hex' : hex, radix: 16));
}

void main() {
  test('the light preset is design/tokens.json', () {
    const preset = SeatLayerPickerThemeData.light();
    final light = _section('color')['light']! as Map<String, Object?>;
    expect(preset.background, _color(light['background']));
    expect(preset.surface, _color(light['surface']));
    expect(preset.text, _color(light['text']));
    expect(preset.mutedText, _color(light['mutedText']));
    expect(preset.divider, _color(light['divider']));
    expect(preset.accent, _color(light['accent']));
    expect(preset.onAccent, _color(light['onAccent']));
    expect(preset.mapTheme!.background, _color(light['mapBackground']));
  });

  test('the dark preset is design/tokens.json', () {
    const preset = SeatLayerPickerThemeData.dark();
    final dark = _section('color')['dark']! as Map<String, Object?>;
    expect(preset.background, _color(dark['background']));
    expect(preset.surface, _color(dark['surface']));
    expect(preset.text, _color(dark['text']));
    expect(preset.accent, _color(dark['accent']));
    expect(preset.mapTheme!.background, _color(dark['mapBackground']));
  });

  test('the layout defaults are design/tokens.json', () {
    const layout = SeatLayerPickerLayout();
    final size = _section('size');
    expect(layout.phoneBreakpoint, size['phoneBreakpoint']);
    expect(layout.headerHeight, size['headerHeight']);
    expect(layout.dockBarHeight, size['dockBarHeight']);
    expect(layout.peekHeight, size['peekHeight']);
    expect(layout.sheetMaxHeightFraction, size['sheetMaxHeightFraction']);
    expect(layout.confirmPhotoHeight, size['confirmPhotoHeight']);
    expect(layout.denseVisibleLines, size['denseVisibleLines']);
    expect(layout.accessibilityControlSize, size['minimumHitTarget']);
  });

  test('the motion table is design/tokens.json and inside its budget', () {
    final motion = _section('motion');
    final durations = motion['duration']! as Map<String, Object?>;
    for (final entry in SeatLayerPickerMotion.catalog.entries) {
      expect(
        entry.value.inMilliseconds,
        durations[entry.key],
        reason: 'motion token ${entry.key}',
      );
      expect(entry.value.inMilliseconds, lessThanOrEqualTo(motion['budgetMs']! as int));
    }
    expect(durations.keys.toSet(), SeatLayerPickerMotion.catalog.keys.toSet());
  });

  test('the haptic map is design/tokens.json', () {
    final haptics = _section('haptics');
    for (final cue in PickerHapticCue.values) {
      expect(pickerHapticStrength(cue), haptics[cue.name]);
    }
  });

  test('the string defaults are design/tokens.json', () {
    const strings = SeatLayerPickerStrings();
    final table = _section('strings');
    expect(strings.overview, table['overview']);
    expect(strings.holdAndCheckout, table['holdAndCheckout']);
    expect(strings.emptyTrayHint, table['emptyTrayHint']);
    expect(strings.backToVenue, table['backToVenue']);
    expect(strings.testMode, table['testMode']);
    expect(strings.loading, table['loading']);
    expect(strings.errorMessage, table['errorMessage']);
    expect(strings.retry, table['retry']);
    expect(strings.accessibilityTitle, table['accessibilityTitle']);
    expect(strings.applyFilters, table['applyFilters']);
    expect(strings.accessNeeds['wheelchair'], table['accessWheelchair']);
    expect(strings.accessNeeds['lift-armrest'], table['accessLiftArmrest']);
  });

  test('picker_tokens.g.dart is not stale', () {
    final result = Process.runSync(
      'dart',
      <String>['run', 'tool/gen_tokens.dart', '--check'],
    );
    expect(
      result.exitCode,
      0,
      reason: '${result.stdout}${result.stderr}',
    );
  });
}
