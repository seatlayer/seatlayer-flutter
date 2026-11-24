/// The SeatLayer credit line, which the picker no longer draws.

library;

import 'package:flutter/widgets.dart';

/// Draws nothing. Kept so an app that mounts it still builds.
@Deprecated('The picker draws no SeatLayer credit. Remove it.')
class SeatLayerPickerAttribution extends StatelessWidget {
  const SeatLayerPickerAttribution({
    super.key,
    this.compact = true,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
