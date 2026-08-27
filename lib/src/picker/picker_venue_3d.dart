import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The chrome drawn over the immersive venue scene.
///
/// The scene itself is the WebView; this is everything around it — where the
/// buyer is sitting, how to move a seat either way, how to look at the whole
/// venue, and how to get back to the map. It adopts the dark palette whatever
/// the resolved theme mode is, because white chrome over a dark venue reads as
/// a mistake rather than as a choice.
///
/// Renders nothing until the snapshot says the scene is up, so it can be
/// placed unconditionally over the map.
class SeatLayerVenue3D extends StatelessWidget {
  /// Creates the immersive chrome.
  const SeatLayerVenue3D({
    super.key,
    this.onBackToVenue,
    this.topInset = 10,
    this.bottomInset = 10,
  });

  /// Replaces the built-in return to the seat map.
  final VoidCallback? onBackToVenue;

  /// Space to leave at the top, clear of the header.
  final double topInset;

  /// Space to leave at the bottom, clear of the cart sheet.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final map = state.snapshot?.map;
    final active = map?.isVenue3D ?? false;
    final theme = seatLayerPickerThemeOf(context).immersive;
    final strings = SeatLayerPickerScope.stringsOf(context);

    return IgnorePointer(
      ignoring: !active,
      child: AnimatedOpacity(
        duration: SeatLayerPickerMotion.of(
          context,
          SeatLayerPickerMotion.immersive,
        ),
        curve: SeatLayerPickerMotion.easeEnter,
        opacity: active ? 1 : 0,
        child: !active
            ? const SizedBox.expand()
            : Stack(
                children: <Widget>[
                  Positioned(
                    top: topInset,
                    left: 10,
                    child: _ImmersivePill(
                      theme: theme,
                      icon: Icons.chevron_left_rounded,
                      label: strings.backToVenue,
                      onPressed: state.isBusy
                          ? null
                          : onBackToVenue ??
                              () => ignorePickerAction(
                                    controller
                                        .setBuyerView(SeatLayerBuyerView.map),
                                  ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomInset,
                    child: _SeatDeck(theme: theme),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SeatDeck extends StatelessWidget {
  const _SeatDeck({required this.theme});

  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final seats = state.selection;
    final targetId = state.snapshot?.map.view3DTargetSeatId;
    final index =
        targetId == null ? -1 : seats.indexWhere((seat) => seat.id == targetId);
    final seated = index >= 0;
    final previous = seated && index > 0 ? seats[index - 1] : null;
    final next = seated && index < seats.length - 1 ? seats[index + 1] : null;
    final busy = state.isBusy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (seated)
          _CaptionChip(
            theme: theme,
            text: strings.seatIdentity(<String>[
              ...?_identityParts(seats[index]),
              strings.viewFromYourSeat,
            ]),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _ImmersiveIcon(
              theme: theme,
              icon: Icons.chevron_left_rounded,
              tooltip: strings.previousSeat,
              onPressed: previous == null || busy
                  ? null
                  : () => _sit(controller, previous),
            ),
            const SizedBox(width: 8),
            _ImmersivePill(
              theme: theme,
              icon: Icons.threesixty_rounded,
              label: strings.openVenue360,
              onPressed: busy
                  ? null
                  : () => ignorePickerAction(
                        controller.setBuyerView(
                          SeatLayerBuyerView.venue3D,
                          resetView: true,
                        ),
                      ),
            ),
            const SizedBox(width: 8),
            _ImmersiveIcon(
              theme: theme,
              icon: Icons.chevron_right_rounded,
              tooltip: strings.nextSeat,
              onPressed:
                  next == null || busy ? null : () => _sit(controller, next),
            ),
            const SizedBox(width: 8),
            _ImmersiveIcon(
              theme: theme,
              icon: Icons.filter_center_focus_rounded,
              tooltip: strings.recentre,
              onPressed: busy || !seated
                  ? null
                  : () => ignorePickerAction(
                        controller.setBuyerView(
                          SeatLayerBuyerView.venue3D,
                          flyToSeatId: seats[index].id,
                          resetView: true,
                        ),
                      ),
            ),
          ],
        ),
      ],
    );
  }

  /// Move to the next seat without standing up.
  ///
  /// Retargeting the existing scene keeps the buyer seated; leaving 3D and
  /// re-entering would rebuild it and read as the map snapping back.
  void _sit(SeatLayerPickerController controller, SelectedSeat seat) {
    ignorePickerAction(
      controller.setBuyerView(
        SeatLayerBuyerView.venue3D,
        flyToSeatId: seat.id,
      ),
    );
  }

  static List<String>? _identityParts(SelectedSeat seat) => <String>[
        if (seat.sectionLabel?.trim().isNotEmpty ?? false)
          seat.sectionLabel!.trim(),
        if (seat.rowLabel?.trim().isNotEmpty ?? false)
          'Row ${seat.rowLabel!.trim()}',
        if (seat.seatNumber?.trim().isNotEmpty ?? false)
          'Seat ${seat.seatNumber!.trim()}',
      ];
}

class _CaptionChip extends StatelessWidget {
  const _CaptionChip({required this.theme, required this.text});

  final SeatLayerResolvedPickerTheme theme;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: pickerAlpha(theme.surface, .88),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
        ),
      );
}

class _ImmersivePill extends StatelessWidget {
  const _ImmersivePill({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final SeatLayerResolvedPickerTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: pickerAlpha(theme.surface, .9),
        shape: StadiumBorder(side: BorderSide(color: theme.divider)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 16, color: theme.text),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _ImmersiveIcon extends StatelessWidget {
  const _ImmersiveIcon({
    required this.theme,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final SeatLayerResolvedPickerTheme theme;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: pickerAlpha(theme.surface, .9),
        shape: CircleBorder(side: BorderSide(color: theme.divider)),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          color: theme.text,
          disabledColor: pickerAlpha(theme.mutedText, .45),
          icon: Icon(icon, size: 20),
        ),
      );
}
