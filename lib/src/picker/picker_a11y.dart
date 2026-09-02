/// What the picker owes a buyer who is not looking at it.
///
/// Three concerns live here, because all three are properties of the picker as
/// a whole rather than of any one surface: the order the surfaces are read in,
/// how far each of them lets the platform grow its type, and the two platform
/// settings — reduce motion's sibling `bold text`, and the announcement
/// channel — that no single component can be trusted to remember.
///
/// Reduced motion is deliberately NOT here: it has its own accessor in
/// `picker_motion.dart`, and one setting with two homes is a setting a surface
/// will read from the wrong one.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'picker_tokens.g.dart';

/// The order a screen reader walks the phone picker in.
///
/// The compact composition is a Column of rows with a Stack in the middle, and
/// a Stack's paint order is not a reading order: the dock is painted after the
/// map's floor rail and before the seat card, which would have the buyer hear
/// "Venue" between two halves of the map's own chrome. Every surface therefore
/// declares where it sits in one traversal, and the order is the buyer's:
/// whose event this is, what the prices are, the venue, where in it they are,
/// then what they have chosen.
///
/// The numbers are spaced so a surface can be inserted between two of them
/// without renumbering the rest.
abstract final class SeatLayerPickerReadingOrder {
  /// Whose event this is, the hold, and the way out.
  static const double header = 100;

  /// The price rail and the Map/3D control that shares its band.
  static const double rail = 200;

  /// The drawn map itself.
  static const double map = 300;

  /// Chrome standing on the map: floor rail, test chip, corner controls.
  static const double mapChrome = 400;

  /// Where in the venue the buyer is, and the ways out of it.
  static const double dock = 500;

  /// The seat card and the general-admission and table prompts.
  static const double prompt = 600;

  /// Toasts, hold prompts and the buyer-facing state overlays.
  static const double notice = 700;

  /// The cart, at peek or open.
  static const double sheet = 800;
}

/// Puts [child] at [order] in the picker's one reading order.
///
/// A sort key applies to the whole subtree, so this is placed once per surface
/// at the composition root rather than sprinkled through the components — the
/// components are also mountable standalone, where there is no order to join.
Widget seatLayerReadingOrder(double order, Widget child) => Semantics(
      sortKey: OrdinalSortKey(order, name: 'seatlayer-picker'),
      child: child,
    );

/// Caps how far the platform's text-size setting may grow the type inside
/// [child].
///
/// A clamp is a statement about a layout, not a preference: past it the surface
/// clips, and a buyer who cannot read a clipped price is worse off than one
/// reading a slightly smaller one. Which clamp belongs to which surface is a
/// design token (`type.scaleClamp` in `design/tokens.json`), so a port cannot
/// invent its own ceiling — and surfaces that own the whole screen and scroll
/// (the prompts) have no token, because they are never clamped.
///
/// At the platform default of 1.0 this changes nothing, which is why the
/// goldens are unaffected.
class SeatLayerTypeScale extends StatelessWidget {
  /// Clamps the type inside [child] at [max].
  const SeatLayerTypeScale({
    super.key,
    required this.max,
    required this.child,
  });

  /// The rail of price chips.
  const SeatLayerTypeScale.rail({super.key, required this.child})
      : max = SeatLayerTypeScaleTokens.rail;

  /// The section dock.
  const SeatLayerTypeScale.dock({super.key, required this.child})
      : max = SeatLayerTypeScaleTokens.dock;

  /// The collapsed cart bar.
  const SeatLayerTypeScale.peek({super.key, required this.child})
      : max = SeatLayerTypeScaleTokens.peek;

  /// The seat card.
  const SeatLayerTypeScale.card({super.key, required this.child})
      : max = SeatLayerTypeScaleTokens.card;

  /// The open sheet and its cart rows.
  const SeatLayerTypeScale.sheet({super.key, required this.child})
      : max = SeatLayerTypeScaleTokens.sheet;

  /// The buyer-facing state overlays and toasts.
  const SeatLayerTypeScale.state({super.key, required this.child})
      : max = SeatLayerTypeScaleTokens.state;

  /// The largest scale factor this surface will honour.
  final double max;

  /// The surface being clamped.
  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: max,
        child: child,
      );
}

/// How far the type in this subtree has actually grown, once [max] has had
/// its say.
///
/// Never below 1: a buyer who has made their text *smaller* is not asking for
/// a shorter dock bar, and a bar that shrank with the type would leave its
/// 44-point controls without room.
double seatLayerTypeScaleOf(BuildContext context, {required double max}) {
  final scale = MediaQuery.textScalerOf(context).scale(100) / 100;
  if (!scale.isFinite || scale <= 1) return 1;
  return scale > max ? max : scale;
}

/// [base] grown by the surface's clamped text scale.
///
/// The fixed heights in `tokens.json` are heights for type at 1.0. Left fixed
/// they become ceilings the moment a buyer scales their text up, and a bar
/// whose contents are taller than the bar clips or overflows. Used as a
/// *minimum* wherever the surface can afford to grow, and as the height where
/// the runtime is also being told what the chrome covers — the reported band
/// and the drawn band have to be the same number.
double seatLayerScaledExtent(
  BuildContext context,
  double base, {
  required double max,
}) =>
    base * seatLayerTypeScaleOf(context, max: max);

/// [weight], heavier, when the platform asks for bold text.
///
/// Flutter honours `MediaQueryData.boldText` in exactly one widget — the text
/// field — so every explicit weight in the picker has to ask. Two steps, not
/// one: the picker's own scale already runs 600–800, and a single step inside
/// it is a change nobody can see.
FontWeight seatLayerBoldWeight(BuildContext context, FontWeight weight) {
  if (!MediaQuery.boldTextOf(context)) return weight;
  final target = weight.value + _boldTextStep;
  for (final candidate in FontWeight.values) {
    if (candidate.value >= target) return candidate;
  }
  return FontWeight.w900;
}

/// How much heavier `bold text` makes the picker's type.
const int _boldTextStep = 200;

/// Say [message] out loud, once.
///
/// For the moments a live region cannot carry: a message that arrives and
/// leaves inside one animation, or one whose surface is unmounted by the time
/// the platform would have got round to reading it.
void seatLayerAnnounce(BuildContext context, String message) {
  final text = message.trim();
  if (text.isEmpty) return;
  SemanticsService.sendAnnouncement(
    View.of(context),
    text,
    Directionality.of(context),
  );
}
