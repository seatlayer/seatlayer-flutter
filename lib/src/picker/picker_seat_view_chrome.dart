/// The words over the 2D "View from here" panorama.
library;

import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_map_controls.dart';
import 'picker_motion.dart';
import 'picker_styles.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

/// The caption strip and disclosure badge drawn over the seat-view panorama.
///
/// The panorama itself is the venue map — the picture, its drag and pinch, and
/// its CLOSE button, which stays web-side because it is the buyer's only way
/// back out of a full-screen image and native chrome does not reach into it.
/// Everything that is *words* is drawn here instead: the seat the view is
/// from, the disclosure caption, and the badge separating an authored capture
/// of the real seat from one the engine drew out of the venue's geometry.
///
/// Why natively at all: on a phone the web picker's own header line, caption
/// and `PREVIEW` badge all landed under the native price rail, which is two
/// pieces of chrome drawn by two owners in the same band. The runtime now
/// suppresses its three and reports the strings on `evt seatView.changed`, so
/// the disclosure is drawn once, in the picker's palette, clear of the rail.
///
/// **It renders nothing unless the runtime handed it something to print.** A
/// runtime that does not advertise `native-seat-view-chrome-v1` still draws
/// its own words, and this widget stays an empty box rather than doubling
/// them — so it can be placed unconditionally over the map.
///
/// Reads everything from the controller, so it works standalone inside a
/// [SeatLayerPickerScope].
class SeatLayerSeatViewChrome extends StatelessWidget {
  /// Creates the panorama's caption chrome.
  const SeatLayerSeatViewChrome({
    super.key,
    this.topInset = 10,
    this.bottomInset = 10,
    this.showDragHint = true,
    this.style,
  });

  /// Space to leave at the top, clear of the header and the price rail.
  final double topInset;

  /// Space to leave at the bottom, clear of the dock and the cart sheet.
  final double bottomInset;

  /// Whether to print the runtime's "drag to look around" hint under the strip.
  final bool showDragHint;

  /// Overrides [SeatLayerPickerStyles.seatViewChromeStyle] for the strip.
  final SeatLayerSurfaceStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final view = controller.seatView;
    final open = view != null && view.hasContent;
    // Over a photograph this is chrome on an image of unknown brightness, so
    // it takes the immersive palette exactly as the 3D scene's chrome does:
    // light type on a dark ground reads on a sunlit stand and on a dim one.
    final theme = seatLayerPickerThemeOf(context).immersive;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final surface =
        (theme.styles.seatViewChromeStyle ?? const SeatLayerSurfaceStyle())
            .merge(style);

    return IgnorePointer(
      // Never takes a touch. Every gesture over the panorama belongs to the
      // panorama, and a strip that ate a drag would freeze the picture under
      // the buyer's finger.
      child: AnimatedOpacity(
        duration: SeatLayerPickerMotion.of(
          context,
          SeatLayerPickerMotion.immersive,
        ),
        curve: SeatLayerPickerMotion.easeEnter,
        opacity: open ? 1 : 0,
        child: !open
            ? const SizedBox.expand()
            : Padding(
                padding: EdgeInsets.fromLTRB(12, topInset, 12, bottomInset),
                child: Semantics(
                  container: true,
                  label: view.title ?? strings.viewFromYourSeat,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CaptionStrip(
                        view: view,
                        theme: theme,
                        surface: surface,
                      ),
                      if (showDragHint &&
                          (view.dragHint?.trim().isNotEmpty ??
                              false)) ...<Widget>[
                        const SizedBox(height: 8),
                        _DragHint(text: view.dragHint!.trim(), theme: theme),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Title, badge and disclosure caption on one ground.
class _CaptionStrip extends StatelessWidget {
  const _CaptionStrip({
    required this.view,
    required this.theme,
    required this.surface,
  });

  final SeatLayerSeatView view;
  final SeatLayerResolvedPickerTheme theme;
  final SeatLayerSurfaceStyle surface;

  @override
  Widget build(BuildContext context) {
    final title = view.title?.trim();
    final caption = view.caption?.trim();
    final badge = view.badge?.trim();

    // The same dark glass the 3D scene's chrome wears: this floats over a
    // photograph of unknown brightness, so it is drawn against its own ground
    // rather than against the picker's theme.
    final body = Padding(
      padding: surface.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: SeatLayerDarkTokens.immersiveGlassInk,
                      fontSize: 14,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    ).merge(surface.textStyle),
                  ),
                if (caption != null && caption.isNotEmpty) ...<Widget>[
                  if (title != null && title.isNotEmpty)
                    const SizedBox(height: 3),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pickerAlpha(
                        SeatLayerDarkTokens.immersiveGlassInk,
                        .78,
                      ),
                      fontSize: 12,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null && badge.isNotEmpty) ...<Widget>[
            const SizedBox(width: 10),
            _DisclosureBadge(
              text: badge,
              real: view.real,
              theme: theme,
            ),
          ],
        ],
      ),
    );
    final shaped = surface.color != null || surface.shape != null
        ? Material(
            color: surface.color ?? pickerAlpha(theme.surface, .92),
            elevation: surface.elevation ?? 0,
            shape: surface.shape,
            clipBehavior: Clip.antiAlias,
            child: body,
          )
        : seatLayerImmersiveGlass(radius: theme.radius, child: body);
    return shaped;
  }
}

/// "Real 360°" or "Preview", already in the buyer's language.
///
/// The word is the runtime's; which of the two it is comes off
/// [SeatLayerSeatView.real], never off matching the translated word.
class _DisclosureBadge extends StatelessWidget {
  const _DisclosureBadge({
    required this.text,
    required this.real,
    required this.theme,
  });

  final String text;
  final bool real;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) {
    final ground = real ? theme.accent : pickerAlpha(theme.text, .14);
    final ink = real ? theme.onAccent : theme.text;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ground,
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ink,
            fontSize: 11,
            fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
            letterSpacing: .2,
            fontFamily: theme.fontFamily,
          ),
        ),
      ),
    );
  }
}

/// "Drag to look around · pinch or scroll to zoom".
class _DragHint extends StatelessWidget {
  const _DragHint({required this.text, required this.theme});

  final String text;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) => Center(
        child: seatLayerImmersiveGlass(
          blur: SeatLayerSizeTokens.immersiveCaptionBlur,
          fill: SeatLayerDarkTokens.immersiveCaption,
          border: SeatLayerDarkTokens.immersiveCaptionBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SeatLayerDarkTokens.immersiveCaptionInk,
                fontSize: SeatLayerSizeTokens.immersiveCaptionFontSize,
                fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                letterSpacing:
                    SeatLayerSizeTokens.immersiveCaptionFontSize * 0.03,
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
        ),
      );
}
