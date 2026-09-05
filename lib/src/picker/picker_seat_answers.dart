part of 'seat_layer_picker_controller.dart';

/// Which seat the buyer is being asked about, and what they have answered.
///
/// Two questions share one card. The first is the original: a seat that has
/// just been tapped is already in the runtime's `selection` — and therefore in
/// the cart, the ticket count and the total — while the native card is still
/// asking whether the buyer wants it, so everything a buyer reads as a
/// commitment is counted from [confirmedCartLines] rather than from the raw
/// snapshot.
///
/// The second is its mirror, and it exists because the answer used to be taken
/// without asking: a second tap on a seat already in the cart dropped it in
/// silence — the ring went, the cart emptied, and nothing said so or offered
/// the seat back. A runtime speaking `seat.retap` keeps the seat selected and
/// reports the tap instead, and [seatAwaitingRemoval] is what the chrome reads
/// to raise the same card asking the opposite question.
///
/// A mixin rather than a plain block of the controller so the two questions,
/// their state and the rules that clear them are readable in one place.
mixin _PickerSeatAnswers on ValueNotifier<SeatLayerPickerState> {
  /// The session's options, owned by the controller this is mixed into.
  SeatLayerPickerOptions get _options;

  /// Whether the controller has been disposed.
  bool get _disposed;

  /// This controller, for the commands that live in extensions of it.
  ///
  /// `picker.setSelectionFocus` is one of those: the controller file is at its
  /// line cap, so the command lives in `picker_selection_focus.dart` and is
  /// reached from here the way a caller outside the SDK would reach it.
  SeatLayerPickerController get _controller;

  /// Labels the buyer has decided about, either way.
  final Set<String> _confirmedLabels = <String>{};

  /// The seat an open confirm card is asking to ADD.
  SelectedSeat? _confirmCardSeat;

  /// The seat an open confirm card is asking to REMOVE.
  SelectedSeat? _retapSeat;

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
  void setConfirmCardSeat(SelectedSeat? seat) {
    _confirmCardSeat = seat;
    _syncSelectionFocus();
  }

  /// Record that the buyer answered for [label], and take its card down.
  ///
  /// Either question: a seat that has just been added is answered for, and so
  /// is one that has just been taken back out.
  @internal
  void markSeatAnswered(String label) {
    final answered = _confirmedLabels.add(label);
    final retapped = _retapSeat?.label == label;
    if (_disposed || !(answered || retapped)) return;
    if (_confirmCardSeat?.label == label) _confirmCardSeat = null;
    if (retapped) _retapSeat = null;
    _syncSelectionFocus();
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
  /// The seat the buyer has tapped a second time, still in their cart.
  ///
  /// Set by a `seat.retap` bridge event, which a runtime sends INSTEAD of
  /// dropping the seat: the seat is still selected when this arrives, and no
  /// `selection.changed` comes with it. The chrome raises the confirm card in
  /// its remove state over this seat; the seat stays in the cart, and stays
  /// counted, until the buyer actually answers.
  ///
  /// Cleared when the seat leaves the selection, when the buyer answers for
  /// it, and by a retap of a different seat — one card, one question.
  SelectedSeat? get seatAwaitingRemoval => _retapSeat;

  /// Take a `seat.retap` event off the bridge.
  ///
  /// A retap of the seat an ADD card is already open about is ignored: that
  /// card is asking about this very seat, and turning its own question round
  /// under the buyer's finger would be a worse surprise than the silence this
  /// replaces.
  void _applyRetap(Object? payload) {
    if (_disposed || _options.readOnly) return;
    final seat = SelectedSeat.fromJson(jGet(payload, 'seat'));
    if (seat == null || seat.label == _confirmCardSeat?.label) return;
    if (_retapSeat?.label == seat.label && _retapSeat == seat) return;
    _retapSeat = seat;
    _syncSelectionFocus();
    notifyListeners();
  }

  /// Put the remove question away without answering it.
  ///
  /// Cancel and the tap outside both land here: neither is an instruction to
  /// give the seat back, and a stray press on the map must never be the thing
  /// that empties someone's cart.
  @internal
  void dismissSeatRemoval() {
    if (_disposed || _retapSeat == null) return;
    _retapSeat = null;
    _syncSelectionFocus();
    notifyListeners();
  }

  /// Keep both questions honest against the selection the runtime reports.
  ///
  /// A seat that left the selection takes its answer with it, so re-picking it
  /// asks again rather than joining the cart silently — and a seat that is no
  /// longer there cannot be the one a remove card is asking about.
  void _syncSeatAnswers(Set<String> live) {
    final focused = _confirmCardSeat ?? _retapSeat;
    _confirmedLabels.removeWhere((label) => !live.contains(label));
    if (_confirmCardSeat != null && !live.contains(_confirmCardSeat!.label)) {
      _confirmCardSeat = null;
    }
    if (_retapSeat != null && !live.contains(_retapSeat!.label)) {
      _retapSeat = null;
    }
    // The runtime drops its own candidate when that seat leaves the selection,
    // so mirror the clear rather than sending a command telling it to repeat
    // what it has already done. Whatever card is left standing is then focused
    // normally — a seat lost from under an add card can still leave a remove
    // card up over a different one.
    if (focused != null &&
        focused.id == _focusedSeatId &&
        !live.contains(focused.label)) {
      _focusedSeatId = null;
    }
    _syncSelectionFocus();
  }

  /// The seat id the runtime is currently painting as the candidate.
  String? _focusedSeatId;

  /// Keep the runtime's candidate paint on the seat a card is asking about.
  ///
  /// Both questions focus: an add card and a remove card are each standing
  /// over one seat the buyer has to find on the map behind them. Whichever is
  /// up wins, and there is only ever one — the layout raises the remove card
  /// only when no seat is waiting to be added.
  ///
  /// Nothing is sent when the answer has not moved. [setConfirmCardSeat] is
  /// called from the chrome's build, so without that this would send a command
  /// on every frame the picker draws.
  ///
  /// Sent from a microtask rather than inline, for the same reason: the send
  /// publishes state, and a controller that notified its listeners from inside
  /// a build would be rebuilding them mid-frame.
  void _syncSelectionFocus() {
    final next = _disposed ? null : (_confirmCardSeat ?? _retapSeat)?.id;
    if (next == _focusedSeatId) return;
    _focusedSeatId = next;
    if (_disposed) return;
    scheduleMicrotask(() {
      // A later change has already claimed the paint, or the picker is gone.
      if (_disposed || _focusedSeatId != next) return;
      if (value.phase == SeatLayerPickerPhase.closed) return;
      unawaited(_controller.setSelectionFocus(next));
    });
  }

  /// Forget which seat the runtime is painting, without repainting it.
  ///
  /// The picker is closing or the runtime is being destroyed: there is nothing
  /// left to paint on, and a command sent into a bridge that is being torn
  /// down would fail where the buyer could do nothing about it. The runtime
  /// drops the candidate with the session anyway.
  @internal
  void forgetSelectionFocus() => _focusedSeatId = null;
}
