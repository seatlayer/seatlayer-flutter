import 'package:flutter/foundation.dart';

import 'picker_tokens.g.dart';

/// The measured sizes the phone picker is built from.
///
/// Every number the phone layout depends on lives here rather than inside a
/// widget, so an integrator can retune the chrome without forking it. The
/// defaults are the owner-approved phone specification and are what the
/// zero-configuration [SeatLayerPicker] renders.
@immutable
class SeatLayerPickerLayout {
  /// Creates a layout token set; every field defaults to the phone spec.
  const SeatLayerPickerLayout({
    this.phoneBreakpoint = SeatLayerSizeTokens.phoneBreakpoint,
    this.wideBreakpoint = SeatLayerSizeTokens.wideBreakpoint,
    this.headerHeight = SeatLayerSizeTokens.headerHeight,
    this.headerLogoSize = SeatLayerSizeTokens.headerLogoSize,
    this.topRailHeight = SeatLayerSizeTokens.topRailHeight,
    this.dockBarHeight = SeatLayerSizeTokens.dockBarHeight,
    this.peekHeight = SeatLayerSizeTokens.peekHeight,
    this.sheetOpenHeadHeight = SeatLayerSizeTokens.sheetOpenHeadHeight,
    this.sheetGrabberWidth = SeatLayerSizeTokens.sheetGrabberWidth,
    this.sheetGrabberHeight = SeatLayerSizeTokens.sheetGrabberHeight,
    this.sheetGrabberInset = SeatLayerSizeTokens.sheetGrabberInset,
    this.sheetToggleSize = SeatLayerSizeTokens.sheetToggleSize,
    this.sheetToggleOpenSize = SeatLayerSizeTokens.sheetToggleOpenSize,
    this.sheetMaxHeight = SeatLayerSizeTokens.sheetMaxHeight,
    this.emptyTrayMaxHeightFraction =
        SeatLayerSizeTokens.emptyTrayMaxHeightFraction,
    this.findPillHeight = SeatLayerSizeTokens.findPillHeight,
    this.denseCollapseFrom = SeatLayerSizeTokens.denseCollapseFrom,
    this.denseRemoveSize = SeatLayerSizeTokens.denseRemoveSize,
    this.denseRunToggleWidth = SeatLayerSizeTokens.denseRunToggleWidth,
    this.denseMoreRowHeight = SeatLayerSizeTokens.denseMoreRowHeight,
    this.checkoutButtonHeight = SeatLayerSizeTokens.checkoutButtonHeight,
    this.bestSeatsSelectHeight = SeatLayerSizeTokens.bestSeatsSelectHeight,
    this.bestSeatsStepperWidth = SeatLayerSizeTokens.bestSeatsStepperWidth,
    this.sheetMaxHeightFraction = SeatLayerSizeTokens.sheetMaxHeightFraction,
    this.emptyTrayMaxHeight = SeatLayerSizeTokens.emptyTrayMaxHeight,
    this.sheetFullHeightFraction = SeatLayerSizeTokens.sheetFullHeightFraction,
    this.denseLineHeight = SeatLayerSizeTokens.denseLineHeight,
    this.denseVisibleLines = SeatLayerSizeTokens.denseVisibleLines,
    this.confirmCardGutter = SeatLayerSizeTokens.confirmCardGutter,
    this.confirmCardMaxWidth = SeatLayerSizeTokens.confirmCardMaxWidth,
    this.confirmCardRestInset = SeatLayerSizeTokens.confirmCardRestInset,
    this.confirmCardSeatGap = SeatLayerSizeTokens.confirmCardSeatGap,
    this.confirmCardTopInset = SeatLayerSizeTokens.confirmCardTopInset,
    this.confirmCardClearance = SeatLayerSizeTokens.confirmCardClearance,
    this.confirmIdentityHeight = SeatLayerSizeTokens.confirmIdentityHeight,
    this.confirmBandHeight = SeatLayerSizeTokens.confirmBandHeight,
    this.confirmPhotoHeight = SeatLayerSizeTokens.confirmPhotoHeight,
    this.confirmRailHeight = SeatLayerSizeTokens.confirmRailHeight,
    this.confirmPillHeight = SeatLayerSizeTokens.confirmPillHeight,
    this.confirmTierHeight = SeatLayerSizeTokens.confirmTierHeight,
    this.confirmActionHeight = SeatLayerSizeTokens.confirmActionHeight,
    this.selectorHeight = SeatLayerSizeTokens.selectorHeight,
    this.accessibilityControlSize =
        SeatLayerSizeTokens.accessibilityControlSize,
    this.mapControlSize = SeatLayerSizeTokens.mapControlSize,
    this.attributionHeight = SeatLayerSizeTokens.attributionHeight,
    this.legendChipFontSize = SeatLayerSizeTokens.legendChipFontSize,
  });

  /// Widths below this use the phone composition.
  final double phoneBreakpoint;

  /// Widths at or above this use the two-pane wide composition.
  final double wideBreakpoint;

  /// Height of the phone header, excluding the top safe area.
  final double headerHeight;

  /// Edge length of the square brand tile inside the phone header.
  final double headerLogoSize;

  /// Height of the phone's top rail of prices, between header and map.
  final double topRailHeight;

  /// Height of the rung-2 dock bar, excluding the bottom safe area.
  final double dockBarHeight;

  /// Height of the collapsed cart sheet, excluding the bottom safe area.
  final double peekHeight;

  /// Height of the cart sheet head once the sheet is open.
  final double sheetOpenHeadHeight;

  /// Width of the grabber drawn at the top of the sheet head.
  final double sheetGrabberWidth;

  /// Height of that grabber.
  final double sheetGrabberHeight;

  /// Distance from the top of the head to the grabber.
  final double sheetGrabberInset;

  /// Edge length of the sheet chevron while the sheet is collapsed.
  final double sheetToggleSize;

  /// Edge length of the chevron's ink once the sheet is open.
  final double sheetToggleOpenSize;

  /// Absolute ceiling for the expanded cart sheet.
  final double sheetMaxHeight;

  /// Ceiling for the expanded sheet while the cart is empty, as a fraction of the screen height.
  final double emptyTrayMaxHeightFraction;

  /// Height of the empty peek bar's "Find seats" ink.
  final double findPillHeight;

  /// How many runs the dense list tolerates before it collapses its tail.
  final int denseCollapseFrom;

  /// Edge length of a dense line's remove glyph, inside its larger target.
  final double denseRemoveSize;

  /// Width of a run's fold chevron.
  final double denseRunToggleWidth;

  /// Height of the dense list's "+N more" row.
  final double denseMoreRowHeight;

  /// Height of the sheet footer's call to action.
  final double checkoutButtonHeight;

  /// Height of one best-seats dropdown on a phone.
  final double bestSeatsSelectHeight;

  /// Width of the best-seats quantity stepper.
  final double bestSeatsStepperWidth;

  /// Ceiling for the expanded cart sheet as a fraction of the screen height.
  final double sheetMaxHeightFraction;

  /// Ceiling for the expanded cart sheet body while the cart is empty.
  final double emptyTrayMaxHeight;

  /// Ceiling for the sheet's native-only full detent, as a fraction of the
  /// screen height.
  ///
  /// Only reachable by dragging, and only offered when the cart is taller than
  /// [sheetMaxHeight] allows: it is the buyer asking to see the rest of a long
  /// order, not a resting height the picker ever chooses for them.
  final double sheetFullHeightFraction;

  /// Height of one line in the dense ticket list.
  final double denseLineHeight;

  /// How many dense lines render before the list collapses the remainder.
  final int denseVisibleLines;

  /// Horizontal inset between the confirm card and the screen edge.
  final double confirmCardGutter;

  /// Ceiling for the confirm card's width.
  final double confirmCardMaxWidth;

  /// Where the confirm card rests when it is not hugging a seat: the gap
  /// between its bottom edge and the foot of the map.
  final double confirmCardRestInset;

  /// The daylight the card leaves above the seat it is hugging.
  final double confirmCardSeatGap;

  /// The closest the card may come to the top of the map.
  final double confirmCardTopInset;

  /// Extra room below the resting card before the seat counts as covered.
  ///
  /// A seat this close to the foot of the map would sit under the resting
  /// card, so the card hugs the seat instead of resting.
  final double confirmCardClearance;

  /// Smallest height of the confirm card's identity grid; it grows with a
  /// section name that needs its second line.
  final double confirmIdentityHeight;

  /// Smallest height of the confirm card's category band.
  final double confirmBandHeight;

  /// Height of the confirm card's seat-view photo strip.
  final double confirmPhotoHeight;

  /// Height of the strip's stand-in rail when there is no photo to show.
  final double confirmRailHeight;

  /// Height of one pill riding the photo strip.
  final double confirmPillHeight;

  /// Smallest height of one ticket-type row on the confirm card.
  final double confirmTierHeight;

  /// Height of the confirm card's Cancel / Select row.
  final double confirmActionHeight;

  /// Height of one best-seats dropdown.
  final double selectorHeight;

  /// Edge length of the accessibility map control.
  final double accessibilityControlSize;

  /// Edge length of every other map corner control.
  final double mapControlSize;

  /// Height of the "Powered by SeatLayer" line.
  final double attributionHeight;

  /// Font size of a price legend chip.
  final double legendChipFontSize;

  /// A copy of this layout with the supplied fields replaced.
  SeatLayerPickerLayout copyWith({
    double? phoneBreakpoint,
    double? wideBreakpoint,
    double? headerHeight,
    double? headerLogoSize,
    double? topRailHeight,
    double? dockBarHeight,
    double? peekHeight,
    double? sheetOpenHeadHeight,
    double? sheetGrabberWidth,
    double? sheetGrabberHeight,
    double? sheetGrabberInset,
    double? sheetToggleSize,
    double? sheetToggleOpenSize,
    double? sheetMaxHeight,
    double? emptyTrayMaxHeightFraction,
    double? findPillHeight,
    int? denseCollapseFrom,
    double? denseRemoveSize,
    double? denseRunToggleWidth,
    double? denseMoreRowHeight,
    double? checkoutButtonHeight,
    double? bestSeatsSelectHeight,
    double? bestSeatsStepperWidth,
    double? sheetMaxHeightFraction,
    double? emptyTrayMaxHeight,
    double? sheetFullHeightFraction,
    double? denseLineHeight,
    int? denseVisibleLines,
    double? confirmCardGutter,
    double? confirmCardMaxWidth,
    double? confirmCardRestInset,
    double? confirmCardSeatGap,
    double? confirmCardTopInset,
    double? confirmCardClearance,
    double? confirmIdentityHeight,
    double? confirmBandHeight,
    double? confirmPhotoHeight,
    double? confirmRailHeight,
    double? confirmPillHeight,
    double? confirmTierHeight,
    double? confirmActionHeight,
    double? selectorHeight,
    double? accessibilityControlSize,
    double? mapControlSize,
    double? attributionHeight,
    double? legendChipFontSize,
  }) =>
      SeatLayerPickerLayout(
        phoneBreakpoint: phoneBreakpoint ?? this.phoneBreakpoint,
        wideBreakpoint: wideBreakpoint ?? this.wideBreakpoint,
        headerHeight: headerHeight ?? this.headerHeight,
        headerLogoSize: headerLogoSize ?? this.headerLogoSize,
        topRailHeight: topRailHeight ?? this.topRailHeight,
        dockBarHeight: dockBarHeight ?? this.dockBarHeight,
        peekHeight: peekHeight ?? this.peekHeight,
        sheetOpenHeadHeight: sheetOpenHeadHeight ?? this.sheetOpenHeadHeight,
        sheetGrabberWidth: sheetGrabberWidth ?? this.sheetGrabberWidth,
        sheetGrabberHeight: sheetGrabberHeight ?? this.sheetGrabberHeight,
        sheetGrabberInset: sheetGrabberInset ?? this.sheetGrabberInset,
        sheetToggleSize: sheetToggleSize ?? this.sheetToggleSize,
        sheetToggleOpenSize: sheetToggleOpenSize ?? this.sheetToggleOpenSize,
        sheetMaxHeight: sheetMaxHeight ?? this.sheetMaxHeight,
        emptyTrayMaxHeightFraction:
            emptyTrayMaxHeightFraction ?? this.emptyTrayMaxHeightFraction,
        findPillHeight: findPillHeight ?? this.findPillHeight,
        denseCollapseFrom: denseCollapseFrom ?? this.denseCollapseFrom,
        denseRemoveSize: denseRemoveSize ?? this.denseRemoveSize,
        denseRunToggleWidth: denseRunToggleWidth ?? this.denseRunToggleWidth,
        denseMoreRowHeight: denseMoreRowHeight ?? this.denseMoreRowHeight,
        checkoutButtonHeight: checkoutButtonHeight ?? this.checkoutButtonHeight,
        bestSeatsSelectHeight:
            bestSeatsSelectHeight ?? this.bestSeatsSelectHeight,
        bestSeatsStepperWidth:
            bestSeatsStepperWidth ?? this.bestSeatsStepperWidth,
        sheetMaxHeightFraction:
            sheetMaxHeightFraction ?? this.sheetMaxHeightFraction,
        emptyTrayMaxHeight: emptyTrayMaxHeight ?? this.emptyTrayMaxHeight,
        sheetFullHeightFraction:
            sheetFullHeightFraction ?? this.sheetFullHeightFraction,
        denseLineHeight: denseLineHeight ?? this.denseLineHeight,
        denseVisibleLines: denseVisibleLines ?? this.denseVisibleLines,
        confirmCardGutter: confirmCardGutter ?? this.confirmCardGutter,
        confirmCardMaxWidth: confirmCardMaxWidth ?? this.confirmCardMaxWidth,
        confirmCardRestInset: confirmCardRestInset ?? this.confirmCardRestInset,
        confirmCardSeatGap: confirmCardSeatGap ?? this.confirmCardSeatGap,
        confirmCardTopInset: confirmCardTopInset ?? this.confirmCardTopInset,
        confirmCardClearance: confirmCardClearance ?? this.confirmCardClearance,
        confirmIdentityHeight:
            confirmIdentityHeight ?? this.confirmIdentityHeight,
        confirmBandHeight: confirmBandHeight ?? this.confirmBandHeight,
        confirmPhotoHeight: confirmPhotoHeight ?? this.confirmPhotoHeight,
        confirmRailHeight: confirmRailHeight ?? this.confirmRailHeight,
        confirmPillHeight: confirmPillHeight ?? this.confirmPillHeight,
        confirmTierHeight: confirmTierHeight ?? this.confirmTierHeight,
        confirmActionHeight: confirmActionHeight ?? this.confirmActionHeight,
        selectorHeight: selectorHeight ?? this.selectorHeight,
        accessibilityControlSize:
            accessibilityControlSize ?? this.accessibilityControlSize,
        mapControlSize: mapControlSize ?? this.mapControlSize,
        attributionHeight: attributionHeight ?? this.attributionHeight,
        legendChipFontSize: legendChipFontSize ?? this.legendChipFontSize,
      );

  @override
  bool operator ==(Object other) =>
      other is SeatLayerPickerLayout &&
      other.phoneBreakpoint == phoneBreakpoint &&
      other.wideBreakpoint == wideBreakpoint &&
      other.headerHeight == headerHeight &&
      other.headerLogoSize == headerLogoSize &&
      other.topRailHeight == topRailHeight &&
      other.dockBarHeight == dockBarHeight &&
      other.peekHeight == peekHeight &&
      other.sheetOpenHeadHeight == sheetOpenHeadHeight &&
      other.sheetGrabberWidth == sheetGrabberWidth &&
      other.sheetGrabberHeight == sheetGrabberHeight &&
      other.sheetGrabberInset == sheetGrabberInset &&
      other.sheetToggleSize == sheetToggleSize &&
      other.sheetToggleOpenSize == sheetToggleOpenSize &&
      other.sheetMaxHeight == sheetMaxHeight &&
      other.emptyTrayMaxHeightFraction == emptyTrayMaxHeightFraction &&
      other.findPillHeight == findPillHeight &&
      other.denseCollapseFrom == denseCollapseFrom &&
      other.denseRemoveSize == denseRemoveSize &&
      other.denseRunToggleWidth == denseRunToggleWidth &&
      other.denseMoreRowHeight == denseMoreRowHeight &&
      other.checkoutButtonHeight == checkoutButtonHeight &&
      other.bestSeatsSelectHeight == bestSeatsSelectHeight &&
      other.bestSeatsStepperWidth == bestSeatsStepperWidth &&
      other.sheetMaxHeightFraction == sheetMaxHeightFraction &&
      other.emptyTrayMaxHeight == emptyTrayMaxHeight &&
      other.sheetFullHeightFraction == sheetFullHeightFraction &&
      other.denseLineHeight == denseLineHeight &&
      other.denseVisibleLines == denseVisibleLines &&
      other.confirmCardGutter == confirmCardGutter &&
      other.confirmCardMaxWidth == confirmCardMaxWidth &&
      other.confirmCardRestInset == confirmCardRestInset &&
      other.confirmCardSeatGap == confirmCardSeatGap &&
      other.confirmCardTopInset == confirmCardTopInset &&
      other.confirmCardClearance == confirmCardClearance &&
      other.confirmIdentityHeight == confirmIdentityHeight &&
      other.confirmBandHeight == confirmBandHeight &&
      other.confirmPhotoHeight == confirmPhotoHeight &&
      other.confirmRailHeight == confirmRailHeight &&
      other.confirmPillHeight == confirmPillHeight &&
      other.confirmTierHeight == confirmTierHeight &&
      other.confirmActionHeight == confirmActionHeight &&
      other.selectorHeight == selectorHeight &&
      other.accessibilityControlSize == accessibilityControlSize &&
      other.mapControlSize == mapControlSize &&
      other.attributionHeight == attributionHeight &&
      other.legendChipFontSize == legendChipFontSize;

  @override
  int get hashCode => Object.hashAll(<Object>[
        phoneBreakpoint,
        wideBreakpoint,
        headerHeight,
        headerLogoSize,
        topRailHeight,
        dockBarHeight,
        peekHeight,
        sheetOpenHeadHeight,
        sheetGrabberWidth,
        sheetGrabberHeight,
        sheetGrabberInset,
        sheetToggleSize,
        sheetToggleOpenSize,
        sheetMaxHeight,
        emptyTrayMaxHeightFraction,
        findPillHeight,
        denseCollapseFrom,
        denseRemoveSize,
        denseRunToggleWidth,
        denseMoreRowHeight,
        checkoutButtonHeight,
        bestSeatsSelectHeight,
        bestSeatsStepperWidth,
        sheetMaxHeightFraction,
        emptyTrayMaxHeight,
        sheetFullHeightFraction,
        denseLineHeight,
        denseVisibleLines,
        confirmCardGutter,
        confirmCardMaxWidth,
        confirmCardRestInset,
        confirmCardSeatGap,
        confirmCardTopInset,
        confirmCardClearance,
        confirmIdentityHeight,
        confirmBandHeight,
        confirmPhotoHeight,
        confirmRailHeight,
        confirmPillHeight,
        confirmTierHeight,
        confirmActionHeight,
        selectorHeight,
        accessibilityControlSize,
        mapControlSize,
        attributionHeight,
        legendChipFontSize,
      ]);
}
