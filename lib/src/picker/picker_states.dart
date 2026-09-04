/// The states the picker has to be able to show instead of a seat map.
///
/// Sales that have ended, an event with nothing left, a buyer session the
/// server will no longer answer for, a hold about to run out, and the moment
/// the tickets are actually theirs. Each is a designed statement rather than a
/// screen full of disabled controls: a buyer who cannot do something should be
/// told what is true, once, in the picker's own voice.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'picker_header.dart';
import 'picker_internal.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'picker_strings.dart';
import 'picker_toast.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

/// Below this much time left, the buyer is offered more of it.
const Duration seatLayerHoldExtendThreshold = Duration(minutes: 1);

/// Whether this event has nothing seated left to sell.
///
/// Every category that is for sale reports zero free, there is at least one
/// such category, and the chart has no standing areas — a venue whose stalls
/// are gone but whose floor is not is not sold out, it is nearly sold out, and
/// saying otherwise sends a buyer away from tickets that exist.
bool seatLayerPickerIsSoldOut(SeatLayerPickerState state) {
  final snapshot = state.snapshot;
  if (snapshot == null) return false;
  if (snapshot.generalAdmissionAreas.isNotEmpty) return false;
  final seated = snapshot.categories
      .where((category) => !category.notForSale)
      .toList(growable: false);
  if (seated.isEmpty) return false;
  return seated.every((category) => category.available <= 0);
}

/// "Sales are closed", said once, where the tickets would have been.
///
/// Neutral by design: an accent-coloured panel reads as something to act on,
/// and there is nothing here to act on.
class SeatLayerPickerSalesClosedStatement extends StatelessWidget {
  /// Creates the statement.
  const SeatLayerPickerSalesClosedStatement({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (state.event?.salesClosed != true) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final when = state.event?.venue;
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(pickerAlpha(theme.text, .05), theme.surface),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.divider),
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            strings.salesClosed,
            style: TextStyle(
              color: theme.text,
              fontSize: 13,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.salesClosedCopy,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 11.5,
              height: 1.45,
              fontFamily: theme.fontFamily,
            ),
          ),
          if (when != null && when.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                when,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 11.5,
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Nothing seated is left. Informational — the picker offers no waitlist.
class SeatLayerPickerSoldOutOverlay extends StatelessWidget {
  /// Creates the sold-out overlay.
  const SeatLayerPickerSoldOutOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (!state.isReady || !seatLayerPickerIsSoldOut(state)) {
      return const SizedBox.shrink();
    }
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final eyebrow = (state.branding?.brandName ??
            state.event?.name ??
            strings.soldOutEyebrow)
        .toUpperCase();
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: pickerAlpha(theme.background, .82),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  eyebrow,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    fontFamily: theme.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.soldOutTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    fontFamily: theme.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Text(
                    strings.soldOutCopy,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the picker says when the buyer's access to these seats has lapsed.
///
/// Four different things are true behind one HTTP failure, and the buyer can
/// only act on two of them, so only those two carry a button. The copy names
/// which one happened rather than asking the buyer to guess.
class SeatLayerPickerAccessPanel extends StatefulWidget {
  /// Creates the access panel.
  const SeatLayerPickerAccessPanel({super.key});

  @override
  State<SeatLayerPickerAccessPanel> createState() =>
      _SeatLayerPickerAccessPanelState();
}

/// One reason's title, sentence, and the action that would help, if any.
@immutable
class SeatLayerAccessTelling {
  /// Creates a telling.
  const SeatLayerAccessTelling({
    required this.title,
    required this.body,
    this.action,
  });

  /// What happened.
  final String title;

  /// What it means for the buyer.
  final String body;

  /// The label of the one thing worth trying, or null when nothing is.
  final String? action;
}

/// The telling for [reason], falling back to the unverified wording.
SeatLayerAccessTelling seatLayerAccessTelling(
  SeatLayerPickerStrings strings,
  String? reason,
) =>
    switch (reason) {
      'paused' => SeatLayerAccessTelling(
          title: strings.accessPausedTitle,
          body: strings.accessPausedCopy,
          action: strings.retry,
        ),
      'revoked' => SeatLayerAccessTelling(
          title: strings.accessRevokedTitle,
          body: strings.accessRevokedCopy,
        ),
      'no_token' || 'provider_failed' => SeatLayerAccessTelling(
          title: strings.accessExpiredTitle,
          body: strings.accessExpiredCopy,
          action: strings.reloadSeatMap,
        ),
      _ => SeatLayerAccessTelling(
          title: strings.accessUnverifiedTitle,
          body: strings.accessUnverifiedCopy,
        ),
    };

class _SeatLayerPickerAccessPanelState
    extends State<SeatLayerPickerAccessPanel> {
  bool _retrying = false;

  Future<void> _retry(SeatLayerPickerController controller) async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      await controller.retry();
    } catch (_) {
      // The panel is what a failed retry lands back on, so there is nothing
      // to route the failure to: it is already the screen saying so.
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    if (state.phase != SeatLayerPickerPhase.unavailable) {
      return const SizedBox.shrink();
    }
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final telling = seatLayerAccessTelling(
      strings,
      state.snapshot?.accessReason,
    );
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: pickerAlpha(theme.background, .9),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(theme.radius),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: pickerAlpha(const Color(0xFF000000), .66),
                      blurRadius: 64,
                      spreadRadius: -24,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                child: Material(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(theme.radius),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(theme.radius),
                      border: Border.all(color: theme.divider),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _AccessIcon(theme: theme, spinning: _retrying),
                        const SizedBox(height: 16),
                        Text(
                          telling.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 18,
                            height: 1.25,
                            letterSpacing: -.27,
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w800),
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          telling.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 13,
                            height: 1.55,
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                        if (telling.action != null) ...<Widget>[
                          const SizedBox(height: 18),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.accent,
                              foregroundColor: theme.onAccent,
                              minimumSize: const Size(
                                0,
                                SeatLayerSizeTokens.minimumHitTarget,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              shape: const StadiumBorder(),
                            ),
                            onPressed:
                                _retrying ? null : () => _retry(controller),
                            child: Text(
                              telling.action!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: seatLayerBoldWeight(
                                    context, FontWeight.w800),
                                fontFamily: theme.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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

/// The panel's one glyph, turning while a retry is in flight.
class _AccessIcon extends StatefulWidget {
  const _AccessIcon({required this.theme, required this.spinning});

  final SeatLayerResolvedPickerTheme theme;
  final bool spinning;

  @override
  State<_AccessIcon> createState() => _AccessIconState();
}

class _AccessIconState extends State<_AccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );

  @override
  void didUpdateWidget(_AccessIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    // Progress the buyer asked for is not decoration: a retry that shows
    // nothing is a button that looks broken. It still stops turning for a
    // viewer who asked for less movement, who gets the disabled button.
    if (widget.spinning && !SeatLayerPickerMotion.reduced(context)) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(pickerAlpha(theme.accent, .16), theme.surface),
        border: Border.all(
          color:
              Color.alphaBlend(pickerAlpha(theme.accent, .42), theme.divider),
        ),
      ),
      child: SizedBox.square(
        dimension: 52,
        child: RotationTransition(
          turns: _spin,
          child: Icon(Icons.refresh_rounded, size: 28, color: theme.accent),
        ),
      ),
    );
  }
}

/// "Your seats are held for 0:48. Need more time?"
///
/// Offered only in the last minute, and only while there is a hold to extend:
/// asked earlier it is a question about a problem the buyer does not have yet.
class SeatLayerPickerExtendHoldPrompt extends StatefulWidget {
  /// Creates the extend prompt.
  const SeatLayerPickerExtendHoldPrompt({super.key});

  @override
  State<SeatLayerPickerExtendHoldPrompt> createState() =>
      _SeatLayerPickerExtendHoldPromptState();
}

class _SeatLayerPickerExtendHoldPromptState
    extends State<SeatLayerPickerExtendHoldPrompt> {
  Timer? _tick;
  bool _adding = false;

  /// Has this hold's one extension been spent, or the offer waved away?
  ///
  /// ONE PER HOLD. The server would allow more, but a buyer who can keep
  /// asking has been handed a way to sit on inventory by reflex rather than by
  /// decision, and a countdown that can always be pushed back is not a
  /// deadline.
  ///
  /// Cleared when there is no hold, which is the only honest boundary
  /// available: snapshots deliberately never carry the hold id, so the gap
  /// between one hold ending and the next beginning is what says "new hold".
  /// A fresh selection after a lapse therefore gets its own extension rather
  /// than inheriting the last one's spent state.
  bool _spent = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _add(SeatLayerPickerController controller) async {
    if (_adding) return;
    setState(() => _adding = true);
    final toasts = seatLayerPickerToasts(controller);
    final strings = SeatLayerPickerScope.stringsOf(context);
    try {
      final extended = await controller.extendHold();
      // Either way the control retires for this hold: granted, the buyer has
      // had their step; refused, the server will not give another. A refusal
      // ends in SILENCE — a hold resumed from the host carries extensions this
      // picker never offered, and that is not a fault the buyer needs a
      // sentence about.
      if (mounted) setState(() => _spent = true);
      if (extended) {
        toasts.show(SeatLayerPickerToast(
          strings.moreTimeAdded,
          tone: SeatLayerPickerToastTone.success,
        ));
      }
    } catch (_) {
      // A transport failure is the one outcome worth a sentence, and the one
      // worth offering again: nothing was decided, so the control stays.
      toasts.show(SeatLayerPickerToast(
        strings.couldNotAddMoreTime,
        tone: SeatLayerPickerToastTone.warning,
      ));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final remaining = state.holdRemaining(seatLayerPickerNow());
    // No hold means the next one is a NEW hold, and a new hold gets its own
    // extension. Assigned rather than setState-ed: it only ever relaxes a gate
    // in the same frame that already has no control to draw, so it cannot miss
    // a repaint, and setState during build would be an error.
    if (state.hold == null) _spent = false;
    final due = state.hold != null &&
        state.checkoutHandoff == null &&
        // Spent or waved away for THIS hold. A control that cannot work should
        // not be visible, and its absence needs no announcement.
        !_spent &&
        remaining > Duration.zero &&
        remaining <= seatLayerHoldExtendThreshold;
    if (!due) return const SizedBox.shrink();
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: pickerAlpha(const Color(0xFF000000), .6),
              blurRadius: 50,
              spreadRadius: -18,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Material(
          color: theme.surface,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.divider),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    strings.seatsHeldForNeedMoreTime('$minutes:$seconds'),
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w600),
                      fontFamily: theme.fontFamily,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: theme.onAccent,
                    minimumSize: const Size(
                      0,
                      SeatLayerSizeTokens.minimumHitTarget,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: _adding ? null : () => _add(controller),
                  // The button says exactly what one tap does. "Add time"
                  // beside a countdown reads like an invitation to choose an
                  // amount, and there is nothing to choose.
                  child: Text(
                    _adding
                        ? strings.addingEllipsis
                        : strings.addMinutes(
                            seatLayerHoldExtendStep.inMinutes,
                          ),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
                // A way to say no. Offered in the last minute over the map,
                // an offer with no refusal is a thing in the way.
                const SizedBox(width: 2),
                IconButton(
                  tooltip: strings.close,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: SeatLayerSizeTokens.minimumHitTarget,
                    height: SeatLayerSizeTokens.minimumHitTarget,
                  ),
                  onPressed: _adding
                      ? null
                      : () => setState(() => _spent = true),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: theme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The moment the tickets are the buyer's.
///
/// Shown only once the handed-off hold has settled to booked — never on the
/// hand-off itself, which is a buyer on their way to pay, not a buyer who has
/// paid. A host that pops the picker route on a sale has already told the
/// buyer, and a second telling behind a dead route would be a screen nobody
/// asked for. `Back to map` takes the overlay away without
/// touching the hold, because the seats are booked either way.
class SeatLayerPickerBookedOverlay extends StatefulWidget {
  /// Creates the booked overlay.
  const SeatLayerPickerBookedOverlay({super.key});

  @override
  State<SeatLayerPickerBookedOverlay> createState() =>
      _SeatLayerPickerBookedOverlayState();
}

class _SeatLayerPickerBookedOverlayState
    extends State<SeatLayerPickerBookedOverlay> {
  /// The hold whose confirmation the buyer has already dismissed.
  String? _dismissed;

  @override
  Widget build(BuildContext context) {
    if (!SeatLayerPickerScope.optionsOf(context).showBookedOverlay) {
      return const SizedBox.shrink();
    }
    final handoff = SeatLayerPickerScope.controllerOf(context).bookedHandoff;
    if (handoff == null) return const SizedBox.shrink();
    if (_dismissed == handoff.holdId) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final tickets = handoff.lineItems.fold<int>(
      0,
      (total, line) => total + line.quantity,
    );
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: theme.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _BookedBadge(theme: theme),
                const SizedBox(height: 12),
                Text(
                  strings.allSetTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 19,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    fontFamily: theme.fontFamily,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    '${strings.ticketCount(tickets)} '
                    '${strings.confirmedAndOnWay}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
                if (handoff.lineItems.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _BookedSeatList(handoff: handoff, theme: theme),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.text,
                    backgroundColor: theme.surface,
                    side: BorderSide(color: theme.divider),
                    minimumSize: const Size(
                      0,
                      SeatLayerSizeTokens.minimumHitTarget,
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => setState(() => _dismissed = handoff.holdId),
                  icon: const Icon(Icons.chevron_left_rounded, size: 18),
                  label: Text(
                    strings.backToMap,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The one tick, drawn rather than popped: the badge lands, then the mark.
class _BookedBadge extends StatelessWidget {
  const _BookedBadge({required this.theme});

  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.accent),
        child: SizedBox.square(
          dimension: 60,
          child: Icon(Icons.check_rounded, size: 30, color: theme.onAccent),
        ),
      );
}

/// What was booked, one pill per line, scrolling past four of them.
class _BookedSeatList extends StatelessWidget {
  const _BookedSeatList({required this.handoff, required this.theme});

  final SeatLayerCheckoutHandoff handoff;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 132),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final line in handoff.lineItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: pickerAlpha(theme.divider, .32),
                      borderRadius: BorderRadius.circular(
                        SeatLayerRadiusTokens.pill,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              line.displayLabel ?? line.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 12.5,
                                fontWeight: seatLayerBoldWeight(
                                    context, FontWeight.w600),
                                fontFamily: theme.fontFamily,
                              ),
                            ),
                          ),
                          if (line.quantity > 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                '×${line.quantity}',
                                style: TextStyle(
                                  color: theme.mutedText,
                                  fontSize: 12.5,
                                  fontWeight: seatLayerBoldWeight(
                                      context, FontWeight.w700),
                                  fontFamily: theme.fontFamily,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
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
      );
}

/// Every map-level state, in the order one may cover another.
///
/// Drop it into the map's [Stack] as a `Positioned.fill`. Each part renders
/// nothing when its own condition is false, so the layer is one line at the
/// composition rather than five conditionals.
class SeatLayerPickerStateLayer extends StatelessWidget {
  /// Creates the state layer.
  const SeatLayerPickerStateLayer({super.key, this.bottomInset = 0});

  /// What the chrome standing on the bottom of the map already covers.
  final double bottomInset;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          const Positioned.fill(child: SeatLayerPickerSoldOutOverlay()),
          Positioned(
            left: 14,
            right: 14,
            // Above the toast band, which is where the answer to pressing
            // `Add time` will arrive.
            bottom: bottomInset + 14 + 56,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: SeatLayerPickerExtendHoldPrompt(),
            ),
          ),
          const Positioned.fill(child: SeatLayerPickerAccessPanel()),
          const Positioned.fill(child: SeatLayerPickerBookedOverlay()),
        ],
      );
}
