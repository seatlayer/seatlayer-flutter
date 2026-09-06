/// WHAT "NOWHERE LEFT TO GO" MEANS, before any control is drawn from it.
///
/// The phone's back-out controls dim rather than disappear, so the reading
/// behind them has to be true — a control that stays put and plainly cannot be
/// pressed says "you are already looking at everything", and it is only
/// allowed to say that when the buyer is.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_models.dart';

import 'picker_test_fixture.dart';

SeatLayerPickerMapState _map({
  bool canZoomOut = true,
  bool? atVenueFit,
  String rung = 'seats',
}) =>
    SeatLayerPickerSnapshot.fromJson(
      pickerSnapshot(
        withSelection: false,
        rung: rung,
        canZoomOut: canZoomOut,
        atVenueFit: atVenueFit,
      ),
    )!
        .map;

void main() {
  test('a framed section always has a rung left', () {
    // Out of the section, then out to the venue. The fit pose does not end the
    // ladder here: leaving the section still has a card and a dim to clear.
    expect(_map(atVenueFit: true).focusedSectionId, isNotNull);
    expect(_map(atVenueFit: true).canStepBack, isTrue);
  });

  test('only the fit pose itself is done', () {
    expect(_map(rung: 'overview', atVenueFit: true).canStepBack, isFalse);
    expect(_map(rung: 'overview', atVenueFit: false).canStepBack, isTrue);
  });

  test('a camera between the venue and the seats is not the venue', () {
    // Section blocks on screen, no seats, venue NOT framed. `canZoomOut` reads
    // that as home; the reported pose does not, and the pose is the honest
    // answer.
    expect(
      _map(rung: 'overview', canZoomOut: false, atVenueFit: false).canStepBack,
      isTrue,
    );
  });

  test('an older runtime keeps its own coarser answer', () {
    // No `atVenueFit` on the wire at all: the SDK falls back to `canZoomOut`
    // rather than reading the missing field as a pose of its own.
    expect(_map(rung: 'overview').atVenueFit, isNull);
    expect(_map(rung: 'overview', canZoomOut: false).canStepBack, isFalse);
    expect(_map(rung: 'overview', canZoomOut: true).canStepBack, isTrue);
  });
}
