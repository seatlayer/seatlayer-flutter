/// The picker's one voice for things that happened to the buyer's cart.
///
/// A toast is a sentence, not a chip: it wraps, it never blocks anything, and
/// it is gone in a few seconds. Everything the buyer must still be able to act
/// on lives on a surface that stays — the tray's lapse line, the access panel,
/// the peek bar — and the toast is the copy of that fact for a buyer who is
/// looking at the map instead.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../payloads.dart';
import 'picker_availability.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_strings.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// How loud one toast is, and what colour its hairline takes.
///
/// Only the border changes between tones. A message the buyer did not ask for
/// should read as the same object every time, coloured by how much it matters
/// rather than repainted into a different component.
enum SeatLayerPickerToastTone {
  /// A fact. "D-14 removed."
  neutral,

  /// Something the buyer should know before they act again.
  warning,

  /// Something that did not work.
  error,

  /// Something that did.
  success,
}

/// One thing to say, and at most one thing to do about it.
@immutable
class SeatLayerPickerToast {
  /// Creates a toast.
  const SeatLayerPickerToast(
    this.message, {
    this.tone = SeatLayerPickerToastTone.neutral,
    this.actionLabel,
    this.onAction,
  });

  /// The sentence.
  final String message;

  /// How much it matters.
  final SeatLayerPickerToastTone tone;

  /// The label of the one action, or null for a toast that only tells.
  final String? actionLabel;

  /// What that action does.
  final VoidCallback? onAction;

  /// Whether this toast offers something to press.
  bool get hasAction => actionLabel != null && onAction != null;
}

/// How long one toast stays up before it takes itself away.
const Duration seatLayerToastDwell = Duration(
  milliseconds: SeatLayerMotionTokens.toastDwell,
);

/// The queue behind one picker's toasts.
///
/// Deliberately a queue of one. Two sentences stacked over a map are two
/// things to read while the thing they are about is underneath them, so a new
/// message replaces the standing one and restarts its dwell. The same sentence
/// arriving twice in a row is ignored, because two signals commonly describe
/// one event — a conflict raises both a per-seat and a bulk telling — and a
/// toast that re-enters says something happened twice.
class SeatLayerPickerToastQueue extends ChangeNotifier {
  SeatLayerPickerToast? _current;
  Timer? _dwell;

  /// What is on screen, or null.
  SeatLayerPickerToast? get current => _current;

  /// Say [toast], replacing anything standing.
  void show(SeatLayerPickerToast toast) {
    if (_current?.message == toast.message && _current?.tone == toast.tone) {
      return;
    }
    _current = toast;
    _dwell?.cancel();
    _dwell = null;
    _arm();
    notifyListeners();
  }

  /// Start the dwell, but only once something is rendering the toast.
  ///
  /// A queue nobody is watching must not run a clock: a picker composed
  /// without a toast layer would otherwise leave a four-second timer behind
  /// every message, and the message itself would expire unseen before the
  /// surface that shows it was ever mounted.
  void _arm() {
    if (_current == null || !hasListeners || _dwell != null) return;
    _dwell = Timer(seatLayerToastDwell, dismiss);
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _arm();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (hasListeners) return;
    _dwell?.cancel();
    _dwell = null;
  }

  /// Take the standing toast away now.
  void dismiss() {
    _dwell?.cancel();
    _dwell = null;
    if (_current == null) return;
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _dwell?.cancel();
    _dwell = null;
    super.dispose();
  }
}

final Expando<SeatLayerPickerToastQueue> _queues =
    Expando<SeatLayerPickerToastQueue>('seatlayer-picker-toasts');

/// The toast queue belonging to [controller], created on first use.
///
/// Held beside the controller rather than inside it: the queue is presentation
/// and the controller is the session, and a host driving the picker headlessly
/// should never allocate one. It lives exactly as long as the controller does.
SeatLayerPickerToastQueue seatLayerPickerToasts(
  SeatLayerPickerController controller,
) =>
    _queues[controller] ??= SeatLayerPickerToastQueue();

/// The toast surface itself: a wrapping sentence on the picker's own ground.
class SeatLayerPickerToastCard extends StatelessWidget {
  /// Creates the surface for [toast].
  const SeatLayerPickerToastCard({super.key, required this.toast, this.theme});

  /// What to say.
  final SeatLayerPickerToast toast;

  /// The palette to paint with, or null to read the map chrome's.
  final SeatLayerResolvedPickerTheme? theme;

  @override
  Widget build(BuildContext context) {
    final palette = theme ?? seatLayerMapChromeThemeOf(context);
    final border = switch (toast.tone) {
      SeatLayerPickerToastTone.neutral => palette.divider,
      SeatLayerPickerToastTone.warning => palette.warning,
      SeatLayerPickerToastTone.error => palette.error,
      // The picker has no green of its own, and inventing one would be a
      // fourteenth colour nobody chose. A confirmation is the buyer's own
      // action landing, which is what the accent already means here.
      SeatLayerPickerToastTone.success => palette.accent,
    };
    final Widget line = Text(
      toast.message,
      style: TextStyle(
        color: palette.text,
        fontSize: 12.5,
        height: 1.35,
        fontWeight: FontWeight.w600,
        fontFamily: palette.fontFamily,
      ),
    );
    // The lift is a real shadow rather than a Material elevation: an elevation
    // cannot spread inwards, so over a pale map it draws a hard ring instead
    // of the long, offset, tighter-than-blurred shadow the rest of the
    // picker's floating surfaces use.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: pickerAlpha(const Color(0xFF000000), .5),
            blurRadius: 32,
            spreadRadius: -12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          padding: EdgeInsets.fromLTRB(16, 9, toast.hasAction ? 8 : 16, 9),
          child: toast.hasAction
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(child: line),
                    const SizedBox(width: 12),
                    _ToastAction(toast: toast, theme: palette),
                  ],
                )
              : line,
        ),
      ),
    );
  }
}

class _ToastAction extends StatelessWidget {
  const _ToastAction({required this.toast, required this.theme});

  final SeatLayerPickerToast toast;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        // A 44 pt hit box around a 30 pt pill: the pill is the drawn size the
        // web picker uses, and a thumb needs the rest of it.
        constraints: const BoxConstraints(
          minHeight: SeatLayerSizeTokens.minimumHitTarget,
        ),
        child: Center(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.accent,
              foregroundColor: theme.onAccent,
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
            ),
            onPressed: toast.onAction,
            child: Text(
              toast.actionLabel!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
        ),
      );
}

/// The bottom-centre band of the map where toasts appear.
///
/// Drop it into the map's [Stack] as a `Positioned.fill`. It renders nothing
/// until something is said, and it never takes a pointer except on its own
/// action button, so the map underneath stays the way out.
class SeatLayerPickerToastLayer extends StatefulWidget {
  /// Creates the toast layer.
  const SeatLayerPickerToastLayer({
    super.key,
    this.bottomInset = 0,
    this.lifted = false,
  });

  /// What the chrome standing on the bottom of the map already covers.
  final double bottomInset;

  /// Whether a seat card is up.
  ///
  /// The message is the reply to the tap that opened that card, so it rises
  /// clear of it rather than being read through it.
  final bool lifted;

  /// How far the toast rises to clear a seat card.
  ///
  /// The web measures the card's own top; a native card is laid out by the
  /// same delegate every time, so one number is the same answer with fewer
  /// moving parts.
  static const double cardLift = SeatLayerSizeTokens.toastCardLift;

  @override
  State<SeatLayerPickerToastLayer> createState() =>
      _SeatLayerPickerToastLayerState();
}

class _SeatLayerPickerToastLayerState extends State<SeatLayerPickerToastLayer> {
  SeatLayerPickerController? _controller;
  SeatLayerPickerToastQueue? _queue;
  StreamSubscription<SelectedObjectUnavailableEvent>? _conflicts;
  StreamSubscription<void>? _expiries;
  SeatLayerHoldLapse? _toldAboutLapse;
  bool? _wasSalesClosed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (identical(controller, _controller)) {
      _syncState();
      return;
    }
    _detach();
    _controller = controller;
    _queue = seatLayerPickerToasts(controller);
    _queue!.addListener(_onQueue);
    controller.addListener(_onControllerChanged);
    _conflicts = controller.mapController.onSelectedObjectsUnavailable.listen(
      _onConflict,
    );
    // A hold that simply ran out, with no refresh to explain it. The richer
    // lapse telling supersedes this one on the next frame when there is one;
    // the queue's replace-in-place is what makes that read as one message.
    _expiries = controller.mapController.onHoldExpired.listen((_) {
      if (_controller?.holdLapse == null) {
        _say(
          SeatLayerPickerToast(
            _strings.holdExpired,
            tone: SeatLayerPickerToastTone.warning,
          ),
        );
      }
    });
    _wasSalesClosed = controller.state.event?.salesClosed;
  }

  void _detach() {
    _controller?.removeListener(_onControllerChanged);
    _queue?.removeListener(_onQueue);
    unawaited(_conflicts?.cancel());
    unawaited(_expiries?.cancel());
    _conflicts = null;
    _expiries = null;
  }

  @override
  void dispose() {
    _detach();
    // The layer owns the moment, not the queue: a picker that outlives this
    // composition keeps its queue, but nothing is left ticking behind a
    // surface that is gone.
    _queue?.dismiss();
    super.dispose();
  }

  SeatLayerPickerStrings get _strings =>
      SeatLayerPickerScope.stringsOf(context);

  void _onQueue() {
    if (mounted) setState(() {});
  }

  void _onControllerChanged() {
    if (mounted) _syncState();
  }

  void _syncState() {
    final controller = _controller;
    if (controller == null) return;
    final closed = controller.state.event?.salesClosed;
    if (closed == true && _wasSalesClosed == false) {
      _say(
        SeatLayerPickerToast(
          _strings.salesClosedToast,
          tone: SeatLayerPickerToastTone.warning,
        ),
      );
    }
    _wasSalesClosed = closed;

    final lapse = controller.holdLapse;
    if (lapse == null) {
      _toldAboutLapse = null;
      return;
    }
    // Identity, not equality: a second lapse covering the same seats is a
    // second thing that happened to this buyer.
    if (identical(_toldAboutLapse, lapse)) return;
    _toldAboutLapse = lapse;
    _say(lapseToastFor(_strings, lapse, controller));
  }

  void _onConflict(SelectedObjectUnavailableEvent event) {
    final strings = _strings;
    final labels = event.labels;
    _say(
      SeatLayerPickerToast(
        labels.length == 1
            ? strings.seatJustTakenByAnother(labels.single)
            : strings.seatsJustTaken,
        tone: SeatLayerPickerToastTone.error,
      ),
    );
  }

  void _say(SeatLayerPickerToast toast) => _queue?.show(toast);

  @override
  Widget build(BuildContext context) {
    final toast = _queue?.current;
    final motion = SeatLayerPickerMotion.of(
      context,
      SeatLayerPickerMotion.enter,
    );
    return IgnorePointer(
      // The band never eats a tap; the action button inside it re-enables
      // itself, so a toast can be acted on without the map going deaf.
      ignoring: toast?.hasAction != true,
      child: Padding(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: widget.bottomInset +
              14 +
              (widget.lifted ? SeatLayerPickerToastLayer.cardLift : 0),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: motion,
            switchInCurve: SeatLayerPickerMotion.easeEnter,
            switchOutCurve: SeatLayerPickerMotion.easeExit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .12),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: toast == null
                ? const SizedBox.shrink()
                : _NudgedToast(
                    key: ValueKey<String>('${toast.tone}:${toast.message}'),
                    toast: toast,
                  ),
          ),
        ),
      ),
    );
  }
}

/// An error toast shakes once as it lands, and nothing else does.
///
/// The shake is the difference between "here is some news" and "the thing you
/// just did did not happen", said without a second colour or a second shape.
class _NudgedToast extends StatefulWidget {
  const _NudgedToast({super.key, required this.toast});

  final SeatLayerPickerToast toast;

  @override
  State<_NudgedToast> createState() => _NudgedToastState();
}

class _NudgedToastState extends State<_NudgedToast>
    with SingleTickerProviderStateMixin {
  /// Null for every tone but error: a toast that does not shake never builds
  /// the machinery to, and never has to take it down again.
  AnimationController? _nudge;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.toast.tone != SeatLayerPickerToastTone.error) return;
    if (SeatLayerPickerMotion.reduced(context)) return;
    if (_nudge != null) return;
    _nudge = AnimationController(
      vsync: this,
      // The one overshoot budget the system already names, spent on a shake
      // rather than on an arrival.
      duration: SeatLayerPickerMotion.cardEnter,
    )..forward();
  }

  @override
  void dispose() {
    _nudge?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Semantics(
      liveRegion: true,
      container: true,
      child: SeatLayerPickerToastCard(toast: widget.toast),
    );
    final nudge = _nudge;
    if (nudge == null) return card;
    return AnimatedBuilder(
      animation: nudge,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeOffset(nudge.value), 0),
        child: child,
      ),
      child: card,
    );
  }

  /// Three decaying swings, ending exactly where it started.
  static double _shakeOffset(double t) {
    if (t == 0 || t == 1) return 0;
    return 5 * (1 - t) * math.sin(t * math.pi * 6);
  }
}

/// The sentence and the offer for one lapse.
///
/// Which of the three tellings applies is a fact about the refresh that found
/// the lapse, never about what the buyer had before they left: a seat the
/// buyer never noticed leaving may be back, and one they were sure of may be
/// gone.
SeatLayerPickerToast lapseToastFor(
  SeatLayerPickerStrings strings,
  SeatLayerHoldLapse lapse,
  SeatLayerPickerController controller,
) {
  final recoverable = lapse.recoverableLabels.length;
  void reselect() =>
      ignorePickerAction(controller.reselectLapsedSeats().then((_) {}));
  return switch (lapse.recovery) {
    SeatLayerRecovery.all => SeatLayerPickerToast(
        strings.holdLapsedStillFree(recoverable),
        tone: SeatLayerPickerToastTone.warning,
        actionLabel: strings.reselectSeats(recoverable),
        onAction: reselect,
      ),
    SeatLayerRecovery.partial => SeatLayerPickerToast(
        strings.holdLapsedSomeTaken(
          lapse.lapsedLabels.length - recoverable,
        ),
        tone: SeatLayerPickerToastTone.warning,
        actionLabel: strings.reselectSeats(recoverable),
        onAction: reselect,
      ),
    SeatLayerRecovery.none => SeatLayerPickerToast(
        strings.holdLapsedAllTaken(lapse.lapsedLabels.length),
        tone: SeatLayerPickerToastTone.error,
      ),
  };
}
