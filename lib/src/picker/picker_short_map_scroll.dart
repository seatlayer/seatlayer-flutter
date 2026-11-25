/// A panel over the map that scrolls where the map is too short for it.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'picker_tokens.g.dart';

/// Scrolls [child] where it does not fit.
///
/// The cart's handle stands half over the map's foot. Only where the content
/// scrolls is there room under it, so its last button can be scrolled clear of
/// the handle; where it fits, nothing moves.
class PickerShortMapScroll extends StatefulWidget {
  const PickerShortMapScroll({
    super.key,
    required this.child,
    required this.roomUnder,
    this.reverse = false,
  });

  /// What the map may be too short for.
  final Widget child;

  /// What [child] itself leaves under its last button.
  final double roomUnder;

  /// Whether it opens at its foot.
  final bool reverse;

  @override
  State<PickerShortMapScroll> createState() => _PickerShortMapScrollState();
}

class _PickerShortMapScrollState extends State<PickerShortMapScroll> {
  bool _scrolls = false;

  double get _room => math.max(
        0,
        SeatLayerSizeTokens.sheetHandleOverhang + 8 - widget.roomUnder,
      );

  bool _onMetrics(ScrollMetricsNotification notification) {
    final beyond =
        notification.metrics.maxScrollExtent - (_scrolls ? _room : 0);
    final scrolls = beyond > .5;
    if (mounted && scrolls != _scrolls) setState(() => _scrolls = scrolls);
    return true;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        onNotification: _onMetrics,
        child: SingleChildScrollView(
          reverse: widget.reverse,
          child: Padding(
            padding: EdgeInsets.only(bottom: _scrolls ? _room : 0),
            child: widget.child,
          ),
        ),
      );
}
