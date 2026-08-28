/// The one moment the buyer is told their hold ended without them.
library;

import 'package:flutter/material.dart';

import 'picker_availability.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_strings.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// Says, once, that a hold lapsed — and offers the seats back where it can.
///
/// Two surfaces for one fact, and deliberately no third. The line stays in the
/// cart sheet, where the buyer's tickets were and where they will look for
/// them; the toast catches a buyer who is looking at the map instead. Neither
/// blocks anything. A dialog was rejected: the buyer has just come back from
/// somewhere else, and a modal is a second thing to dismiss before they can see
/// whether their seats are still there.
///
/// Renders nothing at all when nothing lapsed, and when the host has taken the
/// moment over with `SeatLayerPickerOptions(announceHoldLapse: false)` — which
/// still leaves [SeatLayerPickerCallbacks.onHoldExpired] firing.
class SeatLayerHoldLapseNotice extends StatefulWidget {
  /// Creates the lapse notice.
  const SeatLayerHoldLapseNotice({super.key});

  @override
  State<SeatLayerHoldLapseNotice> createState() =>
      _SeatLayerHoldLapseNoticeState();
}

class _SeatLayerHoldLapseNoticeState extends State<SeatLayerHoldLapseNotice> {
  /// The lapse the toast has already been shown for.
  ///
  /// Identity, not equality: a second lapse with the same seats in it is a
  /// second thing that happened to the buyer and is worth saying again.
  SeatLayerHoldLapse? _announced;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final options = SeatLayerPickerScope.optionsOf(context);
    final lapse = options.announceHoldLapse ? controller.holdLapse : null;
    if (lapse == null) {
      _announced = null;
      return const SizedBox.shrink();
    }
    final strings = SeatLayerPickerScope.stringsOf(context);
    final theme = seatLayerMapChromeThemeOf(context);
    final body = holdLapseBody(strings, lapse);

    if (!identical(_announced, lapse)) {
      _announced = lapse;
      // After the frame: this runs from a build, and a messenger asked to show
      // a bar mid-build rebuilds the tree that is still being built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.hideCurrentSnackBar();
        messenger?.showSnackBar(
          SnackBar(
            // The picker's own surface, not Material's inverse: left alone it
            // paints a white bar across a dark picker.
            backgroundColor: theme.surface,
            duration: SeatLayerPickerMotion.undoWindow,
            content: Text(
              body == null
                  ? strings.holdLapsedTitle
                  : '${strings.holdLapsedTitle} $body',
              style: TextStyle(color: theme.text, fontFamily: theme.fontFamily),
            ),
          ),
        );
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.timer_off_rounded, size: 18, color: theme.mutedText),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.holdLapsedTitle,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: theme.fontFamily,
                  ),
                ),
                if (body != null)
                  Text(
                    body,
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 12,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
              ],
            ),
          ),
          if (lapse.recovery != SeatLayerRecovery.none)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.accent,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () => ignorePickerAction(
                controller.reselectLapsedSeats().then((_) {}),
              ),
              // Styled on the child rather than through `styleFrom`: a
              // ButtonStyle text style replaces the ambient one outright
              // instead of merging with it, so a null family there resolves to
              // the platform default rather than to the picker's face.
              child: Text(
                strings.reselectSeats,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                ),
              ),
            )
          else
            IconButton(
              visualDensity: VisualDensity.compact,
              color: theme.mutedText,
              onPressed: controller.dismissHoldLapse,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

/// The sentence under the lapse title, or null when there is nothing to add.
///
/// Two facts at most, and only the ones that are true: how long the hold was
/// good for, when the session named a window, and how many of the seats are
/// gone for good, when some are and some are not.
@visibleForTesting
String? holdLapseBody(
  SeatLayerPickerStrings strings,
  SeatLayerHoldLapse lapse,
) {
  final parts = <String>[
    if (lapse.heldFor != null) strings.holdLapsedBody(lapse.heldFor!.inMinutes),
    if (lapse.recovery == SeatLayerRecovery.partial)
      strings.seatsNotRecovered(lapse.unrecoveredCount),
  ];
  return parts.isEmpty ? null : parts.join(' ');
}
