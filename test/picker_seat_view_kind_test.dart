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
}
