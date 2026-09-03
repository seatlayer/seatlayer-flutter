/// Which cart lines the buyer has asked to remove, and has not yet seen go.
///
/// `picker.removeCartLine` is slow by nature: the server re-holds whatever is
/// left of the cart before it answers, so on a real event the reply is close to
/// two seconds behind the press. Waiting for it before touching the row meant
/// the sheet said nothing at all for that whole window and then swapped the
/// line's text in one frame.
///
/// This is the small piece of state that lets the row answer the press
/// immediately: the line is marked the moment the buyer asks, drawn at
/// `opacity.removing` with its × inert while the mutation runs, and unmarked
/// either by the snapshot that no longer carries it or by the failure that
/// leaves it where it was.
///
/// It lives beside the controller rather than inside it — the controller is at
/// its line cap — and beside the widget rather than inside it, because the row
/// that starts the removal is rebuilt (and, when a run folds, replaced) before
/// the reply lands.
library;

import 'package:flutter/foundation.dart';

import 'seat_layer_picker_controller.dart';

/// The cart lines one picker has been asked to remove, still in flight.
class SeatLayerCartRemovals extends ChangeNotifier {
  final Set<String> _pending = <String>{};

  /// Whether the line whose inventory label is [label] is on its way out.
  bool isRemoving(String label) => _pending.contains(label);

  /// Whether any line is on its way out.
  bool get isEmpty => _pending.isEmpty;

  /// The buyer has asked for [label] to go.
  ///
  /// A second press on a row already marked changes nothing and notifies
  /// nobody: the × is inert by then, but a swipe that commits at the same
  /// moment can still arrive twice.
  void mark(String label) {
    if (!_pending.add(label)) return;
    notifyListeners();
  }

  /// The mutation failed — put the row back the way it was.
  void restore(String label) {
    if (!_pending.remove(label)) return;
    notifyListeners();
  }

  /// Drop every mark [present] no longer accounts for.
  ///
  /// Called while the list is building, from the snapshot it is building
  /// from, and so deliberately silent: the frame that clears the mark is the
  /// frame that draws the result of clearing it, and notifying listeners
  /// mid-build would schedule a second one to draw the same thing.
  ///
  /// Returns whether anything was cleared, which is what makes it testable
  /// without a widget tree.
  bool settle(Set<String> present) {
    final gone = _pending.where((label) => !present.contains(label)).toList();
    if (gone.isEmpty) return false;
    _pending.removeAll(gone);
    return true;
  }
}

final Expando<SeatLayerCartRemovals> _removals =
    Expando<SeatLayerCartRemovals>('seatlayer-cart-removals');

/// The in-flight removals belonging to [controller], created on first ask.
///
/// Keyed off the controller for the same reason the accessible tour is (see
/// `picker_accessibility_focus.dart`): one picker, one truth, and no widget
/// long-lived enough to hold it.
SeatLayerCartRemovals seatLayerCartRemovalsOf(
  SeatLayerPickerController controller,
) =>
    _removals[controller] ??= SeatLayerCartRemovals();
