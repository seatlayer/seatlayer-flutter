import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_a11y.dart';
import 'picker_accessibility_focus.dart';
import 'picker_internal.dart';
import 'picker_styles.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_tokens.g.dart';
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

  /// How tall the bar is here, once the platform's text size has had its say.
  ///
  /// Fifty-two points is a height for type at 1.0. The name, the count and the
  /// Venue word all grow with the buyer's setting, and a bar that stayed
  /// fifty-two would clip them. Public because the composition that stacks the
  /// dock on the map also has to tell the runtime what band it covers, and a
  /// reported band that disagrees with the drawn one frames a section half
  /// underneath it.
  static double heightFor(BuildContext context) => seatLayerScaledExtent(
        context,
        seatLayerPickerThemeOf(context).layout.dockBarHeight,
        max: SeatLayerTypeScaleTokens.dock,
      );

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final snapshot = controller.state.snapshot;
    final section = _focusedSection(snapshot);
    final theme = seatLayerPickerThemeOf(context);
    final bottomInset =
        reserveBottomInset ? MediaQuery.paddingOf(context).bottom : 0.0;
    final height = SeatLayerDockBar.heightFor(context);
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
    // `· ♿ 2` — of the seats left here, how many carry a provision the buyer
    // is filtering on. Only where the runtime counts them AND a filter is on:
    // the figure answers "does the section I am standing in have what I
    // need", which is not a question anyone is asking without a filter.
    final accessSuffix = _accessibleSuffix(controller, section);
    final onOverviewPressed = busy
        ? null
        : onOverview ?? () => ignorePickerAction(controller.overview());

    final nameStyle = TextStyle(
      color: theme.text,
      fontSize: _nameFontSize,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
      fontFamily: theme.fontFamily,
    );
    // The count is drawn in the text colour, not the muted one: it is the
    // fact the buyer is standing here to read, and a section with four seats
    // left must not whisper it.
    final countStyle = TextStyle(
      color: theme.text,
      fontSize: _countFontSize,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
      fontFamily: theme.fontFamily,
    );
    final venueStyle = TextStyle(
      color: theme.accent,
      fontSize: _venueFontSize,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
      fontFamily: theme.fontFamily,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // The suffix rides on both rungs of the fit ladder, so the width it
        // needs is measured rather than discovered after layout.
        final countLong = count == null
            ? null
            : '${strings.seatsLeftInSection(count)}${accessSuffix ?? ''}';
        final countShort = count == null
            ? null
            : '${strings.seatsLeft(count)}${accessSuffix ?? ''}';
        final plan = _planDock(
          context,
          width: constraints.maxWidth,
          name: name,
          nameStyle: nameStyle,
          count: count,
          countLong: countLong,
          countShort: countShort,
          countStyle: countStyle,
          venueLabel: strings.overview,
          venueStyle: venueStyle,
        );
        final shownCount = switch (plan.count) {
          _DockCount.long => countLong,
          _DockCount.short => countShort,
          _DockCount.hidden => null,
        };

        return Row(
          children: [
            const SizedBox(width: _leadingInset),
            DecoratedBox(
              decoration: BoxDecoration(
                color: pickerSectionColor(
                  section,
                  controller.state.categories,
                  fallback: theme.accent,
                ),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: _dotSize),
            ),
            const SizedBox(width: _itemGap),
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
              // Where the buyer is, said once, whenever it changes. The dock
              // is how a buyer moves between sections, and stepping to the
              // next one changes nothing else on screen that a screen reader
              // would notice — so the bar says where they have arrived and
              // how much room is left there. The COUNT is spoken even at the
              // widths that cannot draw it: what fits on a 320-point row is
              // not a fact about what the buyer needs to know.
              child: Semantics(
                liveRegion: true,
                container: true,
                label: count == null
                    ? name
                    : '$name, ${strings.seatsLeftInSection(count)}'
                        '${accessSuffix ?? ''}',
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      Flexible(
                        child: _CrossfadeText(
                          value: name,
                          maxLines: plan.nameLines,
                          style:
                              nameStyle.copyWith(fontSize: plan.nameFontSize),
                        ),
                      ),
                      if (shownCount != null) ...[
                        const SizedBox(width: _itemGap),
                        _CrossfadeText(
                          value: shownCount,
                          softWrap: false,
                          style: countStyle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: _itemGap),
            _StepButton(
              icon: Icons.arrow_back_rounded,
              tooltip: strings.previousSection,
              onPressed: previous == null || busy
                  ? null
                  : () => _step(controller, previous),
            ),
            const SizedBox(width: _stepGap),
            _StepButton(
              icon: Icons.arrow_forward_rounded,
              tooltip: strings.nextSection,
              onPressed:
                  next == null || busy ? null : () => _step(controller, next),
            ),
            const SizedBox(width: _venueGap),
            if (plan.venueLabelled)
              _VenueButton(
                label: strings.overview,
                style: venueStyle,
                onPressed: onOverviewPressed,
              )
            else
              // The narrowest rung. The control keeps its name for anyone
              // reading the screen; only the drawn word goes.
              _StepButton(
                icon: Icons.chevron_left_rounded,
                tooltip: strings.overview,
                onPressed: onOverviewPressed,
              ),
            const SizedBox(width: _trailingInset),
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
const double _nameFontSize = SeatLayerSizeTokens.dockNameFontSize;
const double _countFontSize = SeatLayerSizeTokens.dockCountFontSize;
const double _venueFontSize = SeatLayerSizeTokens.dockBackFontSize;

/// The size the name drops to once it needs a second line.
///
/// Two lines at the full size would crowd a 52-point bar; this leaves the
/// same breathing room above and below that one full-size line has.
const double _wrappedNameFontSize = 12;

/// The dot naming the section's colour.
const double _dotSize = SeatLayerSizeTokens.dockDotSize;

/// The gap between two pieces of the row.
const double _itemGap = 7;

/// The gap between the two section step buttons.
const double _stepGap = SeatLayerSizeTokens.dockNavGap;

/// The gutters at each end of the bar.
const double _leadingInset = SeatLayerSizeTokens.dockLeadingInset;
const double _trailingInset = SeatLayerSizeTokens.dockTrailingInset;

/// Everything the row spends before the name gets any width.
///
/// The leading gutter, the category dot and the gap after it.
const double _leadingWidth = _leadingInset + _dotSize + _itemGap;

/// What one step control occupies.
///
/// The drawn pill is [SeatLayerSizeTokens.dockNavWidth] wide and the control
/// measures exactly that: it is laid out at a tight size rather than left to
/// Material's own tap-target padding, which is what the taller hit box around
/// it is for. `the dock never overflows` in `picker_dock_bar_test.dart` fails
/// if this ever drifts, because an underestimate here is a row that overflows.
const double _stepWidth = SeatLayerSizeTokens.dockNavWidth;

/// The two section step buttons and the gap between them. They never give way
/// — they are how the buyer moves, and a dock without them is a label.
const double _stepsWidth = _stepWidth * 2 + _stepGap;

/// The gap between the steps and the way back to the venue.
const double _venueGap = 2;

/// Horizontal padding inside the labelled Venue pill: tighter behind the
/// chevron than in front of the word, so the two read as one shape.
const double _venuePaddingStart = 6;
const double _venuePaddingEnd = 10;

/// The Venue pill's chevron, and the gap after it.
const double _venueIconWidth = SeatLayerSizeTokens.dockBackChevronSize + 2;

/// The Venue control once it is only its chevron.
const double _venueIconOnlyWidth = _stepWidth;

/// How much of the count survives at this width.
enum _DockCount {
  /// `72 seats left` — the count and the word that says what it counts.
  long,

  /// `72 left` — the same count, shorter of a word.
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
  required String? countShort,
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
  final longWidth =
      countLong == null ? 0.0 : _itemGap + measure(countLong, countStyle);
  final shortWidth =
      countShort == null ? 0.0 : _itemGap + measure(countShort, countStyle);
  final labelledVenue = _venuePaddingStart +
      _venueIconWidth +
      measure(venueLabel, venueStyle) +
      _venuePaddingEnd;

  double roomFor({required double countWidth, required double venueWidth}) =>
      width -
      _leadingWidth -
      countWidth -
      _itemGap -
      _stepsWidth -
      _venueGap -
      venueWidth -
      _trailingInset;

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
/// ` · ♿ 2` for the focused section, or null where there is nothing to say.
///
/// Three things have to be true: the runtime advertises the counts, the buyer
/// has a filter on, and this section was actually counted for one of the
/// provisions in it. A section with no entry was NOT COUNTED — a different
/// fact from zero — and stays silent rather than claiming to be full.
String? _accessibleSuffix(
  SeatLayerPickerController controller,
  SeatLayerPickerSectionSummary section,
) {
  if (!controller.supportsSectionAccessCounts) return null;
  final active = <String>{
    ...?controller.state.snapshot?.map.accessibilityFilter,
  };
  if (active.isEmpty) return null;
  // The counts ride the catalog's section entries; the map's own focused
  // summary is a lighter record that never carries them, so the catalog entry
  // with the same id is the one to read.
  final catalog = controller.state.snapshot?.sections ?? const [];
  var counted = section;
  for (final entry in catalog) {
    if (entry.id == section.id) {
      counted = entry;
      break;
    }
  }
  final free = seatLayerSectionAccessibleFree(counted, active);
  if (free == null || free <= 0) return null;
  return ' · ♿ $free';
}

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

/// The labelled way out: `‹ Venue`.
///
/// Outlined in the accent rather than filled with it. A filled pill would be
/// the loudest thing in the bar, and the loudest thing in a seat picker is
/// never the exit; a 12 % accent wash behind the word was tried on the web and
/// measured 4.2:1, so the ground stays the plain surface.
class _VenueButton extends StatelessWidget {
  const _VenueButton({
    required this.label,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final TextStyle style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        height: SeatLayerSizeTokens.minimumHitTarget,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
          ),
          child: Container(
            height: seatLayerScaledExtent(
              context,
              SeatLayerSizeTokens.dockBackHeight,
              max: SeatLayerTypeScaleTokens.dock,
            ),
            padding: const EdgeInsetsDirectional.only(
              start: _venuePaddingStart,
              end: _venuePaddingEnd,
            ),
            decoration: ShapeDecoration(
              color: theme.surface,
              shape: StadiumBorder(
                side: BorderSide(
                  color: Color.alphaBlend(
                    pickerAlpha(theme.accent, .55),
                    theme.divider,
                  ),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.chevron_left_rounded,
                  size: SeatLayerSizeTokens.dockBackChevronSize,
                  color: theme.accent,
                ),
                const SizedBox(width: 2),
                Text(label, style: style),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    final enabled = onPressed != null;
    // The drawn pill is 34 × 36 and the control that carries it is 34 × 44:
    // the bar has the height to give, and a 36-point target is under the
    // touch floor. The pill is the button's icon so the taller box stays
    // invisible.
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: _stepWidth,
        height: SeatLayerSizeTokens.minimumHitTarget,
      ),
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Container(
        width: _stepWidth,
        height: SeatLayerSizeTokens.dockNavHeight,
        decoration: ShapeDecoration(
          color: Color.alphaBlend(
            pickerAlpha(theme.surface, .88),
            theme.background,
          ),
          shape: StadiumBorder(side: BorderSide(color: theme.divider)),
        ),
        child: Icon(
          icon,
          size: SeatLayerSizeTokens.dockNavIconSize,
          color: enabled ? theme.text : pickerAlpha(theme.mutedText, .4),
        ),
      ),
    );
  }
}
