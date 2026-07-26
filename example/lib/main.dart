import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeatLayer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final SeatLayerController _controller = SeatLayerController();

  // A real integration sets `apiBase` to the SeatLayer API and passes a live
  // `event` key. This demo instead points `assetPath` at the SDK's offline
  // fixture page, which drives the REAL bridge against a stub chart — so it
  // renders and exercises hold/best/fit with no network. See assets/demo.html.
  late final SeatLayerConfiguration _config = SeatLayerConfiguration(
    event: 'flutter-demo-show',
    apiBase: 'https://api.seatlayer.io',
    currency: 'USD',
    hostInfo: const {'app': 'SeatLayerFlutterDemo/1.0'},
    assetPath: 'packages/seatlayer/assets/demo.html',
  );

  ReadyInfo? _ready;
  List<SelectedSeat> _selection = const [];
  String _status = 'starting…';

  @override
  void initState() {
    super.initState();
    _controller.onSelectionChanged.listen((seats) {
      setState(() => _selection = seats);
    });
    _controller.onHold.listen((hold) {
      _log('hold ${hold.holdId} · ${hold.items?.length ?? 0} seats');
    });
    _controller.onHoldExpired.listen((_) => _log('hold expired'));
    _controller.onError.listen((e) => _log('error: ${e.code}'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _log(String text) => setState(() => _status = text);

  Future<void> _hold() async {
    try {
      final hold = await _controller.hold();
      _log(hold == null ? 'no hold' : 'held ${hold.holdId}');
    } on SeatLayerError catch (e) {
      _log('hold failed: ${e.code}');
    }
  }

  Future<void> _bestAvailable() async {
    try {
      final result = await _controller.bestAvailable(4);
      _log('best: ${(result?.labels ?? const []).join(', ')}');
    } on SeatLayerError catch (e) {
      // sold_out / not_enough_together arrive here with the API code intact.
      _log('best available: ${e.code}');
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
        title: const Text('SeatLayer'),
        backgroundColor: const Color(0xFF0F1116),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The map: a fixed-height box, never inside a scroll view (v0.1).
            Expanded(
              child: Stack(
                children: [
                  SeatLayerView(
                    controller: _controller,
                    configuration: _config,
                    backgroundColor: const Color(0xFF0F1116),
                    onReady: (info) {
                      setState(() => _ready = info);
                      _log(
                        'ready · protocol ${info.protocolRevision} · '
                        'transport ${info.transport.raw}',
                      );
                      // The single most important line for a real integration:
                      // proof the handshake completed.
                      debugPrint(
                        '[SeatLayerDemo] sys.ready '
                        'protocol=${info.protocolRevision} '
                        'mode=${info.mode.raw} '
                        'transport=${info.transport.raw} '
                        'event=${info.eventKey ?? "-"}',
                      );
                    },
                    onLoadError: (e) => _log('load failed: ${e.code}'),
                  ),
                  if (ready != null && ready.mode == EventMode.test)
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
                              '${_selection.map((s) => s.buyerFacingLabel).join(', ')}',
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
                      _Btn('Hold', _hold),
                      const SizedBox(width: 8),
                      _Btn('Best 4', _bestAvailable),
                      const SizedBox(width: 8),
                      _Btn('Fit', _fit),
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

class _Btn extends StatelessWidget {
  const _Btn(this.label, this.onTap);
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
