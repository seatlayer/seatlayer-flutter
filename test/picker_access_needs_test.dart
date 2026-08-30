// The accessibility sheet offers what this event has, not what the SDK knows.
//
// Twelve chips is the vocabulary of the filter, not the inventory of the venue.
// A buyer who needs a step-free seat and taps "Step-free" on a chart with none
// gets an empty map and no explanation, and the twelve dead chips are also
// twelve rows of nothing between them and the two needs the venue does offer.
//
// The distinction the runtime is careful about and this sheet has to keep: a
// need with a count of zero is still listed, greyed. "This venue has no
// wheelchair spaces" and "its wheelchair spaces are taken" are different facts,
// and a chip that simply vanished would state the first when the truth is the
// second.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

BundleInfo _accessBundle({
  bool access = true,
  bool limited = false,
  bool colorblind = true,
}) =>
    nativeChromeBundle(
      capabilities: <String>[
        'native-chrome-contract-v1',
        if (access) 'access-needs-v1',
        if (colorblind) 'colorblind-safe',
      ],
      commands: <String>[
        'picker.setThemeMode',
        if (access) 'picker.setAccessibilityFilter',
        if (limited) 'picker.setLimitedViewFilter',
        if (colorblind) 'picker.setColorblindSafe',
      ],
    );

/// Every chip on the open sheet, in the order it is drawn.
List<String> _chipLabels(WidgetTester tester) => tester
    .widgetList<FilterChip>(find.byType(FilterChip))
    .map((chip) => ((chip.label as Text).data)!)
    .toList(growable: false);

bool _chipEnabled(WidgetTester tester, String label) =>
    tester
        .widgetList<FilterChip>(find.byType(FilterChip))
        .firstWhere((chip) => (chip.label as Text).data == label)
        .onSelected !=
    null;

/// Mount the control, open its sheet, and settle.
Future<void> _openSheet(
  WidgetTester tester,
  FakePickerMap map,
  Map<String, Object?> snapshot, {
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
}) async {
  await tester.pumpWidget(
    pickerHarness(
      map,
      const Align(
        alignment: Alignment.bottomLeft,
        child: SeatLayerPickerAccessibilityFilters(compact: true),
      ),
      options: options,
    ),
  );
  map.emit(snapshot);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(IconButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('only the needs this event offers render, in the runtime order',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(
      tester,
      map,
      pickerSnapshot(
        accessNeeds: <Object?>[
          accessNeed('step-free', 12),
          accessNeed('wheelchair', 4),
          accessNeed('companion', 4),
        ],
      ),
    );

    expect(
      _chipLabels(tester),
      <String>['Step-free · 12', 'Wheelchair · 4', 'Companion · 4'],
      reason: 'the runtime already ordered these; re-sorting them here would '
          'be a second opinion about the same venue',
    );
    expect(find.text('Hearing support'), findsNothing);
  });

  testWidgets('a need whose seats are gone stays, named and disabled',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(
      tester,
      map,
      pickerSnapshot(
        accessNeeds: <Object?>[
          accessNeed('wheelchair', 0),
          accessNeed('companion', 6),
        ],
      ),
    );

    expect(_chipLabels(tester), <String>['Wheelchair', 'Companion · 6']);
    expect(
      _chipEnabled(tester, 'Wheelchair'),
      isFalse,
      reason: 'a filter that can only ever return nothing must not be tappable',
    );
    expect(_chipEnabled(tester, 'Companion · 6'), isTrue);

    await tester.tap(find.text('Wheelchair'));
    await tester.pumpAndSettle();
    expect(_chipLabels(tester), <String>['Wheelchair', 'Companion · 6']);
  });

  testWidgets('an empty inventory does not invent the static taxonomy',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(tester, map, pickerSnapshot());

    expect(_chipLabels(tester), isEmpty);
    expect(find.text('Colourblind-friendly colours'), findsOneWidget);
    expect(find.text('Hide limited-view seats'), findsNothing);
  });

  testWidgets('a limited-view-only event shows only its supported group',
      (tester) async {
    final map = FakePickerMap(
      bundle: _accessBundle(access: false, limited: true, colorblind: false),
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final snapshot = pickerSnapshot();
    final features = snapshot['features']! as Map<String, Object?>;
    features['accessibilityFilter'] = false;
    features['limitedViewFilter'] = true;

    await _openSheet(tester, map, snapshot);

    expect(_chipLabels(tester), isEmpty);
    expect(find.text('Hide limited-view seats'), findsOneWidget);
    expect(find.text('Colourblind-friendly colours'), findsNothing);
  });

  testWidgets('the control disappears when no filter operation is supported',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerAccessibilityFilters(compact: true),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('a host override still names the need', (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(
      tester,
      map,
      pickerSnapshot(
        accessNeeds: <Object?>[
          accessNeed('wheelchair', 3),
          accessNeed('quiet-room', 1),
        ],
      ),
      options: const SeatLayerPickerOptions(
        strings: SeatLayerPickerStrings(
          accessNeeds: <String, String>{'wheelchair': 'Rollstuhlplatz'},
        ),
      ),
    );

    expect(
      _chipLabels(tester),
      <String>['Rollstuhlplatz · 3', 'quiet-room · 1'],
      reason: 'the override wins, and a need this table has no name for is '
          'still reachable under its wire key',
    );
  });
}
