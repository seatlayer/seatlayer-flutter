import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_styles.dart';
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
/// map climbs one level at a time, matching the web picker.
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
    this.style,
  });

  /// Replaces the built-in one-level return from the seat map.
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

  /// Overrides [SeatLayerPickerStyles.dockBarStyle] for this bar.
  final SeatLayerSurfaceStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final snapshot = controller.state.snapshot;
    final section = _focusedSection(snapshot);
    final theme = seatLayerPickerThemeOf(context);
    final bottomInset =
        reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final height = theme.layout.dockBarHeight;
    final barStyle =
        (theme.styles.dockBarStyle ?? const SeatLayerSurfaceStyle())
            .merge(style);

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
            color: barStyle.color ?? theme.surface,
            elevation: barStyle.elevation ?? 8,
            shape: barStyle.shape,
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
    final count = _seatsLeftForBuyer(section, controller.state.selection);
    final onOverviewPressed = busy
        ? null
        : onOverview ?? () => ignorePickerAction(controller.overview());

    final nameStyle = TextStyle(
      color: theme.text,
      fontSize: _nameFontSize,
      fontWeight: FontWeight.w800,
      fontFamily: theme.fontFamily,
    );
    final countStyle = TextStyle(
      color: theme.mutedText,
      fontSize: _countFontSize,
      fontWeight: FontWeight.w600,
      fontFamily: theme.fontFamily,
    );
    final venueStyle = TextStyle(
      fontSize: _venueFontSize,
      fontWeight: FontWeight.w800,
      fontFamily: theme.fontFamily,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final plan = _planDock(
          context,
          width: constraints.maxWidth,
          name: name,
          nameStyle: nameStyle,
          count: count,
          countLong: count == null ? null : strings.seatsLeft(count),
          countStyle: countStyle,
          venueLabel: strings.overview,
          venueStyle: venueStyle,
        );
        final shownCount = switch (plan.count) {
          _DockCount.long => count == null ? null : strings.seatsLeft(count),
          _DockCount.short => count?.toString(),
          _DockCount.hidden => null,
        };

        return Row(
          children: [
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: pickerSectionColor(
                  section,
                  controller.state.categories,
                  fallback: theme.accent,
                ),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 10),
            ),
            const SizedBox(width: 8),
            // The name has first claim on the width. Everything to its right
            // gives way in order — the count's own word, then the count, then
            // the Venue label — before the name loses a single letter, and it
            // takes a second line before it ellipsizes at all. `Sponsor Ta…`
            // names no section a buyer can recognise.
            // One expanded box holds the name and its count, so the name is
            // the only flexible child inside it and takes its own width.
            // A `Flexible` next to a `Spacer` splits the free space with it —
            // which is what capped the name at half the row and cut
            // `Sponsor Ta…` while the bar still had room to its right.
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: _CrossfadeText(
                      value: name,
                      maxLines: plan.nameLines,
                      style: nameStyle.copyWith(fontSize: plan.nameFontSize),
                    ),
                  ),
                  if (shownCount != null) ...[
                    _DockSeparator(color: theme.mutedText),
                    _CrossfadeText(
                      value: shownCount,
                      softWrap: false,
                      style: countStyle,
                    ),
                  ],
                ],
              ),
            ),
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
            if (plan.venueLabelled)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.text,
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: _venuePadding),
                  textStyle: venueStyle,
                ),
                onPressed: onOverviewPressed,
                icon: const Icon(Icons.chevron_left_rounded, size: 18),
                label: Text(strings.overview),
              )
            else
              // The narrowest rung. The control keeps its name for anyone
              // reading the screen; only the drawn word goes.
              _StepButton(
                icon: Icons.chevron_left_rounded,
                tooltip: strings.overview,
                onPressed: onOverviewPressed,
              ),
            const SizedBox(width: 6),
          ],
        );
      },
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

/// Type sizes the dock is drawn at.
const double _nameFontSize = 13;
const double _countFontSize = 13;
const double _venueFontSize = 13;

/// The size the name drops to once it needs a second line.
///
/// Two lines of 13 would crowd a 52-point bar; 12 leaves the same breathing
/// room above and below that one line of 13 has.
const double _wrappedNameFontSize = 12;

/// Everything the row spends before the name gets any width.
///
/// The leading gutter, the category dot and the gap after it.
const double _leadingWidth = 12 + 10 + 8;

/// What one icon control occupies.
///
/// The icon box itself is 36, but Material adds its compact tap-target
/// padding around it and the control lands 40 wide. Measured, not assumed —
/// `the dock never overflows` in `picker_dock_bar_test.dart` fails if this
/// ever drifts, because an underestimate here is a row that overflows.
const double _stepWidth = 40;

/// The two section step buttons, which never give way — they are how the
/// buyer moves, and a dock without them is a label.
const double _stepsWidth = _stepWidth * 2;

/// The gap between the steps and the way back to the venue.
const double _venueGap = 4;

/// Horizontal padding inside the labelled Venue button, per side.
const double _venuePadding = 10;

/// The Venue button's chevron, and the gap `TextButton.icon` puts after it.
const double _venueIconWidth = 18 + 8;

/// Material's minimum width for a button, which the labelled Venue control
/// can never measure under however short its word is.
const double _venueMinWidth = 64;

/// The Venue control once it is only its chevron.
const double _venueIconOnlyWidth = _stepWidth;

/// The trailing gutter.
const double _trailingWidth = 6;

/// The separator between the name and the count, with its own padding.
const double _separatorWidth = 6 + 6 + 4;

/// How much of the count survives at this width.
enum _DockCount {
  /// `72 left` — the count and the word that says what it counts.
  long,

  /// `72` — still an exact number, which is the part that matters.
  short,

  /// Nothing. The name and the controls are worth more than the count.
  hidden,
}

/// What the dock row can afford to draw at [width].
@immutable
class _DockPlan {
  const _DockPlan({
    required this.count,
    required this.venueLabelled,
    required this.nameLines,
    required this.nameFontSize,
  });

  final _DockCount count;
  final bool venueLabelled;
  final int nameLines;
  final double nameFontSize;
}

/// Choose the roomiest arrangement whose name still fits on one line.
///
/// The ladder is fixed and runs right to left, because that is the order the
/// pieces are worth losing: the count's own word first, then the count, then
/// the Venue label. The name is measured against what each rung leaves, and
/// the first rung that fits wins — so a short name keeps `72 left` and a long
/// one keeps its letters. Only when the narrowest rung still cannot hold the
/// name does it take a second line, and only then can it ellipsize.
_DockPlan _planDock(
  BuildContext context, {
  required double width,
  required String name,
  required TextStyle nameStyle,
  required int? count,
  required String? countLong,
  required TextStyle countStyle,
  required String venueLabel,
  required TextStyle venueStyle,
}) {
  final scaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);
  // A `Text` inherits the ambient default — the host's typeface among other
  // things — and a bare `TextPainter` does not. Measuring without the merge
  // sizes the row for a font nothing on screen is drawn in.
  final inherited = DefaultTextStyle.of(context).style;
  double measure(String value, TextStyle style) =>
      _textWidth(value, inherited.merge(style), scaler, direction);

  final nameWidth = measure(name, nameStyle);
  final longWidth = countLong == null
      ? 0.0
      : _separatorWidth + measure(countLong, countStyle);
  final shortWidth =
      count == null ? 0.0 : _separatorWidth + measure('$count', countStyle);
  // A `ButtonStyle` textStyle replaces the ambient default rather than
  // merging with it, so the button's own label is measured raw. The floor is
  // Material's minimum button width, which a short word in another language
  // would otherwise be sized under.
  final labelledVenue = math.max(
    _venueMinWidth,
    _venuePadding * 2 +
        _venueIconWidth +
        _textWidth(venueLabel, venueStyle, scaler, direction),
  );

  double roomFor({required double countWidth, required double venueWidth}) =>
      width -
      _leadingWidth -
      countWidth -
      _stepsWidth -
      _venueGap -
      venueWidth -
      _trailingWidth;

  const rungs = <(_DockCount, bool)>[
    (_DockCount.long, true),
    (_DockCount.short, true),
    (_DockCount.hidden, true),
    (_DockCount.hidden, false),
  ];
  for (final (rungCount, labelled) in rungs) {
    if (rungCount != _DockCount.hidden && count == null) continue;
    final countWidth = switch (rungCount) {
      _DockCount.long => longWidth,
      _DockCount.short => shortWidth,
      _DockCount.hidden => 0.0,
    };
    final room = roomFor(
      countWidth: countWidth,
      venueWidth: labelled ? labelledVenue : _venueIconOnlyWidth,
    );
    if (nameWidth <= room) {
      return _DockPlan(
        count: rungCount,
        venueLabelled: labelled,
        nameLines: 1,
        nameFontSize: nameStyle.fontSize ?? _nameFontSize,
      );
    }
  }
  // Nothing else left to give: the name wraps rather than losing letters.
  return const _DockPlan(
    count: _DockCount.hidden,
    venueLabelled: false,
    nameLines: 2,
    nameFontSize: _wrappedNameFontSize,
  );
}

/// How wide [value] draws on one line in [style].
double _textWidth(
  String value,
  TextStyle style,
  TextScaler scaler,
  TextDirection direction,
) {
  final painter = TextPainter(
    text: TextSpan(text: value, style: style),
    textDirection: direction,
    textScaler: scaler,
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// How many seats are left in [section] for the buyer looking at it.
///
/// The runtime counts a seat as available until it is held, so a section the
/// buyer has just taken two seats out of still reported its whole free count —
/// the dock said `74 left` while two of those seventy-four were in the buyer's
/// own cart. Their own picks come off, so the number moves as they choose.
///
/// Only seats that name this section can be attributed to it; a selection with
/// no section on it leaves the count alone rather than guessing.
int? _seatsLeftForBuyer(
  SeatLayerPickerSectionSummary section,
  List<SelectedSeat> selection,
) {
  final left = section.seatsLeft;
  if (left == null || selection.isEmpty) return left;
  final names = <String>{
    section.label.trim().toLowerCase(),
    if (section.displayLabel != null)
      section.displayLabel!.trim().toLowerCase(),
  }..removeWhere((name) => name.isEmpty);
  if (names.isEmpty) return left;
  var mine = 0;
  for (final seat in selection) {
    final where = seat.sectionLabel?.trim().toLowerCase();
    if (where != null && names.contains(where)) mine += 1;
  }
  final remaining = left - mine;
  return remaining < 0 ? 0 : remaining;
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
    this.maxLines = 1,
  });

  final String value;
  final TextStyle style;
  final bool softWrap;

  /// How many lines the value may take before it ellipsizes.
  final int maxLines;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: SeatLayerPickerMotion.of(
          context,
          SeatLayerPickerMotion.crossfade,
        ),
        child: Text(
          value,
          key: ValueKey<String>(value),
          maxLines: maxLines,
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
