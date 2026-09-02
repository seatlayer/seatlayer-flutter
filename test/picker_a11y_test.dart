// What the picker owes a buyer who is not looking at it.
//
// Three properties are checked here that no single component can hold on its
// own: one reading order across the whole phone composition, type that grows
// with the platform's setting without any surface clipping, and a focus order
// that puts the answer before the way out.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_builders.dart';
import 'package:seatlayer/src/picker/picker_cart_sheet.dart';
import 'package:seatlayer/src/picker/picker_confirm_card.dart';
import 'package:seatlayer/src/picker/picker_dock_bar.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/picker_tokens.g.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const Key _mapSurfaceKey = ValueKey<String>('seatlayer-a11y-map-surface');

/// The whole phone composition, with the WebView replaced by a plain box.
Widget _layout() => SeatLayerPickerAdaptiveLayout(
      onCheckout: (_) async {},
      builders: SeatLayerPickerBuilders(
        map: (context, part) => const SizedBox.expand(key: _mapSurfaceKey),
      ),
    );

/// The venue as the buyer meets it: no card up, one section focused.
Map<String, Object?> _onTheMap({int revision = 1}) => pickerSnapshot(
      revision: revision,
      withSelection: false,
      sections: pickerSections(),
    );

/// The same venue with a tapped seat still waiting for an answer.
Map<String, Object?> _cardUp({int revision = 2}) =>
    pickerSnapshot(revision: revision, sections: pickerSections());

/// [child] under a platform text-size setting of [factor].
Widget _atTextScale(double factor, Widget child) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(factor),
        ),
        child: child,
      ),
    );

/// The root of the live semantics tree.
///
/// `rootPipelineOwner` owns no semantics of its own — the tree hangs off the
/// child owner the renderer binding actually renders through.
SemanticsNode _rootSemantics(WidgetTester tester) =>
    // ignore: deprecated_member_use
    tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;

/// The whole semantics tree, in the order a screen reader walks it.
String _traversal(WidgetTester tester) => _rootSemantics(tester)
    .toStringDeep(childOrder: DebugSemanticsDumpOrder.traversalOrder);

/// Where [needle] first appears in the traversal dump.
int _at(String dump, String needle) {
  final index = dump.indexOf(needle);
  expect(index, isNot(-1), reason: 'nothing in the tree says "$needle"');
  return index;
}

/// Every node in the tree whose properties satisfy [test].
List<SemanticsNode> _nodesWhere(
  WidgetTester tester,
  bool Function(SemanticsData data) test,
) {
  final found = <SemanticsNode>[];
  void walk(SemanticsNode node) {
    if (test(node.getSemanticsData())) found.add(node);
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  walk(_rootSemantics(tester));
  return found;
}

/// The labels of every live region on screen.
List<String> _liveRegions(WidgetTester tester) => _nodesWhere(
      tester,
      (data) => data.flagsCollection.isLiveRegion,
    ).map((node) => node.label).toList(growable: false);

void main() {
  const strings = SeatLayerPickerStrings();

  group('reading order', () {
    testWidgets('the phone picker is read header, rail, map, dock, cart',
        (tester) async {
      final handle = tester.ensureSemantics();
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_onTheMap());
      await pumpToRest(tester);

      final dump = _traversal(tester);
      // The event's name, the rail's way out of a filter, the map, the dock's
      // way back to the venue, and the cart's own control — one of each, in
      // the order the buyer meets them. The Stack in the middle paints the
      // dock AFTER the map's own chrome and BEFORE the card, so nothing but an
      // explicit order puts these five in this sequence.
      final header = _at(dump, 'Mobile Test Event');
      final rail = _at(dump, strings.allPrices);
      final venue = _at(dump, 'seat map');
      final dock = _at(dump, strings.overview);
      final cart = _at(dump, strings.expandCart);
      expect(header, lessThan(rail));
      expect(rail, lessThan(venue));
      expect(venue, lessThan(dock));
      expect(dock, lessThan(cart));
      handle.dispose();
    });
  });

  group('semantics per surface', () {
    testWidgets('the map is one named region with a hint that says how to pick',
        (tester) async {
      final handle = tester.ensureSemantics();
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_onTheMap());
      await pumpToRest(tester);

      final node = tester.getSemantics(find.byKey(_mapSurfaceKey));
      expect(node.label, contains('seat map'));
      expect(node.hint, strings.venueMapHint);
      handle.dispose();
    });

    testWidgets('the peek summary and the dock are the live regions',
        (tester) async {
      final handle = tester.ensureSemantics();
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_onTheMap());
      await pumpToRest(tester);

      final live = _liveRegions(tester);
      // Where the buyer is, and what they have. Both change without the buyer
      // touching them, and neither says so any other way.
      expect(live.any((label) => label.startsWith('Gallery')), isTrue,
          reason: 'the dock says where the buyer is: $live');
      expect(live.any((label) => label.startsWith('From')), isTrue,
          reason: 'the cart summary is a live region: $live');
      handle.dispose();
    });

    testWidgets('the hold countdown speaks minutes, not m:ss', (tester) async {
      final handle = tester.ensureSemantics();
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(pickerSnapshot(
        holdOwner: 'picker',
        withSelection: false,
        sections: pickerSections(),
      ));
      await pumpToRest(tester);

      final live = _liveRegions(tester);
      expect(
        live.any((label) => label.endsWith('minutes left')),
        isTrue,
        reason: 'the hold pill announces a sentence, not a clock: $live',
      );
      // And it is never the drawn `m:ss`, which a screen reader would read as
      // a time of day.
      expect(live.any((label) => label.contains(':')), isFalse);
      handle.dispose();
    });

    testWidgets('the seat card is a named dialog with both answers on it',
        (tester) async {
      final handle = tester.ensureSemantics();
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
      map.emit(_cardUp());
      await pumpToRest(tester);

      final data = tester
          .getSemantics(find.byType(SeatLayerConfirmCard))
          .getSemanticsData();
      expect(data.flagsCollection.scopesRoute, isTrue);
      expect(data.flagsCollection.namesRoute, isTrue);
      // One sentence: where the seat is, what it is, what it costs.
      expect(data.label, contains('Row A'));
      expect(data.label, contains('Seat'));
      final actions = data.customSemanticsActionIds ?? const <int>[];
      final names = actions
          .map((id) => CustomSemanticsAction.getAction(id)!.label)
          .toSet();
      expect(names, containsAll(<String>[strings.addSeat, strings.cancel]));
      handle.dispose();
    });

    testWidgets('a card up hides the map behind it from assistive technology',
        (tester) async {
      final handle = tester.ensureSemantics();
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_onTheMap());
      await pumpToRest(tester);
      expect(_traversal(tester), contains('seat map'));

      // The runtime reports a tap on a seat the buyer has not answered yet.
      map.emit(_cardUp());
      await pumpToRest(tester);

      final dump = _traversal(tester);
      expect(dump, isNot(contains('seat map')));
      expect(dump, contains(strings.addSeat));
      handle.dispose();
    });
  });

  group('announcements', () {
    testWidgets('a toast is spoken, and its action gives focus back',
        (tester) async {
      final handle = tester.ensureSemantics();
      final spoken = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (message) async {
          final event = message! as Map<Object?, Object?>;
          if (event['type'] == 'announce') {
            final data = event['data']! as Map<Object?, Object?>;
            spoken.add(data['message']! as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
      );
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_onTheMap());
      await pumpToRest(tester);
      spoken.clear();

      // A seat taken by somebody else, which is news the buyer did not ask
      // for and which is gone again in four seconds.
      map.emitConflict(<String>['A-1']);
      await pumpToRest(tester);

      expect(
        spoken,
        contains(strings.seatJustTakenByAnother('A-1')),
        reason: 'a toast that fades in and out is announced outright',
      );
      handle.dispose();
    });
  });

  group('dynamic type', () {
    for (final factor in <double>[1.6, 2.0]) {
      testWidgets('the phone picker survives a text scale of $factor',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(map, _atTextScale(factor, _layout())),
        );
        map.emit(_onTheMap());
        await pumpToRest(tester);

        // An overflowing Row reports a FlutterError while it paints.
        expect(tester.takeException(), isNull);
        // And every word the buyer needs is still on screen.
        expect(find.text(strings.allPrices), findsOneWidget);
        expect(find.text(strings.overview), findsWidgets);
      });

      testWidgets('the open cart survives a text scale of $factor',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            _atTextScale(
              factor,
              SeatLayerCartSheet(
                expanded: true,
                onExpandedChanged: (_) {},
                onCheckout: (_) async {},
              ),
            ),
          ),
        );
        map.emit(snapshotWithTicketCount(2));
        await pumpToRest(tester);

        expect(tester.takeException(), isNull);
        expect(find.text(strings.holdAndCheckout), findsOneWidget);
      });

      testWidgets('the seat card survives a text scale of $factor',
          (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            _atTextScale(factor, const SeatLayerConfirmCard()),
          ),
        );
        map.emit(_cardUp());
        await pumpToRest(tester);

        expect(tester.takeException(), isNull);
        expect(find.text(strings.addSeat), findsOneWidget);
        expect(find.text(strings.cancel), findsOneWidget);
      });
    }

    test('a clamped surface grows only as far as its token', () {
      // The clamps are a design decision, not an implementation detail: a port
      // that invents its own ceiling has broken the same contract a port that
      // invents its own colour has. The numbers themselves live in
      // `design/tokens.json`, which `design_tokens_test.dart` locks.
      expect(SeatLayerTypeScaleTokens.rail, 1.3);
      expect(SeatLayerTypeScaleTokens.dock, 1.3);
      expect(SeatLayerTypeScaleTokens.peek, 1.3);
      expect(SeatLayerTypeScaleTokens.card, 1.3);
      expect(SeatLayerTypeScaleTokens.sheet, 1.6);
      expect(SeatLayerTypeScaleTokens.state, 1.6);
    });

    testWidgets('the dock reports the taller band it actually draws',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, _atTextScale(2.0, _layout())),
      );
      map.emit(_onTheMap());
      await pumpToRest(tester);

      // Clamped at the dock's own 1.3, whatever the platform asked for — and
      // the drawn bar is that height, so the band reported to the runtime and
      // the band standing on the map are the same number.
      final drawn = tester.getSize(find.byType(SeatLayerDockBar)).height;
      expect(
        drawn,
        moreOrLessEquals(
          SeatLayerSizeTokens.dockBarHeight * SeatLayerTypeScaleTokens.dock,
          epsilon: 0.5,
        ),
      );
    });
  });

  group('focus', () {
    testWidgets('the first focusable on the card is Add seat, not Cancel',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, const SeatLayerConfirmCard()));
      map.emit(_cardUp());
      await pumpToRest(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedText(), strings.addSeat);

      // And the way out is second, where a way out belongs.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedText(), strings.cancel);
    });

    testWidgets('Escape gives the seat back', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_cardUp());
      await pumpToRest(tester);
      expect(find.text(strings.addSeat), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await pumpToRest(tester);

      expect(
        map.callsTo('picker.removeCartLine'),
        isNotEmpty,
        reason: 'Escape answers the card the way a tap on the map does',
      );
    });

    testWidgets('answering the card puts the buyer back on the map',
        (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(pickerHarness(map, _layout()));
      map.emit(_cardUp());
      await pumpToRest(tester);

      await tester.tap(find.text(strings.addSeat));
      await pumpToRest(tester);
      map.emit(_onTheMap(revision: 3));
      await pumpToRest(tester);

      final focused = FocusManager.instance.primaryFocus;
      expect(
        focused?.debugLabel,
        'seatlayer-picker-map-region',
        reason: 'focus goes back where the buyer was, not to the header',
      );
    });
  });
}

/// The words inside whatever currently has focus.
String? _focusedText() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  String? found;
  void visit(Element element) {
    final widget = element.widget;
    if (found == null && widget is Text) found = widget.data;
    element.visitChildren(visit);
  }

  (context as Element).visitChildren(visit);
  return found;
}
