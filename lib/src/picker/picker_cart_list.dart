import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_tray_dense.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The buyer's tickets, one 40-point line each.
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

    final visibleLimit = theme.layout.denseVisibleLines;
    final collapsed = !_showAll && runs.length > visibleLimit;
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The eyebrow is read out, never drawn: a visible SECTION · ROW · SEAT
        // strip spends a whole row explaining lines that already read as
        // ticket stubs.
        Semantics(
          label: 'Section, row, seat',
          child: const SizedBox.shrink(),
        ),
        for (var index = 0; index < shown.length; index++)
          _RunBlock(
            run: shown[index],
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
        if (runs.length > visibleLimit)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _showAll = !_showAll),
              style: TextButton.styleFrom(
                foregroundColor: theme.accent,
                visualDensity: VisualDensity.compact,
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                ),
              ),
              child: Text(
                collapsed
                    ? strings.moreCount(runs.length - visibleLimit)
                    : strings.showLess,
              ),
            ),
          ),
      ],
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
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    final label = line.item.label;
    try {
      await controller.removeObject(label);
    } catch (_) {
      return;
    }
    callbacks.onSeatRemoved?.call(label);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(strings.seatRemoved),
        duration: SeatLayerPickerMotion.undoWindow,
        action: SnackBarAction(
          label: strings.undo,
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
  SelectedSeat? seat;
  for (final candidate in state.selection) {
    if (candidate.label == item.label) {
      seat = candidate;
      break;
    }
  }
  SeatLayerPickerCategory? category;
  for (final candidate in state.categories) {
    if (candidate.key == item.categoryKey) {
      category = candidate;
      break;
    }
  }
  return SeatLayerTicketLine(
    item: item,
    seat: seat,
    section: seat?.sectionLabel?.trim().isNotEmpty ?? false
        ? seat!.sectionLabel!.trim()
        : category?.label ?? item.buyerFacingLabel,
    rowLabel: pickerRowLabel(seat?.rowLabel, seat?.sectionLabel),
    seatLabel: seat?.seatNumber?.trim().isNotEmpty ?? false
        ? seat!.seatNumber!.trim()
        : item.buyerFacingLabel,
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
    required this.open,
    required this.removable,
    required this.arrivalIndex,
    required this.onToggle,
    required this.onRemove,
  });

  final SeatLayerTicketRun run;
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
                open: false,
                removable: removable,
                onToggle: null,
                onRemove: () => onRemove(member),
              ),
        ],
      );
}

class _DenseLine extends StatelessWidget {
  const _DenseLine({
    required this.line,
    required this.run,
    required this.open,
    required this.removable,
    required this.onToggle,
    required this.onRemove,
  });

  final SeatLayerTicketLine line;
  final SeatLayerTicketRun? run;
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

    return Semantics(
      container: true,
      label: '${line.categoryLabel}, ${strings.seatIdentity(identity)}, '
          '${pickerMoney(context, total, line.item.currency)}',
      child: SizedBox(
        height: theme.layout.denseLineHeight,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.only(left: group == null ? 22 : 0, right: 2),
            child: Row(
              children: [
                if (onToggle != null)
                  AnimatedRotation(
                    duration: SeatLayerPickerMotion.of(
                      context,
                      SeatLayerPickerMotion.pop,
                    ),
                    turns: open ? .25 : 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: theme.mutedText,
                    ),
                  )
                else if (group != null)
                  const SizedBox(width: 18)
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: line.categoryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 8),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: line.section,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        for (final part in identity.skip(1))
                          TextSpan(text: ' · $part'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
                if (size > 1) ...[
                  Text(
                    '$size × ${line.amountText}',
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  pickerMoney(context, total, line.item.currency),
                  softWrap: false,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: theme.fontFamily,
                  ),
                ),
                if (removable)
                  IconButton(
                    tooltip: 'Remove ${line.section} ${line.seatLabel}',
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 34, height: 34),
                    color: theme.mutedText,
                    icon: const Icon(Icons.close_rounded, size: 16),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
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
