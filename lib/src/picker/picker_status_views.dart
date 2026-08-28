/// Everything the picker shows when there is nothing to choose from yet: the
/// loading, failure and empty states, the test-event badge, the floor selector
/// and the wide layout's checkout bar.
library;

import 'package:flutter/material.dart';

import '../seat_layer_error.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'picker_strings.dart';
import 'picker_cart_sheet.dart';
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
    // The badge is drawn ON the map, so it follows the map's palette — which
    // the immersive scene keeps dark whatever side the picker is on. A solid
    // amber lozenge over a dark venue reads as a highlighter stripe left on
    // the screen; on the dark side it becomes a dark pill with amber ink and
    // an amber hairline, which reads as the same badge in the same voice.
    final theme = seatLayerMapChromeThemeOf(context);
    final dark = theme.brightness == Brightness.dark;
    return Semantics(
      label: 'Test event. No real inventory will be booked.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? pickerAlpha(theme.surface, .92) : theme.warning,
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
          border: dark ? Border.all(color: theme.warning) : null,
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 8),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 4 : 6,
          ),
          child: Text(
            compact ? 'TEST MODE' : 'TEST MODE · BOOKS NOTHING',
            style: TextStyle(
              color: dark ? theme.warning : const Color(0xFF1A1200),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
              fontFamily: theme.fontFamily,
            ),
          ),
        ),
      ),
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
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.accent,
                  foregroundColor: theme.onAccent,
                  minimumSize: const Size(156, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(theme.buttonRadius),
                  ),
                ),
                onPressed: controller.canCheckout
                    ? () => ignorePickerAction(
                          checkoutThroughHost(controller, onCheckout),
                        )
                    : null,
                child:
                    state.busyAction == SeatLayerPickerBusyAction.creatingHold
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
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
          CircularProgressIndicator(color: palette.accent),
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
