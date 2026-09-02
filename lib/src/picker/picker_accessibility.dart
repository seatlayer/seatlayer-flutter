/// The accessibility and view filters, and the sheet that edits them.

library;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_tokens.g.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'picker_styles.dart';
import 'seat_layer_picker_theme.dart';

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
    final icon = provisions
        ? Icons.accessible_forward_rounded
        : Icons.palette_outlined;
    if (compact) {
      final theme = seatLayerPickerThemeOf(context);
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
              backgroundColor: theme.surface,
              foregroundColor: activeCount == 0 ? theme.text : theme.accent,
              side: BorderSide(color: theme.divider),
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
    final snapshot = controller.state.snapshot;
    final available = _availability(controller, snapshot);
    if (!available.any || snapshot == null) return;
    final initial = <String>{
      if (available.accessibility) ...snapshot.map.accessibilityFilter,
    };
    final initialHideLimited =
        available.limited && snapshot.map.hideLimitedView;
    final initialColorblind =
        available.colorblind && snapshot.map.colorblindSafe;
    var selected = initial;
    var hideLimited = initialHideLimited;
    var colorblind = initialColorblind;
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
                            value: on,
                            onChanged: enabled
                                ? () => setSheetState(() {
                                      selected = <String>{...selected};
                                      on
                                          ? selected.remove(need.key)
                                          : selected.add(need.key);
                                    })
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
                    onChanged: () =>
                        setSheetState(() => hideLimited = !hideLimited),
                  ),
                if (available.colorblind)
                  _AccessOptionRow(
                    icon: Icons.contrast_rounded,
                    label: strings.colorblindSafe,
                    value: colorblind,
                    onChanged: () =>
                        setSheetState(() => colorblind = !colorblind),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  style: seatLayerButtonShape(theme.buttonRadius),
                  onPressed: () => Navigator.of(context).pop(
                    (
                      types: selected,
                      hideLimited: hideLimited,
                      colorblind: colorblind,
                    ),
                  ),
                  child: Text(strings.applyFilters),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final result = await showModalBottomSheet<
        ({
          Set<String> types,
          bool hideLimited,
          bool colorblind,
        })>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.surface,
      builder: (_) => body,
    );
    if (result == null) return;
    final live = _availability(controller, controller.state.snapshot);
    if (live.accessibility && !setEquals(result.types, initial)) {
      await controller.setAccessibilityFilter(result.types);
    }
    if (live.limited && result.hideLimited != initialHideLimited) {
      await controller.setLimitedViewHidden(result.hideLimited);
    }
    if (live.colorblind && result.colorblind != initialColorblind) {
      await controller.setColorblindSafe(result.colorblind);
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
  });

  final IconData icon;
  final String label;
  final String? note;
  final String? count;
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
                              fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w600,
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
                      Text(
                        count!,
                        style: TextStyle(
                          color: theme.mutedText,
                          fontSize: SeatLayerSizeTokens.accessRowNoteFontSize,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                          fontFamily: theme.fontFamily,
                        ),
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
          alignment:
              on ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
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
