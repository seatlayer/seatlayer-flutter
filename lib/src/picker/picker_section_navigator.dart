/// The wide layout's list of sections.

library;

import 'package:flutter/material.dart';

import 'picker_camera_actions.dart';
import 'picker_internal.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// A chip per section, for the wide layout's side panel.
///
/// A phone gets no equivalent: a chip list of every section is a directory,
/// and it is the wide layout's side panel that has room for one. The phone
/// answers "where am I, and how do I get back" with the map itself — pinch
/// out past the melt point, or the stepped `−` control in the bottom-right
/// corner. This navigator hides itself once seats are revealed.
class SeatLayerPickerSectionNavigator extends StatelessWidget {
  /// Creates the wide layout's section chip list.
  const SeatLayerPickerSectionNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final sections = state.snapshot?.sections ?? const [];
    if (sections.isEmpty || state.snapshot?.map.rung == 'seats') {
      return const SizedBox.shrink();
    }
    final theme = seatLayerPickerThemeOf(context);
    final active = state.snapshot?.map.focusedSectionId;
    return Material(
      color: theme.surface,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          scrollDirection: Axis.horizontal,
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final section = sections[index];
            return ChoiceChip(
              selected: active == section.id,
              label: Text(section.displayLabel ?? section.label),
              onSelected: state.isBusy
                  ? null
                  : (_) =>
                      ignorePickerAction(controller.focusSection(section.id)),
            );
          },
        ),
      ),
    );
  }
}
