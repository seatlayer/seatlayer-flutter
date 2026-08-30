import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
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

class SeatLayerPickerSeatTierChoice extends StatelessWidget {
  const SeatLayerPickerSeatTierChoice({
    super.key,
    required this.tier,
    required this.currency,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final CategoryTier tier;
  final String currency;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final guidance = tier.buyerMessage ??
        (tier.restriction == 'companion'
            ? 'Requires the adjacent wheelchair place.'
            : null);
    final price = pickerMoney(
      context,
      tier.price,
      tier.currency ?? currency,
    );
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
        color: selected ? pickerAlpha(theme.accent, .10) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius),
          side: BorderSide(
            color: selected ? theme.accent : theme.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.radius),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? theme.accent : theme.mutedText,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.name,
                        style: TextStyle(
                          color: theme.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (guidance != null)
                        Text(
                          guidance,
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: TextStyle(
                    color: theme.text,
                    fontWeight: FontWeight.w900,
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
