import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_models.dart';

void main() {
  test('a runtime that reports free seats is believed, even at zero', () {
    final category = SeatLayerPickerCategory.fromJson(<String, Object?>{
      'key': 'stalls',
      'label': 'Stalls',
      'color': '#e5484d',
      'priceMin': 45,
      'priceMax': 45,
      'available': 0,
      'notForSale': false,
      'tiers': <Object?>[],
      'free': 0,
    })!;
    expect(category.free, 0);
    expect(category.available, 0);
  });

  test('an older runtime leaves the free count unknown', () {
    final category = SeatLayerPickerCategory.fromJson(<String, Object?>{
      'key': 'stalls',
      'label': 'Stalls',
      'color': '#e5484d',
      'priceMin': 45,
      'priceMax': 45,
      'available': 12,
      'notForSale': false,
      'tiers': <Object?>[],
    })!;
    expect(category.free, isNull);
    expect(category.available, 12);
  });
}
