/// The accessible-section tour: the runtime's camera flight, and the small
/// piece of state the native chrome needs to narrate it.
///
/// The web menu is a popover drawn over the map, so pressing its "12 free"
/// button steps the camera while the menu stays open and the buyer watches it
/// move. A phone's accessibility sheet is a modal bottom sheet that covers the
/// map, so the same button has to hand the walk over to a control that lives
/// where the map is visible. That is the whole reason this file exists: one
/// tour, started from the sheet and continued from the map.
library;

import 'package:flutter/foundation.dart';

import '../json.dart';
import '../payloads.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

/// The three accessibility-focus commands, and what gates them.
extension SeatLayerPickerAccessibilityFocus on SeatLayerPickerController {
  /// Whether the mounted runtime moves the camera for an accessibility filter
  /// and answers the two focus commands.
  ///
  /// An older runtime applies the filter and leaves the camera where it was.
  /// Chrome that offered a jump anyway would be sending a command with nowhere
  /// to land, so every control this file feeds is gated on this.
  bool get supportsAccessibilityFocus =>
      mapController.bundleInfo
          ?.supportsCapability(seatLayerAccessibilityFocusCapability) ==
      true;

  /// Whether `sections[].accessibleFree` is reported at all.
  ///
  /// Separate from [supportsAccessibilityFocus] because the two are separate
  /// capabilities on the wire: a runtime can fly without counting, and chrome
  /// that read a missing count as zero would tell a buyer a section is full
  /// when the truth is that nobody counted it.
  bool get supportsSectionAccessCounts =>
      mapController.bundleInfo
          ?.supportsCapability(seatLayerSectionAccessCountsCapability) ==
      true;

  /// Re-run the filter's own camera flight without toggling the filter.
  ///
  /// The buyer has panned away from the spaces the filter lit and wants them
  /// back; turning the filter off and on again would be the only other way to
  /// ask, and that briefly shows them the whole venue.
  Future<void> focusAccessibilityFilter() => runPickerMutation(
        'picker.focusAccessibilityFilter',
        null,
        SeatLayerPickerBusyAction.updatingSelection,
      );

  /// Frame the next section holding a matching free space.
  ///
  /// [types] defaults to the active filter, which is what the runtime uses
  /// when the field is absent. A `null` result means nothing matches — not an
  /// error, and never a step with a zero total: the caller hides its control
  /// rather than drawing "0 of 0".
  Future<SeatLayerAccessibleStep?> focusNextAccessibleSection({
    Set<String>? types,
  }) async {
    final result = await runPickerMutation(
      'picker.focusNextAccessibleSection',
      <String, Object?>{
        if (types != null && types.isNotEmpty) 'types': types.toList(),
      },
      SeatLayerPickerBusyAction.updatingSelection,
    );
    return SeatLayerAccessibleStep.fromJson(jGet(result, 'step'));
  }
}

/// Where the accessible-section tour has got to, for one picker.
///
/// Two surfaces narrate one walk — the sheet's count chip starts it, the map's
/// stepper pill continues it — and the sheet is gone by the time the pill is
/// visible. Neither can own the state, so it lives here, beside the commands
/// that change it and out of the picker controller, which is at its line cap.
class SeatLayerAccessibleTour extends ChangeNotifier {
  /// The last step the runtime answered with, or `null` before the first one.
  SeatLayerAccessibleStep? get step => _step;
  SeatLayerAccessibleStep? _step;

  /// Which provisions the walk is over. Empty before it starts.
  Set<String> get types => _types;
  Set<String> _types = const <String>{};

  /// Whether the runtime has answered that nothing matches.
  ///
  /// Distinct from "not started": a walk that ran out has a control to take
  /// down, and one that never began has a control to draw for the first time.
  bool get exhausted => _exhausted;
  bool _exhausted = false;

  /// Whether a step is in flight, so the control cannot be double-pressed.
  bool get walking => _walking;
  bool _walking = false;

  /// Begin (or restart) a walk over [types], with nothing framed yet.
  void begin(Set<String> types) {
    _types = Set<String>.unmodifiable(types);
    _step = null;
    _exhausted = false;
    notifyListeners();
  }

  /// Forget the walk — the filter changed underneath it, or was turned off.
  void reset() {
    if (_types.isEmpty && _step == null && !_exhausted) return;
    _types = const <String>{};
    _step = null;
    _exhausted = false;
    notifyListeners();
  }

  /// Take one step, and hand back what the runtime framed.
  ///
  /// A `null` answer marks the walk exhausted rather than throwing it away, so
  /// the control that asked can fade out instead of blinking back to its first
  /// appearance.
  Future<SeatLayerAccessibleStep?> next(
    SeatLayerPickerController controller,
  ) async {
    if (_walking) return _step;
    _walking = true;
    notifyListeners();
    try {
      final step = await controller.focusNextAccessibleSection(
        types: _types.isEmpty ? null : _types,
      );
      _step = step;
      _exhausted = step == null;
      return step;
    } catch (_) {
      // The controller already published the typed failure for native UI; the
      // walk keeps whatever it last framed rather than claiming it ended.
      return _step;
    } finally {
      _walking = false;
      notifyListeners();
    }
  }
}

final Expando<SeatLayerAccessibleTour> _tours =
    Expando<SeatLayerAccessibleTour>('seatlayer-accessible-tour');

/// The tour belonging to [controller], created on first ask.
///
/// Attached to the controller rather than held by a widget: the sheet that
/// starts the walk is disposed before the pill that continues it is built.
SeatLayerAccessibleTour seatLayerAccessibleTourOf(
  SeatLayerPickerController controller,
) =>
    _tours[controller] ??= SeatLayerAccessibleTour();

/// How many sections hold a free space matching any of [types].
///
/// Counted from `sections[].accessibleFree`, so it is only meaningful on a
/// runtime advertising `section-access-counts-v1`; a section with no entry for
/// an active type was not counted and is not counted here either.
int seatLayerAccessibleSectionCount(
  SeatLayerPickerSnapshot? snapshot,
  Set<String> types,
) {
  if (snapshot == null || types.isEmpty) return 0;
  var count = 0;
  for (final section in snapshot.sections) {
    for (final type in types) {
      final free = section.accessibleFree[type];
      if (free != null && free > 0) {
        count++;
        break;
      }
    }
  }
  return count;
}

/// How many free spaces [section] holds across [types], or `null` when none of
/// them was counted.
///
/// `null` and `0` are different answers and the chrome draws them differently:
/// nothing at all versus a section the filter lit but has emptied.
int? seatLayerSectionAccessibleFree(
  SeatLayerPickerSectionSummary section,
  Set<String> types,
) {
  int? total;
  for (final type in types) {
    final free = section.accessibleFree[type];
    if (free == null) continue;
    total = (total ?? 0) + free;
  }
  return total;
}
