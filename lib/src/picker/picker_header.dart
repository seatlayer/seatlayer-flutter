import 'dart:async';

import 'package:flutter/material.dart';

import 'picker_internal.dart';
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

  /// Whether to render the phone's 56-point height.
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
    return Material(
      color: headerStyle.color ?? theme.surface,
      elevation: headerStyle.elevation ?? 0,
      shape: headerStyle.shape,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: compact ? theme.layout.headerHeight : null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 12 : 16, 0, 4, 0),
            child: Row(
              children: [
                _PickerBrandMark(theme: theme, state: state, size: logoSize),
                SizedBox(width: compact ? 10 : 12),
                Expanded(
                  child: showEventDetails && !options.hideEventDetails
                      ? _EventTitle(compact: compact)
                      : const SizedBox.shrink(),
                ),
                if (showHoldPill && state.hold != null) ...[
                  const SeatLayerPickerHoldCountdown(),
                  const SizedBox(width: 4),
                ],
                if (onClose != null)
                  IconButton(
                    tooltip: strings.close,
                    onPressed: onClose,
                    color: theme.text,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded, size: compact ? 20 : 24),
                  ),
              ],
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
          fontSize: 14,
          fontWeight: FontWeight.w800,
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
        borderRadius: BorderRadius.circular(size < 30 ? 6 : 10),
        child: Image(
          image: provider ?? NetworkImage(url!),
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.accent,
          borderRadius: BorderRadius.circular(size < 30 ? 6 : 10),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.event_seat_rounded,
            size: size * .56,
            color: theme.onAccent,
          ),
        ),
      );
}

/// How long the buyer's seats stay held, counting down once a second.
///
/// Renders nothing until there is a hold, so it can be placed unconditionally.
class SeatLayerPickerHoldCountdown extends StatefulWidget {
  /// Creates the hold countdown pill.
  const SeatLayerPickerHoldCountdown({super.key});

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
    final remaining =
        state.holdRemaining(SeatLayerPickerHoldCountdown.debugClock());
    final minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: pickerAlpha(theme.accent, .12),
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 13, color: theme.accent),
            const SizedBox(width: 5),
            Text(
              strings.heldFor('$minutes:$seconds'),
              semanticsLabel:
                  '${remaining.inMinutes} minutes $seconds seconds remaining',
              style: TextStyle(
                color: theme.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
