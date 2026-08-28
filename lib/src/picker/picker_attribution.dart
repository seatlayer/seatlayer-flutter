/// The SeatLayer credit line every embed carries, and the mark beside it.
///
/// Whether it renders at all is the organizer's entitlement, reported in the
/// snapshot's branding — it is never a host switch.

library;

import 'package:flutter/material.dart';

import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

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
    final theme = seatLayerPickerThemeOf(context);
    return Semantics(
      label: 'Powered by SeatLayer',
      child: Opacity(
        opacity: compact ? .64 : .72,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 12,
            vertical: compact ? 1 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SeatLayerPoweredMark(compact: compact),
              SizedBox(width: compact ? 4 : 5),
              Text(
                'Powered by SeatLayer',
                style: TextStyle(
                  color: theme.text,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: compact ? .1 : .2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatLayerPoweredMark extends StatelessWidget {
  const _SeatLayerPoweredMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dimension = compact ? 12.0 : 16.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1220),
        borderRadius: BorderRadius.circular(compact ? 3 : 4),
      ),
      child: SizedBox.square(
        dimension: dimension,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 2 : 3,
            vertical: compact ? 2.5 : 3.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SeatLayerMarkRow(width: compact ? 8 : 10),
              _SeatLayerMarkRow(width: compact ? 5.5 : 7),
              _SeatLayerMarkRow(width: compact ? 3 : 4),
            ],
          ),
        ),
      ),
    );
  }
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
