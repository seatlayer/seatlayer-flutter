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

  test('an ALL-CAPS abbreviation of the section comes off too', () {
    // The shape the pilot showed: `GALL-H` printed under a section already
    // named `Gallery`, and `ORCH-A` under `Orchestra`.
    expect(pickerRowLabel('GALL-H', 'Gallery'), 'H');
    expect(pickerRowLabel('ORCH-A', 'Orchestra'), 'A');
    expect(pickerRowLabel('ORCH A', 'Orchestra'), 'A');
    expect(pickerRowLabel('GALL\u00b7H', 'Gallery'), 'H');
    expect(pickerRowLabel('GALL/H', 'Gallery'), 'H');
  });

  test('a bare row name is never mistaken for a section code', () {
    // No separator, so there is no token to take off — however much of the
    // section name it happens to look like.
    expect(pickerRowLabel('A', 'Anfiteatro'), 'A');
    expect(pickerRowLabel('A', 'Orchestra'), 'A');
  });

  test('the section code the snapshot supplies is taken off exactly', () {
    expect(pickerRowLabel('BLK9-H', 'Upper Tier', sectionCode: 'BLK9'), 'H');
    // A code that is not this section's is not a licence to strip.
    expect(
      pickerRowLabel('BLK9-H', 'Upper Tier', sectionCode: 'BLK8'),
      'BLK9-H',
    );
  });

  test('a token that names something else survives', () {
    expect(pickerRowLabel('VIP-3', 'Gallery'), 'VIP-3');
    expect(pickerRowLabel('Balcony-C', 'Stalls D'), 'Balcony-C');
    // A single letter is a row group far more often than a section code.
    expect(pickerRowLabel('G-4', 'Gallery'), 'G-4');
  });

  test('a separator the section left behind is cleaned up', () {
    expect(pickerRowLabel('Gallery-H', 'Gallery'), 'H');
    expect(pickerRowLabel('Stalls D \u00b7 C', 'Stalls D'), 'C');
  });
}
