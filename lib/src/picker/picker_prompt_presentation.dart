/// One motion language for every native decision surface: scrim, seat card,
/// GA/table prompts and their exit, and the loading/failure overlay above
/// them. The canvas remains mounted underneath, so opening a card never resets
/// camera state or causes a map flash.
///
/// Split out of `picker_adaptive_layout.dart`: the composition root decides
/// *which* surface is up, and this file decides how one arrives and leaves.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'picker_a11y.dart';
import 'picker_confirm_card.dart';
import 'picker_motion.dart';
import 'picker_tokens.g.dart';

/// The loading/failure overlay, fading out rather than popping.
///
/// The map is revealed by lifting this, so a hard cut is the one thing that
/// makes a finished load look like a second one starting.
class PickerStatusOverlay extends StatelessWidget {
  const PickerStatusOverlay({super.key, required this.overlay});

  /// What to cover the map with, or null to reveal it.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: overlay == null,
        child: AnimatedSwitcher(
          // Arriving is not animated: the overlay is up before the buyer sees
          // the route at all. Only its departure is watched.
          duration: Duration.zero,
          reverseDuration: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.exit,
          ),
          switchOutCurve: SeatLayerPickerMotion.easeExit,
          child: overlay ?? const SizedBox.shrink(),
        ),
      );
}

class PickerPromptTransition extends StatelessWidget {
  const PickerPromptTransition({
    super.key,
    required this.scrimColor,
    required this.child,
    this.seatCard = false,
    this.anchor,
    this.topInset = 0,
    this.bottomInset = 0,
    this.onDismiss,
    this.onSheetBand,
    this.readingOrder,
  });

  final Color scrimColor;
  final Widget? child;

  /// Whether the prompt is the phone's seat card.
  ///
  /// The card is the only prompt that behaves like a native moment rather than
  /// a dialog: it rises from the foot of the map as a sheet, spotlights the
  /// seat it is asking about, and the map behind it is still the way out.
  /// Dialogs are centred instead.
  final bool seatCard;

  /// Where on the map the seat was drawn, if the runtime said.
  ///
  /// The card no longer moves to it — it is a fixed sheet. The anchor is what
  /// the glass behind the card cuts its hole around, so the seat under
  /// discussion stays visible while the map around it recedes.
  final Offset? anchor;

  /// The band of map the picker's own chrome is standing on, at the top.
  final double topInset;

  /// The same, at the bottom.
  final double bottomInset;

  /// Called when the buyer taps the map around the card.
  ///
  /// It is also what Escape does. A physical keyboard is not a phone
  /// accessory, but a switch control and an external keyboard both send it,
  /// and the buyer who reaches for it means the same thing the tap does: not
  /// this seat.
  final VoidCallback? onDismiss;

  /// What the raised seat card covers, as a bottom viewport inset, once it
  /// has been measured.
  ///
  /// The card is a fixed sheet and the MAP is what moves out from under it,
  /// which the runtime only does for chrome it has been told about.
  final ValueChanged<double>? onSheetBand;

  /// Where the prompt sits in the picker's one reading order, if the host
  /// composition has one.
  final double? readingOrder;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final prompt = child;
    final springy = seatCard && !reducedMotion;
    return _ordered(
      // While a prompt is up it is the only thing on the map worth hearing.
      // Everything painted before it — the map, its chrome, the dock — is
      // hidden from assistive technology, exactly as a modal route would hide
      // the page under it. The toasts and the cart sheet are painted after,
      // and stay audible on purpose: a toast is the answer to the press, and
      // the cart is what the seat is being added to.
      BlockSemantics(
        blocking: prompt != null,
        child: _escapable(
          IgnorePointer(
            ignoring: prompt == null,
            child: AnimatedSwitcher(
              duration: SeatLayerPickerMotion.of(
                context,
                seatCard
                    ? SeatLayerPickerMotion.cardEnter
                    : SeatLayerPickerMotion.enter,
              ),
              reverseDuration: SeatLayerPickerMotion.of(
                context,
                SeatLayerPickerMotion.exit,
              ),
              switchInCurve: SeatLayerPickerMotion.easeEnter,
              switchOutCurve: SeatLayerPickerMotion.easeExit,
              transitionBuilder: (current, animation) {
                if (reducedMotion) return current;
                final eased = CurvedAnimation(
                  parent: animation,
                  curve: SeatLayerPickerMotion.easeEnter,
                  reverseCurve: SeatLayerPickerMotion.easeExit,
                );
                if (springy) {
                  // The sheet always rises: it has one home, at the foot of
                  // the map, and arriving from under the screen's edge is the
                  // entrance a phone buyer already knows. Points, not a
                  // fraction of the card's own height — the distance is a
                  // property of the gesture, not of how tall the card is.
                  const dy = _cardTravel;
                  return FadeTransition(
                    opacity: eased,
                    child: AnimatedBuilder(
                      animation: eased,
                      builder: (context, inner) => Transform.translate(
                        offset: Offset(0, dy * (1 - eased.value)),
                        child: inner,
                      ),
                      // Leaving is a shrink towards the peek bar the ticket just
                      // went to, so the card exits smaller than it entered.
                      child: ScaleTransition(
                        scale: Tween<double>(begin: _cardArrivalScale, end: 1)
                            .animate(eased),
                        child: current,
                      ),
                    ),
                  );
                }
                return FadeTransition(
                  opacity: eased,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .035),
                      end: Offset.zero,
                    ).animate(eased),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: .965, end: 1).animate(eased),
                      child: current,
                    ),
                  ),
                );
              },
              child: prompt == null
                  ? const SizedBox.expand(
                      key: ValueKey<String>('picker-prompt-none'))
                  : _PromptBackdrop(
                      key: ValueKey<Object>((
                        prompt.runtimeType,
                        prompt.key ?? prompt.runtimeType,
                      )),
                      scrimColor: scrimColor,
                      // Glass only for a seat card with a seat to spotlight.
                      // A prompt about no one seat has nothing to cut a hole
                      // around, and in the immersive scene the seat IS the
                      // picture.
                      spotlight: seatCard ? anchor : null,
                      onDismiss: onDismiss,
                      // Each prompt owns its own insets: the phone confirm card is
                      // specified as the screen less one 16pt gutter, and a shared
                      // outer padding would quietly narrow it.
                      child: seatCard
                          ? _SeatCardFrame(
                              topInset: topInset,
                              bottomInset: bottomInset,
                              onSheetBand: onSheetBand,
                              child: prompt,
                            )
                          : Center(child: prompt),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// [child] at this composition's place in the picker's reading order.
  Widget _ordered(Widget child) {
    final order = readingOrder;
    return order == null ? child : seatLayerReadingOrder(order, child);
  }

  /// Escape answers the prompt the way a tap on the map around it does.
  Widget _escapable(Widget child) {
    final dismiss = onDismiss;
    if (dismiss == null) return child;
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): dismiss,
      },
      child: child,
    );
  }
}

/// How far the seat card travels on arrival, in logical points.
const double _cardTravel = 10;

/// How small it starts, so it grows into place rather than sliding into it.
const double _cardArrivalScale = .97;

/// How much of the cart sheet is left while the card is asking its question.
///
/// The sheet is still readable — the buyer can see what is already in the cart
/// — but it is plainly not the surface being answered.
const double _confirmingDim = .58;

/// The map behind a prompt: glass, and a way out through it.
///
/// The map is never unmounted for this, so the venue stays present behind the
/// decision. Over the 3D scene the dim is transparent as well.
class _PromptBackdrop extends StatelessWidget {
  const _PromptBackdrop({
    super.key,
    required this.scrimColor,
    required this.onDismiss,
    required this.child,
    this.spotlight,
  });

  final Color scrimColor;

  /// Where the seat under discussion is, in this backdrop's own coordinates.
  ///
  /// When given, the glass has a hole in it there: the buyer is being asked
  /// about ONE seat and can still see it. Absent — the immersive scene, or a
  /// prompt about no seat in particular — the backdrop is flat.
  final Offset? spotlight;

  final VoidCallback? onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final backdrop = spotlight == null
        ? ColoredBox(color: scrimColor)
        : _SpotlightGlass(at: spotlight!);
    return Stack(
      children: [
        // The dismissing tap belongs to the backdrop, not to the whole area:
        // a detector wrapping both would take taps the card itself wanted.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: backdrop,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// The cart sheet while the seat card is up: dimmed, and out of reach.
///
/// A confirm card asks one question, and every other surface on the screen
/// has to stop offering answers to it while it does. The map's own chrome is
/// already behind the card's backdrop; the sheet is a sibling below the map,
/// so it is paused here instead — faded rather than hidden, because what is
/// already in the cart is context for the seat being decided on.
class PickerPausedWhileConfirming extends StatelessWidget {
  const PickerPausedWhileConfirming({
    super.key,
    required this.confirming,
    required this.child,
  });

  /// Whether a seat card is up.
  final bool confirming;

  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: confirming,
        child: AnimatedOpacity(
          opacity: confirming ? _confirmingDim : 1,
          duration: SeatLayerPickerMotion.of(
            context,
            SeatLayerPickerMotion.exit,
          ),
          curve: SeatLayerPickerMotion.easeEnter,
          child: child,
        ),
      );
}

/// Holds the seat card at its one home: the fixed sheet at the foot of the
/// map the picker's own chrome has left.
///
/// It also measures the card, because the height of a sheet built from a
/// seat's own facts — photo strip or rail, tiers, notices — is not known
/// until it has been laid out, and the band the sheet covers is what the
/// runtime has to be told to frame the map above.
class _SeatCardFrame extends StatelessWidget {
  const _SeatCardFrame({
    required this.topInset,
    required this.bottomInset,
    required this.onSheetBand,
    required this.child,
  });

  final double topInset;
  final double bottomInset;

  /// The band this sheet covers, as a bottom viewport inset, once the card
  /// has a height. Reported after the frame that measured it.
  final ValueChanged<double>? onSheetBand;

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomSingleChildLayout(
        delegate: _SeatCardLayout(
          topInset: topInset,
          bottomInset: bottomInset,
          onSheetBand: onSheetBand,
        ),
        child: child,
      );
}

/// Places the sheet from [seatLayerConfirmCardTop], and reports what it
/// covers from [seatLayerConfirmSheetBand].
class _SeatCardLayout extends SingleChildLayoutDelegate {
  const _SeatCardLayout({
    required this.topInset,
    required this.bottomInset,
    required this.onSheetBand,
  });

  final double topInset;
  final double bottomInset;
  final ValueChanged<double>? onSheetBand;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final top = seatLayerConfirmCardTop(
      card: childSize,
      area: size,
      topInset: topInset,
      bottomInset: bottomInset,
    );
    final report = onSheetBand;
    if (report != null) {
      // Layout is not a place to call setState from, and the caller's answer
      // is a viewport report that only has to be right by the next frame —
      // the card is still arriving for another 320 ms.
      final band = seatLayerConfirmSheetBand(
        cardTop: top,
        area: size,
        topInset: topInset,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => report(band));
    }
    return Offset(0, top);
  }

  @override
  bool shouldRelayout(_SeatCardLayout oldDelegate) =>
      oldDelegate.topInset != topInset ||
      oldDelegate.bottomInset != bottomInset;
}

/// The map put behind glass while a seat card asks about one seat.
///
/// The phone card rests over a map that is otherwise fully legible, so the
/// moment of decision competed with several thousand other seats. Per-seat
/// dimming already recedes the candidate's neighbours; nothing quieted the
/// MAP. A translucent fill with a small blur does, and a hole cut around the
/// tapped seat is what makes it a spotlight rather than a curtain.
///
/// Never takes a pointer event of its own — the press has to reach the
/// dismissing detector underneath, exactly as a press on bare map does.
class _SpotlightGlass extends StatelessWidget {
  const _SpotlightGlass({required this.at});

  /// The centre of the clear hole.
  final Offset at;

  @override
  Widget build(BuildContext context) {
    // Reduced transparency is a legibility setting, not a taste. Flutter has
    // no direct reading of it, so high contrast stands in: drop the blur and
    // deepen the fill, and the map still recedes without being smeared.
    final flat = MediaQuery.highContrastOf(context);
    final veil = Color.fromRGBO(
      0,
      0,
      0,
      flat
          ? SeatLayerOpacityTokens.confirmScrimFlat
          : SeatLayerOpacityTokens.confirmScrim,
    );
    // The feather runs from the clear radius out to the full-strength one, so
    // the hole has no hard edge to read as a drawn circle.
    final Widget glass = ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment(
          (at.dx / bounds.width) * 2 - 1,
          (at.dy / bounds.height) * 2 - 1,
        ),
        radius: SeatLayerSizeTokens.confirmScrimFeatherRadius /
            (bounds.shortestSide / 2),
        colors: const <Color>[Color(0x00000000), Color(0xFF000000)],
        stops: const <double>[
          SeatLayerSizeTokens.confirmScrimClearRadius /
              SeatLayerSizeTokens.confirmScrimFeatherRadius,
          1,
        ],
      ).createShader(bounds),
      child: flat
          ? ColoredBox(color: veil)
          : BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: SeatLayerSizeTokens.confirmScrimBlur,
                sigmaY: SeatLayerSizeTokens.confirmScrimBlur,
              ),
              child: ColoredBox(color: veil),
            ),
    );
    return IgnorePointer(child: glass);
  }
}
