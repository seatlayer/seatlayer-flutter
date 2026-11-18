// The wide composition: the header's date line, the side panel's headings and
// foot, the order of the map's control column, and the wide seat card's labels.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_attribution.dart';
import 'package:seatlayer/src/picker/picker_best_seats.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_legend.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_seat_confirmation.dart';
import 'package:seatlayer/src/picker/picker_status_views.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_wide_panel.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// A tablet held landscape: wide by the picker's own breakpoint.
const Size _tablet = Size(1024, 768);

void _useTablet(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _tablet;
  addTearDown(tester.view.reset);
}

BundleInfo _bundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'colorblind-safe',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setColorblindSafe',
        'picker.overview',
        'picker.zoomIn',
        'picker.zoomOut',
      ],
    );

/// The drop-in layout with the web view replaced.
Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(),
      ),
    );

/// [pickerSnapshot] with its event block changed by [event].
Map<String, Object?> _withEvent(
  Map<String, Object?> snapshot,
  Map<String, Object?> Function(Map<String, Object?> event) event,
) =>
    <String, Object?>{
      ...snapshot,
      'event': event(<String, Object?>{
        ...snapshot['event']! as Map<String, Object?>,
      }),
    };

/// [pickerSnapshot] with no price to name yet: no category, no filter.
Map<String, Object?> _noPrices() {
  final snapshot = pickerSnapshot(withSelection: false);
  return <String, Object?>{
    ...snapshot,
    'catalog': <String, Object?>{
      ...snapshot['catalog']! as Map<String, Object?>,
      'categories': <Object?>[],
    },
    'map': <String, Object?>{
      ...snapshot['map']! as Map<String, Object?>,
      'categoryFilter': <Object?>[],
    },
  };
}

Future<FakePickerMap> _mount(
  WidgetTester tester,
  Widget child,
  Map<String, Object?> snapshot, {
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
}) async {
  final map = FakePickerMap(bundle: _bundle());
  addTearDown(map.dispose);
  _useTablet(tester);
  await tester.pumpWidget(
    pickerHarness(
      map,
      Directionality(textDirection: direction, child: child),
      options: options,
      platformBrightness: brightness,
    ),
  );
  map.emit(snapshot);
  await pumpToRest(tester);
  return map;
}

Rect _rect(WidgetTester tester, Finder finder) => tester.getRect(finder.first);

void main() {
  group('the wide header', () {
    const header = SeatLayerPickerHeader(compact: false);

    testWidgets('draws the runtime\'s date label before the venue',
        (tester) async {
      await _mount(
        tester,
        header,
        _withEvent(
          pickerSnapshot(),
          (event) => event
            ..['startsAt'] = 1786806000000.0
            ..['timezone'] = 'Europe/London'
            ..['startsAtLabel'] = 'Sat 15 Aug · 15:00',
        ),
      );

      expect(
        find.text('Sat 15 Aug · 15:00 · Riverside Auditorium'),
        findsOneWidget,
      );
    });

    testWidgets('with only an instant, draws no date at all', (tester) async {
      // An instant and a zone name, and no label: formatting it here would
      // print the device's hour, which is not the venue's.
      await _mount(
        tester,
        header,
        _withEvent(
          pickerSnapshot(),
          (event) => event
            ..['startsAt'] = 1786806000000.0
            ..['timezone'] = 'Europe/London',
        ),
      );

      expect(find.text('Riverside Auditorium'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\d{1,2}:\d{2}')), findsNothing);
      expect(find.textContaining(' · '), findsNothing);
    });

    testWidgets('with no start at all, names the venue alone', (tester) async {
      await _mount(tester, header, pickerSnapshot());

      expect(find.text('Riverside Auditorium'), findsOneWidget);
      expect(find.textContaining(' · '), findsNothing);
    });

    testWidgets('a label without a venue stands alone', (tester) async {
      await _mount(
        tester,
        header,
        _withEvent(
          pickerSnapshot(),
          (event) => event
            ..remove('venue')
            ..['startsAtLabel'] = 'Sat 15 Aug · 15:00',
        ),
      );

      expect(find.text('Sat 15 Aug · 15:00'), findsOneWidget);
    });

    testWidgets('the phone header stays one line, with no date',
        (tester) async {
      await _mount(
        tester,
        const SeatLayerPickerHeader(compact: true),
        _withEvent(
          pickerSnapshot(),
          (event) => event..['startsAtLabel'] = 'Sat 15 Aug · 15:00',
        ),
      );

      expect(find.textContaining('Sat 15 Aug'), findsNothing);
    });
  });

  group('the wide panel', () {
    for (final brightness in Brightness.values) {
      testWidgets('names the prices and the seats — ${brightness.name}',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await _mount(
          tester,
          _layout(),
          pickerSnapshot(withSelection: false),
          brightness: brightness,
        );

        final prices = find.text('Ticket prices');
        final seats = find.text('Your seats');
        expect(prices, findsOneWidget);
        expect(seats, findsOneWidget);
        // Each heading stands over what it names.
        expect(
          _rect(tester, prices).bottom,
          lessThanOrEqualTo(
            _rect(tester, find.byType(SeatLayerPriceLegend)).top + .5,
          ),
        );
        expect(
          _rect(tester, seats).bottom,
          lessThanOrEqualTo(
            _rect(tester, find.byType(SeatLayerBestSeatsForm)).top + .5,
          ),
        );
        expect(
          _rect(tester, find.byType(SeatLayerPriceLegend)).bottom,
          lessThanOrEqualTo(_rect(tester, seats).top + .5),
        );
        // The seats heading stands a little further from what is above it.
        for (final (label, air) in <(String, double)>[
          ('Ticket prices', SeatLayerSizeTokens.widePanelHeadingPadTop),
          ('Your seats', SeatLayerSizeTokens.widePanelSeatsHeadingPadTop),
        ]) {
          final heading = find.ancestor(
            of: find.text(label),
            matching: find.byType(SeatLayerWidePanelHeading),
          );
          expect(
            _rect(tester, find.text(label)).top - _rect(tester, heading).top,
            closeTo(air, .5),
            reason: label,
          );
        }
        // In the panel's quiet ink, on either side.
        final theme = seatLayerPickerThemeOf(tester.element(prices));
        expect(tester.widget<Text>(prices).style!.color, theme.mutedText);
        expect(
          theme.mutedText,
          brightness == Brightness.dark
              ? isNot(SeatLayerLightTokens.mutedText)
              : SeatLayerLightTokens.mutedText,
        );
        // Headings a screen reader can step between.
        for (final label in <String>['Ticket prices', 'Your seats']) {
          expect(
            tester.getSemantics(find.bySemanticsLabel(label)),
            isSemantics(label: label, isHeader: true),
            reason: label,
          );
        }
        semantics.dispose();
      });
    }

    testWidgets('names no prices while there are none', (tester) async {
      await _mount(tester, _layout(), _noPrices());

      expect(find.text('Ticket prices'), findsNothing);
      expect(find.text('Your seats'), findsOneWidget);
    });

    testWidgets('names no seats while the picker is still loading',
        (tester) async {
      final map = FakePickerMap(bundle: _bundle());
      addTearDown(map.dispose);
      _useTablet(tester);
      await tester.pumpWidget(pickerHarness(map, _layout()));
      await tester.pump();

      expect(find.byType(SeatLayerWidePanelHeading), findsNothing);
    });

    testWidgets('the credit sits under the checkout bar', (tester) async {
      await _mount(tester, _layout(), pickerSnapshot());

      final bar = _rect(tester, find.byType(SeatLayerPickerCheckoutBar));
      final credit = _rect(tester, find.byType(SeatLayerPickerAttribution));
      expect(credit.top, greaterThanOrEqualTo(bar.bottom - .5));
      // And the panel ends where the screen does: nothing hangs below it.
      expect(credit.bottom, lessThanOrEqualTo(_tablet.height + .5));
    });

    testWidgets('the device inset is taken once, under the credit',
        (tester) async {
      final map = FakePickerMap(bundle: _bundle());
      addTearDown(map.dispose);
      _useTablet(tester);
      tester.view.padding = const FakeViewPadding(bottom: 20);
      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(pickerSnapshot());
      await pumpToRest(tester);

      final button = _rect(
        tester,
        find.descendant(
          of: find.byType(SeatLayerPickerCheckoutBar),
          matching: find.byType(FilledButton),
        ),
      );
      final credit = _rect(tester, find.byType(SeatLayerPickerAttribution));
      // No inset-sized gap between the button and the line under it.
      expect(credit.top - button.bottom, lessThan(20));
      expect(credit.bottom, lessThanOrEqualTo(_tablet.height - 20 + .5));
    });

    for (final direction in TextDirection.values) {
      final rtl = direction == TextDirection.rtl;
      testWidgets('the panel and its hairline follow ${direction.name}',
          (tester) async {
        await _mount(
          tester,
          _layout(),
          pickerSnapshot(withSelection: false),
          direction: direction,
          options: rtl
              ? SeatLayerPickerOptions(
                  strings: SeatLayerPickerStrings.forLocale(const Locale('ar')),
                )
              : const SeatLayerPickerOptions(),
        );

        final panel = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth ==
                  SeatLayerSizeTokens.widePanelWidth,
        );
        expect(panel, findsOneWidget);
        final box =
            tester.widget<Container>(panel).decoration! as BoxDecoration;
        final border = box.border! as BorderDirectional;
        // The hairline is on the edge that meets the map, whichever side
        // that is: the start edge.
        expect(border.start.style, BorderStyle.solid);
        expect(border.end, BorderSide.none);
        final rect = _rect(tester, panel);
        if (rtl) {
          expect(rect.left, closeTo(0, .5));
        } else {
          expect(rect.right, closeTo(_tablet.width, .5));
        }
        // The headings read from the panel's start edge, in the buyer's
        // language.
        final heading = find.text(rtl ? 'أسعار التذاكر' : 'Ticket prices');
        expect(heading, findsOneWidget);
        expect(find.text(rtl ? 'مقاعدك' : 'Your seats'), findsOneWidget);
        final words = _rect(tester, heading);
        // The hairline's own point, then the panel's side padding.
        final inset = border.start.width + SeatLayerSizeTokens.widePanelPadX;
        if (rtl) {
          expect(words.right, closeTo(rect.right - inset, .5));
        } else {
          expect(words.left, closeTo(rect.left + inset, .5));
        }
      });
    }
  });

  group('the wide control column', () {
    const column = SeatLayerPickerMapControls(compact: false);

    testWidgets(
        'with a section framed: Venue, Map | 3D, display options, '
        '+, −', (tester) async {
      await _mount(tester, column, pickerSnapshot(withSelection: false));

      final order = <Finder>[
        find.byType(SeatLayerPickerOverviewButton),
        find.byType(SeatLayerPickerViewModeButton),
        find.byType(SeatLayerPickerAccessibilityFilters),
        find.byType(SeatLayerPickerZoomInButton),
        find.byType(SeatLayerPickerZoomOutButton),
      ];
      for (final control in order) {
        expect(control, findsOneWidget);
      }
      for (var index = 1; index < order.length; index++) {
        expect(
          _rect(tester, order[index - 1]).bottom,
          lessThanOrEqualTo(_rect(tester, order[index]).top + .5),
          reason: 'control $index',
        );
      }
      // The palette is a switch in the display options; no second copy.
      expect(find.byType(SeatLayerPickerColorblindButton), findsNothing);
    });

    testWidgets('at the whole venue, Map | 3D heads the column',
        (tester) async {
      await _mount(
        tester,
        column,
        pickerSnapshot(withSelection: false, rung: 'overview'),
      );

      expect(find.byType(SeatLayerPickerOverviewButton), findsNothing);
      final head = _rect(tester, find.byType(SeatLayerPickerViewModeButton));
      expect(
        head.top,
        closeTo(_rect(tester, find.byType(SeatLayerPickerMapControls)).top, .5),
      );
      expect(
        head.bottom,
        lessThanOrEqualTo(
          _rect(tester, find.byType(SeatLayerPickerAccessibilityFilters)).top +
              .5,
        ),
      );
    });

    testWidgets('a host that asks for the colour-blind toggle gets it last',
        (tester) async {
      await _mount(
        tester,
        column,
        pickerSnapshot(withSelection: false),
        options: const SeatLayerPickerOptions(
          chrome: SeatLayerPickerChromeOptions(showColorblindControl: true),
        ),
      );

      final toggle = find.byType(SeatLayerPickerColorblindButton);
      expect(toggle, findsOneWidget);
      expect(
        _rect(tester, toggle).top,
        greaterThanOrEqualTo(
          _rect(tester, find.byType(SeatLayerPickerZoomOutButton)).bottom - .5,
        ),
      );
    });

    test('the toggle is off by default on both widths', () {
      const chrome = SeatLayerPickerChromeOptions();
      expect(chrome.colorblindControlFor(phone: false), isFalse);
      expect(chrome.colorblindControlFor(phone: true), isFalse);
      const asked = SeatLayerPickerChromeOptions(showColorblindControl: true);
      expect(asked.colorblindControlFor(phone: false), isTrue);
      expect(asked.colorblindControlFor(phone: true), isTrue);
    });
  });

  group('the wide seat card', () {
    testWidgets('draws its labels as the strings give them', (tester) async {
      await _mount(
        tester,
        const SeatLayerPickerSeatConfirmation(),
        pickerSnapshot(),
      );

      expect(find.text('Section'), findsOneWidget);
      expect(find.text('Row'), findsOneWidget);
      expect(find.text('Seat'), findsOneWidget);
      expect(find.text('SECTION'), findsNothing);
    });

    testWidgets('and never upper-cases a language in code', (tester) async {
      final turkish = SeatLayerPickerStrings.forLocale(const Locale('tr'));
      await _mount(
        tester,
        const SeatLayerPickerSeatConfirmation(),
        pickerSnapshot(),
        options: SeatLayerPickerOptions(strings: turkish),
      );

      // The row's label is the seat's own word, from the chart; section and
      // seat are the translator's, letter for letter. Dart's toUpperCase
      // would turn `i` into `I` where Turkish writes `İ`.
      expect(find.text(turkish.sectionWord), findsOneWidget);
      expect(find.text(turkish.seatWord), findsOneWidget);
      expect(find.text(turkish.sectionWord.toUpperCase()), findsNothing);
    });
  });
}
