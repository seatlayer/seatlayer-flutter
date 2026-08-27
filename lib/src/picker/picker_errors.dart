/// The inline failure bar shown inside the buyer chrome.

library;

import 'package:flutter/material.dart';

import '../seat_layer_error.dart';
import 'picker_models.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPickerActionError extends StatelessWidget {
  const SeatLayerPickerActionError({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final error = controller.state.error;
    if (error == null || controller.state.phase != SeatLayerPickerPhase.ready) {
      return const SizedBox.shrink();
    }
    final theme = seatLayerPickerThemeOf(context);
    final message = error is SeatLayerError ? error.message : '$error';
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Dismiss error',
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
