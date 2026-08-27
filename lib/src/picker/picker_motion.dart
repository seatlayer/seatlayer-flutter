import 'package:flutter/widgets.dart';

import 'picker_tokens.g.dart';

/// The picker's timing vocabulary, mirroring the web widget's `pickerMotion`.
///
/// One table, spent by every animated moment in the native chrome. Surfaces
/// that open the same way animate for the same length of time, which is the
/// difference between an interface that reads as designed and one that reads
/// as assembled. Nothing here exceeds 420 ms — past that a buyer is waiting
/// rather than watching.
///
/// Read a duration through [SeatLayerPickerMotion.of], never from these
/// constants directly: `of` collapses everything to zero when the viewer has
/// asked for less movement.
abstract final class SeatLayerPickerMotion {
  /// Anything arriving: cards, sheets, toasts, overlays.
  static const Duration enter =
      Duration(milliseconds: SeatLayerMotionTokens.enter);

  /// Anything leaving. Faster than the entrance — a departure should not be
  /// something the buyer waits through.
  static const Duration exit =
      Duration(milliseconds: SeatLayerMotionTokens.exit);

  /// The dock bar riding in from under the map.
  static const Duration dock =
      Duration(milliseconds: SeatLayerMotionTokens.dock);

  /// The cart sheet changing height or state.
  static const Duration sheet =
      Duration(milliseconds: SeatLayerMotionTokens.sheet);

  /// A selected seat flying from the confirm card to the peek bar.
  static const Duration fly =
      Duration(milliseconds: SeatLayerMotionTokens.fly);

  /// One seat of a best-available result popping in.
  static const Duration pop =
      Duration(milliseconds: SeatLayerMotionTokens.pop);

  /// Between consecutive members of a set.
  static const Duration stagger =
      Duration(milliseconds: SeatLayerMotionTokens.stagger);

  /// Swapping text in place — the dock name as the map pans under it.
  static const Duration crossfade =
      Duration(milliseconds: SeatLayerMotionTokens.crossfade);

  /// A toast or undo bar rising.
  static const Duration toast =
      Duration(milliseconds: SeatLayerMotionTokens.toast);

  /// The immersive 3D chrome settling onto the scene.
  static const Duration immersive =
      Duration(milliseconds: SeatLayerMotionTokens.immersive);

  /// How long an undo stays offered after a ticket is removed.
  ///
  /// Not an animation and deliberately outside [catalog]'s budget: this is how
  /// long a buyer has to change their mind, and four seconds is the shortest
  /// span that survives a glance away from the screen.
  static const Duration undoWindow =
      Duration(milliseconds: SeatLayerMotionTokens.undoWindow);

  /// Every token, for the catalogue test that keeps them inside the budget.
  static const Map<String, Duration> catalog = <String, Duration>{
    'enter': enter,
    'exit': exit,
    'dock': dock,
    'sheet': sheet,
    'fly': fly,
    'pop': pop,
    'stagger': stagger,
    'crossfade': crossfade,
    'toast': toast,
    'immersive': immersive,
  };

  /// The one overshoot in the system, reserved for a buyer's own action
  /// landing: a card arriving from the seat, a sheet springing open.
  static const Curve spring = Curves.easeOutBack;

  /// Everything else arriving.
  static const Curve easeEnter = Curves.easeOutCubic;

  /// Everything leaving.
  static const Curve easeExit = Curves.easeInCubic;

  /// [token], or [Duration.zero] when this viewer has asked for less movement.
  static Duration of(BuildContext context, Duration token) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : token;

  /// Whether this viewer has asked for less movement.
  ///
  /// Motion that has no reduced form — a fly-to-tray indicator, a staggered
  /// arrival — is skipped entirely rather than played instantly.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
