/// The accessibility and view filters, and the sheet that edits them.

library;

import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_models.dart';
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
      style: seatLayerButtonShape(
        seatLayerPickerThemeOf(context).buttonRadius,
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.accessible_forward_rounded, size: 18),
      label: Text(
        active.isEmpty
            ? SeatLayerPickerScope.stringsOf(context).accessibility
            : '${active.length} filters',
      ),
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
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    // What this EVENT actually offers, in the runtime's own order, named from
    // the string table. One the table has no name for is drawn under its wire
    // key rather than dropped, so a need added on the runtime side is
    // reachable before this side catches up.
    //
    // A runtime that does not report its needs falls back to the full static
    // list, which is what the sheet has always shown. The fallback is on an
    // empty list rather than on the capability alone, because "reported
    // nothing" and "reported that this venue offers nothing" are the same
    // twelve dead chips either way, and the twelve are at least honest about
    // what the filter can express.
    final offered = controller.state.snapshot?.map.accessNeeds ??
        const <SeatLayerAccessNeed>[];
    final useOffered = controller.supportsAccessNeeds && offered.isNotEmpty;
    final needs = <_AccessNeedChip>[
      if (useOffered)
        for (final need in offered)
          _AccessNeedChip(
            key: need.key,
            label: strings.accessNeeds[need.key] ?? need.key,
            count: need.count,
          )
      else
        for (final entry in strings.accessNeeds.entries)
          _AccessNeedChip(key: entry.key, label: entry.value),
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: needs.map((need) {
                        final on = selected.contains(need.key);
                        // A need with nothing free stays on the sheet and goes
                        // dark. Removing it would say the venue has no such
                        // seats, which is a different and usually wrong claim.
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
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.hideLimitedView),
                  value: hideLimited,
                  onChanged: (value) =>
                      setSheetState(() => hideLimited = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.colorblindSafe),
                  value: colorblind,
                  onChanged: (value) => setSheetState(() => colorblind = value),
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
    await controller.setAccessibilityFilter(result.types);
    if (result.hideLimited != initialHideLimited) {
      await controller.setLimitedViewHidden(result.hideLimited);
    }
    if (result.colorblind != initialColorblind) {
      await controller.setColorblindSafe(result.colorblind);
    }
  }
}

/// One chip on the accessibility sheet.
///
/// [count] is null when the runtime did not report one, which is the static
/// fallback: no number is drawn and the chip stays live, because an unknown
/// count is not a count of zero.
@immutable
class _AccessNeedChip {
  const _AccessNeedChip({required this.key, required this.label, this.count});

  final String key;
  final String label;
  final int? count;
}
