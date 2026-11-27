/// Where the pieces over a phone's map stand, from its top line down.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'picker_connection_status.dart';
import 'picker_options.dart';
import 'picker_status_views.dart';
import 'picker_tokens.g.dart';
import 'picker_venue_3d.dart';
import 'picker_map_controls.dart';

/// The arithmetic of the map's top and bottom bands on a phone.
abstract final class PickerPhoneTop {
  /// The gap between two stacked pieces of map chrome, and how far a floating
  /// control stands off the map's edge — one pair for every anchor region.
  static const double gap = SeatLayerSizeTokens.mapAnchorGap;
  static const double inset = SeatLayerSizeTokens.mapAnchorInset;

  /// Where the phone's map chrome starts, below the map's own top edge.
  static const double railTop = 8;

  /// How much of the map the immersive scene's own chrome is given when
  /// nothing else stands in the map's top corners.
  ///
  /// The prices are a row above the map rather than on it; only the Map/3D
  /// control shares the map's top edge, and when it does the scene's chrome
  /// steps below it — see [immersiveTopInset].
  static const double _venue3DRestingInset = inset;

  /// How much of the map's top the phone's chrome is standing on.
  ///
  /// The rail of prices is a row above the map rather than a band on it, so it
  /// is deliberately not counted. What is left standing on the map is the
  /// floor strip and, under it, the test badge — and a test event is not a
  /// rare case, it is what every integration sees first. In the immersive
  /// scene `‹ Back to venue` takes the strip's place, and only while the scene
  /// is aimed at a seat.
  static double topBand({
    required bool panorama,
    required bool testBadge,
    required bool venue3D,
    required bool backPill,
    required double backPillInset,
    required bool viewModeControl,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    if (panorama) return 0;
    // The Map/3D control shares the map's top line with the badge, so the
    // band is whichever of the two reaches lower.
    final control =
        viewModeControl ? railTop + SeatLayerPickerViewModeControl.height : 0.0;
    final above = aboveBadgeBand(
      venue3D: venue3D,
      backPill: backPill,
      backPillInset: backPillInset,
      viewModeControl: viewModeControl,
      floorStrip: floorStrip,
      floorStripHeight: floorStripHeight,
    );
    if (!testBadge) return above > control ? above : control;
    final badge = testBadgeTop(
          venue3D: venue3D,
          backPill: backPill,
          backPillInset: backPillInset,
          viewModeControl: viewModeControl,
          floorStrip: floorStrip,
          floorStripHeight: floorStripHeight,
        ) +
        SeatLayerPickerTestModeIndicator.compactHeight;
    return badge > control ? badge : control;
  }

  /// Where the immersive scene's own chrome starts.
  ///
  /// The scene's rotate control and its way back both sit on the map's top
  /// line; when the Map/3D control is already there they step under it.
  static double immersiveTopInset({required bool viewModeControl}) =>
      viewModeControl
          ? railTop + SeatLayerPickerViewModeControl.height + gap
          : _venue3DRestingInset;

  /// The band the floor strip, or the scene's way back, occupies on its own.
  static double aboveBadgeBand({
    required bool venue3D,
    required bool backPill,
    required double backPillInset,
    required bool viewModeControl,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    if (venue3D) {
      return backPill ? backPillInset + SeatLayerVenue3D.backPillHeight : 0;
    }
    if (floorStrip) {
      return floorStripTop(viewModeControl: viewModeControl) + floorStripHeight;
    }
    return 0;
  }

  /// Where the floor strip starts: the map's top line, or under the Map/3D
  /// control when that is on the same line — the strip runs the map's full
  /// width and the two would otherwise be drawn over each other.
  static double floorStripTop({required bool viewModeControl}) =>
      viewModeControl
          ? railTop + SeatLayerPickerViewModeControl.height + gap
          : railTop;

  /// Where the test-mode badge sits, which is one line under whatever is
  /// above it — or at the map's own top corner when nothing is.
  static double testBadgeTop({
    required bool venue3D,
    required bool backPill,
    required double backPillInset,
    required bool viewModeControl,
    required bool floorStrip,
    required double floorStripHeight,
  }) {
    final above = aboveBadgeBand(
      venue3D: venue3D,
      backPill: backPill,
      backPillInset: backPillInset,
      viewModeControl: viewModeControl,
      floorStrip: floorStrip,
      floorStripHeight: floorStripHeight,
    );
    return above == 0 ? railTop : above + gap;
  }

  /// Where the connection status stands: on the test badge's line at
  /// [top], after the badge, short of the Map / 3D switch when the switch
  /// shares that line. A status too wide for that goes under the badge and
  /// the switch. When the levels run along the top line between the two,
  /// it goes under them.
  static PickerConnectionStatusPlace connectionPlace({
    required double top,
    required double badgeWidth,
    required double controlWidth,
    bool levelsOnLine = false,
    double maxWidth = double.infinity,
  }) {
    final switchBottom = controlWidth > 0
        ? railTop + SeatLayerPickerViewModeControl.height
        : 0.0;
    final belowTop = math.max(
      badgeWidth > 0
          ? top + SeatLayerPickerTestModeIndicator.compactHeight + gap
          : top,
      controlWidth > 0 ? switchBottom + gap : top,
    );
    if (levelsOnLine) {
      return PickerConnectionStatusPlace(
        top: belowTop,
        start: inset,
        end: inset,
        belowTop: belowTop,
        inset: inset,
        maxWidth: maxWidth,
      );
    }
    final sharesSwitch = controlWidth > 0 && top < switchBottom;
    return PickerConnectionStatusPlace(
      top: top,
      start: inset + (badgeWidth > 0 ? badgeWidth + gap : 0),
      end: inset +
          (sharesSwitch
              ? controlWidth + SeatLayerSizeTokens.connectionStatusSwitchGap
              : 0),
      belowTop: belowTop,
      inset: inset,
      maxWidth: maxWidth,
    );
  }

  /// How much of the map's bottom the phone's chrome is standing on.
  ///
  /// The dock on the map — zero unless a host asked for one, since the phone
  /// mounts none — and in the scene the seat deck above it, which is taller
  /// once the buyer is sitting somewhere because it grows a caption. The
  /// header and the cart sheet are rows of the same Column as the map, so the
  /// map surface already ends where they begin and they are correctly not
  /// reported.
  static double bottomBand({
    required SeatLayerPickerChromeOptions chrome,
    required bool seated,
    required double dockLift,
    required bool venue3D,
  }) {
    // `dockLift` is already zero unless a dock is really drawn.
    final dock = dockLift;
    if (!venue3D || !chrome.showVenue3DChrome) return dock;
    final deck =
        inset + dockLift + SeatLayerVenue3D.seatDeckHeight(seated: seated);
    return deck > dock ? deck : dock;
  }

  /// Whether a [pill] of levels fits on the map's top line, between the
  /// [badge] at the start and the [control] at the end, on a map [width]
  /// wide. A width of 0 is a piece that is not there, or not measured yet.
  static bool fitsOneLine({
    required double width,
    required double badge,
    required double control,
    required double pill,
  }) {
    if (pill <= 0) return false;
    final used = inset * 2 +
        (badge > 0 ? badge + gap : 0) +
        (control > 0 ? control + gap : 0);
    return pill <= width - used;
  }
}

/// Reports the width its child is laid out at, after the frame.
class PickerMeasuredWidth extends SingleChildRenderObjectWidget {
  /// Measures [child] and reports its width to [onWidth].
  const PickerMeasuredWidth({
    super.key,
    required this.onWidth,
    required Widget super.child,
  });

  /// Called after layout whenever the measured width changes.
  final ValueChanged<double> onWidth;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasuredWidth(onWidth);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderMeasuredWidth).onWidth = onWidth;
}

class _RenderMeasuredWidth extends RenderProxyBox {
  _RenderMeasuredWidth(this.onWidth);

  ValueChanged<double> onWidth;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final measured = size.width;
    if (_reported != null && (measured - _reported!).abs() < .5) return;
    _reported = measured;
    // After the frame: a listener that rebuilds from inside layout would be
    // changing the tree it is measured in.
    WidgetsBinding.instance.addPostFrameCallback((_) => onWidth(measured));
  }
}
