/// Everything the picker shows when there is nothing to choose from yet: the
/// loading, failure and empty states, the test-event badge, the floor selector
/// and the wide layout's checkout bar.
library;

import 'package:flutter/material.dart';

import '../seat_layer_error.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_options.dart';
import 'picker_strings.dart';
import 'picker_cart_sheet.dart';
import 'picker_checkout_cta.dart';
import 'seat_layer_picker_scope.dart';
import 'picker_tokens.g.dart';
import 'picker_styles.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPickerTestModeIndicator extends StatelessWidget {
  /// Creates the test-event badge.
  const SeatLayerPickerTestModeIndicator({super.key, this.compact = false});

  /// Whether to render the phone's short badge.
  final bool compact;

  /// How tall the phone's badge is.
  ///
  /// Published because the badge is drawn ON the map, so the layout has to
  /// include it in the band it reports to the runtime.
  static const double compactHeight = 20;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (!state.isTestEvent) return const SizedBox.shrink();
    final strings = SeatLayerPickerScope.stringsOf(context);
    // The badge is drawn ON the map, so it follows the map's palette — which
    // the immersive scene keeps dark whatever side the picker is on. A solid
    // amber lozenge over a dark venue reads as a highlighter stripe left on
    // the screen; on the dark side it becomes a dark pill with amber ink and
    // an amber hairline, which reads as the same badge in the same voice.
    final theme = seatLayerMapChromeThemeOf(context);
    final dark = theme.brightness == Brightness.dark;
    // Sentence case with a status dot, the way the web picker says it. Shouted
    // capitals read as a warning about the buyer's own booking; this is a
    // statement about the event, and a status light is how an interface says
    // one.
    final ink = dark ? theme.warning : const Color(0xFF1A1200);
    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? pickerAlpha(theme.surface, .92) : theme.warning,
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
        border: dark ? Border.all(color: theme.warning) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 8),
        ],
      ),
      child: Padding(
        // The compact badge takes its height from [compactHeight] rather than
        // from padding around a glyph, because the layout reserves exactly
        // that band on the map and a font that measures differently would
        // otherwise push the badge out of it.
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 0 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 5),
            ),
            const SizedBox(width: 5),
            Text(
              compact ? strings.testMode : strings.testModeLong,
              style: TextStyle(
                color: ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: theme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      label: 'Test event. No real inventory will be booked.',
      child: compact ? SizedBox(height: compactHeight, child: pill) : pill,
    );
  }
}

class SeatLayerPickerFloorSelector extends StatelessWidget {
  const SeatLayerPickerFloorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final floors = state.snapshot?.floors ?? const [];
    if (floors.length < 2) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: pickerAlpha(theme.surface, .94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: state.snapshot?.map.floorId,
            hint: const Text('Floor'),
            items: floors
                .map(
                  (floor) => DropdownMenuItem<String>(
                    value: floor.id,
                    child: Text(floor.name),
                  ),
                )
                .toList(),
            onChanged: (floorId) {
              if (floorId != null) {
                ignorePickerAction(controller.setFloor(floorId));
              }
            },
          ),
        ),
      ),
    );
  }
}

/// The dense ticket list, under its dev.4 name.
@Deprecated('Renamed to SeatLayerCartList; the alias goes away at 0.4.')
class SeatLayerPickerCheckoutBar extends StatelessWidget {
  const SeatLayerPickerCheckoutBar({
    super.key,
    required this.onCheckout,
  });

  final SeatLayerCheckoutCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    return Material(
      color: theme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: theme.mutedText, fontSize: 11),
                    ),
                    Text(
                      pickerMoney(
                        context,
                        state.snapshot?.cartTotal ?? 0,
                        state.snapshot?.currency ?? 'USD',
                      ),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SeatLayerCheckoutCta(
                label: (context) =>
                    SeatLayerPickerScope.stringsOf(context).continueWord,
                onPressed: () => checkoutThroughHost(controller, onCheckout),
                builder: (context, cta, onPressed) => FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: theme.onAccent,
                    minimumSize: const Size(156, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(theme.buttonRadius),
                    ),
                  ),
                  onPressed: onPressed,
                  child: SeatLayerCheckoutCtaLabel(
                    cta: cta,
                    color: theme.onAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the picker shows while the seat map is still coming up.
///
/// Placed inside a [SeatLayerPickerScope] it reads the picker's own palette
/// and strings. A host also has to render the failures that happen BEFORE a
/// scope exists — minting a buyer token, loading its own catalogue — so
/// [SeatLayerPickerLoadingView.standalone] takes the same two values directly
/// and needs no scope at all.
class SeatLayerPickerLoadingView extends StatelessWidget {
  /// Creates the loading view, reading the scope above it.
  const SeatLayerPickerLoadingView({super.key})
      : theme = null,
        strings = null;

  /// Creates the loading view outside any scope.
  ///
  /// Use it for the wait before the picker is mounted, so the buyer sees one
  /// interface rather than the host's spinner and then SeatLayer's.
  const SeatLayerPickerLoadingView.standalone({
    super.key,
    required SeatLayerResolvedPickerTheme this.theme,
    this.strings = const SeatLayerPickerStrings(),
  });

  /// The palette to paint with, or null to read it from the scope.
  final SeatLayerResolvedPickerTheme? theme;

  /// The words to use, or null to read them from the scope.
  final SeatLayerPickerStrings? strings;

  @override
  Widget build(BuildContext context) {
    final palette = theme ?? seatLayerPickerThemeOf(context);
    final words = strings ?? SeatLayerPickerScope.stringsOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _VenueSilhouette(accent: palette.accent),
          const SizedBox(height: 16),
          Text(
            words.loading,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.text,
              fontFamily: palette.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// The space the silhouette is drawn in, and the aspect it keeps.
const Size _silhouetteBox = Size(200, 140);

/// One breath of the loading silhouette, in and out.
const Duration _silhouetteBreath = Duration(milliseconds: 1600);

/// A venue in outline, breathing, while the real one is on its way.
///
/// The same shape the web picker draws while it loads: three seating shells
/// around a stage. A spinner says only that something is happening; this says
/// what is about to arrive, so the map does not read as a second load when it
/// replaces it.
class _VenueSilhouette extends StatefulWidget {
  const _VenueSilhouette({required this.accent});

  /// The picker's accent, spent faintly — this is a placeholder, not a
  /// picture, and it must not compete with the map that lands on top of it.
  final Color accent;

  @override
  State<_VenueSilhouette> createState() => _VenueSilhouetteState();
}

class _VenueSilhouetteState extends State<_VenueSilhouette>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: _silhouetteBreath,
    value: 1,
  );

  late final Animation<double> _opacity = _breath
      .drive(CurveTween(curve: Curves.easeInOut))
      .drive(Tween<double>(begin: .55, end: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A viewer who asked for less movement gets the silhouette at full
    // strength and perfectly still, rather than a faster version of it.
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
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: CustomPaint(
          size: _silhouetteBox,
          painter: _VenueSilhouettePainter(accent: widget.accent),
        ),
      );
}

/// Draws the shells and the stage inside [_silhouetteBox], scaled to fit.
class _VenueSilhouettePainter extends CustomPainter {
  const _VenueSilhouettePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final horizontal = size.width / _silhouetteBox.width;
    final vertical = size.height / _silhouetteBox.height;
    // Fit, never fill: the shells keep their proportions in whatever box a
    // host's own loading slot gives them.
    final scale = horizontal < vertical ? horizontal : vertical;
    if (scale <= 0) return;
    canvas.save();
    canvas.translate(
      (size.width - _silhouetteBox.width * scale) / 2,
      (size.height - _silhouetteBox.height * scale) / 2,
    );
    canvas.scale(scale);

    final fill = Paint()..color = pickerAlpha(accent, .14);
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = pickerAlpha(accent, .28);

    final shells = <Path>[
      _shell(left: 20, right: 180, top: 92, ry: 52, depth: 14, deepRy: 62),
      _shell(left: 32, right: 168, top: 74, ry: 42, depth: 12, deepRy: 50),
      _shell(left: 46, right: 154, top: 58, ry: 32, depth: 10, deepRy: 38),
    ];
    for (final shell in shells) {
      canvas
        ..drawPath(shell, fill)
        ..drawPath(shell, hairline);
    }

    final stage = RRect.fromRectAndRadius(
      const Rect.fromLTWH(62, 16, 76, 16),
      const Radius.circular(4),
    );
    canvas
      ..drawRRect(stage, fill)
      ..drawRRect(stage, hairline)
      ..restore();
  }

  /// One seating shell: a shallow arc over a deeper one, closed into a band.
  Path _shell({
    required double left,
    required double right,
    required double top,
    required double ry,
    required double depth,
    required double deepRy,
  }) {
    final rx = (right - left) / 2;
    return Path()
      ..moveTo(left, top)
      ..arcToPoint(
        Offset(right, top),
        radius: Radius.elliptical(rx, ry),
      )
      ..lineTo(right, top + depth)
      ..arcToPoint(
        Offset(left, top + depth),
        radius: Radius.elliptical(rx + 14, deepRy),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldRepaint(_VenueSilhouettePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

/// What the picker shows when the seat map could not be loaded.
///
/// [SeatLayerPickerErrorView.standalone] is the same view outside any scope,
/// for the failures a host has to render before the picker is mounted.
class SeatLayerPickerErrorView extends StatelessWidget {
  /// Creates the failure view, reading the scope above it.
  const SeatLayerPickerErrorView({super.key, this.onRetry})
      : theme = null,
        strings = null,
        message = null;

  /// Creates the failure view outside any scope.
  const SeatLayerPickerErrorView.standalone({
    super.key,
    required SeatLayerResolvedPickerTheme this.theme,
    required VoidCallback this.onRetry,
    this.strings = const SeatLayerPickerStrings(),
    this.message,
  });

  /// Replaces the controller's own retry.
  final VoidCallback? onRetry;

  /// The palette to paint with, or null to read it from the scope.
  final SeatLayerResolvedPickerTheme? theme;

  /// The words to use, or null to read them from the scope.
  final SeatLayerPickerStrings? strings;

  /// What went wrong, or null for the generic wording.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final palette = theme ?? seatLayerPickerThemeOf(context);
    final words = strings ?? SeatLayerPickerScope.stringsOf(context);
    final controller =
        theme == null ? SeatLayerPickerScope.controllerOf(context) : null;
    final error = controller?.state.error;
    final text = message ??
        (error is SeatLayerError ? error.message : words.errorMessage);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_off_rounded, size: 40, color: palette.mutedText),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontFamily: palette.fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              style: seatLayerButtonShape(palette.buttonRadius),
              onPressed:
                  onRetry ?? () => ignorePickerAction(controller!.retry()),
              child: Text(words.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class SeatLayerPickerEmptyView extends StatelessWidget {
  const SeatLayerPickerEmptyView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No selectable seats are currently available.'),
        ),
      );
}
