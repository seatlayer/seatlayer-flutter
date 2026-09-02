import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_haptics.dart';
import 'picker_motion.dart';
import 'picker_sheet_drag.dart';
import 'picker_tokens.g.dart';
import 'picker_tray_dense.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

/// The buyer's tickets, one full-target line each.
///
/// Consecutive seats that differ only by number fold into a run —
/// `Gallery · A · 1–6   6 × €25   €150` — which a tap opens in place, so a
/// buyer can still drop one seat out of six. Past a handful of runs the tail
/// collapses behind a `+N more` control rather than turning the sheet into a
/// scroll.
///
/// Reads everything from the scope, so it works standalone inside a
/// [SeatLayerPickerScope].
class SeatLayerCartList extends StatefulWidget {
  /// Creates a dense ticket list.
  const SeatLayerCartList({super.key, this.compact = true});

  /// Kept for source compatibility with the card-based tray it replaces; the
  /// dense line is the same height either way.
  final bool compact;

  @override
  State<SeatLayerCartList> createState() => _SeatLayerCartListState();
}

class _SeatLayerCartListState extends State<SeatLayerCartList> {
  final Set<int> _openRuns = <int>{};
  final Set<String> _seenKeys = <String>{};
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final runs = groupTicketLines(_resolveLines(context, state));
    if (runs.isEmpty) {
      _seenKeys.clear();
      return const SizedBox.shrink();
    }

    // Two numbers, not one: a list only collapses once it is long enough to
    // be a scroll, and when it does it keeps fewer lines than that. Four
    // visible out of six is a tail worth hiding; four out of five is not.
    final visibleLimit = theme.layout.denseVisibleLines;
    final collapsible = runs.length >= theme.layout.denseCollapseFrom;
    final collapsed = !_showAll && collapsible;
    final shown = collapsed ? runs.take(visibleLimit).toList() : runs;
    final arrivals = <String>[
      for (final run in runs)
        if (!_seenKeys.contains(run.members.first.item.lineKey))
          run.members.first.item.lineKey,
    ];
    _seenKeys
      ..clear()
      ..addAll(runs.map((run) => run.members.first.item.lineKey));

    final removable = !SeatLayerPickerScope.optionsOf(context).readOnly &&
        state.holdOwner != SeatLayerHoldOwner.host;

    // One plate, hairlines inside it. The lines are stubs of one ticket,
    // and a stack of separately bordered cards read as a stack of unrelated
    // things rather than as one order.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.divider),
        borderRadius: BorderRadius.circular(
          theme.radius * SeatLayerRadiusTokens.smallRatio,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          theme.radius * SeatLayerRadiusTokens.smallRatio,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The eyebrow is read out, never drawn: a visible
            // SECTION · ROW · SEAT strip spends a whole row explaining lines
            // that already read as ticket stubs.
            Semantics(
              label: 'Section, row, seat',
              child: const SizedBox.shrink(),
            ),
            for (var index = 0; index < shown.length; index++)
              _RunBlock(
                run: shown[index],
                first: index == 0,
                open: _openRuns.contains(index),
                removable: removable,
                arrivalIndex:
                    arrivals.indexOf(shown[index].members.first.item.lineKey),
                onToggle: () => setState(
                  () => _openRuns.contains(index)
                      ? _openRuns.remove(index)
                      : _openRuns.add(index),
                ),
                onRemove: (line) => _remove(controller, line),
              ),
            if (collapsible)
              _MoreRow(
                collapsed: collapsed,
                label: collapsed
                    ? strings.moreCount(runs.length - visibleLimit)
                    : strings.showLess,
                onPressed: () => setState(() => _showAll = !_showAll),
              ),
          ],
        ),
      ),
    );
  }

  /// Remove immediately, and offer the way back.
  ///
  /// A confirmation dialog for one ticket costs every buyer a tap to protect
  /// against a mistake that is one tap to undo.
  Future<void> _remove(
    SeatLayerPickerController controller,
    SeatLayerTicketLine line,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    // The undo bar is the picker's own chrome, so it takes the picker's
    // palette. Left to Material it inherits the app's, which paints a white
    // bar across a dark picker.
    final theme = seatLayerPickerThemeOf(context);
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    final label = line.item.label;
    try {
      await controller.removeObject(label);
    } catch (_) {
      return;
    }
    callbacks.onSeatRemoved?.call(label);
    // Felt, not just seen: the row is gone from under the finger, and the undo
    // bar that follows is at the other end of the phone.
    controller.emitHaptic(PickerHapticCue.ticketRemoved);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        backgroundColor: theme.surface,
        content: Text(
          strings.seatRemoved,
          style: TextStyle(color: theme.text, fontFamily: theme.fontFamily),
        ),
        duration: SeatLayerPickerMotion.undoWindow,
        action: SnackBarAction(
          label: strings.undo,
          textColor: theme.accent,
          onPressed: () =>
              ignorePickerAction(controller.selectObjects(<String>[label])),
        ),
      ),
    );
  }
}

/// Resolve the cart into display lines.
List<SeatLayerTicketLine> _resolveLines(
  BuildContext context,
  SeatLayerPickerState state,
) {
  final theme = seatLayerPickerThemeOf(context);
  return <SeatLayerTicketLine>[
    for (final item in state.cartLines)
      _resolveLine(context, state, item, theme),
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
  // `Row D · Seat 1` on its own names nothing a buyer can find in a venue. The
  // type is never *added* to a section for the same reason it is not drawn
  // beside one — `Gallery · Gallery · A · 1` is a stutter, not an address.
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
    groupable: ticketIsGroupable(item, seat),
    held: state.holdOwner == SeatLayerHoldOwner.host,
  );
}

class _RunBlock extends StatelessWidget {
  const _RunBlock({
    required this.run,
    required this.first,
    required this.open,
    required this.removable,
    required this.arrivalIndex,
    required this.onToggle,
    required this.onRemove,
  });

  final SeatLayerTicketRun run;
  final bool first;
  final bool open;
  final bool removable;
  final int arrivalIndex;
  final VoidCallback onToggle;
  final ValueChanged<SeatLayerTicketLine> onRemove;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArrivalPop(
            index: arrivalIndex,
            child: _DenseLine(
              line: run.members.first,
              run: run.isGroup ? run : null,
              first: first,
              member: false,
              open: open,
              removable: removable,
              onToggle: run.isGroup ? onToggle : null,
              onRemove: () => onRemove(run.members.first),
            ),
          ),
          if (run.isGroup && open)
            for (final member in run.membersInSeatOrder)
              _DenseLine(
                line: member,
                run: null,
                first: false,
                member: true,
                open: false,
                removable: removable,
                onToggle: null,
                onRemove: () => onRemove(member),
              ),
        ],
      );
}

/// The list's tail, and the one control that unfolds it.
class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.collapsed,
    required this.label,
    required this.onPressed,
  });

  final bool collapsed;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: seatLayerScaledExtent(
          context,
          theme.layout.denseMoreRowHeight,
          max: SeatLayerTypeScaleTokens.sheet,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 12.5,
                fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
                fontFamily: theme.fontFamily,
              ),
            ),
            AnimatedRotation(
              duration: SeatLayerPickerMotion.of(
                context,
                SeatLayerPickerMotion.pop,
              ),
              turns: collapsed ? 0 : .5,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 13,
                color: theme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DenseLine extends StatelessWidget {
  const _DenseLine({
    required this.line,
    required this.run,
    required this.first,
    required this.member,
    required this.open,
    required this.removable,
    required this.onToggle,
    required this.onRemove,
  });

  final SeatLayerTicketLine line;
  final SeatLayerTicketRun? run;
  final bool first;
  final bool member;
  final bool open;
  final bool removable;
  final VoidCallback? onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final group = run;
    final seats = group == null ? line.seatLabel : group.seatsLabel;
    final total = group == null ? line.amount : group.total;
    final size = group?.members.length ?? 1;
    final identity = <String>[
      line.section,
      if (line.rowLabel.isNotEmpty) line.rowLabel,
      if (seats.isNotEmpty && line.section.isNotEmpty) seats,
    ];

    // The type is read out only when it is not already the name of the line;
    // on a chart with no sections the two are the same string, and hearing
    // "Standard, Standard · Row D · 1" is the spoken form of the stutter the
    // drawn line avoids.
    final spokenType =
        line.categoryLabel.toLowerCase() == line.section.toLowerCase()
            ? ''
            : '${line.categoryLabel}, ';

    return Semantics(
      container: true,
      label: '$spokenType${strings.seatIdentity(identity)}, '
          '${pickerMoney(context, total, line.item.currency)}',
      child: _SwipeToRemove(
        // A run's head stands for every seat under it, and a swipe that took
        // six tickets away on one flick is a gesture nobody would trust. Open
        // the run and swipe a seat, or press the ×, which still asks the same
        // question of the whole run as it always did.
        enabled: removable && !line.held && run == null,
        onRemove: onRemove,
        child: Container(
          height: seatLayerScaledExtent(
            context,
            theme.layout.denseLineHeight,
            max: SeatLayerTypeScaleTokens.sheet,
          ),
          decoration: BoxDecoration(
            // A held row is inventory the server has already set aside. A wash
            // of the accent and a bar down its leading edge say so without
            // spending a column on a word.
            color: line.held
                ? pickerAlpha(theme.accent, .07)
                : member
                    ? pickerAlpha(theme.divider, .16)
                    : null,
            border: Border(
              top: first
                  ? BorderSide.none
                  : BorderSide(color: pickerAlpha(theme.divider, .7)),
            ),
          ),
          child: Stack(
            children: [
              if (line.held)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(
                    color: pickerAlpha(theme.accent, .72),
                    child: const SizedBox(width: 3),
                  ),
                ),
              InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: member ? 26 : 9,
                    end: 4,
                  ),
                  child: Row(
                    children: [
                      _LineMark(line: line, run: group, open: open),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: line.section,
                                style: TextStyle(
                                    fontWeight: seatLayerBoldWeight(
                                        context, FontWeight.w700)),
                              ),
                              for (final part
                                  in identity.skip(1)) ...<InlineSpan>[
                                TextSpan(
                                  text: ' · ',
                                  style: TextStyle(color: theme.mutedText),
                                ),
                                TextSpan(text: part),
                              ],
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 13,
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w600),
                            fontFamily: theme.fontFamily,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      if (size > 1) ...[
                        const SizedBox(width: 7),
                        Text(
                          '$size × ${line.amountText}',
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 11,
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w600),
                            fontFamily: theme.fontFamily,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 7),
                      Text(
                        pickerMoney(context, total, line.item.currency),
                        softWrap: false,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 13,
                          fontWeight:
                              seatLayerBoldWeight(context, FontWeight.w700),
                          fontFamily: theme.fontFamily,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      if (removable)
                        _RemoveButton(line: line, onPressed: onRemove)
                      else
                        const SizedBox(width: 7),
                    ],
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

/// A ticket the buyer can push out of the list.
///
/// The native way out, beside the × rather than instead of it: the row follows
/// the finger toward the leading edge, uncovers a red plate as it goes, and
/// leaves once it has travelled far enough — or once it has been thrown, which
/// is the same instruction given faster. Everything the × does afterwards, a
/// swipe does too, undo bar included.
///
/// It is deliberately not a [Dismissible]: that widget owns the removal, animates
/// the gap closed itself, and needs a key per row; here the cart is the source of
/// truth and the row disappears because the snapshot no longer has it.
class _SwipeToRemove extends StatefulWidget {
  const _SwipeToRemove({
    required this.enabled,
    required this.onRemove,
    required this.child,
  });

  /// Whether this row may be swiped at all. A held row never is: those seats
  /// belong to a hold the host owns, and the row says so with a lock.
  final bool enabled;

  /// Called once the swipe has committed — the same callback the × uses.
  final VoidCallback onRemove;

  final Widget child;

  @override
  State<_SwipeToRemove> createState() => _SwipeToRemoveState();
}

class _SwipeToRemoveState extends State<_SwipeToRemove>
    with SingleTickerProviderStateMixin {
  /// How far the row has travelled toward the remove edge, in points. Always
  /// positive; which way that is on screen is [Directionality]'s business.
  late final AnimationController _slide;

  double _raw = 0;
  double _width = 0;
  bool _committed = false;

  @override
  void initState() {
    super.initState();
    // Eagerly, not lazily: a row that is never swiped is still disposed, and a
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
    // Out of the plate first, then gone: a row that vanishes under the finger
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

/// What stands at the head of a line: a run's fold control, a category
/// colour, or the lock of a seat the server has already set aside.
///
/// A lock is not a colour: a held seat gets a mark that survives being read
/// in greyscale, because it is the one state with consequences.
class _LineMark extends StatelessWidget {
  const _LineMark({required this.line, required this.run, required this.open});

  final SeatLayerTicketLine line;
  final SeatLayerTicketRun? run;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final group = run;
    if (group != null) {
      // The chevron is a marker, not the target: the whole line opens the
      // run, and the line clears the touch floor in both directions on its
      // own.
      return SizedBox(
        width: theme.layout.denseRunToggleWidth,
        child: AnimatedRotation(
          duration: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.pop,
          ),
          turns: open ? .25 : 0,
          child: Icon(
            Icons.chevron_right_rounded,
            size: 13,
            color: theme.mutedText,
          ),
        ),
      );
    }
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
          dimension: 14,
          child: Icon(Icons.lock_rounded, size: 9, color: theme.accent),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: line.categoryColor,
        shape: BoxShape.circle,
      ),
      child: const SizedBox.square(dimension: 9),
    );
  }
}

/// One ticket's way out.
///
/// The glyph stays small; the target around it does not.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.line, required this.onPressed});

  final SeatLayerTicketLine line;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return IconButton(
      tooltip: 'Remove ${line.section} ${line.seatLabel}',
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: SeatLayerSizeTokens.minimumHitTarget,
        height: SeatLayerSizeTokens.minimumHitTarget,
      ),
      color: theme.mutedText,
      style: IconButton.styleFrom(
        minimumSize: Size.square(theme.layout.denseRemoveSize),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.close_rounded, size: 12),
    );
  }
}

/// A newly arrived line settling in, one after the next.
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
