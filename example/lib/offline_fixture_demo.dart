// The raw protocol-1 fixture, for bridge development without a live event.
//
// Run it directly:
//
//   flutter run -t lib/offline_fixture_demo.dart
//
// It deliberately exercises the stable raw [SeatLayerView], not the picker.
import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

void main() => runApp(
  MaterialApp(
    title: 'SeatLayer raw fixture',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: const OfflineRawFixtureDemo(),
  ),
);

/// Zero-configuration fallback for bridge development and first-time clones.
///
/// The bundled fixture intentionally exercises the stable raw protocol-v1
/// [SeatLayerView]. It does not pretend to implement the protocol-v2 picker.
class OfflineRawFixtureDemo extends StatefulWidget {
  /// Creates the raw fixture demo.
  const OfflineRawFixtureDemo({super.key});

  @override
  State<OfflineRawFixtureDemo> createState() => _OfflineRawFixtureDemoState();
}

class _OfflineRawFixtureDemoState extends State<OfflineRawFixtureDemo> {
  final SeatLayerController _controller = SeatLayerController();

  late final SeatLayerConfiguration _configuration = SeatLayerConfiguration(
    event: 'flutter-demo-show',
    apiBase: 'https://api.seatlayer.io',
    currency: 'USD',
    hostInfo: const {'app': 'SeatLayerFlutterRawFixture/1.0'},
    assetPath: 'assets/demo.html',
  );

  ReadyInfo? _ready;
  List<SelectedSeat> _selection = const [];
  String _status = 'starting…';

  @override
  void initState() {
    super.initState();
    _controller.onSelectionChanged.listen((seats) {
      if (mounted) setState(() => _selection = seats);
    });
    _controller.onHold.listen((hold) {
      _log('hold created · ${hold.items?.length ?? 0} item(s)');
    });
    _controller.onHoldExpired.listen((_) => _log('hold expired'));
    _controller.onError.listen((error) => _log('error: ${error.code}'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _log(String text) {
    if (mounted) setState(() => _status = text);
  }

  Future<void> _hold() async {
    try {
      final hold = await _controller.hold();
      _log(hold == null ? 'no hold' : 'hold created');
    } on SeatLayerError catch (error) {
      _log('hold failed: ${error.code}');
    }
  }

  Future<void> _bestAvailable() async {
    try {
      final result = await _controller.bestAvailable(4);
      _log('best: ${(result?.labels ?? const []).join(', ')}');
    } on SeatLayerError catch (error) {
      _log('best available: ${error.code}');
    }
  }

  Future<void> _fit() async {
    await _controller.zoomToFit();
    _log('zoomed to fit');
  }

  @override
  Widget build(BuildContext context) {
    final ready = _ready;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1116),
      appBar: AppBar(
        title: const Text('Raw protocol-v1 offline fixture'),
        backgroundColor: const Color(0xFF0F1116),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SeatLayerView(
                    controller: _controller,
                    configuration: _configuration,
                    backgroundColor: const Color(0xFF0F1116),
                    onReady: (info) {
                      setState(() => _ready = info);
                      _log(
                        'ready · protocol ${info.protocolRevision} · '
                        'transport ${info.transport.raw}',
                      );
                    },
                    onLoadError: (error) {
                      _log('load failed: ${error.code}');
                    },
                  ),
                  // Raw integrations own their surrounding chrome. The full
                  // SeatLayerPicker renders this indicator itself exactly once.
                  if (ready?.mode == EventMode.test)
                    Positioned(
                      top: 8,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD98C1A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TEST EVENT · BOOKS NOTHING',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selection.isEmpty
                        ? 'No seats selected'
                        : '${_selection.length} selected · '
                              '${_selection.map((seat) => seat.buyerFacingLabel).join(', ')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _status,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ActionButton('Hold', _hold),
                      const SizedBox(width: 8),
                      _ActionButton('Best 4', _bestAvailable),
                      const SizedBox(width: 8),
                      _ActionButton('Fit', _fit),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.label, this.onTap);

  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: () => onTap(),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF57D9A3),
          foregroundColor: Colors.black,
        ),
        child: Text(label),
      ),
    );
  }
}
