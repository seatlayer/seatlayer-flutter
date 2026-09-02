// Loading, failure and the accessibility sheet are buyer-facing surfaces too.
//
// All three were hard-coded English, so a host passing
// `SeatLayerConfiguration.locale` got a localised map with English native
// chrome on top of it. The failure view also demanded a scope, which is the
// one thing a host cannot have for the failures it must render itself — a
// buyer token that would not mint, a catalogue that would not load.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_layout.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerResolvedPickerTheme _standaloneTheme =
    SeatLayerResolvedPickerTheme(
  brightness: Brightness.dark,
  accent: SeatLayerDarkTokens.accent,
  onAccent: SeatLayerDarkTokens.onAccent,
  background: SeatLayerDarkTokens.background,
  surface: SeatLayerDarkTokens.surface,
  text: SeatLayerDarkTokens.text,
  mutedText: SeatLayerDarkTokens.mutedText,
  divider: SeatLayerDarkTokens.divider,
  error: SeatLayerDarkTokens.error,
  warning: SeatLayerDarkTokens.warning,
  radius: SeatLayerRadiusTokens.base,
  buttonRadius: SeatLayerRadiusTokens.button,
  layout: SeatLayerPickerLayout(),
);

void main() {
  testWidgets('the loading view renders with no scope above it',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeatLayerPickerLoadingView.standalone(theme: _standaloneTheme),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Loading seat map…'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Loading seat map…')).style!.color,
      SeatLayerDarkTokens.text,
    );
  });

  testWidgets('the failure view renders with no scope, and retries',
      (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeatLayerPickerErrorView.standalone(
            theme: _standaloneTheme,
            message: 'Your session could not be started.',
            onRetry: () => retried++,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Title, what went wrong, and what to do about it — the failure card says
    // three things, and the host's own sentence is the middle one.
    expect(find.text("The seat map didn't load"), findsOneWidget);
    expect(find.text('Your session could not be started.'), findsOneWidget);
    expect(find.text('Check your connection and try again.'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });

  testWidgets('the empty view is a host wording too', (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerEmptyView(),
        options: const SeatLayerPickerOptions(
          strings: SeatLayerPickerStrings(
            noSelectableSeats: 'Aucun siège disponible.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun siège disponible.'), findsOneWidget);
  });

  testWidgets('a host wording reaches the loading and failure views',
      (tester) async {
    const words = SeatLayerPickerStrings(
      loading: 'Chargement du plan…',
      errorMessage: 'Le plan n’a pas pu être chargé.',
      retry: 'Réessayer',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              const SeatLayerPickerLoadingView.standalone(
                theme: _standaloneTheme,
                strings: words,
              ),
              SeatLayerPickerErrorView.standalone(
                theme: _standaloneTheme,
                strings: words,
                onRetry: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Chargement du plan…'), findsOneWidget);
    expect(find.text('Le plan n’a pas pu être chargé.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('the scoped views read the picker theme and strings',
      (tester) async {
    final map = FakePickerMap();
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const SeatLayerPickerLoadingView(),
        options: const SeatLayerPickerOptions(
          strings: SeatLayerPickerStrings(loading: 'Un momento…'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Un momento…'), findsOneWidget);
  });

  testWidgets('the accessibility sheet is a host wording too', (tester) async {
    final map = FakePickerMap(
      bundle: nativeChromeBundle(
        capabilities: const <String>[
          'native-chrome-contract-v1',
          'access-needs-v1',
          'colorblind-safe',
        ],
        commands: const <String>[
          'picker.setAccessibilityFilter',
          'picker.setLimitedViewFilter',
          'picker.setColorblindSafe',
        ],
      ),
    );
    addTearDown(map.dispose);
    usePhoneSurface(tester);

    await tester.pumpWidget(
      pickerHarness(
        map,
        const Align(
          alignment: Alignment.topLeft,
          child: SeatLayerPickerAccessibilityFilters(compact: true),
        ),
        options: const SeatLayerPickerOptions(
          strings: SeatLayerPickerStrings(
            accessibilityTitle: 'Barrierefreiheit',
            applyFilters: 'Filter anwenden',
            hideLimitedView: 'Sicht eingeschränkt ausblenden',
            colorblindSafe: 'Farbenblind-freundlich',
            accessNeeds: <String, String>{'wheelchair': 'Rollstuhl'},
          ),
        ),
      ),
    );
    final snapshot = pickerSnapshot(
      accessNeeds: <Object?>[accessNeed('wheelchair', 1)],
    );
    (snapshot['features']! as Map<String, Object?>)['limitedViewFilter'] = true;
    map.emit(snapshot);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.accessible_forward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Barrierefreiheit'), findsOneWidget);
    expect(find.text('Rollstuhl · 1'), findsOneWidget);
    expect(find.text('Filter anwenden'), findsOneWidget);
    expect(find.text('Sicht eingeschränkt ausblenden'), findsOneWidget);
    expect(find.text('Farbenblind-freundlich'), findsOneWidget);
    // The table the host supplied is the table, not a patch over the default.
    expect(find.text('Companion'), findsNothing);
  });
}
