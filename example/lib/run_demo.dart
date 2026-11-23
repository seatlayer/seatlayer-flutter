import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

/// The run picker, opened on its own route as an app would open it.
///
/// Run with:
///
///   flutter run --dart-define=SEATLAYER_RUN=pg_your_test_run
///
/// Optional: `SEATLAYER_API_BASE`, `SEATLAYER_LOCALE` and
/// `SEATLAYER_THEME_MODE=auto|light|dark`, as for the event picker.
class LiveRunDemo extends StatefulWidget {
  const LiveRunDemo({
    super.key,
    required this.run,
    required this.themeMode,
    this.apiBase,
    this.locale,
  });

  final String run;
  final SeatLayerThemeMode themeMode;
  final String? apiBase;
  final String? locale;

  @override
  State<LiveRunDemo> createState() => _LiveRunDemoState();
}

class _LiveRunDemoState extends State<LiveRunDemo> {
  final _controller = SeatLayerRunController();
  final _subscriptions = <StreamSubscription<Object?>>[];
  String _last = '';

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll(<StreamSubscription<Object?>>[
      _controller.onReady.listen((info) {
        debugPrint(
          '[SeatLayerRunExample] ready protocol=${info.protocolRevision} '
          'run=${widget.run} timeToHelloMs=${info.timeToHelloMs} '
          'timeToReadyMs=${info.timeToReadyMs}',
        );
      }),
      _controller.onRun.listen((run) {
        debugPrint(
          '[SeatLayerRunExample] run performances=${run.performances.length}',
        );
      }),
      _controller.onStatus.listen((status) {
        debugPrint('[SeatLayerRunExample] status=${status.kind}');
      }),
      _controller.onHold.listen((hold) {
        debugPrint('[SeatLayerRunExample] hold=${hold?.operationId ?? "-"}');
      }),
      _controller.onError.listen((error) {
        debugPrint('[SeatLayerRunExample] error=${error.code}');
      }),
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final locale = widget.locale == null
        ? Localizations.localeOf(context)
        : Locale(widget.locale!.split(RegExp('[-_]')).first);
    final handoff = await showSeatLayerRunPicker(
      context,
      configuration: SeatLayerRunConfiguration(
        run: widget.run,
        apiBase: widget.apiBase,
        locale: widget.locale,
        hostInfo: const {'app': 'SeatLayerFlutterPickerExample/0.3-dev'},
      ),
      controller: _controller,
      themeMode: widget.themeMode,
      strings: SeatLayerPickerStrings.forLocale(locale),
      // Your server prices and books the hold here, then the app tells the
      // page with `markBooked`. The example only shows what it received.
      onContinue: (handoff) => debugPrint(
        '[SeatLayerRunExample] continue=${handoff.operationId} '
        'seats=${handoff.seatLabels.length} '
        'performances=${handoff.performanceKeys.length}',
      ),
      onClose: () => debugPrint('[SeatLayerRunExample] close'),
    );
    if (!mounted) return;
    setState(
      () => _last = handoff == null
          ? 'Closed.'
          : 'Continued with ${handoff.operationId}. Book it on your server.',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_last.isNotEmpty) Text(_last, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _open,
                child: const Text('Open the run'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
