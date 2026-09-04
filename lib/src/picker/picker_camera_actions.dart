/// Where the camera stands, as commands.
///
/// The six that only move the view: which section is framed, which rung the
/// map is drawn at, and the zoom ladder. None of them changes what the buyer
/// has chosen or what inventory is held, which is why they sit apart from the
/// controller's selection and hold surface — a camera command can be sent on a
/// read-only picker, and none of them needs to be serialized against a hold.
library;

import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

/// The camera and framing commands.
extension SeatLayerPickerCamera on SeatLayerPickerController {
  /// Frame [sectionId] and draw its seats.
  Future<void> focusSection(String sectionId) => runPickerMutation(
        'picker.focusSection',
        <String, Object?>{'sectionId': sectionId},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Leave any framed section and show the whole venue.
  Future<void> overview() => runPickerMutation(
        'picker.overview',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Jump to a level of detail: `zones`, `sections` or `seats`.
  Future<void> setRung(String rung) => runPickerMutation(
        'picker.setRung',
        <String, Object?>{'rung': rung},
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Step the camera in.
  Future<void> zoomIn() => runPickerMutation(
        'picker.zoomIn',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Step the camera back out.
  ///
  /// A ladder, not a factor: one step returns to the section the buyer drilled
  /// into, the next leaves it for the venue. `map.canZoomOut` says whether
  /// there is a rung left, and is what chrome dims against.
  Future<void> zoomOut() => runPickerMutation(
        'picker.zoomOut',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Fit the whole chart in the viewport.
  Future<void> zoomToFit() => runPickerMutation(
        'picker.zoomToFit',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );
}
