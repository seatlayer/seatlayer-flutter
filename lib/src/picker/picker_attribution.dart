/// The SeatLayer credit line every embed carries, and the mark beside it.
///
/// Whether it renders at all is the organizer's entitlement, reported in the
/// snapshot's branding — it is never a host switch.

library;

import 'package:flutter/material.dart';

import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

class SeatLayerPickerAttribution extends StatelessWidget {
  const SeatLayerPickerAttribution({
    super.key,
    this.compact = true,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (state.branding?.attributionRequired != true) {
      return const SizedBox.shrink();
    }
    // The credit sits on the sheet, which takes the map chrome's palette — in
    // the immersive scene that is the dark side whatever the picker is set to.
    // Read from the picker's own palette, the words were dark ink on a dark
    // sheet, and only the mark survived.
    final theme = seatLayerMapChromeThemeOf(context);
    return Semantics(
      label: 'Powered by SeatLayer',
      child: Opacity(
        opacity: .72,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 2 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _SeatLayerPoweredMark(),
              const SizedBox(width: 5),
              Text(
                'Powered by SeatLayer',
                style: TextStyle(
                  color: theme.text,
                  fontSize: compact ? 11 : 12,
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
                  fontFamily: theme.fontFamily,
                  // `.02em` of the line's own size, as the web sets it.
                  letterSpacing: compact ? .22 : .24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The SeatLayer mark: three stacked rows of seats, one plate.
///
/// Sixteen points square on every surface — the credit reads as one thing
/// wherever it is drawn, and a mark that shrinks with its line reads as a
/// smudge rather than as a logo.
class _SeatLayerPoweredMark extends StatelessWidget {
  const _SeatLayerPoweredMark();

  /// Edge length of the plate.
  static const double size = 16;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1220),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox.square(
          dimension: size,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _SeatLayerMarkRow(width: 10),
                _SeatLayerMarkRow(width: 7),
                _SeatLayerMarkRow(width: 4),
              ],
            ),
          ),
        ),
      );
}

class _SeatLayerMarkRow extends StatelessWidget {
  const _SeatLayerMarkRow({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFCF7EE),
            borderRadius: BorderRadius.circular(2),
          ),
          child: SizedBox(width: width, height: 2),
        ),
      );
}
