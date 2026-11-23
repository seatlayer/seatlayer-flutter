// The phone device matrix: the event picker on the phones buyers carry.
//
// Every phone here is a real screen with its real safe areas, at device pixel
// ratio 1 so a picture's pixels are the points the specification uses. The
// picker is the shipped page, `SeatLayerPickerPage`, or `showSeatLayerPicker`
// for the presentation choice; only the map itself is a plain placeholder,
// because it is a web view and is checked on real devices instead.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// One phone screen: its size in points and what the system draws over it.
class Phone {
  const Phone(this.name, this.size, this.insets);

  final String name;
  final Size size;

  /// The status bar, notch or Dynamic Island, home indicator or gesture bar.
  final EdgeInsets insets;

  bool get landscape => size.width > size.height;

  /// Where the picker's controls must stay.
  Rect get safe => Rect.fromLTRB(
        insets.left,
        insets.top,
        size.width - insets.right,
        size.height - insets.bottom,
      );

  @override
  String toString() => name;
}

/// The phones held upright, narrowest first.
const List<Phone> uprightPhones = <Phone>[
  // iPhone SE (1st generation), and the smallest Android screens.
  Phone('320', Size(320, 568), EdgeInsets.only(top: 20)),
  // The common Android phone: the Pixel 7's status bar over its camera cutout
  // and its gesture bar, as the emulator reports them.
  Phone('360', Size(360, 800), EdgeInsets.only(top: 52, bottom: 24)),
  // iPhone SE (2nd and 3rd generation): no notch, no home indicator.
  Phone('375', Size(375, 667), EdgeInsets.only(top: 20)),
  // iPhone 12 to 14: the notch.
  Phone('390', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
  // iPhone 15 and 16: the Dynamic Island.
  Phone('393', Size(393, 852), EdgeInsets.only(top: 59, bottom: 34)),
  // Pixel 7, as its emulator reports it: 1080 × 2400 at 420 dpi.
  Phone('412', Size(412, 915), EdgeInsets.only(top: 52, bottom: 24)),
  // iPhone 15 and 16 Plus and Pro Max.
  Phone('430', Size(430, 932), EdgeInsets.only(top: 59, bottom: 34)),
];

/// The phones held sideways.
const List<Phone> sidewaysPhones = <Phone>[
  Phone(
    '844x390',
    Size(844, 390),
    EdgeInsets.only(left: 47, right: 47, bottom: 21),
  ),
  // Pixel 7 turned sideways: the camera cutout becomes the left inset.
  Phone(
    '915x412',
    Size(915, 412),
    EdgeInsets.only(left: 52, top: 28, bottom: 24),
  ),
];

/// What the buyer is looking at.
enum PhoneState {
  /// The map is up and nothing is chosen.
  ready,

  /// One seat tapped: its confirm card is up.
  card,

  /// Two seats in the cart: the dock bar and the cart peek.
  cart,

  /// The cart sheet open over three seats.
  cartOpen,

  /// The 3D venue under the runtime's default map gestures: no Rotate / Move.
  venue3DMap,

  /// The 3D venue under the older gestures, with the Rotate / Move pair.
  venue3DClassic,
}

/// How the picker reaches the screen.
enum PhonePresentation {
  /// `SeatLayerPickerPage` as the app's own route.
  page,

  /// `showSeatLayerPicker` with its adaptive choice.
  show,

  /// `SeatLayerPicker` mounted bare in the host's own scaffold, with no
  /// SafeArea around it, as the example app does.
  bare,
}

Map<String, Object?> _confirmedCart(int count) {
  final snapshot = snapshotWithTicketCount(count);
  snapshot['hold'] = <String, Object?>{
    'active': true,
    'expiresAt': 1999999999000.0,
    'ownership': 'picker',
  };
  return snapshot;
}

Map<String, Object?> _snapshotFor(PhoneState state) {
  switch (state) {
    case PhoneState.ready:
      return pickerSnapshot(withSelection: false, sections: pickerSections());
    case PhoneState.card:
      return pickerSnapshot(sections: pickerSections());
    case PhoneState.cart:
      return _confirmedCart(2);
    case PhoneState.cartOpen:
      return _confirmedCart(3);
    case PhoneState.venue3DMap:
    case PhoneState.venue3DClassic:
      final snapshot = _confirmedCart(1);
      (snapshot['map']! as Map<String, Object?>)['buyerView'] = 'venue3d';
      return snapshot;
  }
}

const Color _mapPlaceholderColor = Color(0xFF9AA3AE);

/// A flat stand-in for the web view the map is drawn in.
Widget _mapPlaceholder(BuildContext context, SeatLayerPickerPartContext part) =>
    const ColoredBox(color: _mapPlaceholderColor, child: SizedBox.expand());

/// Put the picker on [phone] in [state].
///
/// Returns the strings the picker draws, so a check can find its own words in
/// any language.
Future<SeatLayerPickerStrings> pumpPhone(
  WidgetTester tester,
  Phone phone,
  PhoneState state, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Locale locale = const Locale('en'),
  PhonePresentation presentation = PhonePresentation.page,
  bool golden = false,
}) async {
  useFakeWebViewPlatform();
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = phone.size
    ..padding = FakeViewPadding(
      left: phone.insets.left,
      top: phone.insets.top,
      right: phone.insets.right,
      bottom: phone.insets.bottom,
    )
    ..viewPadding = FakeViewPadding(
      left: phone.insets.left,
      top: phone.insets.top,
      right: phone.insets.right,
      bottom: phone.insets.bottom,
    );
  addTearDown(tester.view.reset);

  // What runtime 1.0.0 speaks on a chart with no access provisions, so the
  // map carries the same control column as a real app: the palette disc
  // above the whole-venue disc.
  final map = FakePickerMap(
    bundle: nativeChromeBundle(
      capabilities: const <String>[
        'native-chrome-contract-v1',
        'viewport-insets-v1',
        'colorblind-safe',
        'venue-3d-controls-v1',
      ],
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.setColorblindSafe',
        'picker.setVenue3DNavigationMode',
      ],
    ),
  );
  addTearDown(map.dispose);
  final picker = SeatLayerPickerController(mapController: map);
  addTearDown(picker.dispose);

  final strings = SeatLayerPickerStrings.forLocale(locale);
  final rtl = locale.languageCode == 'ar' || locale.languageCode == 'he';
  final configuration = SeatLayerConfiguration(event: 'ev_test');
  final options = SeatLayerPickerOptions(
    strings: strings,
    touchNavigation3D: state == PhoneState.venue3DClassic
        ? SeatLayer3DTouchNavigation.classic
        : SeatLayer3DTouchNavigation.map,
  );
  const builders = SeatLayerPickerBuilders(map: _mapPlaceholder);
  // A test has no system font: text with no family of its own falls to the
  // engine's square stand-in, much wider than real letters. Roboto, as an
  // Android phone draws it, measures the words as a buyer sees them.
  const theme = SeatLayerPickerThemeData(fontFamily: 'Roboto');

  final Widget home = switch (presentation) {
    PhonePresentation.page => SeatLayerPickerPage(
        configuration: configuration,
        controller: picker,
        options: options,
        theme: theme,
        builders: builders,
        onCheckout: (_) {},
      ),
    PhonePresentation.bare => Scaffold(
        body: SeatLayerPicker(
          configuration: configuration,
          controller: picker,
          options: options,
          theme: theme,
          builders: builders,
          onCheckout: (_) {},
        ),
      ),
    PhonePresentation.show => Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => showSeatLayerPicker(
              context,
              configuration: configuration,
              controller: picker,
              options: options,
              theme: theme,
              builders: builders,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
  };

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
      home: home,
    ),
  );
  if (presentation == PhonePresentation.show) {
    await tester.tap(find.text('Open'));
    await tester.pump();
  }
  map.emit(_snapshotFor(state));
  await pumpToRest(tester);
  if (state == PhoneState.cartOpen) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded).first);
    await pumpToRest(tester);
  }
  return strings;
}

/// A control a buyer can tap, where it is on the screen.
class Tappable {
  Tappable(this.node, this.rect, {this.atScrollEdge = false});

  final SemanticsNode node;
  final Rect rect;

  /// Cut by the edge of a list it scrolls in: partly scrolled out of view,
  /// where a finger scrolls it back rather than tapping half of it.
  final bool atScrollEdge;

  String get name {
    final data = node.getSemanticsData();
    final label = data.label.isNotEmpty ? data.label : data.tooltip;
    return label.isEmpty ? 'node #${node.id}' : '"$label"';
  }

  bool contains(Tappable other) {
    for (SemanticsNode? up = other.node.parent; up != null; up = up.parent) {
      if (up == node) return true;
    }
    return false;
  }
}

/// Every control on screen that answers a tap, in screen coordinates.
List<Tappable> tappables(WidgetTester tester) {
  // ignore: deprecated_member_use
  final root = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
  final found = <Tappable>[];
  void visit(SemanticsNode node, Matrix4 toScreen, Rect? scroller) {
    final transform = node.transform == null
        ? toScreen
        : (toScreen.clone()..multiply(node.transform!));
    final data = node.getSemanticsData();
    final rect = MatrixUtils.transformRect(transform, node.rect);
    final scrolls = data.hasAction(SemanticsAction.scrollUp) ||
        data.hasAction(SemanticsAction.scrollDown);
    if (data.hasAction(SemanticsAction.tap) &&
        !data.flagsCollection.isHidden &&
        !node.isInvisible &&
        rect.width > 0 &&
        rect.height > 0) {
      final edge = scroller != null &&
          ((rect.top - scroller.top).abs() < .5 ||
              (rect.bottom - scroller.bottom).abs() < .5);
      found.add(Tappable(node, rect, atScrollEdge: edge));
    }
    node.visitChildren((child) {
      visit(child, transform, scrolls ? rect : scroller);
      return true;
    });
  }

  visit(root, Matrix4.identity(), null);
  return found;
}

/// Whether a press at [point] lands on [control]: the semantics node of
/// something on the press's hit path is the control's own or one inside it.
bool pressReaches(WidgetTester tester, Offset point, Tappable control) {
  final hit = HitTestResult();
  tester.binding.hitTestInView(hit, point, tester.view.viewId);
  for (final entry in hit.path) {
    final target = entry.target;
    if (target is! RenderObject) continue;
    final node = target.debugSemantics;
    if (node == null) continue;
    if (node == control.node) return true;
    for (SemanticsNode? up = node.parent; up != null; up = up.parent) {
      if (up == control.node) return true;
    }
  }
  return false;
}

/// The smallest a control may be: WCAG 2.2's 24 points (2.5.8, level AA).
///
/// Apple asks for 44. The approved phone boards draw several controls between
/// the two, so [controlsUnder] lists those for a decision rather than failing.
const double minimumTapTarget = 24;

/// What Apple's Human Interface Guidelines ask a control to be.
const double recommendedTapTarget = 44;

/// The controls on screen smaller than [side] in either direction.
List<Tappable> controlsUnder(WidgetTester tester, double side) => <Tappable>[
      for (final control in tappables(tester))
        if (!control.atScrollEdge &&
            (control.rect.width < side - .5 || control.rect.height < side - .5))
          control,
    ];

/// Fail with every way the screen breaks on [phone].
///
/// An overflow or any other layout error has already failed the test by the
/// time this runs: the framework reports it as it happens.
///
/// Overlap is not judged from semantics: a control's semantic box is not its
/// touch area (the cart handle's box reaches 22 points over the map, where a
/// tap still lands on the map), so it would report collisions a finger never
/// meets.
void expectPhoneLayout(
  WidgetTester tester,
  Phone phone,
  SeatLayerPickerStrings strings,
) {
  expect(tester.takeException(), isNull);
  final problems = <String>[];
  final safe = phone.safe.inflate(.5);
  for (final control in tappables(tester)) {
    final rect = control.rect;
    if (!safe.contains(rect.topLeft) || !safe.contains(rect.bottomRight)) {
      problems.add('${control.name} at $rect leaves the safe area $safe');
    }
  }
  for (final control in controlsUnder(tester, minimumTapTarget)) {
    problems.add('${control.name} is ${control.rect.size}, under '
        '$minimumTapTarget × $minimumTapTarget');
  }
  // No control covered by another. Where two overlap, a press there must
  // reach the smaller one: a disc standing on the edge of a wide row is
  // fine, but a disc over half of a switch takes that half's presses. The
  // map's own surface answers a tap too and every control stands on it, so
  // the surface is not compared.
  double area(Rect rect) => rect.width * rect.height;
  final surface = find.byWidgetPredicate(
    (widget) => widget is ColoredBox && widget.color == _mapPlaceholderColor,
  );
  final mapRect =
      surface.evaluate().isEmpty ? Rect.zero : tester.getRect(surface.first);
  bool isSurface(Rect rect) =>
      area(mapRect) > 0 && area(rect.intersect(mapRect)) >= .9 * area(mapRect);
  final controls = <Tappable>[
    for (final control in tappables(tester))
      if (!control.atScrollEdge && !isSurface(control.rect)) control,
  ];
  for (var i = 0; i < controls.length; i++) {
    for (var j = i + 1; j < controls.length; j++) {
      final a = controls[i];
      final b = controls[j];
      if (a.contains(b) || b.contains(a)) continue;
      final both = a.rect.intersect(b.rect);
      if (both.width <= 1 || both.height <= 1) continue;
      final smaller = area(a.rect) <= area(b.rect) ? a : b;
      final larger = identical(smaller, a) ? b : a;
      if (!pressReaches(tester, both.center, smaller)) {
        problems.add('${larger.name} at ${larger.rect} covers '
            '${smaller.name} at ${smaller.rect}');
      }
    }
  }
  final mainLabels = <String>[
    strings.addSeat,
    strings.continueWord,
    strings.continueToCheckout,
  ];
  for (final paragraph in tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  )) {
    final text = paragraph.text.toPlainText();
    if (!mainLabels.any(text.contains)) continue;
    if (paragraph.didExceedMaxLines) {
      problems.add('the main button label "$text" is cut');
    }
    // Drawn is not enough: a press on its middle has to reach it. A card that
    // hung past the foot of a short map was drawn there and pressed nothing.
    final middle = paragraph.localToGlobal(
      paragraph.size.center(Offset.zero),
    );
    final hit = HitTestResult();
    tester.binding.hitTestInView(hit, middle, tester.view.viewId);
    if (!hit.path.any((entry) => identical(entry.target, paragraph))) {
      problems.add('a press on "$text" at $middle does not reach it');
    }
  }
  expect(problems, isEmpty, reason: 'on the $phone phone');
}
