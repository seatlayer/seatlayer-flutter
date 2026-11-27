/// The phone's cart row: the circle that opens the list, what the cart holds
/// and what it comes to, and the way on, on one line.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'picker_a11y.dart';
import 'picker_cart_bar_rule.dart';
import 'picker_cart_list.dart';
import 'picker_checkout_cta.dart';
import 'picker_money.dart';
import 'picker_motion.dart';
import 'picker_styles.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// How wide [text] is drawn in [style] here.
double _widthOf(BuildContext context, String text, TextStyle style) {
  if (text.isEmpty) return 0;
  final bold = MediaQuery.boldTextOf(context);
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: bold
          ? style.merge(const TextStyle(fontWeight: FontWeight.bold))
          : style,
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

PickerCartBarWidths _widthsOf(
  BuildContext context,
  String label,
  TextStyle style,
) =>
    PickerCartBarWidths(
      whole: _widthOf(context, label, style),
      parts: <double>[
        for (final part in pickerCartBarParts(label))
          _widthOf(context, part, style),
      ],
    );

/// The words that stay on the button, in the app's own wording.
List<String> _ownWords(BuildContext context) {
  final strings = SeatLayerPickerScope.stringsOf(context);
  return <String>[
    strings.findBestSeatsCta,
    strings.holdAndCheckout,
    strings.continueToCheckout,
  ];
}

/// The row a checkout button stands in. A button with one over it takes the
/// row's measures.
class PickerCartBarRow extends InheritedWidget {
  /// Creates the row's measures.
  const PickerCartBarRow({
    super.key,
    required this.width,
    required super.child,
  });

  /// The row's width, its padding included.
  final double width;

  /// The row around [context], if there is one.
  static PickerCartBarRow? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PickerCartBarRow>();

  @override
  bool updateShouldNotify(PickerCartBarRow old) => old.width != width;
}

/// The checkout button's style in the row, under whatever the app sets.
ButtonStyle pickerCartBarButtonStyle(BuildContext context, ButtonStyle? app) {
  final theme = seatLayerMapChromeThemeOf(context);
  final own = theme.buttonRadius == SeatLayerRadiusTokens.button;
  return FilledButton.styleFrom(
    backgroundColor: theme.accent,
    foregroundColor: theme.onAccent,
    disabledBackgroundColor: Color.lerp(theme.surface, theme.background, .35),
    disabledForegroundColor: theme.mutedText,
    minimumSize: Size(0, theme.layout.checkoutButtonHeight),
    padding: const EdgeInsets.symmetric(
      horizontal: PickerCartBarSize.buttonPadX,
      vertical: PickerCartBarSize.buttonPadY,
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    textStyle: TextStyle(
      fontSize: PickerCartBarSize.buttonFont,
      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
      fontFamily: theme.fontFamily,
      height: PickerCartBarSize.buttonLine,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  )
      .copyWith(
        side: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? BorderSide(color: theme.divider)
              : null,
        ),
      )
      .merge(app)
      .merge(
        seatLayerButtonShape(
          own ? PickerCartBarSize.buttonRadius : theme.buttonRadius,
        ),
      );
}

TextStyle _buttonText(ButtonStyle style, {required bool enabled}) =>
    style.textStyle?.resolve(<WidgetState>{
      if (!enabled) WidgetState.disabled,
    }) ??
    const TextStyle();

/// The checkout button as the row draws it.
class PickerCartBarButton extends StatelessWidget {
  /// Creates the row's button.
  const PickerCartBarButton({
    super.key,
    required this.cta,
    required this.onPressed,
    required this.row,
    this.style,
  });

  /// What it says.
  final SeatLayerCheckoutCtaState cta;

  /// What a press does, or null.
  final VoidCallback? onPressed;

  /// The row it stands in.
  final PickerCartBarRow row;

  /// The app's own style.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = pickerCartBarButtonStyle(context, style);
    final base = _buttonText(resolved, enabled: onPressed != null);
    final size = base.fontSize ?? PickerCartBarSize.buttonFont;
    TextStyle at(double letters) => base.copyWith(
          fontSize: size * letters / PickerCartBarSize.buttonFont,
        );
    final own = _ownWords(context);
    final labelIsOwn = own.contains(cta.label);
    final plan = PickerCartBarPlan.of(
      width: row.width,
      own: <PickerCartBarWidths>[
        for (final words in own) _widthsOf(context, words, base),
      ],
      label: <PickerCartBarWidths>[
        for (final letters in labelIsOwn
            ? PickerCartBarSize.letters.take(1)
            : PickerCartBarSize.letters)
          _widthsOf(context, cta.label, at(letters)),
      ],
      labelIsOwn: labelIsOwn,
    );
    return SizedBox(
      width: plan.buttonWidth,
      child: FilledButton(
        style: resolved,
        onPressed: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: plan.textWidth),
          child: Text(
            cta.label,
            textAlign: TextAlign.center,
            style: plan.letters == 0
                ? null
                : TextStyle(
                    fontSize:
                        at(PickerCartBarSize.letters[plan.letters]).fontSize,
                  ),
          ),
        ),
      ),
    );
  }
}

/// What the row says.
///
/// It counts what the buyer has AGREED to. A tapped seat is in the runtime's
/// selection — and so in the cart, the count and the total — from the moment
/// it is tapped, but a confirm card standing over the map is still asking
/// whether they want it.
@immutable
class PickerCartBarSummary {
  const PickerCartBarSummary._({
    required this.closed,
    required this.count,
    required this.first,
    required this.total,
    required this.second,
  });

  /// Reads the cart.
  factory PickerCartBarSummary.of(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final state = controller.state;
    if (state.event?.salesClosed == true && state.hold == null) {
      return PickerCartBarSummary._(
        closed: true,
        count: 0,
        first: strings.salesClosed,
        total: '',
        second: state.event?.startsAtLabel ?? '',
      );
    }
    final count = controller.confirmedTicketCount;
    final currency = state.snapshot?.currency ?? 'USD';
    return PickerCartBarSummary._(
      closed: false,
      count: count,
      first: count == 0 ? strings.noSeatsSelected : strings.ticketCount(count),
      total: count == 0
          ? ''
          : pickerMoney(context, controller.confirmedCartTotal, currency),
      second: count == 0
          ? ''
          : seatLayerCartSeatsLine(controller.confirmedCartLines, state),
    );
  }

  /// The sale is over and no seat is held: the row says so, and has no button.
  final bool closed;

  /// How many tickets.
  final int count;

  /// "2 tickets", "No seats selected" or "Sales are closed".
  final String first;

  /// The total, or nothing.
  final String total;

  /// The seats' names, or a closed event's date.
  final String second;

  /// What a screen reader says.
  String get spoken => <String>[first, if (closed) second else total]
      .where((part) => part.isNotEmpty)
      .join(', ');
}

/// The row itself, with the buyer's own news over it.
class PickerCartBar extends StatelessWidget {
  /// Creates the row.
  const PickerCartBar({
    super.key,
    required this.news,
    required this.button,
    required this.buttonIsOwn,
    required this.buttonStyle,
    required this.attribution,
    required this.open,
    required this.asking,
    required this.onToggle,
  });

  /// What stands over the row. It takes no room while it says nothing.
  ///
  /// Where the screen has too little room for all of it, the last part is
  /// given what the others leave.
  final List<Widget> news;

  /// The way on.
  final Widget button;

  /// Whether [button] takes the row's measures. An app's own part keeps the
  /// full width, under the words.
  final bool buttonIsOwn;

  /// The app's own style for the ready-made button.
  final ButtonStyle? buttonStyle;

  /// A line of the app's own under the row.
  final Widget? attribution;

  /// Whether the list is open.
  final bool open;

  /// A seat card is asking: nothing in the row can be pressed until it is
  /// answered.
  final bool asking;

  /// Opens or closes the list.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final summary = PickerCartBarSummary.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // The news gives way before the row does: what the row cannot spare
        // it is not given, and its last part scrolls in what is left.
        Flexible(
          child: _RoomForNews(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PickerCartBarSize.padX,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ...news.take(news.length - 1),
                  if (news.isNotEmpty) Flexible(child: news.last),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: asking,
          child: Opacity(
            opacity: asking ? PickerCartBarSize.askingOpacity : 1,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _row(context, summary, constraints.maxWidth),
            ),
          ),
        ),
        // Centred, not trailing: at the foot of a phone the trailing edge is
        // the display's rounded corner.
        if (attribution case final line?) Center(child: line),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    PickerCartBarSummary summary,
    double width,
  ) {
    final words = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PickerCartBarSize.minHeight),
      child: Row(
        children: <Widget>[
          PickerCartBarDisc(open: open, hidden: asking, onPressed: onToggle),
          const SizedBox(width: PickerCartBarSize.gap - _discReach),
          Expanded(
            child: Semantics(
              // Announced on change rather than on a timer: the sentence
              // changes when the cart does, and never otherwise.
              liveRegion: true,
              container: true,
              label: summary.spoken,
              // The words open the list as the circle does; a screen reader
              // is given the circle for it, and reads these as a line.
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: PickerCartBarSize.minHeight,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      heightFactor: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) => PickerCartBarWords(
                          summary: summary,
                          room: constraints.maxWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    const padding = EdgeInsetsDirectional.fromSTEB(
      PickerCartBarSize.padX - _discReach,
      PickerCartBarSize.padY,
      PickerCartBarSize.padX,
      0,
    );
    if (summary.closed) return Padding(padding: padding, child: words);
    final resolved = pickerCartBarButtonStyle(context, buttonStyle);
    final text = _buttonText(resolved, enabled: true);
    final under = !buttonIsOwn ||
        PickerCartBarPlan.of(
          width: width,
          own: <PickerCartBarWidths>[
            for (final own in _ownWords(context)) _widthsOf(context, own, text),
          ],
          label: <PickerCartBarWidths>[
            _widthsOf(context, _ownWords(context).first, text),
          ],
          labelIsOwn: true,
        ).under;
    final way = PickerCartBarRow(width: width, child: button);
    if (under) {
      return Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            words,
            const SizedBox(height: PickerCartBarSize.underGap),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: _discReach),
              child: buttonIsOwn ? way : button,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(child: words),
          const SizedBox(width: PickerCartBarSize.gap),
          way,
        ],
      ),
    );
  }
}

/// How far the circle's press reaches past what is drawn.
const double _discReach =
    (PickerCartBarSize.minHeight - PickerCartBarSize.disc) / 2;

/// The row's circle: the one named control that opens and closes the list.
///
/// Its arrow points up while the list is shut and turns over when it opens, so
/// the state and the control that changes it are one thing. Drawn at 28
/// points, pressed over 44.
class PickerCartBarDisc extends StatelessWidget {
  /// Creates the circle.
  const PickerCartBarDisc({
    super.key,
    required this.open,
    required this.hidden,
    required this.onPressed,
  });

  /// Whether the list is open.
  final bool open;

  /// A seat card is asking: the circle is not drawn and its place is kept.
  final bool hidden;

  /// Opens or closes the list.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const side = PickerCartBarSize.minHeight;
    if (hidden) return const SizedBox.square(dimension: side);
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Semantics(
      container: true,
      button: true,
      expanded: open,
      label: open ? strings.collapseCart : strings.expandCart,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: side,
            child: Center(
              child: Container(
                width: PickerCartBarSize.disc,
                height: PickerCartBarSize.disc,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.divider),
                ),
                child: AnimatedRotation(
                  duration: SeatLayerPickerMotion.of(
                    context,
                    SeatLayerPickerMotion.chevron,
                  ),
                  curve: SeatLayerPickerMotion.easeEnter,
                  turns: open ? .5 : 0,
                  child: CustomPaint(
                    size: const Size.square(PickerCartBarSize.chevron),
                    painter: _ChevronPainter(theme.text),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An arrow of 12 by 6 in a box of 24, with a stroke of 2.6.
class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    canvas.drawPath(
      Path()
        ..moveTo(6 * unit, 15 * unit)
        ..lineTo(12 * unit, 9 * unit)
        ..lineTo(18 * unit, 15 * unit),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}

/// The row's words.
class PickerCartBarWords extends StatelessWidget {
  /// Creates the words.
  const PickerCartBarWords({
    super.key,
    required this.summary,
    required this.room,
  });

  /// What they say.
  final PickerCartBarSummary summary;

  /// The width they have.
  final double room;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    final base = DefaultTextStyle.of(context).style;
    TextStyle words(double size, FontWeight weight, Color color) => base.merge(
          TextStyle(
            color: color,
            fontSize: size,
            fontWeight: seatLayerBoldWeight(context, weight),
            fontFamily: theme.fontFamily,
            height: PickerCartBarSize.wordsLine / size,
            letterSpacing: 0,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        );
    final countStyle =
        words(PickerCartBarSize.countFont, FontWeight.w600, theme.text);
    final totalStyle =
        words(PickerCartBarSize.totalFont, FontWeight.w800, theme.text)
            .copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final countWidth = _widthOf(context, summary.first, countStyle);
    final totalWidth = _widthOf(context, summary.total, totalStyle);
    final beside = summary.total.isEmpty ||
        pickerCartBarTotalBeside(
          count: countWidth,
          total: totalWidth,
          room: room,
        );
    final second = summary.second.isEmpty || !beside
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              summary.second,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: words(
                PickerCartBarSize.namesFont,
                FontWeight.w400,
                theme.mutedText,
              ),
            ),
          );
    Widget first(Color ink) => SeatLayerCrossFade(
          token: summary.first,
          child: Text(
            summary.first,
            maxLines: summary.count == 0 && !summary.closed ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: countStyle.copyWith(color: ink),
          ),
        );
    Widget amount(Color ink) => SeatLayerCrossFade(
          token: summary.total,
          child: Text(
            summary.total,
            maxLines: 1,
            softWrap: false,
            style: totalStyle.copyWith(color: ink),
          ),
        );
    if (summary.total.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PickerCartSwell(
            token: summary.first,
            most: 1,
            builder: first,
          ),
          if (second != null) second,
        ],
      );
    }
    final line = countWidth + PickerCartBarSize.totalGap + totalWidth;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (beside)
          PickerCartSwell(
            token: summary.first,
            // Never past the words' own room.
            most: line > 0 ? math.max(1, math.min(1.3, room / line)) : 1.3,
            builder: (ink) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(child: first(ink)),
                const SizedBox(width: PickerCartBarSize.totalGap),
                // The words that leave may be wider than the ones that come.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(0, room - PickerCartBarSize.totalGap),
                  ),
                  child: amount(ink),
                ),
              ],
            ),
          )
        else ...<Widget>[
          PickerCartSwell(token: summary.first, most: 1, builder: first),
          const SizedBox(height: 1),
          // A total is never cut: a longer one is drawn smaller.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: PickerCartSwell(
              token: summary.first,
              most: 1,
              builder: amount,
            ),
          ),
        ],
        if (second != null) second,
      ],
    );
  }
}

/// The one beat of movement a changed count earns: the only feedback a buyer
/// gets that a tap on the map reached a collapsed sheet.
///
/// The words grow out of their own start and their ink blinks to the accent.
class PickerCartSwell extends StatefulWidget {
  /// Creates the swell.
  const PickerCartSwell({
    super.key,
    required this.token,
    required this.builder,
    this.most = 1.3,
    this.anchor = AlignmentDirectional.centerStart,
  });

  /// What it says; a change is what swells.
  final String token;

  /// Draws the words in the ink of the moment.
  final Widget Function(Color ink) builder;

  /// How large it gets.
  final double most;

  /// The edge it grows from.
  final AlignmentGeometry anchor;

  @override
  State<PickerCartSwell> createState() => _PickerCartSwellState();
}

class _PickerCartSwellState extends State<PickerCartSwell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.bump,
  );
  late String _last = widget.token;

  /// A change waiting for the chip to land before it is allowed to swell.
  bool _onLanding = false;

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (widget.token != _last) {
      _last = widget.token;
      if (!SeatLayerPickerMotion.reduced(context)) _onLanding = true;
    }
    // On the chip's LANDING, not on the press: while a chip is still flying
    // the number holds still, and the controller rebuilds this the moment the
    // flight is over.
    if (_onLanding && !controller.cartLanding) {
      _onLanding = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _bump.forward(from: 0);
      });
    }
    final theme = seatLayerMapChromeThemeOf(context);
    return AnimatedBuilder(
      animation: _bump,
      builder: (context, _) {
        final t = _curve(_bump.value);
        return Transform.scale(
          scale: 1 + ((widget.most - 1) * t),
          alignment: widget.anchor.resolve(Directionality.of(context)),
          child: widget.builder(Color.lerp(theme.text, theme.accent, t)!),
        );
      },
    );
  }

  /// Out to the full swell at forty-five per cent, and back.
  static double _curve(double t) => t <= .45
      ? SeatLayerPickerMotion.easeEnter.transform(t / .45)
      : SeatLayerPickerMotion.easeEnter.transform((1 - t) / .55);
}

/// Room over the news, only while there is some.
class _RoomForNews extends SingleChildRenderObjectWidget {
  const _RoomForNews({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderRoomForNews(null);
}

class _RenderRoomForNews extends RenderShiftedBox {
  _RenderRoomForNews(super.child);

  @override
  void performLayout() {
    final news = child;
    if (news == null) {
      size = constraints.smallest;
      return;
    }
    // The room over the news comes out of what the news is given, so the
    // two together never stand taller than the row allows.
    final loose = constraints.loosen();
    news.layout(
      loose.copyWith(
        maxHeight: math.max(0.0, loose.maxHeight - PickerCartBarSize.padY),
      ),
      parentUsesSize: true,
    );
    final room = news.size.height > 0 ? PickerCartBarSize.padY : 0.0;
    (news.parentData! as BoxParentData).offset = Offset(0, room);
    size = constraints.constrain(
      Size(constraints.maxWidth, news.size.height + room),
    );
  }
}
