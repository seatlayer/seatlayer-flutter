import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_map_controls.dart';
import 'picker_camera_actions.dart';
import 'picker_models.dart';
import 'picker_motion.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

/// How far the scene's chrome stands off the picture's edges.
const double _anchorInset = SeatLayerSizeTokens.mapAnchorInset;

/// The gap between two chips on the seat deck.
const double _chipGap = 6;

/// `.03em` of tracking, expressed in points against each size that carries it.
const double _backTracking = SeatLayerSizeTokens.immersiveBackFontSize * 0.03;
const double _captionTracking =
    SeatLayerSizeTokens.immersiveCaptionFontSize * 0.03;

/// The chrome drawn over the immersive venue scene.
///
/// The scene itself is the venue map; this is everything around it — where the
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

  /// Replaces the built-in return from a seat target to the 3D venue.
  final VoidCallback? onBackToVenue;

  /// Space to leave at the top, clear of the header.
  final double topInset;

  /// Space to leave at the bottom, clear of the cart sheet.
  final double bottomInset;

  /// How tall `‹ Back to venue` is.
  ///
  /// Published so a host stacking its own chrome under the scene's way back —
  /// the turnkey layout stacks the test-mode badge there — measures the same
  /// pill this widget draws instead of repeating a number.
  static const double backPillHeight =
      SeatLayerSizeTokens.immersiveBackPillHeight;

  /// How tall the caption chip naming the buyer's seat is.
  static const double captionChipHeight = 28;

  /// The gap between the caption chip and the control row below it.
  static const double captionGap = SeatLayerSizeTokens.mapAnchorGap;

  /// How tall the seat deck at the bottom of the scene is.
  ///
  /// The chips are always there; the caption chip only once the buyer is
  /// sitting in a seat, where it names the seat directly above the controls
  /// that move between them. Published so the layout can report the band this
  /// chrome stands on without repeating either number.
  static double seatDeckHeight({required bool seated}) =>
      (seated ? captionChipHeight + captionGap : 0) +
      SeatLayerSizeTokens.minimumHitTarget;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final map = state.snapshot?.map;
    final active =
        (map?.isVenue3D ?? false) && controller.seatView?.hasContent != true;
    final targeted = map?.view3DTargetSeatId != null;
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
                  if (targeted)
                    Positioned(
                      top: topInset,
                      left: _anchorInset,
                      child: _BackPill(
                        label: strings.backToVenue,
                        onPressed: state.isBusy
                            ? null
                            : onBackToVenue ??
                                () => ignorePickerAction(
                                      controller.setBuyerView(
                                        SeatLayerBuyerView.venue3D,
                                        resetView: true,
                                      ),
                                    ),
                      ),
                    ),
                  Positioned(
                    top: topInset,
                    right: _anchorInset,
                    child: const SeatLayerPicker3DNavigationModeButton(),
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
    final snapshot = state.snapshot!;
    final map = snapshot.map;
    final targetId = map.view3DTargetSeatId;
    final index =
        targetId == null ? -1 : seats.indexWhere((seat) => seat.id == targetId);
    final targeted = targetId != null;
    final previousSeatId = map.reportsView3DPosition
        ? map.view3DPreviousSeatId
        : index > 0
            ? seats[index - 1].id
            : null;
    final nextSeatId = map.reportsView3DPosition
        ? map.view3DNextSeatId
        : index >= 0 && index < seats.length - 1
            ? seats[index + 1].id
            : null;
    final busy = state.isBusy;
    final bundle = controller.mapController.bundleInfo;
    bool supports3DCommand(String command) =>
        bundle?.supportsCapability('venue-3d-controls-v1') == true &&
        bundle?.supportsCommand(command) == true;
    final seatViewAvailable = targeted &&
        snapshot.capabilities.contains('seatView') &&
        bundle?.supportsCapability('seat-view-v1') == true &&
        bundle?.supportsCommand('picker.openSeatView') == true;
    final controls = <Widget>[
      if (targeted) ...<Widget>[
        _ImmersiveIcon(
          theme: theme,
          icon: Icons.chevron_left_rounded,
          tooltip: strings.previousSeat,
          onPressed: previousSeatId == null || busy
              ? null
              : () => _sit(controller, previousSeatId),
        ),
        if (seatViewAvailable)
          _ImmersiveAction(
            theme: theme,
            icon: Icons.threesixty_rounded,
            label: strings.viewFromHere,
            onPressed: busy
                ? null
                : () => ignorePickerAction(
                      controller.openSeatViewById(targetId),
                    ),
          ),
        _ImmersiveIcon(
          theme: theme,
          icon: Icons.chevron_right_rounded,
          tooltip: strings.nextSeat,
          onPressed: nextSeatId == null || busy
              ? null
              : () => _sit(controller, nextSeatId),
        ),
        _ImmersiveIcon(
          theme: theme,
          icon: Icons.filter_center_focus_rounded,
          tooltip: strings.recentre,
          onPressed: busy
              ? null
              : () => ignorePickerAction(
                    controller.setBuyerView(
                      SeatLayerBuyerView.venue3D,
                      flyToSeatId: targetId,
                      resetView: true,
                    ),
                  ),
        ),
      ] else ...<Widget>[
        if (supports3DCommand('picker.zoomOut'))
          _ImmersiveIcon(
            theme: theme,
            icon: Icons.remove_rounded,
            tooltip: strings.zoomOut,
            onPressed:
                busy ? null : () => ignorePickerAction(controller.zoomOut()),
          ),
        if (supports3DCommand('picker.zoomToFit'))
          _ImmersiveAction(
            theme: theme,
            icon: Icons.fit_screen_rounded,
            label: strings.fitVenue,
            onPressed:
                busy ? null : () => ignorePickerAction(controller.zoomToFit()),
          ),
        if (supports3DCommand('picker.zoomIn'))
          _ImmersiveIcon(
            theme: theme,
            icon: Icons.add_rounded,
            tooltip: strings.zoomIn,
            onPressed:
                busy ? null : () => ignorePickerAction(controller.zoomIn()),
          ),
      ],
    ];

    if (controls.isEmpty) return const SizedBox.shrink();
    // Its own scroller, so a venue that grows another action never pushes one
    // off the edge of a 320-point phone; centred while they all fit.
    final row = SizedBox(
      height: SeatLayerSizeTokens.minimumHitTarget,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _anchorInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.max(0, constraints.maxWidth - _anchorInset * 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var index = 0;
                    index < controls.length;
                    index++) ...<Widget>[
                  if (index > 0) const SizedBox(width: _chipGap),
                  controls[index],
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (!targeted) return row;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SeatCaption(theme: theme),
        const SizedBox(height: SeatLayerVenue3D.captionGap),
        row,
      ],
    );
  }

  /// Move to the next seat without standing up.
  ///
  /// Retargeting the existing scene keeps the buyer seated; leaving 3D and
  /// re-entering would rebuild it and read as the map snapping back.
  void _sit(SeatLayerPickerController controller, String seatId) {
    ignorePickerAction(
      controller.setBuyerView(
        SeatLayerBuyerView.venue3D,
        flyToSeatId: seatId,
      ),
    );
  }

  /// The section, row and seat the scene is aimed at, in that order.
  static List<String> identityParts(
    SeatLayerPickerState state,
    SelectedSeat seat,
  ) {
    final row = pickerRowLabel(
      seat.rowLabel,
      seat.sectionLabel,
      sectionCode: pickerSectionCode(state, seat.sectionLabel),
    );
    return <String>[
      if (seat.sectionLabel?.trim().isNotEmpty ?? false)
        seat.sectionLabel!.trim(),
      if (row.isNotEmpty) 'Row $row',
      if (seat.seatNumber?.trim().isNotEmpty ?? false)
        'Seat ${seat.seatNumber!.trim()}',
    ];
  }
}

/// Where the buyer is sitting, printed under the way out.
class _SeatCaption extends StatelessWidget {
  const _SeatCaption({required this.theme});

  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final map = state.snapshot?.map;
    final targetId = map?.view3DTargetSeatId;
    if (map == null || targetId == null) return const SizedBox.shrink();
    final index = state.selection.indexWhere((seat) => seat.id == targetId);
    final target =
        map.view3DTargetSeat ?? (index >= 0 ? state.selection[index] : null);
    if (target == null) return const SizedBox.shrink();
    return Center(
      child: seatLayerImmersiveGlass(
        blur: SeatLayerSizeTokens.immersiveCaptionBlur,
        fill: SeatLayerDarkTokens.immersiveCaption,
        border: SeatLayerDarkTokens.immersiveCaptionBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            strings.seatIdentity(<String>[
              ..._SeatDeck.identityParts(state, target),
              strings.viewFromYourSeat,
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: SeatLayerDarkTokens.immersiveCaptionInk,
              fontSize: SeatLayerSizeTokens.immersiveCaptionFontSize,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
              letterSpacing: _captionTracking,
              fontFamily: theme.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}

/// `‹ Back to venue` — the only way out of an exact seat.
class _BackPill extends StatelessWidget {
  const _BackPill({required this.label, required this.onPressed});

  /// Carried only so the pill's accessible name is the drawn word.
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => seatLayerImmersiveGlass(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: SeatLayerVenue3D.backPillHeight,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 9, end: 13),
                child: _BackPillContents(label: label),
              ),
            ),
          ),
        ),
      );
}

/// Split out only so the pill's own padding can stay `const`.
class _BackPillContents extends StatelessWidget {
  const _BackPillContents({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.chevron_left_rounded,
          size: SeatLayerSizeTokens.immersiveBackIconSize,
          color: SeatLayerDarkTokens.immersiveGlassInk,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: SeatLayerDarkTokens.immersiveGlassInk,
            fontSize: SeatLayerSizeTokens.immersiveBackFontSize,
            fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
            letterSpacing: _backTracking,
          ),
        ),
      ],
    );
  }
}

/// A labelled chip on the seat deck.
class _ImmersiveAction extends StatelessWidget {
  const _ImmersiveAction({
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
  Widget build(BuildContext context) => seatLayerImmersiveGlass(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: SeatLayerSizeTokens.minimumHitTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SeatLayerSizeTokens.immersiveNavChipPaddingX,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      icon,
                      size: SeatLayerSizeTokens.immersiveBackIconSize,
                      color: SeatLayerDarkTokens.immersiveGlassInk,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: SeatLayerDarkTokens.immersiveGlassInk,
                        fontSize: SeatLayerSizeTokens.immersiveNavChipFontSize,
                        fontWeight:
                            seatLayerBoldWeight(context, FontWeight.w700),
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// A round chip on the seat deck: one glyph, no word.
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
  Widget build(BuildContext context) => seatLayerImmersiveGlass(
        circular: true,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: SeatLayerSizeTokens.minimumHitTarget,
            height: SeatLayerSizeTokens.minimumHitTarget,
          ),
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
          ),
          color: SeatLayerDarkTokens.immersiveGlassInk,
          disabledColor: pickerAlpha(SeatLayerDarkTokens.immersiveGlassInk, .6),
          icon: Icon(icon, size: SeatLayerSizeTokens.immersiveBackIconSize + 5),
        ),
      );
}
