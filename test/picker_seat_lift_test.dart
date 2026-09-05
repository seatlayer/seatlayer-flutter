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

/// A mounted phone picker with the ADD card up over A-1, on a runtime that
/// answers every frame with a 120 px lift at gesture count 2.
Future<SeatLayerPickerController> _cardUp(
  WidgetTester tester,
  FakePickerMap map,
) async {
  final picker = SeatLayerPickerController(mapController: map);
  addTearDown(picker.dispose);
  useFakeWebViewPlatform();
  usePhoneSurface(tester);
  await tester.pumpWidget(pickerHarness(map, _layout(), controller: picker));
  map.emit(pickerSnapshot(sections: pickerSections()));
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

    test('the restore fraction undoes the lift, within the band', () {
      expect(
        seatLayerSheetRestoreFraction(fraction: 0.3, dy: -100, band: 500),
        closeTo(0.5, 1e-9),
      );
      expect(
        seatLayerSheetRestoreFraction(fraction: 0.3, dy: -400, band: 500),
        1,
      );
      expect(seatLayerSheetRestoreFraction(fraction: 0.3, dy: 5, band: 0), 0.3);
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
      expect(
        calls.last.$2,
        closeTo(
          seatLayerSheetRestoreFraction(
            fraction: calls.first.$2,
            dy: -200,
            band: 784,
          ),
          1e-9,
        ),
      );
      expect(lift.seatId, isNull);
      expect(lift.dy, 0);
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

      lift.sync(
          seatId: 's1',
          mapHeight: 844,
          top: 60,
          bottom: 0,
          sheet: 300,
          revision: 1);
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
    // Every lift was −120 px, so the restore aims that far back down the band.
    expect(restore['fraction']! as double, greaterThan(liftFraction));
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
