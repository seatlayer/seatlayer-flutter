import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

CategoryTier? seatLayerPickerSelectedTier(
  SelectedSeat seat,
  String? tierId,
) {
  if (tierId == null) return null;
  for (final tier in seat.tiers ?? const <CategoryTier>[]) {
    if (tier.id == tierId) return tier;
  }
  return null;
}

double? seatLayerPickerSelectedPrice(SelectedSeat seat, String? tierId) =>
    seatLayerPickerSelectedTier(seat, tierId)?.price ?? seat.price;

String seatLayerPickerSelectedCurrency(SelectedSeat seat, String? tierId) =>
    seatLayerPickerSelectedTier(seat, tierId)?.currency ??
    seat.currency ??
    'USD';

/// One ticket type, as a row the buyer presses rather than a menu entry.
///
/// The selected row is marked three ways at once — an accent border, an accent
/// wash, and a rail on its leading edge — because on a phone the difference
/// between two rows a few points apart has to survive a glance.
class SeatLayerPickerSeatTierChoice extends StatelessWidget {
  /// Creates one ticket-type row.
  const SeatLayerPickerSeatTierChoice({
    super.key,
    required this.tier,
    required this.currency,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.compact = false,
  });

  /// The ticket type this row offers.
  final CategoryTier tier;

  /// The currency to price it in when the tier does not name its own.
  final String currency;

  /// Whether this is the type the seat is currently being bought as.
  final bool selected;

  /// Whether the row may be pressed.
  final bool enabled;

  /// Called when the buyer chooses this type.
  final VoidCallback onTap;

  /// Whether this row is on the phone's confirm card rather than the wide one.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final guidance = tier.buyerMessage ??
        (tier.restriction == 'companion'
            ? strings.tierCompanionGuidance
            : null);
    final price = pickerMoney(
      context,
      tier.price,
      tier.currency ?? currency,
    );
    final radius =
        BorderRadius.circular(SeatLayerRadiusTokens.button);
    return Semantics(
      label: <String>[
        tier.name,
        price,
        if (guidance != null) guidance,
      ].join(' · '),
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      child: Material(
        color: selected
            ? Color.alphaBlend(pickerAlpha(theme.accent, .13), theme.surface)
            // A shade off the surface, so the rows read as choices sitting on
            // the card rather than as lines ruled across it.
            : Color.alphaBlend(
                pickerAlpha(theme.background, .72),
                theme.surface,
              ),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: selected ? theme.accent : theme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    width: 3,
                    child: ColoredBox(color: theme.accent),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: compact
                      ? theme.layout.confirmTierHeight
                      : theme.layout.confirmActionHeight,
                ),
                child: Padding(
                  padding: compact
                      ? const EdgeInsets.fromLTRB(9, 7, 9, 7)
                      : const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier.name,
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: theme.fontFamily,
                              ),
                            ),
                            if (guidance != null)
                              Text(
                                guidance,
                                style: TextStyle(
                                  // The note is the reason the row exists once
                                  // it is chosen, so it takes the full ink.
                                  color: selected
                                      ? theme.text
                                      : theme.mutedText,
                                  fontSize: 10.5,
                                  height: 1.3,
                                  fontFamily: theme.fontFamily,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        price,
                        softWrap: false,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: theme.fontFamily,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
