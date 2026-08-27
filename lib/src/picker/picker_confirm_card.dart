import 'dart:async';

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_styles.dart';
import 'picker_motion.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The phone's one-seat decision surface.
///
/// A buyer who has just tapped a seat is answering one question — this seat,
/// this price, yes or no — so the card carries the seat's identity, its price,
/// the two ways to look at it, and the two answers. The category name is
/// deliberately absent: the map is already painted in the category's colour and
/// the dot repeats it, so spelling it out costs a line to say what the section
/// name mostly said.
///
/// Everything comes from the scope, so this works standalone inside a
/// [SeatLayerPickerScope].
class SeatLayerConfirmCard extends StatefulWidget {
  /// Creates a confirm card for [seat], or for the latest selected seat.
  const SeatLayerConfirmCard({
    super.key,
    this.seat,
    this.onConfirm,
    this.onCancel,
    this.onViewFromSeat,
    this.onShow3D,
    this.showSeatView = true,
    this.show3D = true,
    this.style,
  });

  /// The seat being decided on; defaults to the most recent selection.
  final SelectedSeat? seat;

  /// Called after the buyer accepts the seat.
  final FutureOr<void> Function(SelectedSeat seat)? onConfirm;

  /// Called instead of removing the seat when the buyer cancels.
  final FutureOr<void> Function(SelectedSeat seat)? onCancel;

  /// Replaces the SDK's view-from-seat action.
  final FutureOr<void> Function(SelectedSeat seat)? onViewFromSeat;

  /// Replaces the SDK's venue-3D action.
  final FutureOr<void> Function(SelectedSeat seat)? onShow3D;

  /// Whether the capability-gated view-from-seat pill may be shown.
  final bool showSeatView;

  /// Whether the capability-gated 3D pill may be shown.
  final bool show3D;

  /// Overrides [SeatLayerPickerStyles.confirmCardStyle] for this card.
  final SeatLayerSurfaceStyle? style;

  @override
  State<SeatLayerConfirmCard> createState() => _SeatLayerConfirmCardState();
}

class _SeatLayerConfirmCardState extends State<SeatLayerConfirmCard> {
  String? _dismissedLabel;

  @override
  void didUpdateWidget(covariant SeatLayerConfirmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seat?.label != widget.seat?.label) _dismissedLabel = null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (SeatLayerPickerScope.optionsOf(context).readOnly) {
      return const SizedBox.shrink();
    }
    final selection = controller.state.selection;
    final seat = widget.seat ?? (selection.isEmpty ? null : selection.last);
    if (seat == null || seat.label == _dismissedLabel) {
      return const SizedBox.shrink();
    }

    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final layout = theme.layout;
    final options = SeatLayerPickerScope.optionsOf(context);
    final capabilities =
        controller.state.snapshot?.capabilities ?? const <String>{};
    final category = controller.state.categories
        .where((item) => item.key == seat.categoryKey)
        .firstOrNull;

    final seatView = widget.showSeatView &&
            options.enableSeatView &&
            capabilities.contains('seatView')
        ? widget.onViewFromSeat ?? controller.openSeatView
        : null;
    final venue3D =
        widget.show3D && options.enable3D && capabilities.contains('venue3d')
            ? widget.onShow3D ?? controller.showSeatIn3D
            : null;
    final hasStrip = seatView != null || venue3D != null;
    final cardStyle =
        (theme.styles.confirmCardStyle ?? const SeatLayerSurfaceStyle())
            .merge(widget.style);

    // The card sizes itself to its content and to the screen less one gutter
    // on each side; whoever places it decides where on the map it sits.
    return Align(
      alignment: Alignment.center,
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: layout.confirmCardGutter),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: layout.confirmCardMaxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: Material(
            key: const ValueKey<String>('seatlayer.confirm-card.surface'),
            color: cardStyle.color ?? theme.surface,
            elevation: cardStyle.elevation ?? 18,
            shadowColor: pickerAlpha(const Color(0xFF000000), .26),
            shape: cardStyle.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.radius + 4),
                  side: BorderSide(color: pickerAlpha(theme.divider, .9)),
                ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: layout.confirmIdentityHeight,
                  child: _IdentityRow(
                    seat: seat,
                    color: pickerColor(category?.color) ?? theme.accent,
                  ),
                ),
                if (hasStrip) ...[
                  SizedBox(
                    height: layout.confirmPhotoHeight,
                    child: _InspectionStrip(
                      seat: seat,
                      onViewFromSeat: seatView,
                      onShow3D: venue3D,
                      onInspected: _dismiss,
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else
                  const SizedBox(height: 5),
                SizedBox(
                  height: layout.confirmActionHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: _CardButton(
                          label: strings.cancel,
                          filled: false,
                          style: theme.styles.secondaryButtonStyle,
                          onPressed: controller.state.isBusy
                              ? null
                              : () => _cancel(controller, seat),
                        ),
                      ),
                      const SizedBox(width: 1),
                      Expanded(
                        child: _CardButton(
                          label: strings.select,
                          icon: Icons.check_rounded,
                          filled: true,
                          style: theme.styles.primaryButtonStyle,
                          onPressed: controller.state.isBusy
                              ? null
                              : () => _confirm(controller, seat),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dismiss(SelectedSeat seat) {
    if (mounted) setState(() => _dismissedLabel = seat.label);
  }

  Future<void> _confirm(
    SeatLayerPickerController controller,
    SelectedSeat seat,
  ) async {
    // The seat already joined the selection when it was tapped, and the
    // haptics policy has already spent its click on that. A second cue here
    // would buzz twice for one seat.
    final origin = _cardCentre();
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    try {
      await widget.onConfirm?.call(seat);
      callbacks.onSeatSelected?.call(seat);
      if (!mounted) return;
      _flyToPeek(origin);
      _dismiss(seat);
    } catch (_) {
      // The controller keeps the typed failure in picker state for native UI.
    }
  }

  Future<void> _cancel(
    SeatLayerPickerController controller,
    SelectedSeat seat,
  ) async {
    try {
      if (widget.onCancel != null) {
        await widget.onCancel!(seat);
      } else {
        await controller.removeObject(seat.label);
      }
      _dismiss(seat);
    } catch (_) {
      // The controller keeps the typed failure in picker state for native UI.
    }
  }

  Offset? _cardCentre() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  /// Send a small dot from the card to the peek bar.
  ///
  /// It says where the ticket went, which is the one thing a card that closes
  /// cannot say by closing. Skipped entirely under reduced motion — an
  /// indicator that appears and vanishes in the same frame is just a flicker.
  void _flyToPeek(Offset? from) {
    if (from == null || SeatLayerPickerMotion.reduced(context)) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final screen = MediaQuery.sizeOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final to = Offset(screen.width / 2, screen.height - 24);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingDot(
        from: from,
        to: to,
        color: theme.accent,
        onDone: entry.remove,
      ),
    );
    overlay.insert(entry);
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.seat, required this.color});

  final SelectedSeat seat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final row = pickerRowLabel(
      seat.rowLabel,
      seat.sectionLabel,
      sectionCode: pickerSectionCode(
        SeatLayerPickerScope.stateOf(context),
        seat.sectionLabel,
      ),
    );
    final parts = <String>[
      if (seat.sectionLabel?.trim().isNotEmpty ?? false)
        seat.sectionLabel!.trim(),
      if (row.isNotEmpty) '${_rowWord(seat)} $row',
      '${_seatWord(seat)} ${seat.seatNumber?.trim().isNotEmpty ?? false ? seat.seatNumber!.trim() : seat.buyerFacingLabel}',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 10),
          ),
          const SizedBox(width: 8),
          // The place ellipsizes; the row, the seat and the price never do —
          // a truncated seat number is a different seat.
          Flexible(
            child: Text(
              strings.seatIdentity(parts),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
          if (seat.price != null) ...[
            const SizedBox(width: 10),
            Text(
              pickerMoney(context, seat.price!, seat.currency ?? 'USD'),
              softWrap: false,
              style: TextStyle(
                color: theme.text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontFamily: theme.fontFamily,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _rowWord(SelectedSeat seat) {
    final authored = seat.displayType?.trim().isNotEmpty ?? false
        ? seat.displayType!.trim()
        : seat.rowType?.trim().isNotEmpty ?? false
            ? seat.rowType!.trim()
            : 'Row';
    return authored;
  }

  static String _seatWord(SelectedSeat seat) =>
      seat.objectType == ObjectType.booth ? 'Place' : 'Seat';
}

/// The photo strip, and the two ways to look at the seat that live on it.
///
/// The snapshot carries no seat-view image URL, so the strip renders the
/// neutral gradient in every case; the pills are what the buyer is actually
/// reaching for, and they are gated on the runtime's own capabilities.
class _InspectionStrip extends StatelessWidget {
  const _InspectionStrip({
    required this.seat,
    required this.onViewFromSeat,
    required this.onShow3D,
    required this.onInspected,
  });

  final SelectedSeat seat;
  final FutureOr<void> Function(SelectedSeat seat)? onViewFromSeat;
  final FutureOr<void> Function(SelectedSeat seat)? onShow3D;
  final ValueChanged<SelectedSeat> onInspected;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final busy = SeatLayerPickerScope.stateOf(context).isBusy;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(pickerAlpha(theme.accent, .22), theme.surface),
            Color.alphaBlend(pickerAlpha(theme.text, .12), theme.surface),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            if (onViewFromSeat != null)
              _StripPill(
                icon: Icons.visibility_outlined,
                label: strings.viewFromHere,
                onPressed:
                    busy ? null : () => _inspect(context, onViewFromSeat!),
              ),
            const Spacer(),
            if (onShow3D != null)
              _StripPill(
                icon: Icons.view_in_ar_rounded,
                label: strings.venue3D,
                onPressed: busy ? null : () => _inspect(context, onShow3D!),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _inspect(
    BuildContext context,
    FutureOr<void> Function(SelectedSeat seat) action,
  ) async {
    final callbacks = SeatLayerPickerScope.callbacksOf(context);
    try {
      await action(seat);
      // The card stays put until the runtime has actually mounted the
      // immersive surface: removing it first lets the tail of the same iOS
      // tap reach the WebView and select a seat underneath.
      callbacks.onSeatViewOpened?.call(seat);
      onInspected(seat);
    } catch (_) {
      // A controller-backed action already published a typed picker error.
    }
  }
}

class _StripPill extends StatelessWidget {
  const _StripPill({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final pill = theme.styles.pillStyle ?? const SeatLayerSurfaceStyle();
    return Material(
      color: pill.color ?? pickerAlpha(theme.surface, .92),
      elevation: pill.elevation ?? 0,
      shape: pill.shape ?? theme.styles.chipShape ?? const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: theme.text),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    this.icon,
    this.style,
  });

  final String label;
  final bool filled;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final disabled = onPressed == null;
    final background = filled
        ? theme.accent
        : Color.alphaBlend(pickerAlpha(theme.text, .04), theme.surface);
    final ink = filled ? theme.onAccent : theme.text;
    final styledGround = seatLayerStyleRole(
      style?.backgroundColor,
      disabled: disabled,
    );
    final styledInk =
        seatLayerStyleRole(style?.foregroundColor, disabled: disabled);
    return Material(
      color: styledGround ??
          (disabled
              ? Color.alphaBlend(
                  pickerAlpha(theme.mutedText, .16),
                  theme.surface,
                )
              : background),
      shape: seatLayerStyleRole(style?.shape),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: styledInk ?? ink),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: styledInk ??
                      (disabled ? pickerAlpha(theme.mutedText, .58) : ink),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                ).merge(seatLayerStyleRole(style?.textStyle)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyingDot extends StatefulWidget {
  const _FlyingDot({
    required this.from,
    required this.to,
    required this.color,
    required this.onDone,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final VoidCallback onDone;

  @override
  State<_FlyingDot> createState() => _FlyingDotState();
}

class _FlyingDotState extends State<_FlyingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SeatLayerPickerMotion.fly,
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
          final t = Curves.easeInOutCubic.transform(_controller.value);
          final position = Offset.lerp(widget.from, widget.to, t)!;
          return Positioned(
            left: position.dx - 6,
            top: position.dy - 6,
            child: IgnorePointer(
              child: Opacity(
                opacity: 1 - (t * t),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 12),
                ),
              ),
            ),
          );
        },
      );
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
