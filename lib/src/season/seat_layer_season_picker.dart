/// The Season in the app: the event picker's header over the Season page.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../picker/picker_header.dart';
import '../picker/picker_layout.dart';
import '../picker/picker_models.dart';
import '../picker/picker_status_views.dart';
import '../picker/picker_strings.dart';
import '../picker/picker_tokens.g.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import '../seat_layer_surface_route.dart';
import 'season_configuration.dart';
import 'season_models.dart';
import 'seat_layer_season_controller.dart';
import 'seat_layer_season_view.dart';

/// Receives a Season hold when the buyer presses Continue. Book it on your
/// server at your prices; throw to keep the buyer on the Season.
typedef SeatLayerSeasonContinueCallback = FutureOr<void> Function(
  SeatLayerSeasonHandoff handoff,
);

/// How a close the buyer asked for ended, and the hold it was about.
typedef SeatLayerSeasonCloseCallback = void Function(
  SeatLayerSeasonCloseOutcome outcome,
  String? operationId,
);

/// The complete Season picker: the header the event picker wears (brand
/// mark, name, hold clock, ✕) over the Season page, which draws the package,
/// the dates, the map and the cart.
///
/// Give it a definite size. [showSeatLayerSeasonPicker] puts it on a route of
/// its own with system Back wired up.
class SeatLayerSeasonPicker extends StatefulWidget {
  /// Creates a Season picker for [configuration].
  const SeatLayerSeasonPicker({
    super.key,
    required this.configuration,
    required this.onContinue,
    this.controller,
    this.theme,
    this.themeMode = SeatLayerThemeMode.auto,
    this.strings = const SeatLayerPickerStrings(),
    this.onBooked,
    this.onClose,
  });

  /// Which Season to open and how.
  final SeatLayerSeasonConfiguration configuration;

  /// Receives the hold when the buyer continues to your checkout.
  final SeatLayerSeasonContinueCallback onContinue;

  /// The page driver, or null to let the picker own one.
  final SeatLayerSeasonController? controller;

  /// Explicit colours; these win over the resolved [themeMode].
  final SeatLayerPickerThemeData? theme;

  /// Which side to paint. [SeatLayerThemeMode.auto] follows the app live,
  /// with no reload.
  final SeatLayerThemeMode themeMode;

  /// The header's words. Pass the language the page speaks:
  /// `SeatLayerPickerStrings.forLocale(...)`.
  final SeatLayerPickerStrings strings;

  /// A hold this picker made is booked (after
  /// [SeatLayerSeasonController.markBooked]).
  final ValueChanged<SeatLayerSeasonHandoff>? onBooked;

  /// The buyer closed the Season. Without it the close button is hidden.
  final SeatLayerSeasonCloseCallback? onClose;

  @override
  State<SeatLayerSeasonPicker> createState() => SeatLayerSeasonPickerState();
}

/// The state of a [SeatLayerSeasonPicker]; [requestClose] asks the page.
class SeatLayerSeasonPickerState extends State<SeatLayerSeasonPicker>
    with WidgetsBindingObserver {
  late SeatLayerSeasonController _controller;
  late bool _ownsController;
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// The side the page booted on, and the side it was last told.
  SeatLayerThemeMode? _bootMode;
  SeatLayerThemeMode? _pageMode;
  double? _sentBottomInset;

  /// Why the page did not load, while the event picker's failure view stands
  /// in its place; and which page Retry is on, so a retry mounts a new one.
  SeatLayerError? _loadError;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attach(widget.controller);
  }

  void _attach(SeatLayerSeasonController? given) {
    _controller = given ?? SeatLayerSeasonController();
    _ownsController = given == null;
    void rebuild(Object? _) {
      if (mounted) setState(() {});
    }

    _subscriptions.addAll(<StreamSubscription<Object?>>[
      _controller.onStatus.listen(rebuild),
      _controller.onHold.listen(rebuild),
      _controller.onReady.listen((_) {
        // A page that just booted knows its boot side and no insets.
        _pageMode = null;
        _sentBottomInset = null;
        rebuild(null);
      }),
      _controller.onContinue.listen(
        (handoff) => unawaited(Future<void>.sync(
          () => widget.onContinue(handoff),
        ).catchError((Object _) {})),
      ),
      _controller.onBooked.listen((handoff) => widget.onBooked?.call(handoff)),
    ]);
  }

  void _detach() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    if (_ownsController) _controller.dispose();
  }

  @override
  void didUpdateWidget(covariant SeatLayerSeasonPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _detach();
    _bootMode = null;
    _attach(widget.controller);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detach();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.isReady) return;
    final foreground = switch (state) {
      AppLifecycleState.resumed => true,
      AppLifecycleState.paused || AppLifecycleState.hidden => false,
      _ => null,
    };
    if (foreground == null) return;
    // Best effort: coming back, the page re-reads the hold itself.
    unawaited(_controller
        .setForeground(foreground)
        .then<void>((_) {}, onError: (Object _) {}));
  }

  /// The buyer asked to leave (✕ or Back). With seats held the page asks
  /// whether to release or keep them; [SeatLayerSeasonPicker.onClose] hears
  /// how it ended, unless the buyer stayed.
  ///
  /// Each press is sent: a second one while the question is up dismisses it,
  /// and both answer that the buyer stayed (Back pressed twice).
  Future<void> requestClose() async {
    try {
      final closed = _controller.isReady
          ? await _controller.requestClose()
          : (outcome: SeatLayerSeasonCloseOutcome.closed, operationId: null);
      if (!mounted || !closed.outcome.closes) return;
      widget.onClose?.call(closed.outcome, closed.operationId);
    } catch (_) {
      // The page kept the seats and said why on its own status line.
    }
  }

  /// A Season that cannot be mounted renders nothing and fails the handshake
  /// (`sys.error`, `sys.incompatible`, or no answer in time). The buyer gets
  /// the event picker's own failure view under the bar, not a blank page.
  void _failed(SeatLayerError error) {
    if (mounted) setState(() => _loadError = error);
  }

  /// Retry boots a new page, as the event picker's does.
  void _retry() => setState(() {
        _loadError = null;
        _page += 1;
      });

  /// The side the page is painted on: `auto` resolved here, where the app's
  /// own brightness is known, as the event picker does.
  SeatLayerThemeMode _sideOf(BuildContext context) =>
      resolveSeatLayerThemeBrightness(context, widget.themeMode) ==
              Brightness.dark
          ? SeatLayerThemeMode.dark
          : SeatLayerThemeMode.light;

  void _follow(SeatLayerThemeMode mode, double bottomInset) {
    _bootMode ??= mode;
    if (!_controller.isReady) return;
    final themeChanged = mode != (_pageMode ?? _bootMode);
    final insetChanged = bottomInset != _sentBottomInset;
    if (!themeChanged && !insetChanged) return;
    if (themeChanged) _pageMode = mode;
    if (insetChanged) _sentBottomInset = bottomInset;
    // Both repaint the page in place; a changed boot theme would reload it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isReady) return;
      if (themeChanged && _pageMode == mode) {
        unawaited(_controller
            .setThemeMode(mode)
            .then<void>((_) {}, onError: (Object _) {}));
      }
      if (insetChanged && _sentBottomInset == bottomInset) {
        // The page's cart docks over the home indicator; the app's header
        // already holds the top.
        unawaited(_controller
            .setViewportInsets(EdgeInsets.only(bottom: bottomInset))
            .then<void>((_) {}, onError: (Object _) {}));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = _sideOf(context);
    _follow(mode, MediaQuery.paddingOf(context).bottom);
    final status = _controller.status;
    final theme = seatLayerSeasonThemeOf(context, widget, status);
    final hold = _controller.hold;
    final wide = MediaQuery.sizeOf(context).width >=
            SeatLayerSizeTokens.wideBreakpoint &&
        seatLayerOnTablet(context);
    return ColoredBox(
      color: theme.background,
      child: Column(
        children: <Widget>[
          SeatLayerHeaderBar(
            theme: theme,
            strings: widget.strings,
            logoUrl: status?.branding?.logoUrl,
            markName: status?.branding?.brandName ?? status?.seasonName,
            // Until the page names the Season, the bar keeps the event
            // picker's loading words.
            title: status?.seasonName ?? widget.strings.chooseSeats,
            clock: hold == null
                ? null
                : SeatLayerHoldClock(
                    expiresAt: hold.expiresAt,
                    theme: theme,
                    strings: widget.strings,
                    compact: !wide,
                  ),
            onClose:
                widget.onClose == null ? null : () => unawaited(requestClose()),
            compact: !wide,
          ),
          Expanded(
            child: _loadError != null
                ? SeatLayerPickerErrorView.standalone(
                    theme: theme,
                    strings: widget.strings,
                    onRetry: _retry,
                  )
                : SeatLayerSeasonView(
                    key: ValueKey<int>(_page),
                    controller: _controller,
                    configuration: widget.configuration,
                    bootThemeMode: _bootMode ?? mode,
                    backgroundColor: theme.mapBackground ?? theme.background,
                    onLoadError: _failed,
                  ),
          ),
        ],
      ),
    );
  }
}

/// The palette a [SeatLayerSeasonPicker] paints with: the host's theme, then
/// the club's brand once the page sends it.
SeatLayerResolvedPickerTheme seatLayerSeasonThemeOf(
  BuildContext context,
  SeatLayerSeasonPicker widget,
  SeatLayerSeasonStatus? status,
) =>
    resolveSeatLayerPalette(
      context,
      status?.branding,
      widget.theme,
      brightness: resolveSeatLayerThemeBrightness(context, widget.themeMode),
    );

/// Present a [SeatLayerSeasonPicker] on a route of its own, and complete with
/// the hold the buyer continued with, or null if they closed the Season.
///
/// [onContinue] runs BEFORE the route pops, so a host that books the hold
/// there can throw to refuse it and keep the buyer on the Season.
Future<SeatLayerSeasonHandoff?> showSeatLayerSeasonPicker(
  BuildContext context, {
  required SeatLayerSeasonConfiguration configuration,
  SeatLayerSeasonContinueCallback? onContinue,
  SeatLayerSeasonController? controller,
  SeatLayerPickerThemeData? theme,
  SeatLayerThemeMode themeMode = SeatLayerThemeMode.auto,
  SeatLayerPickerStrings strings = const SeatLayerPickerStrings(),
  ValueChanged<SeatLayerSeasonHandoff>? onBooked,
  SeatLayerSeasonCloseCallback? onClose,
  SeatLayerPickerPresentation presentation =
      SeatLayerPickerPresentation.adaptive,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) =>
    showSeatLayerSurface<SeatLayerSeasonHandoff>(
      context,
      presentation: presentation,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      page: (inDialog) => _SeatLayerSeasonPage(
        useScaffold: !inDialog,
        picker: (key, pop) => SeatLayerSeasonPicker(
          key: key,
          configuration: configuration,
          controller: controller,
          theme: theme,
          themeMode: themeMode,
          strings: strings,
          onBooked: onBooked,
          onContinue: (handoff) async {
            await onContinue?.call(handoff);
            pop(handoff);
          },
          onClose: (outcome, operationId) {
            onClose?.call(outcome, operationId);
            pop(null);
          },
        ),
      ),
    );

/// The Season picker in the shared page frame.
class _SeatLayerSeasonPage extends StatefulWidget {
  const _SeatLayerSeasonPage({required this.useScaffold, required this.picker});

  final bool useScaffold;
  final SeatLayerSeasonPicker Function(
    GlobalKey<SeatLayerSeasonPickerState> key,
    void Function(SeatLayerSeasonHandoff? result) pop,
  ) picker;

  @override
  State<_SeatLayerSeasonPage> createState() => _SeatLayerSeasonPageState();
}

class _SeatLayerSeasonPageState extends State<_SeatLayerSeasonPage> {
  final _picker = GlobalKey<SeatLayerSeasonPickerState>();
  bool _allowPop = false;

  void _pop(SeatLayerSeasonHandoff? result) {
    if (!mounted || _allowPop) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final picker = widget.picker(_picker, _pop);
    return SeatLayerSurfaceFrame(
      // The club's brand never sets the ground, so the frame needs no status.
      theme: seatLayerSeasonThemeOf(context, picker, null),
      canPop: _allowPop,
      onBack: () => unawaited(_picker.currentState?.requestClose()),
      useScaffold: widget.useScaffold,
      child: picker,
    );
  }
}
