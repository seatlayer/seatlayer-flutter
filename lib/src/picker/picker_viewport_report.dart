/// Coalescing for what the host tells the runtime its chrome is covering.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'picker_models.dart';

/// Sends viewport insets to the runtime at most once per frame, and never
/// twice for the same numbers.
///
/// Extracted from the controller because it is its own small state machine and
/// shares nothing with the rest of the session. Native chrome settles over
/// several layout passes — the dock animating in while the sheet re-measures —
/// and each pass would otherwise mint its own command and its own map revision,
/// so the picker went busy and the camera re-framed while the buyer was still
/// dragging a sheet.
class PickerViewportReport {
  /// Creates a reporter that hands each settled value to [send].
  PickerViewportReport({required this.send});

  /// Delivers one report to the runtime.
  final Future<void> Function(SeatLayerViewportInsets? insets) send;

  SeatLayerViewportInsets? _pending;
  bool _hasPending = false;
  SeatLayerViewportInsets? _sent;
  bool _hasSent = false;
  bool _flushScheduled = false;
  /// The send still waiting on the runtime, so a repeat of the value it
  /// carries waits with it instead of reporting success on its behalf.
  Future<void>? _inFlight;

  /// Report [insets], or null to frame against the whole surface again.
  ///
  /// Safe to call from every layout pass: repeats are dropped and several
  /// calls inside one frame coalesce into the last.
  Future<void> report(SeatLayerViewportInsets? insets) {
    _pending = insets;
    _hasPending = true;
    if (_flushScheduled) return Future<void>.value();
    _flushScheduled = true;
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      if (!completer.isCompleted) completer.complete(_flush());
    });
    return completer.future;
  }

  /// Forget what was reported to a runtime that is going away.
  ///
  /// A fresh runtime frames against its whole surface until it is told
  /// otherwise, so the next report has to be sent even when the numbers have
  /// not moved.
  void forget() {
    _sent = null;
    _hasSent = false;
    _inFlight = null;
  }

  Future<void> _flush() {
    if (!_hasPending) return Future<void>.value();
    final wanted = _pending;
    _hasPending = false;
    // A REPEAT IS NOT AN ACKNOWLEDGEMENT. Dropping the duplicate command is
    // right — the runtime already has these numbers — but the caller is asking
    // "has the runtime been told", and answering yes while the first send is
    // still unanswered is what let the map be revealed at a framing the
    // runtime had not applied. The repeat waits on the send it duplicates.
    if (_hasSent && _sent == wanted) return _inFlight ?? Future<void>.value();
    _sent = wanted;
    _hasSent = true;
    final sending = send(wanted);
    _inFlight = sending;
    return sending.whenComplete(() {
      if (identical(_inFlight, sending)) _inFlight = null;
    });
  }
}
