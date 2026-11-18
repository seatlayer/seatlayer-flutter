/// The toast that answers a tap on a piece of the picker's own chrome.
///
/// The test-event chip says what it is in two words; a tap on it says what
/// that means in a sentence. The sentence travels through the picker's one
/// toast queue, so it is announced once, takes itself away after the same
/// dwell as every other toast, keeps clear of the checkout and the cart sheet
/// handle, and arrives without movement when motion is reduced. Only the
/// surface differs: a full-width ink band at the foot of the map, which also
/// goes away when the buyer taps it.
library;

import 'package:flutter/material.dart';

import 'picker_a11y.dart';
import 'picker_internal.dart';
import 'picker_toast.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_theme.dart';

/// A toast explaining a piece of chrome the buyer tapped.
class PickerExplainerToast extends SeatLayerPickerToast {
  /// Creates the explanation [message].
  const PickerExplainerToast(super.message);
}

/// The ink band an explanation is drawn on.
///
/// The map's own text colour is the ground and its background the ink, so the
/// band reads as the inverse of the map in either theme.
class PickerExplainerToastCard extends StatelessWidget {
  /// Creates the band for [toast].
  const PickerExplainerToastCard({super.key, required this.toast, this.theme});

  /// What to say.
  final PickerExplainerToast toast;

  /// The palette to paint with, or null to read the map chrome's.
  final SeatLayerResolvedPickerTheme? theme;

  @override
  Widget build(BuildContext context) {
    final palette = theme ?? seatLayerMapChromeThemeOf(context);
    const radius = BorderRadius.all(
      Radius.circular(SeatLayerRadiusTokens.explainerToast),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.text,
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: pickerAlpha(const Color(0xFF000000), .5),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SeatLayerSizeTokens.explainerToastPaddingX,
        vertical: SeatLayerSizeTokens.explainerToastPaddingY,
      ),
      child: Text(
        toast.message,
        style: TextStyle(
          color: palette.background,
          fontSize: SeatLayerSizeTokens.explainerToastFontSize,
          height: 1.35,
          fontWeight: seatLayerBoldWeight(context, FontWeight.w500),
          fontFamily: palette.fontFamily,
        ),
      ),
    );
  }
}
