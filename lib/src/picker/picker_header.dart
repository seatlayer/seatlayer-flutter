import 'dart:async';

import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_styles.dart';
import 'picker_models.dart';
import 'seat_layer_picker_scope.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_theme.dart';

/// Whose event this is, how long the seats are held, and the way out.
///
/// The hold pill lives here and nowhere else. A countdown inside the cart sheet
/// is invisible while the sheet is at peek, which is where a buyer spends most
/// of the flow, and two countdowns on one screen is one too many.
class SeatLayerPickerHeader extends StatelessWidget {
  /// Creates the picker header.
  const SeatLayerPickerHeader({
    super.key,
    this.onClose,
    this.showEventDetails = true,
    this.compact = false,
    this.showHoldPill = true,
    this.style,
  });

  /// Called when the buyer dismisses the picker; omit to hide the control.
  final VoidCallback? onClose;

  /// Whether to name the event and its venue.
  final bool showEventDetails;

  /// Whether to render the phone's 38-point line.
  final bool compact;

  /// Whether to show the hold countdown while seats are held.
  final bool showHoldPill;

  /// Overrides [SeatLayerPickerStyles.headerStyle] for this header.
  final SeatLayerSurfaceStyle? style;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    // The header caps the immersive scene, so it takes its palette too.
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final options = SeatLayerPickerScope.optionsOf(context);
    final logoSize = compact ? theme.layout.headerLogoSize : 36.0;

    final headerStyle =
        (theme.styles.headerStyle ?? const SeatLayerSurfaceStyle())
            .merge(style);
    // The phone header is a 38-point line with 6 points of air above and
    // below its tallest piece — a minimum, not a fixed height, so a buyer who
    // has scaled their text up gets a taller header rather than a clipped one.
    final gap = SizedBox(width: compact ? 8 : 12);
    return Material(
      // The header sits on the picker's ground, as the web's does; the rail
      // under it is the first surface.
      color: headerStyle.color ?? theme.background,
      elevation: headerStyle.elevation ?? 0,
      shape: headerStyle.shape,
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: compact ? theme.layout.headerHeight : 0,
          ),
          child: Padding(
            // No trailing pad on a phone: the close button carries its own, so
            // its ring ends ten points from the edge while the target it
            // answers to runs all the way out to the corner.
            padding: compact
                ? const EdgeInsets.only(left: 12)
                : const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Row(
              children: [
                _air(
                  compact,
                  _PickerBrandMark(theme: theme, state: state, size: logoSize),
                ),
                gap,
                Expanded(
                  child: _air(
                    compact,
                    showEventDetails && !options.hideEventDetails
                        ? _EventTitle(compact: compact)
                        : const SizedBox.shrink(),
                  ),
                ),
                // Sales that have ended are a fact about the event, so they
                // are stated beside its name — and never in the accent, which
                // in this header means "your seats".
                if (state.event?.salesClosed == true) ...[
                  _air(compact,
                      SeatLayerPickerSalesClosedPill(compact: compact)),
                  gap,
                ],
                if (showHoldPill && state.hold != null) ...[
                  _air(compact, SeatLayerPickerHoldCountdown(compact: compact)),
                  gap,
                ],
                if (onClose != null)
                  compact
                      ? _CloseRing(onClose: onClose!, tooltip: strings.close)
                      : IconButton(
                          tooltip: strings.close,
                          onPressed: onClose,
                          color: theme.text,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close_rounded, size: 24),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Six points of air above and below a header piece, on a phone.
///
/// The close button's touch target is the whole height of the line, so the
/// row itself carries no vertical padding; everything beside it takes its own.
Widget _air(bool compact, Widget child) => compact
    ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: child,
      )
    : child;

/// The way out: a 26-point ring, inside a target that reaches the corner.
///
/// The web draws the same ring and hangs a 44-point pseudo-element off it,
/// which can overflow its 38-point row; a Flutter hit box cannot leave its
/// parent, so the target is the whole height of the header line and wide
/// enough to reach the screen edge while the ring stays ten points clear of
/// it.
class _CloseRing extends StatelessWidget {
  const _CloseRing({required this.onClose, required this.tooltip});

  final VoidCallback onClose;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    const ring = SeatLayerSizeTokens.headerCloseSize;
    // The target is the line, so it has to be the line the header was told to
    // draw rather than the default the tokens ship.
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: SizedBox(
            width: ring + 20,
            height: theme.layout.headerHeight,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.divider),
                ),
                child: SizedBox.square(
                  dimension: ring,
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: theme.mutedText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventTitle extends StatelessWidget {
  const _EventTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final event = state.event;
    // The runtime's own name wins the moment it arrives; until then the host's
    // is a better placeholder than a generic instruction, because it is the
    // name the buyer just tapped and the header never has to change its mind.
    final placeholder = SeatLayerPickerScope.optionsOf(context).eventName;
    final runtimeName = event?.name;
    final name = runtimeName != null && runtimeName.isNotEmpty
        ? runtimeName
        : (placeholder != null && placeholder.isNotEmpty
            ? placeholder
            : strings.chooseSeats);
    if (compact) {
      // One line. A phone header that stacks a name over a venue spends the
      // height the map needs on words the buyer already chose their way past.
      return Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.text,
          fontSize: SeatLayerSizeTokens.headerNameFontSize,
          fontWeight: FontWeight.w700,
          height: 1.2,
          fontFamily: theme.fontFamily,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFamily: theme.fontFamily,
          ),
        ),
        if (event?.venue != null)
          Text(
            event!.venue!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 12,
              fontFamily: theme.fontFamily,
            ),
          ),
      ],
    );
  }
}

class _PickerBrandMark extends StatelessWidget {
  const _PickerBrandMark({
    required this.theme,
    required this.state,
    required this.size,
  });

  final SeatLayerResolvedPickerTheme theme;
  final SeatLayerPickerState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final provider = theme.logo;
    final url = state.branding?.logoUrl;
    if (provider != null || url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Image(
          image: provider ?? NetworkImage(url!),
          width: size,
          height: size,
          // A logo is a mark, not a picture: `cover` is what the web uses, so
          // a wordmark fills the square instead of shrinking inside it.
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  double get _radius => size < 30 ? SeatLayerRadiusTokens.headerLogo : 10;

  /// The organizer's initial, or the seat glyph when nothing is named.
  ///
  /// A letter is the mark the web falls back to, and it is the one thing on
  /// the header that says whose event this is when no logo was uploaded.
  Widget _fallback() {
    final named = state.branding?.brandName ?? state.event?.name;
    final letter = named == null || named.trim().isEmpty
        ? null
        : String.fromCharCode(named.trim().runes.first).toUpperCase();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.accent,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: letter == null
              ? Icon(
                  Icons.event_seat_rounded,
                  size: size * .56,
                  color: theme.onAccent,
                )
              : Text(
                  letter,
                  style: TextStyle(
                    color: theme.onAccent,
                    fontSize: size * .5,
                    fontWeight: FontWeight.w800,
                    fontFamily: theme.fontFamily,
                  ),
                ),
        ),
      ),
    );
  }
}

/// The instant every hold-derived surface reads its clock from.
///
/// One clock for the pill, the extend prompt and anything else counting the
/// same hold down: two clocks read a fraction of a second apart show the buyer
/// two different numbers for one fact. Pinned by `flutter_test_config` so a
/// golden of a countdown is the same picture every run.
DateTime seatLayerPickerNow() => SeatLayerPickerHoldCountdown.debugClock();

/// How long the buyer's seats stay held, counting down once a second.
///
/// Renders nothing until there is a hold, so it can be placed unconditionally.
class SeatLayerPickerHoldCountdown extends StatefulWidget {
  /// Creates the hold countdown pill.
  const SeatLayerPickerHoldCountdown({super.key, this.compact = false});

  /// Whether to render the phone's smaller pill.
  final bool compact;

  /// Below this much time left the pill stops being a fact and starts being a
  /// warning: it fills with the accent and its dot breathes.
  static const Duration expiring = Duration(minutes: 1);

  /// The wall clock this pill counts down against.
  ///
  /// A golden of the header is a picture of a running countdown, so the real
  /// clock would make it a different picture every second. `flutter_test_config`
  /// pins this to a fixed instant for the whole test run; nothing in the
  /// shipped SDK ever reassigns it.
  @visibleForTesting
  static DateTime Function() debugClock = DateTime.now;

  @override
  State<SeatLayerPickerHoldCountdown> createState() =>
      _SeatLayerPickerHoldCountdownState();
}

class _SeatLayerPickerHoldCountdownState
    extends State<SeatLayerPickerHoldCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (state.hold == null) return const SizedBox.shrink();
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final remaining = state.holdRemaining(seatLayerPickerNow());
    final minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final expiring = remaining <= SeatLayerPickerHoldCountdown.expiring;
    // Two states, one pill: a tinted plate while there is time, and the whole
    // accent once there is not. A countdown that only changes its number is a
    // countdown a buyer reads once and then stops looking at.
    final ink = expiring ? theme.onAccent : seatLayerAccentText(theme);
    final compact = widget.compact;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: expiring
            ? theme.accent
            : Color.alphaBlend(pickerAlpha(theme.accent, .14), theme.surface),
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12,
          vertical: compact ? 4 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HoldDot(color: ink, pulsing: expiring),
            SizedBox(width: compact ? 5 : 6),
            Text(
              strings.heldFor('$minutes:$seconds'),
              semanticsLabel:
                  '${remaining.inMinutes} minutes $seconds seconds remaining',
              style: TextStyle(
                color: ink,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                fontFamily: theme.fontFamily,
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The accent, darkened toward the text colour until it can be read as text.
///
/// A brand accent is chosen to be seen as a filled button, not to be legible
/// as 11 pt type on a pale plate. This walks it toward the picker's own ink
/// until the pair clears the 4.5:1 contrast a small label needs, and stops as
/// soon as it does, so a brand that was already legible keeps its own colour.
Color seatLayerAccentText(SeatLayerResolvedPickerTheme theme) {
  Color candidate = theme.accent;
  for (var step = 0; step < 10; step += 1) {
    if (_contrast(candidate, theme.surface) >= 4.5 &&
        _contrast(candidate, theme.background) >= 4.5) {
      return candidate;
    }
    candidate = Color.lerp(theme.accent, theme.text, (step + 1) * .1)!;
  }
  return theme.text;
}

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + .05) / (darker + .05);
}

/// The hold pill's status light, breathing once the hold is nearly out.
class _HoldDot extends StatefulWidget {
  const _HoldDot({required this.color, required this.pulsing});

  final Color color;
  final bool pulsing;

  @override
  State<_HoldDot> createState() => _HoldDotState();
}

class _HoldDotState extends State<_HoldDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didUpdateWidget(_HoldDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    if (widget.pulsing && !SeatLayerPickerMotion.reduced(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pickerAlpha(widget.color, .78),
            boxShadow: _pulse.value == 0
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: pickerAlpha(
                        widget.color,
                        .9 * (1 - _pulse.value),
                      ),
                      spreadRadius: 7 * _pulse.value,
                    ),
                  ],
          ),
          child: const SizedBox.square(dimension: 7),
        ),
      );
}

/// "Sales are closed", stated in the header beside the event's name.
class SeatLayerPickerSalesClosedPill extends StatelessWidget {
  /// Creates the sales-closed pill.
  const SeatLayerPickerSalesClosedPill({super.key, this.compact = false});

  /// Whether to render the phone's smaller pill.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(pickerAlpha(theme.text, .12), theme.surface),
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12,
          vertical: compact ? 4 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.lock_outline_rounded, size: 13, color: theme.text),
            const SizedBox(width: 6),
            Text(
              strings.salesClosed,
              maxLines: 1,
              style: TextStyle(
                color: theme.text,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                fontFamily: theme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
