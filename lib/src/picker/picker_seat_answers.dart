part of 'seat_layer_picker_controller.dart';

/// Which seat the buyer is being asked about, and what they have answered.
///
/// A seat that has just been tapped is already in the runtime's `selection` —
/// and therefore in the cart, the ticket count and the total — while the
/// native confirm card is still asking whether the buyer wants it. So
/// everything a buyer reads as a commitment is counted from
/// [confirmedCartLines] rather than from the raw snapshot.
///
/// A mixin rather than a plain block of the controller so the question, the
/// state behind it and the rules that clear it are readable in one place.
mixin _PickerSeatAnswers on ValueNotifier<SeatLayerPickerState> {
  /// The session's options, owned by the controller this is mixed into.
  SeatLayerPickerOptions get _options;

  /// Whether the controller has been disposed.
  bool get _disposed;

  /// Labels the buyer has decided about, either way.
  final Set<String> _confirmedLabels = <String>{};

  /// The seat an open confirm card is asking about.
  SelectedSeat? _confirmCardSeat;

  /// The seat a confirm card is standing over, unanswered.
  ///
  /// The runtime has no notion of an unconfirmed selection: a tapped seat is
  /// in `selection` — and therefore in the cart, the ticket count and the
  /// total — from the moment it is tapped. The confirm card is native chrome
  /// drawn over that, so without this the buyer sees `1 ticket · €40` and a
  /// live Continue behind a card that is still asking whether they want the
  /// seat at all.
  ///
  /// Reported by whichever chrome is actually asking, so it is null in a
  /// composed layout that shows no card — a seat nobody is asking about is
  /// simply in the cart.
  SelectedSeat? get seatAwaitingConfirmation => _confirmCardSeat;

  /// The seat the picker would ask about next, if it asks at all.
  ///
  /// Null for a read-only session, for `confirmSelection: false`, once a hold
  /// exists, and when every selected seat has been answered for.
  @internal
  SelectedSeat? get unansweredSeat {
    if (_options.readOnly || !_options.confirmSelection) return null;
    // A live hold does not silence the question: the seats a hold arrived
    // with were adopted as answered when it appeared (see _applySnapshot), so
    // what is left unanswered here is what the buyer tapped since.
    for (final seat in value.selection.reversed) {
      if (!_confirmedLabels.contains(seat.label)) return seat;
    }
    return null;
  }

  /// Tell the controller which seat the open confirm card is showing.
  ///
  /// Called from the chrome's build, so it deliberately does not notify: the
  /// widgets that read it are built after it in the same pass, and every one
  /// of them rebuilds with the layout that reports it.
  @internal
  void setConfirmCardSeat(SelectedSeat? seat) => _confirmCardSeat = seat;

  /// Record that the buyer answered for [label], and take its card down.
  @internal
  void markSeatAnswered(String label) {
    if (_disposed || !_confirmedLabels.add(label)) return;
    if (_confirmCardSeat?.label == label) _confirmCardSeat = null;
    notifyListeners();
  }

  /// The cart the buyer has actually agreed to.
  ///
  /// [SeatLayerPickerState.cartLines] less the seat whose card is still open,
  /// matched on the runtime's own seat id where it gave one and on the
  /// inventory label otherwise. Use it — and [confirmedTicketCount] and
  /// [confirmedCartTotal] — for anything the buyer reads as a commitment.
  List<SeatLayerCheckoutLineItem> get confirmedCartLines {
    final pending = seatAwaitingConfirmation;
    if (pending == null) return value.cartLines;
    return List<SeatLayerCheckoutLineItem>.unmodifiable(
      value.cartLines.where(
        (line) => line.seatId == null
            ? line.label != pending.label
            : line.seatId != pending.id,
      ),
    );
  }

  /// How many tickets the buyer has agreed to.
  int get confirmedTicketCount => seatAwaitingConfirmation == null
      ? (value.snapshot?.ticketCount ?? value.cartLines.length)
      : confirmedCartLines.fold<int>(0, (sum, line) => sum + line.quantity);

  /// What the buyer has agreed to, in the cart's currency.
  double get confirmedCartTotal => seatAwaitingConfirmation == null
      ? (value.snapshot?.cartTotal ??
          value.cartLines.fold<double>(0, (sum, line) => sum + line.total))
      : confirmedCartLines.fold<double>(0, (sum, line) => sum + line.total);
  /// Keep the question honest against the selection the runtime reports.
  ///
  /// A seat that left the selection takes its answer with it, so re-picking it
  /// asks again rather than joining the cart silently.
  void _syncSeatAnswers(Set<String> live) {
    _confirmedLabels.removeWhere((label) => !live.contains(label));
    if (_confirmCardSeat != null && !live.contains(_confirmCardSeat!.label)) {
      _confirmCardSeat = null;
    }
  }
}
