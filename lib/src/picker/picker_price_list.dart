/// The wide panel's prices: one row per ticket type, its colour, its name and
/// its price.
///
/// Not exported. The phone keeps the chip rail (`SeatLayerPriceLegend`); a
/// panel beside the map has the room to name every price, so it lists them.

library;

import 'package:flutter/material.dart';

import 'picker_a11y.dart';
import 'picker_header.dart' show seatLayerAccentText;
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The ticket types as a list, each row a filter toggle.
///
/// A row is the same toggle a chip is on the phone: pressed, the map shows
/// only that price's seats; pressed again, everything. A price with nothing
/// left is struck through and quieter, and stays a toggle, so a buyer who
/// pinned it can switch the filter off from the row they switched it on with.
/// A long list scrolls inside a bound, so the buyer's seats stay in view.
class SeatLayerWidePriceList extends StatelessWidget {
  /// Creates the wide price list.
  const SeatLayerWidePriceList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final categories = state.categories
        .where((category) => !category.notForSale)
        .toList(growable: false);
    if (categories.isEmpty) return const SizedBox.shrink();
    final currency = state.snapshot?.currency ?? 'USD';
    final active = state.snapshot?.map.categoryFilter ?? const <String>{};
    // The rail's rule: a zero is believed only from a runtime that counts.
    final countsSeats = controller.mapController.bundleInfo
            ?.supportsCapability('category-availability-v1') ==
        true;
    final rows = <Widget>[
      for (final category in categories)
        _PriceRow(
          theme: theme,
          label: category.label,
          amount: _amount(context, category, currency),
          color: pickerColor(category.color) ?? theme.accent,
          selected: active.contains(category.key),
          soldOut: countsSeats && category.free == 0,
          soldOutWord: strings.soldOutTitle,
          onPressed: () => ignorePickerAction(
            controller.setCategoryFilter(
              active.contains(category.key)
                  ? const <String>{}
                  : <String>{category.key},
              focus: true,
            ),
          ),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SeatLayerSizeTokens.widePanelPadX -
            SeatLayerSizeTokens.widePriceRowPadX,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: SeatLayerSizeTokens.widePriceListMaxHeight,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ),
    );
  }

  /// The price as the rail writes it: one figure, or the floor of a spread
  /// with a `+`; null where the category has no price configured.
  static String? _amount(
    BuildContext context,
    SeatLayerPickerCategory category,
    String currency,
  ) {
    final priced = category.priceMin > 0 || category.priceMax > 0;
    if (!priced) return null;
    return category.priceMin == category.priceMax
        ? pickerMoney(context, category.priceMin, currency)
        : '${pickerMoney(context, category.priceMin, currency)}+';
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.theme,
    required this.label,
    required this.amount,
    required this.color,
    required this.selected,
    required this.soldOut,
    required this.soldOutWord,
    required this.onPressed,
  });

  final SeatLayerResolvedPickerTheme theme;
  final String label;
  final String? amount;
  final Color color;
  final bool selected;
  final bool soldOut;
  final String soldOutWord;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ink = soldOut
        ? theme.mutedText
        : selected
            ? seatLayerAccentText(theme)
            : theme.text;
    final style = TextStyle(
      color: ink,
      fontSize: SeatLayerSizeTokens.widePriceFontSize,
      fontFamily: theme.fontFamily,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: <String>[
        amount == null ? label : '$label — $amount',
        if (soldOut) soldOutWord,
      ].join(', '),
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.control),
            child: Ink(
              decoration: BoxDecoration(
                color: selected
                    ? pickerAlpha(theme.accent, .09)
                    : const Color(0x00000000),
                borderRadius:
                    BorderRadius.circular(SeatLayerRadiusTokens.control),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SeatLayerSizeTokens.widePriceRowHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SeatLayerSizeTokens.widePriceRowPadX,
                  ),
                  child: Row(
                    children: <Widget>[
                      Opacity(
                        opacity:
                            soldOut ? SeatLayerOpacityTokens.legendSoldOut : 1,
                        child: Container(
                          width: SeatLayerSizeTokens.widePriceDotSize,
                          height: SeatLayerSizeTokens.widePriceDotSize,
                          decoration: BoxDecoration(
                            color: soldOut ? theme.mutedText : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: SeatLayerSizeTokens.widePriceDotGap),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: style.copyWith(
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w600),
                          ),
                        ),
                      ),
                      if (amount != null) ...<Widget>[
                        const SizedBox(
                          width: SeatLayerSizeTokens.widePriceDotGap,
                        ),
                        Text(
                          amount!,
                          maxLines: 1,
                          style: style.copyWith(
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w800),
                            decoration:
                                soldOut ? TextDecoration.lineThrough : null,
                            decorationColor: ink,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
