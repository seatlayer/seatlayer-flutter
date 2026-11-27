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

/// Where nothing above the bar bounds it (the wide panel), how much of the
/// screen's height its words may take before they scroll.
const double _maxHeightFraction = .15;

/// And what they always get there.
const double _minMaxHeight = 84;

class SeatLayerPickerActionError extends StatelessWidget {
  const SeatLayerPickerActionError({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final error = state.error;
    if (error == null ||
        state.phase != SeatLayerPickerPhase.ready ||
        // A lost line and a server fault are told in amber by the toast
        // layer; the red line is for refusals.
        pickerFailureKind(error) != PickerFailureKind.other) {
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
        failure: error is SeatLayerError ? controller.failureFor(error) : null,
      );
      message = words.message;
      detail = words.detail;
    }
    return LayoutBuilder(
      builder: (context, room) => Material(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A sentence is never cut, and the button under it stays in
                    // reach. Where the bar is given a height (under the cart
                    // row), the words stand whole wherever it has room for
                    // them and scroll only where it has not; elsewhere they
                    // scroll past a share of the screen.
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: room.maxHeight.isFinite
                              ? double.infinity
                              : math.max(
                                  MediaQuery.sizeOf(context).height *
                                      _maxHeightFraction,
                                  _minMaxHeight,
                                ),
                        ),
                        child: SingleChildScrollView(
                          primary: false,
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: release == null ? 10 : 0,
                          ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (release != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 10),
                        child: OutlinedButton(
                          onPressed: state.isBusy ? null : release,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(strings.releaseAndChangeSeats),
                        ),
                      ),
                  ],
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
      ),
    );
  }
}
