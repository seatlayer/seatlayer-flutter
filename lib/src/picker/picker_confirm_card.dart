import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_a11y.dart';
import 'picker_haptics.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_strings.dart';
import 'picker_styles.dart';
import 'picker_motion.dart';
import 'picker_ticket_tiers.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

part 'picker_confirm_card_parts.dart';
part 'picker_confirm_card_actions.dart';
part 'picker_confirm_card_placement.dart';

/// The phone's one-seat decision surface.
///
/// A buyer who has just tapped a seat is answering one question — this seat,
/// this price, yes or no — so the card is read top to bottom as that question:
/// where the seat is, what it costs, what it looks like from there, and then
/// the two answers.
///
/// Where it is comes first as a grid rather than a sentence. `Gallery · Row A ·
/// Seat 1` reads as one long label a buyer has to parse; three labelled cells —
/// section, row, seat — let the eye land on the number it came for. The
/// category and the price share the band under it, tinted in the category's own
/// colour, which is the same colour the seat is painted on the map.
///
/// Everything comes from the scope, so this works standalone inside a
/// [SeatLayerPickerScope].
class SeatLayerConfirmCard extends StatefulWidget {
  /// Creates a confirm card for [seat], or for the latest selected seat.
  const SeatLayerConfirmCard({
    super.key,
    this.seat,
    this.onConfirm,
    this.onCancel,
    this.onViewFromSeat,
    this.onShow3D,
    this.showSeatView = true,
    this.show3D = true,
    this.style,
  });

  /// The seat being decided on; defaults to the most recent selection.
  final SelectedSeat? seat;

  /// Called after the buyer accepts the seat.
  final FutureOr<void> Function(SelectedSeat seat)? onConfirm;

  /// Called instead of removing the seat when the buyer cancels.
  final FutureOr<void> Function(SelectedSeat seat)? onCancel;

  /// Replaces the SDK's view-from-seat action.
  final FutureOr<void> Function(SelectedSeat seat)? onViewFromSeat;

  /// Replaces the SDK's venue-3D action.
  final FutureOr<void> Function(SelectedSeat seat)? onShow3D;

  /// Whether the capability-gated view-from-seat pill may be shown.
  final bool showSeatView;

  /// Whether the capability-gated 3D pill may be shown.
  final bool show3D;

  /// Overrides [SeatLayerPickerStyles.confirmCardStyle] for this card.
  final SeatLayerSurfaceStyle? style;

  @override
  State<SeatLayerConfirmCard> createState() => _SeatLayerConfirmCardState();
}

class _SeatLayerConfirmCardState extends State<SeatLayerConfirmCard> {
  String? _seatKey;
  String? _tierId;
  String? _dismissedLabel;

  /// Whether the buyer has found this card yet.
  ///
  /// The invitation — one highlight across `Add seat`, then a slow breath that
  /// keeps going for as long as the card goes unanswered — exists to say where
  /// the answer is. A buyer whose finger is on the card, or whose keyboard
  /// focus is on the button, has found it, so the first pointer down anywhere
  /// on the card or focus on `Add seat` ends the invitation for good.
  bool _touched = false;

  /// The buyer has found the answer; stop pointing at it.
  void _endInvite() {
    if (!_touched) setState(() => _touched = true);
  }

  /// Whether the press has been committed and the button now says "Added".
  bool _added = false;

  /// How far down the buyer has pushed the card, in logical points.
  ///
  /// Positive is towards the map's bottom edge, which is the direction the
  /// card leaves in. Reset whenever the card is asking about a new seat.
  double _drag = 0;

  /// Whether an answer is already on its way, so a second one is ignored.
  ///
  /// A swipe that ends past the threshold and a tap on `Cancel` are two ways
  /// to say the same thing, and a fling can land in the same frame as a tap.
  bool _answering = false;

  @override
  void didUpdateWidget(covariant SeatLayerConfirmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seat?.label != widget.seat?.label) {
      _seatKey = null;
      _tierId = widget.seat?.tierId;
      _dismissedLabel = null;
      _touched = false;
      _added = false;
      _drag = 0;
      _answering = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (SeatLayerPickerScope.optionsOf(context).readOnly) {
      return const SizedBox.shrink();
    }
    final selection = controller.state.selection;
    final seat = widget.seat ?? (selection.isEmpty ? null : selection.last);
    final map = controller.state.snapshot?.map;
    // The panorama is the seat's own view: it answers the same question this
    // card asks, so the card stands down for it. The 3D venue does not — the
    // buyer is still looking at a seat from outside it — so the card comes
    // back there, in its own dimensions, as soon as the seat is tapped — the
    // scene is already moving toward it, and the web card does not wait.
    final panoramaUp = controller.seatView?.hasContent == true;
    final immersive = !panoramaUp && (map?.isVenue3D ?? false);
    if (seat == null || panoramaUp) return const SizedBox.shrink();
    final seatKey = '${seat.id}\u0000${seat.label}';
    if (_seatKey != seatKey) {
      _seatKey = seatKey;
      _tierId = seat.tierId ?? seat.tiers?.firstOrNull?.id;
      _dismissedLabel = null;
      _touched = false;
      _added = false;
      _drag = 0;
      _answering = false;
      _announceArrival(controller);
    }
    if (seat.label == _dismissedLabel) return const SizedBox.shrink();
    _tierId ??= seat.tierId ?? seat.tiers?.firstOrNull?.id;

    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final layout = theme.layout;
    final options = SeatLayerPickerScope.optionsOf(context);
    final capabilities =
        controller.state.snapshot?.capabilities ?? const <String>{};
    final category = controller.state.categories
        .where((item) => item.key == seat.categoryKey)
        .firstOrNull;
    final tiers = seat.tiers ?? const <CategoryTier>[];
    final selectedPrice = seatLayerPickerSelectedPrice(seat, _tierId);
    final selectedCurrency = seatLayerPickerSelectedCurrency(seat, _tierId);

    final seatView = widget.showSeatView &&
            options.enableSeatView &&
            capabilities.contains('seatView')
        ? widget.onViewFromSeat ?? controller.openSeatView
        : null;
    final venue3D =
        widget.show3D && options.enable3D && capabilities.contains('venue3d')
            ? widget.onShow3D ?? controller.showSeatIn3D
            : null;
    final cardStyle =
        (theme.styles.confirmCardStyle ?? const SeatLayerSurfaceStyle())
            .merge(widget.style);

    final categoryColor = pickerColor(category?.color) ?? theme.accent;
    final invite = !_touched && !SeatLayerPickerMotion.reduced(context);

    // What the organizer has said about this particular seat, in the order a
    // buyer needs it: the badge that raises the price, then the warning that
    // lowers it, then whatever else was written about it.
    final commercial = seat.commercial;
    final premium = commercial?.premium ?? false;
    // Restricted wins over obstructed: two words for the same disappointment
    // is one word too many, and the stronger of the pair is the honest one.
    final viewNotice = commercial?.restrictedView == true
        ? strings.restrictedView
        : commercial?.obstructedView == true
            ? strings.obstructedView
            : null;
    final note = commercial?.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    // A lone tier is guidance, never a fieldset: an exclusive choice between
    // one option is not a choice, and drawing it as one asks for a decision
    // the buyer cannot make.
    final loneTierNote =
        tiers.length == 1 ? tiers.first.buyerMessage?.trim() : null;
    final bodyContent = tiers.length > 1 ||
        premium ||
        viewNotice != null ||
        hasNote ||
        (loneTierNote?.isNotEmpty ?? false);
    // A booth, a table or a general-admission area is not a seat, and the
    // button must not call it one.
    final addLabel =
        seat.objectType == null || seat.objectType == ObjectType.seat
            ? strings.addSeat
            : strings.select;
    // In the scene the venue is already the picture, so a photo strip has
    // nothing left to stand in for: the one place the buyer has not looked
    // from is the seat itself, and that becomes the card's inspection row.
    final inspectUp = immersive && seatView != null;

    // Everything the card is about, as one sentence. A screen reader that
    // walked the drawn card would hear six unlabelled cells — a name, two
    // numbers, a colour swatch, a word and an amount — in the order they are
    // painted. The card is a dialog, so it is NAMED, and the name is the
    // question it is asking: this seat, this category, this price.
    final spokenIdentity = strings.seatIdentity(<String>[
      if (seat.sectionLabel?.trim().isNotEmpty ?? false)
        seat.sectionLabel!.trim(),
      if (seat.rowLabel?.trim().isNotEmpty ?? false)
        '${_IdentityGrid._rowWord(seat, strings)} '
            '${seat.rowLabel!.trim()}',
      '${_IdentityGrid._seatWord(seat, strings)} ${seat.buyerFacingLabel}',
      if (category != null) category.label,
      if (selectedPrice != null)
        pickerMoney(context, selectedPrice, selectedCurrency),
    ]);
    final busy = controller.state.isBusy;
    // The card sizes itself to its content and to the screen less one gutter
    // on each side; whoever places it decides where on the map it sits.
    return Semantics(
      // A dialog, in every sense a native platform has one: it names itself,
      // it owns the focus while it is up, and the map behind it is hidden
      // (the composition's own BlockSemantics does that half).
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: spokenIdentity,
      // Both answers, reachable without hunting for the buttons. A rotor
      // action is how a screen-reader buyer says yes or no to a card they
      // have just been read.
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        CustomSemanticsAction(label: addLabel): () {
          if (!busy) ignorePickerAction(_confirm(controller, seat));
        },
        CustomSemanticsAction(label: strings.cancel): () {
          if (!busy) ignorePickerAction(_cancel(controller, seat));
        },
      },
      child: SeatLayerTypeScale.card(
        child: FocusTraversalGroup(
          // Add seat first, Cancel second: the focus lands on the answer the
          // card exists to collect, not on the way out of it. Drawn order is
          // the other way round — Cancel is the narrow box on the left — and
          // the two orders are allowed to disagree.
          policy: OrderedTraversalPolicy(),
          child: FocusScope(
            autofocus: true,
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: layout.confirmCardGutter),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // The scene gives the card its own width: there is no map legend
                    // to read around it, and the seat's own name is longer once the
                    // buyer is inside the venue looking at it.
                    maxWidth: immersive
                        ? SeatLayerSizeTokens.confirmCardImmersiveMaxWidth
                        : layout.confirmCardMaxWidth,
                    maxHeight: MediaQuery.sizeOf(context).height * .72,
                  ),
                  child: Listener(
                    onPointerDown: (_) => _endInvite(),
                    // Pushing the card down is the third answer, and the one a thumb
                    // reaches first. It follows the finger exactly as far as the
                    // threshold and then goes stiff, so the resistance itself says
                    // the card is already far enough to let go of. The follow is
                    // direct manipulation rather than decoration, so reduced motion
                    // leaves it alone — what it does drop is the theatre after it.
                    child: GestureDetector(
                      onVerticalDragUpdate: controller.state.isBusy
                          ? null
                          : (details) =>
                              setState(() => _drag += details.delta.dy),
                      onVerticalDragEnd: controller.state.isBusy
                          ? null
                          : (details) => _settleDrag(
                                controller,
                                seat,
                                (details.primaryVelocity ?? 0).toDouble(),
                              ),
                      child: Transform.translate(
                        offset: Offset(0, _rubberBand(_drag)),
                        child: _CardSurface(
                          style: cardStyle,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _IdentityGrid(seat: seat, immersive: immersive),
                              // The band is the category speaking for itself: its
                              // colour, its name, how much of it is left, and what it
                              // costs. Without a category there is nothing for it to
                              // say, and a price with no name beside it belongs
                              // nowhere on this card.
                              if (category != null)
                                _CategoryBand(
                                  category: category,
                                  color: categoryColor,
                                  price: selectedPrice,
                                  currency: selectedCurrency,
                                ),
                              // The picture is what `View from here` opens, so the
                              // strip is drawn full-bleed only where that action
                              // exists; 3D rides its far corner. With 3D alone there
                              // is no picture to stand in for, so the pills sit on a
                              // plain rail instead of in an empty frame.
                              if (!immersive && seatView != null)
                                _PhotoStrip(
                                  onViewFromSeat: controller.state.isBusy
                                      ? null
                                      : () => _inspect(seat, seatView),
                                  onShow3D:
                                      venue3D == null || controller.state.isBusy
                                          ? null
                                          : () => _inspect(seat, venue3D),
                                )
                              else if (!immersive && venue3D != null)
                                _ActionRail(
                                  onShow3D: controller.state.isBusy
                                      ? null
                                      : () => _inspect(seat, venue3D),
                                ),
                              if (bodyContent)
                                Flexible(
                                  child: SingleChildScrollView(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 10, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (tiers.length > 1)
                                          _TierPicker(
                                            tiers: tiers,
                                            currency: seat.currency ?? 'USD',
                                            selectedId: _tierId,
                                            enabled: !controller.state.isBusy,
                                            onSelected: (id) =>
                                                setState(() => _tierId = id),
                                          )
                                        else if (loneTierNote != null &&
                                            loneTierNote.isNotEmpty)
                                          _TierNote(note: loneTierNote),
                                        if (premium ||
                                            viewNotice != null ||
                                            hasNote)
                                          _SeatNotices(
                                            premium: premium,
                                            viewNotice: viewNotice,
                                            note: hasNote ? note : null,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (inspectUp)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10,
                                    bodyContent
                                        ? SeatLayerSizeTokens
                                            .confirmImmersiveInspectGap
                                        : SeatLayerSizeTokens
                                                .confirmImmersiveBodyTop +
                                            SeatLayerSizeTokens
                                                .confirmImmersiveInspectGap,
                                    10,
                                    0,
                                  ),
                                  child: _InspectionRow(
                                    onViewFromSeat: controller.state.isBusy
                                        ? null
                                        : () => _inspect(seat, seatView),
                                  ),
                                ),
                              // The two answers are boxes of their own inside the
                              // card's gutter, not a bar fused to its bottom edge: a
                              // corner-to-corner fill reads as the card's frame, not
                              // as a thing to press.
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  10,
                                  immersive
                                      ? (bodyContent || inspectUp
                                          ? SeatLayerSizeTokens
                                              .confirmImmersiveActionGap
                                          : SeatLayerSizeTokens
                                              .confirmImmersiveBodyTop)
                                      : (bodyContent ? 10 : 8),
                                  10,
                                  immersive
                                      ? SeatLayerSizeTokens
                                          .confirmImmersiveBodyBottom
                                      : 10,
                                ),
                                child: SizedBox(
                                  // Forty-four points of answer at the
                                  // platform's default, and proportionally
                                  // more once the buyer has scaled their text
                                  // up: a fixed box would clip the word the
                                  // whole card exists to offer. It stays a
                                  // HEIGHT rather than a minimum because the
                                  // button paints its arrival sweep in a
                                  // Stack, which has no intrinsic height.
                                  height: seatLayerScaledExtent(
                                    context,
                                    layout.confirmActionHeight,
                                    max: SeatLayerTypeScaleTokens.card,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) => Row(
                                      children: [
                                        // Just over a third to leave, the rest to
                                        // accept: the two answers are not equally
                                        // likely, and the card should not pretend
                                        // that they are.
                                        FocusTraversalOrder(
                                          order: const NumericFocusOrder(2),
                                          child: SizedBox(
                                            width: constraints.maxWidth *
                                                _cancelShare,
                                            child: _CancelButton(
                                              label: strings.cancel,
                                              style: theme
                                                  .styles.secondaryButtonStyle,
                                              onPressed: controller.state.isBusy
                                                  ? null
                                                  : () =>
                                                      _cancel(controller, seat),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: FocusTraversalOrder(
                                            order: const NumericFocusOrder(1),
                                            child: _AddSeatButton(
                                              label: _added
                                                  ? strings.added
                                                  : addLabel,
                                              added: _added,
                                              invite: invite,
                                              onInviteEnd: _endInvite,
                                              style: theme
                                                  .styles.primaryButtonStyle,
                                              onPressed: controller.state.isBusy
                                                  ? null
                                                  : () => _confirm(
                                                      controller, seat),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _dismiss(SelectedSeat seat) {
    if (mounted) setState(() => _dismissedLabel = seat.label);
  }

  /// A light cue the first time this card asks about a seat.
  ///
  /// Fired after the frame that put it on screen rather than during it: a
  /// build is not the place for a side effect, and a card that buzzes before
  /// it is drawn is answering a tap the buyer cannot see the result of yet.
  void _announceArrival(SeatLayerPickerController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.emitHaptic(PickerHapticCue.cardArrived);
    });
  }

  /// How far the card actually moves when it has been pushed [drag] points.
  ///
  /// One to one until the card is far enough down to let go of, and a third
  /// of that afterwards. Upward it barely moves at all: there is nothing above
  /// the card to drag it towards.
  static double _rubberBand(double drag) {
    if (drag <= 0) return drag / 6;
    if (drag <= _dismissDrag) return drag;
    return _dismissDrag + ((drag - _dismissDrag) / 3);
  }

  /// The buyer let go: either the card leaves, or it springs back.
  void _settleDrag(
    SeatLayerPickerController controller,
    SelectedSeat seat,
    double velocity,
  ) {
    if (_drag >= _dismissDrag || velocity >= _dismissVelocity) {
      unawaited(_cancel(controller, seat));
      return;
    }
    setState(() => _drag = 0);
  }

  Future<void> _confirm(
    SeatLayerPickerController controller,
    SelectedSeat seat,
  ) async {
    if (_answering) return;
    _answering = true;
    // The tap that put the seat on the map earned the policy's light click;
    // this is a different moment and a heavier one, because it is the press
    // that decides what the buyer is going to pay for.
    controller.emitHaptic(PickerHapticCue.seatConfirmed);
    final origin = _cardCentre();
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    final reduced = SeatLayerPickerMotion.reduced(context);
    try {
      if (_tierId != null && _tierId != seat.tierId) {
        await controller.setSeatTier(seat.id, _tierId);
      }
      await widget.onConfirm?.call(seat);
      callbacks.onSeatSelected?.call(seat);
      if (!mounted) return;
      // The facts never wait for the picture: the ticket is in the cart and
      // the peek total has already changed by the time the button admits it.
      if (!reduced) {
        setState(() => _added = true);
        await Future<void>.delayed(SeatLayerPickerMotion.pressSweep);
        if (!mounted) return;
      }
      _flyToPeek(origin, seat, controller);
      _dismiss(seat);
    } catch (_) {
      // The controller keeps the typed failure in picker state for native UI.
      // The card stays, so the answer must be offerable again.
      _answering = false;
    }
  }

  Future<void> _inspect(
    SelectedSeat seat,
    FutureOr<void> Function(SelectedSeat seat) action,
  ) async {
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    try {
      await action(seat);
      // The card stays put until the runtime has actually mounted the
      // immersive surface: removing it first lets the tail of the same iOS
      // tap reach the WebView and select a seat underneath.
      callbacks.onSeatViewOpened?.call(seat);
    } catch (_) {
      // A controller-backed action already published a typed picker error.
    }
  }

  Future<void> _cancel(
    SeatLayerPickerController controller,
    SelectedSeat seat,
  ) async {
    if (_answering) return;
    _answering = true;
    // A tick, not an impact: giving a seat back is the buyer changing their
    // mind, and nothing about that is worth a thump.
    controller.emitHaptic(PickerHapticCue.cardCancelled);
    try {
      if (widget.onCancel != null) {
        await widget.onCancel!(seat);
      } else {
        await controller.removeObject(seat.label);
      }
      _dismiss(seat);
    } catch (_) {
      // The controller keeps the typed failure in picker state for native UI.
      _answering = false;
      if (mounted) setState(() => _drag = 0);
    }
  }

  Offset? _cardCentre() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  /// Send the seat itself from the card to the peek summary.
  ///
  /// A labelled chip in the category's own colour, not an anonymous dot: it
  /// says which ticket went where, which is the one thing a card that closes
  /// cannot say by closing. Skipped entirely under reduced motion — an
  /// indicator that appears and vanishes in the same frame is just a flicker.
  void _flyToPeek(
    Offset? from,
    SelectedSeat seat,
    SeatLayerPickerController controller,
  ) {
    if (from == null || SeatLayerPickerMotion.reduced(context)) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final screen = MediaQuery.sizeOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final category = controller.state.categories
        .where((item) => item.key == seat.categoryKey)
        .firstOrNull;
    final to = Offset(screen.width / 2, screen.height - _peekAim);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingSeat(
        from: from,
        to: to,
        color: pickerColor(category?.color) ?? theme.accent,
        label: seat.buyerFacingLabel,
        fontFamily: theme.fontFamily,
        onDone: entry.remove,
      ),
    );
    overlay.insert(entry);
  }
}

/// How much of the decision row the quiet answer takes.
///
/// The web picker's `flex:0 0 34%`. Not a half, because the two answers are
/// not equally likely; not a third, because `Cancel` still has to read as a
/// button rather than as a margin.
const double _cancelShare = .34;

/// How far above the foot of the screen the flying chip aims.
///
/// The collapsed sheet's summary line is what the ticket has just changed, so
/// that is where the chip lands.
const double _peekAim = 24;

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
