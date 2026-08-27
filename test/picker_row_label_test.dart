import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_internal.dart';

void main() {
  test('a fully qualified row name drops the section it repeats', () {
    expect(pickerRowLabel('Stalls D C', 'Stalls D'), 'C');
    expect(pickerRowLabel('Stalls D D', 'Stalls D'), 'D');
  });

  test('a row that does not repeat its section is left alone', () {
    expect(pickerRowLabel('C', 'Stalls D'), 'C');
    expect(pickerRowLabel('Balcony C', 'Stalls D'), 'Balcony C');
  });

  test('a row named exactly like its section keeps its name', () {
    expect(pickerRowLabel('Stalls D', 'Stalls D'), 'Stalls D');
  });

  test('missing halves are handled without inventing a label', () {
    expect(pickerRowLabel(null, 'Stalls D'), '');
    expect(pickerRowLabel('  C ', null), 'C');
  });
}
