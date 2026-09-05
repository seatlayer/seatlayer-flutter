/// The accessibility and view filters, and the sheet that edits them.

library;

import 'package:flutter/material.dart';

import 'picker_accessibility_focus.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_pending_seat.dart';
import 'picker_tokens.g.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'picker_strings.dart';
import 'picker_styles.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

/// The filters a buyer with an access need reaches for.
///
/// On the phone this is one 44-point control at the map's bottom-left corner,
/// and the colourblind-safe palette lives inside it rather than as its own
/// button on the map — which is where someone who needs it goes looking.
class SeatLayerPickerAccessibilityFilters extends StatelessWidget {
  /// Creates the accessibility filter control.
  const SeatLayerPickerAccessibilityFilters({
    super.key,
    this.compact = false,
  });

  /// Whether to render the phone's single round control.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final snapshot = state.snapshot;
    final controller = SeatLayerPickerScope.controllerOf(context);
    final available = _availability(controller, snapshot);
    if (!available.any) {
      return const SizedBox.shrink();
    }
    final activeCount = (available.accessibility
            ? snapshot!.map.accessibilityFilter.length
            : 0) +
        (available.limited && snapshot?.map.hideLimitedView == true ? 1 : 0) +
        (available.colorblind && snapshot?.map.colorblindSafe == true ? 1 : 0);
    final onPressed =
        state.isBusy ? null : () => ignorePickerAction(_show(context));
    final strings = SeatLayerPickerScope.stringsOf(context);
    // A chart with no access provisions at all has nothing behind this
    // control but how the map is drawn, and the icon says which of the two
    // this is before it is opened: the ISO wheelchair when the venue authors
    // provisions, a palette when all it offers is colour.
    final provisions = available.accessibility;
    final name = provisions ? strings.accessibility : strings.displayOptions;
    final icon =
        provisions ? Icons.accessible_forward_rounded : Icons.palette_outlined;
    if (compact) {
      // Floating on the venue, so the MAP's palette and the disc's own ground
      // — the panel surface vanishes into a dark map at 1.14:1.
      final theme = seatLayerMapChromeThemeOf(context);
      final disc = seatLayerMapChromeDisc(theme);
      final size = theme.layout.accessibilityControlSize;
      return DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 20,
              spreadRadius: -12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: size,
          child: IconButton(
            tooltip: activeCount == 0
                ? name
                : '$activeCount accessibility filters active',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: size, height: size),
            style: IconButton.styleFrom(
              backgroundColor: disc.ground,
              foregroundColor: activeCount == 0 ? theme.text : theme.accent,
              side: BorderSide(color: disc.line),
            ),
            onPressed: onPressed,
            icon: Badge(
              isLabelVisible: activeCount > 0,
              label: Text('$activeCount'),
              child: Icon(icon, size: _controlIconSize),
            ),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      style: seatLayerButtonShape(
        seatLayerPickerThemeOf(context).buttonRadius,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(activeCount == 0 ? name : '$activeCount filters'),
    );
  }

  Future<void> _show(BuildContext context) async {
    final controller = SeatLayerPickerScope.controllerOf(context);
    var snapshot = controller.state.snapshot;
    var available = _availability(controller, snapshot);
    if (!available.any || snapshot == null) return;
    // Only one decision surface may hold the screen. A seat card left standing
    // behind this sheet is a question the buyer can neither read nor answer,
    // so it comes down first — the same clearing the web picker does before
    // any surface goes up (`SeatPicker.clearDecisionSurfaces`).
    await controller.cancelPendingSeat();
    if (!context.mounted) return;
    // Giving the seat back moved the cart, so the sheet is built from what the
    // runtime says now rather than from what it said before the card went.
    snapshot = controller.state.snapshot;
    available = _availability(controller, snapshot);
    if (!available.any || snapshot == null) return;
    // The switches draw from this and the runtime is told as each one moves;
    // there is no staged copy waiting on a button, because a switch IS the
    // action.
    var selected = <String>{
      if (available.accessibility) ...snapshot.map.accessibilityFilter,
    };
    var hideLimited = available.limited && snapshot.map.hideLimitedView;
    var colorblind = available.colorblind && snapshot.map.colorblindSafe;
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    // What this EVENT actually offers, in the runtime's own order, named from
    // the string table. One the table has no name for is drawn under its wire
    // key rather than dropped, so a need added on the runtime side is
    // reachable before this side catches up.
    //
    // Missing inventory truth fails closed. The static twelve-key vocabulary
    // is not evidence that this event has any of those seats.
    final offered = snapshot.map.accessNeeds;
    // The count only becomes a button where the runtime answers the tour.
    final canJump = controller.supportsAccessibilityFocus;
    // The companion note is only true of a chart that authors companion
    // places, so it is drawn from the same inventory the rows are.
    final hasCompanionPlaces =
        offered.any((need) => need.key == _companionNeedKey);
    final needs = <_AccessNeedRow>[
      if (available.accessibility)
        for (final need in offered)
          _AccessNeedRow(
            key: need.key,
            label: strings.accessNeeds[need.key] ?? need.key,
            count: need.count,
            note: hasCompanionPlaces && need.key == _wheelchairNeedKey
                ? strings.companionSeatsNote
                : null,
          )
    ];
    // Each switch goes straight to the runtime. Availability is re-read at the
    // moment of the flip, not captured when the sheet opened: a snapshot that
    // arrives while it is up can withdraw a capability under it.
    Future<void> applyTypes(Set<String> next) async {
      if (!_availability(controller, controller.state.snapshot).accessibility) {
        return;
      }
      // Since runtime 0.77.1 the command carries the web menu's own flight:
      // turning a filter ON flies to the matching spaces, or holds the venue
      // rung with the spread hint where they span it. Nothing to follow it
      // with — the interim `picker.overview` this used to send is gone.
      await controller.setAccessibilityFilter(next);
      // A filter the buyer has just changed invalidates whatever walk was
      // under way over the old one.
      if (controller.supportsAccessibilityFocus) {
        seatLayerAccessibleTourOf(controller).reset();
      }
    }

    Future<void> applyLimited(bool next) async {
      if (!_availability(controller, controller.state.snapshot).limited) return;
      await controller.setLimitedViewHidden(next);
    }

    Future<void> applyColorblind(bool next) async {
      if (!_availability(controller, controller.state.snapshot).colorblind) {
        return;
      }
      await controller.setColorblindSafe(next);
    }

    // The sheet body is built INSIDE the scope and handed to the route, so the
    // route's builder — which runs under the Navigator overlay, above the
    // scope — still gets the picker's controller, strings and palette.
    final body = SeatLayerPickerScope.inherit(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.accessibilityTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (needs.isNotEmpty)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: needs.map((need) {
                          final on = selected.contains(need.key);
                          // A need with nothing free stays on the sheet and
                          // goes dark. Removing it would claim the venue has no
                          // such seats, which is a different fact.
                          final enabled = need.count == null || need.count! > 0;
                          return _AccessOptionRow(
                            icon: Icons.accessible_rounded,
                            label: need.label,
                            note: need.note,
                            count: need.count == null
                                ? null
                                : need.count! > 0
                                    ? strings.accessFreeCount(need.count!)
                                    : strings.accessNoneLeft,
                            // The web menu's own "12 free" button, which steps
                            // the camera through the sections that hold them.
                            // Only where the runtime can fly and there is
                            // something to fly to; otherwise the number stays
                            // the static fact it has always been.
                            countLabel: canJump && (need.count ?? 0) > 0
                                ? '${need.label}, '
                                    '${strings.accessFreeCount(need.count!)}, '
                                    '${strings.accessJumpFirstSection}'
                                : null,
                            // The one control on the sheet that is not a
                            // switch, and the one that closes it: the walk it
                            // starts happens on the map this sheet covers.
                            onCountPressed: canJump && (need.count ?? 0) > 0
                                ? () => Navigator.of(context).pop(need.key)
                                : null,
                            value: on,
                            onChanged: enabled
                                ? () {
                                    final next = <String>{...selected};
                                    on
                                        ? next.remove(need.key)
                                        : next.add(need.key);
                                    setSheetState(() => selected = next);
                                    ignorePickerAction(applyTypes(next));
                                  }
                                : null,
                          );
                        }).toList(growable: false),
                      ),
                    ),
                  ),
                if (available.limited)
                  _AccessOptionRow(
                    icon: Icons.contrast_rounded,
                    label: strings.hideLimitedView,
                    value: hideLimited,
                    onChanged: () {
                      final next = !hideLimited;
                      setSheetState(() => hideLimited = next);
                      ignorePickerAction(applyLimited(next));
                    },
                  ),
                if (available.colorblind)
                  _AccessOptionRow(
                    icon: Icons.contrast_rounded,
                    label: strings.colorblindSafe,
                    value: colorblind,
                    onChanged: () {
                      final next = !colorblind;
                      setSheetState(() => colorblind = next);
                      ignorePickerAction(applyColorblind(next));
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // Every switch has already been sent by the time this returns; the only
    // thing the sheet hands back is the provision a pressed count asked to
    // walk, if any. Drag-down and the scrim close it with nothing, which is
    // exactly right — there is nothing left to apply.
    final jumpTo = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.surface,
      builder: (_) => body,
    );
    if (jumpTo == null) return;
    // A pressed count turns its own provision on, then starts a walk over that
    // provision alone.
    if (!selected.contains(jumpTo)) {
      selected = <String>{...selected, jumpTo};
      await applyTypes(selected);
    }
    if (controller.supportsAccessibilityFocus) {
      final tour = seatLayerAccessibleTourOf(controller);
      tour.begin(<String>{jumpTo});
      await tour.next(controller);
    }
  }
}

_FilterAvailability _availability(
  SeatLayerPickerController controller,
  SeatLayerPickerSnapshot? snapshot,
) {
  final bundle = controller.mapController.bundleInfo;
  final nativeChrome =
      bundle?.supportsCapability('native-chrome-contract-v1') == true;
  final accessibility = snapshot != null &&
      snapshot.capabilities.contains('accessibilityFilter') &&
      controller.supportsAccessNeeds &&
      snapshot.map.accessNeeds.isNotEmpty &&
      nativeChrome &&
      bundle?.supportsCommand('picker.setAccessibilityFilter') == true;
  final limited = snapshot != null &&
      snapshot.capabilities.contains('limitedViewFilter') &&
      nativeChrome &&
      bundle?.supportsCommand('picker.setLimitedViewFilter') == true;
  final colorblind = snapshot != null &&
      nativeChrome &&
      bundle?.supportsCapability('colorblind-safe') == true &&
      bundle?.supportsCommand('picker.setColorblindSafe') == true;
  return _FilterAvailability(
    accessibility: accessibility,
    limited: limited,
    colorblind: colorblind,
  );
}

@immutable
class _FilterAvailability {
  const _FilterAvailability({
    required this.accessibility,
    required this.limited,
    required this.colorblind,
  });

  final bool accessibility;
  final bool limited;
  final bool colorblind;

  bool get any => accessibility || limited || colorblind;
}

/// One row on the accessibility sheet.
///
/// [count] is nullable for forward-compatible callers even though current
/// inventory reports include it. A `null` count means "not counted": the row
/// draws no number and is never disabled, which is different from zero.
@immutable
class _AccessNeedRow {
  const _AccessNeedRow({
    required this.key,
    required this.label,
    this.count,
    this.note,
  });

  final String key;
  final String label;
  final int? count;
  final String? note;
}

/// The runtime's own key for the two provisions the sheet says more about.
const String _wheelchairNeedKey = 'wheelchair';
const String _companionNeedKey = 'companion';

/// How large the map control's drawn glyph is.
const double _controlIconSize = 21;

/// One switchable line: an icon cell, what it is, how many are free, and the
/// switch that turns it on.
///
/// The whole row is the control — a 44-point line, not a 20-point switch at
/// the end of one — so the buyer aims at the words rather than at the toggle.
class _AccessOptionRow extends StatelessWidget {
  const _AccessOptionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.note,
    this.count,
    this.countLabel,
    this.onCountPressed,
  });

  final IconData icon;
  final String label;
  final String? note;
  final String? count;

  /// What a screen reader calls the count when it is pressable.
  final String? countLabel;

  /// Start the accessible-section tour on this provision, or null to leave the
  /// count the static fact it is on a runtime that cannot fly.
  final VoidCallback? onCountPressed;

  final bool value;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      // Explicit, so the pressable count inside stays its own button rather
      // than being folded into the row's toggle: the two do different things
      // and a buyer who only hears "Wheelchair, on" cannot find the jump.
      explicitChildNodes: onCountPressed != null,
      child: Opacity(
        opacity: enabled ? 1 : _disabledRowOpacity,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onChanged,
            borderRadius: BorderRadius.circular(theme.buttonRadius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: SeatLayerSizeTokens.minimumHitTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SeatLayerSizeTokens.accessRowPaddingX,
                  vertical: SeatLayerSizeTokens.accessRowPaddingY,
                ),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: SeatLayerSizeTokens.accessRowIconCell,
                      child: Icon(icon, size: 16, color: theme.mutedText),
                    ),
                    const SizedBox(width: SeatLayerSizeTokens.accessRowGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            label,
                            style: TextStyle(
                              color: theme.text,
                              fontSize:
                                  SeatLayerSizeTokens.accessRowLabelFontSize,
                              fontWeight:
                                  seatLayerBoldWeight(context, FontWeight.w700),
                              height: 1.25,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                          if (note != null) ...<Widget>[
                            const SizedBox(height: 1),
                            Text(
                              note!,
                              style: TextStyle(
                                color: theme.mutedText,
                                fontSize:
                                    SeatLayerSizeTokens.accessRowNoteFontSize,
                                fontWeight: seatLayerBoldWeight(
                                    context, FontWeight.w600),
                                height: 1.3,
                                fontFamily: theme.fontFamily,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (count != null) ...<Widget>[
                      const SizedBox(width: SeatLayerSizeTokens.accessRowGap),
                      _AccessCount(
                        count: count!,
                        label: countLabel,
                        onPressed: enabled ? onCountPressed : null,
                        theme: theme,
                      ),
                    ],
                    const SizedBox(width: SeatLayerSizeTokens.accessRowGap),
                    _AccessSwitch(on: value, theme: theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "12 free" at the end of a row — a fact, or the button that starts the
/// accessible-section tour.
///
/// One widget for both because the number must not move when it becomes
/// pressable: the pill is drawn around the same text at the same size, so a
/// runtime that gains the capability does not also reflow the sheet.
class _AccessCount extends StatelessWidget {
  const _AccessCount({
    required this.count,
    required this.label,
    required this.onPressed,
    required this.theme,
  });

  final String count;
  final String? label;
  final VoidCallback? onPressed;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      count,
      style: TextStyle(
        color: onPressed == null ? theme.mutedText : theme.accent,
        fontSize: SeatLayerSizeTokens.accessRowNoteFontSize,
        fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        fontFamily: theme.fontFamily,
      ),
    );
    if (onPressed == null) return text;
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          // Drawn as a pill around the number, but claiming the full hit
          // target: the count is small type at the end of a row and a buyer
          // reaching for it with a thumb must not have to aim.
          constraints: const BoxConstraints(
            minWidth: SeatLayerSizeTokens.minimumHitTarget,
            minHeight: SeatLayerSizeTokens.minimumHitTarget,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius:
                  BorderRadius.circular(SeatLayerRadiusTokens.pill),
              child: Center(
                widthFactor: 1,
                child: Container(
                  height: SeatLayerSizeTokens.accessStepHeight,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SeatLayerSizeTokens.accessStepPaddingX,
                  ),
                  decoration: ShapeDecoration(
                    color: pickerAlpha(theme.accent, .12),
                    shape: StadiumBorder(
                      side: BorderSide(color: theme.divider),
                    ),
                  ),
                  child: text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `♿ 2 of 6 ›` — where the accessible-section tour has got to, and the way to
/// its next stop.
///
/// The web draws no such control: its menu is a popover over the map, so the
/// count it steps from is still on screen while the camera moves. The phone's
/// sheet covers the map and has to close, so the walk needs somewhere visible
/// to continue from, and this is it.
class SeatLayerPickerAccessibleStepper extends StatelessWidget {
  /// Creates the accessible-section stepper.
  const SeatLayerPickerAccessibleStepper({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = SeatLayerPickerScope.stateOf(context);
    final snapshot = state.snapshot;
    final active = <String>{...?snapshot?.map.accessibilityFilter};
    // No filter, or a runtime that cannot fly: there is no walk to narrate.
    if (active.isEmpty || !controller.supportsAccessibilityFocus) {
      return const SizedBox.shrink();
    }
    final tour = seatLayerAccessibleTourOf(controller);
    return AnimatedBuilder(
      animation: tour,
      builder: (context, _) => _build(context, controller, snapshot, active,
          tour, SeatLayerPickerScope.stringsOf(context)),
    );
  }

  Widget _build(
    BuildContext context,
    SeatLayerPickerController controller,
    SeatLayerPickerSnapshot? snapshot,
    Set<String> active,
    SeatLayerAccessibleTour tour,
    SeatLayerPickerStrings strings,
  ) {
    // A walk over provisions the buyer has since turned off is not this
    // filter's walk. It is read as "not started" rather than reset here,
    // because a notifier must not fire from inside a build.
    final current = tour.types.isNotEmpty &&
        tour.types.every((type) => active.contains(type));
    final step = current ? tour.step : null;
    // The runtime answered that nothing matches: the pill goes, rather than
    // standing there offering a step that cannot be taken.
    if (current && tour.exhausted) return const SizedBox.shrink();

    final counted = controller.supportsSectionAccessCounts;
    final sections = counted
        ? seatLayerAccessibleSectionCount(snapshot, current ? tour.types : active)
        : 0;
    // Where the counts ARE reported and none of them is positive, there is
    // nothing to walk. Where they are not reported at all, the pill is drawn
    // with no figure until the first step answers — a runtime that can fly
    // but does not count still has a tour worth offering.
    if (counted && step == null && sections == 0) {
      return const SizedBox.shrink();
    }
    final label = step != null
        ? strings.accessibleStep(step.index + 1, step.total)
        : counted
            ? strings.accessibleSections(sections)
            : null;

    final theme = seatLayerPickerThemeOf(context);
    final busy = tour.walking || controller.state.isBusy;
    return Semantics(
      button: true,
      enabled: !busy,
      label: label == null
          ? strings.accessJumpNextSection
          : '$label, ${strings.accessJumpNextSection}',
      child: ExcludeSemantics(
        child: AnimatedSwitcher(
          // The runtime owns the camera, and does the right thing under
          // reduced motion; the pill itself only ever fades.
          duration: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.crossfade,
          ),
          child: _StepperPill(
            key: ValueKey<String>(label ?? ''),
            label: label,
            theme: theme,
            onPressed: busy
                ? null
                : () => ignorePickerAction(_step(controller, tour, active)),
          ),
        ),
      ),
    );
  }

  Future<void> _step(
    SeatLayerPickerController controller,
    SeatLayerAccessibleTour tour,
    Set<String> active,
  ) async {
    final current = tour.types.isNotEmpty &&
        tour.types.every((type) => active.contains(type));
    if (!current) tour.begin(active);
    await tour.next(controller);
  }
}

/// The drawn pill. Separated so the switcher can cross-fade one label into the
/// next without rebuilding the gesture around it.
class _StepperPill extends StatelessWidget {
  const _StepperPill({
    super.key,
    required this.label,
    required this.theme,
    required this.onPressed,
  });

  final String? label;
  final SeatLayerResolvedPickerTheme theme;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: theme.text,
      fontSize: SeatLayerSizeTokens.accessStepFontSize,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      fontFamily: theme.fontFamily,
      height: 1,
    );
    return ConstrainedBox(
      // Thirty points drawn inside a forty-four point target, so the pill sits
      // beside the round control without out-weighing it and is still thumbable.
      constraints: const BoxConstraints(
        minHeight: SeatLayerSizeTokens.minimumHitTarget,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
          child: Center(
            widthFactor: 1,
            child: Container(
              height: SeatLayerSizeTokens.accessStepHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: SeatLayerSizeTokens.accessStepPaddingX,
              ),
              decoration: ShapeDecoration(
                color: theme.surface,
                shape: StadiumBorder(side: BorderSide(color: theme.divider)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.accessible_rounded,
                    size: _stepperGlyphSize,
                    color: theme.accent,
                  ),
                  if (label != null) ...<Widget>[
                    const SizedBox(width: SeatLayerSizeTokens.accessStepGap),
                    Text(label!, style: style),
                  ],
                  const SizedBox(width: SeatLayerSizeTokens.accessStepGap),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: _stepperChevronSize,
                    color: theme.mutedText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The wheelchair mark on the stepper, sized to its eleven-point type.
const double _stepperGlyphSize = 14;

/// The stepper's chevron, one step larger so the direction reads at a glance.
const double _stepperChevronSize = 16;

/// A row that cannot be turned on is dimmed rather than removed.
const double _disabledRowOpacity = .58;

/// The switch drawn at the end of a row.
///
/// Drawn rather than a Material [Switch]: the platform control is half again
/// as tall as this line and would set the row's height instead of sitting in
/// it. The row carries the semantics, so this is decoration.
class _AccessSwitch extends StatelessWidget {
  const _AccessSwitch({required this.on, required this.theme});

  final bool on;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) {
    const width = SeatLayerSizeTokens.accessSwitchWidth;
    const height = SeatLayerSizeTokens.accessSwitchHeight;
    const knob = SeatLayerSizeTokens.accessSwitchKnob;
    const inset = (height - knob) / 2;
    final duration = SeatLayerPickerMotion.of(
      context,
      SeatLayerPickerMotion.crossfade,
    );
    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.ease,
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: on ? theme.accent : pickerAlpha(theme.mutedText, .32),
          shape: const StadiumBorder(),
        ),
        child: AnimatedAlign(
          duration: duration,
          curve: Curves.ease,
          alignment: on
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: inset),
            child: Container(
              width: knob,
              height: knob,
              decoration: BoxDecoration(
                color: theme.surface,
                shape: BoxShape.circle,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
