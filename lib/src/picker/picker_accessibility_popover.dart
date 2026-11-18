/// The accessibility options as a popover beside their control, for the wide
/// layout, where a bottom sheet would cover the map the buyer is filtering.
///
/// Not exported. The control decides between this and the phone's bottom
/// sheet from where it stands: inside the wide control column it finds a
/// [SeatLayerAccessPopoverAnchor] above it.

library;

import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';

import 'picker_motion.dart';
import 'picker_tokens.g.dart';

/// Marks the wide control column, whose accessibility control opens a
/// popover beside itself instead of a bottom sheet.
class SeatLayerAccessPopoverAnchor extends InheritedWidget {
  /// Marks [child] as standing in the wide control column.
  const SeatLayerAccessPopoverAnchor({super.key, required super.child});

  /// Whether [context] stands in the wide control column.
  ///
  /// Read when the control is pressed, not while it builds, so it registers
  /// no dependency.
  static bool of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SeatLayerAccessPopoverAnchor>() !=
      null;

  @override
  bool updateShouldNotify(SeatLayerAccessPopoverAnchor oldWidget) => false;
}

/// Opens [child] in a popover beside the control that [context] belongs to.
///
/// The popover stands on the control's start side — away from the column,
/// towards the map — with its top level with the control's top, and is moved
/// up as far as it must to stay on screen. It is modal: a tap outside it, the
/// system back gesture or Escape closes it with nothing, and whatever its
/// content pops with is the result.
///
/// It also closes itself when the window changes size while it is open — a
/// rotation, a split-screen resize. The control it stood beside has moved, or
/// gone with the wide layout itself, and a popover pointing at where a control
/// used to be is worse than one more tap to open it again.
Future<T?> showSeatLayerAccessPopover<T>({
  required BuildContext context,
  required Widget child,
  required double maxHeight,
  required Color surface,
  required Color divider,
  required String label,
  required String barrierLabel,
}) {
  final navigator = Navigator.of(context);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final control = context.findRenderObject()! as RenderBox;
  final anchor =
      control.localToGlobal(Offset.zero, ancestor: overlay) & control.size;
  return navigator.push(
    _AccessPopoverRoute<T>(
      anchor: anchor,
      textDirection: Directionality.of(context),
      maxHeight: maxHeight,
      surface: surface,
      divider: divider,
      label: label,
      barrierLabel: barrierLabel,
      reducedMotion: SeatLayerPickerMotion.reduced(context),
      child: child,
    ),
  );
}

class _AccessPopoverRoute<T> extends PopupRoute<T> {
  _AccessPopoverRoute({
    required this.anchor,
    required this.textDirection,
    required this.maxHeight,
    required this.surface,
    required this.divider,
    required this.label,
    required this.barrierLabel,
    required this.reducedMotion,
    required this.child,
  });

  final Rect anchor;
  final TextDirection textDirection;
  final double maxHeight;
  final Color surface;
  final Color divider;
  final String label;
  final bool reducedMotion;
  final Widget child;

  @override
  final String barrierLabel;

  // No scrim: the map beside the popover stays readable while the switches
  // change it, which is the point of not covering it.
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration =>
      reducedMotion ? Duration.zero : SeatLayerPickerMotion.pop;

  /// The window size the popover was placed for.
  Size? _placedFor;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Registered as a dependency, so a resize rebuilds this page.
    final size = MediaQuery.sizeOf(context);
    _placedFor ??= size;
    if (size != _placedFor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isActive) navigator?.removeRoute(this);
      });
    }
    return CustomSingleChildLayout(
      delegate: SeatLayerAccessPopoverLayout(
        anchor: anchor,
        textDirection: textDirection,
        padding: MediaQuery.paddingOf(context),
        maxHeight: maxHeight,
      ),
      child: Semantics(
        // What Flutter's own Dialog announces itself as.
        role: SemanticsRole.dialog,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: label,
        child: Material(
          color: surface,
          elevation: SeatLayerElevationTokens.sheet,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.sheet),
            side: BorderSide(color: divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: SeatLayerPickerMotion.easeEnter,
          reverseCurve: SeatLayerPickerMotion.easeExit,
        ),
        child: child,
      );
}

/// Where the popover stands, given the control it opened from.
@visibleForTesting
class SeatLayerAccessPopoverLayout extends SingleChildLayoutDelegate {
  /// Lays the popover out beside [anchor], inside the screen less [padding].
  const SeatLayerAccessPopoverLayout({
    required this.anchor,
    required this.textDirection,
    required this.padding,
    required this.maxHeight,
  });

  /// The control's rectangle, in the overlay's coordinates.
  final Rect anchor;

  /// The reading direction: the popover opens towards its start.
  final TextDirection textDirection;

  /// The device's safe-area insets.
  final EdgeInsets padding;

  /// The tallest the popover may be, as the bottom sheet is bounded.
  final double maxHeight;

  static const double _margin = SeatLayerSizeTokens.accessPopoverMargin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final room = padding.deflateSize(constraints.biggest);
    final width = math.max(
      0.0,
      math.min(
        SeatLayerSizeTokens.accessPopoverWidth,
        room.width - 2 * _margin,
      ),
    );
    final height = math.max(
      0.0,
      math.min(maxHeight, room.height - 2 * _margin),
    );
    return BoxConstraints(minWidth: width, maxWidth: width, maxHeight: height);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    const gap = SeatLayerSizeTokens.accessPopoverGap;
    final left = padding.left + _margin;
    final right = math.max(
      left,
      size.width - padding.right - _margin - childSize.width,
    );
    final x = textDirection == TextDirection.rtl
        ? anchor.right + gap
        : anchor.left - gap - childSize.width;
    final top = padding.top + _margin;
    final bottom = math.max(
      top,
      size.height - padding.bottom - _margin - childSize.height,
    );
    // Level with the control's top; where that would run off the foot, level
    // with its bottom instead; and never off the screen either way.
    var y = anchor.top;
    if (y > bottom) y = anchor.bottom - childSize.height;
    return Offset(x.clamp(left, right), y.clamp(top, bottom));
  }

  @override
  bool shouldRelayout(SeatLayerAccessPopoverLayout oldDelegate) =>
      anchor != oldDelegate.anchor ||
      textDirection != oldDelegate.textDirection ||
      padding != oldDelegate.padding ||
      maxHeight != oldDelegate.maxHeight;
}
