// The map moves out from under the seat card by PANNING, as the web sheet does.
//
// With a runtime that answers `picker.frameSeat`, the sheet is no longer
// reported as a viewport inset — that re-frames the section and changes the
// zoom — and the tapped seat is panned to a constant fraction of the band the
// sheet leaves clear instead, then put back when the card leaves unless the
// buyer has moved the map since. An older runtime keeps the inset.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/payloads.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_prompt_presentation.dart';
import 'package:seatlayer/src/picker/picker_seat_lift.dart';
import 'package:seatlayer/src/picker/picker_strings.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

const SeatLayerPickerStrings _strings = SeatLayerPickerStrings();
const String _seatId = 'seat-a-1';

Widget _layout() => SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {});

BundleInfo _framingBundle() => nativeChromeBundle(
      commands: const <String>[
        'picker.setThemeMode',
        'picker.setViewportInsets',
        'picker.frameSeat',
      ],
    );

List<Map<String, Object?>> _frames(FakePickerMap map) => map
    .callsTo(seatLayerFrameSeatCommand)
    .map((call) => call.$2! as Map<String, Object?>)
    .toList();

Map<String, Object?> _lastInsets(FakePickerMap map) =>
    map.callsTo('picker.setViewportInsets').last.$2! as Map<String, Object?>;

/// The same snapshot, with the runtime reporting where it drew the seat.
///
/// `screenPoint` is computed when the snapshot is built, so it is where the
/// seat sat BEFORE any pan this card asks for.
Map<String, Object?> _seatDrawnAt(double x, double y, {int revision = 1}) {
  final snapshot =
      pickerSnapshot(sections: pickerSections(), revision: revision);
  final selection = Map<String, Object?>.from(
    snapshot['selection']! as Map<String, Object?>,
  );
  final seats = (selection['seats']! as List<Object?>)
      .map((seat) => Map<String, Object?>.from(seat! as Map<String, Object?>))
      .toList();
  seats.first['screenPoint'] = <String, Object?>{'x': x, 'y': y};
  selection['seats'] = seats;
  return <String, Object?>{...snapshot, 'selection': selection};
}

/// Where the glass behind the card leaves the map clear.
Offset? _spotlight(WidgetTester tester) => tester
    .widget<PickerPromptTransition>(find.byType(PickerPromptTransition))
    .anchor;

/// A runtime that pans the seat into place once and then reports it settled,
/// which is what a real one does: the second ask answers `dy: 0`.
FakePickerMap _pansOnceMap({double dy = -120, int gestures = 2}) {
  var panned = false;
  return FakePickerMap(
    bundle: _framingBundle(),
    handler: (command, payload) async {
      if (command != seatLayerFrameSeatCommand) return null;
      final answer = <String, Object?>{
        'dy': panned ? 0.0 : dy,
        'gestures': gestures,
      };
      panned = true;
      return answer;
    },
  );
}

/// A mounted phone picker with the ADD card up over A-1, on a runtime that
/// answers every frame with a 120 px lift at gesture count 2.
Future<SeatLayerPickerController> _cardUp(
  WidgetTester tester,
  FakePickerMap map, {
  Map<String, Object?>? snapshot,
}) async {
  final picker = SeatLayerPickerController(mapController: map);
  addTearDown(picker.dispose);
  useFakeWebViewPlatform();
  usePhoneSurface(tester);
  await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
  map.emit(snapshot ?? pickerSnapshot(sections: pickerSections()));
  await pumpToRest(tester);
  // The lift waits for the map to hold still across two frames.
  await tester.pump();
  await pumpToRest(tester);
  return picker;
}

FakePickerMap _framingMap({double dy = -120, int gestures = 2}) =>
    FakePickerMap(
      bundle: _framingBundle(),
      handler: (command, payload) async {
        if (command != seatLayerFrameSeatCommand) return null;
        return <String, Object?>{'dy': dy, 'gestures': gestures};
      },
    );

void main() {
  group('seatLayerSheetLiftFraction', () {
    test('folds the sheet into a fraction of the band the runtime knows', () {
      // 844 map, 60 top chrome, no bottom chrome, 300 px sheet: the seat has
      // to sit at 0.48 of the 484 px clear band = 232 px into a 784 px band.
      final f = seatLayerSheetLiftFraction(
        mapHeight: 844,
        top: 60,
        bottom: 0,
        sheet: 300,
      );
      expect(f, closeTo(484 * 0.48 / 784, 1e-9));
    });

    test('is clamped, and zero without a band', () {
      expect(
        seatLayerSheetLiftFraction(
            mapHeight: 100, top: 0, bottom: 0, sheet: 0, at: 5),
        1,
      );
      expect(
        seatLayerSheetLiftFraction(
            mapHeight: 100, top: 60, bottom: 60, sheet: 10),
        0,
      );
      expect(
        seatLayerSheetLiftFraction(
            mapHeight: 100, top: 0, bottom: 0, sheet: 100),
        0,
      );
    });
  });

  group('PickerSeatLift', () {
    test('lifts once per question, follows revisions, and restores', () async {
      final calls = <(String, double, int?)>[];
      const gestures = 2;
      final lift = PickerSeatLift(
        frame: (seatId, {required fraction, int? gestures}) async {
          calls.add((seatId, fraction, gestures));
          return const SeatLayerSeatFrame(dy: -100, gestures: 2);
        },
      );
      void sync({String? seat = 's1', int revision = 1, double sheet = 300}) =>
          lift.sync(
            seatId: seat,
            mapHeight: 844,
            top: 60,
            bottom: 0,
            sheet: sheet,
            revision: revision,
          );

      sync();
      sync(); // the same question again: nothing new
      await Future<void>.delayed(Duration.zero);
      expect(calls, hasLength(1));
      expect(calls.single.$1, 's1');
      expect(calls.single.$3, isNull);
      expect(lift.dy, -100);

      // A new snapshot re-asks, with the count from the last answer.
      sync(revision: 2);
      await Future<void>.delayed(Duration.zero);
      expect(calls, hasLength(2));
      expect(calls.last.$3, gestures);
      expect(lift.dy, -200);

      // The card leaves: one restore, with the count, at the undoing fraction.
      sync(seat: null);
      await Future<void>.delayed(Duration.zero);
      expect(calls, hasLength(3));
      expect(calls.last.$3, gestures);
      expect(calls.last.$2, seatLayerSheetRestoreFraction);
      expect(lift.seatId, isNull);
      expect(lift.dy, 0);
    });

    test('reports the pan the chrome has to add, and forgets it on a snapshot',
        () async {
      // The spotlight hole is cut against `screenPoint`, which is only ever as
      // fresh as the last snapshot. A pan carries no revision, so the shell
      // adds what has been panned SINCE that snapshot — and nothing once a
      // newer one has folded the pan in.
      var changed = 0;
      final lift = PickerSeatLift(
        onChanged: () => changed += 1,
        frame: (seatId, {required fraction, int? gestures}) async =>
            const SeatLayerSeatFrame(dy: -100, gestures: 2),
        settle: const <Duration>[Duration(milliseconds: 5)],
      );
      void sync({int revision = 1}) => lift.sync(
            seatId: 's1',
            mapHeight: 844,
            top: 60,
            bottom: 0,
            sheet: 300,
            revision: revision,
          );

      // Two syncs at one height: the lift waits for the map to hold still.
      sync();
      sync();
      await Future<void>.delayed(Duration.zero);
      expect(lift.anchorDy, -100);
      expect(changed, 1);

      // The runtime re-fitted under the card and the lift went again: the
      // hole moves with it, on the same snapshot.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(lift.anchorDy, -200);
      expect(changed, 2);

      // A newer snapshot's screen points already stand where the map is now.
      sync(revision: 2);
      expect(lift.anchorDy, 0);
      await Future<void>.delayed(Duration.zero);
      expect(lift.anchorDy, -100);

      lift.forget();
      expect(lift.anchorDy, 0);
    });

    test('an unmeasured card sends nothing, and a refused lift is not undone',
        () async {
      final calls = <double>[];
      final lift = PickerSeatLift(
        frame: (seatId, {required fraction, int? gestures}) async {
          calls.add(fraction);
          // The buyer moved the map: the count moved on, and the pan was 0.
          return const SeatLayerSeatFrame(dy: 0, gestures: 7);
        },
      );
      lift.sync(
          seatId: 's1',
          mapHeight: 844,
          top: 60,
          bottom: 0,
          sheet: 0,
          revision: 1);
      await Future<void>.delayed(Duration.zero);
      expect(calls, isEmpty);

      // Two syncs at one height: the lift waits for the map to hold still.
      for (var i = 0; i < 2; i += 1) {
        lift.sync(
            seatId: 's1',
            mapHeight: 844,
            top: 60,
            bottom: 0,
            sheet: 300,
            revision: 1);
      }
      await Future<void>.delayed(Duration.zero);
      expect(calls, hasLength(1));
      expect(lift.dy, 0);
      lift.sync(
          seatId: null,
          mapHeight: 844,
          top: 60,
          bottom: 0,
          sheet: 0,
          revision: 1);
      await Future<void>.delayed(Duration.zero);
      // Nothing stood, so nothing is put back.
      expect(calls, hasLength(1));
    });
  });

  test('a lift waits for two syncs that agree on the map height', () async {
    final heights = <double>[];
    final lift = PickerSeatLift(
      frame: (seatId, {required fraction, int? gestures}) async {
        heights.add(fraction);
        return const SeatLayerSeatFrame(dy: -50, gestures: 1);
      },
    );
    void sync(double h) => lift.sync(
          seatId: 's1',
          mapHeight: h,
          top: 0,
          bottom: 0,
          sheet: 200,
          revision: 1,
        );
    // The sheet is collapsing: the map grows every frame.
    sync(500);
    sync(560);
    sync(620);
    await Future<void>.delayed(Duration.zero);
    expect(heights, isEmpty);
    expect(lift.pending, isTrue);
    // Two frames agree: the lift goes, folded against the settled height.
    sync(620);
    await Future<void>.delayed(Duration.zero);
    expect(heights, hasLength(1));
    expect(lift.pending, isFalse);
    expect(
      heights.single,
      closeTo(
        seatLayerSheetLiftFraction(
          mapHeight: 620,
          top: 0,
          bottom: 0,
          sheet: 200,
        ),
        1e-9,
      ),
    );
  });

  test('a lift asks again after it lands, and stops when told to forget',
      () async {
    var calls = 0;
    final lift = PickerSeatLift(
      frame: (seatId, {required fraction, int? gestures}) async {
        calls += 1;
        return const SeatLayerSeatFrame(dy: -10, gestures: 1);
      },
      settle: const <Duration>[Duration(milliseconds: 5)],
    );
    for (var i = 0; i < 2; i += 1) {
      lift.sync(
        seatId: 's1',
        mapHeight: 800,
        top: 0,
        bottom: 0,
        sheet: 300,
        revision: 1,
      );
    }
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    // The runtime may have re-fitted under the lift: ask once more.
    expect(calls, 2);
    expect(lift.dy, -20);
    lift.forget();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(calls, 2);
  });

  testWidgets(
      'the card pans its seat into the clear band, and the sheet is not an inset',
      (tester) async {
    final map = _framingMap();
    addTearDown(map.dispose);
    await _cardUp(tester, map);

    final frames = _frames(map);
    expect(frames, isNotEmpty);
    expect(frames.first['seatId'], _seatId);
    final fraction = frames.first['fraction']! as double;
    expect(fraction, greaterThan(0));
    expect(fraction, lessThan(seatLayerSheetSeatFraction + 1e-9));
    expect(frames.first.containsKey('gestures'), isFalse);

    // The sheet's band is folded into the fraction, never into the insets:
    // with no dock on the phone the bottom inset stays at zero.
    expect(_lastInsets(map)['bottom'], 0.0);
  });

  testWidgets('cancelling the card puts the map back, with the gesture count',
      (tester) async {
    final map = _framingMap();
    addTearDown(map.dispose);
    await _cardUp(tester, map);
    final lifted = _frames(map).length;
    final liftFraction = _frames(map).first['fraction']! as double;

    await tester.tap(find.text(_strings.cancel));
    await pumpToRest(tester);

    final frames = _frames(map);
    expect(frames.length, greaterThan(lifted));
    final restore = frames.last;
    expect(restore['seatId'], _seatId);
    expect(restore['gestures'], 2);
    // The resting place is the middle of the clear band, never a sum of pans.
    expect(restore['fraction'], seatLayerSheetRestoreFraction);
    expect(liftFraction, lessThan(seatLayerSheetRestoreFraction));
  });

  testWidgets('the spotlight follows the seat the lift moved', (tester) async {
    // The hole in the glass is cut around `selection[].screenPoint`, which the
    // runtime computes when it BUILDS a snapshot. `picker.frameSeat` is camera
    // only — no revision, no snapshot — so the point the chrome holds is where
    // the seat sat before the lift, and the hole was left a whole lift band
    // below the seat it was meant to be showing (iOS 26.5, on device).
    final map = _pansOnceMap();
    addTearDown(map.dispose);
    await _cardUp(tester, map, snapshot: _seatDrawnAt(195, 500));

    expect(_frames(map), isNotEmpty);
    final anchor = _spotlight(tester);
    expect(anchor, isNotNull);
    expect(anchor!.dx, closeTo(195, .01));
    expect(
      anchor.dy,
      closeTo(380, .01),
      reason: 'the seat was panned 120 px up out from under the card',
    );
  });

  testWidgets(
      'a fresh snapshot already carries the lift, and is not counted '
      'twice', (tester) async {
    // A later snapshot — an availability refresh, a glide landing — recomputes
    // the screen point against the camera the lift already moved. Adding the
    // standing pan to THAT point would push the hole as far above the seat as
    // it used to sit below it.
    final map = _pansOnceMap();
    addTearDown(map.dispose);
    await _cardUp(tester, map, snapshot: _seatDrawnAt(195, 500));

    map.emit(_seatDrawnAt(195, 380, revision: 2));
    await pumpToRest(tester);

    expect(_spotlight(tester)!.dy, closeTo(380, .01));
  });

  testWidgets('a runtime that cannot pan cuts the hole where the seat is',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    await _cardUp(tester, map, snapshot: _seatDrawnAt(195, 500));

    expect(map.callsTo(seatLayerFrameSeatCommand), isEmpty);
    expect(_spotlight(tester)!.dy, closeTo(500, .01));
  });

  testWidgets('a runtime without the pan keeps the sheet as an inset',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    await _cardUp(tester, map);

    expect(map.callsTo(seatLayerFrameSeatCommand), isEmpty);
    expect(_lastInsets(map)['bottom']! as double, greaterThan(0));
  });
}
