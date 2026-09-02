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
            borderRadius:
                BorderRadius.circular(SeatLayerRadiusTokens.button),
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
                fontWeight: FontWeight.w800,
                fontFamily: theme.fontFamily,
              ).merge(seatLayerStyleRole(style?.textStyle)),
            ),
          ),
        ),
      ),
    );
  }
}

/// How many breaths the invitation takes before it rests.
///
/// Bounded on purpose, where the web widget's is not. An animation with no end
/// is movement in the corner of the eye for as long as the buyer hesitates,
/// and a card that will not stop moving reads as a card that has not finished
/// loading.
const int _inviteBreaths = 3;

/// How far the breath's halo reaches, and how deep its colour goes.
const double _inviteHalo = 6;
const double _inviteHaloInk = .35;

/// How much the button swells at the top of each breath.
const double _inviteSwell = .02;

/// The card's recommended answer, and the small theatre around it.
///
/// Three things happen here, and each says something the still button cannot.
/// On arrival one highlight crosses it: this is the thing to press. While it
/// waits it breathes, slowly, three times: the offer is still open. On the
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
    this.style,
  });

  final String label;

  /// Whether the press has been committed and the button is now a receipt.
  final bool added;

  /// Whether the arrival highlight and the breath play at all.
  final bool invite;

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

  @override
  void initState() {
    super.initState();
    if (widget.invite) _invite.forward();
  }

  @override
  void didUpdateWidget(covariant _AddSeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.invite && oldWidget.invite) _invite.stop();
    if (widget.added && !oldWidget.added) {
      _invite.stop();
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
  double get _sweep => ((_elapsed - _inviteDelayMs) / _inviteSweepMs)
      .clamp(0.0, 1.0)
      .toDouble();

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
            : theme.accent);
    final ink = styledInk ??
        (disabled ? pickerAlpha(theme.mutedText, .58) : theme.onAccent);
    final shape = seatLayerStyleRole(widget.style?.shape) ??
        RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SeatLayerRadiusTokens.button),
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
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 13,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: theme.fontFamily,
                                ).merge(
                                  seatLayerStyleRole(widget.style?.textStyle),
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
  /// Zero before the breathing starts and zero again once the last breath is
  /// out, so the button ends the invitation at exactly its resting size.
  double get _breath {
    final since = _elapsed - _inviteBreatheDelayMs;
    if (since <= 0 || _invite.value >= 1) return 0;
    return (1 - math.cos((since / _inviteBreatheMs) * 2 * math.pi)) / 2;
  }
}

/// How long the whole invitation lasts, wait and breaths together.
final Duration _inviteSpan = SeatLayerPickerMotion.inviteBreatheDelay +
    (SeatLayerPickerMotion.inviteBreathe * _inviteBreaths);

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
        ..color = pickerAlpha(color, _inviteHaloInk * (1 - breath))
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
  const _TickPainter({required this.color, required this.drawn});

  final Color color;

  /// How much of the stroke is on the canvas, 0 to 1.
  final double drawn;

  @override
  void paint(Canvas canvas, Size size) {
    if (drawn <= 0) return;
    final scale = size.width / 24;
    final path = Path()
      ..moveTo(20 * scale, 6 * scale)
      ..lineTo(9 * scale, 17 * scale)
      ..lineTo(4 * scale, 12 * scale);
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
      oldDelegate.color != color || oldDelegate.drawn != drawn;
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
                                fontWeight: FontWeight.w700,
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
Color _flyingInk(Color fill) =>
    fill.computeLuminance() > .5 ? const Color(0xFF111111) : const Color(0xFFFFFFFF);
