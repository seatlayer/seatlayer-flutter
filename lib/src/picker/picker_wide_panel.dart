/// Pieces of the wide layout's side panel: its headings and its foot.
///
/// The adaptive layout composes them; they live here so that file stays
/// within the package's readability cap. Not exported: a host composing its
/// own wide layout draws its own headings.

library;

import 'package:flutter/material.dart';

import 'picker_a11y.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_theme.dart';

/// A heading in the wide panel — "Ticket prices", "Your seats".
///
/// Drawn as given: upper-casing in code is not a language's own capitals
/// (Turkish `i` would become `I`, not `İ`). Marked as a heading, so a screen
/// reader can step from the prices to the buyer's seats.
class SeatLayerWidePanelHeading extends StatelessWidget {
  /// Creates a panel heading reading [text].
  const SeatLayerWidePanelHeading(this.text, {super.key});

  /// The words, as the strings object gives them.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        SeatLayerSizeTokens.widePanelPadX,
        SeatLayerSizeTokens.widePanelHeadingPadTop,
        SeatLayerSizeTokens.widePanelPadX,
        SeatLayerSizeTokens.widePanelHeadingPadBottom,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          container: true,
          header: true,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: SeatLayerSizeTokens.widePanelHeadingFontSize,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
              fontFamily: theme.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}

/// The foot of the wide panel: the checkout bar, then the credit under it.
///
/// The credit closes the panel, below the button rather than above it, so the
/// button sits straight under the buyer's seats. The device's bottom inset is
/// taken once, under the credit: the checkout bar is told there is none, or
/// the inset would open a gap between the button and the line under it.
class SeatLayerWidePanelFoot extends StatelessWidget {
  /// Creates the foot from the layout's [checkout] bar and [attribution].
  const SeatLayerWidePanelFoot({
    super.key,
    required this.checkout,
    required this.attribution,
  });

  /// The checkout bar, or whatever a host's builder drew in its place.
  final Widget checkout;

  /// The credit line; it draws nothing where the organizer may omit it.
  final Widget attribution;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: checkout,
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: attribution,
              ),
            ),
          ),
        ],
      );
}
