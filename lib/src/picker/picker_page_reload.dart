part of 'seat_layer_picker_controller.dart';

/// A page that takes another's place, and the hold it is asked to take up.
///
/// A mixin for the same reason as [_PickerSeatAnswers]: the controller file is
/// at its line cap.
mixin _PickerPageReload on ValueNotifier<SeatLayerPickerState> {
  SeatLayerPickerController get _controller;

  late final PickerReloadHold _reloadHold = PickerReloadHold(
    holdIsActive: () => value.hold != null,
    resume: _resumeHold,
    gone: (holdId) {
      if (value.checkoutHandoff?.holdId == holdId) {
        value = value.withoutHandoff();
      }
    },
  );

  bool _pageWasUp = false;
  bool _bootsWithoutInitialHold = false;

  /// Whether the page starts without [SeatLayerPickerOptions.initialHoldId]:
  /// one that takes another's place is asked for the hold once it is up.
  @internal
  bool get bootsWithoutInitialHold => _bootsWithoutInitialHold;

  /// Recreate the embedded runtime after a load or compatibility failure.
  ///
  /// Selection and hold recovery remain runtime/server-authoritative; the SDK
  /// does not pretend stale local state survived a failed transport.
  Future<void> retry() {
    final controller = _controller;
    if (controller._disposed || value.phase == SeatLayerPickerPhase.closed) {
      return Future<void>.error(const SeatLayerError.destroyed());
    }
    return controller._serialize(() async {
      _rememberHold();
      // A failed handshake has no live picker to clean up. If the runtime did
      // reach Ready (for example access later became unavailable), acknowledge
      // destroy before the ValueKey swap removes its WebView so a picker-owned
      // hold is not left solely to TTL cleanup.
      if (controller.mapController.isReady) {
        try {
          await controller.mapController.runBridgeCommand('picker.destroy');
        } catch (_) {
          // Retry remains recoverable when the old runtime is already gone.
        }
      }
      _replacePage();
    });
  }

  void _replacePage() {
    final controller = _controller;
    controller._reloadGeneration += 1;
    controller._haptics.reset();
    controller._viewportReport.forget();
    controller._blockedRegions.forget();
    controller._seatView = null;
    // A retry is a second open, and its own wait starts here.
    controller._tapToReadyMs = null;
    controller._readyInfo = null;
    controller._mountClock
      ..reset()
      ..start();
    _bootsWithoutInitialHold = _pageWasUp;
    value = value.reloading();
  }

  /// What the page that is going away has. Without a hold of its own, what it
  /// was still being asked for stands.
  void _rememberHold() {
    if (value.hold == null) return;
    _reloadHold.remember(
      value.checkoutHandoff?.holdId ??
          (value.hasHostOwnedHold ? _controller._options.initialHoldId : null),
    );
  }

  /// [next] may come from a page that took the place of [current]'s.
  void _pageTookOver(
    SeatLayerPickerSnapshot? current,
    SeatLayerPickerSnapshot next,
  ) {
    _pageWasUp = true;
    if (current != null && current.sessionId != next.sessionId) _rememberHold();
  }

  Future<bool> _resumeHold(String holdId) {
    final controller = _controller;
    return controller._serialize(() async {
      if (value.hold != null) return false;
      final result = await controller.mapController.runBridgeCommand(
        'picker.resumeHold',
        <String, Object?>{'holdId': holdId},
      );
      controller._applySnapshotFromResult(result);
      final revision = jInt(jGet(result, 'revision'));
      if (revision != null) await controller._awaitRevision(revision);
      return value.hold != null;
    });
  }
}
