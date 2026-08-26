import 'dart:async';

import 'package:flutter/material.dart';

import '../seat_layer_configuration.dart';
import 'picker_builders.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'seat_layer_picker.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPickerPage extends StatefulWidget {
  const SeatLayerPickerPage({
    super.key,
    required this.configuration,
    required this.onCheckout,
    this.controller,
    this.options = const SeatLayerPickerOptions(),
    this.theme,
    this.builders = const SeatLayerPickerBuilders(),
    this.callbacks = const SeatLayerPickerCallbacks(),
    this.onClose,
    this.useScaffold = true,
    this.popOnCheckout = false,
  });

  final SeatLayerConfiguration configuration;
  final SeatLayerCheckoutCallback onCheckout;
  final SeatLayerPickerController? controller;
  final SeatLayerPickerOptions options;
  final SeatLayerPickerThemeData? theme;
  final SeatLayerPickerBuilders builders;
  final SeatLayerPickerCallbacks callbacks;
  final VoidCallback? onClose;
  final bool useScaffold;
  final bool popOnCheckout;

  @override
  State<SeatLayerPickerPage> createState() => _SeatLayerPickerPageState();
}

class _SeatLayerPickerPageState extends State<SeatLayerPickerPage> {
  late SeatLayerPickerController _controller;
  late bool _ownsController;
  bool _allowPop = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SeatLayerPickerController();
    _ownsController = widget.controller == null;
  }

  @override
  void didUpdateWidget(covariant SeatLayerPickerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    if (_ownsController) _controller.dispose();
    _controller = widget.controller ?? SeatLayerPickerController();
    _ownsController = widget.controller == null;
  }

  Future<void> _requestClose(SeatLayerPickerCloseReason reason) async {
    if (_closing || _allowPop) return;
    _closing = true;
    try {
      await _controller.close(reason: reason);
      widget.onClose?.call();
      if (!mounted) return;
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
    } finally {
      _closing = false;
    }
  }

  Future<void> _checkout(SeatLayerCheckoutHandoff handoff) async {
    await widget.onCheckout(handoff);
    if (!widget.popOnCheckout || !mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop(handoff);
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picker = SeatLayerPicker(
      configuration: widget.configuration,
      controller: _controller,
      options: widget.options,
      theme: widget.theme,
      builders: widget.builders,
      callbacks: widget.callbacks,
      onCheckout: _checkout,
      onClose: () => unawaited(
        _requestClose(SeatLayerPickerCloseReason.closeButton),
      ),
    );
    final content = SafeArea(child: picker);
    return PopScope(
      canPop: _allowPop,
      // Flutter 3.19 compatibility; newer SDKs prefer onPopInvokedWithResult.
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop) {
          unawaited(_requestClose(SeatLayerPickerCloseReason.systemBack));
        }
      },
      child: widget.useScaffold ? Scaffold(body: content) : content,
    );
  }
}

Future<SeatLayerCheckoutHandoff?> showSeatLayerPicker(
  BuildContext context, {
  required SeatLayerConfiguration configuration,
  SeatLayerPickerController? controller,
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  SeatLayerPickerThemeData? theme,
  SeatLayerPickerBuilders builders = const SeatLayerPickerBuilders(),
  SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
  SeatLayerPickerPresentation presentation =
      SeatLayerPickerPresentation.adaptive,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final resolved = presentation == SeatLayerPickerPresentation.adaptive
      ? (MediaQuery.sizeOf(context).width >= 700
          ? SeatLayerPickerPresentation.dialog
          : SeatLayerPickerPresentation.fullScreen)
      : presentation;

  if (resolved == SeatLayerPickerPresentation.dialog) {
    return showDialog<SeatLayerCheckoutHandoff>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: false,
      routeSettings: routeSettings,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 820),
          child: SeatLayerPickerPage(
            configuration: configuration,
            controller: controller,
            options: options,
            theme: theme,
            builders: builders,
            callbacks: callbacks,
            useScaffold: false,
            popOnCheckout: true,
            onCheckout: (_) {},
          ),
        ),
      ),
    );
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<SeatLayerCheckoutHandoff>(
    MaterialPageRoute<SeatLayerCheckoutHandoff>(
      settings: routeSettings,
      fullscreenDialog: true,
      builder: (_) => SeatLayerPickerPage(
        configuration: configuration,
        controller: controller,
        options: options,
        theme: theme,
        builders: builders,
        callbacks: callbacks,
        popOnCheckout: true,
        onCheckout: (_) {},
      ),
    ),
  );
}
