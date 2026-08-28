import 'package:flutter/material.dart';

/// How one painted surface of the picker chrome is drawn.
///
/// A surface is a card, a bar, a sheet or a chip: something with a ground, an
/// outline and a shape. Every field is optional and every omitted field keeps
/// the value the spec gives that surface, so a host can restyle one corner
/// radius without restating a palette.
@immutable
class SeatLayerSurfaceStyle {
  /// Creates a partial surface style.
  const SeatLayerSurfaceStyle({
    this.color,
    this.shape,
    this.elevation,
    this.padding,
    this.textStyle,
  });

  /// Ground the surface paints.
  final Color? color;

  /// Outline and corner shape.
  final ShapeBorder? shape;

  /// Material elevation.
  final double? elevation;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Type for the surface's own label, where it has one.
  final TextStyle? textStyle;

  /// This style with [other]'s set fields on top.
  SeatLayerSurfaceStyle merge(SeatLayerSurfaceStyle? other) => other == null
      ? this
      : SeatLayerSurfaceStyle(
          color: other.color ?? color,
          shape: other.shape ?? shape,
          elevation: other.elevation ?? elevation,
          padding: other.padding ?? padding,
          textStyle: textStyle == null
              ? other.textStyle
              : textStyle!.merge(other.textStyle),
        );

  @override
  bool operator ==(Object other) =>
      other is SeatLayerSurfaceStyle &&
      other.color == color &&
      other.shape == shape &&
      other.elevation == elevation &&
      other.padding == padding &&
      other.textStyle == textStyle;

  @override
  int get hashCode => Object.hash(color, shape, elevation, padding, textStyle);
}

/// The shape every action in the picker carries.
///
/// Material 3 rounds buttons to a stadium. The picker's actions are not pills:
/// they round to `radius.button`, which is what the web picker's own buttons
/// measure. A button that draws no shape of its own asks for this one, and any
/// `style:` a host passes still wins over it.
ButtonStyle seatLayerButtonShape(double radius) => ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );

/// Read one resolvable role out of a [ButtonStyle].
///
/// The confirm card's two halves are one seam-free 1:1 split rather than two
/// Material buttons, so they cannot simply be handed a [ButtonStyle]. They read
/// the roles that do apply — ground, ink, shape and type — out of the slot
/// instead, which keeps one API for restyling every action in the picker.
T? seatLayerStyleRole<T>(
  WidgetStateProperty<T?>? property, {
  bool disabled = false,
}) =>
    property?.resolve(
      disabled ? <WidgetState>{WidgetState.disabled} : const <WidgetState>{},
    );

/// Per-element style slots for the native picker chrome.
///
/// These exist so one element can be restyled without replacing the widget
/// that draws it. Turning the peek bar's `Continue` into a square filled
/// button is three lines:
///
/// ```dart
/// SeatLayerPickerThemeData.light(
///   styles: SeatLayerPickerStyles(
///     continueButtonStyle: FilledButton.styleFrom(
///       shape: const RoundedRectangleBorder(),
///     ),
///   ),
/// )
/// ```
///
/// Every widget that owns a slot also takes a `style:` parameter, which wins
/// over the theme for that one instance.
@immutable
class SeatLayerPickerStyles {
  /// Creates a partial set of slots; omitted slots keep the spec's own look.
  const SeatLayerPickerStyles({
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.continueButtonStyle,
    this.iconButtonStyle,
    this.chipShape,
    this.legendChipStyle,
    this.dockBarStyle,
    this.confirmCardStyle,
    this.sheetStyle,
    this.headerStyle,
    this.pillStyle,
  });

  /// Filled actions: `Select`, `Hold seats & checkout`, `Find N best seats`.
  final ButtonStyle? primaryButtonStyle;

  /// Quiet actions beside a primary one: `Cancel`.
  final ButtonStyle? secondaryButtonStyle;

  /// The peek bar's `Continue · total`, which is its own decision.
  ///
  /// Falls back to [primaryButtonStyle] when unset.
  final ButtonStyle? continueButtonStyle;

  /// Round map controls, the sheet chevron and the row's remove control.
  final ButtonStyle? iconButtonStyle;

  /// Shape shared by the price chips and the pills, when set.
  final OutlinedBorder? chipShape;

  /// The price legend's chips.
  final SeatLayerSurfaceStyle? legendChipStyle;

  /// The focused-section dock bar.
  final SeatLayerSurfaceStyle? dockBarStyle;

  /// The anchored seat confirmation card.
  final SeatLayerSurfaceStyle? confirmCardStyle;

  /// The cart sheet, peek and expanded.
  final SeatLayerSurfaceStyle? sheetStyle;

  /// The event header.
  final SeatLayerSurfaceStyle? headerStyle;

  /// The hold countdown pill and the confirm card's photo/3D pills.
  final SeatLayerSurfaceStyle? pillStyle;

  /// This set with [other]'s set slots on top.
  SeatLayerPickerStyles merge(SeatLayerPickerStyles? other) => other == null
      ? this
      : SeatLayerPickerStyles(
          primaryButtonStyle:
              primaryButtonStyle?.merge(other.primaryButtonStyle) ??
                  other.primaryButtonStyle,
          secondaryButtonStyle:
              secondaryButtonStyle?.merge(other.secondaryButtonStyle) ??
                  other.secondaryButtonStyle,
          continueButtonStyle:
              continueButtonStyle?.merge(other.continueButtonStyle) ??
                  other.continueButtonStyle,
          iconButtonStyle: iconButtonStyle?.merge(other.iconButtonStyle) ??
              other.iconButtonStyle,
          chipShape: other.chipShape ?? chipShape,
          legendChipStyle: legendChipStyle == null
              ? other.legendChipStyle
              : legendChipStyle!.merge(other.legendChipStyle),
          dockBarStyle: dockBarStyle == null
              ? other.dockBarStyle
              : dockBarStyle!.merge(other.dockBarStyle),
          confirmCardStyle: confirmCardStyle == null
              ? other.confirmCardStyle
              : confirmCardStyle!.merge(other.confirmCardStyle),
          sheetStyle: sheetStyle == null
              ? other.sheetStyle
              : sheetStyle!.merge(other.sheetStyle),
          headerStyle: headerStyle == null
              ? other.headerStyle
              : headerStyle!.merge(other.headerStyle),
          pillStyle: pillStyle == null
              ? other.pillStyle
              : pillStyle!.merge(other.pillStyle),
        );

  /// The style the peek bar's `Continue` actually uses.
  ButtonStyle? get resolvedContinueButtonStyle =>
      primaryButtonStyle?.merge(continueButtonStyle) ?? continueButtonStyle;

  @override
  bool operator ==(Object other) =>
      other is SeatLayerPickerStyles &&
      other.primaryButtonStyle == primaryButtonStyle &&
      other.secondaryButtonStyle == secondaryButtonStyle &&
      other.continueButtonStyle == continueButtonStyle &&
      other.iconButtonStyle == iconButtonStyle &&
      other.chipShape == chipShape &&
      other.legendChipStyle == legendChipStyle &&
      other.dockBarStyle == dockBarStyle &&
      other.confirmCardStyle == confirmCardStyle &&
      other.sheetStyle == sheetStyle &&
      other.headerStyle == headerStyle &&
      other.pillStyle == pillStyle;

  @override
  int get hashCode => Object.hash(
        primaryButtonStyle,
        secondaryButtonStyle,
        continueButtonStyle,
        iconButtonStyle,
        chipShape,
        legendChipStyle,
        dockBarStyle,
        confirmCardStyle,
        sheetStyle,
        headerStyle,
        pillStyle,
      );
}
