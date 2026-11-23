import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'picker/picker_layout.dart';
import 'picker/picker_models.dart';
import 'picker/picker_system_overlay.dart';
import 'picker/seat_layer_picker_theme.dart';

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

/// The frame a SeatLayer page stands in on its route: system Back asks the
/// page first, the scaffold wears the page's own ground, and the status bar is
/// dressed to match it.
@internal
class SeatLayerSurfaceFrame extends StatelessWidget {
  /// Creates the frame around [child].
  const SeatLayerSurfaceFrame({
    super.key,
    required this.theme,
    required this.canPop,
    required this.onBack,
    required this.child,
    this.useScaffold = true,
    this.manageSystemOverlays = true,
  });

  /// The page's resolved palette.
  final SeatLayerResolvedPickerTheme theme;

  /// Whether the route may pop without asking the page.
  final bool canPop;

  /// System Back, while [canPop] is false.
  final VoidCallback onBack;

  /// Whether to wrap the page in a [Scaffold]. Off inside a dialog.
  final bool useScaffold;

  /// Whether to dress the status bar.
  final bool manageSystemOverlays;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The page reserves its top and side insets; the surface owns the bottom
    // one. This lets the dock adapt its gesture clearance instead of
    // inheriting an unavoidable empty strip in full-screen presentations.
    final content = SafeArea(bottom: false, child: child);
    final page = PopScope(
      canPop: canPop,
      // Flutter 3.19 compatibility; newer SDKs prefer onPopInvokedWithResult.
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop) onBack();
      },
      // A bare `Scaffold` paints the HOST application's
      // `scaffoldBackgroundColor`, and the page hands its top inset to a
      // SafeArea rather than to the header — so a dark page inside a
      // light-themed host wore a white band above its own header. The ground
      // is the surface the header docks on, so the strip reads as part of the
      // header.
      child: useScaffold
          ? Scaffold(backgroundColor: theme.surface, body: content)
          : content,
    );
    if (!manageSystemOverlays) return page;
    // The page's own region is sized to the page, and the frame hands the top
    // inset to a SafeArea — so nothing inside it reaches the strip the status
    // bar is drawn over. This region does, which is what makes the clock
    // legible on a full-screen page.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: seatLayerPickerOverlayStyle(theme),
      child: page,
    );
  }
}
