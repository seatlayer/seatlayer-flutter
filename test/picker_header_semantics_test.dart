// The header's name and its way out are two things to a screen reader: the
// name a heading, Close a button. Merged, the name read as part of the button
// and a double tap on it closed the picker.
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_matrix_harness.dart';

void main() {
  for (final phone in <Phone>[uprightPhones.first, sidewaysPhones.first]) {
    testWidgets('$phone: the event name is a heading, Close its own button',
        (tester) async {
      final semantics = tester.ensureSemantics();
      final strings = await pumpPhone(tester, phone, PhoneState.ready);
      final title = tester.getSemantics(find.text('Mobile Test Event'));
      expect(title.label, 'Mobile Test Event');
      expect(title.flagsCollection.isHeader, isTrue);
      expect(title.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      final close = tester.getSemantics(find.bySemanticsLabel(strings.close));
      expect(close.label, strings.close);
      expect(close.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      semantics.dispose();
    });
  }
}
