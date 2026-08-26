import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/open_enums.dart';
import 'package:seatlayer/src/picker/picker_models.dart';

import 'picker_test_fixture.dart';

void main() {
  test('decodes one atomic native picker snapshot', () {
    final snapshot = SeatLayerPickerSnapshot.fromJson(
      pickerSnapshot(holdOwner: 'picker'),
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.schema, SeatLayerPickerSnapshot.currentSchema);
    expect(snapshot.sessionId, 'session-1');
    expect(snapshot.revision, 1);
    expect(snapshot.event.name, 'Mobile Test Event');
    expect(snapshot.event.mode, EventMode.test);
    expect(snapshot.categories.single.tiers.single.name, 'Adult');
    expect(snapshot.map.focusedSection?.id, 'section-a');
    expect(snapshot.selection.single.displayLabel, 'Row A, Seat 1');
    expect(snapshot.cartLines.single.buyerFacingLabel, 'Row A, Seat 1');
    expect(snapshot.cartTotal, 25);
    expect(snapshot.hold.active, isTrue);
    expect(snapshot.hold.expiresAt, 1999999999000.0);
    expect(snapshot.holdOwner, SeatLayerHoldOwner.picker);
    expect(snapshot.capabilities,
        containsAll(<String>['bestAvailable', 'floors']));
  });

  test('snapshot collections cannot be mutated by an app', () {
    final snapshot = SeatLayerPickerSnapshot.fromJson(pickerSnapshot())!;

    expect(
      () => snapshot.categories.add(snapshot.categories.single),
      throwsUnsupportedError,
    );
    expect(
      () => snapshot.map.categoryFilter.add('premium'),
      throwsUnsupportedError,
    );
  });

  test('incomplete payload is rejected instead of fabricating a session', () {
    expect(
      SeatLayerPickerSnapshot.fromJson(<String, Object?>{
        'schema': SeatLayerPickerSnapshot.currentSchema,
        'sessionId': 'session-1',
      }),
      isNull,
    );
  });
}
