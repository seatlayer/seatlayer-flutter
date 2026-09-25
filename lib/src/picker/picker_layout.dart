import 'package:flutter/foundation.dart';

import 'picker_tokens.g.dart';

/// The measured sizes the phone picker is built from.
///
/// Every number the phone layout depends on lives here rather than inside a
/// widget, so an integrator can retune the chrome without forking it. The
/// defaults are the approved phone specification and are what the
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
    this.checkoutButtonHeight = SeatLayerSizeTokens.checkoutButtonHeight,
    this.sheetHandleWidth = SeatLayerSizeTokens.sheetHandleWidth,
    this.sheetHandleHeight = SeatLayerSizeTokens.sheetHandleHeight,
    this.sheetHandleOverhang = SeatLayerSizeTokens.sheetHandleOverhang,
    this.sheetHeadHeight = SeatLayerSizeTokens.sheetHeadHeight,
    this.cartCardMinHeight = SeatLayerSizeTokens.cartCardMinHeight,
    this.cartCardGap = SeatLayerSizeTokens.cartCardGap,
    this.cartPeekMaxHeight = SeatLayerSizeTokens.cartPeekMaxHeight,
    this.bestSeatsSelectHeight = SeatLayerSizeTokens.bestSeatsSelectHeight,
    this.bestSeatsStepperWidth = SeatLayerSizeTokens.bestSeatsStepperWidth,
    this.sheetMaxHeightFraction = SeatLayerSizeTokens.sheetMaxHeightFraction,
    this.emptyTrayMaxHeight = SeatLayerSizeTokens.emptyTrayMaxHeight,
    this.sheetFullHeightFraction = SeatLayerSizeTokens.sheetFullHeightFraction,
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

  /// Width of the handle pill that straddles the sheet's top edge.
  final double sheetHandleWidth;

  /// Height of that pill; half of it sits above the sheet.
  final double sheetHandleHeight;

  /// How much of the pill stands above the sheet's own top edge.
  final double sheetHandleOverhang;

  /// Height of the sheet's head — the lower half of the handle, and nothing else drawn under it.
  final double sheetHeadHeight;

  /// Least height of one cart card, which is what its two full-size targets need.
  final double cartCardMinHeight;

  /// Gap between two cart cards.
  final double cartCardGap;

  /// Ceiling on the cart list while the sheet is collapsed: three whole cards and a sliver of the fourth.
  final double cartPeekMaxHeight;

  /// Horizontal inset between the confirm card and the screen edge.
  final double confirmCardGutter;

  /// Ceiling for the confirm card's width.
  final double confirmCardMaxWidth;

  /// Where the confirm card rests: the gap between its bottom edge and the
  /// foot of the map. The phone card has no other home.
  final double confirmCardRestInset;

  /// The daylight between the card's top edge and the band the map is framed
  /// into above it, so a seat is never pressed against the card asking about
  /// it.
  final double confirmCardSeatGap;

  /// The closest the card may come to the top of the map.
  final double confirmCardTopInset;

  /// Retained for source compatibility; nothing reads it.
  ///
  /// It measured the band of low seats that sent the card to a raised home.
  /// The card no longer moves to the seat — it is a fixed sheet, and the map
  /// is framed above it instead — so there is no covered band to size.
  final double confirmCardClearance;

  /// Smallest height of the confirm card's identity grid; it grows with a
  /// section name that needs its second line.
  final double confirmIdentityHeight;

  /// Smallest height of the confirm card's category band.
  final double confirmBandHeight;

  /// Height of the confirm card's seat-view photo strip.
  final double confirmPhotoHeight;

  /// Height of the strip's stand-in rail when there is no photo to show.
  ///
  /// The phone card no longer draws that rail — with no photograph the strip
  /// leaves the card and the 3D action moves into the decision row — so this
  /// knob is inert on the SDK's own card. It is kept because it is public
  /// API and a host composing its own card may still want the measure.
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
    double? checkoutButtonHeight,
    double? bestSeatsSelectHeight,
    double? bestSeatsStepperWidth,
    double? sheetMaxHeightFraction,
    double? emptyTrayMaxHeight,
    double? sheetFullHeightFraction,
    double? sheetHandleWidth,
    double? sheetHandleHeight,
    double? sheetHandleOverhang,
    double? sheetHeadHeight,
    double? cartCardMinHeight,
    double? cartCardGap,
    double? cartPeekMaxHeight,
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
        sheetHandleWidth: sheetHandleWidth ?? this.sheetHandleWidth,
        sheetHandleHeight: sheetHandleHeight ?? this.sheetHandleHeight,
        sheetHandleOverhang: sheetHandleOverhang ?? this.sheetHandleOverhang,
        sheetHeadHeight: sheetHeadHeight ?? this.sheetHeadHeight,
        cartCardMinHeight: cartCardMinHeight ?? this.cartCardMinHeight,
        cartCardGap: cartCardGap ?? this.cartCardGap,
        cartPeekMaxHeight: cartPeekMaxHeight ?? this.cartPeekMaxHeight,
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
      other.checkoutButtonHeight == checkoutButtonHeight &&
      other.bestSeatsSelectHeight == bestSeatsSelectHeight &&
      other.bestSeatsStepperWidth == bestSeatsStepperWidth &&
      other.sheetMaxHeightFraction == sheetMaxHeightFraction &&
      other.emptyTrayMaxHeight == emptyTrayMaxHeight &&
      other.sheetFullHeightFraction == sheetFullHeightFraction &&
      other.sheetHandleWidth == sheetHandleWidth &&
      other.sheetHandleHeight == sheetHandleHeight &&
      other.sheetHandleOverhang == sheetHandleOverhang &&
      other.sheetHeadHeight == sheetHeadHeight &&
      other.cartCardMinHeight == cartCardMinHeight &&
      other.cartCardGap == cartCardGap &&
      other.cartPeekMaxHeight == cartPeekMaxHeight &&
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
        checkoutButtonHeight,
        bestSeatsSelectHeight,
        bestSeatsStepperWidth,
        sheetMaxHeightFraction,
        emptyTrayMaxHeight,
        sheetFullHeightFraction,
        sheetHandleWidth,
        sheetHandleHeight,
        sheetHandleOverhang,
        sheetHeadHeight,
        cartCardMinHeight,
        cartCardGap,
        cartPeekMaxHeight,
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
