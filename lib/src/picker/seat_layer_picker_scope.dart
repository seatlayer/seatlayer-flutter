import 'dart:async';

import 'package:flutter/widgets.dart';

import '../seat_layer_configuration.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'picker_strings.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_theme.dart';

/// Shared picker state for a composed layout.
///
/// Every SeatLayer chrome widget reads its controller, configuration, options,
/// theme and resolved brightness from the nearest scope, so a host can place
/// one component by hand and keep the rest of the drop-in.
class SeatLayerPickerScope extends StatefulWidget {
  /// Creates a scope. Supply a [controller] to keep the session across route
  /// changes; otherwise the scope owns one for its own lifetime.
  const SeatLayerPickerScope({
    super.key,
    required this.configuration,
    required this.child,
    this.controller,
    this.options = const SeatLayerPickerOptions(),
    this.theme,
    this.themeMode = SeatLayerThemeMode.auto,
    this.callbacks = const SeatLayerPickerCallbacks(),
  });

  /// What event to load and how.
  final SeatLayerConfiguration configuration;

  /// The session driver, or null to let the scope own one.
  final SeatLayerPickerController? controller;

  /// Behaviour switches for the session and its chrome.
  final SeatLayerPickerOptions options;

  /// Explicit colours; these win over the resolved mode.
  final SeatLayerPickerThemeData? theme;

  /// Which side of the theme to paint, and what to tell the runtime.
  final SeatLayerThemeMode themeMode;

  /// Session lifecycle callbacks.
  final SeatLayerPickerCallbacks callbacks;

  /// The composition below this scope.
  final Widget child;

  /// The controller driving the picker above [context].
  static SeatLayerPickerController controllerOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.controller;
  }

  /// The most recent state of the picker above [context].
  static SeatLayerPickerState stateOf(BuildContext context) =>
      controllerOf(context).value;

  /// What event the picker above [context] loaded.
  static SeatLayerConfiguration configurationOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.configuration;
  }

  /// Behaviour switches for the picker above [context].
  static SeatLayerPickerOptions optionsOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.options;
  }

  /// The host's explicit theme, if it supplied one.
  static SeatLayerPickerThemeData? themeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.theme;
  }

  /// The requested theme mode of the picker above [context].
  static SeatLayerThemeMode themeModeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.themeMode;
  }

  /// The side [themeModeOf] resolved to, following the device under
  /// [SeatLayerThemeMode.auto].
  static Brightness brightnessOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.brightness;
  }

  /// Lifecycle callbacks registered on the picker above [context].
  static SeatLayerPickerCallbacks callbacksOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.callbacks;
  }

  /// Buyer-facing strings for the picker above [context].
  static SeatLayerPickerStrings stringsOf(BuildContext context) =>
      optionsOf(context).strings;

  /// Tell the map above [context] how much of it your chrome is covering.
  ///
  /// The runtime frames the venue against the whole map surface, so a rail, a
  /// dock or a sheet drawn over that surface covers part of what it just
  /// framed. Report those bands and the camera aims at the visible part
  /// instead; the map still draws and pans underneath, so nothing becomes
  /// unreachable.
  ///
  /// The drop-in layout does this for its own chrome. Call it from a composed
  /// layout whenever a piece of your chrome appears, disappears or changes
  /// height, and pass null on dispose to hand the whole surface back. Calls
  /// are coalesced per frame and repeats are dropped, so reporting from every
  /// layout pass is cheap. Runtimes that do not advertise the capability
  /// receive nothing and keep framing against the whole surface.
  static void setViewportInsets(
    BuildContext context,
    SeatLayerViewportInsets? insets,
  ) {
    final scope =
        context.getInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    unawaited(
      scope!.controller.setViewportInsets(insets).catchError((Object _) {}),
    );
  }

  @override
  State<SeatLayerPickerScope> createState() => _SeatLayerPickerScopeState();
}

class _SeatLayerPickerScopeState extends State<SeatLayerPickerScope> {
  late SeatLayerPickerController _controller;
  late bool _ownsController;
  Brightness? _announcedBrightness;

  @override
  void initState() {
    super.initState();
    _adopt(widget.controller);
  }

  void _adopt(SeatLayerPickerController? supplied) {
    _controller = supplied ?? SeatLayerPickerController();
    _ownsController = supplied == null;
    _controller.attach(
      configuration: widget.configuration,
      options: widget.options,
      callbacks: widget.callbacks,
    );
  }

  @override
  void didUpdateWidget(covariant SeatLayerPickerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.detach();
      if (_ownsController) _controller.dispose();
      _adopt(widget.controller);
      return;
    }
    if (oldWidget.configuration.event != widget.configuration.event) {
      if (!_ownsController) {
        throw StateError(
          'Changing picker events requires a new SeatLayerPickerController',
        );
      }
      _controller.detach();
      _controller.dispose();
      _adopt(null);
      return;
    }
    _controller.updateBinding(
      options: widget.options,
      callbacks: widget.callbacks,
    );
  }

  @override
  void dispose() {
    _controller.detach();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness =
        resolveSeatLayerThemeBrightness(context, widget.themeMode);
    _announceBrightness(brightness);
    return _SeatLayerPickerInherited(
      controller: _controller,
      configuration: widget.configuration,
      options: widget.options,
      theme: widget.theme,
      themeMode: widget.themeMode,
      brightness: brightness,
      callbacks: widget.callbacks,
      child: widget.child,
    );
  }

  void _announceBrightness(Brightness brightness) {
    if (_announcedBrightness == brightness) return;
    _announcedBrightness = brightness;
    final callback = widget.callbacks.onThemeResolved;
    if (callback == null) return;
    // The host is told after the frame that carries the change, so a listener
    // that calls setState does not rebuild the tree it is being told about.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback(brightness);
    });
  }
}

class _SeatLayerPickerInherited
    extends InheritedNotifier<SeatLayerPickerController> {
  const _SeatLayerPickerInherited({
    required this.controller,
    required this.configuration,
    required this.options,
    required this.theme,
    required this.themeMode,
    required this.brightness,
    required this.callbacks,
    required super.child,
  }) : super(notifier: controller);

  final SeatLayerPickerController controller;
  final SeatLayerConfiguration configuration;
  final SeatLayerPickerOptions options;
  final SeatLayerPickerThemeData? theme;
  final SeatLayerThemeMode themeMode;
  final Brightness brightness;
  final SeatLayerPickerCallbacks callbacks;

  @override
  bool updateShouldNotify(covariant _SeatLayerPickerInherited oldWidget) =>
      controller != oldWidget.controller ||
      !configuration.semanticallyEquals(oldWidget.configuration) ||
      options != oldWidget.options ||
      theme != oldWidget.theme ||
      themeMode != oldWidget.themeMode ||
      brightness != oldWidget.brightness ||
      super.updateShouldNotify(oldWidget);
}
