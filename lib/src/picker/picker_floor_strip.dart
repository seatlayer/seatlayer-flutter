/// Which floor of the building the buyer is looking at.
library;

import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_styles.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// A chip row naming the floors of a multi-floor venue.
///
/// A theatre stacked three levels deep drawn all at once is a picture of a
/// building, not a plan of one: the stalls, the circle and the gallery overlap
/// and the buyer cannot tell which seats are where. The web picker answers
/// that with a strip of floor chips and one floor drawn at a time, and this is
/// the same control natively.
///
/// **It renders nothing unless there is a choice to make**: no floors, one
/// floor, or a runtime that does not report floors at all, and the strip is an
/// empty box. The "All floors" chip needs BOTH halves of the runtime's word —
/// the `floor-stack-v1` capability, which says the runtime has modes, and a
/// reported `floorMode`, which says which one it is in. A chip drawn on one
/// half alone would send `'all'` to a runtime with no such floor.
///
/// The floors are drawn in the order the snapshot gave them, which is the
/// venue's own order from the stage upward. Nothing is re-sorted: the runtime
/// does not report a level, and a sort key that is always null is a sort that
/// only ever runs by accident.
///
/// The default below a 640 px map is one floor, not the stack, which is the
/// runtime's own default; this control shows what that is and lets the buyer
/// change it.
///
/// Reads everything from the snapshot, so it works standalone inside a
/// [SeatLayerPickerScope]. The drop-in places it directly under the top rail
/// and reports the band it stands on, so the runtime keeps framing sections
/// clear of it.
class SeatLayerFloorStrip extends StatelessWidget {
  /// Creates the floor strip.
  const SeatLayerFloorStrip({
    super.key,
    this.compact = true,
    this.onFloorChanged,
    this.style,
  });

  /// Whether to render the phone's chip size and spacing.
  final bool compact;

  /// Called with the floor the buyer chose, [seatLayerAllFloors] for all.
  ///
  /// The change itself is still made by the controller; this is a
  /// notification, not a replacement.
  final ValueChanged<String>? onFloorChanged;

  /// Overrides [SeatLayerPickerStyles.floorStripStyle] for these chips.
  final SeatLayerSurfaceStyle? style;

  /// How tall the strip is, so a layout can report the band it covers.
  ///
  /// The track's own padding on both sides of a chip, which is what the web
  /// picker's floor rail measures.
  static double heightFor({bool compact = true}) =>
      (compact
          ? SeatLayerSizeTokens.floorChipHeight
          : SeatLayerSizeTokens.floorChipHeight + 6) +
      _trackPadding * 2;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final map = state.snapshot?.map;
    final floors = map?.floors ?? const <FloorInfo>[];
    // One floor is not a choice, and neither is none.
    if (map == null || floors.length < 2) return const SizedBox.shrink();

    // Over the immersive scene this is chrome on a dark venue, so it takes the
    // scene's palette exactly as the price rail above it does.
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final chipStyle =
        (theme.styles.floorStripStyle ?? const SeatLayerSurfaceStyle())
            .merge(style);
    final busy = state.isBusy;
    final showsAll = map.showsAllFloors;
    final offersAll = map.hasFloorModes && controller.supportsFloorStack;

    final chips = <Widget>[
      // Only offered by a runtime that has told us — twice — that it stacks.
      if (offersAll)
        _FloorChip(
          label: strings.allFloors,
          selected: showsAll,
          compact: compact,
          theme: theme,
          style: chipStyle,
          onPressed: busy || showsAll
              ? null
              : () => _choose(controller, seatLayerAllFloors),
        ),
      for (final floor in floors)
        _FloorChip(
          label: floor.name,
          selected: !showsAll && map.activeFloorId == floor.id,
          compact: compact,
          theme: theme,
          style: chipStyle,
          onPressed: busy || (!showsAll && map.activeFloorId == floor.id)
              ? null
              : () => _choose(controller, floor.id),
        ),
    ];

    // One track, not a row of loose chips: the floors are one control with a
    // choice in it, and the pill around them is what says so. It scrolls
    // inside itself, so a venue with six levels never pushes the map about.
    return Center(
      child: Material(
        color: pickerAlpha(theme.surface, .92),
        shape: StadiumBorder(side: BorderSide(color: theme.divider)),
        elevation: chipStyle.elevation ?? 2,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: heightFor(compact: compact),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.all(_trackPadding),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: _trackGap),
            itemBuilder: (context, index) => chips[index],
          ),
        ),
      ),
    );
  }

  void _choose(SeatLayerPickerController controller, String floorId) {
    ignorePickerAction(controller.setFloor(floorId));
    onFloorChanged?.call(floorId);
  }
}

/// The track's own padding, and the gap between two chips inside it.
///
/// Both are deliberately tight: on a phone the rail is a control the buyer
/// glances at, and air inside it only makes the track wider than the map can
/// spare.
const double _trackPadding = SeatLayerSizeTokens.floorRailPadding;
const double _trackGap = SeatLayerSizeTokens.floorRailGap;

/// `.05em` of tracking on the chip label, which is what the web's floor rail
/// carries. Expressed in points against the compact size, as Flutter's
/// [TextStyle.letterSpacing] is absolute.
const double _chipTracking = SeatLayerSizeTokens.floorChipFontSize * 0.05;

class _FloorChip extends StatelessWidget {
  const _FloorChip({
    required this.label,
    required this.selected,
    required this.compact,
    required this.theme,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool compact;
  final SeatLayerResolvedPickerTheme theme;
  final SeatLayerSurfaceStyle style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        // Inside the track a chip is a segment, not a card: unselected it is
        // transparent on the track's own ground and reads as muted text, and
        // only the floor being drawn wears the accent.
        child: Material(
          color: selected ? theme.accent : style.color ?? Colors.transparent,
          elevation: style.elevation ?? 0,
          shape: style.shape ?? theme.styles.chipShape ?? const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: compact
                    ? SeatLayerSizeTokens.floorChipHeight
                    : SeatLayerSizeTokens.floorChipHeight + 6,
              ),
              child: Padding(
                padding: style.padding ??
                    EdgeInsets.symmetric(
                      horizontal: compact
                          ? SeatLayerSizeTokens.floorChipPaddingX
                          : SeatLayerSizeTokens.floorChipPaddingX + 3,
                    ),
                child: Center(
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? theme.onAccent : theme.mutedText,
                        fontSize: compact
                            ? SeatLayerSizeTokens.floorChipFontSize
                            : SeatLayerSizeTokens.floorChipFontSize + 1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: _chipTracking,
                        fontFamily: theme.fontFamily,
                      ).merge(style.textStyle),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
