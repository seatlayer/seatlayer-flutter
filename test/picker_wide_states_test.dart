// The wide layout's states: the panel while the picker loads, the
// accessibility options as a popover beside their control, and the 3D
// Rotate / Move pair when its words do not fit.
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_accessibility.dart';
import 'package:seatlayer/src/picker/picker_accessibility_popover.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_map_controls.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';
import 'package:seatlayer/src/picker/picker_venue_3d.dart';
import 'package:seatlayer/src/picker/picker_wide_panel.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_theme.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const Size _tablet = Size(1024, 768);

void _useSurface(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

/// [child] with the ambient media changed by [edit].
Widget _withMedia(
  Widget child,
  MediaQueryData Function(MediaQueryData media) edit,
) =>
    Builder(
      builder: (context) => MediaQuery(
        data: edit(MediaQuery.of(context)),
        child: child,
      ),
    );

Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(),
      ),
    );

BundleInfo _scene3DBundle() => nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'venue-3d-controls-v1',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setBuyerView',
        'picker.setVenue3DNavigationMode',
      ],
    );

/// The bars the loading panel draws, in paint order.
List<Rect> _bars(WidgetTester tester, Color ink) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(SeatLayerWidePanelLoading),
        matching: find.byType(Container),
      ),
    )
    .where(
      (box) =>
          box.decoration is BoxDecoration &&
          (box.decoration! as BoxDecoration).color == ink,
    )
    .map((box) => tester.getRect(find.byWidget(box)))
    .toList(growable: false);

/// The focus node of the accessibility control's button.
FocusNode _controlFocus(WidgetTester tester) => Focus.of(
      tester.element(
        find
            .descendant(
              of: find.byType(SeatLayerPickerAccessibilityFilters),
              matching: find.byType(Icon),
            )
            .first,
      ),
    );

double _breath(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(SeatLayerWidePanelLoading),
            matching: find.byType(FadeTransition),
          )
          .first,
    )
    .opacity
    .value;

void main() {
  group('the wide panel while loading', () {
    for (final brightness in Brightness.values) {
      testWidgets('holds its shape in grey bars — ${brightness.name}',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        _useSurface(tester, _tablet);
        await tester.pumpWidget(
          pickerHarness(map, _layout(), platformBrightness: brightness),
        );
        await tester.pump();

        expect(find.byType(SeatLayerWidePanelLoading), findsOneWidget);
        expect(find.text('Ticket prices'), findsOneWidget);
        expect(find.text('Your seats'), findsNothing);
        expect(find.byType(SeatLayerWideCheckoutFoot), findsNothing);
        final theme = seatLayerPickerThemeOf(
          tester.element(find.byType(SeatLayerWidePanelLoading)),
        );
        final bars = _bars(tester, theme.divider);
        // Three where the prices go, then the foot's line and its button.
        expect(bars, hasLength(5));
        const inner = SeatLayerSizeTokens.widePanelWidth -
            1 -
            2 * SeatLayerSizeTokens.widePanelPadX;
        for (final (index, fraction)
            in SeatLayerWidePanelLoading.priceBarFractions.indexed) {
          expect(bars[index].width, closeTo(inner * fraction, .5));
          expect(
            bars[index].height,
            SeatLayerSizeTokens.widePanelPlaceholderBarHeight,
          );
        }
        expect(
          bars[3].width,
          closeTo(inner * SeatLayerWidePanelLoading.footBarFraction, .5),
        );
        expect(bars[4].width, closeTo(inner, .5));
        expect(
          bars[4].height,
          SeatLayerSizeTokens.widePanelPlaceholderButtonHeight,
        );
        // The foot's bars sit at the foot.
        expect(bars[4].bottom, greaterThan(_tablet.height - 40));
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }

    testWidgets('gives way to the real panel when the snapshot lands',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      _useSurface(tester, _tablet);
      await tester.pumpWidget(pickerHarness(map, _layout()));
      await tester.pump();
      expect(find.byType(SeatLayerWidePanelLoading), findsOneWidget);

      map.emit(pickerSnapshot());
      await pumpToRest(tester);

      expect(find.byType(SeatLayerWidePanelLoading), findsNothing);
      expect(find.text('Your seats'), findsOneWidget);
      expect(find.byType(SeatLayerWideCheckoutFoot), findsOneWidget);
    });

    testWidgets('breathes with the venue outline', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      _useSurface(tester, _tablet);
      await tester.pumpWidget(pickerHarness(map, _layout()));
      await tester.pump();
      final first = _breath(tester);
      await tester.pump(
        const Duration(milliseconds: SeatLayerMotionTokens.loadingBreath ~/ 2),
      );
      expect(_breath(tester), isNot(closeTo(first, .01)));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('stands still under reduced motion', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      _useSurface(tester, _tablet);
      await tester.pumpWidget(
        pickerHarness(
          map,
          _withMedia(
            _layout(),
            (media) => media.copyWith(disableAnimations: true),
          ),
        ),
      );
      await tester.pump();
      expect(_breath(tester), 1);
      await tester.pump(
        const Duration(milliseconds: SeatLayerMotionTokens.loadingBreath ~/ 2),
      );
      expect(_breath(tester), 1);
    });
  });

  group('the wide accessibility options', () {
    Future<FakePickerMap> open(
      WidgetTester tester, {
      required bool wide,
      TextDirection direction = TextDirection.ltr,
      SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
      bool keyboard = false,
      VoidCallback? onMapTap,
      List<String> needs = const <String>['wheelchair'],
    }) async {
      final map = FakePickerMap(bundle: accessibilityFocusBundle());
      addTearDown(map.dispose);
      _useSurface(tester, wide ? _tablet : phoneSize);
      await tester.pumpWidget(
        pickerHarness(
          map,
          Directionality(
            textDirection: direction,
            child: Stack(
              children: <Widget>[
                // The map under the column, counting the taps it receives.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onMapTap,
                  ),
                ),
                // Where the layout stands the column: the map's top end.
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(
                      SeatLayerSizeTokens.mapAnchorInset,
                    ),
                    child: SeatLayerPickerMapControls(compact: !wide),
                  ),
                ),
              ],
            ),
          ),
          options: options,
        ),
      );
      map.emit(
        pickerSnapshot(
          withSelection: false,
          accessNeeds: <Object?>[for (final need in needs) accessNeed(need, 15)],
        ),
      );
      await tester.pumpAndSettle();
      final control = find.descendant(
        of: find.byType(SeatLayerPickerAccessibilityFilters),
        matching: find.byType(IconButton),
      );
      if (keyboard) {
        _controlFocus(tester).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      } else {
        await tester.tap(control);
      }
      await tester.pumpAndSettle();
      return map;
    }

    Finder popover() => find.ancestor(
          of: find.text('Accessibility and view'),
          matching: find.byType(Material),
        );

    for (final direction in TextDirection.values) {
      final rtl = direction == TextDirection.rtl;
      testWidgets(
          'open beside the control, not over the map — '
          '${direction.name}', (tester) async {
        await open(
          tester,
          wide: true,
          direction: direction,
          options: rtl
              ? SeatLayerPickerOptions(
                  strings: SeatLayerPickerStrings.forLocale(const Locale('ar')),
                )
              : const SeatLayerPickerOptions(),
        );
        final strings = rtl
            ? SeatLayerPickerStrings.forLocale(const Locale('ar'))
            : const SeatLayerPickerStrings();
        final title = strings.accessibilityTitle;
        final card = find
            .ancestor(of: find.text(title), matching: find.byType(Material))
            .first;

        expect(find.byType(BottomSheet), findsNothing);
        expect(card, findsOneWidget);
        final box = tester.getRect(card);
        final control =
            tester.getRect(find.byType(SeatLayerPickerAccessibilityFilters));
        expect(box.width, SeatLayerSizeTokens.accessPopoverWidth);
        // On the control's start side, towards the map, level with its top.
        if (rtl) {
          expect(
            box.left,
            closeTo(control.right + SeatLayerSizeTokens.accessPopoverGap, .5),
          );
        } else {
          expect(
            box.right,
            closeTo(control.left - SeatLayerSizeTokens.accessPopoverGap, .5),
          );
        }
        expect(box.top, closeTo(control.top, .5));
        // The same rows the sheet carries.
        expect(find.text(strings.accessFreeCount(15)), findsOneWidget);
      });
    }

    testWidgets('close on Escape', (tester) async {
      await open(tester, wide: true);
      expect(popover(), findsWidgets);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Accessibility and view'), findsNothing);
    });

    testWidgets('close on a tap outside', (tester) async {
      await open(tester, wide: true);

      await tester.tapAt(const Offset(40, 700));
      await tester.pumpAndSettle();

      expect(find.text('Accessibility and view'), findsNothing);
    });

    testWidgets('a pressed count still walks the map', (tester) async {
      final map = await open(tester, wide: true);

      await tester.tap(find.text('15 free'));
      await tester.pumpAndSettle();

      expect(
        map.callsTo('picker.setAccessibilityFilter').single.$2,
        <String, Object?>{
          'types': <String>['wheelchair'],
        },
      );
      expect(map.callsTo('picker.focusNextAccessibleSection'), hasLength(1));
      expect(find.text('Accessibility and view'), findsNothing);
    });

    testWidgets('are a dialog to a screen reader', (tester) async {
      final semantics = tester.ensureSemantics();
      await open(tester, wide: true);

      final dialog = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.role == SemanticsRole.dialog,
      );
      expect(dialog, findsOneWidget);
      final node = tester.getSemantics(dialog);
      expect(node.getSemanticsData().role, SemanticsRole.dialog);
      expect(
        node,
        isSemantics(
          label: 'Accessibility and view',
          scopesRoute: true,
          namesRoute: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('give focus back to their control when they close',
        (tester) async {
      await open(tester, wide: true, keyboard: true);
      expect(find.text('Accessibility and view'), findsOneWidget);
      expect(_controlFocus(tester).hasPrimaryFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Accessibility and view'), findsNothing);
      expect(_controlFocus(tester).hasPrimaryFocus, isTrue);
    });

    testWidgets('a tap outside closes them and never reaches the map',
        (tester) async {
      var mapTaps = 0;
      await open(tester, wide: true, onMapTap: () => mapTaps++);

      await tester.tapAt(const Offset(40, 700));
      await tester.pumpAndSettle();
      expect(find.text('Accessibility and view'), findsNothing);
      expect(mapTaps, 0);

      // With them closed, the same tap is the map's.
      await tester.tapAt(const Offset(40, 700));
      await tester.pumpAndSettle();
      expect(mapTaps, 1);
    });

    testWidgets('close when the window changes size', (tester) async {
      await open(tester, wide: true);
      expect(find.text('Accessibility and view'), findsOneWidget);

      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpAndSettle();

      expect(find.text('Accessibility and view'), findsNothing);
    });

    for (final scale in <double>[1, 1.3, 2]) {
      testWidgets('wrap a long name instead of cutting it — text $scale',
          (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        for (final tag in <String>['en', 'de', 'fr', 'fi', 'ru', 'ar', 'ja']) {
          final strings = SeatLayerPickerStrings.forLocale(Locale(tag));
          await open(
            tester,
            wide: true,
            direction: tag == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            options: SeatLayerPickerOptions(strings: strings),
            needs: strings.accessNeeds.keys.toList(),
          );
          expect(tester.takeException(), isNull, reason: tag);
          for (final name in <String>[
            strings.colorblindSafe,
            ...strings.accessNeeds.values,
          ]) {
            final text = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.text(name, skipOffstage: false).first,
                matching: find.byType(RichText, skipOffstage: false),
              ),
            );
            expect(text.didExceedMaxLines, isFalse, reason: '$tag: $name');
            expect(text.maxLines, isNull, reason: '$tag: $name');
          }
          await tester.pumpWidget(const SizedBox());
        }
      });
    }

    testWidgets('the phone keeps its bottom sheet', (tester) async {
      await open(tester, wide: false);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Accessibility and view'), findsOneWidget);
    });

    test('moves up where it would run off the foot', () {
      const screen = Size(1024, 768);
      const child = Size(320, 400);
      const anchor = Rect.fromLTWH(960, 700, 44, 44);
      for (final direction in TextDirection.values) {
        final layout = SeatLayerAccessPopoverLayout(
          anchor: anchor,
          textDirection: direction,
          padding: EdgeInsets.zero,
          maxHeight: 600,
        );
        final at = layout.getPositionForChild(screen, child);
        // Level with the control's bottom instead of its top.
        expect(at.dy, anchor.bottom - child.height);
        // And never off the screen: in RTL the control's end side has no
        // room, so it is held at the margin.
        expect(
          at.dx,
          direction == TextDirection.rtl
              ? screen.width -
                  SeatLayerSizeTokens.accessPopoverMargin -
                  child.width
              : anchor.left -
                  SeatLayerSizeTokens.accessPopoverGap -
                  child.width,
        );
      }
    });
  });

  group('the 3D Rotate / Move pair', () {
    Future<void> mount(
      WidgetTester tester, {
      required Size size,
      double textScale = 1,
      TextDirection direction = TextDirection.ltr,
      bool targeted = false,
    }) async {
      useFakeWebViewPlatform();
      final fake = FakePickerMap(bundle: _scene3DBundle());
      addTearDown(fake.dispose);
      _useSurface(tester, size);
      final snapshot = snapshotWithTicketCount(1, revision: 3);
      final map = snapshot['map']! as Map<String, Object?>;
      map['buyerView'] = 'venue3d';
      if (targeted) {
        final seat = ((snapshot['selection']! as Map<String, Object?>)['seats']!
                as List<Object?>)
            .first! as Map<String, Object?>;
        map['view3dTargetSeatId'] = seat['id'];
        map['view3dTargetSeat'] = seat;
      }
      await tester.pumpWidget(
        pickerHarness(
          fake,
          Directionality(
            textDirection: direction,
            child: _withMedia(
              const SeatLayerVenue3D(),
              (media) => media.copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
            ),
          ),
          // The pair is drawn only under the older touch gestures.
          options: const SeatLayerPickerOptions(
            touchNavigation3D: SeatLayer3DTouchNavigation.classic,
          ),
        ),
      );
      fake.emit(snapshot);
      await pumpToRest(tester);
    }

    testWidgets('keeps its words where they fit', (tester) async {
      await mount(tester, size: phoneSize);

      expect(find.text('Rotate venue'), findsOneWidget);
      expect(find.text('Move venue'), findsOneWidget);
      expect(find.byIcon(Icons.threesixty_rounded), findsNothing);
    });

    testWidgets('keeps its words beside the back pill', (tester) async {
      await mount(tester, size: phoneSize, targeted: true);

      final pill = tester.getRect(find.text('Back to venue'));
      final pair = tester.getRect(
        find.byType(SeatLayerPicker3DNavigationModeButton),
      );
      expect(find.text('Rotate venue'), findsOneWidget);
      expect(pair.left, greaterThan(pill.right));
      expect(
        pair.right,
        closeTo(phoneSize.width - SeatLayerSizeTokens.mapAnchorInset, .5),
      );
    });

    for (final direction in TextDirection.values) {
      final rtl = direction == TextDirection.rtl;
      testWidgets('at triple text, draws glyphs on a phone — ${direction.name}',
          (tester) async {
        const phone = Size(375, 812);
        final semantics = tester.ensureSemantics();
        await mount(tester, size: phone, textScale: 3, direction: direction);

        expect(find.text('Rotate venue'), findsNothing);
        expect(find.byIcon(Icons.threesixty_rounded), findsOneWidget);
        expect(find.byIcon(Icons.open_with_rounded), findsOneWidget);
        final pair = tester.getRect(
          find.byType(SeatLayerPicker3DNavigationModeButton),
        );
        // On the screen, at the end edge.
        expect(pair.left, greaterThanOrEqualTo(0));
        expect(pair.right, lessThanOrEqualTo(phone.width));
        const inset = SeatLayerSizeTokens.mapAnchorInset;
        if (rtl) {
          expect(pair.left, closeTo(inset, .5));
        } else {
          expect(pair.right, closeTo(phone.width - inset, .5));
        }
        // Each half still says its words: to a screen reader, and on a long
        // press.
        expect(find.bySemanticsLabel('Rotate venue'), findsOneWidget);
        expect(find.bySemanticsLabel('Move venue'), findsOneWidget);
        expect(find.byTooltip('Rotate venue'), findsOneWidget);
        expect(find.byTooltip('Move venue'), findsOneWidget);
        semantics.dispose();
      });
    }

    testWidgets('glyphs keep a full touch reach', (tester) async {
      await mount(tester, size: const Size(375, 812), textScale: 3);

      for (final icon in <IconData>[
        Icons.threesixty_rounded,
        Icons.open_with_rounded,
      ]) {
        final reach = tester.getRect(
          find
              .ancestor(
                of: find.byIcon(icon),
                matching: find.byType(GestureDetector),
              )
              .first,
        );
        expect(
          reach.width,
          greaterThanOrEqualTo(SeatLayerSizeTokens.minimumHitTarget),
        );
        expect(
          reach.height,
          greaterThanOrEqualTo(SeatLayerSizeTokens.minimumHitTarget),
        );
      }
    });
  });
}
