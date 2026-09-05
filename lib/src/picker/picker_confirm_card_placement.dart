// Where the seat card sits over the map, and what of the map it stands on.
//
// Split out of `picker_confirm_card.dart`. Both rules are pure — a card size,
// a map size, the chrome above and below — so they are decided once here and
// tested directly.
part of 'picker_confirm_card.dart';

/// The gap between the fixed sheet and the nearest seat the runtime should
/// keep clear of it.
///
/// The web widget's `NARROW_CONFIRM_SEAT_GAP`: the band the buyer is meant to
/// read the map in ends this far above the sheet's top edge, so a seat framed
/// into it is never pressed against the card asking about it.
const double seatLayerConfirmCardSeatGap =
    SeatLayerSizeTokens.confirmCardSeatGap;

/// Where the card rests: the daylight between its bottom edge and the foot of
/// the map.
const double seatLayerConfirmCardRestInset =
    SeatLayerSizeTokens.confirmCardRestInset;

/// The closest the card may come to the top of the map.
const double seatLayerConfirmCardTopInset =
    SeatLayerSizeTokens.confirmCardTopInset;

/// Where the card's top edge belongs over a [area]-sized map.
///
/// **One home, and the map moves instead.** The phone card is a fixed bottom
/// sheet: it rests [restInset] above the foot of the map the chrome has left,
/// on every tap, so Cancel and Add seat are under the same pixels every time.
/// Nothing about the tapped seat is read here.
///
/// The card used to move to the seat — first tracking its y, then choosing
/// between two homes. On a 956 pt phone that read badly: the seat is a small
/// ring in a small hole and the card is at the foot of a tall map, so the two
/// halves of one question were up to 600 pt apart and the buyer had to hunt
/// for the seat they had just tapped. Keeping the seat and the card together
/// is the MAP's job now — see [seatLayerConfirmSheetBand], which tells the
/// runtime what the sheet covers so its framing aims at the band above it.
///
/// [topInset] and [bottomInset] are the bands the picker's own chrome stands
/// on: the map the card lives over is what is left between them, so the card
/// never slides behind the dock or under the floor strip.
double seatLayerConfirmCardTop({
  required Size card,
  required Size area,
  double topInset = 0,
  double bottomInset = 0,
  double restInset = seatLayerConfirmCardRestInset,
  double headroom = seatLayerConfirmCardTopInset,
}) {
  final foot = area.height - bottomInset;
  final ceiling = topInset + headroom;
  return math.max(ceiling, foot - restInset - card.height);
}

/// What the raised sheet covers, as a bottom viewport inset for the runtime.
///
/// The runtime frames every fit and every focus glide INSIDE the insets the
/// host reports, so this is what moves the map out from under the card: a
/// sheet the runtime has not been told about is a sheet the venue is framed
/// underneath. Measured from the foot of the map surface — the same box the
/// canvas fills — up to [seatGap] above the card's top edge, so the clear
/// band ends in daylight rather than against the card's own shadow.
///
/// Returns 0 when the sheet would leave no band at all: a host short enough
/// that the card fills it has nowhere to put the seat, and an inset taller
/// than the viewport would ask the runtime to frame into nothing. Mirrors the
/// web widget's own guard on the same number.
double seatLayerConfirmSheetBand({
  required double cardTop,
  required Size area,
  double topInset = 0,
  double seatGap = seatLayerConfirmCardSeatGap,
}) {
  final band = area.height - cardTop + seatGap;
  if (area.height - topInset - band <= 0) return 0;
  return band;
}
