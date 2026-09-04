import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../open_enums.dart';
import 'picker_camera_actions.dart';
import 'picker_internal.dart';
import 'picker_motion.dart';
import 'picker_accessibility.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

/// The dark glass every piece of 3D chrome is drawn on.
///
/// Deliberately theme-independent: this floats over a rendered venue, not over
/// the picker's own ground, and white chrome over a lit stage reads as a
/// mistake in either palette. One recipe — a near-black fill at 62 %, a
/// one-point white hairline at 22 %, and a six-point blur behind both — so the
/// back pill, the deck's chips and the caption cannot drift apart.
Widget seatLayerImmersiveGlass({
  required Widget child,
  double blur = SeatLayerSizeTokens.immersiveGlassBlur,
  Color fill = SeatLayerDarkTokens.immersiveGlass,
  Color border = SeatLayerDarkTokens.immersiveGlassBorder,
  bool circular = false,
  double? radius,
}) {
  final ShapeBorder shape = circular
      ? CircleBorder(side: BorderSide(color: border))
      : radius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(color: border),
            )
          : StadiumBorder(side: BorderSide(color: border));
  return ClipPath(
    clipper: ShapeBorderClipper(shape: shape),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: fill, shape: shape),
        child: child,
      ),
    ),
  );
}

/// The controls that sit on the map itself.
///
/// On a phone they go to the map's anchor regions — accessibility bottom-left,
/// Map/3D top-right, and one back-out control bottom-right. That control walks
/// the ladder a step at a time and dims once the whole venue is on screen,
/// rather than coming and going under the buyer's thumb. Fit-to-venue and
/// zoom-in are absent by default: fit made the same journey in one jump with
/// nothing to tell the two round buttons apart, and pinch already handles
/// continuous zoom without drawing a toolbar over the venue.
///
/// The wide layout keeps the vertical rail, where there is room for it.
class SeatLayerPickerMapControls extends StatelessWidget {
  /// Creates the map controls for the current layout.
  const SeatLayerPickerMapControls({
    super.key,
    this.compact = false,
    this.edgeInset = SeatLayerSizeTokens.mapAnchorInset,
    this.bottomInset = 0,
    this.includeViewModeControl = true,
  });

  /// Whether to render the phone's corner placement.
  final bool compact;

  /// Distance from each screen edge.
  final double edgeInset;

  /// Extra space to leave at the bottom, so controls ride above the dock bar.
  final double bottomInset;

  /// Whether the Map/3D control belongs to this stack.
  ///
  /// The turnkey phone layout draws the price legend and the Map/3D control as
  /// one top rail, so the two cannot land on top of each other whatever the
  /// translated labels measure. It therefore takes the control out of here and
  /// places it itself. A host composing its own layout keeps the default.
  final bool includeViewModeControl;

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
          if (chrome.zoomToFitControlFor(phone: false))
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
    final has3D = owner.includeViewModeControl &&
        chrome.showViewModeControl &&
        options.enable3D &&
        state.snapshot?.capabilities.contains('venue3d') == true;
    // While the immersive scene is up there is no flat map to fit, filter or
    // pan, and SeatLayerVenue3D owns that corner. Only the way back stays.
    final onMap = !(state.snapshot?.map.isVenue3D ?? false);
    final phoneZoomPair = chrome.zoomControlsFor(phone: true);
    // ONE control, one ladder. `−` walks back a step at a time — the section
    // the buyer drilled into, then the whole venue — and fit-to-screen did
    // the same journey in one jump, so the corner carried two round buttons
    // with nothing on either saying which was which. The phone keeps the
    // stepped one. Pinch is what zooms in, so `+` is never here unless the
    // host asks.
    //
    // DIMMED, NOT GONE. It used to appear only once the buyer was deep enough
    // to be lost, so the corner grew and shrank a button under their thumb. A
    // control that stays put and plainly cannot be pressed says "you are
    // already looking at everything" without moving the target.
    final zoomColumn = <Widget>[
      if (onMap && phoneZoomPair) const SeatLayerPickerZoomInButton(),
      if (onMap) const SeatLayerPickerZoomOutButton(),
      if (onMap && chrome.zoomToFitControlFor(phone: true))
        const SeatLayerPickerZoomToFitButton(),
    ];
    final bottomLeftColumn = <Widget>[
      if (onMap && chrome.colorblindControlFor(phone: true))
        const SeatLayerPickerColorblindButton(),
      // The round control, and — while a filter is on and the runtime answers
      // the tour — the stepper that walks the sections holding matching
      // spaces. Beside it rather than above it: they are one subject, and the
      // corner already stacks the colourblind control above both.
      if (onMap && chrome.showAccessibilityControl)
        const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SeatLayerPickerAccessibilityFilters(compact: true),
            SizedBox(width: SeatLayerSizeTokens.accessStepGap),
            SeatLayerPickerAccessibleStepper(),
          ],
        ),
    ];
    return Stack(
      children: <Widget>[
        if (has3D)
          Positioned(
            top: inset,
            right: inset,
            child: const SeatLayerPickerViewModeControl(),
          ),
        if (bottomLeftColumn.isNotEmpty)
          Positioned(
            left: inset,
            bottom: bottom,
            child: _AnchorColumn(
              gap: SeatLayerSizeTokens.mapAnchorGap,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bottomLeftColumn,
            ),
          ),
        if (zoomColumn.isNotEmpty)
          Positioned(
            right: inset,
            bottom: bottom,
            child: _AnchorColumn(
              gap: SeatLayerSizeTokens.zoomColumnGap,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: zoomColumn,
            ),
          ),
        // The back-to-overview control is a different question from the zoom
        // ladder: it only has an answer while a section is actually framed.
        if (onMap &&
            chrome.overviewControlFor(phone: true) &&
            state.snapshot?.map.focusedSection != null)
          Positioned(
            left: inset,
            top: inset,
            child: const SeatLayerPickerOverviewButton(),
          ),
      ],
    );
  }
}

/// One of the map's anchor regions: a column of controls with an even gap.
///
/// The regions are what stop a floating control from landing on top of
/// another one, so every stack of chrome goes through one rather than being
/// positioned against a number of its own.
class _AnchorColumn extends StatelessWidget {
  const _AnchorColumn({
    required this.gap,
    required this.crossAxisAlignment,
    required this.children,
  });

  final double gap;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          for (var index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0) SizedBox(height: gap),
            children[index],
          ],
        ],
      );
}

/// Map or 3D, as one segmented control.
///
/// Two labelled halves say what the other state is; a single icon button only
/// says that something will change.
class SeatLayerPickerViewModeControl extends StatelessWidget {
  /// Creates the Map / 3D segmented control.
  const SeatLayerPickerViewModeControl({super.key});

  /// How tall the control is; the segments are built to this.
  static const double height = SeatLayerSizeTokens.viewModeControlHeight;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    if (state.snapshot?.capabilities.contains('venue3d') != true) {
      return const SizedBox.shrink();
    }
    final theme = seatLayerMapChromeThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final is3D = state.snapshot?.map.isVenue3D ?? false;
    // A track with the two halves inside it: the pill the buyer is in is
    // filled, the one they can move to is quiet, and the plate under both says
    // the pair is one control rather than two buttons that happen to touch.
    return Semantics(
      container: true,
      label: strings.venueView,
      // A Container, not a DecoratedBox: the hairline is part of the track's
      // measured height, the way a border-box is on the web, so the pair
      // stands exactly as tall as the layout reserves for it.
      child: Container(
        decoration: BoxDecoration(
          // The track floats on the venue like the corner discs, so it takes
          // the same ground rather than the panel's.
          color: seatLayerMapChromeDisc(theme).ground,
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
          border: Border.all(color: seatLayerMapChromeDisc(theme).line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: pickerAlpha(const Color(0xFF000000), .65),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -16,
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Segment(
              label: strings.mapView,
              tooltip: strings.flat2dMap,
              selected: !is3D,
              onPressed: state.isBusy || !is3D
                  ? null
                  : () => ignorePickerAction(
                        controller.setBuyerView(SeatLayerBuyerView.map),
                      ),
            ),
            const SizedBox(width: 2),
            _Segment(
              label: strings.venue3D,
              tooltip: strings.interactive3dVenueView,
              selected: is3D,
              onPressed: state.isBusy || is3D
                  ? null
                  : () => ignorePickerAction(
                        controller.setBuyerView(SeatLayerBuyerView.venue3D),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerMapChromeThemeOf(context);
    return Semantics(
      button: true,
      selected: selected,
      tooltip: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: selected ? theme.accent : const Color(0x00000000),
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: SeatLayerSizeTokens.viewModeButtonHeight,
                minWidth: SeatLayerSizeTokens.viewModeButtonMinWidth,
              ),
              // Both factors, so a half is the size of its own label plus its
              // minimum — not whatever room the corner it is placed in has.
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? theme.onAccent : theme.mutedText,
                      fontSize: SeatLayerSizeTokens.viewModeLabelFontSize,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                      letterSpacing:
                          SeatLayerSizeTokens.viewModeLabelFontSize * .04,
                      fontFamily: theme.fontFamily,
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
      tooltip: SeatLayerPickerScope.stringsOf(context).zoomIn,
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
      tooltip: SeatLayerPickerScope.stringsOf(context).zoomOut,
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
    final bundle = controller.mapController.bundleInfo;
    if (bundle?.supportsCapability('venue-3d-controls-v1') != true ||
        bundle?.supportsCommand('picker.setVenue3DNavigationMode') != true) {
      return const SizedBox.shrink();
    }
    final moving = map!.view3DNavigationMode == SeatLayer3DNavigationMode.move;
    final strings = SeatLayerPickerScope.stringsOf(context);
    final onPressed = controller.state.isBusy
        ? null
        : () => ignorePickerAction(
              controller.set3DNavigationMode(
                moving
                    ? SeatLayer3DNavigationMode.rotate
                    : SeatLayer3DNavigationMode.move,
              ),
            );
    // This control only ever exists over the rendered venue, so it wears the
    // scene's glass rather than the picker's own surface.
    return seatLayerImmersiveGlass(
      circular: true,
      child: IconButton(
        tooltip: moving ? strings.moveVenue : strings.rotateVenue,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: SeatLayerSizeTokens.immersiveNavCloseSize,
          height: SeatLayerSizeTokens.immersiveNavCloseSize,
        ),
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        ),
        color: SeatLayerDarkTokens.immersiveGlassInk,
        disabledColor: pickerAlpha(SeatLayerDarkTokens.immersiveGlassInk, .6),
        icon: Icon(
          moving ? Icons.open_with_rounded : Icons.threesixty_rounded,
          size: SeatLayerSizeTokens.immersiveBackIconSize + 3,
        ),
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
    // The MAP's palette, not the panel's. These discs float on the venue, so
    // they darken with the immersive scene like the rest of the map chrome.
    final theme = seatLayerMapChromeThemeOf(context);
    final size = theme.layout.mapControlSize;
    // A ground of the disc's own, because the panel surface is not one. On
    // dark, a translucent panel surface over the venue measured 1.14:1 against
    // the map — a dark blob on dark. The two sides need different halves of
    // the fix, which is why this is two tokens and not a stronger opacity:
    // dark separates by the FILL (2.96:1), light by the EDGE (3.72:1 against
    // the disc, 3.17:1 against the map), since white is already as far from a
    // light map as a colour can get and still only 1.17:1 from it.
    final disc = seatLayerMapChromeDisc(theme);
    final chrome = disc.ground;
    final chromeLine = disc.line;
    return AnimatedContainer(
      duration: SeatLayerPickerMotion.of(context, SeatLayerPickerMotion.pop),
      curve: SeatLayerPickerMotion.easeEnter,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Color.alphaBlend(pickerAlpha(theme.accent, .13), chrome)
            : chrome,
        border: Border.all(
          color: active ? pickerAlpha(theme.accent, .52) : chromeLine,
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
