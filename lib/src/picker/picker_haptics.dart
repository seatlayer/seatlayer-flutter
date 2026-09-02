import 'dart:async';

import 'package:flutter/services.dart';

import 'picker_models.dart';
import 'picker_tokens.g.dart';

/// One thing worth feeling.
enum PickerHapticCue {
  /// A seat joined the selection. The lightest cue there is: picking seats is
  /// a repeated action and anything heavier becomes noise by the fourth tap.
  selectionAdded,

  /// The map moved into a different section — a change of place, not of
  /// inventory.
  sectionFocused,

  /// Seats are now actually held. The one moment in the flow where something
  /// irreversible-feeling happened, so it gets a firm cue.
  holdCreated,

  /// The hold ran out and the seats went back. The heaviest cue in the set,
  /// and the only one for something the buyer did not do — it has to reach
  /// them when they are not looking at the screen, which is exactly when a
  /// hold lapses.
  ///
  /// Fired from the runtime's own expiry signal rather than from the snapshot:
  /// a snapshot only shows a hold going inactive, and a buyer releasing their
  /// seats deliberately must not feel like a loss.
  holdExpired,

  /// The phone's seat card arrived over the map. Light, because the buyer's
  /// finger is still on the glass where the seat was: this is the surface
  /// answering the tap, not news.
  cardArrived,

  /// The buyer pressed `Add seat`. The firmest cue in the picking loop — it is
  /// the one tap that changes what they are going to pay for.
  seatConfirmed,

  /// The seat card was dismissed — the button, a tap outside, or a swipe down.
  /// The lightest cue there is: nothing happened that the buyer has to notice.
  cardCancelled,
}

/// Decides WHICH haptic to fire, without knowing how to fire one.
///
/// Kept pure and separate for two reasons. It is the part with the actual
/// judgement in it — what counts as a change, and what must stay silent — and
/// that judgement is testable only if it is not tangled up with a platform
/// channel.
///
/// This policy owns the cues that have to be *deduced*. The three seat-card
/// cues are not: the card knows exactly when it arrived and which of its two
/// answers was pressed, so it asks the controller for those directly and
/// nothing here has to guess at them.
///
/// Every cue decided here is derived from the snapshot stream, because the
/// snapshot is the only place where selection, focus and hold are known to
/// agree with each other. Reacting to a per-event selection signal as well
/// would fire twice for one seat: the event and the snapshot that confirms it
/// are the same news.
///
/// The rule that matters most is the seeding one: the FIRST snapshot never
/// fires anything. A buyer returning to a picker that already has a focused
/// section and a resumed hold has not just done those things, and buzzing
/// twice on open would teach them the feedback means nothing.
class PickerHapticsPolicy {
  int? _selectionCount;
  String? _focusedSectionId;
  bool _holdActive = false;
  bool _seeded = false;

  /// Start over — a fresh handshake, or a reloaded page.
  void reset() {
    _selectionCount = null;
    _focusedSectionId = null;
    _holdActive = false;
    _seeded = false;
  }

  /// A new snapshot. Returns every cue it implies, in the order they should
  /// fire.
  List<PickerHapticCue> onSnapshot(SeatLayerPickerSnapshot snapshot) {
    final focusedSectionId = snapshot.map.focusedSectionId;
    final holdActive = snapshot.hold.active;
    final selectionCount = snapshot.selection.length;

    if (!_seeded) {
      _seeded = true;
      _focusedSectionId = focusedSectionId;
      _holdActive = holdActive;
      _selectionCount = selectionCount;
      return const <PickerHapticCue>[];
    }

    final cues = <PickerHapticCue>[];

    // Only a GROWING selection is worth a cue. Deselecting is the undo of an
    // action the buyer already felt, and removals also arrive in bulk when a
    // hold lapses — a burst of clicks for seats being taken away reads as the
    // app celebrating a loss.
    final previousCount = _selectionCount;
    _selectionCount = selectionCount;
    if (previousCount != null && selectionCount > previousCount) {
      cues.add(PickerHapticCue.selectionAdded);
    }

    if (focusedSectionId != _focusedSectionId) {
      _focusedSectionId = focusedSectionId;
      // Returning to the overview is a section change too, but it is a step
      // BACK — the buyer already felt the tap that got them there, and a cue
      // for leaving a place is not the same information as arriving at one.
      if (focusedSectionId != null) cues.add(PickerHapticCue.sectionFocused);
    }

    if (holdActive != _holdActive) {
      _holdActive = holdActive;
      if (holdActive) cues.add(PickerHapticCue.holdCreated);
    }

    return cues;
  }
}

/// Turns a cue into an actual vibration.
///
/// Silent on desktop and web, and on any device with the motor disabled — the
/// platform decides.
///
/// The failure is swallowed HERE rather than at the call site, because these
/// calls fail asynchronously: they reach a platform channel through a Future,
/// so a `try` around the invocation catches nothing and the rejection surfaces
/// later as an unhandled error with no owner. There is always a caller for whom
/// no channel exists — a headless test binding, an embedder that has torn its
/// messenger down — and a cue that cannot play is not an error anyone can act
/// on. Nothing that depends on the buyer's seats may ever fail because a phone
/// declined to buzz.
void playPickerHaptic(PickerHapticCue cue) {
  unawaited(_fire(pickerHapticStrength(cue)).catchError((Object _) {}));
}

/// Which platform strength [cue] fires, named the way `design/tokens.json`
/// names it so every SDK feels the same.
String pickerHapticStrength(PickerHapticCue cue) => switch (cue) {
      PickerHapticCue.selectionAdded => SeatLayerHapticTokens.selectionAdded,
      PickerHapticCue.sectionFocused => SeatLayerHapticTokens.sectionFocused,
      PickerHapticCue.holdCreated => SeatLayerHapticTokens.holdCreated,
      PickerHapticCue.holdExpired => SeatLayerHapticTokens.holdExpired,
      PickerHapticCue.cardArrived => SeatLayerHapticTokens.cardArrived,
      PickerHapticCue.seatConfirmed => SeatLayerHapticTokens.seatConfirmed,
      PickerHapticCue.cardCancelled => SeatLayerHapticTokens.cardCancelled,
    };

Future<void> _fire(String strength) => switch (strength) {
      'selection' => HapticFeedback.selectionClick(),
      'light' => HapticFeedback.lightImpact(),
      'medium' => HapticFeedback.mediumImpact(),
      'heavy' => HapticFeedback.heavyImpact(),
      _ => HapticFeedback.selectionClick(),
    };
