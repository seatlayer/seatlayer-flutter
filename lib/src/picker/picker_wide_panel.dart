/// Pieces of the wide layout's side panel: its headings and its foot.
///
/// The adaptive layout composes them; they live here so that file stays
/// within the package's readability cap. Not exported: a host composing its
/// own wide layout draws its own headings.

library;

import 'package:flutter/material.dart';

import 'picker_a11y.dart';
import 'picker_motion.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_theme.dart';

/// A heading in the wide panel — "Ticket prices", "Your seats".
///
/// Drawn as given: upper-casing in code is not a language's own capitals
/// (Turkish `i` would become `I`, not `İ`). Marked as a heading, so a screen
/// reader can step from the prices to the buyer's seats.
class SeatLayerWidePanelHeading extends StatelessWidget {
  /// Creates a panel heading reading [text].
  const SeatLayerWidePanelHeading(this.text, {super.key})
      : padTop = SeatLayerSizeTokens.widePanelHeadingPadTop;

  /// The heading over the buyer's seats, which stands a little further from
  /// the prices above it than the first heading does from the header.
  const SeatLayerWidePanelHeading.seats(this.text, {super.key})
      : padTop = SeatLayerSizeTokens.widePanelSeatsHeadingPadTop;

  /// The words, as the strings object gives them.
  final String text;

  /// The air above the heading.
  final double padTop;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        SeatLayerSizeTokens.widePanelPadX,
        padTop,
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

/// The panel while the first snapshot is on its way.
///
/// It keeps the shape it is about to have — the prices heading, three grey
/// bars where the prices will be, and a bar and a button-sized block at the
/// foot — so nothing in the panel jumps when the prices land. The bars
/// breathe with the venue silhouette on the map beside them, and stand still
/// for a viewer who asked for less movement. They say nothing to a screen
/// reader: the map's loading surface already announces the load.
class SeatLayerWidePanelLoading extends StatefulWidget {
  /// Creates the placeholder panel under the [ticketPrices] heading.
  const SeatLayerWidePanelLoading({super.key, required this.ticketPrices});

  /// The heading drawn above the bars, as the strings object gives it.
  final String ticketPrices;

  /// Each price bar's share of the panel's inner width, top to bottom.
  static const List<double> priceBarFractions = <double>[.70, .55, .62];

  /// The foot's summary bar, as a share of the panel's inner width.
  static const double footBarFraction = .40;

  @override
  State<SeatLayerWidePanelLoading> createState() =>
      _SeatLayerWidePanelLoadingState();
}

class _SeatLayerWidePanelLoadingState extends State<SeatLayerWidePanelLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: SeatLayerMotionTokens.loadingBreath),
    value: 1,
  );

  // The silhouette's own curve and depth, so the two breathe as one.
  late final Animation<double> _opacity = _breath
      .drive(CurveTween(curve: Curves.easeInOut))
      .drive(Tween<double>(begin: .55, end: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (SeatLayerPickerMotion.reduced(context)) {
      _breath.stop();
      _breath.value = 1;
      return;
    }
    if (!_breath.isAnimating) _breath.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    Widget bar(double fraction) => FractionallySizedBox(
          widthFactor: fraction,
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            height: SeatLayerSizeTokens.widePanelPlaceholderBarHeight,
            decoration: BoxDecoration(
              color: theme.divider,
              borderRadius: BorderRadius.circular(
                SeatLayerSizeTokens.widePanelPlaceholderBarHeight / 2,
              ),
            ),
          ),
        );
    const gap =
        SizedBox(height: SeatLayerSizeTokens.widePanelPlaceholderBarGap);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SeatLayerWidePanelHeading(widget.ticketPrices),
        ExcludeSemantics(
          child: FadeTransition(
            opacity: _opacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SeatLayerSizeTokens.widePanelPadX,
                vertical: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final (index, fraction) in SeatLayerWidePanelLoading
                      .priceBarFractions.indexed) ...[
                    if (index > 0) gap,
                    bar(fraction),
                  ],
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        ExcludeSemantics(
          child: FadeTransition(
            opacity: _opacity,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SeatLayerSizeTokens.widePanelPadX,
                  8,
                  SeatLayerSizeTokens.widePanelPadX,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    bar(SeatLayerWidePanelLoading.footBarFraction),
                    gap,
                    Container(
                      height:
                          SeatLayerSizeTokens.widePanelPlaceholderButtonHeight,
                      decoration: BoxDecoration(
                        color: theme.divider,
                        borderRadius: BorderRadius.circular(
                          SeatLayerRadiusTokens.peekButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
