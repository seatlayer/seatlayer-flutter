import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

void main() {
  test('a seat says what a view from it would show, or nothing', () {
    final real = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-1',
      'label': 'A-1',
      'seatViewKind': 'real',
    })!;
    final generated = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-2',
      'label': 'A-2',
      'seatViewKind': 'generated',
    })!;
    final silent = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-3',
      'label': 'A-3',
    })!;
    expect(real.seatViewKind, 'real');
    expect(generated.seatViewKind, 'generated');
    expect(silent.seatViewKind, isNull);
  });

  test('the seat carries its photograph, its sight line and its passport', () {
    final seat = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-1',
      'label': 'A-1',
      'seatViewThumb': <String, Object?>{
        'reference': '/pub/events/ev_test/assets/seat-a-1.jpg',
        'kind': 'real',
      },
      'sightlineMetres': 7.4,
      'seatViewConfidence': <String, Object?>{
        'headline': 'Modelled view',
        'model': 'Photogrammetry',
        'reality': 'Matched to a survey',
        'coverage': 'Whole bowl',
        'provenance': 'Venue survey',
        'freshness': 'This season',
        'limitations': <Object?>['Lighting differs'],
        'modeledTarget': 'Row A eye height',
      },
    })!;

    expect(seat.seatViewThumb!.reference,
        '/pub/events/ev_test/assets/seat-a-1.jpg');
    expect(seat.seatViewThumb!.kind, 'real');
    expect(seat.sightlineMetres, 7.4);
    expect(seat.seatViewConfidence!.headline, 'Modelled view');
    expect(seat.seatViewConfidence!.modeledTarget, 'Row A eye height');
    expect(seat.seatViewConfidence!.limitations, <String>['Lighting differs']);
  });

  test('a seat that says nothing new decodes to nothing new', () {
    final seat = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-1',
      'label': 'A-1',
    })!;

    expect(seat.seatViewThumb, isNull);
    expect(seat.sightlineMetres, isNull);
    expect(seat.seatViewConfidence, isNull);
  });

  test('a thumbnail with no reference is no thumbnail', () {
    final seat = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-1',
      'label': 'A-1',
      'seatViewThumb': <String, Object?>{'kind': 'real'},
    })!;

    expect(seat.seatViewThumb, isNull);
    expect(seat.seatViewKind, isNull);
  });

  test('the deprecated kind falls back to the thumbnail it lives on', () {
    final seat = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-1',
      'label': 'A-1',
      'seatViewThumb': <String, Object?>{
        'reference': '/pub/events/ev_test/assets/a.jpg',
        'kind': 'real',
      },
    })!;

    expect(seat.seatViewKind, 'real');
  });

  test('an unfamiliar confidence field is ignored, not fatal', () {
    final seat = SelectedSeat.fromJson(<String, Object?>{
      'id': 'seat-1',
      'label': 'A-1',
      'seatViewConfidence': <String, Object?>{
        'headline': 'Modelled view',
        'somethingNew': 42,
      },
    })!;

    expect(seat.seatViewConfidence!.headline, 'Modelled view');
    expect(seat.seatViewConfidence!.limitations, isEmpty);
    expect(seat.seatViewConfidence!.modeledTarget, isNull);
  });
}
