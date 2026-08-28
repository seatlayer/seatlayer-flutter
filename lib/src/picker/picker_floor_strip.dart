/// Which floor of the building the buyer is looking at.
library;

import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_styles.dart';
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
  static double heightFor({bool compact = true}) => compact ? 30 : 36;

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

    return SizedBox(
      height: heightFor(compact: compact),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) => chips[index],
      ),
    );
  }

  void _choose(SeatLayerPickerController controller, String floorId) {
    ignorePickerAction(controller.setFloor(floorId));
    onFloorChanged?.call(floorId);
  }

}

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
        child: Material(
          color: selected
              ? theme.accent
              : style.color ??
                  Color.alphaBlend(pickerAlpha(theme.text, .04), theme.surface),
          elevation: style.elevation ?? 0,
          shape: style.shape ??
              theme.styles.chipShape?.copyWith(
                side:
                    BorderSide(color: selected ? theme.accent : theme.divider),
              ) ??
              StadiumBorder(
                side:
                    BorderSide(color: selected ? theme.accent : theme.divider),
              ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: style.padding ??
                  EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? theme.onAccent : theme.text,
                      fontSize:
                          compact ? theme.layout.legendChipFontSize : 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: theme.fontFamily,
                    ).merge(style.textStyle),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
