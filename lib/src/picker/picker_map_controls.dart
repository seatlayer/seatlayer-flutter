import 'package:flutter/material.dart';

import '../open_enums.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'seat_layer_picker_components.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// The controls that sit on the map itself.
///
/// On a phone they go to the corners — accessibility bottom-left, fit-to-screen
/// bottom-right, Map/3D top-right — because a vertical stack of six circles at
/// one edge is a toolbar drawn over the venue the buyer is trying to read. The
/// zoom pair is absent by default: pinch already does it, better.
///
/// The wide layout keeps the vertical rail, where there is room for it.
class SeatLayerPickerMapControls extends StatelessWidget {
  /// Creates the map controls for the current layout.
  const SeatLayerPickerMapControls({
    super.key,
    this.compact = false,
    this.edgeInset = 10,
    this.bottomInset = 0,
  });

  /// Whether to render the phone's corner placement.
  final bool compact;

  /// Distance from each screen edge.
  final double edgeInset;

  /// Extra space to leave at the bottom, so controls ride above the dock bar.
  final double bottomInset;

  @override
  Widget build(BuildContext context) =>
      compact ? _CornerControls(this) : _RailControls(this);
}

class _RailControls extends StatelessWidget {
  const _RailControls(this.owner);

  final SeatLayerPickerMapControls owner;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final options = SeatLayerPickerScope.optionsOf(context);
    final chrome = options.chrome;
    final map = state.snapshot?.map;
    return AnimatedSize(
      duration: SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.pop),
      curve: SeatLayerPickerMotion.easeEnter,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (chrome.overviewControlFor(phone: false) &&
              map?.focusedSection != null)
            const SeatLayerPickerOverviewButton(),
          if (chrome.zoomControlsFor(phone: false)) ...<Widget>[
            const SeatLayerPickerZoomInButton(),
            const SeatLayerPickerZoomOutButton(),
          ],
          if (chrome.showZoomToFitControl)
            const SeatLayerPickerZoomToFitButton(),
          if (chrome.showViewModeControl &&
              options.enable3D &&
              state.snapshot?.capabilities.contains('venue3d') == true)
            const SeatLayerPickerViewModeButton(),
          if (map?.isVenue3D == true)
            const SeatLayerPicker3DNavigationModeButton(),
          if (chrome.colorblindControlFor(phone: false))
            const SeatLayerPickerColorblindButton(),
        ]
            .map(
              (control) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: control,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _CornerControls extends StatelessWidget {
  const _CornerControls(this.owner);

  final SeatLayerPickerMapControls owner;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final options = SeatLayerPickerScope.optionsOf(context);
    final chrome = options.chrome;
    final inset = owner.edgeInset;
    final bottom = inset + owner.bottomInset;
    final has3D = chrome.showViewModeControl &&
        options.enable3D &&
        state.snapshot?.capabilities.contains('venue3d') == true;
    return Stack(
      children: <Widget>[
        if (has3D)
          Positioned(
            top: inset,
            right: inset,
            child: const SeatLayerPickerViewModeControl(),
          ),
        if (chrome.showAccessibilityControl)
          Positioned(
            left: inset,
            bottom: bottom,
            child: const SeatLayerPickerAccessibilityFilters(compact: true),
          ),
        if (chrome.showZoomToFitControl)
          Positioned(
            right: inset,
            bottom: bottom,
            child: const SeatLayerPickerZoomToFitButton(),
          ),
        if (chrome.zoomControlsFor(phone: true))
          Positioned(
            right: inset,
            bottom: bottom + 42,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SeatLayerPickerZoomInButton(),
                SizedBox(height: 6),
                SeatLayerPickerZoomOutButton(),
              ],
            ),
          ),
        if (chrome.overviewControlFor(phone: true) &&
            state.snapshot?.map.focusedSection != null)
          Positioned(
            left: inset,
            top: inset,
            child: const SeatLayerPickerOverviewButton(),
          ),
        if (chrome.colorblindControlFor(phone: true))
          Positioned(
            left: inset,
            bottom: bottom + 52,
            child: const SeatLayerPickerColorblindButton(),
          ),
      ],
    );
  }
}

/// Map or 3D, as one segmented control.
///
/// Two labelled halves say what the other state is; a single icon button only
/// says that something will change.
class SeatLayerPickerViewModeControl extends StatelessWidget {
  /// Creates the Map / 3D segmented control.
  const SeatLayerPickerViewModeControl({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    if (state.snapshot?.capabilities.contains('venue3d') != true) {
      return const SizedBox.shrink();
    }
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final is3D = state.snapshot?.map.isVenue3D ?? false;
    return Material(
      color: pickerAlpha(theme.surface, .94),
      shape: StadiumBorder(side: BorderSide(color: theme.divider)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Segment(
            label: strings.mapView,
            selected: !is3D,
            onPressed: state.isBusy || !is3D
                ? null
                : () => ignorePickerAction(
                      controller.setBuyerView(SeatLayerBuyerView.map),
                    ),
          ),
          _Segment(
            label: strings.venue3D,
            selected: is3D,
            onPressed: state.isBusy || is3D
                ? null
                : () => ignorePickerAction(
                      controller.setBuyerView(SeatLayerBuyerView.venue3D),
                    ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? theme.accent : const Color(0x00000000),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32, minWidth: 46),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? theme.onAccent : theme.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFamily: theme.fontFamily,
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

/// A standalone back-to-venue control for custom picker compositions.
class SeatLayerPickerOverviewButton extends StatelessWidget {
  /// Creates the back-to-venue control.
  const SeatLayerPickerOverviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    return _ControlButton(
      icon: Icons.arrow_back_rounded,
      tooltip: SeatLayerPickerScope.stringsOf(context).backToVenue,
      onPressed: controller.overview,
    );
  }
}

/// A standalone zoom-in control for custom picker compositions.
class SeatLayerPickerZoomInButton extends StatelessWidget {
  /// Creates the zoom-in control.
  const SeatLayerPickerZoomInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final map = controller.state.snapshot?.map;
    return _ControlButton(
      icon: Icons.add_rounded,
      tooltip: 'Zoom in',
      onPressed: map?.canZoomIn == false ? null : controller.zoomIn,
    );
  }
}

/// A standalone zoom-out control for custom picker compositions.
class SeatLayerPickerZoomOutButton extends StatelessWidget {
  /// Creates the zoom-out control.
  const SeatLayerPickerZoomOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final map = controller.state.snapshot?.map;
    return _ControlButton(
      icon: Icons.remove_rounded,
      tooltip: 'Zoom out',
      onPressed: map?.canZoomOut == false ? null : controller.zoomOut,
    );
  }
}

/// A standalone fit-to-venue control for custom picker compositions.
class SeatLayerPickerZoomToFitButton extends StatelessWidget {
  /// Creates the fit-to-venue control.
  const SeatLayerPickerZoomToFitButton({super.key});

  @override
  Widget build(BuildContext context) => _ControlButton(
        icon: Icons.center_focus_strong_rounded,
        tooltip: SeatLayerPickerScope.stringsOf(context).fitVenue,
        onPressed: SeatLayerPickerScope.controllerOf(context).zoomToFit,
      );
}

/// A standalone Map / real venue-3D toggle for custom picker compositions.
///
/// This drives the same lazy WebGL venue scene and gesture system as the web
/// picker; it is not a canvas projection change.
class SeatLayerPickerViewModeButton extends StatelessWidget {
  /// Creates the Map / 3D toggle.
  const SeatLayerPickerViewModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final is3D = controller.state.snapshot?.map.isVenue3D ?? false;
    final available =
        controller.state.snapshot?.capabilities.contains('venue3d') == true;
    if (!available) return const SizedBox.shrink();
    return _ControlButton(
      icon: is3D ? Icons.map_outlined : Icons.view_in_ar_rounded,
      tooltip: is3D ? 'Back to seat map' : 'Open interactive 3D venue',
      active: is3D,
      onPressed: controller.state.isBusy
          ? null
          : () => controller.setBuyerView(
                is3D ? SeatLayerBuyerView.map : SeatLayerBuyerView.venue3D,
              ),
    );
  }
}

/// Rotate / Move toggle for the active real venue-3D camera.
///
/// Pinch-to-zoom and two-finger movement remain available in both modes; this
/// explicit control makes the primary one-finger gesture discoverable.
class SeatLayerPicker3DNavigationModeButton extends StatelessWidget {
  /// Creates the 3D navigation-mode toggle.
  const SeatLayerPicker3DNavigationModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final map = controller.state.snapshot?.map;
    if (map?.isVenue3D != true) return const SizedBox.shrink();
    final moving = map!.view3DNavigationMode == SeatLayer3DNavigationMode.move;
    return _ControlButton(
      icon: moving ? Icons.open_with_rounded : Icons.threesixty_rounded,
      tooltip: moving ? 'Drag to move venue' : 'Drag to rotate venue',
      active: true,
      onPressed: controller.state.isBusy
          ? null
          : () => controller.set3DNavigationMode(
                moving
                    ? SeatLayer3DNavigationMode.rotate
                    : SeatLayer3DNavigationMode.move,
              ),
    );
  }
}

/// A standalone colorblind-safe map toggle for custom picker compositions.
///
/// On the phone this lives inside the accessibility sheet rather than on the
/// map, which is where a buyer who needs it goes looking.
class SeatLayerPickerColorblindButton extends StatelessWidget {
  /// Creates the colourblind-safe toggle.
  const SeatLayerPickerColorblindButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final active = controller.state.snapshot?.map.colorblindSafe ?? false;
    return _ControlButton(
      icon: Icons.visibility_rounded,
      tooltip: 'Colorblind-safe colors',
      active: active,
      onPressed: () => controller.setColorblindSafe(!active),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function()? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final size = theme.layout.mapControlSize;
    return AnimatedContainer(
      duration: SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.pop),
      curve: SeatLayerPickerMotion.easeEnter,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Color.alphaBlend(pickerAlpha(theme.accent, .13), theme.surface)
            : pickerAlpha(theme.surface, .94),
        border: Border.all(
          color: active ? pickerAlpha(theme.accent, .52) : theme.divider,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          padding: EdgeInsets.zero,
          onPressed:
              onPressed == null ? null : () => ignorePickerAction(onPressed!()),
          icon: Icon(
            icon,
            size: 20,
            color: active ? theme.accent : theme.text,
          ),
        ),
      ),
    );
  }
}
