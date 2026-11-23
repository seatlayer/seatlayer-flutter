import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

import 'run_demo.dart';
import 'season_demo.dart';

const _eventKey = String.fromEnvironment('SEATLAYER_EVENT');
const _seasonKey = String.fromEnvironment('SEATLAYER_SEASON');
const _runKey = String.fromEnvironment('SEATLAYER_RUN');
const _publicKey = String.fromEnvironment('SEATLAYER_PUBLIC_KEY');
const _runtimeUrl = String.fromEnvironment('SEATLAYER_RUNTIME_URL');
const _apiBase = String.fromEnvironment('SEATLAYER_API_BASE');
const _localeTag = String.fromEnvironment('SEATLAYER_LOCALE');

/// The language named by `--dart-define=SEATLAYER_LOCALE=…`, or null for the
/// device's own.
Locale? get _locale {
  if (_localeTag.isEmpty) return null;
  final parts = _localeTag.split(RegExp('[-_]'));
  return Locale(parts.first, parts.length > 1 ? parts[1] : null);
}

/// Right-to-left languages the picker ships.
const Set<String> _rightToLeft = <String>{'ar', 'he', 'fa', 'ku'};
const _themeModeName = String.fromEnvironment(
  'SEATLAYER_THEME_MODE',
  defaultValue: 'auto',
);

/// The theme mode named by `--dart-define=SEATLAYER_THEME_MODE=…`.
///
/// Unknown names fall back to [SeatLayerThemeMode.auto] so a typo opens the
/// picker rather than failing the run.
SeatLayerThemeMode get _themeMode => switch (_themeModeName) {
  'light' => SeatLayerThemeMode.light,
  'dark' => SeatLayerThemeMode.dark,
  _ => SeatLayerThemeMode.auto,
};

void main() => runApp(const DemoApp());

/// The example app.
///
/// It opens on a home screen with the three pickers: an event, a Season and a
/// run. Each opens when its key is passed; without one it names the define to
/// pass rather than quietly showing something else. The raw protocol-1
/// fixture lives in `offline_fixture_demo.dart` for bridge work.
class DemoApp extends StatelessWidget {
  /// Creates the example app.
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SeatLayer Flutter seat picker',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    themeMode: switch (_themeMode) {
      SeatLayerThemeMode.light => ThemeMode.light,
      SeatLayerThemeMode.dark => ThemeMode.dark,
      SeatLayerThemeMode.auto => ThemeMode.system,
    },
    home: const _Home(),
  );
}

/// The three pickers, one button each.
class _Home extends StatelessWidget {
  const _Home();

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String, String, Widget Function())>[
      (
        'Event',
        _eventKey,
        'SEATLAYER_EVENT=ev_…',
        () => const LivePickerDemo(),
      ),
      (
        'Season',
        _seasonKey,
        'SEATLAYER_SEASON=sea_…',
        () => LiveSeasonDemo(
          season: _seasonKey,
          themeMode: _themeMode,
          apiBase: _apiBase.isEmpty ? null : _apiBase,
          locale: _localeTag.isEmpty ? null : _localeTag,
        ),
      ),
      (
        'Run',
        _runKey,
        'SEATLAYER_RUN=pg_…',
        () => LiveRunDemo(
          run: _runKey,
          themeMode: _themeMode,
          apiBase: _apiBase.isEmpty ? null : _apiBase,
          assetPath: _runtimeUrl.isEmpty ? null : _runtimeUrl,
          locale: _localeTag.isEmpty ? null : _localeTag,
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('SeatLayer pickers')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            for (final (name, key, define, page) in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    enabled: key.isNotEmpty,
                    title: Text(name),
                    subtitle: Text(
                      key.isNotEmpty ? key : 'Pass --dart-define=$define',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _push(context, page()),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'The event picker also takes '
              '--dart-define=SEATLAYER_PUBLIC_KEY=pk_test_…. For bridge work '
              'without a key, run lib/offline_fixture_demo.dart.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// The complete native picker used for live protocol-v2 validation.
///
/// Run with:
///
///   flutter run \
///     --dart-define=SEATLAYER_EVENT=ev_your_test_event \
///     --dart-define=SEATLAYER_PUBLIC_KEY=pk_test_your_public_key
///
/// Optional: `SEATLAYER_API_BASE` points the session at another API origin, and
/// `SEATLAYER_THEME_MODE=auto|light|dark` pins the picker's appearance.
///
/// While validating a pre-release renderer, also point the SDK at it:
///
///   --dart-define=SEATLAYER_RUNTIME_URL=https://…
class LivePickerDemo extends StatefulWidget {
  const LivePickerDemo({super.key});

  @override
  State<LivePickerDemo> createState() => _LivePickerDemoState();
}

class _LivePickerDemoState extends State<LivePickerDemo> {
  late final SeatLayerConfiguration _configuration = SeatLayerConfiguration(
    event: _eventKey,
    publicKey: _publicKey.isEmpty ? null : _publicKey,
    apiBase: _apiBase.isEmpty ? null : _apiBase,
    // The map's own language; the native chrome follows it below.
    locale: _localeTag.isEmpty ? null : _localeTag,
    hostInfo: const {'app': 'SeatLayerFlutterPickerExample/0.3-dev'},
    assetPath: _runtimeUrl.isEmpty
        ? SeatLayerConfiguration.defaultAssetPath
        : _runtimeUrl,
  );

  Future<void> _openCheckout(SeatLayerCheckoutHandoff handoff) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Scrolls on a phone held sideways, where the sheet is shorter than
      // its words.
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Checkout handoff received',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                '${handoff.lineItems.length} line item(s) · '
                '${handoff.currency} ${handoff.total.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              const Text(
                'The hold is now host-owned. Send handoff.holdId to your '
                'trusted backend, inspect the hold there, then take payment '
                'and book with an idempotent order reference.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = _locale ?? Localizations.localeOf(context);
    return Directionality(
      textDirection: _rightToLeft.contains(locale.languageCode)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        body: SeatLayerPicker(
          configuration: _configuration,
          themeMode: _themeMode,
          options: SeatLayerPickerOptions(
            strings: SeatLayerPickerStrings.forLocale(locale),
          ),
          callbacks: SeatLayerPickerCallbacks(
            onReady: (info) {
              final helloToReadyMs =
                  info.timeToHelloMs == null || info.timeToReadyMs == null
                  ? null
                  : info.timeToReadyMs! - info.timeToHelloMs!;
              debugPrint(
                '[SeatLayerPickerExample] ready '
                'protocol=${info.protocolRevision} '
                'mode=${info.mode.raw} '
                'event=${info.eventKey ?? "-"} '
                'timeToHelloMs=${info.timeToHelloMs} '
                'helloToReadyMs=$helloToReadyMs '
                'timeToReadyMs=${info.timeToReadyMs}',
              );
            },
            onChartLoad: (load) {
              final trace = load.trace;
              debugPrint(
                '[SeatLayerPickerPerf] '
                'tapToReadyMs=${load.tapToReadyMs} '
                'hostMs=${load.hostMs} '
                'bootMs=${trace.bootMs} '
                'documentMs=${trace.documentMs} '
                'handshakeMs=${trace.handshakeMs} '
                'renderMs=${trace.ms} '
                'paintMs=${trace.paint} '
                'availabilityMs=${trace.availabilityMs} '
                'load=${trace.load} '
                'chartCache=${trace.chartCache} '
                'host=${trace.host} '
                'platform=${trace.platform} '
                'bundle=${trace.bundle}',
              );
            },
            onError: (error) {
              debugPrint('[SeatLayerPickerExample] error=${error.code}');
            },
          ),
          onCheckout: _openCheckout,
          // ✕ goes back to the home screen.
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
