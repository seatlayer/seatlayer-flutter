import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

/// The Season picker, opened on its own route as an app would open it.
///
/// Run with:
///
///   flutter run --dart-define=SEATLAYER_SEASON=sea_your_test_season
///
/// Optional: `SEATLAYER_API_BASE`, `SEATLAYER_LOCALE` and
/// `SEATLAYER_THEME_MODE=auto|light|dark`, as for the event picker.
class LiveSeasonDemo extends StatefulWidget {
  const LiveSeasonDemo({
    super.key,
    required this.season,
    required this.themeMode,
    this.apiBase,
    this.locale,
  });

  final String season;
  final SeatLayerThemeMode themeMode;
  final String? apiBase;
  final String? locale;

  @override
  State<LiveSeasonDemo> createState() => _LiveSeasonDemoState();
}

class _LiveSeasonDemoState extends State<LiveSeasonDemo> {
  final _controller = SeatLayerSeasonController();
  final _subscriptions = <StreamSubscription<Object?>>[];
  String _last = '';

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll(<StreamSubscription<Object?>>[
      _controller.onReady.listen((info) {
        debugPrint(
          '[SeatLayerSeasonExample] ready protocol=${info.protocolRevision} '
          'season=${widget.season} timeToHelloMs=${info.timeToHelloMs} '
          'timeToReadyMs=${info.timeToReadyMs}',
        );
      }),
      _controller.onStatus.listen((status) {
        debugPrint(
          '[SeatLayerSeasonExample] status=${status.kind} '
          'dates=${status.dates?.length ?? "-"}',
        );
      }),
      _controller.onHold.listen((hold) {
        debugPrint('[SeatLayerSeasonExample] hold=${hold?.operationId ?? "-"}');
      }),
      _controller.onError.listen((error) {
        debugPrint('[SeatLayerSeasonExample] error=${error.code}');
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
    final handoff = await showSeatLayerSeasonPicker(
      context,
      configuration: SeatLayerSeasonConfiguration(
        season: widget.season,
        apiBase: widget.apiBase,
        locale: widget.locale,
        hostInfo: const {'app': 'SeatLayerFlutterPickerExample/0.3-dev'},
      ),
      controller: _controller,
      themeMode: widget.themeMode,
      strings: SeatLayerPickerStrings.forLocale(locale),
      // Your server books the hold here, at your prices, then the app tells
      // the page with `markBooked`. The example only shows what it received.
      onContinue: (handoff) => debugPrint(
        '[SeatLayerSeasonExample] continue=${handoff.operationId} '
        'seats=${(handoff.json['seats'] as List?)?.length ?? "-"}',
      ),
      onClose: (outcome, operationId) => debugPrint(
        '[SeatLayerSeasonExample] close=$outcome hold=${operationId ?? "-"}',
      ),
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
                child: const Text('Open the Season'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
