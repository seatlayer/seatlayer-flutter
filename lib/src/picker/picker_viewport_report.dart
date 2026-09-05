/// Coalescing for what the host tells the runtime about its own chrome.
library;

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'picker_models.dart';

/// Sends one kind of host report to the runtime at most once per frame, and
/// never twice for the same value.
///
/// Extracted from the controller because it is its own small state machine and
/// shares nothing with the rest of the session. Native chrome settles over
/// several layout passes — the dock animating in while the sheet re-measures —
/// and each pass would otherwise mint its own command and its own map revision,
/// so the picker went busy and the camera re-framed while the buyer was still
/// dragging a sheet.
///
/// Generic over the value because two reports share the rule: the viewport
/// insets, and the rectangles of chrome a tap must never fall through
/// ([PickerViewportReport], [PickerBlockedRegionsReport]).
class PickerCoalescedReport<T> {
  /// Creates a reporter that hands each settled value to [send].
  ///
  /// [equals] decides what "the same value" means; the default is `==`, which
  /// a list of regions has to replace with element-wise equality.
  PickerCoalescedReport({required this.send, bool Function(T a, T b)? equals})
      : _equals = equals ?? _defaultEquals;

  /// Delivers one report to the runtime.
  final Future<void> Function(T value) send;

  final bool Function(T a, T b) _equals;

  static bool _defaultEquals<T>(T a, T b) => a == b;

  T? _pending;
  bool _hasPending = false;
  T? _sent;
  bool _hasSent = false;
  bool _flushScheduled = false;

  /// The send still waiting on the runtime, so a repeat of the value it
  /// carries waits with it instead of reporting success on its behalf.
  Future<void>? _inFlight;

  /// Report [value].
  ///
  /// Safe to call from every layout pass: repeats are dropped and several
  /// calls inside one frame coalesce into the last.
  Future<void> report(T value) {
    _pending = value;
    _hasPending = true;
    if (_flushScheduled) return Future<void>.value();
    _flushScheduled = true;
    final completer = Completer<void>();
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      _flushScheduled = false;
      if (!completer.isCompleted) completer.complete(_flush());
    });
    // A report made from a build rides the frame that is already being
    // drawn. One made from a timer — a guard rectangle lingering after its
    // control has gone — has no frame coming in an idle app, and a
    // post-frame callback with no frame behind it is a report never sent.
    if (binding.schedulerPhase == SchedulerPhase.idle) binding.scheduleFrame();
    return completer.future;
  }

  /// Forget what was reported to a runtime that is going away.
  ///
  /// A fresh runtime knows nothing until it is told, so the next report has
  /// to be sent even when the value has not moved.
  void forget() {
    _sent = null;
    _hasSent = false;
    _inFlight = null;
  }

  Future<void> _flush() {
    if (!_hasPending) return Future<void>.value();
    final wanted = _pending as T;
    _hasPending = false;
    // A REPEAT IS NOT AN ACKNOWLEDGEMENT. Dropping the duplicate command is
    // right — the runtime already has this value — but the caller is asking
    // "has the runtime been told", and answering yes while the first send is
    // still unanswered is what let the map be revealed at a framing the
    // runtime had not applied. The repeat waits on the send it duplicates.
    if (_hasSent && _equals(_sent as T, wanted)) {
      return _inFlight ?? Future<void>.value();
    }
    _sent = wanted;
    _hasSent = true;
    final sending = send(wanted);
    _inFlight = sending;
    return sending.whenComplete(() {
      if (identical(_inFlight, sending)) _inFlight = null;
    });
  }
}

/// The viewport insets report: null frames against the whole surface again.
typedef PickerViewportReport = PickerCoalescedReport<SeatLayerViewportInsets?>;
