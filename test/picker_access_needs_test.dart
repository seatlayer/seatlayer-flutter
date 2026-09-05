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

/// Every access-need row on the open sheet, in the order it is drawn.
///
/// A row is read as `label` or `label · count`, which is the pair of things it
/// draws — the provision and how much of it is left.
List<String> _rowLabels(WidgetTester tester) => tester
    .widgetList<Semantics>(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Semantics),
      ),
    )
    .where((row) => row.properties.toggled != null)
    .map((row) {
      final label = row.properties.label!;
      final count = _countFor(tester, label);
      return count == null ? label : '$label · $count';
    })
    .toList(growable: false);

/// The count drawn at the end of the row named [label], if it draws one.
String? _countFor(WidgetTester tester, String label) {
  final texts = tester
      .widgetList<Text>(
        find.descendant(
          of: find.ancestor(
            of: find.text(label),
            matching: find.byType(Row),
          ).first,
          matching: find.byType(Text),
        ),
      )
      .map((text) => text.data)
      .where((data) => data != null && data != label)
      .toList(growable: false);
  return texts.isEmpty ? null : texts.last;
}

bool _rowEnabled(WidgetTester tester, String label) => tester
    .widgetList<Semantics>(
      find.ancestor(of: find.text(label), matching: find.byType(Semantics)),
    )
    .any((row) => row.properties.enabled == true);

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
      _rowLabels(tester),
      <String>[
        'Step-free · 12 free',
        'Wheelchair · 4 free',
        'Companion · 4 free',
      ],
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

    expect(
      _rowLabels(tester),
      <String>['Wheelchair · None left', 'Companion · 6 free'],
    );
    expect(
      _rowEnabled(tester, 'Wheelchair'),
      isFalse,
      reason: 'a filter that can only ever return nothing must not be tappable',
    );
    expect(_rowEnabled(tester, 'Companion'), isTrue);

    await tester.tap(find.text('Wheelchair'));
    await tester.pumpAndSettle();
    expect(
      _rowLabels(tester),
      <String>['Wheelchair · None left', 'Companion · 6 free'],
    );
  });

  testWidgets('a wheelchair row says the companion place beside it stays',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(
      tester,
      map,
      pickerSnapshot(
        accessNeeds: <Object?>[
          accessNeed('wheelchair', 4),
          accessNeed('companion', 4),
        ],
      ),
    );

    expect(
      find.text('Companion places beside them stay selectable'),
      findsOneWidget,
    );
  });

  testWidgets('a chart with no companion places makes no such promise',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(
      tester,
      map,
      pickerSnapshot(accessNeeds: <Object?>[accessNeed('wheelchair', 4)]),
    );

    expect(
      find.text('Companion places beside them stay selectable'),
      findsNothing,
    );
  });

  testWidgets('a chart with no provisions at all is named Display options',
      (tester) async {
    // The control is still worth having — the palette lives behind it — but
    // calling it accessibility on a chart that authors none would promise
    // seats this venue does not have.
    final map = FakePickerMap(
      bundle: _accessBundle(access: false, colorblind: true),
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const Align(
          alignment: Alignment.bottomLeft,
          child: SeatLayerPickerAccessibilityFilters(compact: true),
        ),
      ),
    );
    map.emit(pickerSnapshot());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Display options'), findsOneWidget);
    expect(find.byTooltip('Accessibility and view filters'), findsNothing);
  });

  testWidgets('an empty inventory does not invent the static taxonomy',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(tester, map, pickerSnapshot());

    expect(_rowLabels(tester), isEmpty);
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

    expect(_rowLabels(tester), isEmpty);
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

  testWidgets('a switch applies as it is flipped, with no apply step',
      (tester) async {
    // A switch IS the action. Staging the flips behind an "Apply filters"
    // button made the sheet ask twice for one decision, and left a buyer who
    // dragged the sheet away — the gesture that closes every other sheet —
    // with a map that had ignored everything they just did. The web menu has
    // never had an apply step: `pickerAccessibilityMenu.wire()` calls
    // `setColorblindSafe` / `setLimitedViewHidden` / `applyFilter()` straight
    // out of the row's own click handler.
    final map = FakePickerMap(bundle: _accessBundle(limited: true));
    addTearDown(map.dispose);
    usePhoneSurface(tester);
    final snapshot = pickerSnapshot(
      accessNeeds: <Object?>[accessNeed('wheelchair', 15)],
    );
    (snapshot['features']! as Map<String, Object?>)['limitedViewFilter'] = true;

    await _openSheet(tester, map, snapshot);

    expect(find.text('Apply filters'), findsNothing);
    expect(map.callsTo('picker.setAccessibilityFilter'), isEmpty);

    await tester.tap(find.text('Wheelchair'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.setAccessibilityFilter').single.$2,
      <String, Object?>{
        'types': <String>['wheelchair'],
      },
    );
    // The buyer may well flip another; only the drag handle and the scrim
    // take the sheet away.
    expect(find.text('Wheelchair'), findsOneWidget);
    expect(find.text('Colourblind-friendly colours'), findsOneWidget);

    await tester.tap(find.text('Hide limited-view seats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Colourblind-friendly colours'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.setLimitedViewFilter').single.$2,
      <String, Object?>{'on': true},
    );
    expect(
      map.callsTo('picker.setColorblindSafe').single.$2,
      <String, Object?>{'on': true},
    );
    expect(find.text('Hide limited-view seats'), findsOneWidget);
  });

  testWidgets('flipping a switch back turns it off on the runtime too',
      (tester) async {
    final map = FakePickerMap(bundle: _accessBundle());
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await _openSheet(
      tester,
      map,
      pickerSnapshot(
        accessNeeds: <Object?>[
          accessNeed('wheelchair', 15),
          accessNeed('companion', 15),
        ],
      ),
    );

    await tester.tap(find.text('Wheelchair'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Companion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wheelchair'));
    await tester.pumpAndSettle();

    expect(
      map.callsTo('picker.setAccessibilityFilter').map((call) => call.$2),
      <Map<String, Object?>>[
        <String, Object?>{
          'types': <String>['wheelchair'],
        },
        <String, Object?>{
          'types': <String>['wheelchair', 'companion'],
        },
        <String, Object?>{
          'types': <String>['companion'],
        },
      ],
      reason: 'the sheet holds the union it drew, and sends it whole each time',
    );
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
      _rowLabels(tester),
      <String>['Rollstuhlplatz · 3 free', 'quiet-room · 1 free'],
      reason: 'the override wins, and a need this table has no name for is '
          'still reachable under its wire key',
    );
  });
}
