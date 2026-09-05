// The seat card's two answers, and what happens after one is chosen.
//
// Split out of `picker_confirm_card.dart`. `Cancel` and `Add seat` are the
// card's decision row; the rest of this file is the moment after `Add seat` is
// pressed — the invite halo that draws the thumb to it, the finish that
// sweeps across the button, the tick it settles into, and the chip that flies
// from the card down to the cart.
part of 'picker_confirm_card.dart';

/// The card's quiet answer: no fill, so it never competes with `Add seat`.
class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.label,
    required this.onPressed,
    this.style,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final disabled = onPressed == null;
    final styledGround = seatLayerStyleRole(
      style?.backgroundColor,
      disabled: disabled,
    );
    final styledInk =
        seatLayerStyleRole(style?.foregroundColor, disabled: disabled);
    return Material(
      color: styledGround ??
          // The divider's own colour at less than half strength: enough of a
          // ground to read as a button, never enough to compete for the press.
          pickerAlpha(theme.divider, theme.divider.a * .44),
      shape: seatLayerStyleRole(style?.shape) ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.button),
            side: BorderSide(color: theme.divider),
          ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: styledInk ??
                    (disabled
                        ? pickerAlpha(theme.mutedText, .5)
                        : theme.mutedText),
                fontSize: 13,
                height: 1.15,
                fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                fontFamily: theme.fontFamily,
              ).merge(seatLayerStyleRole(style?.textStyle)),
            ),
          ),
        ),
      ),
    );
  }
}

/// How far the breath's halo reaches, and how deep its colour goes.
const double _inviteHalo = 6;
const double _inviteHaloInk = .35;

/// How much the button swells at the top of each breath.
const double _inviteSwell = .02;

/// The card's recommended answer, and the small theatre around it.
///
/// Three things happen here, and each says something the still button cannot.
/// On arrival one highlight crosses it: this is the thing to press. While it
/// waits it breathes, slowly, for as long as it waits: the offer is still
/// open, and it is the buyer's own hesitation that keeps it open. On the
/// press its own ink fills from the left under a drawn check and the word
/// turns to "Added": the ticket is in the cart. Only the last of the three is
/// about the buyer's own action, and the ticket was counted before the sweep
/// started — this is a receipt, not a progress bar.
class _AddSeatButton extends StatefulWidget {
  const _AddSeatButton({
    required this.label,
    required this.added,
    required this.invite,
    required this.onPressed,
    required this.onInviteEnd,
    this.destructive = false,
    this.style,
  });

  final String label;

  /// Whether this press takes a seat back out of the cart.
  ///
  /// The same button, asking the opposite question: it carries the failure
  /// colour and a cross rather than the accent and a tick. A TICK IS THE
  /// WRONG PROMISE ON A REMOVE — it reads as "done, added" on the one press
  /// that empties a line out of the cart.
  final bool destructive;

  /// Whether the press has been committed and the button is now a receipt.
  final bool added;

  /// Whether the arrival highlight and the breath play at all.
  final bool invite;

  /// The buyer has found this button, so the card can stop pointing at it.
  ///
  /// Reaching the button by keyboard is the same answer as putting a finger on
  /// the card: the invitation has done its job and must not keep moving under
  /// a focus ring the buyer is already reading.
  final VoidCallback onInviteEnd;

  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  State<_AddSeatButton> createState() => _AddSeatButtonState();
}

class _AddSeatButtonState extends State<_AddSeatButton>
    with TickerProviderStateMixin {
  /// The whole invitation on one clock: the wait, the highlight, the second
  /// wait, and the breaths.
  ///
  /// One controller rather than two and a pair of timers, so the invitation is
  /// something the scheduler knows about from the first frame — a delay held
  /// in a timer is a delay nothing can settle, wind forward or stop.
  late final AnimationController _invite = AnimationController(
    vsync: this,
    duration: _inviteSpan,
  );
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.pressSweep,
  );

  /// Whether the invitation is still running.
  ///
  /// The breath has no end of its own — it stops because the buyer answered
  /// it — so the controller alone cannot say whether the button is inviting or
  /// merely parked at some value it was stopped on.
  bool _inviting = false;

  /// How many invitations this button has played.
  int _inviteRun = 0;

  @override
  void initState() {
    super.initState();
    if (widget.invite) _startInvite();
  }

  /// Play the wait, the highlight and the second wait once, then breathe.
  ///
  /// The breath loops over the tail of the same clock rather than on a second
  /// controller, so `_elapsed` keeps meaning the same thing after the first
  /// pass: past the highlight's window for good, and cycling through one
  /// breath's worth of the span.
  void _startInvite() {
    _inviting = true;
    // Which invitation this is. Cancelling a run completes its ticker future
    // too, so without a token a card restarting for a second seat would take
    // the first card's completion as its own and start breathing early.
    final run = ++_inviteRun;
    _invite.forward().whenCompleteOrCancel(() {
      if (!mounted || !_inviting || run != _inviteRun) return;
      _invite.repeat(
        min: _inviteBreatheDelayMs / _inviteSpan.inMilliseconds,
        max: 1,
        period: SeatLayerPickerMotion.inviteBreathe,
      );
    });
  }

  /// End the invitation, and end it at rest.
  ///
  /// [_inviting] is cleared before the controller is stopped so the frame that
  /// draws the answer already draws no halo: a breath frozen half-way out is a
  /// button that looks permanently swollen.
  void _stopInvite() {
    if (!_inviting) return;
    _inviting = false;
    _invite.stop();
  }

  @override
  void didUpdateWidget(covariant _AddSeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.invite && oldWidget.invite) _stopInvite();
    // A card asking about a second seat is a second card: the buyer has not
    // answered this one yet, so it points at itself from the beginning again
    // rather than inheriting the last card's spent invitation.
    if (widget.invite && !oldWidget.invite) {
      _press.value = 0;
      _invite.value = 0;
      _startInvite();
    }
    if (widget.added && !oldWidget.added) {
      _stopInvite();
      _press.forward();
    }
  }

  @override
  void dispose() {
    _invite.dispose();
    _press.dispose();
    super.dispose();
  }

  /// How far into the invitation the button is, in milliseconds.
  double get _elapsed => _invite.value * _inviteSpan.inMilliseconds;

  /// How much of the arrival highlight has crossed the button.
  double get _sweep =>
      ((_elapsed - _inviteDelayMs) / _inviteSweepMs).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final disabled = widget.onPressed == null;
    final styledGround = seatLayerStyleRole(
      widget.style?.backgroundColor,
      disabled: disabled,
    );
    final styledInk =
        seatLayerStyleRole(widget.style?.foregroundColor, disabled: disabled);
    final ground = styledGround ??
        (disabled
            ? Color.alphaBlend(pickerAlpha(theme.mutedText, .16), theme.surface)
            : (widget.destructive ? theme.error : theme.accent));
    // [SeatLayerPickerThemeData.onAccent] is authored against the accent and
    // says nothing about the failure colour, so the destructive ink is read
    // off the ground it actually sits on.
    final ink = styledInk ??
        (disabled
            ? pickerAlpha(theme.mutedText, .58)
            : (widget.destructive
                ? (ThemeData.estimateBrightnessForColor(ground) ==
                        Brightness.dark
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF000000))
                : theme.onAccent));
    final shape = seatLayerStyleRole(widget.style?.shape) ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.button),
        );
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_invite, _press]),
      builder: (context, _) {
        final breath = _breath;
        return Transform.scale(
          scale: 1 + (_inviteSwell * breath),
          child: CustomPaint(
            // The halo is drawn outside the button's own box, so it has to
            // live on a painter above it rather than inside its Material.
            painter: _InviteHalo(color: theme.accent, breath: breath),
            child: Material(
              color: ground,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _AddSeatFinish(
                        ink: ink,
                        sweep: _sweep,
                        press: _press.value,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: widget.onPressed,
                    onFocusChange: (focused) {
                      if (focused) widget.onInviteEnd();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // The check is drawn rather than swapped in: it
                            // grows out of the press it is answering.
                            SizedBox.square(
                              dimension: 16,
                              child: CustomPaint(
                                painter: _TickPainter(
                                  color: ink,
                                  drawn: widget.added ? _press.value : 1,
                                  cross: widget.destructive,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            // Shrinks only when it must: `Remove seat` beside
                            // the 3D square and a 34% Cancel does not fit at
                            // full size on a 390 pt phone, and an answer the
                            // buyer cannot read ("Remove s…") is worse than
                            // one a point smaller.
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.label,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 13,
                                    height: 1.15,
                                    fontWeight: seatLayerBoldWeight(
                                        context, FontWeight.w800),
                                    fontFamily: theme.fontFamily,
                                  ).merge(
                                    seatLayerStyleRole(
                                      widget.style?.textStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Where in the current breath the button is: 0 at rest, 1 at the top.
  ///
  /// Zero before the breathing starts and zero the instant the invitation is
  /// answered, so the button leaves the invitation at exactly its resting
  /// size. In between it is the web's own two-keyframe breath: out to the top
  /// by the halfway mark and back down again, each half eased in and out
  /// rather than one cosine across the whole cycle — a cosine is symmetric but
  /// not the same curve, and the peak is where the eye reads the amplitude.
  double get _breath {
    if (!_inviting) return 0;
    final since = _elapsed - _inviteBreatheDelayMs;
    if (since <= 0) return 0;
    final phase = (since / _inviteBreatheMs).clamp(0.0, 1.0).toDouble();
    return phase < .5
        ? _inviteEase.transform(phase * 2)
        : 1 - _inviteEase.transform((phase - .5) * 2);
  }
}

/// The invitation's clock: the wait before the breathing, then one breath.
///
/// The breath loops over the last [SeatLayerPickerMotion.inviteBreathe] of it
/// for as long as the card is unanswered, so this is the span of the first
/// pass rather than of the whole invitation — the invitation has no length,
/// only an end, and the buyer decides when.
final Duration _inviteSpan = SeatLayerPickerMotion.inviteBreatheDelay +
    SeatLayerPickerMotion.inviteBreathe;

/// The curve each half of a breath travels, matching the web's
/// `--slm-mo-inout` `cubic-bezier(.4,0,.6,1)`.
const Curve _inviteEase = Cubic(.4, 0, .6, 1);

final double _inviteDelayMs =
    SeatLayerPickerMotion.inviteDelay.inMilliseconds.toDouble();
final double _inviteSweepMs =
    SeatLayerPickerMotion.inviteSweep.inMilliseconds.toDouble();
final double _inviteBreatheDelayMs =
    SeatLayerPickerMotion.inviteBreatheDelay.inMilliseconds.toDouble();
final double _inviteBreatheMs =
    SeatLayerPickerMotion.inviteBreathe.inMilliseconds.toDouble();

/// The breath's halo, drawn outside the button it belongs to.
class _InviteHalo extends CustomPainter {
  const _InviteHalo({required this.color, required this.breath});

  final Color color;
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    if (breath <= 0) return;
    final spread = _inviteHalo * breath;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height).inflate(spread / 2),
        Radius.circular(SeatLayerRadiusTokens.button + (spread / 2)),
      ),
      Paint()
        // The colour holds and only the reach grows, as a box-shadow's spread
        // does: a halo that fades as it widens reads as a ripple leaving the
        // button, and this one is the button itself swelling.
        ..color = pickerAlpha(color, _inviteHaloInk)
        ..style = PaintingStyle.stroke
        ..strokeWidth = spread,
    );
  }

  @override
  bool shouldRepaint(_InviteHalo oldDelegate) =>
      oldDelegate.color != color || oldDelegate.breath != breath;
}

/// Everything painted over `Add seat`: the arrival highlight, and the press
/// filling the button with its own ink from the left.
class _AddSeatFinish extends CustomPainter {
  const _AddSeatFinish({
    required this.ink,
    required this.sweep,
    required this.press,
  });

  final Color ink;
  final double sweep;
  final double press;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (press > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * press, size.height),
        Paint()..color = pickerAlpha(ink, .20),
      );
    }
    if (sweep > 0 && sweep < 1) {
      // A band two button-widths wide crossing from wholly left to wholly
      // right, so the highlight enters and leaves rather than fading in place.
      final centre = (sweep * 4) - 2;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(centre - 1, 0),
            end: Alignment(centre + 1, 0),
            stops: const <double>[0, .32, .68, 1],
            colors: <Color>[
              pickerAlpha(ink, 0),
              pickerAlpha(ink, .24),
              pickerAlpha(ink, .24),
              pickerAlpha(ink, 0),
            ],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_AddSeatFinish oldDelegate) =>
      oldDelegate.ink != ink ||
      oldDelegate.sweep != sweep ||
      oldDelegate.press != press;
}

/// The tick on `Add seat`, drawn stroke-first so the press can draw it again.
class _TickPainter extends CustomPainter {
  const _TickPainter({
    required this.color,
    required this.drawn,
    this.cross = false,
  });

  final Color color;

  /// How much of the stroke is on the canvas, 0 to 1.
  final double drawn;

  /// Draw a cross instead: the same glyph slot, the opposite answer.
  final bool cross;

  @override
  void paint(Canvas canvas, Size size) {
    if (drawn <= 0) return;
    final scale = size.width / 24;
    final path = cross
        ? (Path()
          ..moveTo(6 * scale, 6 * scale)
          ..lineTo(18 * scale, 18 * scale)
          ..moveTo(18 * scale, 6 * scale)
          ..lineTo(6 * scale, 18 * scale))
        : (Path()
          ..moveTo(20 * scale, 6 * scale)
          ..lineTo(9 * scale, 17 * scale)
          ..lineTo(4 * scale, 12 * scale));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (drawn >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * drawn), paint);
    }
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.drawn != drawn ||
      oldDelegate.cross != cross;
}

/// The ticket itself, travelling from the card to the collapsed cart.
///
/// A labelled chip in the category's colour rather than a dot: what left the
/// card is a specific seat, and the buyer should be able to read which one on
/// its way to the summary that has already counted it.
class _FlyingSeat extends StatefulWidget {
  const _FlyingSeat({
    required this.from,
    required this.to,
    required this.color,
    required this.label,
    required this.fontFamily,
    required this.onDone,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final String label;
  final String? fontFamily;
  final VoidCallback onDone;

  @override
  State<_FlyingSeat> createState() => _FlyingSeatState();
}

class _FlyingSeatState extends State<_FlyingSeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.confirmFlight,
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final raw = _controller.value;
          final t = SeatLayerPickerMotion.spring.transform(raw);
          final position = Offset.lerp(widget.from, widget.to, t)!;
          // It appears at just over half size, reaches full size a fifth of
          // the way along, and shrinks as it lands.
          final scale = raw < _flyRise
              ? .6 + (.4 * (raw / _flyRise))
              : 1 - (.45 * ((raw - _flyRise) / (1 - _flyRise)));
          final opacity = raw < _flyRise
              ? raw / _flyRise
              : 1 - (.85 * ((raw - _flyRise) / (1 - _flyRise)));
          return Positioned(
            left: position.dx,
            top: position.dy,
            child: IgnorePointer(
              child: FractionalTranslation(
                translation: const Offset(-.5, -.5),
                child: Opacity(
                  opacity: opacity.clamp(0, 1),
                  child: Transform.scale(
                    scale: scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(
                          SeatLayerRadiusTokens.pill,
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              widget.label,
                              softWrap: false,
                              style: TextStyle(
                                color: _flyingInk(widget.color),
                                fontSize: 11,
                                height: 1,
                                fontWeight: seatLayerBoldWeight(
                                    context, FontWeight.w700),
                                fontFamily: widget.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

/// When the chip reaches full size, as a fraction of its flight.
const double _flyRise = .22;

/// Ink that reads on a category colour nobody chose for legibility.
Color _flyingInk(Color fill) => fill.computeLuminance() > .5
    ? const Color(0xFF111111)
    : const Color(0xFFFFFFFF);
