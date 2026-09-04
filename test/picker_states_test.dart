// The screens the picker shows instead of a seat map.
//
// Each of these is a claim the buyer will act on — that there is nothing left,
// that their session is gone, that their seats are booked — so each one's
// condition is pinned here rather than left to the composition. The costly
// mistakes are the false positives: "Sold out" over a venue whose standing
// floor is still open, or a confirmation over a hold that is still the
// picker's own.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_header.dart';
import 'package:seatlayer/src/picker/picker_models.dart';
import 'package:seatlayer/src/picker/picker_options.dart';
import 'package:seatlayer/src/picker/picker_states.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

/// [pickerSnapshot] with its one seated category emptied.
Map<String, Object?> _soldOutSnapshot({
  List<Object?> gaAreas = const <Object?>[],
}) {
  final snapshot = pickerSnapshot(withSelection: false);
  final catalog = Map<String, Object?>.from(
    snapshot['catalog']! as Map<String, Object?>,
  );
  catalog['categories'] = <Object?>[
    <String, Object?>{
      ...(catalog['categories']! as List<Object?>).first!
          as Map<String, Object?>,
      'available': 0,
    },
  ];
  catalog['gaAreas'] = gaAreas;
  return <String, Object?>{...snapshot, 'catalog': catalog};
}

/// [pickerSnapshot] whose access the runtime will no longer vouch for.
Map<String, Object?> _accessSnapshot(String reason) {
  final snapshot = pickerSnapshot(withSelection: false);
  return <String, Object?>{
    ...snapshot,
    'access': <String, Object?>{
      'configured': true,
      'status': 'expired',
      'reason': reason,
    },
  };
}

/// [pickerSnapshot] holding a cart that runs out in [seconds].
Map<String, Object?> _expiringSnapshot(int seconds, {int revision = 1}) {
  final snapshot = pickerSnapshot(holdOwner: 'picker', revision: revision);
  return <String, Object?>{
    ...snapshot,
    'hold': <String, Object?>{
      'active': true,
      'expiresAt': seatLayerPickerNow()
          .add(Duration(seconds: seconds))
          .millisecondsSinceEpoch
          .toDouble(),
      'ownership': 'picker',
    },
  };
}

void main() {
  group('sold out', () {
    test('is every seated category at zero, and no standing floor', () {
      expect(
        seatLayerPickerIsSoldOut(_state(_soldOutSnapshot())),
        isTrue,
      );
    });

    test('is not claimed while a standing area is still open', () {
      final state = _state(
        _soldOutSnapshot(
          gaAreas: <Object?>[
            <String, Object?>{
              'id': 'floor',
              'label': 'Standing floor',
              'available': 120,
            },
          ],
        ),
      );

      expect(
        seatLayerPickerIsSoldOut(state),
        isFalse,
        reason: 'tickets that exist must not be hidden behind "Sold out"',
      );
    });

    test('is not claimed on a chart with nothing for sale at all', () {
      final snapshot = pickerSnapshot(withSelection: false);
      final catalog = Map<String, Object?>.from(
        snapshot['catalog']! as Map<String, Object?>,
      );
      catalog['categories'] = <Object?>[];

      expect(
        seatLayerPickerIsSoldOut(
          _state(<String, Object?>{...snapshot, 'catalog': catalog}),
        ),
        isFalse,
      );
    });

    testWidgets('says so on the map', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const _Fill(SeatLayerPickerSoldOutOverlay())),
      );
      map.emit(_soldOutSnapshot());
      await tester.pumpAndSettle();

      expect(find.text('Sold out'), findsOneWidget);
      expect(
        find.text('No reserved seats are currently available for this event.'),
        findsOneWidget,
      );
    });
  });

  group('the access panel', () {
    test('names which of the four things happened', () {
      const strings = SeatLayerPickerStrings();

      expect(
        seatLayerAccessTelling(strings, 'paused').title,
        'These seats are on hold right now',
      );
      expect(
        seatLayerAccessTelling(strings, 'revoked').action,
        isNull,
        reason: 'a revoked link has nothing left to try',
      );
      expect(
        seatLayerAccessTelling(strings, 'no_token').action,
        'Reload seat map',
      );
      expect(
        seatLayerAccessTelling(strings, 'something-new').title,
        "We couldn't verify your access",
      );
    });

    testWidgets('retries, and shows that it is working', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      final controller = SeatLayerPickerController(mapController: map);
      await tester.pumpWidget(
        pickerHarness(
          map,
          const _Fill(SeatLayerPickerAccessPanel()),
          controller: controller,
        ),
      );
      map.emit(_accessSnapshot('no_token'));
      await tester.pumpAndSettle();

      expect(find.text('Your seat session has expired'), findsOneWidget);

      await tester.tap(find.text('Reload seat map'));
      await tester.pumpAndSettle();

      expect(
        controller.state.phase,
        isNot(SeatLayerPickerPhase.unavailable),
        reason: 'the retry has to actually restart the runtime',
      );
      expect(find.text('Your seat session has expired'), findsNothing);
    });

    testWidgets('is absent while the picker is ready', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const _Fill(SeatLayerPickerAccessPanel())),
      );
      map.emit(pickerSnapshot());
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('the extend prompt', () {
    testWidgets('asks only in the last minute', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const _Fill(SeatLayerPickerExtendHoldPrompt())),
      );
      map.emit(_expiringSnapshot(300, revision: 1));
      await tester.pumpAndSettle();

      expect(find.text('+5 min'), findsNothing);

      map.emit(_expiringSnapshot(48, revision: 2));
      await tester.pumpAndSettle();

      // The button names the amount one tap adds. "Add time" beside a
      // countdown read like an invitation to choose one.
      expect(find.text('+5 min'), findsOneWidget);
      expect(
        find.textContaining('Your seats are held for 0:48'),
        findsOneWidget,
      );
    });

    testWidgets('asks the controller for more time', (tester) async {
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const _Fill(SeatLayerPickerExtendHoldPrompt())),
      );
      map.emit(_expiringSnapshot(48));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+5 min'));
      await tester.pumpAndSettle();

      // One fixed step, not the host's whole configured hold window.
      expect(
        map.callsTo('picker.extendHold').single.$2,
        <String, Object?>{'ttlMs': 5 * 60 * 1000},
      );
    });

    testWidgets('offers its step once per hold', (tester) async {
      // The server would allow more, but a buyer who can keep asking has been
      // handed a way to sit on inventory by reflex rather than by decision,
      // and a countdown that can always be pushed back is not a deadline.
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const _Fill(SeatLayerPickerExtendHoldPrompt())),
      );
      map.emit(_expiringSnapshot(48));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+5 min'));
      await tester.pumpAndSettle();

      // Retired for this hold, even though the clock is still in the last
      // minute and the offer would otherwise be due again on the next tick.
      map.emit(_expiringSnapshot(40, revision: 9));
      await tester.pumpAndSettle();
      expect(find.text('+5 min'), findsNothing);
      expect(map.callsTo('picker.extendHold'), hasLength(1));
    });

    testWidgets('can be waved away without spending the step', (tester) async {
      // Offered in the last minute over the map, an offer with no refusal is
      // a thing in the way.
      final map = FakePickerMap();
      addTearDown(map.dispose);
      usePhoneSurface(tester);

      await tester.pumpWidget(
        pickerHarness(map, const _Fill(SeatLayerPickerExtendHoldPrompt())),
      );
      map.emit(_expiringSnapshot(48));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('+5 min'), findsNothing);
      expect(map.callsTo('picker.extendHold'), isEmpty);
    });
  });

  group('the booked overlay', () {
    testWidgets('lists what was booked, and offers the map back',
        (tester) async {
      final map = FakePickerMap(
        bundle: nativeChromeBundle(),
        handler: (command, payload) async => <String, Object?>{
          'revision': 2,
          'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
          'handoff': <String, Object?>{
            'holdId': 'hold-1',
            'expiresAt': 1999999999000.0,
            'currency': 'EUR',
            'total': 50.0,
            'lineItems': <Object?>[
              <String, Object?>{
                'lineKey': 'seat:A-1:adult',
                'label': 'A-1',
                'displayLabel': 'Row A, Seat 1',
                'objectId': 'seat-a-1',
                'objectType': 'seat',
                'categoryKey': 'standard',
                'unitPrice': 25.0,
                'currency': 'EUR',
                'quantity': 2,
              },
            ],
          },
        },
      );
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      final controller = SeatLayerPickerController(mapController: map);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const _Fill(SeatLayerPickerBookedOverlay()),
          controller: controller,
        ),
      );
      map.emit(pickerSnapshot(holdOwner: 'host'));
      await tester.pumpAndSettle();

      expect(find.text("You're all set"), findsNothing);

      await controller.checkout();
      await tester.pumpAndSettle();
      // The hand-off is a buyer on the way to pay, not a sale.
      expect(find.text("You're all set"), findsNothing);

      // The hold vanishes with no expiry announced: the seats sold.
      map.emit(pickerSnapshot(revision: 3));
      await tester.pumpAndSettle();

      expect(find.text("You're all set"), findsOneWidget);
      expect(
        find.text('2 tickets confirmed. A confirmation is on its way.'),
        findsOneWidget,
      );
      expect(find.text('Row A, Seat 1'), findsOneWidget);

      await tester.tap(find.text('Back to map'));
      await tester.pumpAndSettle();

      expect(
        find.text("You're all set"),
        findsNothing,
        reason: 'the map is the way out, and the hold is unaffected',
      );
      expect(controller.state.checkoutHandoff, isNotNull);
    });

    testWidgets('a host that tells the buyer itself can keep the overlay down',
        (tester) async {
      final map = FakePickerMap(
        bundle: nativeChromeBundle(),
        handler: (command, payload) async => <String, Object?>{
          'revision': 2,
          'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
          'handoff': <String, Object?>{
            'holdId': 'hold-1',
            'expiresAt': 1999999999000.0,
            'currency': 'EUR',
            'total': 25.0,
            'lineItems': <Object?>[],
          },
        },
      );
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      final controller = SeatLayerPickerController(mapController: map);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const _Fill(SeatLayerPickerBookedOverlay()),
          controller: controller,
          options: const SeatLayerPickerOptions(showBookedOverlay: false),
        ),
      );
      map.emit(pickerSnapshot(holdOwner: 'host'));
      await tester.pumpAndSettle();
      await controller.checkout();
      await tester.pumpAndSettle();
      map.emit(pickerSnapshot(revision: 3));
      await tester.pumpAndSettle();

      expect(find.text("You're all set"), findsNothing);
      expect(controller.bookedHandoff, isNotNull,
          reason: 'the sale is still known; only the telling is the host\'s');
    });

    testWidgets('a hold that ran out behind checkout is not a sale',
        (tester) async {
      final map = FakePickerMap(
        bundle: nativeChromeBundle(),
        handler: (command, payload) async => <String, Object?>{
          'revision': 2,
          'snapshot': pickerSnapshot(revision: 2, holdOwner: 'host'),
          'handoff': <String, Object?>{
            'holdId': 'hold-1',
            'expiresAt': 1999999999000.0,
            'currency': 'EUR',
            'total': 25.0,
            'lineItems': <Object?>[],
          },
        },
      );
      addTearDown(map.dispose);
      usePhoneSurface(tester);
      final controller = SeatLayerPickerController(mapController: map);

      await tester.pumpWidget(
        pickerHarness(
          map,
          const _Fill(SeatLayerPickerBookedOverlay()),
          controller: controller,
        ),
      );
      map.emit(pickerSnapshot(holdOwner: 'host'));
      await tester.pumpAndSettle();
      await controller.checkout();
      await tester.pumpAndSettle();

      // The runtime announces the expiry before the snapshot that shows the
      // hold gone, as it does on the wire.
      map.emitEvent('hold.expired', null);
      await tester.pumpAndSettle();
      map.emit(pickerSnapshot(revision: 3));
      await tester.pumpAndSettle();

      expect(find.text("You're all set"), findsNothing);
    });
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('sold out — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              const SizedBox(
                width: 390,
                height: 420,
                child: SeatLayerPickerSoldOutOverlay(),
              ),
            ),
            platformBrightness: brightness,
          ),
        );
        map.emit(_soldOutSnapshot());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'sold_out_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('access panel — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              const SizedBox(
                width: 390,
                height: 420,
                child: SeatLayerPickerAccessPanel(),
              ),
            ),
            platformBrightness: brightness,
          ),
        );
        map.emit(_accessSnapshot('no_token'));
        await tester.pumpAndSettle();

        await expectGolden(tester, 'access_panel_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('extend prompt — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              const SizedBox(
                width: 390,
                height: 96,
                child: Center(child: SeatLayerPickerExtendHoldPrompt()),
              ),
            ),
            platformBrightness: brightness,
          ),
        );
        map.emit(_expiringSnapshot(48));
        await tester.pumpAndSettle();

        await expectGolden(tester, 'extend_prompt_${brightness.name}');
      }, tags: goldenTag);

      testWidgets('sales closed — ${brightness.name}', (tester) async {
        final map = FakePickerMap();
        addTearDown(map.dispose);
        usePhoneSurface(tester);

        await tester.pumpWidget(
          pickerHarness(
            map,
            goldenSubject(
              const SizedBox(
                width: 390,
                height: 120,
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: SeatLayerPickerSalesClosedStatement(),
                ),
              ),
            ),
            platformBrightness: brightness,
          ),
        );
        map.emit(_closedSnapshot());
        await tester.pumpAndSettle();

        await expectGolden(tester, 'sales_closed_${brightness.name}');
      }, tags: goldenTag);
    }
  }, skip: goldenSkip);
}

/// [pickerSnapshot] for an event that has stopped selling.
Map<String, Object?> _closedSnapshot() {
  final snapshot = pickerSnapshot(withSelection: false);
  return <String, Object?>{
    ...snapshot,
    'event': <String, Object?>{
      ...snapshot['event']! as Map<String, Object?>,
      'salesClosed': true,
    },
  };
}

/// A ready state carrying [snapshot], for the pure predicate tests.
SeatLayerPickerState _state(Map<String, Object?> snapshot) =>
    const SeatLayerPickerState.initializing().applying(
      SeatLayerPickerSnapshot.fromJson(snapshot)!,
    );

/// Give a map-level state the whole surface, the way the layout does.
class _Fill extends StatelessWidget {
  const _Fill(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(child: child);
}
