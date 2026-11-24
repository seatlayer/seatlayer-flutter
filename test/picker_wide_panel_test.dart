// The wide composition: the control column at
// the map's bottom end, the prices as a named list, and the panel's foot as a
// summary line over one full-width button.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_price_list.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_wide_panel.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const Size _tablet = Size(1024, 768);

/// The panel's inner width: its width, less its hairline and side padding.
const double _inner = SeatLayerSizeTokens.widePanelWidth -
    1 -
    2 * SeatLayerSizeTokens.widePanelPadX;

BundleInfo _bundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'category-availability-v1',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setCategoryFilter',
        'picker.overview',
        'picker.zoomIn',
        'picker.zoomOut',
      ],
    );

Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(),
      ),
    );

/// [snapshot] with its catalogue's categories replaced by [categories].
Map<String, Object?> _withCategories(
  Map<String, Object?> snapshot,
  List<Map<String, Object?>> categories, {
  List<Object?> filter = const <Object?>[],
}) =>
    <String, Object?>{
      ...snapshot,
      'catalog': <String, Object?>{
        ...snapshot['catalog']! as Map<String, Object?>,
        'categories': categories,
      },
      'map': <String, Object?>{
        ...snapshot['map']! as Map<String, Object?>,
        'categoryFilter': filter,
      },
    };

Map<String, Object?> _category(
  String key,
  String label,
  double price, {
  String color = '#635BFF',
  int? free,
}) =>
    <String, Object?>{
      'key': key,
      'label': label,
      'color': color,
      'priceMin': price,
      'priceMax': price,
      'available': 40,
      if (free != null) 'free': free,
      'notForSale': false,
    };

Map<String, Object?> _stands({List<Object?> filter = const <Object?>[]}) =>
    _withCategories(
      pickerSnapshot(withSelection: false),
      <Map<String, Object?>>[
        _category('north', 'North Stand', 22, color: '#2F80ED'),
        _category('main', 'Main Stand', 28, color: '#27AE60'),
        _category('east', 'East Stand', 34, color: '#F2994A', free: 0),
      ],
      filter: filter,
    );

Future<FakePickerMap> _mount(
  WidgetTester tester,
  Map<String, Object?> snapshot, {
  Widget? child,
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
}) async {
  final map = FakePickerMap(bundle: _bundle());
  addTearDown(map.dispose);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _tablet;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    pickerHarness(
      map,
      Directionality(textDirection: direction, child: child ?? _layout()),
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
  group('the control column', () {
    for (final direction in TextDirection.values) {
      final rtl = direction == TextDirection.rtl;
      testWidgets('stands at the map\'s bottom end — ${direction.name}',
          (tester) async {
        await _mount(
          tester,
          pickerSnapshot(withSelection: false, rung: 'overview'),
          direction: direction,
        );

        const inset = SeatLayerSizeTokens.mapAnchorInset;
        const mapWidth = 1024 - SeatLayerSizeTokens.widePanelWidth;
        final column = _rect(tester, find.byType(SeatLayerPickerMapControls));
        // The last disc is the column's foot; the column's own padding
        // below it is the same seven points on every control.
        final stepOut =
            _rect(tester, find.byType(SeatLayerPickerZoomOutButton));
        expect(column.bottom, closeTo(_tablet.height - inset, .5));
        expect(stepOut.bottom, lessThanOrEqualTo(column.bottom));
        expect(stepOut.top, greaterThan(_tablet.height / 2));
        if (rtl) {
          // The panel is on the left; the map, and its end edge, after it.
          expect(
            column.left,
            closeTo(SeatLayerSizeTokens.widePanelWidth + inset, .5),
          );
        } else {
          expect(column.right, closeTo(mapWidth - inset, .5));
        }
      });
    }

    testWidgets('the way back joins the top and moves nothing below it',
        (tester) async {
      final map = await _mount(
        tester,
        pickerSnapshot(withSelection: false, rung: 'overview'),
      );
      final before = _rect(tester, find.byType(SeatLayerPickerZoomOutButton));
      expect(find.byType(SeatLayerPickerOverviewButton), findsNothing);

      map.emit(pickerSnapshot(withSelection: false, revision: 2));
      await tester.pumpAndSettle();

      expect(find.byType(SeatLayerPickerOverviewButton), findsOneWidget);
      expect(
        _rect(tester, find.byType(SeatLayerPickerZoomOutButton)),
        before,
      );
      expect(
        _rect(tester, find.byType(SeatLayerPickerOverviewButton)).bottom,
        lessThanOrEqualTo(
          _rect(tester, find.byType(SeatLayerPickerViewModeButton)).top + .5,
        ),
      );
    });
  });

  group('the price list', () {
    for (final brightness in Brightness.values) {
      testWidgets('names every price — ${brightness.name}', (tester) async {
        await _mount(tester, _stands(), brightness: brightness);

        expect(find.byType(SeatLayerWidePriceList), findsOneWidget);
        for (final (name, price) in <(String, String)>[
          ('North Stand', '€22'),
          ('Main Stand', '€28'),
          ('East Stand', '€34'),
        ]) {
          expect(find.text(name), findsOneWidget);
          expect(find.text(price), findsOneWidget);
          // Name at the start, price at the end, on one row.
          expect(
            _rect(tester, find.text(name)).center.dy,
            closeTo(_rect(tester, find.text(price)).center.dy, 1),
          );
          expect(
            _rect(tester, find.text(price)).left,
            greaterThan(_rect(tester, find.text(name)).right),
          );
        }
        // One row under another, in the panel's own ink.
        expect(
          _rect(tester, find.text('Main Stand')).top,
          greaterThan(_rect(tester, find.text('North Stand')).bottom),
        );
        final theme =
            seatLayerPickerThemeOf(tester.element(find.text('North Stand')));
        expect(
          tester.widget<Text>(find.text('North Stand')).style!.color,
          theme.text,
        );
        expect(
          tester
              .getSize(find.ancestor(
                of: find.text('North Stand'),
                matching: find.byType(InkWell),
              ))
              .height,
          greaterThanOrEqualTo(SeatLayerSizeTokens.widePriceRowHeight),
        );
      });
    }

    testWidgets('a row filters the map to its price, and back', (tester) async {
      final map = await _mount(tester, _stands());

      await tester.tap(find.text('Main Stand'));
      await tester.pump();
      expect(map.callsTo('picker.setCategoryFilter').last.$2, <String, Object?>{
        'categoryKeys': <String>['main'],
        'focus': true,
      });

      // A later revision, or the picker keeps the newer one it has.
      map.emit(_stands(filter: <Object?>['main'])..['revision'] = 10);
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Main Stand — €28')),
        isSemantics(isSelected: true, isButton: true),
      );
      semantics.dispose();

      await tester.tap(find.text('Main Stand'));
      await tester.pump();
      expect(map.callsTo('picker.setCategoryFilter').last.$2, <String, Object?>{
        // Cleared, the way the rail's chips clear it.
        'categoryKeys': null,
        'focus': true,
      });
    });

    testWidgets('a sold-out price is struck through and still a toggle',
        (tester) async {
      final map = await _mount(tester, _stands());

      expect(
        tester.widget<Text>(find.text('€34')).style!.decoration,
        TextDecoration.lineThrough,
      );
      expect(
        tester.widget<Text>(find.text('€22')).style!.decoration,
        isNot(TextDecoration.lineThrough),
      );
      await tester.tap(find.text('East Stand'));
      await tester.pump();
      expect(map.callsTo('picker.setCategoryFilter'), hasLength(1));
    });

    testWidgets('a long list scrolls inside its bound', (tester) async {
      await _mount(
        tester,
        _withCategories(
          pickerSnapshot(withSelection: false),
          <Map<String, Object?>>[
            for (var index = 0; index < 12; index++)
              _category('c$index', 'Band $index', 20.0 + index),
          ],
        ),
      );

      expect(
        _rect(tester, find.byType(SeatLayerWidePriceList)).height,
        lessThanOrEqualTo(SeatLayerSizeTokens.widePriceListMaxHeight + .5),
      );
      // The buyer's seats are still in view under it.
      expect(find.text('Your seats').hitTestable(), findsOneWidget);
    });

    testWidgets('in Arabic the price stands at the left', (tester) async {
      await _mount(
        tester,
        _stands(),
        direction: TextDirection.rtl,
        options: SeatLayerPickerOptions(
          strings: SeatLayerPickerStrings.forLocale(const Locale('ar')),
        ),
      );

      final name = _rect(tester, find.text('North Stand'));
      final price = _rect(
        tester,
        find.descendant(
          of: find.byType(SeatLayerWidePriceList),
          matching: find.textContaining('22'),
        ),
      );
      expect(price.right, lessThan(name.left));
    });
  });

  group('the panel foot', () {
    Finder button() => find.descendant(
          of: find.byType(SeatLayerWideCheckoutFoot),
          matching: find.byType(FilledButton),
        );

    testWidgets('empty: "No seats selected" over "Find best seats", off',
        (tester) async {
      await _mount(tester, pickerSnapshot(withSelection: false));

      expect(find.text('No seats selected'), findsOneWidget);
      expect(
        find.descendant(of: button(), matching: find.text('Find best seats')),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(button()).onPressed, isNull);
      // Full width, under the line.
      expect(_rect(tester, button()).width, closeTo(_inner, .5));
      expect(
        _rect(tester, button()).top,
        greaterThan(_rect(tester, find.text('No seats selected')).bottom),
      );
    });

    for (final (name, options) in <(String, SeatLayerPickerOptions)>[
      (
        'best seats switched off',
        const SeatLayerPickerOptions(enableBestAvailable: false),
      ),
      ('a read-only picker', const SeatLayerPickerOptions(readOnly: true)),
    ]) {
      testWidgets('empty, with $name: "Select seats", off', (tester) async {
        await _mount(
          tester,
          pickerSnapshot(withSelection: false),
          options: options,
        );

        // No best-seats card to point at, so no way to seats is named.
        expect(
          find.descendant(of: button(), matching: find.text('Select seats')),
          findsOneWidget,
        );
        expect(find.text('Find best seats'), findsNothing);
        expect(tester.widget<FilledButton>(button()).onPressed, isNull);
      });
    }

    testWidgets('with seats held: the count and total over the checkout',
        (tester) async {
      await _mount(tester, pickerSnapshot(holdOwner: 'picker'));

      expect(find.text('1 ticket'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SeatLayerWideCheckoutFoot),
          matching: find.text('€25'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: button(),
          matching: find.text('Continue to checkout'),
        ),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(button()).onPressed, isNotNull);
      expect(_rect(tester, button()).width, closeTo(_inner, .5));
      // The cards above already name the seats; the foot does not repeat
      // them.
      expect(
        find.descendant(
          of: find.byType(SeatLayerWideCheckoutFoot),
          matching: find.textContaining('A · 1'),
        ),
        findsNothing,
      );
    });

    testWidgets('sales closed: the button says so, off', (tester) async {
      final snapshot = pickerSnapshot(withSelection: false);
      (snapshot['event']! as Map<String, Object?>)['salesClosed'] = true;
      await _mount(tester, snapshot);

      expect(
        find.descendant(of: button(), matching: find.text('Sales closed')),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(button()).onPressed, isNull);
    });
  });
}
