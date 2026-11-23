/// The app's own server booked the hold; the map is told so at once.
///
/// Without this the picker finds a booking by itself: a handed-off hold that
/// leaves the snapshot with no expiry announced is a sale (see
/// `picker_booked_tracker.dart`). That still holds. This is the explicit word
/// for a host whose server has just booked: the runtime paints the bought seats
/// booked, stops the clock and never releases that hold afterwards, and the
/// snapshot that follows ends the hold the same way a booking does, so
/// `onBooked` and the booked overlay follow as before.
///
/// The web picker's `markBooked(holdId?)`, over the bridge.
library;

import 'package:meta/meta.dart';

import '../json.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

/// The capability a runtime advertises when it takes `picker.markBooked`.
const String seatLayerMarkBookedCapability = 'hold-mark-booked-v1';

/// The bridge command, named once so the gate and the send cannot drift.
@internal
const String seatLayerMarkBookedCommand = 'picker.markBooked';

/// Telling the map that the host's server booked a hold.
extension SeatLayerPickerMarkBooked on SeatLayerPickerController {
  /// Whether the mounted runtime takes [markBooked].
  bool get supportsMarkBooked =>
      mapController.bundleInfo?.supportsCapability(
        seatLayerMarkBookedCapability,
      ) ==
      true;

  /// Settle a hold your server has booked: the seats are painted booked, the
  /// hold clock stops, and the picker never releases that hold.
  ///
  /// Call it only after your server has booked. The picker takes your word for
  /// it: called earlier, the seats show as taken until the server's hold runs
  /// out, and the picker will not release it.
  ///
  /// Without [holdId] it means the hold this picker handed to your checkout,
  /// never any other. A named [holdId] must be the hold held now.
  ///
  /// Resolves true when the hold is booked, or was already marked booked.
  /// Resolves false and changes nothing for another hold, no hold, or a
  /// runtime that does not take the command ([supportsMarkBooked] is false);
  /// the picker then still finds the booking when the hold leaves the map.
  ///
  /// Allowed on a read-only picker: it books, releases and changes nothing on
  /// the server.
  Future<bool> markBooked({String? holdId}) async {
    if (!supportsMarkBooked) return false;
    final result = await runPickerMutation(
      seatLayerMarkBookedCommand,
      <String, Object?>{if (holdId != null) 'holdId': holdId},
      SeatLayerPickerBusyAction.none,
    );
    return jBool(jGet(result, 'booked')) == true;
  }
}
