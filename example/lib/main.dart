import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

const _eventKey = String.fromEnvironment('SEATLAYER_EVENT');
const _publicKey = String.fromEnvironment('SEATLAYER_PUBLIC_KEY');
const _runtimeUrl = String.fromEnvironment('SEATLAYER_RUNTIME_URL');
const _apiBase = String.fromEnvironment('SEATLAYER_API_BASE');
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
/// It opens on the live picker, which is the product. Pass no event key and it
/// says so rather than quietly showing something else; the raw protocol-1
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
    home: _eventKey.isEmpty ? const _MissingEventKey() : const LivePickerDemo(),
  );
}

class _MissingEventKey extends StatelessWidget {
  const _MissingEventKey();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'Run with --dart-define=SEATLAYER_EVENT=ev_… and '
          '--dart-define=SEATLAYER_PUBLIC_KEY=pk_test_… to open the '
          'picker.\n\nFor bridge work without a key, run '
          'lib/offline_fixture_demo.dart.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
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
/// During runtime development, also provide the immutable HTTPS test document:
///
///   --dart-define=SEATLAYER_RUNTIME_URL=https://.../mobile.html
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
      builder: (context) => SafeArea(
        child: Padding(
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
    return Scaffold(
      body: SeatLayerPicker(
        configuration: _configuration,
        themeMode: _themeMode,
        callbacks: SeatLayerPickerCallbacks(
          onReady: (info) {
            debugPrint(
              '[SeatLayerPickerExample] ready '
              'protocol=${info.protocolRevision} '
              'mode=${info.mode.raw} '
              'event=${info.eventKey ?? "-"}',
            );
          },
          onError: (error) {
            debugPrint('[SeatLayerPickerExample] error=${error.code}');
          },
        ),
        onCheckout: _openCheckout,
      ),
    );
  }
}
