import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// Where the buyer is, and the two ways out, docked under the map.
///
/// The dock is the phone's answer to "which section am I in, how much room is
/// left here, and how do I get back". It renders only at rung 2 — the map
/// focused on one section with its seats revealed — and slides away when the
/// map returns to the venue overview.
///
/// It reads everything from the snapshot, so it works standalone inside a
/// [SeatLayerPickerScope]; nothing about it is coupled to the drop-in layout.
class SeatLayerDockBar extends StatelessWidget {
  /// Creates a dock bar for the currently focused section.
  const SeatLayerDockBar({
    super.key,
    this.onOverview,
    this.onSectionChanged,
    this.reserveBottomInset = true,
  });

  /// Replaces the built-in return to the venue overview.
  final VoidCallback? onOverview;

  /// Called with the id of the section a step control moved to.
  ///
  /// The step itself is still performed by the controller; this is a
  /// notification, not a replacement.
  final ValueChanged<String>? onSectionChanged;

  /// Whether to reserve the device's bottom inset below the bar.
  ///
  /// Leave it on when the dock is the lowest thing on screen. The drop-in
  /// turns it off while the cart sheet is mounted, because the sheet already
  /// owns that space and two reservations would stack.
  final bool reserveBottomInset;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final snapshot = controller.state.snapshot;
    final section = _focusedSection(snapshot);
    final theme = seatLayerPickerThemeOf(context);
    final bottomInset =
        reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final height = theme.layout.dockBarHeight;

    final visible = section != null && snapshot!.map.rung == 'seats';
    return AnimatedSlide(
      duration: SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.dock),
      curve: SeatLayerPickerMotion.easeEnter,
      offset: visible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.dock),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Material(
            color: theme.surface,
            elevation: 8,
            child: SizedBox(
              height: height + bottomInset,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: section == null
                    ? const SizedBox.shrink()
                    : _DockContents(
                        section: section,
                        sections: snapshot!.sections,
                        onOverview: onOverview,
                        onSectionChanged: onSectionChanged,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

SeatLayerPickerSectionSummary? _focusedSection(
  SeatLayerPickerSnapshot? snapshot,
) {
  if (snapshot == null) return null;
  final focused = snapshot.map.focusedSection;
  if (focused != null) return focused;
  final id = snapshot.map.focusedSectionId;
  if (id == null) return null;
  for (final section in snapshot.sections) {
    if (section.id == id) return section;
  }
  return null;
}

class _DockContents extends StatelessWidget {
  const _DockContents({
    required this.section,
    required this.sections,
    required this.onOverview,
    required this.onSectionChanged,
  });

  final SeatLayerPickerSectionSummary section;
  final List<SeatLayerPickerSectionSummary> sections;
  final VoidCallback? onOverview;
  final ValueChanged<String>? onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final index = sections.indexWhere((item) => item.id == section.id);
    final previous = index > 0 ? sections[index - 1] : null;
    final next =
        index >= 0 && index < sections.length - 1 ? sections[index + 1] : null;
    final busy = controller.state.isBusy;
    final name = section.displayLabel ?? section.label;
    final count = section.seatsLeft;

    return Row(
      children: [
        const SizedBox(width: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: pickerColor(section.color) ?? theme.accent,
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 10),
        ),
        const SizedBox(width: 8),
        // The name may ellipsize; the count may not. A truncated count reads
        // as a different number, which is worse than a truncated place name.
        Flexible(
          child: _CrossfadeText(
            value: name,
            style: TextStyle(
              color: theme.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: theme.fontFamily,
            ),
          ),
        ),
        if (count != null) ...[
          _DockSeparator(color: theme.mutedText),
          _CrossfadeText(
            value: strings.seatsLeft(count),
            softWrap: false,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
        const Spacer(),
        _StepButton(
          icon: Icons.chevron_left_rounded,
          tooltip: strings.previousSection,
          onPressed: previous == null || busy
              ? null
              : () => _step(controller, previous),
        ),
        _StepButton(
          icon: Icons.chevron_right_rounded,
          tooltip: strings.nextSection,
          onPressed:
              next == null || busy ? null : () => _step(controller, next),
        ),
        const SizedBox(width: 4),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: theme.text,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: theme.fontFamily,
            ),
          ),
          onPressed: busy
              ? null
              : onOverview ??
                  () => ignorePickerAction(controller.overview()),
          icon: const Icon(Icons.chevron_left_rounded, size: 18),
          label: Text(strings.overview),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  void _step(
    SeatLayerPickerController controller,
    SeatLayerPickerSectionSummary target,
  ) {
    ignorePickerAction(controller.focusSection(target.id));
    onSectionChanged?.call(target.id);
  }
}

class _DockSeparator extends StatelessWidget {
  const _DockSeparator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          '·',
          style: TextStyle(color: pickerAlpha(color, .7), fontSize: 13),
        ),
      );
}

/// Text that changes in place instead of being swapped under the eye.
///
/// The dock follows the map, so on a phone this runs every time a pan settles
/// over a new section — one word changing, not a new bar arriving.
class _CrossfadeText extends StatelessWidget {
  const _CrossfadeText({
    required this.value,
    required this.style,
    this.softWrap = true,
  });

  final String value;
  final TextStyle style;
  final bool softWrap;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: SeatLayerPickerMotion.of(
          context,
          SeatLayerPickerMotion.crossfade,
        ),
        child: Text(
          value,
          key: ValueKey<String>(value),
          maxLines: 1,
          softWrap: softWrap,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      );
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      color: theme.text,
      disabledColor: pickerAlpha(theme.mutedText, .4),
      icon: Icon(icon, size: 22),
    );
  }
}
