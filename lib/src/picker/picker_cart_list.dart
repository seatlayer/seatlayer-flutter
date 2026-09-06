/// The buyer's tickets, one card each — the SAME card on every width.
///
/// The phone used to draw a second cart: a bordered plate of 44 pt
/// hairline-divided lines, with consecutive seats folded into runs behind a
/// `+N more`. It saved real pixels and it cost the sheet its coherence — a
/// bordered list on its own surface between a chrome band and a shadowed
/// footer reads as three blocks stacked in a panel rather than as one panel —
/// and it was a second rendering of one cart to keep in step with the first.
///
/// So there is one card now (owner call 2026-09-06: "cards should be the same
/// design as desktop"): a colour dot, the name, the position and type in grey
/// under it, whatever the organizer has said about the seat, the price, and the
/// two actions. The collapsed sheet caps the list at three of them and scrolls
/// (see `picker_cart_sheet.dart`), which is the same answer folding gave
/// without a second design.
///
/// Gone with the fold: the run model, the `+N more` tail and the plate.
library;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../payloads.dart';
import 'picker_buyer_asset_loader.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_seat_notes.dart';
import 'picker_cart_removal.dart';
import 'picker_haptics.dart';
import 'picker_motion.dart';

import 'picker_sheet_drag.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';
import 'picker_strings.dart';

/// One ticket, resolved for the cart card.
///
/// The strings arrive already looked up, so everything below is pure data and
/// can be tested without a widget tree.
@immutable
class SeatLayerTicketLine {
  /// Creates one resolved ticket line.
  const SeatLayerTicketLine({
    required this.item,
    required this.section,
    required this.rowLabel,
    required this.seatLabel,
    required this.categoryLabel,
    required this.categoryColor,
    required this.amountText,
    required this.amount,
    required this.held,
    this.seat,
  });

  /// The cart line this stands for; [SeatLayerCheckoutLineItem.label] is the
  /// inventory identity used for removal.
  final SeatLayerCheckoutLineItem item;

  /// The selected seat behind the line, when the runtime reported one.
  final SelectedSeat? seat;

  /// Buyer-facing place name.
  final String section;

  /// Buyer-facing row name; empty when the object has no row.
  final String rowLabel;

  /// Buyer-facing seat name.
  final String seatLabel;

  /// The category's name. Drawn on the grey line only when it is not already
  /// the name of the card, and always read out.
  final String categoryLabel;

  /// The category's display colour.
  final Color categoryColor;

  /// Rendered price for this line.
  final String amountText;

  /// Numeric total for this line.
  final double amount;

  /// Whether the line is a server-committed hold rather than a fresh pick.
  final bool held;
}

/// The buyer's tickets, one card each.
///
/// Reads everything from the scope, so it works standalone inside a
/// [SeatLayerPickerScope].
class SeatLayerCartList extends StatefulWidget {
  /// Creates the cart list.
  const SeatLayerCartList({super.key, this.compact = true});

  /// Kept for source compatibility with the widths that used to draw a denser
  /// list; the card is the same card either way.
  final bool compact;

  @override
  State<SeatLayerCartList> createState() => _SeatLayerCartListState();
}

class _SeatLayerCartListState extends State<SeatLayerCartList> {
  final Set<String> _seenKeys = <String>{};

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final removals = seatLayerCartRemovalsOf(controller);
    // The mark is answered by the snapshot, not by the reply: a line the cart
    // no longer carries has finished leaving however the runtime said so.
    removals.settle(<String>{for (final item in state.cartLines) item.label});
    final lines = _resolveLines(context, state);
    if (lines.isEmpty) {
      _seenKeys.clear();
      return const SizedBox.shrink();
    }

    final arrivals = <String>[
      for (final line in lines)
        if (!_seenKeys.contains(line.item.lineKey)) line.item.lineKey,
    ];
    _seenKeys
      ..clear()
      ..addAll(lines.map((line) => line.item.lineKey));

    // The × stays on a card even while the host owns the hold (2026-09-05,
    // TestFlight): hiding it left a buyer back from checkout with a washed
    // card and no way to change anything. The runtime refuses the removal, and
    // that refusal is drawn as a state with a way out by the action bar.
    final removable = !SeatLayerPickerScope.optionsOf(context).readOnly;
    final locate = _seatViewOpener(context, controller);

    // The cards are rebuilt on the removals as well as on the snapshot: the
    // press that starts a removal changes how a card is drawn a second or more
    // before the snapshot that finishes it arrives.
    return ListenableBuilder(
      listenable: removals,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < lines.length; index++) ...<Widget>[
            if (index > 0) SizedBox(height: theme.layout.cartCardGap),
            _ArrivalPop(
              index: arrivals.indexOf(lines[index].item.lineKey),
              child: SeatLayerCartCard(
                line: lines[index],
                removable: removable,
                removing: removals.isRemoving(lines[index].item.label),
                onRemove: () => _remove(controller, lines[index]),
                onLocate: locate == null || lines[index].seat == null
                    ? null
                    : () => locate(lines[index].seat!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Remove immediately.
  ///
  /// A confirmation dialog for one ticket costs every buyer a tap to protect
  /// against a mistake that is one tap to reverse: re-picking the seat is the
  /// same gesture that chose it.
  ///
  /// "Immediately" is the card, not the server. `picker.removeCartLine`
  /// re-holds the rest of the cart before it answers — close to two seconds on
  /// a real event — so the card is marked, faded and made inert in the same
  /// frame as the press, against a decision that has already been taken. The
  /// mark is dropped by the snapshot that no longer carries the line, or
  /// restored here if the mutation fails.
  Future<void> _remove(
    SeatLayerPickerController controller,
    SeatLayerTicketLine line,
  ) async {
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    final removals = seatLayerCartRemovalsOf(controller);
    final label = line.item.label;
    removals.mark(label);
    // Felt, not just seen: the card is on its way out from under the finger,
    // and nothing else will say so.
    controller.emitHaptic(PickerHapticCue.ticketRemoved);
    // NOTHING IS SAID. The buyer pressed ✕ on a specific card and that card is
    // now gone from the tray, the total has moved and the checkout action has
    // recounted — announcing it as well is telling someone what they just did.
    //
    // The FAILURE path below keeps its telling: a removal that did not happen
    // is the one case the tray cannot show by itself.
    try {
      await controller.removeObject(label);
    } catch (_) {
      // The controller has already published the typed failure, which the
      // sheet's inline action error draws. What is owed here is the card: it
      // was faded in the same frame as the press, and it comes back.
      removals.restore(label);
      return;
    }
    // A reply that left the line standing is not a removal, however it was
    // reported; the card comes back rather than staying faded for good.
    removals.restore(label);
    callbacks.onSeatRemoved?.call(label);
  }
}

/// Who opens the view from a seat, or null where there is no view to open.
///
/// The same gate the confirm card's strip uses: the host has to allow it, the
/// runtime has to advertise `seatView`, and — because a stand-in the runtime
/// could draw for any seat is never offered — the seat has to carry an
/// authored photograph.
ValueChanged<SelectedSeat>? _seatViewOpener(
  BuildContext context,
  SeatLayerPickerController controller,
) {
  final options = SeatLayerPickerScope.optionsOf(context);
  final capabilities =
      controller.state.snapshot?.capabilities ?? const <String>{};
  if (!options.enableSeatView || !capabilities.contains('seatView')) {
    return null;
  }
  if (!controller.supportsSeatViewThumbnails) return null;
  return (seat) {
    if (seat.seatViewThumb == null) return;
    ignorePickerAction(controller.openSeatView(seat));
    SeatLayerPickerScope.callbacksOf(context).onSeatViewOpened?.call(seat);
  };
}

/// Resolve the cart into display lines.
List<SeatLayerTicketLine> _resolveLines(
  BuildContext context,
  SeatLayerPickerState state,
) {
  final theme = seatLayerPickerThemeOf(context);
  // A seat the card is still asking about is not in the cart yet: it is in
  // the runtime's selection, and listing it here before the buyer has said
  // yes shows them a ticket they have not taken.
  final confirmed =
      SeatLayerPickerScope.controllerOf(context).confirmedCartLines;
  return <SeatLayerTicketLine>[
    for (final item in confirmed) _resolveLine(context, state, item, theme),
  ];
}

SeatLayerTicketLine _resolveLine(
  BuildContext context,
  SeatLayerPickerState state,
  SeatLayerCheckoutLineItem item,
  SeatLayerResolvedPickerTheme theme,
) {
  final seat = _seatBehind(state.selection, item);
  SeatLayerPickerCategory? category;
  for (final candidate in state.categories) {
    if (candidate.key == item.categoryKey) {
      category = candidate;
      break;
    }
  }
  // The line's own address first, the selected seat's second. A line the buyer
  // never tapped — a Best Available result, a resumed hold — is in no renderer
  // selection at all, so the join finds nothing and only the line knows where
  // the seat is.
  //
  // Where the chart has no sections the ticket type names the line instead:
  // `Row D · Seat 1` on its own names nothing a buyer can find in a venue.
  final section = _first(item.sectionLabel, seat?.sectionLabel);
  final row = _first(item.rowLabel, seat?.rowLabel);
  final number = _first(item.seatNumber, seat?.seatNumber);
  return SeatLayerTicketLine(
    item: item,
    seat: seat,
    section: section ?? category?.label ?? item.buyerFacingLabel,
    rowLabel: pickerRowLabel(
      row,
      section,
      sectionCode: pickerSectionCode(state, section),
    ),
    seatLabel: number ?? item.buyerFacingLabel,
    categoryLabel: category?.label ?? item.categoryKey,
    categoryColor: pickerColor(category?.color) ?? theme.accent,
    amountText: pickerMoney(context, item.total, item.currency),
    amount: item.total,
    held: state.holdOwner == SeatLayerHoldOwner.host,
  );
}

/// One ticket, as the desktop panel and the phone sheet both draw it.
///
/// A row, not a two-column grid: everything the card needs sits on one
/// baseline, so its trailing edge lands on the panel's own gutter with every
/// other card's. The organizer's notes are a footnote UNDER that line — the
/// card is already a bordered ticket, and a tinted band inside one reads as a
/// card inside a card.
class SeatLayerCartCard extends StatelessWidget {
  /// Creates one cart card.
  const SeatLayerCartCard({
    super.key,
    required this.line,
    required this.removable,
    required this.removing,
    required this.onRemove,
    this.onLocate,
  });

  /// The ticket this card stands for.
  final SeatLayerTicketLine line;

  /// Whether this session may remove tickets at all.
  final bool removable;

  /// Whether the buyer has asked for this line and the server has not answered
  /// yet. The card is drawn at `opacity.removing` and its × is inert.
  final bool removing;

  /// Takes the ticket out of the cart.
  final VoidCallback onRemove;

  /// Opens the view from this seat, or null where there is none to open.
  final VoidCallback? onLocate;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final layout = theme.layout;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final identity = <String>[
      line.section,
      if (line.rowLabel.isNotEmpty) line.rowLabel,
      if (line.seatLabel.isNotEmpty && line.section.isNotEmpty) line.seatLabel,
    ];
    // The type is read out only when it is not already the name of the card;
    // on a chart with no sections the two are the same string, and hearing
    // "Standard, Standard · Row D · 1" is the spoken form of a stutter.
    final typeIsName =
        line.categoryLabel.toLowerCase() == line.section.toLowerCase();
    final notes = seatLayerCartNoteLines(line.seat, strings);

    return Semantics(
      container: true,
      label: <String>[
        if (!typeIsName) line.categoryLabel,
        strings.seatIdentity(identity),
        line.amountText,
        for (final note in notes) note.spoken,
      ].join(', '),
      child: _SwipeToRemove(
        enabled: removable && !line.held && !removing,
        onRemove: onRemove,
        child: AnimatedOpacity(
          // The one beat that says the press landed. It is not a departure —
          // the card is still there — so it fades to a state rather than out.
          opacity: removing ? SeatLayerOpacityTokens.removing : 1,
          duration: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.crossfade,
          ),
          child: Container(
            constraints: BoxConstraints(
              minHeight: seatLayerScaledExtent(
                context,
                layout.cartCardMinHeight,
                max: SeatLayerTypeScaleTokens.sheet,
              ),
            ),
            decoration: BoxDecoration(
              // A held card is inventory the server has already set aside. A
              // wash of the accent and a warmer border say so without spending
              // a column on a word.
              color: line.held
                  ? Color.alphaBlend(
                      pickerAlpha(theme.accent, .07), theme.surface)
                  : theme.surface,
              border: Border.all(
                color: line.held
                    ? Color.alphaBlend(
                        pickerAlpha(theme.accent, .45), theme.divider)
                    : theme.divider,
              ),
              borderRadius:
                  BorderRadius.circular(SeatLayerSizeTokens.cartCardRadius),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ExcludeSemantics(child: _CardMark(line: line)),
                const SizedBox(width: 10),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // The name ellipsizes — a long venue section is the one
                        // fact here that can be longer than the panel.
                        Text(
                          line.section,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // design/tokens.json › type.cartCardName.
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 13,
                            height: 1.25,
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w700),
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                        _PositionLine(
                          parts: <String>[
                            ...identity.skip(1),
                            if (!typeIsName) line.categoryLabel,
                          ],
                        ),
                        if (notes.isNotEmpty) _CardNotes(notes: notes),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: SeatLayerCrossFade(
                    token: line.amountText,
                    child: Text(
                      line.amountText,
                      softWrap: false,
                      // design/tokens.json › type.cartCardAmount.
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 13,
                        fontWeight:
                            seatLayerBoldWeight(context, FontWeight.w800),
                        fontFamily: theme.fontFamily,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ),
                // A HORIZONTAL PAIR, NOT A BORDERED COLUMN, and both boxes are
                // the full touch floor: they sit two points apart, so growing
                // invisible boxes any further would let the ✕ claim part of the
                // eye's own ink.
                if (onLocate != null)
                  _CardAction(
                    icon: Icons.visibility_outlined,
                    label: strings.viewFromHere,
                    onPressed: onLocate,
                  ),
                if (removable)
                  _CardAction(
                    icon: Icons.close_rounded,
                    label: '${strings.removeSeat} ${line.section} '
                        '${line.seatLabel}',
                    // Inert, not gone: a target that disappears under the thumb
                    // takes the card's shape with it, and the press it was
                    // answering has already been accepted.
                    onPressed: removing ? null : onRemove,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The grey line under the name: where the seat is, and what kind it is.
class _PositionLine extends StatelessWidget {
  const _PositionLine({required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    return SeatLayerCrossFade(
      token: parts.join(' · '),
      child: Text(
        parts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // design/tokens.json › type.cartCardPosition.
        style: TextStyle(
          color: theme.mutedText,
          fontSize: 11.5,
          height: 1.3,
          fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
          fontFamily: theme.fontFamily,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// What stands at the head of a card: the category colour, or the lock of a
/// seat the server has already set aside.
///
/// A lock is not a colour: a held seat gets a mark that survives being read in
/// greyscale, because it is the one state with consequences.
class _CardMark extends StatelessWidget {
  const _CardMark({required this.line});

  final SeatLayerTicketLine line;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    if (line.held) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            pickerAlpha(theme.accent, .18),
            theme.surface,
          ),
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: 17,
          child: Icon(Icons.lock_rounded, size: 10, color: theme.accent),
        ),
      );
    }
    // The same hairline the confirm card's band dot carries, for the same
    // reason: a pale category on the panel's own surface is otherwise a disc
    // you cannot find.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: line.categoryColor,
        shape: BoxShape.circle,
        border: Border.all(color: pickerAlpha(theme.text, .22)),
      ),
      child: const SizedBox.square(dimension: 9),
    );
  }
}

/// One of the card's two actions: the glyph stays small, the target does not.
class _CardAction extends StatelessWidget {
  const _CardAction({
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
    // A TIGHT BOX, not a minimum. Material pads an icon button out to its own
    // 48-point tap target whatever the style asks for, and four points per
    // card is what puts the fourth card past the collapsed cart's cap: the
    // box is the touch floor exactly, and the glyph inside it does not move.
    return SizedBox.square(
      dimension: SeatLayerSizeTokens.minimumHitTarget,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: SeatLayerSizeTokens.minimumHitTarget,
          height: SeatLayerSizeTokens.minimumHitTarget,
        ),
        color: theme.text,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(SeatLayerSizeTokens.minimumHitTarget),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 18),
      ),
    );
  }
}

/// One line of what the organizer has said about a seat.
@immutable
class SeatLayerCartNoteLine {
  /// Creates one resolved note line.
  const SeatLayerCartNoteLine({required this.title, this.note});

  /// The attribute's buyer-facing name.
  final String title;

  /// The organizer's own sentence, where it belongs to this line.
  final String? note;

  /// The whole line as it is read out.
  String get spoken => note == null ? title : '$title: $note';
}

/// Every note a cart card owes, in reading order.
///
/// The cart says all of this ONCE, in WORDS: the same rows the seat card
/// draws as bands ([seatLayerSeatNotesFor]), read here as title and sentence
/// and nothing else. One row model, two readings — the card used to carry
/// icon markers as well, and since both drew the same set the line read as
/// the same fact printed twice.
List<SeatLayerCartNoteLine> seatLayerCartNoteLines(
  SelectedSeat? seat,
  SeatLayerPickerStrings strings,
) {
  if (seat == null) return const <SeatLayerCartNoteLine>[];
  return List<SeatLayerCartNoteLine>.unmodifiable(
    seatLayerSeatNotesFor(seat, strings).map(
      (row) => SeatLayerCartNoteLine(title: row.title, note: row.note),
    ),
  );
}

/// The notes, as a footnote under the line they belong to.
class _CardNotes extends StatelessWidget {
  const _CardNotes({required this.notes});

  final List<SeatLayerCartNoteLine> notes;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: SeatLayerSizeTokens.cartNotePadTop),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: pickerAlpha(theme.divider, .72)),
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: SeatLayerSizeTokens.cartNotePadTop),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var index = 0; index < notes.length; index++) ...<Widget>[
                if (index > 0)
                  const SizedBox(height: SeatLayerSizeTokens.cartNoteGap),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: notes[index].title,
                        // design/tokens.json › type.cartNoteTitle.
                        style: TextStyle(
                          color: theme.text,
                          fontWeight:
                              seatLayerBoldWeight(context, FontWeight.w800),
                        ),
                      ),
                      if (notes[index].note case final String note)
                        TextSpan(
                          text: ' $note',
                          style: TextStyle(color: theme.mutedText),
                        ),
                    ],
                  ),
                  // design/tokens.json › type.cartNoteText.
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A ticket the buyer can push out of the list.
///
/// The native way out, beside the × rather than instead of it: the card follows
/// the finger toward the leading edge, uncovers a red plate as it goes, and
/// leaves once it has travelled far enough — or once it has been thrown, which
/// is the same instruction given faster. Everything the × does afterwards, a
/// swipe does too.
///
/// It is deliberately not a [Dismissible]: that widget owns the removal,
/// animates the gap closed itself, and needs a key per row; here the cart is
/// the source of truth and the card disappears because the snapshot no longer
/// has it.
class _SwipeToRemove extends StatefulWidget {
  const _SwipeToRemove({
    required this.enabled,
    required this.onRemove,
    required this.child,
  });

  /// Whether this card may be swiped at all. A held card never is: those seats
  /// belong to a hold the host owns, and the card says so with a lock.
  final bool enabled;

  /// Called once the swipe has committed — the same callback the × uses.
  final VoidCallback onRemove;

  final Widget child;

  @override
  State<_SwipeToRemove> createState() => _SwipeToRemoveState();
}

class _SwipeToRemoveState extends State<_SwipeToRemove>
    with SingleTickerProviderStateMixin {
  /// How far the card has travelled toward the remove edge, in points. Always
  /// positive; which way that is on screen is [Directionality]'s business.
  late final AnimationController _slide;

  double _raw = 0;
  double _width = 0;
  bool _committed = false;

  @override
  void initState() {
    super.initState();
    // Eagerly, not lazily: a card that is never swiped is still disposed, and a
    // ticker created during dispose looks up an ancestor that is already gone.
    _slide = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  bool get _reversed => Directionality.of(context) == TextDirection.rtl;

  void _onStart(DragStartDetails details) {
    _slide.stop();
    _raw = _slide.value;
  }

  void _onUpdate(DragUpdateDetails details) {
    _raw += _reversed ? details.delta.dx : -details.delta.dx;
    _slide.value = pickerRubberBand(_raw, 0, _width);
  }

  void _onEnd(DragEndDetails details) {
    final velocity = _reversed
        ? details.velocity.pixelsPerSecond.dx
        : -details.velocity.pixelsPerSecond.dx;
    final committed =
        _slide.value >= _width * SeatLayerPhysicsTokens.swipeCommitFraction ||
            velocity >= SeatLayerPhysicsTokens.swipeFlingVelocity;
    if (!committed) {
      _returnHome(velocity);
      return;
    }
    _commit(velocity);
  }

  void _returnHome(double velocity) {
    _raw = 0;
    if (SeatLayerPickerMotion.reduced(context)) {
      _slide.value = 0;
      return;
    }
    _slide.animateWith(
      SpringSimulation(pickerSheetSpring, _slide.value, 0, velocity),
    );
  }

  void _commit(double velocity) {
    if (_committed) return;
    _committed = true;
    if (SeatLayerPickerMotion.reduced(context)) {
      _finish();
      return;
    }
    // Out of the plate first, then gone: a card that vanishes under the finger
    // leaves the buyer unsure which ticket they removed.
    _slide
        .animateWith(
          SpringSimulation(pickerSheetSpring, _slide.value, _width, velocity),
        )
        .whenComplete(_finish);
  }

  void _finish() {
    if (!mounted) return;
    _committed = false;
    _raw = 0;
    _slide.value = 0;
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final theme = seatLayerPickerThemeOf(context);
    final travelled = _slide.value;
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          excludeFromSemantics: true,
          onHorizontalDragStart: _onStart,
          onHorizontalDragUpdate: _onUpdate,
          onHorizontalDragEnd: _onEnd,
          child: Stack(
            children: [
              // The plate is only drawn while there is something to see, so a
              // list at rest is the same list it has always been.
              if (travelled > 0)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      SeatLayerSizeTokens.cartCardRadius,
                    ),
                    child: ColoredBox(
                      // The one place in the picker that is never the accent: a
                      // brand colour that happens to be red would make every
                      // other swipe look like a warning, and a brand colour that
                      // happens to be green would make this one look safe.
                      color: theme.error,
                      child: const Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(end: 14),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            // The same ink the inline error bar puts on this
                            // same red.
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(_reversed ? travelled : -travelled, 0),
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A newly arrived card settling in, one after the next.
///
/// Best-available drops several seats into the cart at once; landing them
/// together reads as a page redraw, landing them in sequence reads as seats
/// being found. The whole set is bounded, so a large result never turns the
/// arrival into a wait.
class _ArrivalPop extends StatelessWidget {
  const _ArrivalPop({required this.index, required this.child});

  final int index;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (index < 0 || SeatLayerPickerMotion.reduced(context)) return child;
    final delay = SeatLayerPickerMotion.stagger * index;
    final total = SeatLayerPickerMotion.pop + delay;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(index),
      tween: Tween<double>(begin: 0, end: 1),
      duration:
          total > SeatLayerPickerMotion.fly ? SeatLayerPickerMotion.fly : total,
      curve: Interval(
        total.inMilliseconds == 0
            ? 0
            : (delay.inMilliseconds / total.inMilliseconds).clamp(0, .9),
        1,
        curve: SeatLayerPickerMotion.easeEnter,
      ),
      builder: (context, value, inner) => Opacity(
        opacity: value,
        child: Transform.scale(
          scale: .94 + (.06 * value),
          alignment: Alignment.centerLeft,
          child: inner,
        ),
      ),
      child: child,
    );
  }
}

/// The selected seat a cart line stands for.
///
/// The inventory label is the primary key, but it is not the only identifier
/// the contract carries and it is not always the one a line arrives with — a
/// Best Available result, for instance, is a line the buyer never tapped. The
/// object id and the seat's own id are checked next, so an identity the
/// runtime did send is used rather than falling back to the category name and
/// a raw inventory label.
SelectedSeat? _seatBehind(
  List<SelectedSeat> selection,
  SeatLayerCheckoutLineItem item,
) {
  final seatId = item.seatId;
  if (seatId != null) {
    for (final candidate in selection) {
      if (candidate.id == seatId) return candidate;
    }
  }
  for (final candidate in selection) {
    if (candidate.label == item.label) return candidate;
  }
  for (final candidate in selection) {
    if (candidate.objectId != null && candidate.objectId == item.objectId) {
      return candidate;
    }
  }
  for (final candidate in selection) {
    if (candidate.id == item.objectId) return candidate;
  }
  return null;
}

/// [primary] if it carries something to print, else [fallback].
String? _first(String? primary, String? fallback) {
  final first = primary?.trim() ?? '';
  if (first.isNotEmpty) return first;
  final second = fallback?.trim() ?? '';
  return second.isEmpty ? null : second;
}
