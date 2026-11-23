// The run picker on every phone in the matrix: the app's header (NS01) over
// group.html, which a test cannot draw — the page is the web view, so its area
// shows the page's ground here and the device runs show the rest.
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
import 'run_harness.dart';

/// What the header shows.
enum RunPhoneState {
  /// Booted, before `group.ready`: the picker's loading words.
  ready,

  /// `group.ready` names the run.
  named,

  /// Named, seats held: the clock.
  held,

  /// The run could not be shown: the event picker's failure view.
  failed,
}

Future<SeatLayerPickerStrings> _pumpRun(
  WidgetTester tester,
  Phone phone,
  RunPhoneState state, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Locale locale = const Locale('en'),
  bool golden = false,
}) async {
  // The page FR01 pairs with: it honours `appBar`.
  final page = RunPage(useFakeWebViewPlatform(), hello: runHelloAppBar);
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
            onPressed: () => showSeatLayerRunPicker(
              context,
              configuration: runConfiguration,
              // A test has no system font; Roboto measures the words as a
              // buyer sees them.
              theme: const SeatLayerPickerThemeData(fontFamily: 'Roboto'),
              strings: strings,
              onClose: () {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  if (state == RunPhoneState.failed) {
    await page.fail(tester);
    await pumpToRest(tester);
    return strings;
  }
  await page.boot(tester);
  if (state != RunPhoneState.ready) page.ready('The Lantern Keeper');
  if (state == RunPhoneState.held) page.held('pghop_a');
  await pumpToRest(tester);
  return strings;
}

void _expectRunLayout(WidgetTester tester, Phone phone,
    RunPhoneState state, SeatLayerPickerStrings strings) {
  expectPhoneLayout(tester, phone, strings);
  // The bar stands under the safe area's top; the page fills the rest.
  final bar = tester.getRect(find.byType(SeatLayerHeaderBar));
  final page = tester.getRect(find.byType(
    state == RunPhoneState.failed
        ? SeatLayerPickerErrorView
        : SeatLayerRunView,
  ));
  // Under the status bar, on the page's ground, as on the event page.
  expect(bar.top, phone.insets.top);
  expect(page.top, moreOrLessEquals(bar.bottom));
  // The web view passes no bottom inset to the page, so the app keeps it
  // clear of the home indicator (the failure view is the app's own and needs
  // no room).
  expect(
    page.bottom,
    state == RunPhoneState.failed
        ? phone.size.height
        : phone.size.height - phone.insets.bottom,
  );
  expect(page.left, moreOrLessEquals(phone.insets.left));
  expect(page.right, moreOrLessEquals(phone.size.width - phone.insets.right));
  expect(find.byTooltip(strings.close), findsOneWidget);
  expect(
    find.byType(SeatLayerHoldClock),
    state == RunPhoneState.held ? findsOneWidget : findsNothing,
  );
  if (state == RunPhoneState.failed) {
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
        for (final state in RunPhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings =
                await _pumpRun(tester, phone, state, textScale: textScale);
            _expectRunLayout(tester, phone, state, strings);
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
        final strings = await _pumpRun(
          tester,
          phone,
          RunPhoneState.named,
          brightness: Brightness.dark,
        );
        _expectRunLayout(tester, phone, RunPhoneState.named, strings);
        semantics.dispose();
      });
    }
  });

  group('right to left, Arabic', () {
    for (final phone in uprightPhones.where(
      (phone) => phone.name == '320' || phone.name == '390',
    )) {
      for (final textScale in const <double>[1, 1.3, 2]) {
        for (final state in RunPhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings = await _pumpRun(
              tester,
              phone,
              state,
              textScale: textScale,
              locale: const Locale('ar'),
            );
            _expectRunLayout(tester, phone, state, strings);
            semantics.dispose();
          });
        }
      }
    }
  });

  group('sideways', () {
    for (final phone in sidewaysPhones) {
      for (final textScale in const <double>[1, 1.3]) {
        for (final state in RunPhoneState.values) {
          testWidgets('$phone, text $textScale, ${state.name}', (tester) async {
            final semantics = tester.ensureSemantics();
            final strings =
                await _pumpRun(tester, phone, state, textScale: textScale);
            _expectRunLayout(tester, phone, state, strings);
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
      RunPhoneState state, {
      Brightness brightness = Brightness.light,
      double textScale = 1,
      Locale locale = const Locale('en'),
    }) async {
      await _pumpRun(
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
      for (final state in RunPhoneState.values) {
        final name = 'run_390_${state.name}_${brightness.name}';
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
      final name = 'run_${phone.name}_held_light${_scale(textScale)}';
      testWidgets(name, tags: goldenTag, (tester) async {
        await shoot(tester, name, phone, RunPhoneState.held,
            textScale: textScale);
      });
    }
    testWidgets('run_320_failed_light_t20', tags: goldenTag,
        (tester) async {
      await shoot(tester, 'run_320_failed_light_t20', phone320,
          RunPhoneState.failed,
          textScale: 2);
    });
    testWidgets('run_390_ar_held_light', tags: goldenTag, (tester) async {
      await shoot(
          tester, 'run_390_ar_held_light', phone390, RunPhoneState.held,
          locale: const Locale('ar'));
    });
    final sideways = sidewaysPhones.first;
    testWidgets('run_${sideways.name}_held_light', tags: goldenTag,
        (tester) async {
      await shoot(tester, 'run_${sideways.name}_held_light', sideways,
          RunPhoneState.held);
    });
  }, skip: goldenSkip);
}
