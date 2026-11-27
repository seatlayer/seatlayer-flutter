// Every phone control drawn under 44 points answers presses on 44 points
// across it, each way, while it is drawn where and as large as before.
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_tap_area.dart';

import 'phone_matrix_harness.dart';

/// What takes a press on [area]: the first pointer listener inside it.
RenderPointerListener _handler(RenderObject area) {
  final queue = <RenderObject>[area];
  while (queue.isNotEmpty) {
    final next = queue.removeAt(0);
    if (next is RenderPointerListener) return next;
    next.visitChildren(queue.add);
  }
  throw StateError('nothing in $area takes a press');
}

/// How far, through [rect]'s middle along [axis], presses reach [handler].
double _reach(WidgetTester tester, Rect rect, Object handler, Axis axis) {
  var run = 0.0;
  var best = 0.0;
  for (var d = -40.0; d <= 40; d += .5) {
    final point = axis == Axis.horizontal
        ? rect.center.translate(d, 0)
        : rect.center.translate(0, d);
    final hit = HitTestResult();
    tester.binding.hitTestInView(hit, point, tester.view.viewId);
    if (hit.path.any((entry) => identical(entry.target, handler))) {
      run += .5;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}

void main() {
  final phones = <Phone>[
    uprightPhones.firstWhere((phone) => phone.name == '390'),
    sidewaysPhones.firstWhere((phone) => phone.name == '844x390'),
  ];
  for (final phone in phones) {
    for (final (state, controls) in const <(PhoneState, int)>[
      // Close, All prices, a price, 3D, display options, whole venue.
      (PhoneState.ready, 6),
      (PhoneState.cart, 6),
      // Close and Map.
      (PhoneState.venue3DMap, 2),
    ]) {
      testWidgets('$phone, ${state.name}', (tester) async {
        await pumpPhone(tester, phone, state);
        var measured = 0;
        for (final area in tester.renderObjectList<RenderPickerTapArea>(
          find.byType(PickerTapArea),
        )) {
          if (!area.enabled || !area.hasSize) continue;
          final rect = MatrixUtils.transformRect(
            area.getTransformTo(null),
            Offset.zero & area.size,
          );
          if (rect.shortestSide >= recommendedTapTarget) continue;
          final handler = _handler(area);
          // Not on screen, or under something: nothing to measure.
          if (_reach(tester, rect, handler, Axis.horizontal) == 0) continue;
          measured++;
          for (final axis in Axis.values) {
            expect(
              _reach(tester, rect, handler, axis),
              greaterThanOrEqualTo(recommendedTapTarget - .5),
              reason: '${area.debugCreator} $rect along ${axis.name}',
            );
          }
        }
        expect(measured, controls);
      });
    }
  }
}
