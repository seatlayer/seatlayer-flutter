/// The run in the app: the event picker's header over the run page.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../bridge/bridge_page_recovery.dart';
import '../picker/picker_header.dart';
import '../picker/picker_layout.dart';
import '../picker/picker_models.dart';
import '../picker/picker_status_views.dart';
import '../picker/picker_strings.dart';
import '../picker/picker_tokens.g.dart';
import '../picker/seat_layer_picker_theme.dart';
import '../seat_layer_error.dart';
import '../seat_layer_page_keeper.dart';
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
/// `appBar` hides its name row, steps, hint line and key too.
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

  /// The hold the buyer has, whether or not a page is up.
  SeatLayerRunHandoff? _held;

  /// The hold a page that takes another's place opens on.
  SeatLayerRunHandoff? _resumed;

  /// Whether a page was up, and whether this page takes its place: that one
  /// starts without the hold the configuration opens on, which may be gone.
  bool _pageWasUp = false;
  bool _again = false;

  final SeatLayerPageRecovery _recovery = SeatLayerPageRecovery();
  late final SeatLayerPageKeeper _keeper = SeatLayerPageKeeper(_pageLost);

  /// The bottom inset this page was last sent, and whether it refused one.
  double? _sentBottomInset;
  bool _insetsRefused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attach(widget.controller);
  }

  void _attach(SeatLayerRunController? given) {
    _controller = given ?? SeatLayerRunController();
    _ownsController = given == null;
    _keeper.watch(_controller);
    void rebuild(Object? _) {
      if (mounted) setState(() {});
    }

    _subscriptions.addAll(<StreamSubscription<Object?>>[
      _controller.onReady.listen((_) {
        _pageWasUp = true;
        if (_resumed == null) _held = _controller.hold;
        // A page that just booted knows no insets.
        _sentBottomInset = null;
        _insetsRefused = false;
        rebuild(null);
        // A resumed hold may never be announced: ask the page, so the bar
        // shows its clock.
        if (_resumed != null ||
            widget.configuration.initialOperationId != null) {
          unawaited(_controller
              .readHeldOrder()
              .then<void>((_) {}, onError: (Object _) {}));
        }
      }),
      _controller.onRun.listen(rebuild),
      _controller.onStatus.listen(rebuild),
      _controller.onHold.listen((hold) {
        _held = hold;
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
    _keeper.unwatch();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    if (_ownsController) _controller.dispose();
  }

  @override
  void didUpdateWidget(covariant SeatLayerRunPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controllerChanged = oldWidget.controller != widget.controller;
    if (controllerChanged ||
        !oldWidget.configuration.semanticallyEquals(widget.configuration)) {
      // Another page is asked for: it opens on what it is given.
      _held = _resumed = null;
      _pageWasUp = _again = false;
    }
    if (!controllerChanged) return;
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
    if (_keeper.appMoved(state) || !_controller.isReady) return;
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

  /// Whether this page keeps its own cart clear of the home indicator / gesture
  /// bar from the inset the app sends. Without it the app keeps a band
  /// there: the web view passes no bottom inset (env() reads 0 on iOS and
  /// Android).
  bool get _pageTakesInsets =>
      _controller.isReady &&
      !_insetsRefused &&
      (_controller.bundleInfo?.supportsCommand('group.setViewportInsets') ??
          false);

  /// Send the bottom inset after `group.ready` and when it changes (rotation).
  void _followInset(double bottomInset) {
    if (bottomInset == _sentBottomInset) return;
    _sentBottomInset = bottomInset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isReady) return;
      if (_sentBottomInset != bottomInset) return;
      unawaited(_controller
          .setViewportInsets(EdgeInsets.only(bottom: bottomInset))
          .then<void>((_) {}, onError: (Object _) {
        // The page did not take it: the app keeps the band.
        if (mounted) setState(() => _insetsRefused = true);
      }));
    });
  }

  void _failed(SeatLayerError error) {
    if (!mounted) return;
    setState(() {
      // A hold that is gone is not a run that did not load.
      if (_resumed == null) {
        _loadError = error;
      } else {
        _resumed = null;
        _nextPage();
      }
    });
  }

  /// The system ended the page: a new one opens on the same hold, until pages
  /// keep being lost. Then the failure view stands there, with Try again.
  void _pageLost() {
    if (!mounted) return;
    _controller.detachTransport();
    if (!_recovery.lost()) {
      _resumed = null;
      return _failed(
        const SeatLayerError.transport(
          'The system keeps closing the SeatLayer page.',
        ),
      );
    }
    setState(() {
      _loadError = null;
      _resumed = _held;
      _nextPage();
    });
  }

  void _nextPage() {
    _again = _pageWasUp;
    _page += 1;
  }

  /// Retry boots a new page, as the event picker's does.
  void _retry() {
    _recovery.reset();
    setState(() {
      _loadError = null;
      _resumed = _held;
      _nextPage();
    });
  }

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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final pageTakesInsets = _pageTakesInsets;
    if (pageTakesInsets) _followInset(bottomInset);
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
                // A page that takes the inset runs its cart under the home
                // indicator; for one that does not, the app keeps it clear,
                // on the cart's surface.
                : ColoredBox(
                    color: theme.surface,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: pageTakesInsets ? 0 : bottomInset,
                      ),
                      child: SeatLayerRunView.inPicker(
                        key: ValueKey<int>(_page),
                        resumed: _resumed,
                        again: _again,
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
