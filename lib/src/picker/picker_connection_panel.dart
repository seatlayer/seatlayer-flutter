/// The panel for a seat map that could not open because the device is
/// offline, and the retries it makes by itself.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'picker_a11y.dart';
import 'picker_connection.dart';
import 'picker_connection_status.dart';
import 'picker_strings.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_theme.dart';

/// How long the panel waits before each retry of its own: 10 s, 20 s, then
/// every 30 s.
Duration pickerOfflineRetryAfter(int tries) => switch (tries) {
      0 => const Duration(seconds: 10),
      1 => const Duration(seconds: 20),
      _ => const Duration(seconds: 30),
    };

/// How many retries a picker has made since it last opened, kept across the
/// panel being rebuilt by each retry.
final Expando<_Tries> _tries = Expando<_Tries>('offline retries');

class _Tries {
  int count = 0;
  DateTime last = DateTime.now();
}

/// "You're offline", "Check your connection and try again.", "Try again".
///
/// While the app is in front the panel tries again by itself after
/// [pickerOfflineRetryAfter]; in the background it waits.
class PickerOfflinePanel extends StatefulWidget {
  /// Creates the panel.
  const PickerOfflinePanel({
    super.key,
    required this.controller,
    required this.palette,
    required this.words,
    required this.onRetry,
  });

  /// The picker whose page did not open.
  final SeatLayerPickerController controller;

  /// The palette to paint with.
  final SeatLayerResolvedPickerTheme palette;

  /// The words to use.
  final SeatLayerPickerStrings words;

  /// Opens the page again.
  final VoidCallback onRetry;

  @override
  State<PickerOfflinePanel> createState() => _PickerOfflinePanelState();
}

class _PickerOfflinePanelState extends State<PickerOfflinePanel>
    with WidgetsBindingObserver {
  Timer? _retry;

  _Tries get _count {
    final tries = _tries[widget.controller] ??= _Tries();
    // A picker that has been fine for a while starts the steps again.
    if (DateTime.now().difference(tries.last) > const Duration(minutes: 2)) {
      tries.count = 0;
    }
    return tries;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final life = WidgetsBinding.instance.lifecycleState;
    if (life == null || life == AppLifecycleState.resumed) _schedule();
  }

  void _schedule() {
    _retry?.cancel();
    final tries = _count;
    _retry = Timer(pickerOfflineRetryAfter(tries.count), () {
      if (!mounted) return;
      tries
        ..count += 1
        ..last = DateTime.now();
      widget.onRetry();
      // A retry that leaves this panel up (it failed at once) waits for the
      // next step; one that replaces it ends here, in [dispose].
      if (mounted) _schedule();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _schedule();
    } else {
      _retry?.cancel();
      _retry = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final words = widget.words;
    final dark = palette.brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? palette.surface : palette.background,
                shape: BoxShape.circle,
                border: Border.all(color: palette.divider),
              ),
              child: PickerConnectionSign(
                shown: SeatLayerConnectionShown.offline,
                color: pickerConnectionSignColor(
                  SeatLayerConnectionShown.offline,
                  palette,
                ),
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                words.offline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 17,
                  height: 1.3,
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
                  fontFamily: palette.fontFamily,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                words.checkConnection,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.mutedText,
                  fontSize: 14,
                  height: 1.45,
                  fontFamily: palette.fontFamily,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.onAccent,
                minimumSize: const Size(
                  128,
                  SeatLayerSizeTokens.minimumHitTarget,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(palette.buttonRadius),
                ),
              ),
              onPressed: widget.onRetry,
              child: Text(
                words.retry,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
                  fontFamily: palette.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
