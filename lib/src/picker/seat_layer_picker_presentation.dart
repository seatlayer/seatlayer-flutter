import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../seat_layer_configuration.dart';
import 'picker_builders.dart';
import 'picker_models.dart';
import 'picker_options.dart';
import 'picker_system_overlay.dart';
import 'seat_layer_picker.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_theme.dart';

/// [SeatLayerPicker] on a route of its own, with system back wired up.
///
/// Takes every option [SeatLayerPicker] takes and forwards all of them; the
/// page adds only what a route needs — a scaffold, and popping on checkout.
class SeatLayerPickerPage extends StatefulWidget {
  /// Creates a full-page picker for [configuration].
  const SeatLayerPickerPage({
    super.key,
    required this.configuration,
    required this.onCheckout,
    this.controller,
    this.options = const SeatLayerPickerOptions(),
    this.theme,
    this.themeMode = SeatLayerThemeMode.auto,
    this.builders = const SeatLayerPickerBuilders(),
    this.callbacks = const SeatLayerPickerCallbacks(),
    this.onClose,
    this.useScaffold = true,
    this.popOnCheckout = false,
  });

  /// What event to load and how.
  final SeatLayerConfiguration configuration;

  /// Receives the hold when the buyer continues to checkout.
  final SeatLayerCheckoutCallback onCheckout;

  /// The session driver, or null to let the page own one.
  final SeatLayerPickerController? controller;

  /// Behaviour switches for the session and its chrome.
  final SeatLayerPickerOptions options;

  /// Explicit colours; these win over the resolved [themeMode].
  final SeatLayerPickerThemeData? theme;

  /// Which side of the theme to paint, and what to tell the runtime.
  ///
  /// [SeatLayerThemeMode.auto] follows the device live. Note that an explicit
  /// preset — `SeatLayerPickerThemeData.light()` or `.dark()` — supplies a
  /// complete ground palette that wins over the resolved mode, so a host that
  /// wants `auto` to work must brand with the default constructor:
  /// `SeatLayerPickerThemeData(accent: ...)`.
  final SeatLayerThemeMode themeMode;

  /// Replacements for individual parts of the default composition.
  final SeatLayerPickerBuilders builders;

  /// Session lifecycle callbacks.
  final SeatLayerPickerCallbacks callbacks;

  /// Called after the session closes and before the route pops.
  final VoidCallback? onClose;

  /// Whether to wrap the picker in a [Scaffold]. Off inside a dialog.
  final bool useScaffold;

  /// Whether a completed checkout pops the route with its handoff.
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
      themeMode: widget.themeMode,
      builders: widget.builders,
      callbacks: widget.callbacks,
      onCheckout: _checkout,
      onClose: () => unawaited(
        _requestClose(SeatLayerPickerCloseReason.closeButton),
      ),
    );
    // The page reserves its top and side insets; the mobile ticket panel owns
    // the bottom inset. This lets the dock adapt its gesture clearance instead
    // of inheriting an unavoidable empty strip in full-screen presentations.
    final content = SafeArea(bottom: false, child: picker);
    final page = PopScope(
      canPop: _allowPop,
      // Flutter 3.19 compatibility; newer SDKs prefer onPopInvokedWithResult.
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop) {
          unawaited(_requestClose(SeatLayerPickerCloseReason.systemBack));
        }
      },
      child: widget.useScaffold ? _scaffold(content) : content,
    );
    if (!widget.options.chrome.manageSystemOverlays) return page;
    // The picker's own region is sized to the picker, and the page deliberately
    // hands the top inset to a SafeArea — so nothing inside it reaches the
    // strip the status bar is drawn over. This region does, which is what makes
    // the clock legible on a full-screen picker.
    return _withResolvedTheme(
      page,
      (context, theme, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: seatLayerPickerOverlayStyle(theme),
        child: child,
      ),
    );
  }

  /// The picker on a scaffold whose ground is the picker's own.
  ///
  /// A bare `Scaffold` paints the HOST application's
  /// `scaffoldBackgroundColor`, and the page hands its top inset to a SafeArea
  /// rather than to the header — so a dark picker inside a light-themed host
  /// wore a white band above its own header. The ground is the surface the
  /// header docks on, so the strip reads as part of the header.
  ///
  /// In the immersive scene that surface is the dark venue, so the strip
  /// follows the scene palette too — otherwise a light picker keeps a white
  /// band above a black 3D view.
  Widget _scaffold(Widget content) => _withResolvedTheme(
        content,
        (context, theme, child) =>
            Scaffold(backgroundColor: theme.surface, body: child),
      );

  /// Build [child] under the picker's currently resolved palette.
  ///
  /// Resolved through a listener rather than once, because the organizer's
  /// branding and the immersive scene both arrive with a snapshot. [child] is
  /// passed through untouched, so a new palette never rebuilds the picker.
  Widget _withResolvedTheme(
    Widget child,
    Widget Function(
      BuildContext context,
      SeatLayerResolvedPickerTheme theme,
      Widget child,
    ) build,
  ) =>
      ValueListenableBuilder<SeatLayerPickerState>(
        valueListenable: _controller,
        child: child,
        builder: (context, state, inner) {
          final resolved = resolveSeatLayerPickerTheme(
            context,
            state,
            widget.theme,
            brightness:
                resolveSeatLayerThemeBrightness(context, widget.themeMode),
          );
          final venue3D = state.snapshot?.map.isVenue3D ?? false;
          return build(
            context,
            venue3D ? resolved.immersive : resolved,
            inner!,
          );
        },
      );
}

/// Present [SeatLayerPickerPage] and complete with the buyer's hold.
///
/// Resolves to the [SeatLayerCheckoutHandoff] the buyer continued with, or
/// null if they dismissed the picker. Every [SeatLayerPickerPage] option is
/// forwarded; [presentation], [useRootNavigator] and [routeSettings] are the
/// route's own.
///
/// [onCheckout] runs BEFORE the route pops, so a host that books the hold
/// there can throw to refuse it and keep the buyer in the picker. Omit it and
/// the returned future is the whole handoff.
Future<SeatLayerCheckoutHandoff?> showSeatLayerPicker(
  BuildContext context, {
  required SeatLayerConfiguration configuration,
  SeatLayerCheckoutCallback? onCheckout,
  SeatLayerPickerController? controller,
  SeatLayerPickerOptions options = const SeatLayerPickerOptions(),
  SeatLayerPickerThemeData? theme,
  SeatLayerThemeMode themeMode = SeatLayerThemeMode.auto,
  SeatLayerPickerBuilders builders = const SeatLayerPickerBuilders(),
  SeatLayerPickerCallbacks callbacks = const SeatLayerPickerCallbacks(),
  VoidCallback? onClose,
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
            themeMode: themeMode,
            builders: builders,
            callbacks: callbacks,
            onClose: onClose,
            useScaffold: false,
            popOnCheckout: true,
            onCheckout: onCheckout ?? (_) {},
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
        themeMode: themeMode,
        builders: builders,
        callbacks: callbacks,
        onClose: onClose,
        popOnCheckout: true,
        onCheckout: onCheckout ?? (_) {},
      ),
    ),
  );
}
