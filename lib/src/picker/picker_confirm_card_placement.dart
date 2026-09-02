// Where the seat card sits over the map, and which way it points.
//
// Split out of `picker_confirm_card.dart`. The placement rule is pure — a
// card size, a map size, the seat's point — so it is decided once here and
// tested directly, and the pointer that draws the result lives beside it.
part of 'picker_confirm_card.dart';

/// Which edge of the seat card points back at the seat, if any.
enum SeatLayerConfirmCardNotch {
  /// The card is centred and points at nothing: the runtime did not say where
  /// on the map the seat was drawn.
  none,

  /// The card sits above the seat, so it points down at it.
  bottom,

  /// The card sits below the seat, so it points up at it.
  ///
  /// [seatLayerConfirmCardPlacement] never chooses this: a card that would sit
  /// below the seat is a card that was never in the seat's way, and it rests
  /// where the thumb is instead. It stays here for a host placing the card by
  /// its own rule.
  top,
}

/// Where the seat card sits over the map, and which way it points.
@immutable
class SeatLayerConfirmCardPlacement {
  /// Creates a placement.
  const SeatLayerConfirmCardPlacement({required this.top, required this.notch});

  /// The card's own top edge, in the map surface's coordinates.
  final double top;

  /// Which edge carries the pointer, if the seat's place is known.
  final SeatLayerConfirmCardNotch notch;

  @override
  bool operator ==(Object other) =>
      other is SeatLayerConfirmCardPlacement &&
      other.top == top &&
      other.notch == notch;

  @override
  int get hashCode => Object.hash(top, notch);

  @override
  String toString() => 'SeatLayerConfirmCardPlacement($top, ${notch.name})';
}

/// The gap between the seat and the card's nearest edge.
const double seatLayerConfirmCardSeatGap =
    SeatLayerSizeTokens.confirmCardSeatGap;

/// Where the card rests when it is not hugging a seat: the daylight between
/// its bottom edge and the foot of the map.
const double seatLayerConfirmCardRestInset =
    SeatLayerSizeTokens.confirmCardRestInset;

/// The closest the card may come to the top of the map.
const double seatLayerConfirmCardTopInset =
    SeatLayerSizeTokens.confirmCardTopInset;

/// Extra room below the resting card before the seat counts as covered.
const double seatLayerConfirmCardClearance =
    SeatLayerSizeTokens.confirmCardClearance;

/// Where a card of [card] size belongs over a [area]-sized map.
///
/// Two placements, decided by one question: would the resting card cover the
/// seat it is asking about? A card resting on the foot of the map is where the
/// thumb already is and leaves the whole map readable, so that is the default.
/// Only a seat low enough to end up underneath it — within
/// [seatLayerConfirmCardClearance] of the resting card's top edge — makes the
/// card rise and hug the seat instead, sitting
/// [seatLayerConfirmCardSeatGap] above it and pointing down at it.
///
/// [topInset] and [bottomInset] are the bands the picker's own chrome stands
/// on: the map the card lives over is what is left between them, so the card
/// never slides behind the dock or under the floor strip. Pure, so both cases
/// are decided once and tested directly.
SeatLayerConfirmCardPlacement seatLayerConfirmCardPlacement({
  required Offset? seat,
  required Size card,
  required Size area,
  double topInset = 0,
  double bottomInset = 0,
  double gap = seatLayerConfirmCardSeatGap,
  double restInset = seatLayerConfirmCardRestInset,
  double clearance = seatLayerConfirmCardClearance,
  double headroom = seatLayerConfirmCardTopInset,
}) {
  // The foot of the band the card lives in, and the highest its top edge may
  // go inside it.
  final foot = area.height - bottomInset;
  final ceiling = topInset + headroom;
  final resting = math.max(ceiling, foot - restInset - card.height);
  if (seat == null || seat.dy < foot - restInset - card.height - clearance) {
    // Nothing to get out of the way of: rest on the bottom edge, so the map
    // above stays the buyer's and the card reads as a sheet.
    return SeatLayerConfirmCardPlacement(
      top: resting,
      notch: SeatLayerConfirmCardNotch.none,
    );
  }
  return SeatLayerConfirmCardPlacement(
    top: (seat.dy - gap - card.height).clamp(
      ceiling,
      math.max(ceiling, foot - card.height),
    ),
    notch: SeatLayerConfirmCardNotch.bottom,
  );
}

/// The pointer between the card and the seat it is about.
///
/// Drawn as part of the card rather than as a decoration on it: same surface,
/// same hairline, and the hairline is erased where the two meet so the notch
/// reads as the card's own edge pulled towards the seat.
class SeatLayerConfirmCardPointer extends StatelessWidget {
  /// Creates a pointer of [height] pointing [up] or down.
  const SeatLayerConfirmCardPointer({
    super.key,
    required this.up,
    this.height = 8,
    this.width = 18,
  });

  /// Whether the tip points towards the top of the screen.
  final bool up;

  /// How far the tip reaches out of the card.
  final double height;

  /// How wide the pointer's base is where it leaves the card.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _PointerPainter(
          up: up,
          surface: theme.surface,
          border: pickerAlpha(theme.divider, .9),
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({
    required this.up,
    required this.surface,
    required this.border,
  });

  final bool up;
  final Color surface;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    }
    canvas.drawPath(path, Paint()..color = surface);
    // Only the two sloping sides are stroked: the base is where the card is,
    // and a line there would draw the card's edge across its own pointer.
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) =>
      oldDelegate.up != up ||
      oldDelegate.surface != surface ||
      oldDelegate.border != border;
}
