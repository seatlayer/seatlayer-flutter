import 'package:flutter/widgets.dart';

import '../seat_layer_configuration.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPickerScope extends StatefulWidget {
  const SeatLayerPickerScope({
    super.key,
    required this.configuration,
    required this.child,
    this.controller,
    this.options = const SeatLayerPickerOptions(),
    this.theme,
    this.callbacks = const SeatLayerPickerCallbacks(),
  });

  final SeatLayerConfiguration configuration;
  final SeatLayerPickerController? controller;
  final SeatLayerPickerOptions options;
  final SeatLayerPickerThemeData? theme;
  final SeatLayerPickerCallbacks callbacks;
  final Widget child;

  static SeatLayerPickerController controllerOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.controller;
  }

  static SeatLayerPickerState stateOf(BuildContext context) =>
      controllerOf(context).value;

  static SeatLayerConfiguration configurationOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.configuration;
  }

  static SeatLayerPickerOptions optionsOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.options;
  }

  static SeatLayerPickerThemeData? themeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SeatLayerPickerInherited>();
    assert(scope != null, 'No SeatLayerPickerScope found above this context');
    return scope!.theme;
  }

  @override
  State<SeatLayerPickerScope> createState() => _SeatLayerPickerScopeState();
}

class _SeatLayerPickerScopeState extends State<SeatLayerPickerScope> {
  late SeatLayerPickerController _controller;
  late bool _ownsController;

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
  Widget build(BuildContext context) => _SeatLayerPickerInherited(
        controller: _controller,
        configuration: widget.configuration,
        options: widget.options,
        theme: widget.theme,
        child: widget.child,
      );
}

class _SeatLayerPickerInherited
    extends InheritedNotifier<SeatLayerPickerController> {
  const _SeatLayerPickerInherited({
    required this.controller,
    required this.configuration,
    required this.options,
    required this.theme,
    required super.child,
  }) : super(notifier: controller);

  final SeatLayerPickerController controller;
  final SeatLayerConfiguration configuration;
  final SeatLayerPickerOptions options;
  final SeatLayerPickerThemeData? theme;

  @override
  bool updateShouldNotify(covariant _SeatLayerPickerInherited oldWidget) =>
      controller != oldWidget.controller ||
      !configuration.semanticallyEquals(oldWidget.configuration) ||
      options != oldWidget.options ||
      theme != oldWidget.theme ||
      super.updateShouldNotify(oldWidget);
}
