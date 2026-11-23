// The Season picker on every phone in the matrix: the app's header (NS01)
// over season.html, which a test cannot draw — the page is the web view, so
// its area shows the page's ground here and the device runs show the rest.
//
// Same phones, text sizes, languages and sideways set as the event picker
// (`phone_matrix_test.dart`), with the same layout checks.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'fake_webview_platform.dart';
import 'phone_matrix_harness.dart';
import 'picker_widget_harness.dart';
import 'season_harness.dart';

/// What the header shows.
enum SeasonPhoneState {
  /// Runtime 1.0.0's page, nothing held: the picker's loading words.
  ready,

  /// Seats held: the clock.
  held,

  /// Runtime 1.0.1's page names the Season and its club; seats held.
  named,

  /// The Season could not be shown: the event picker's failure view.
  failed,
}

Future<SeatLayerPickerStrings> _pumpSeason(
  WidgetTester tester,
  Phone phone,
  SeasonPhoneState state, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Locale locale = const Locale('en'),
  bool golden = false,
}) async {
  final page = SeasonPage(useFakeWebViewPlatform());
  putOnPhone(tester, phone);
  final strings = SeatLayerPickerStrings.forLocale(locale);
  final rtl = locale.languageCode == 'ar' || locale.languageCode == 'he';
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: brightness),
      themeAnimationDuration: Duration.zero,
      builder: (context, inner) {
        final Widget framed = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            platformBrightness: brightness,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: inner!,
          ),
        );
        return golden ? goldenSubject(framed) : framed;
      },
      home: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => showSeatLayerSeasonPicker(
              context,
              configuration: seasonConfiguration,
              // A test has no system font; Roboto measures the words as a
              // buyer sees them.
              theme: const SeatLayerPickerThemeData(fontFamily: 'Roboto'),
              strings: strings,
              onClose: (_, __) {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  if (state == SeasonPhoneState.failed) {
    page.post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.0',
      'protocol': <String, Object?>{'min': 2, 'max': 2},
      'capabilities': <String>['season-surface-v1', 'season-app-shell-v1'],
      'events': <String>[],
      'commands': <String>[],
    });
    await tester.pump();
    page.evt('sys.error', <String, Object?>{'code': 'render_failed'});
    await pumpToRest(tester);
    return strings;
  }
  await page.boot(tester);
  if (state == SeasonPhoneState.named) {
    page.named('Riverside Winter Season 2027', 'Riverside FC');
  }
  if (state != SeasonPhoneState.ready) page.held('sop_a');
  await pumpToRest(tester);
  return strings;
}

void _expectSeasonLayout(WidgetTester tester, Phone phone,
    SeasonPhoneState state, SeatLayerPickerStrings strings) {
  expectPhoneLayout(tester, phone, strings);
  // The bar stands under the safe area's top; the page fills the rest.
  final bar = tester.getRect(find.byType(SeatLayerHeaderBar));
  final page = tester.getRect(find.byType(
    state == SeasonPhoneState.failed
        ? SeatLayerPickerErrorView
        : SeatLayerSeasonView,
  ));
  // Under the status bar, on the page's ground, as on the event page.
  expect(bar.top, phone.insets.top);
  expect(page.top, moreOrLessEquals(bar.bottom));
  expect(page.bottom, phone.size.height,
      reason: 'the page owns the bottom inset (season.setViewportInsets)');
  expect(page.left, moreOrLessEquals(phone.insets.left));
  expect(page.right, moreOrLessEquals(phone.size.width - phone.insets.right));
  expect(find.byTooltip(strings.close), findsOneWidget);
  expect(
    find.byType(SeatLayerHoldClock),
    state == SeasonPhoneState.ready || state == SeasonPhoneState.failed
        ? findsNothing
        : findsOneWidget,
  );
  if (state == SeasonPhoneState.failed) {
    expect(find.text(strings.retry), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, strings.retry)).height,
      greaterThanOrEqualTo(SeatLayerSizeTokens.minimumHitTarget),
    );
  }
}

String _scale(double textScale) =>
    textScale == 1 ? '' : '_t${(textScale * 10).round()}';

void main() {
  group('upright', () {
    for (final phone in uprightPhones) {
      for (final textScale in const <double>[1, 1.3, 2]) {
        for (final state in SeasonPhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings =
                await _pumpSeason(tester, phone, state, textScale: textScale);
            _expectSeasonLayout(tester, phone, state, strings);
            semantics.dispose();
          });
        }
      }
    }
  });

  group('dark', () {
    for (final phone in uprightPhones) {
      testWidgets('$phone, named', (tester) async {
        final semantics = tester.ensureSemantics();
        final strings = await _pumpSeason(
          tester,
          phone,
          SeasonPhoneState.named,
          brightness: Brightness.dark,
        );
        _expectSeasonLayout(tester, phone, SeasonPhoneState.named, strings);
        semantics.dispose();
      });
    }
  });

  group('right to left, Arabic', () {
    for (final phone in uprightPhones.where(
      (phone) => phone.name == '320' || phone.name == '390',
    )) {
      for (final textScale in const <double>[1, 1.3, 2]) {
        for (final state in SeasonPhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings = await _pumpSeason(
              tester,
              phone,
              state,
              textScale: textScale,
              locale: const Locale('ar'),
            );
            _expectSeasonLayout(tester, phone, state, strings);
            semantics.dispose();
          });
        }
      }
    }
  });

  group('sideways', () {
    for (final phone in sidewaysPhones) {
      for (final textScale in const <double>[1, 1.3]) {
        for (final state in SeasonPhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings =
                await _pumpSeason(tester, phone, state, textScale: textScale);
            _expectSeasonLayout(tester, phone, state, strings);
            semantics.dispose();
          });
        }
      }
    }
  });

  group('pictures', () {
    Future<void> shoot(
      WidgetTester tester,
      String name,
      Phone phone,
      SeasonPhoneState state, {
      Brightness brightness = Brightness.light,
      double textScale = 1,
      Locale locale = const Locale('en'),
    }) async {
      await _pumpSeason(
        tester,
        phone,
        state,
        brightness: brightness,
        textScale: textScale,
        locale: locale,
        golden: true,
      );
      await expectGolden(tester, name);
    }

    final phone320 = uprightPhones.firstWhere((phone) => phone.name == '320');
    final phone390 = uprightPhones.firstWhere((phone) => phone.name == '390');
    final phone430 = uprightPhones.firstWhere((phone) => phone.name == '430');
    for (final brightness in Brightness.values) {
      for (final state in SeasonPhoneState.values) {
        final name = 'season_390_${state.name}_${brightness.name}';
        testWidgets(name, tags: goldenTag, (tester) async {
          await shoot(tester, name, phone390, state, brightness: brightness);
        });
      }
    }
    for (final (phone, textScale) in <(Phone, double)>[
      (phone320, 1),
      (phone320, 2),
      (phone430, 1),
      (phone390, 2),
    ]) {
      final name = 'season_${phone.name}_named_light${_scale(textScale)}';
      testWidgets(name, tags: goldenTag, (tester) async {
        await shoot(tester, name, phone, SeasonPhoneState.named,
            textScale: textScale);
      });
    }
    testWidgets('season_320_failed_light_t20', tags: goldenTag,
        (tester) async {
      await shoot(tester, 'season_320_failed_light_t20', phone320,
          SeasonPhoneState.failed,
          textScale: 2);
    });
    testWidgets('season_390_ar_named_light', tags: goldenTag, (tester) async {
      await shoot(
          tester, 'season_390_ar_named_light', phone390, SeasonPhoneState.named,
          locale: const Locale('ar'));
    });
    final sideways = sidewaysPhones.first;
    testWidgets('season_${sideways.name}_named_light', tags: goldenTag,
        (tester) async {
      await shoot(tester, 'season_${sideways.name}_named_light', sideways,
          SeasonPhoneState.named);
    });
  }, skip: goldenSkip);
}
