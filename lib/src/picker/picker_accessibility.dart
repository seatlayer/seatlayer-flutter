/// The accessibility and view filters, and the sheet that edits them.

library;

import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The filters a buyer with an access need reaches for.
///
/// On the phone this is one 44-point control at the map's bottom-left corner,
/// and the colourblind-safe palette lives inside it rather than as its own
/// button on the map — which is where someone who needs it goes looking.
class SeatLayerPickerAccessibilityFilters extends StatelessWidget {
  /// Creates the accessibility filter control.
  const SeatLayerPickerAccessibilityFilters({
    super.key,
    this.compact = false,
  });

  /// Whether to render the phone's single round control.
  final bool compact;

  static const Map<String, String> _labels = <String, String>{
    'wheelchair': 'Wheelchair',
    'companion': 'Companion',
    'semi-ambulatory': 'Semi-ambulatory',
    'designated-aisle': 'Aisle seat',
    'step-free': 'Step-free',
    'hearing': 'Hearing support',
    'cart': 'Mobility cart',
    'sign-language': 'Sign language view',
    'low-vision': 'Low vision',
    'sensory-friendly': 'Sensory-friendly',
    'plus-size': 'Plus-size seat',
    'lift-armrest': 'Lift armrest',
  };

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final snapshot = state.snapshot;
    if (snapshot == null ||
        !snapshot.capabilities.contains('accessibilityFilter')) {
      return const SizedBox.shrink();
    }
    final active = snapshot.map.accessibilityFilter;
    final onPressed =
        state.isBusy ? null : () => ignorePickerAction(_show(context));
    if (compact) {
      final theme = seatLayerPickerThemeOf(context);
      final size = theme.layout.accessibilityControlSize;
      return SizedBox.square(
        dimension: size,
        child: IconButton(
          tooltip: active.isEmpty
              ? SeatLayerPickerScope.stringsOf(context).accessibility
              : '${active.length} accessibility filters active',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          style: IconButton.styleFrom(
            backgroundColor: theme.surface.withAlpha(240),
            foregroundColor: active.isEmpty ? theme.text : theme.accent,
            side: BorderSide(color: theme.divider),
          ),
          onPressed: onPressed,
          icon: Badge(
            isLabelVisible: active.isNotEmpty,
            label: Text('${active.length}'),
            child: const Icon(Icons.accessible_forward_rounded, size: 20),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.accessible_forward_rounded, size: 18),
      label:
          Text(active.isEmpty ? 'Accessibility' : '${active.length} filters'),
    );
  }

  Future<void> _show(BuildContext context) async {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final initial = <String>{
      ...?controller.state.snapshot?.map.accessibilityFilter,
    };
    final initialHideLimited =
        controller.state.snapshot?.map.hideLimitedView ?? false;
    final initialColorblind =
        controller.state.snapshot?.map.colorblindSafe ?? false;
    var selected = initial;
    var hideLimited = initialHideLimited;
    var colorblind = initialColorblind;
    final result = await showModalBottomSheet<
        ({
          Set<String> types,
          bool hideLimited,
          bool colorblind,
        })>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Accessibility and view',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: _labels.entries.map((entry) {
                        final on = selected.contains(entry.key);
                        return FilterChip(
                          selected: on,
                          label: Text(entry.value),
                          onSelected: (_) => setSheetState(() {
                            selected = <String>{...selected};
                            on
                                ? selected.remove(entry.key)
                                : selected.add(entry.key);
                          }),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hide limited-view seats'),
                  value: hideLimited,
                  onChanged: (value) =>
                      setSheetState(() => hideLimited = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Colorblind-safe colors'),
                  value: colorblind,
                  onChanged: (value) => setSheetState(() => colorblind = value),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    (
                      types: selected,
                      hideLimited: hideLimited,
                      colorblind: colorblind,
                    ),
                  ),
                  child: const Text('Apply filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result == null) return;
    await controller.setAccessibilityFilter(result.types);
    if (result.hideLimited != initialHideLimited) {
      await controller.setLimitedViewHidden(result.hideLimited);
    }
    if (result.colorblind != initialColorblind) {
      await controller.setColorblindSafe(result.colorblind);
    }
  }
}
