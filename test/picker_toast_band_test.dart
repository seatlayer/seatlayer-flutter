import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_adaptive_layout.dart';
import 'package:seatlayer/src/picker/picker_toast.dart';
import 'package:seatlayer/src/picker/seat_layer_picker_controller.dart';

import 'fake_webview_platform.dart';
import 'picker_test_fixture.dart';
import 'picker_widget_harness.dart';

void main() {
  testWidgets('the undo toast stays one line tall with the sheet expanded',
      (tester) async {
    final map = FakePickerMap(bundle: nativeChromeBundle());
    addTearDown(map.dispose);
    useFakeWebViewPlatform();
    usePhoneSurface(tester);
    final controller = SeatLayerPickerController(mapController: map);
    await tester.pumpWidget(
      pickerHarness(
        map,
        SeatLayerPickerAdaptiveLayout(onCheckout: (_) async {}),
        controller: controller,
      ),
    );
    map.emit(pickerSnapshot(sections: pickerSections()));
    await pumpToRest(tester);
    controller.setCartSheetExpanded(true);
    await pumpToRest(tester);
    seatLayerPickerToasts(controller).show(
      const SeatLayerPickerToast('Ticket removed',
          actionLabel: 'Undo', onAction: _noop),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final card = find.byType(SeatLayerPickerToastCard);
    expect(card, findsOneWidget);
    // One line and a pill: the band is a sentence over the map, not a wall.
    // The action's hit box once centred itself in every point of loose height
    // the layer offered, which with the sheet open was the whole map.
    expect(tester.getSize(card).height, lessThanOrEqualTo(64));
    expect(find.text('Undo'), findsOneWidget);
  });
}

void _noop() {}
