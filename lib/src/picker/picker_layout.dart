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
    this.dockBarHeight = SeatLayerSizeTokens.dockBarHeight,
    this.peekHeight = SeatLayerSizeTokens.peekHeight,
    this.sheetMaxHeightFraction = SeatLayerSizeTokens.sheetMaxHeightFraction,
    this.emptyTrayMaxHeight = SeatLayerSizeTokens.emptyTrayMaxHeight,
    this.denseLineHeight = SeatLayerSizeTokens.denseLineHeight,
    this.denseVisibleLines = SeatLayerSizeTokens.denseVisibleLines,
    this.confirmCardGutter = SeatLayerSizeTokens.confirmCardGutter,
    this.confirmCardMaxWidth = SeatLayerSizeTokens.confirmCardMaxWidth,
    this.confirmIdentityHeight = SeatLayerSizeTokens.confirmIdentityHeight,
    this.confirmPhotoHeight = SeatLayerSizeTokens.confirmPhotoHeight,
    this.confirmActionHeight = SeatLayerSizeTokens.confirmActionHeight,
    this.selectorHeight = SeatLayerSizeTokens.selectorHeight,
    this.accessibilityControlSize = SeatLayerSizeTokens.accessibilityControlSize,
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

  /// Height of the rung-2 dock bar, excluding the bottom safe area.
  final double dockBarHeight;

  /// Height of the collapsed cart sheet, excluding the bottom safe area.
  final double peekHeight;

  /// Ceiling for the expanded cart sheet as a fraction of the screen height.
  final double sheetMaxHeightFraction;

  /// Ceiling for the expanded cart sheet body while the cart is empty.
  final double emptyTrayMaxHeight;

  /// Height of one line in the dense ticket list.
  final double denseLineHeight;

  /// How many dense lines render before the list collapses the remainder.
  final int denseVisibleLines;

  /// Horizontal inset between the confirm card and the screen edge.
  final double confirmCardGutter;

  /// Ceiling for the confirm card's width.
  final double confirmCardMaxWidth;

  /// Height of the confirm card's identity row.
  final double confirmIdentityHeight;

  /// Height of the confirm card's seat-view photo strip.
  final double confirmPhotoHeight;

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
    double? dockBarHeight,
    double? peekHeight,
    double? sheetMaxHeightFraction,
    double? emptyTrayMaxHeight,
    double? denseLineHeight,
    int? denseVisibleLines,
    double? confirmCardGutter,
    double? confirmCardMaxWidth,
    double? confirmIdentityHeight,
    double? confirmPhotoHeight,
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
        dockBarHeight: dockBarHeight ?? this.dockBarHeight,
        peekHeight: peekHeight ?? this.peekHeight,
        sheetMaxHeightFraction:
            sheetMaxHeightFraction ?? this.sheetMaxHeightFraction,
        emptyTrayMaxHeight: emptyTrayMaxHeight ?? this.emptyTrayMaxHeight,
        denseLineHeight: denseLineHeight ?? this.denseLineHeight,
        denseVisibleLines: denseVisibleLines ?? this.denseVisibleLines,
        confirmCardGutter: confirmCardGutter ?? this.confirmCardGutter,
        confirmCardMaxWidth: confirmCardMaxWidth ?? this.confirmCardMaxWidth,
        confirmIdentityHeight:
            confirmIdentityHeight ?? this.confirmIdentityHeight,
        confirmPhotoHeight: confirmPhotoHeight ?? this.confirmPhotoHeight,
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
      other.dockBarHeight == dockBarHeight &&
      other.peekHeight == peekHeight &&
      other.sheetMaxHeightFraction == sheetMaxHeightFraction &&
      other.emptyTrayMaxHeight == emptyTrayMaxHeight &&
      other.denseLineHeight == denseLineHeight &&
      other.denseVisibleLines == denseVisibleLines &&
      other.confirmCardGutter == confirmCardGutter &&
      other.confirmCardMaxWidth == confirmCardMaxWidth &&
      other.confirmIdentityHeight == confirmIdentityHeight &&
      other.confirmPhotoHeight == confirmPhotoHeight &&
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
        dockBarHeight,
        peekHeight,
        sheetMaxHeightFraction,
        emptyTrayMaxHeight,
        denseLineHeight,
        denseVisibleLines,
        confirmCardGutter,
        confirmCardMaxWidth,
        confirmIdentityHeight,
        confirmPhotoHeight,
        confirmActionHeight,
        selectorHeight,
        accessibilityControlSize,
        mapControlSize,
        attributionHeight,
        legendChipFontSize,
      ]);
}
