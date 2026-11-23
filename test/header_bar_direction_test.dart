// The header bar mirrors with the reading direction: in Arabic the brand mark
// stands as far from the right edge as it stands from the left in English,
// and the close ring as far from the left as it does from the right.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';
import 'package:seatlayer/src/picker/picker_header.dart';

import 'fake_webview_platform.dart';
import 'season_harness.dart';

final Finder _mark = find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString() == '_PickerBrandMark',
);

/// The mark's gap from the edge it starts at, and the close ring's from the
/// edge it ends at.
Future<(double, double)> _gaps(
  WidgetTester tester,
  TextDirection direction,
  Size size,
) async {
  // A fresh page each time: the bar of the other direction goes first.
  await tester.pumpWidget(const SizedBox.shrink());
  final page = SeasonPage(useFakeWebViewPlatform());
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: SeatLayerSeasonPicker(
        configuration: seasonConfiguration,
        onContinue: (_) {},
        onClose: (_, __) {},
      ),
    ),
  ));
  await page.boot(tester);
  await tester.pump();
  final bar = tester.getRect(find.byType(SeatLayerHeaderBar));
  final mark = tester.getRect(_mark);
  final close = tester.getRect(find.byTooltip('Close seat selection'));
  return direction == TextDirection.ltr
      ? (mark.left - bar.left, bar.right - close.right)
      : (bar.right - mark.right, close.left - bar.left);
}

void main() {
  for (final (name, size) in <(String, Size)>[
    ('phone', const Size(390, 844)),
    ('wide', const Size(1024, 768)),
  ]) {
    testWidgets('the $name bar mirrors in right to left', (tester) async {
      final ltr = await _gaps(tester, TextDirection.ltr, size);
      final rtl = await _gaps(tester, TextDirection.rtl, size);
      expect(ltr.$1, greaterThan(0));
      expect(rtl.$1, moreOrLessEquals(ltr.$1), reason: 'mark from its edge');
      expect(rtl.$2, moreOrLessEquals(ltr.$2), reason: 'close from its edge');
    });
  }
}
