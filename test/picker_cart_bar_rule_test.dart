import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_cart_bar_rule.dart';

/// Widths of 14-point letters, each [letter] wide and a space of 4.
PickerCartBarWidths _widths(String label, [double letter = 8]) {
  final parts = <double>[
    for (final part in pickerCartBarParts(label)) part.runes.length * letter,
  ];
  return PickerCartBarWidths(
    parts: parts,
    whole: parts.fold<double>(0, (sum, part) => sum + part) +
        (parts.length - 1) * 4,
  );
}

const List<String> _own = <String>[
  'Find best seats',
  'Hold seats & checkout',
  'Continue to checkout',
];

PickerCartBarPlan _plan(double width, String label, [double letter = 8]) =>
    PickerCartBarPlan.of(
      width: width,
      own: <PickerCartBarWidths>[
        for (final words in _own) _widths(words, letter),
      ],
      label: <PickerCartBarWidths>[
        for (final size in PickerCartBarSize.letters)
          _widths(label, letter * size / 14),
      ],
      labelIsOwn: _own.contains(label),
    );

void main() {
  test('breaks lines between words, and between letters without spaces', () {
    expect(
      pickerCartBarParts('Hold seats & checkout'),
      <String>['Hold', 'seats', '&', 'checkout'],
    );
    expect(pickerCartBarParts('選ぶ'), <String>['選', 'ぶ']);
    final label = _widths('Hold seats & checkout');
    expect(label.linesIn(200), 1);
    expect(label.linesIn(100), 2);
    expect(label.linesIn(70), 3);
  });

  test('balances two lines to the narrowest width that keeps them two', () {
    final label = _widths('Hold seats & checkout');
    final balanced = label.balancedIn(120);
    expect(label.linesIn(balanced), 2);
    expect(label.linesIn(balanced - 2), greaterThan(2));
    expect(balanced, lessThan(90));
    expect(_widths('Find').balancedIn(120), 32);
  });

  test('gives the button its words, at least 112 and at most 46% of the row',
      () {
    expect(_plan(393, 'Find best seats').buttonWidth, 141);
    expect(_plan(393, 'Select').buttonWidth, 112);
    final wide = _plan(393, 'Hold seats & checkout');
    expect(wide.buttonWidth, closeTo((393 - 24) * .46, .001));
    expect(
      wide.wordsWidth,
      closeTo(393 - 24 - 28 - 10 - 10 - wide.buttonWidth, .001),
    );
    expect(wide.under, isFalse);
  });

  test('puts the button under the words in every state once its own need more',
      () {
    for (final label in <String>[
      ..._own,
      'Securing your seats',
      'Select seats',
    ]) {
      final tight = _plan(320, label, 14);
      expect(tight.under, isTrue);
      expect(tight.buttonWidth, 296);
      expect(tight.wordsWidth, 258);
      expect(tight.letters, 0);
    }
  });

  test('makes a busy label smaller instead of the layout', () {
    const busy = 'Seats secured. Opening checkout';
    expect(_plan(393, busy).letters, 0);
    expect(_plan(320, busy).letters, greaterThan(0));
    expect(_plan(320, busy).under, isFalse);
    expect(
      _plan(320, 'One two three four five six seven eight').letters,
      2,
    );
  });

  test('drops the total to the second line where the two do not fit', () {
    expect(pickerCartBarTotalBeside(count: 60, total: 40, room: 120), isTrue);
    expect(pickerCartBarTotalBeside(count: 60, total: 80, room: 120), isFalse);
  });
}
