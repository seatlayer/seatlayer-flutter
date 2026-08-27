import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// What each colour on the map costs.
///
/// A row of small chips — a dot and a price — that scrolls sideways rather than
/// wrapping, so a venue with nine categories costs the map one line instead of
/// three. Tapping a chip filters the map to that category and frames it;
/// tapping it again clears the filter.
class SeatLayerPriceLegend extends StatelessWidget {
  /// Creates the price legend.
  const SeatLayerPriceLegend({super.key, this.compact = false});

  /// Whether to render the phone's chip size and spacing.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final categories = state.categories
        .where((category) => !category.notForSale)
        .toList(growable: false);
    if (categories.isEmpty) return const SizedBox.shrink();
    final currency = state.snapshot?.currency ?? 'USD';
    final active = state.snapshot?.map.categoryFilter ?? const <String>{};

    return SizedBox(
      height: compact ? 30 : 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = active.contains(category.key);
          return _LegendChip(
            label: compact
                ? pickerCompactMoney(category.priceMin, currency)
                : '${category.label} · '
                    '${pickerMoney(context, category.priceMin, currency)}',
            color: pickerColor(category.color) ?? theme.accent,
            selected: selected,
            compact: compact,
            semanticsLabel: '${category.label}, '
                '${pickerMoney(context, category.priceMin, currency)}',
            onPressed: () => ignorePickerAction(
              controller.setCategoryFilter(
                selected ? const <String>{} : <String>{category.key},
                focus: !selected,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The price legend, under its dev.4 name.
@Deprecated('Renamed to SeatLayerPriceLegend; the alias goes away at 0.4.')
typedef SeatLayerPickerPriceRail = SeatLayerPriceLegend;

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.compact,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool compact;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: Material(
        color: selected
            ? theme.accent
            : Color.alphaBlend(pickerAlpha(theme.text, .04), theme.surface),
        shape: StadiumBorder(
          side: BorderSide(color: selected ? theme.accent : theme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                  child: SizedBox.square(dimension: compact ? 8 : 10),
                ),
                SizedBox(width: compact ? 5 : 7),
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? theme.onAccent : theme.text,
                      fontSize: compact
                          ? theme.layout.legendChipFontSize
                          : 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
