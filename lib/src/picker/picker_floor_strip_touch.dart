/// The floor strip's touch area in the ready-made layout.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'picker_floor_strip.dart';
import 'picker_tokens.g.dart';

/// A [SeatLayerFloorStrip] whose chips take a tap over
/// [SeatLayerSizeTokens.minimumHitTarget] points of height, drawn as before.
///
/// The chips stay as small as they are drawn; the room above and below them
/// takes the tap for the chip it is nearest to. That room is part of this
/// box, so the map is told the buyer's finger is on the strip there.
class SeatLayerFloorStripTouch extends SingleChildRenderObjectWidget {
  /// Creates the strip with its touch area, or without it.
  SeatLayerFloorStripTouch({
    super.key,
    required this.compact,
    this.enabled = true,
  }) : super(child: SeatLayerFloorStrip(compact: compact));

  /// Whether to render the phone's chip size and spacing.
  final bool compact;

  /// False where the host draws a strip of its own around this one.
  final bool enabled;

  /// The room above the strip that takes a tap. In the panel it is all above:
  /// there the line under the strip follows at once.
  /// None where the host draws a strip of its own.
  static double above({required bool compact, bool enabled = true}) =>
      !enabled ? 0 : _missing(compact) / (compact ? 2 : 1);

  static double _below({required bool compact}) =>
      _missing(compact) - above(compact: compact);

  static double _missing(bool compact) =>
      (SeatLayerSizeTokens.minimumHitTarget -
              SeatLayerFloorStrip.heightFor(compact: compact))
          .clamp(0, double.infinity);

  EdgeInsets get _room => enabled
      ? EdgeInsets.only(
          top: above(compact: compact),
          bottom: _below(compact: compact),
        )
      : EdgeInsets.zero;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFloorStripTouch(_room, enabled);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) =>
      (renderObject as _RenderFloorStripTouch)
        ..padding = _room
        ..enabled = enabled;
}

class _RenderFloorStripTouch extends RenderPadding {
  _RenderFloorStripTouch(EdgeInsets room, this.enabled) : super(padding: room);

  bool enabled;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null || child.size.isEmpty || !enabled) {
      return super.hitTestChildren(result, position: position);
    }
    final offset = (child.parentData! as BoxParentData).offset;
    final local = position - offset;
    // Moved onto the nearest chip, not onto a point: a drag still scrolls.
    const track = SeatLayerSizeTokens.floorRailPadding;
    final onChip = Offset(
      local.dx,
      local.dy.clamp(track, child.size.height - track - .01),
    );
    return result.addWithPaintOffset(
      offset: position - onChip,
      position: position,
      hitTest: (result, moved) => child.hitTest(result, position: moved),
    );
  }
}
