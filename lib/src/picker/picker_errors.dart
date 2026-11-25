/// The inline failure bar shown inside the buyer chrome.

library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../seat_layer_error.dart';
import 'picker_error_words.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// Refusals the runtime answers when the picker tries to change a hold it may
/// not change — the buyer came back from checkout and tapped another seat, or
/// asked for a hold it already has. Each one is a STATE with a way out, not a
/// failure, and the bar says so in the buyer's words rather than the bridge's.
const Set<String> _holdOwnershipCodes = <String>{
  'hold_owned_by_host',
  'hold_selection_mismatch',
  'hold_already_active',
};

/// How much of the screen's height the bar's words may take before they scroll.
const double _maxHeightFraction = .15;

/// And what they always get, on a phone held sideways.
const double _minMaxHeight = 84;

class SeatLayerPickerActionError extends StatelessWidget {
  const SeatLayerPickerActionError({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final error = state.error;
    if (error == null || state.phase != SeatLayerPickerPhase.ready) {
      return const SizedBox.shrink();
    }
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final code = error is SeatLayerError ? error.code : null;
    final handoff = state.checkoutHandoff;
    final String message;
    String? detail;
    VoidCallback? release;
    if (code != null && _holdOwnershipCodes.contains(code)) {
      if (handoff != null || state.hasHostOwnedHold) {
        message = strings.holdInCheckoutTitle;
        detail = strings.holdInCheckoutBody;
        if (handoff != null) {
          release = () => ignorePickerAction(
                controller.rejectCheckoutHandoff(handoff).then((_) {
                  if (identical(controller.state.error, error)) {
                    controller.dismissError();
                  }
                }),
              );
        }
      } else {
        message = strings.holdAlreadyHeldTitle;
        detail = strings.holdAlreadyHeldBody;
      }
    } else {
      final words = pickerErrorWords(
        error,
        strings,
        failure:
            error is SeatLayerError ? controller.failureFor(error) : null,
      );
      message = words.message;
      detail = words.detail;
    }
    return Material(
      color: theme.error,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 9),
            Expanded(
              // A sentence that outgrows its share of the screen scrolls: it is
              // never cut, and the checkout button under it stays in reach.
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: math.max(
                    MediaQuery.sizeOf(context).height * _maxHeightFraction,
                    _minMaxHeight,
                  ),
                ),
                child: SingleChildScrollView(
                  primary: false,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                      if (release != null) ...[
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: state.isBusy ? null : release,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(strings.releaseAndChangeSeats),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: strings.dismissError,
              onPressed: controller.dismissError,
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
