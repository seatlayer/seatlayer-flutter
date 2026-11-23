import 'package:flutter/material.dart';

import 'picker/picker_layout.dart';
import 'picker/picker_models.dart';

/// Shows a SeatLayer page on a route of its own, and completes with what the
/// route pops.
///
/// [SeatLayerPickerPresentation.adaptive] opens a dialog on a tablet at least
/// 700 wide, and full screen otherwise: a phone is a phone however it is held.
/// [page] builds the page; it is told whether it stands inside the dialog,
/// where it draws no scaffold of its own.
Future<T?> showSeatLayerSurface<T>(
  BuildContext context, {
  required SeatLayerPickerPresentation presentation,
  required bool useRootNavigator,
  RouteSettings? routeSettings,
  required Widget Function(bool inDialog) page,
}) {
  final resolved = presentation == SeatLayerPickerPresentation.adaptive
      ? (MediaQuery.sizeOf(context).width >= 700 && seatLayerOnTablet(context)
          ? SeatLayerPickerPresentation.dialog
          : SeatLayerPickerPresentation.fullScreen)
      : presentation;

  if (resolved == SeatLayerPickerPresentation.dialog) {
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: false,
      routeSettings: routeSettings,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 820),
          child: page(true),
        ),
      ),
    );
  }

  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    MaterialPageRoute<T>(
      settings: routeSettings,
      fullscreenDialog: true,
      builder: (_) => page(false),
    ),
  );
}
