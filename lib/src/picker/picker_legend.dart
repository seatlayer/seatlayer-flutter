import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_styles.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// What each colour on the map costs.
///
/// A row of small chips — a dot and a price — that scrolls sideways rather than
/// wrapping, so a venue with nine categories costs the map one line instead of
/// three. Tapping a chip filters the map to that category and frames it;
/// tapping it again clears the filter.
class SeatLayerPriceLegend extends StatefulWidget {
  /// Creates the price legend.
  const SeatLayerPriceLegend({super.key, this.compact = false, this.style});

  /// Whether to render the phone's chip size and spacing.
  final bool compact;

  /// Overrides [SeatLayerPickerStyles.legendChipStyle] for these chips.
  final SeatLayerSurfaceStyle? style;

  /// How wide each soft edge is where the row runs on past the viewport.
  ///
  /// The trailing edge is also the gap the rail keeps clear of whatever sits
  /// beside it, so the last chip is never a hard vertical cut against the
  /// Map/3D control.
  static const double edgeFade = 22;

  @override
  State<SeatLayerPriceLegend> createState() => _SeatLayerPriceLegendState();
}

class _SeatLayerPriceLegendState extends State<SeatLayerPriceLegend> {
  /// `(fade the leading edge, fade the trailing edge)`.
  ///
  /// A notifier rather than [setState]: the scroll metrics arrive during
  /// layout, where rebuilding the subtree is not allowed, and a repainted
  /// [ShaderMask] is all this needs.
  final ValueNotifier<(bool, bool)> _edges =
      ValueNotifier<(bool, bool)>((false, false));

  @override
  void dispose() {
    _edges.dispose();
    super.dispose();
  }

  void _readEdges(ScrollMetrics metrics) {
    if (!metrics.hasContentDimensions) return;
    final next = (
      metrics.extentBefore > 0.5,
      metrics.extentAfter > 0.5,
    );
    if (_edges.value != next) _edges.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    // Over the immersive scene this rail is white chrome on a dark venue, so
    // it takes the scene's palette the way the 3D chrome does.
    final theme = seatLayerMapChromeThemeOf(context);
    final categories = state.categories
        .where((category) => !category.notForSale)
        .toList(growable: false);
    if (categories.isEmpty) return const SizedBox.shrink();
    final currency = state.snapshot?.currency ?? 'USD';
    final active = state.snapshot?.map.categoryFilter ?? const <String>{};
    final direction = Directionality.of(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    // The rail leads with the way out of a filter, the way the web rail does:
    // on a 390 pt phone the chip that turned the filter on is often scrolled
    // off the screen, and a buyer who has not filtered yet reads the same
    // first chip as "these are all the prices" — which is what it means.
    const clearFilter = 1;
    final chipStyle =
        (theme.styles.legendChipStyle ?? const SeatLayerSurfaceStyle())
            .merge(widget.style);

    final Widget list = ListView.separated(
      // The trailing pad is the fade's own width, so a rail scrolled to its
      // end shows the last chip whole rather than under the soft edge.
      padding: EdgeInsetsDirectional.only(
        start: compact ? 10 : 12,
        end: SeatLayerPriceLegend.edgeFade,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: categories.length + clearFilter,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        if (index < clearFilter) {
          return _LegendChip(
            style: chipStyle,
            label: strings.allPrices,
            color: null,
            selected: active.isEmpty,
            compact: compact,
            theme: theme,
            semanticsLabel: strings.allPrices,
            onPressed: () => ignorePickerAction(
              controller.setCategoryFilter(const <String>{}, focus: false),
            ),
          );
        }
        final category = categories[index - clearFilter];
        final selected = active.contains(category.key);
        return _LegendChip(
          style: chipStyle,
          label: compact
              ? pickerCompactMoney(category.priceMin, currency)
              : '${category.label} · '
                  '${pickerMoney(context, category.priceMin, currency)}',
          color: pickerColor(category.color) ?? theme.accent,
          selected: selected,
          compact: compact,
          theme: theme,
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
    );

    return SizedBox(
      // The band, not the chip: the drawn chip stays thirty points on a phone,
      // and the extra height around it is the part a thumb lands on.
      height: compact ? SeatLayerSizeTokens.minimumHitTarget : 40,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          _readEdges(notification.metrics);
          return false;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _readEdges(notification.metrics);
            return false;
          },
          child: ValueListenableBuilder<(bool, bool)>(
            valueListenable: _edges,
            child: list,
            builder: (context, edges, child) {
              final (leading, trailing) = edges;
              if (!leading && !trailing) return child!;
              return ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => _edgeShader(
                  bounds,
                  direction: direction,
                  leading: leading,
                  trailing: trailing,
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// An opacity ramp that dissolves whichever edge the row continues past.
Shader _edgeShader(
  Rect bounds, {
  required TextDirection direction,
  required bool leading,
  required bool trailing,
}) {
  const fade = SeatLayerPriceLegend.edgeFade;
  final width = bounds.width <= 0 ? 1.0 : bounds.width;
  // `stops` must not decrease, which a fade wider than half a narrow rail
  // would otherwise cause.
  final ramp = (fade / width).clamp(0.0, 0.5);
  final start = leading ? ramp : 0.0;
  final end = trailing ? 1 - ramp : 1.0;
  return LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: const <Color>[
      Color(0x00FFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: <double>[0, start, end, 1],
  ).createShader(bounds, textDirection: direction);
}

/// The price legend, under its dev.4 name.
@Deprecated('Renamed to SeatLayerPriceLegend; the alias goes away at 0.4.')
typedef SeatLayerPickerPriceRail = SeatLayerPriceLegend;

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.style,
    required this.label,
    required this.color,
    required this.selected,
    required this.compact,
    required this.semanticsLabel,
    required this.theme,
    required this.onPressed,
  });

  final SeatLayerSurfaceStyle style;
  final String label;

  /// The category's colour, or null for a chip that names no category.
  final Color? color;
  final bool selected;
  final bool compact;
  final String semanticsLabel;
  final SeatLayerResolvedPickerTheme theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final chipStyle = style;
    // The ink is the chip; the target is the whole band it sits in. The outer
    // gesture answers the strip above and below the pill, the inner ink well
    // answers the pill itself and keeps the ripple inside it, and only one of
    // the two ever wins a tap.
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Center(child: _ink(chipStyle)),
      ),
    );
  }

  Widget _ink(SeatLayerSurfaceStyle chipStyle) => SizedBox(
        height: compact ? 30 : 40,
        child: Material(
        color: selected
            ? theme.accent
            : chipStyle.color ??
                Color.alphaBlend(pickerAlpha(theme.text, .04), theme.surface),
        elevation: chipStyle.elevation ?? 0,
        shape: chipStyle.shape ??
            theme.styles.chipShape?.copyWith(
              side: BorderSide(color: selected ? theme.accent : theme.divider),
            ) ??
            StadiumBorder(
              side:
                  BorderSide(color: selected ? theme.accent : theme.divider),
            ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (color != null) ...[
                  DecoratedBox(
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                    child: SizedBox.square(dimension: compact ? 8 : 10),
                  ),
                  SizedBox(width: compact ? 5 : 7),
                ],
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? theme.onAccent : theme.text,
                      fontSize: compact ? theme.layout.legendChipFontSize : 12,
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
