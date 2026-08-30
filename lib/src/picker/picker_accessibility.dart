/// The accessibility and view filters, and the sheet that edits them.

library;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'picker_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final snapshot = state.snapshot;
    final controller = SeatLayerPickerScope.controllerOf(context);
    final available = _availability(controller, snapshot);
    if (!available.any) {
      return const SizedBox.shrink();
    }
    final activeCount = (available.accessibility
            ? snapshot!.map.accessibilityFilter.length
            : 0) +
        (available.limited && snapshot?.map.hideLimitedView == true ? 1 : 0) +
        (available.colorblind && snapshot?.map.colorblindSafe == true ? 1 : 0);
    final onPressed =
        state.isBusy ? null : () => ignorePickerAction(_show(context));
    if (compact) {
      final theme = seatLayerPickerThemeOf(context);
      final size = theme.layout.accessibilityControlSize;
      return SizedBox.square(
        dimension: size,
        child: IconButton(
          tooltip: activeCount == 0
              ? SeatLayerPickerScope.stringsOf(context).accessibility
              : '$activeCount accessibility filters active',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          style: IconButton.styleFrom(
            backgroundColor: theme.surface.withAlpha(240),
            foregroundColor: activeCount == 0 ? theme.text : theme.accent,
            side: BorderSide(color: theme.divider),
          ),
          onPressed: onPressed,
          icon: Badge(
            isLabelVisible: activeCount > 0,
            label: Text('$activeCount'),
            child: const Icon(Icons.accessible_forward_rounded, size: 20),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      style: seatLayerButtonShape(
        seatLayerPickerThemeOf(context).buttonRadius,
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.accessible_forward_rounded, size: 18),
      label: Text(
        activeCount == 0
            ? SeatLayerPickerScope.stringsOf(context).accessibility
            : '$activeCount filters',
      ),
    );
  }

  Future<void> _show(BuildContext context) async {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final snapshot = controller.state.snapshot;
    final available = _availability(controller, snapshot);
    if (!available.any || snapshot == null) return;
    final initial = <String>{
      if (available.accessibility) ...snapshot.map.accessibilityFilter,
    };
    final initialHideLimited =
        available.limited && snapshot.map.hideLimitedView;
    final initialColorblind =
        available.colorblind && snapshot.map.colorblindSafe;
    var selected = initial;
    var hideLimited = initialHideLimited;
    var colorblind = initialColorblind;
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    // What this EVENT actually offers, in the runtime's own order, named from
    // the string table. One the table has no name for is drawn under its wire
    // key rather than dropped, so a need added on the runtime side is
    // reachable before this side catches up.
    //
    // Missing inventory truth fails closed. The static twelve-key vocabulary
    // is not evidence that this event has any of those seats.
    final offered = snapshot.map.accessNeeds;
    final needs = <_AccessNeedChip>[
      if (available.accessibility)
        for (final need in offered)
          _AccessNeedChip(
            key: need.key,
            label: strings.accessNeeds[need.key] ?? need.key,
            count: need.count,
          )
    ];
    // The sheet body is built INSIDE the scope and handed to the route, so the
    // route's builder — which runs under the Navigator overlay, above the
    // scope — still gets the picker's controller, strings and palette.
    final body = SeatLayerPickerScope.inherit(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.accessibilityTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (needs.isNotEmpty)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: needs.map((need) {
                          final on = selected.contains(need.key);
                          // A need with nothing free stays on the sheet and
                          // goes dark. Removing it would claim the venue has no
                          // such seats, which is a different fact.
                          final enabled = need.count == null || need.count! > 0;
                          return FilterChip(
                            selected: on,
                            label: Text(
                              need.count == null || need.count == 0
                                  ? need.label
                                  : strings.accessNeedWithCount(
                                      need.label,
                                      need.count!,
                                    ),
                            ),
                            onSelected: enabled
                                ? (_) => setSheetState(() {
                                      selected = <String>{...selected};
                                      on
                                          ? selected.remove(need.key)
                                          : selected.add(need.key);
                                    })
                                : null,
                          );
                        }).toList(growable: false),
                      ),
                    ),
                  ),
                if (available.limited)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.hideLimitedView),
                    value: hideLimited,
                    onChanged: (value) =>
                        setSheetState(() => hideLimited = value),
                  ),
                if (available.colorblind)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.colorblindSafe),
                    value: colorblind,
                    onChanged: (value) =>
                        setSheetState(() => colorblind = value),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  style: seatLayerButtonShape(theme.buttonRadius),
                  onPressed: () => Navigator.of(context).pop(
                    (
                      types: selected,
                      hideLimited: hideLimited,
                      colorblind: colorblind,
                    ),
                  ),
                  child: Text(strings.applyFilters),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final result = await showModalBottomSheet<
        ({
          Set<String> types,
          bool hideLimited,
          bool colorblind,
        })>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.surface,
      builder: (_) => body,
    );
    if (result == null) return;
    final live = _availability(controller, controller.state.snapshot);
    if (live.accessibility && !setEquals(result.types, initial)) {
      await controller.setAccessibilityFilter(result.types);
    }
    if (live.limited && result.hideLimited != initialHideLimited) {
      await controller.setLimitedViewHidden(result.hideLimited);
    }
    if (live.colorblind && result.colorblind != initialColorblind) {
      await controller.setColorblindSafe(result.colorblind);
    }
  }
}

_FilterAvailability _availability(
  SeatLayerPickerController controller,
  SeatLayerPickerSnapshot? snapshot,
) {
  final bundle = controller.mapController.bundleInfo;
  final nativeChrome =
      bundle?.supportsCapability('native-chrome-contract-v1') == true;
  final accessibility = snapshot != null &&
      snapshot.capabilities.contains('accessibilityFilter') &&
      controller.supportsAccessNeeds &&
      snapshot.map.accessNeeds.isNotEmpty &&
      nativeChrome &&
      bundle?.supportsCommand('picker.setAccessibilityFilter') == true;
  final limited = snapshot != null &&
      snapshot.capabilities.contains('limitedViewFilter') &&
      nativeChrome &&
      bundle?.supportsCommand('picker.setLimitedViewFilter') == true;
  final colorblind = snapshot != null &&
      nativeChrome &&
      bundle?.supportsCapability('colorblind-safe') == true &&
      bundle?.supportsCommand('picker.setColorblindSafe') == true;
  return _FilterAvailability(
    accessibility: accessibility,
    limited: limited,
    colorblind: colorblind,
  );
}

@immutable
class _FilterAvailability {
  const _FilterAvailability({
    required this.accessibility,
    required this.limited,
    required this.colorblind,
  });

  final bool accessibility;
  final bool limited;
  final bool colorblind;

  bool get any => accessibility || limited || colorblind;
}

/// One chip on the accessibility sheet.
///
/// [count] is nullable for forward-compatible callers even though current
/// inventory reports include it.
@immutable
class _AccessNeedChip {
  const _AccessNeedChip({required this.key, required this.label, this.count});

  final String key;
  final String label;
  final int? count;
}
