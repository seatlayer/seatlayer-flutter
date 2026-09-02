import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_haptics.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_strings.dart';
import 'picker_styles.dart';
import 'picker_motion.dart';
import 'picker_ticket_tiers.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

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

  /// Whether the buyer has touched this card yet.
  ///
  /// The invitation — one highlight across `Add seat`, then a slow breath —
  /// exists to say where the answer is. A buyer whose finger is already on the
  /// card has found it, so the first pointer down anywhere on the card ends the
  /// invitation for good.
  bool _touched = false;

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
    final immersiveUp = controller.seatView?.hasContent == true ||
        (controller.state.snapshot?.map.isVenue3D ?? false);
    if (seat == null || immersiveUp) {
      return const SizedBox.shrink();
    }
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

    // The card sizes itself to its content and to the screen less one gutter
    // on each side; whoever places it decides where on the map it sits.
    return Align(
      alignment: Alignment.center,
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: layout.confirmCardGutter),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: layout.confirmCardMaxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: Listener(
            onPointerDown: (_) {
              if (!_touched) setState(() => _touched = true);
            },
            // Pushing the card down is the third answer, and the one a thumb
            // reaches first. It follows the finger exactly as far as the
            // threshold and then goes stiff, so the resistance itself says
            // the card is already far enough to let go of. The follow is
            // direct manipulation rather than decoration, so reduced motion
            // leaves it alone — what it does drop is the theatre after it.
            child: GestureDetector(
              onVerticalDragUpdate: controller.state.isBusy
                  ? null
                  : (details) => setState(() => _drag += details.delta.dy),
              onVerticalDragEnd: controller.state.isBusy
                  ? null
                  : (details) => _settleDrag(
                        controller,
                        seat,
                        (details.primaryVelocity ?? 0).toDouble(),
                      ),
              child: Transform.translate(
                offset: Offset(0, _rubberBand(_drag)),
                child: Material(
                  key: const ValueKey<String>('seatlayer.confirm-card.surface'),
                  color: cardStyle.color ?? theme.surface,
                  elevation: cardStyle.elevation ?? 18,
                  shadowColor: pickerAlpha(const Color(0xFF000000), .26),
                  shape: cardStyle.shape ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(theme.radius + 4),
                        side: BorderSide(color: pickerAlpha(theme.divider, .9)),
                      ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: layout.confirmIdentityHeight,
                        child: _IdentityGrid(seat: seat),
                      ),
                      // The band is the category speaking for itself: its
                      // colour, its name, how much of it is left, and what it
                      // costs. Without a category there is nothing for it to
                      // say, and a price with no name beside it belongs
                      // nowhere on this card.
                      if (category != null)
                        SizedBox(
                          height: layout.confirmBandHeight,
                          child: _CategoryBand(
                            category: category,
                            color: categoryColor,
                            price: selectedPrice,
                            currency: selectedCurrency,
                          ),
                        ),
                      // The gradient stands in for the photograph that
                      // `View from here` opens, so it is drawn only where
                      // that action exists.
                      if (seatView != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: layout.confirmPhotoHeight,
                          child: _PhotoStrip(
                            onViewFromSeat: controller.state.isBusy
                                ? null
                                : () => _inspect(seat, seatView),
                          ),
                        ),
                      ],
                      // 3D is a place to go, not a badge on a picture, so it
                      // is a full-width action of its own — legible, and big
                      // enough to hit — rather than a pill floating in an
                      // empty frame.
                      if (venue3D != null) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            height: layout.confirmActionHeight,
                            child: _SecondaryAction(
                              icon: Icons.view_in_ar_rounded,
                              label: strings.seeItIn3D,
                              onPressed: controller.state.isBusy
                                  ? null
                                  : () => _inspect(seat, venue3D),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(
                        height: seatView == null && venue3D == null ? 5 : 10,
                      ),
                      if (tiers.length > 1)
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final tier in tiers)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 7),
                                    child: SeatLayerPickerSeatTierChoice(
                                      tier: tier,
                                      currency: seat.currency ?? 'USD',
                                      selected: _tierId == tier.id,
                                      enabled: !controller.state.isBusy,
                                      onTap: () =>
                                          setState(() => _tierId = tier.id),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: layout.confirmActionHeight,
                        child: Row(
                          children: [
                            // One third to leave, two thirds to accept: the
                            // two answers are not equally likely, and the
                            // card should not pretend that they are.
                            Expanded(
                              child: _CancelButton(
                                label: strings.cancel,
                                style: theme.styles.secondaryButtonStyle,
                                onPressed: controller.state.isBusy
                                    ? null
                                    : () => _cancel(controller, seat),
                              ),
                            ),
                            const SizedBox(width: 1),
                            Expanded(
                              flex: 2,
                              child: _AddSeatButton(
                                label: _added ? strings.added : strings.addSeat,
                                added: _added,
                                invite: invite,
                                style: theme.styles.primaryButtonStyle,
                                onPressed: controller.state.isBusy
                                    ? null
                                    : () => _confirm(controller, seat),
                              ),
                            ),
                          ],
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
      _flyToPeek(origin);
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

  /// Send a small dot from the card to the peek bar.
  ///
  /// It says where the ticket went, which is the one thing a card that closes
  /// cannot say by closing. Skipped entirely under reduced motion — an
  /// indicator that appears and vanishes in the same frame is just a flicker.
  void _flyToPeek(Offset? from) {
    if (from == null || SeatLayerPickerMotion.reduced(context)) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final screen = MediaQuery.sizeOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final to = Offset(screen.width / 2, screen.height - 24);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingDot(
        from: from,
        to: to,
        color: theme.accent,
        onDone: entry.remove,
      ),
    );
    overlay.insert(entry);
  }
}

/// Where the seat is, as labelled cells rather than one long sentence.
///
/// Section, row and seat each get their own cell with a small eyebrow over the
/// value, so the buyer checking a row letter reads one word instead of parsing
/// `Gallery · Row A · Seat 1`. The section takes whatever the other two leave,
/// because it is the only one of the three that is ever a real name; with no
/// section to show, the remaining cells share the width evenly.
///
/// A screen reader still hears the sentence: the grid is one semantics node
/// carrying the same identity the rest of the picker reads out.
class _IdentityGrid extends StatelessWidget {
  const _IdentityGrid({required this.seat});

  final SelectedSeat seat;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final section = seat.sectionLabel?.trim() ?? '';
    final row = pickerRowLabel(
      seat.rowLabel,
      seat.sectionLabel,
      sectionCode: pickerSectionCode(
        SeatLayerPickerScope.stateOf(context),
        seat.sectionLabel,
      ),
    );
    final number = seat.seatNumber?.trim().isNotEmpty ?? false
        ? seat.seatNumber!.trim()
        : seat.buyerFacingLabel;
    final rowWord = _rowWord(seat, strings);
    final seatWord = _seatWord(seat, strings);
    final cells = <(String, String)>[
      if (section.isNotEmpty) (strings.sectionWord, section),
      if (row.isNotEmpty) (rowWord, row),
      (seatWord, number),
    ];
    final children = <Widget>[];
    for (var index = 0; index < cells.length; index++) {
      if (index > 0) {
        children.add(
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: pickerAlpha(theme.divider, .9),
          ),
        );
      }
      final cell = _cell(context, cells[index].$1, cells[index].$2);
      children.add(
        section.isEmpty || index == 0
            ? Expanded(child: cell)
            : ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 54, maxWidth: 120),
                child: cell,
              ),
      );
    }
    return Semantics(
      container: true,
      label: strings.seatIdentity(<String>[
        if (section.isNotEmpty) section,
        if (row.isNotEmpty) '$rowWord $row',
        '$seatWord $number',
      ]),
      child: ExcludeSemantics(child: Row(children: children)),
    );
  }

  Widget _cell(BuildContext context, String eyebrow, String value) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10,
              height: 1.2,
              letterSpacing: .8,
              fontWeight: FontWeight.w800,
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.text,
              fontSize: 18,
              height: 1.1,
              fontWeight: FontWeight.w800,
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  /// What the chart calls a row, where it called it anything.
  static String _rowWord(SelectedSeat seat, SeatLayerPickerStrings strings) =>
      seat.displayType?.trim().isNotEmpty ?? false
          ? seat.displayType!.trim()
          : seat.rowType?.trim().isNotEmpty ?? false
              ? seat.rowType!.trim()
              : strings.rowWord;

  static String _seatWord(SelectedSeat seat, SeatLayerPickerStrings strings) =>
      seat.objectType == ObjectType.booth
          ? strings.placeWord
          : strings.seatWord;
}

/// How far down the card has to be pushed before letting go cancels.
///
/// Far enough that a thumb resting on the card while the map settles cannot
/// reach it, and short enough to be one comfortable flick.
const double _dismissDrag = 72;

/// A downward flick this fast cancels however short it was.
///
/// Points per second. A deliberate flick clears it easily; the drift at the
/// end of a slow, reconsidered drag does not.
const double _dismissVelocity = 700;

/// How few is few enough to say so.
///
/// A round dozen, chosen because it is the point where the number stops
/// describing a section and starts describing the buyer's odds: above it the
/// count is inventory, below it the count is a queue. Pressure the buyer can
/// check against the map is honest; pressure at forty seats is not.
const int _scarceRemaining = 12;

/// The category, in the category's own colour, and what it costs.
///
/// The map is already painted in these colours, so the band is the one place
/// on the card where naming the category earns its line: the buyer matches the
/// tint to the seat they just tapped. The price lives here rather than on the
/// button, where it would be the same number the cart is about to say.
class _CategoryBand extends StatelessWidget {
  const _CategoryBand({
    required this.category,
    required this.color,
    required this.price,
    required this.currency,
  });

  final SeatLayerPickerCategory category;
  final Color color;
  final double? price;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    // Below the threshold the count stops being a fact about the category and
    // becomes a reason to answer now, so it says so and takes the warning ink.
    // Zero is not scarcity: a category with nothing left cannot be the one the
    // buyer just tapped a seat in, and "Only 0 left" would be nonsense.
    final scarce =
        category.available > 0 && category.available <= _scarceRemaining;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(pickerAlpha(color, .11), theme.surface),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 3,
            height: double.infinity,
            child: ColoredBox(color: color),
          ),
          const SizedBox(width: 9),
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 6),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
                // How much of this category is left, where availability knows.
                if (category.available > 0) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      scarce
                          ? strings.onlyLeft(category.available)
                          : strings.seatsLeft(category.available),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scarce ? theme.warning : theme.mutedText,
                        fontSize: 12,
                        fontWeight: scarce ? FontWeight.w800 : FontWeight.w600,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (price != null) ...[
            const SizedBox(width: 10),
            Text(
              pickerMoney(context, price!, currency),
              softWrap: false,
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: theme.fontFamily,
              ),
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// The seat photograph's stand-in, with the way into it.
///
/// The snapshot carries no seat-view image URL, so the strip renders a neutral
/// gradient wherever `View from here` is offered, and the pill rides its
/// top-right corner the way a control on a photograph does. Without that
/// action there is no picture to stand in for and the strip is not drawn.
class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.onViewFromSeat});

  final VoidCallback? onViewFromSeat;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(pickerAlpha(theme.accent, .22), theme.surface),
            Color.alphaBlend(pickerAlpha(theme.text, .12), theme.surface),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.topRight,
          child: _StripAction(
            icon: Icons.visibility_outlined,
            label: strings.viewFromHere,
            onPressed: onViewFromSeat,
          ),
        ),
      ),
    );
  }
}

class _StripAction extends StatelessWidget {
  const _StripAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final pill = theme.styles.pillStyle ?? const SeatLayerSurfaceStyle();
    return Material(
      // A near-opaque surface pill lifts off the photograph underneath it.
      color: pill.color ?? pickerAlpha(theme.surface, .92),
      elevation: pill.elevation ?? 0,
      // `View from here` is an action, not a chip, so it carries the button
      // radius rather than the chip's stadium.
      shape: pill.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.buttonRadius),
          ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: theme.text),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A full-width, quietly tinted action on the card's own surface.
class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final ink =
        onPressed == null ? pickerAlpha(theme.mutedText, .58) : theme.text;
    return Material(
      color: Color.alphaBlend(pickerAlpha(theme.text, .06), theme.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.buttonRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The card's quiet answer: no fill, so it never competes with `Add seat`.
class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.label,
    required this.onPressed,
    this.style,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final disabled = onPressed == null;
    final styledGround = seatLayerStyleRole(
      style?.backgroundColor,
      disabled: disabled,
    );
    final styledInk =
        seatLayerStyleRole(style?.foregroundColor, disabled: disabled);
    return Material(
      color: styledGround ?? const Color(0x00000000),
      shape: seatLayerStyleRole(style?.shape),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: styledInk ?? pickerAlpha(theme.text, disabled ? .34 : .8),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: theme.fontFamily,
            ).merge(seatLayerStyleRole(style?.textStyle)),
          ),
        ),
      ),
    );
  }
}

/// How many breaths the invitation takes before it rests.
///
/// Bounded on purpose. An animation with no end is movement in the corner of
/// the eye for as long as the buyer hesitates, and a card that will not stop
/// moving reads as a card that has not finished loading.
const int _inviteBreaths = 3;

/// The card's recommended answer, and the small theatre around it.
///
/// Three things happen here, and each says something the still button cannot.
/// On arrival one highlight crosses it: this is the thing to press. While it
/// waits it breathes, slowly, three times: the offer is still open. On the
/// press its own ink fills from the left under a drawn check and the word
/// turns to "Added": the ticket is in the cart. Only the last of the three is
/// about the buyer's own action, and the ticket was counted before the sweep
/// started — this is a receipt, not a progress bar.
class _AddSeatButton extends StatefulWidget {
  const _AddSeatButton({
    required this.label,
    required this.added,
    required this.invite,
    required this.onPressed,
    this.style,
  });

  final String label;

  /// Whether the press has been committed and the button is now a receipt.
  final bool added;

  /// Whether the arrival highlight and the breath play at all.
  final bool invite;

  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  State<_AddSeatButton> createState() => _AddSeatButtonState();
}

class _AddSeatButtonState extends State<_AddSeatButton>
    with TickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.inviteSweep,
  );
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.inviteBreathe * _inviteBreaths,
  );
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.pressSweep,
  );

  @override
  void initState() {
    super.initState();
    if (widget.invite) {
      _sweep.forward().whenComplete(() {
        if (mounted && widget.invite && !widget.added) _breathe.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _AddSeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.invite && oldWidget.invite) {
      _sweep.stop();
      _breathe.stop();
    }
    if (widget.added && !oldWidget.added) {
      _sweep.stop();
      _breathe.stop();
      _press.forward();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _breathe.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final disabled = widget.onPressed == null;
    final styledGround = seatLayerStyleRole(
      widget.style?.backgroundColor,
      disabled: disabled,
    );
    final styledInk =
        seatLayerStyleRole(widget.style?.foregroundColor, disabled: disabled);
    final ground = styledGround ??
        (disabled
            ? Color.alphaBlend(pickerAlpha(theme.mutedText, .16), theme.surface)
            : theme.accent);
    final ink = styledInk ??
        (disabled ? pickerAlpha(theme.mutedText, .58) : theme.onAccent);
    return Material(
      color: ground,
      shape: seatLayerStyleRole(widget.style?.shape),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_sweep, _breathe, _press]),
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: CustomPaint(
                painter: _AddSeatFinish(
                  ink: ink,
                  sweep: _sweep.value,
                  breathe: _breathe.value,
                  press: _press.value,
                ),
              ),
            ),
            InkWell(
              onTap: widget.onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The check is drawn rather than swapped in: it grows out
                    // of the press it is answering.
                    Transform.scale(
                      scale: widget.added ? _checkScale : 1,
                      child: Icon(Icons.check_rounded, size: 16, color: ink),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: theme.fontFamily,
                        ).merge(seatLayerStyleRole(widget.style?.textStyle)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _checkScale =>
      .7 +
      (.3 * Curves.easeOutBack.transform((_press.value * 1.6).clamp(0.0, 1.0)));
}

/// Everything painted over `Add seat`: the arrival highlight, the breath, and
/// the press filling the button with its own ink from the left.
class _AddSeatFinish extends CustomPainter {
  const _AddSeatFinish({
    required this.ink,
    required this.sweep,
    required this.breathe,
    required this.press,
  });

  final Color ink;
  final double sweep;
  final double breathe;
  final double press;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (press > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * press, size.height),
        Paint()..color = pickerAlpha(ink, .18),
      );
    }
    if (breathe > 0 && breathe < 1) {
      final glow = (1 - math.cos(breathe * _inviteBreaths * 2 * math.pi)) / 2;
      canvas.drawRect(rect, Paint()..color = pickerAlpha(ink, .09 * glow));
    }
    if (sweep > 0 && sweep < 1) {
      final centre = (sweep * 3) - 1.5;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(centre - .7, 0),
            end: Alignment(centre + .7, 0),
            colors: <Color>[
              pickerAlpha(ink, 0),
              pickerAlpha(ink, .26),
              pickerAlpha(ink, 0),
            ],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_AddSeatFinish oldDelegate) =>
      oldDelegate.ink != ink ||
      oldDelegate.sweep != sweep ||
      oldDelegate.breathe != breathe ||
      oldDelegate.press != press;
}

class _FlyingDot extends StatefulWidget {
  const _FlyingDot({
    required this.from,
    required this.to,
    required this.color,
    required this.onDone,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final VoidCallback onDone;

  @override
  State<_FlyingDot> createState() => _FlyingDotState();
}

class _FlyingDotState extends State<_FlyingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.fly,
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_controller.value);
          final position = Offset.lerp(widget.from, widget.to, t)!;
          return Positioned(
            left: position.dx - 6,
            top: position.dy - 6,
            child: IgnorePointer(
              child: Opacity(
                opacity: 1 - (t * t),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 12),
                ),
              ),
            ),
          );
        },
      );
}

/// Which edge of the seat card points back at the seat, if any.
enum SeatLayerConfirmCardNotch {
  /// The card is centred and points at nothing: the runtime did not say where
  /// on the map the seat was drawn.
  none,

  /// The card sits above the seat, so it points down at it.
  bottom,

  /// The card sits below the seat, so it points up at it.
  top,
}

/// Where the seat card sits over the map, and which way it points.
@immutable
class SeatLayerConfirmCardPlacement {
  /// Creates a placement.
  const SeatLayerConfirmCardPlacement({required this.top, required this.notch});

  /// The card's own top edge, in the map surface's coordinates.
  final double top;

  /// Which edge carries the pointer, if the seat's place is known.
  final SeatLayerConfirmCardNotch notch;

  @override
  bool operator ==(Object other) =>
      other is SeatLayerConfirmCardPlacement &&
      other.top == top &&
      other.notch == notch;

  @override
  int get hashCode => Object.hash(top, notch);

  @override
  String toString() => 'SeatLayerConfirmCardPlacement($top, ${notch.name})';
}

/// The gap between the seat and the card's nearest edge.
const double seatLayerConfirmCardSeatGap = 12;

/// Where a card of [card] size belongs over a [area]-sized map.
///
/// The card wants to be near the seat without covering it, so it sits a
/// [seatLayerConfirmCardSeatGap] above the seat and points down. Where there
/// is not enough map above the seat for that — the seat is near the top, or
/// the card is tall — it goes the same distance below and points up instead.
/// With no [seat] it rests in the middle of whatever the chrome has left,
/// which is where every runtime before `seat-screen-point-v1` puts it.
///
/// [topInset] and [bottomInset] are the bands the picker's own chrome stands
/// on: the card must not slide under the floor strip or behind the dock, so
/// both cases are clamped into what is left even when the clamp costs the card
/// its gap. Pure, so the three cases are decided once and tested directly.
SeatLayerConfirmCardPlacement seatLayerConfirmCardPlacement({
  required Offset? seat,
  required Size card,
  required Size area,
  double topInset = 0,
  double bottomInset = 0,
  double gap = seatLayerConfirmCardSeatGap,
}) {
  final ceiling = topInset;
  final floor = area.height - bottomInset - card.height;
  // A card taller than the band it has to live in cannot be clamped into it;
  // pinning it to the top at least keeps its actions reachable.
  final lowest = math.max(ceiling, floor);
  if (seat == null) {
    // No seat to point at: rest at the foot of the map, the way the web card
    // does, so the map above stays the buyer's and the card reads as a sheet.
    return SeatLayerConfirmCardPlacement(
      top: lowest,
      notch: SeatLayerConfirmCardNotch.none,
    );
  }
  final above = seat.dy - gap - card.height;
  if (above >= ceiling) {
    return SeatLayerConfirmCardPlacement(
      top: math.min(above, lowest),
      notch: SeatLayerConfirmCardNotch.bottom,
    );
  }
  return SeatLayerConfirmCardPlacement(
    top: (seat.dy + gap).clamp(ceiling, lowest),
    notch: SeatLayerConfirmCardNotch.top,
  );
}

/// The pointer between the card and the seat it is about.
///
/// Drawn as part of the card rather than as a decoration on it: same surface,
/// same hairline, and the hairline is erased where the two meet so the notch
/// reads as the card's own edge pulled towards the seat.
class SeatLayerConfirmCardPointer extends StatelessWidget {
  /// Creates a pointer of [height] pointing [up] or down.
  const SeatLayerConfirmCardPointer({
    super.key,
    required this.up,
    this.height = 8,
    this.width = 18,
  });

  /// Whether the tip points towards the top of the screen.
  final bool up;

  /// How far the tip reaches out of the card.
  final double height;

  /// How wide the pointer's base is where it leaves the card.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _PointerPainter(
          up: up,
          surface: theme.surface,
          border: pickerAlpha(theme.divider, .9),
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({
    required this.up,
    required this.surface,
    required this.border,
  });

  final bool up;
  final Color surface;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    }
    canvas.drawPath(path, Paint()..color = surface);
    // Only the two sloping sides are stroked: the base is where the card is,
    // and a line there would draw the card's edge across its own pointer.
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) =>
      oldDelegate.up != up ||
      oldDelegate.surface != surface ||
      oldDelegate.border != border;
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
