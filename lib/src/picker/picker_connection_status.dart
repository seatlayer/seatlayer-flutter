/// The connection status on the map: "You're offline", "Updating…" and
/// "Back online".
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import 'picker_a11y.dart';
import 'picker_connection.dart';
import 'picker_header.dart' show seatLayerPickerNow;
import 'picker_motion.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// Where the status may stand on the map's top line.
///
/// Beside: from [start] to [end] on the line at [top]. When the words do not
/// fit there on one line each, the status goes under the line at [belowTop]
/// and takes the map's whole width between the two [inset]s.
@immutable
class PickerConnectionStatusPlace {
  /// Creates a place.
  const PickerConnectionStatusPlace({
    required this.top,
    required this.start,
    required this.end,
    required this.belowTop,
    required this.inset,
    this.maxWidth = double.infinity,
  });

  /// The top of the line the status shares.
  final double top;

  /// Where the status starts on that line: after the test badge, if any.
  final double start;

  /// How much of the line's end is taken: the Map / 3D switch and its gap.
  final double end;

  /// The top of the row under the line, for a status that does not fit.
  final double belowTop;

  /// The map's own margin on both sides.
  final double inset;

  /// The widest the status is drawn, on a wide map.
  final double maxWidth;
}

/// The connection status, drawn on the map at [place].
///
/// Shows what [SeatLayerPickerController.connectionShown] says. Takes no
/// touches: the map under it still pans and zooms.
class SeatLayerPickerConnectionStatus extends StatefulWidget {
  /// Creates the status.
  const SeatLayerPickerConnectionStatus({super.key, required this.place});

  /// Where it stands.
  final PickerConnectionStatusPlace place;

  @override
  State<SeatLayerPickerConnectionStatus> createState() =>
      _SeatLayerPickerConnectionStatusState();
}

class _SeatLayerPickerConnectionStatusState
    extends State<SeatLayerPickerConnectionStatus>
    with TickerProviderStateMixin {
  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.connectionIn,
  );
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.connectionRing,
  );
  ValueListenable<SeatLayerConnectionShown>? _source;

  @override
  void initState() {
    super.initState();
    // Gone once it has faded out, so nothing is left for a screen reader.
    _presence.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _drawn = SeatLayerConnectionShown.none);
      }
    });
  }

  /// What is drawn: the last thing said, kept while the status fades out.
  SeatLayerConnectionShown _drawn = SeatLayerConnectionShown.none;
  Timer? _heldEnds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final source = SeatLayerPickerScope.controllerOf(context).connectionShown;
    if (!identical(source, _source)) {
      _source?.removeListener(_changed);
      _source = source..addListener(_changed);
      _changed();
    }
  }

  void _changed() {
    final shown = _source!.value;
    final reduced = SeatLayerPickerMotion.reduced(context);
    // Reduced motion keeps a short fade: a status that blinks in and out is
    // harder to notice than one that fades.
    final fade = reduced
        ? SeatLayerPickerMotion.crossfade
        : SeatLayerPickerMotion.connectionIn;
    _presence.duration = fade;
    _presence.reverseDuration = fade;
    if (shown == SeatLayerConnectionShown.none) {
      _presence.reverse();
    } else {
      setState(() => _drawn = shown);
      _presence.forward();
      _announce(shown);
    }
    if (shown == SeatLayerConnectionShown.updating && !reduced) {
      if (!_ring.isAnimating) _ring.repeat();
    } else {
      _ring.stop();
    }
  }

  /// "You're offline" and "Back online" are read once; "Updating…" is not.
  void _announce(SeatLayerConnectionShown shown) {
    if (shown == SeatLayerConnectionShown.updating) return;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final words = <String>[
      shown == SeatLayerConnectionShown.back
          ? strings.backOnline
          : strings.offline,
      if (shown == SeatLayerConnectionShown.offline && _heldWithTimeLeft())
        strings.stillHeld,
    ].join(' ');
    seatLayerAnnounce(context, words);
  }

  /// A hold the server confirmed, with time left on its clock.
  bool _heldWithTimeLeft() {
    final state = SeatLayerPickerScope.stateOf(context);
    return state.hold?.active == true &&
        state.holdRemaining(seatLayerPickerNow()) > Duration.zero;
  }

  /// Drops the second line at 0:00: from then the seats are not known to be
  /// held until the server has said so.
  void _dropHeldLineAtZero() {
    _heldEnds?.cancel();
    final remaining = SeatLayerPickerScope.stateOf(context)
        .holdRemaining(seatLayerPickerNow());
    if (remaining <= Duration.zero) return;
    _heldEnds = Timer(remaining, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _source?.removeListener(_changed);
    _heldEnds?.cancel();
    _presence.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = SeatLayerPickerScope.stringsOf(context);
    final theme = seatLayerMapChromeThemeOf(context);
    final dark = theme.brightness == Brightness.dark;
    final drawn = _drawn;
    if (drawn == SeatLayerConnectionShown.none) return const SizedBox.shrink();
    final title = switch (drawn) {
      SeatLayerConnectionShown.offline => strings.offline,
      SeatLayerConnectionShown.back => strings.backOnline,
      _ => strings.updating,
    };
    final held =
        drawn == SeatLayerConnectionShown.offline && _heldWithTimeLeft();
    if (held) _dropHeldLineAtZero();
    final line = held ? strings.stillHeld : null;
    final sign = switch (drawn) {
      SeatLayerConnectionShown.offline => dark
          ? SeatLayerDarkTokens.connectionLost
          : SeatLayerLightTokens.connectionLost,
      SeatLayerConnectionShown.back => dark
          ? SeatLayerDarkTokens.connectionBack
          : SeatLayerLightTokens.connectionBack,
      _ => theme.mutedText,
    };
    // Measured and drawn with the same style the Text widgets end up with.
    final inherited = DefaultTextStyle.of(context).style;
    final titleStyle = inherited.merge(TextStyle(
      color: theme.text,
      fontSize: SeatLayerSizeTokens.connectionStatusTitleFont,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
      height: 1.3,
      fontFamily: theme.fontFamily,
    ));
    final lineStyle = inherited.merge(TextStyle(
      color: theme.mutedText,
      fontSize: SeatLayerSizeTokens.connectionStatusLineFont,
      fontWeight: FontWeight.w400,
      height: 1.35,
      fontFamily: theme.fontFamily,
    ));
    final scaler = MediaQuery.textScalerOf(context);
    // The sign grows with the words, to the same 1.6 the sheet stops at.
    final signSize = scaler
        .clamp(maxScaleFactor: SeatLayerTypeScaleTokens.sheet)
        .scale(SeatLayerSizeTokens.connectionStatusSign);
    final place = widget.place;
    final direction = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, box) {
        double words(String text, TextStyle style) => (TextPainter(
              text: TextSpan(text: text, style: style),
              textDirection: direction,
              textScaler: scaler,
              maxLines: 1,
            )..layout())
                .width;
        final natural = SeatLayerSizeTokens.connectionStatusPadStart +
            signSize +
            SeatLayerSizeTokens.connectionStatusSignGap +
            math.max(words(title, titleStyle),
                line == null ? 0.0 : words(line, lineStyle)) +
            SeatLayerSizeTokens.connectionStatusPadEnd +
            2;
        final beside =
            math.min(box.maxWidth - place.start - place.end, place.maxWidth);
        final fits = natural <= beside;
        final card = _Card(
          sign: PickerConnectionSign(
            shown: drawn,
            color: sign,
            size: signSize,
            ring: _ring,
          ),
          title: title,
          line: line,
          titleStyle: titleStyle,
          lineStyle: lineStyle,
          ground: dark ? theme.surface : theme.background,
          edge: theme.divider,
          stretch: !fits,
        );
        final reduced = SeatLayerPickerMotion.reduced(context);
        final arriving = AnimatedBuilder(
          animation: _presence,
          builder: (context, child) {
            final t =
                SeatLayerPickerMotion.easeEnter.transform(_presence.value);
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(
                  0,
                  reduced
                      ? 0
                      : (1 - t) * SeatLayerSizeTokens.connectionStatusRise,
                ),
                child: child,
              ),
            );
          },
          child: Semantics(
            container: true,
            label: [title, if (line != null) line].join(' '),
            child: ExcludeSemantics(child: card),
          ),
        );
        return IgnorePointer(
          child: Stack(
            children: <Widget>[
              PositionedDirectional(
                top: fits ? place.top : place.belowTop,
                start: fits ? place.start : place.inset,
                end: fits ? null : place.inset,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: fits ? beside : double.infinity,
                  ),
                  child: arriving,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.sign,
    required this.title,
    required this.line,
    required this.titleStyle,
    required this.lineStyle,
    required this.ground,
    required this.edge,
    required this.stretch,
  });

  final Widget sign;
  final String title;
  final String? line;
  final TextStyle titleStyle;
  final TextStyle lineStyle;
  final Color ground;
  final Color edge;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final duration = SeatLayerPickerMotion.reduced(context)
        ? SeatLayerPickerMotion.crossfade
        : SeatLayerPickerMotion.connectionWords;
    final words = Column(
      key: ValueKey<String>('$title|$line'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: titleStyle),
        if (line != null) Text(line!, style: lineStyle),
      ],
    );
    return AnimatedSize(
      duration: duration,
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        key: const ValueKey<String>('seatlayer-connection-status'),
        constraints: BoxConstraints(
          minHeight: line == null
              ? SeatLayerSizeTokens.connectionStatusHeight
              : SeatLayerSizeTokens.connectionStatusTwoLineHeight,
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(
          SeatLayerSizeTokens.connectionStatusPadStart,
          6,
          SeatLayerSizeTokens.connectionStatusPadEnd,
          6,
        ),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: BorderRadius.circular(
            line == null
                ? SeatLayerRadiusTokens.pill
                : SeatLayerRadiusTokens.connectionStatusTwoLines,
          ),
          border: Border.all(color: edge),
          // The map buttons' own shadow, so the status sits at their height.
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
          children: <Widget>[
            sign,
            const SizedBox(width: SeatLayerSizeTokens.connectionStatusSignGap),
            Flexible(
              child: AnimatedSwitcher(
                duration: duration,
                layoutBuilder: (current, previous) => Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: <Widget>[...previous, if (current != null) current],
                ),
                child: words,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The three signs differ in shape as well as colour: a crossed-out wifi
/// sign, a turning ring, a tick.
class PickerConnectionSign extends StatelessWidget {
  /// Creates a sign. [ring] turns the ring; null stands it still.
  const PickerConnectionSign({
    super.key,
    required this.shown,
    required this.color,
    required this.size,
    this.ring,
  });

  final SeatLayerConnectionShown shown;
  final Color color;
  final double size;
  final Animation<double>? ring;

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(
      size: Size.square(size),
      painter: _SignPainter(shown, color),
    );
    final turns = ring;
    if (shown != SeatLayerConnectionShown.updating || turns == null) {
      return painted;
    }
    return RotationTransition(turns: turns, child: painted);
  }
}

class _SignPainter extends CustomPainter {
  _SignPainter(this.shown, this.color);

  final SeatLayerConnectionShown shown;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 24-unit grid.
    canvas.scale(size.width / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (shown) {
      case SeatLayerConnectionShown.updating:
        const box = Rect.fromLTWH(3.5, 3.5, 17, 17);
        canvas.drawArc(
          box,
          0,
          math.pi * 2,
          false,
          Paint()
            ..color = color.withValues(alpha: color.a * .22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
        canvas.drawArc(
            box, -math.pi / 2, 1.9, false, stroke..strokeWidth = 2.6);
      case SeatLayerConnectionShown.back:
        canvas.drawPath(
          Path()
            ..moveTo(5, 12.6)
            ..lineTo(9.8, 17.2)
            ..lineTo(19, 7.4),
          stroke..strokeWidth = 2.6,
        );
      case SeatLayerConnectionShown.offline:
      case SeatLayerConnectionShown.none:
        canvas.drawCircle(const Offset(12, 19.6), 1.25, Paint()..color = color);
        canvas.drawPath(
          Path()
            ..moveTo(8.5, 16.43)
            ..arcToPoint(const Offset(15.5, 16.43),
                radius: const Radius.circular(5))
            ..moveTo(5, 12.86)
            ..arcToPoint(const Offset(10.17, 10.17),
                radius: const Radius.circular(10))
            ..moveTo(19, 12.86)
            ..arcToPoint(const Offset(16.99, 11.34),
                radius: const Radius.circular(10), clockwise: false)
            ..moveTo(2, 8.82)
            ..arcToPoint(const Offset(6.18, 6.18),
                radius: const Radius.circular(15))
            ..moveTo(22, 8.82)
            ..arcToPoint(const Offset(10.71, 5.06),
                radius: const Radius.circular(15), clockwise: false),
          stroke,
        );
        canvas.drawLine(const Offset(3, 3), const Offset(21, 21), stroke);
    }
  }

  @override
  bool shouldRepaint(_SignPainter old) =>
      old.shown != shown || old.color != color;
}

/// The sign's colour for [shown]: amber when lost, green when back, the muted
/// text colour while trying. Never the club's accent.
Color pickerConnectionSignColor(
  SeatLayerConnectionShown shown,
  SeatLayerResolvedPickerTheme theme,
) {
  final dark = theme.brightness == Brightness.dark;
  return switch (shown) {
    SeatLayerConnectionShown.offline => dark
        ? SeatLayerDarkTokens.connectionLost
        : SeatLayerLightTokens.connectionLost,
    SeatLayerConnectionShown.back => dark
        ? SeatLayerDarkTokens.connectionBack
        : SeatLayerLightTokens.connectionBack,
    _ => theme.mutedText,
  };
}
