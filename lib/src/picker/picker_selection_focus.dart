/// The candidate seat, as the runtime paints it.
///
/// A tapped seat is in `selection` from the moment it is tapped, and every
/// selected seat is drawn the same way — whether it is the one a card is
/// standing over or one of five the buyer settled minutes ago. On a map of
/// several thousand seats that leaves the buyer hunting for the seat they are
/// being asked about.
///
/// The web picker separates the two by telling the runtime which seat the card
/// is asking about: the runtime rings that one seat and pales its neighbours,
/// and clears the ring when the card goes. This is the same instruction, over
/// the bridge — paint, and nothing but paint.
library;

import 'package:meta/meta.dart';

import '../bridge/bridge_protocol.dart';
import '../seat_layer_error.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

/// The bridge command, named once so the gate and the send cannot drift.
@internal
const String seatLayerSelectionFocusCommand = 'picker.setSelectionFocus';

/// The one paint-only selection command.
extension SeatLayerPickerSelectionFocus on SeatLayerPickerController {
  /// Whether the mounted runtime paints a candidate seat.
  ///
  /// Gated on the command being in the bundle's own `hello` table rather than
  /// on a capability string: this changes nothing a snapshot reports, so the
  /// command table IS the whole contract. An older runtime advertises neither
  /// and is left drawing every selected seat alike, exactly as before.
  bool get supportsSelectionFocus =>
      mapController.bundleInfo?.supportsCommand(
        seatLayerSelectionFocusCommand,
      ) ==
      true;

  /// Paint [seatId] as the seat the buyer is being asked about, or clear the
  /// candidate with `null`.
  ///
  /// Paint only. It selects nothing, holds nothing and moves no camera, so it
  /// is safe on a read-only picker and carries no busy action — a buyer must
  /// not watch the chrome grey out because a card opened over a seat.
  ///
  /// Nothing is sent to a runtime that does not advertise the command. One
  /// that advertises it and still answers `unsupported_command` is not a
  /// failure the buyer has anything to do with either — the seat is simply
  /// painted the way it was before — so that one code is swallowed rather than
  /// published as an action error. Every other failure surfaces as usual.
  Future<void> setSelectionFocus(String? seatId) async {
    if (!supportsSelectionFocus) return;
    try {
      await runPickerMutation(
        seatLayerSelectionFocusCommand,
        <String, Object?>{'seatId': seatId},
        SeatLayerPickerBusyAction.none,
      );
    } on SeatLayerError catch (error) {
      if (error.code != BridgeErrorCode.unsupportedCommand) rethrow;
      // Only ours to take back: anything else that has landed on the state
      // since is a live failure with chrome of its own.
      if (identical(value.error, error)) value = value.withoutError();
    }
  }
}
