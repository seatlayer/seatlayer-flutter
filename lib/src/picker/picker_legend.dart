import 'package:flutter/material.dart';

import 'picker_a11y.dart';
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
  /// Only the edge a chip is actually crossing is faded: a rail scrolled to
  /// its end shows the last price whole, so a hidden chip never looks like the
  /// end of the list and a rail that fits keeps both rounded ends.
  static const double edgeFade = SeatLayerSizeTokens.legendRailEdgeFade;

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
    final chipStyle =
        (theme.styles.legendChipStyle ?? const SeatLayerSurfaceStyle())
            .merge(widget.style);

    final Widget list = ListView.separated(
      // One point of air, so a chip's border is not shaved by the scroller's
      // own edge; the rail's ten points are outside it.
      padding: const EdgeInsets.all(1),
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 5),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = active.contains(category.key);
        // A spread cannot fit a chip, so it becomes a floor: "€30+" is honest
        // and short, and the exact range is one tap away in the list. A
        // category with no configured price is a real chart state, and a chip
        // that is only a dot says nothing — so it wears its name instead.
        final priced = category.priceMin > 0 || category.priceMax > 0;
        final amount = !priced
            ? null
            : category.priceMin == category.priceMax
                ? pickerMoney(context, category.priceMin, currency)
                : '${pickerMoney(context, category.priceMin, currency)}+';
        return _LegendChip(
          style: chipStyle,
          label: amount == null
              ? category.label
              : compact
                  ? amount
                  : '${category.label} · $amount',
          color: pickerColor(category.color) ?? theme.accent,
          selected: selected,
          compact: compact,
          theme: theme,
          semanticsLabel:
              amount == null ? category.label : '${category.label} — $amount',
          // `focus` on BOTH directions. Turning a band on flies to its seats;
          // turning it off is "show me everything" and must answer with the
          // whole venue. Clearing without focus left the buyer inside the
          // drill-in they were in, with the block melt running under seats
          // drawn at full strength — the map came back washed out.
          onPressed: () => ignorePickerAction(
            controller.setCategoryFilter(
              selected ? const <String>{} : <String>{category.key},
              focus: true,
            ),
          ),
        );
      },
    );

    final Widget scroller = NotificationListener<ScrollMetricsNotification>(
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
    );

    return SizedBox(
      // The band, not the chip: the drawn chip stays twenty-four points, and
      // the height around it is the part a thumb lands on. Both grow with the
      // buyer's text size, up to the rail's own clamp — a price the rail has
      // cut in half is a price nobody can act on.
      height: seatLayerScaledExtent(
        context,
        compact
            ? SeatLayerSizeTokens.minimumHitTarget
            : SeatLayerSizeTokens.minimumHitTarget - 4,
        max: SeatLayerTypeScaleTokens.rail,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        child: Row(
          children: <Widget>[
            // THE WAY OUT COMES FIRST AND NEVER SCROLLS AWAY. Every other chip
            // narrows the map; without this one a buyer who pinned a category
            // could only widen it again from a control two gestures deep
            // inside a collapsed sheet. The web pins it with `position:sticky`
            // inside the scroller; here it is simply not in the scroller,
            // which is the same promise and needs no halo to hide chips
            // sliding under it.
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 1,
                top: 1,
                bottom: 1,
              ),
              child: _LegendChip(
                style: chipStyle,
                label: strings.allPrices,
                color: null,
                selected: active.isEmpty,
                compact: compact,
                theme: theme,
                semanticsLabel: strings.allPrices,
                // "All prices" means show me everything: the venue, with every
                // section on screen — not the pose a band took the buyer from,
                // and not the section they had drilled into before that.
                onPressed: () => ignorePickerAction(
                  controller.setCategoryFilter(const <String>{}, focus: true),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: scroller),
          ],
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
        child: Center(child: _ink(context, chipStyle)),
      ),
    );
  }

  Widget _ink(BuildContext context, SeatLayerSurfaceStyle chipStyle) {
    // A named category leads with its colour; the way out of a filter has no
    // colour to key, so it wears the rail's own surface and a heavier word.
    final naming = color != null;
    final Color ground = selected
        ? theme.accent
        : chipStyle.color ?? (naming ? theme.background : theme.surface);
    final BorderSide side = BorderSide(
      color: selected ? const Color(0x00000000) : theme.divider,
    );
    return SizedBox(
      height: seatLayerScaledExtent(
        context,
        compact ? SeatLayerSizeTokens.legendChipHeight : 40,
        max: SeatLayerTypeScaleTokens.rail,
      ),
      child: Material(
        color: ground,
        elevation: chipStyle.elevation ?? 0,
        shape: chipStyle.shape ??
            theme.styles.chipShape?.copyWith(side: side) ??
            StadiumBorder(side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: compact
                ? const EdgeInsetsDirectional.fromSTEB(7, 0, 9, 0)
                : const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (color != null) ...[
                  _CategoryDot(
                    color: color!,
                    theme: theme,
                    selected: selected,
                    size: compact
                        ? SeatLayerSizeTokens.legendChipDotSize
                        : SeatLayerSizeTokens.legendChipDotSize + 3,
                  ),
                  const SizedBox(width: 5),
                ],
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? theme.onAccent : theme.text,
                      fontSize: compact ? theme.layout.legendChipFontSize : 12,
                      // The way out is the one chip that is a word rather than
                      // a number, so it is set a little lighter than the
                      // prices it leads.
                      fontWeight:
                          naming ? FontWeight.w800 : const FontWeight(750),
                      fontFamily: theme.fontFamily,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
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

/// The chip's colour key, drawn so it survives every ground it sits on.
///
/// On a light map the category colours are shown tinted rather than solid, and
/// the swatch follows: a pale fill inside a full-strength ring, which is the
/// same seat a buyer is looking for. A selected chip fills with the accent, so
/// the ring turns to the accent's ink to stay visible.
class _CategoryDot extends StatelessWidget {
  const _CategoryDot({
    required this.color,
    required this.theme,
    required this.selected,
    required this.size,
  });

  final Color color;
  final SeatLayerResolvedPickerTheme theme;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final light = theme.brightness == Brightness.light;
    final ring = selected
        ? theme.onAccent
        : light
            ? color
            : null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: light && !selected
            ? Color.alphaBlend(pickerAlpha(color, .32), theme.surface)
            : color,
        shape: BoxShape.circle,
        border: ring == null
            ? null
            : Border.all(color: ring, width: 1.5, strokeAlign: 1),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}
