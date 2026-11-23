/// The run in the app: the event picker's header over the run page.
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
import 'run_configuration.dart';
import 'run_models.dart';
import 'seat_layer_run_controller.dart';
import 'seat_layer_run_view.dart';

/// Receives a run hold when the buyer presses Continue. Price and book it on
/// your server; throw to keep the buyer on the run.
typedef SeatLayerRunContinueCallback = FutureOr<void> Function(
  SeatLayerRunHandoff handoff,
);

/// The complete run picker: the header the event picker wears (brand mark,
/// name, hold clock, ✕) over the run page, which draws the map, the seat
/// card and the cart. The page's own header is off, and a page that honours
/// `appBar` hides its name row, steps, hint line and key too (FR01).
///
/// Give it a definite size. [showSeatLayerRunPicker] puts it on a route of its
/// own with system Back wired up.
///
/// It stays on the side it opened on (light or dark): runtime 1.0.0's run
/// page cannot repaint in place, and a reload would take the buyer's seats.
class SeatLayerRunPicker extends StatefulWidget {
  /// Creates a run picker for [configuration].
  const SeatLayerRunPicker({
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

  /// Which run to open and how.
  final SeatLayerRunConfiguration configuration;

  /// Receives the hold when the buyer continues to your checkout.
  final SeatLayerRunContinueCallback onContinue;

  /// The page driver, or null to let the picker own one.
  final SeatLayerRunController? controller;

  /// Explicit colours; these win over the resolved [themeMode].
  final SeatLayerPickerThemeData? theme;

  /// Which side to paint, resolved once when the page boots.
  final SeatLayerThemeMode themeMode;

  /// The header's words. Pass the language the page speaks:
  /// `SeatLayerPickerStrings.forLocale(...)`.
  final SeatLayerPickerStrings strings;

  /// A hold is booked (after [SeatLayerRunController.markBooked]).
  final ValueChanged<SeatLayerRunHandoff>? onBooked;

  /// The buyer closed the run; seats not handed off were released. Without
  /// it the close button is hidden.
  final VoidCallback? onClose;

  @override
  State<SeatLayerRunPicker> createState() => SeatLayerRunPickerState();
}

/// The state of a [SeatLayerRunPicker]; [requestClose] closes it.
class SeatLayerRunPickerState extends State<SeatLayerRunPicker>
    with WidgetsBindingObserver, SeatLayerSurfaceCloser<SeatLayerRunPicker> {
  late SeatLayerRunController _controller;
  late bool _ownsController;
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// The side the page booted on; the bar keeps it too.
  SeatLayerThemeMode? _bootMode;

  /// Why the page did not load, while the event picker's failure view stands
  /// in its place; and which page Retry is on.
  SeatLayerError? _loadError;
  int _page = 0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attach(widget.controller);
  }

  void _attach(SeatLayerRunController? given) {
    _controller = given ?? SeatLayerRunController();
    _ownsController = given == null;
    void rebuild(Object? _) {
      if (mounted) setState(() {});
    }

    _subscriptions.addAll(<StreamSubscription<Object?>>[
      _controller.onReady.listen((_) {
        rebuild(null);
        // A resumed hold may never be announced: ask the page, so the bar
        // shows its clock.
        if (widget.configuration.initialOperationId != null) {
          unawaited(_controller
              .readHeldOrder()
              .then<void>((_) {}, onError: (Object _) {}));
        }
      }),
      _controller.onRun.listen(rebuild),
      _controller.onStatus.listen(rebuild),
      _controller.onHold.listen(rebuild),
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
  void didUpdateWidget(covariant SeatLayerRunPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _detach();
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

  /// The buyer asked to leave (✕ or Back), as on the event picker: seats not
  /// handed off are released (`group.destroy`), then
  /// [SeatLayerRunPicker.onClose] hears it.
  @override
  Future<void> requestClose() async {
    if (_closing) return;
    _closing = true;
    try {
      if (_controller.isReady) await _controller.destroy();
      if (mounted) widget.onClose?.call();
    } finally {
      _closing = false;
    }
  }

  void _failed(SeatLayerError error) {
    if (mounted) setState(() => _loadError = error);
  }

  /// Retry boots a new page, as the event picker's does.
  void _retry() => setState(() {
        _loadError = null;
        _page += 1;
      });

  @override
  Widget build(BuildContext context) {
    final mode = _bootMode ??= seatLayerRunSideOf(context, widget.themeMode);
    final status = _controller.status;
    final descriptor = _controller.descriptor;
    final theme = resolveSeatLayerPalette(
      context,
      status?.branding,
      widget.theme,
      brightness: mode == SeatLayerThemeMode.dark
          ? Brightness.dark
          : Brightness.light,
    );
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
            markName: status?.branding?.brandName ?? descriptor?.name,
            // Until the page names the run, the bar keeps the event picker's
            // loading words.
            title: descriptor?.name ?? widget.strings.chooseSeats,
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
                // The web view does not pass the bottom safe area to the page
                // (env() reads 0 on iOS and Android), and the run page takes
                // no insets yet, so the app keeps it clear of the home
                // indicator, on the cart's surface.
                : ColoredBox(
                    color: theme.surface,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom,
                      ),
                      child: SeatLayerRunView(
                        key: ValueKey<int>(_page),
                        controller: _controller,
                        configuration: widget.configuration,
                        bootThemeMode: mode,
                        backgroundColor:
                            theme.mapBackground ?? theme.background,
                        onLoadError: _failed,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The side a run is painted on: `auto` resolved where the app's own
/// brightness is known, as the event picker does.
SeatLayerThemeMode seatLayerRunSideOf(
  BuildContext context,
  SeatLayerThemeMode mode,
) =>
    resolveSeatLayerThemeBrightness(context, mode) == Brightness.dark
        ? SeatLayerThemeMode.dark
        : SeatLayerThemeMode.light;

/// Present a [SeatLayerRunPicker] on a route of its own, and complete with the
/// hold the buyer continued with, or null if they closed the run.
///
/// [onContinue] runs BEFORE the route pops, so a host that books the hold
/// there can throw to refuse it and keep the buyer on the run.
Future<SeatLayerRunHandoff?> showSeatLayerRunPicker(
  BuildContext context, {
  required SeatLayerRunConfiguration configuration,
  SeatLayerRunContinueCallback? onContinue,
  SeatLayerRunController? controller,
  SeatLayerPickerThemeData? theme,
  SeatLayerThemeMode themeMode = SeatLayerThemeMode.auto,
  SeatLayerPickerStrings strings = const SeatLayerPickerStrings(),
  ValueChanged<SeatLayerRunHandoff>? onBooked,
  VoidCallback? onClose,
  SeatLayerPickerPresentation presentation =
      SeatLayerPickerPresentation.adaptive,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  // One side for the whole route, the frame included: the page keeps the
  // side it boots on.
  final side = seatLayerRunSideOf(context, themeMode);
  return showSeatLayerSurface<SeatLayerRunHandoff>(
    context,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    page: (inDialog) => SeatLayerSurfacePage<SeatLayerRunHandoff>(
      useScaffold: !inDialog,
      theme: (context) => resolveSeatLayerPalette(
        context,
        null,
        theme,
        brightness:
            side == SeatLayerThemeMode.dark ? Brightness.dark : Brightness.light,
      ),
      surface: (key, pop) => SeatLayerRunPicker(
        key: key,
        configuration: configuration,
        controller: controller,
        theme: theme,
        themeMode: side,
        strings: strings,
        onBooked: onBooked,
        onContinue: (handoff) async {
          await onContinue?.call(handoff);
          pop(handoff);
        },
        onClose: () {
          onClose?.call();
          pop(null);
        },
      ),
    ),
  );
}
