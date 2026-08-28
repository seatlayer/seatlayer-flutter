// The native chrome, over a canned snapshot, for design review.
//
// This is NOT a working picker: the map is a placeholder and no runtime is
// loaded. It exists because the chrome is the part of the picker Flutter owns —
// the venue itself stays in the WebView by design — and reviewing that chrome
// should not require a live event key.
//
//   flutter run -t lib/chrome_preview.dart
//
// Switch pages with the tabs; switch appearance with the device.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seatlayer/seatlayer.dart';

void main() => runApp(const ChromePreviewApp());

/// A tabbed tour of every rebuilt picker surface.
class ChromePreviewApp extends StatelessWidget {
  /// Creates the preview app.
  const ChromePreviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SeatLayer chrome preview',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    home: const _Preview(),
  );
}

class _Preview extends StatefulWidget {
  const _Preview();

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  final _FixtureRuntime _runtime = _FixtureRuntime();
  late final SeatLayerPickerController _picker = SeatLayerPickerController(
    mapController: _runtime,
  );
  bool _expanded = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runtime.emit(_snapshot(seats: 6));
    });
  }

  @override
  void dispose() {
    _picker.dispose();
    _runtime.dispose();
    super.dispose();
  }

  void _show(int page, {required int seats, bool venue3D = false}) {
    setState(() {
      _page = page;
      _expanded = page == 2 || page == 3;
    });
    _runtime.emit(_snapshot(seats: seats, venue3D: venue3D));
  }

  @override
  Widget build(BuildContext context) => SeatLayerPickerScope(
    configuration: SeatLayerConfiguration(event: 'ev_preview'),
    controller: _picker,
    child: Scaffold(
      body: Column(
        children: <Widget>[
          SeatLayerPickerHeader(compact: true, onClose: () {}),
          Expanded(
            child: Stack(
              children: <Widget>[
                const Positioned.fill(child: _VenuePlaceholder()),
                const Positioned(
                  top: 8,
                  left: 0,
                  right: 56,
                  child: SeatLayerPriceLegend(compact: true),
                ),
                const Positioned.fill(
                  child: SeatLayerPickerMapControls(
                    compact: true,
                    bottomInset: 52,
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SeatLayerDockBar(reserveBottomInset: false),
                ),
                const Positioned.fill(
                  child: SeatLayerVenue3D(topInset: 46, bottomInset: 62),
                ),
                if (_page == 1)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x99000000),
                      child: Center(child: SeatLayerConfirmCard()),
                    ),
                  ),
              ],
            ),
          ),
          SeatLayerCartSheet(
            expanded: _expanded,
            onExpandedChanged: (value) => setState(() => _expanded = value),
            onCheckout: (_) async {},
          ),
          _Tabs(
            page: _page,
            onSelected: (page) => switch (page) {
              0 => _show(0, seats: 6),
              1 => _show(1, seats: 1),
              2 => _show(2, seats: 6),
              3 => _show(3, seats: 0),
              _ => _show(4, seats: 3, venue3D: true),
            },
          ),
        ],
      ),
    ),
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.page, required this.onSelected});

  final int page;
  final ValueChanged<int> onSelected;

  static const List<String> _labels = <String>[
    'Dock',
    'Card',
    'Cart',
    'Empty',
    '3D',
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SizedBox(
      height: 44,
      child: Row(
        children: <Widget>[
          for (var index = 0; index < _labels.length; index++)
            Expanded(
              child: TextButton(
                onPressed: () => onSelected(index),
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    fontWeight: page == index
                        ? FontWeight.w900
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Stands in for the drawn map, which lives in the WebView.
class _VenuePlaceholder extends StatelessWidget {
  const _VenuePlaceholder();

  @override
  Widget build(BuildContext context) {
    // The real 3D scene is dark whatever the picker's mode is, which is why
    // the chrome over it goes dark too. The stand-in follows suit.
    final venue3D =
        SeatLayerPickerScope.stateOf(context).snapshot?.map.isVenue3D ?? false;
    final dark = venue3D || Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F1522) : const Color(0xFFE9EDF4),
      ),
      child: Center(
        child: Text(
          'venue renders here',
          style: TextStyle(
            color: dark ? const Color(0x33EEF1F8) : const Color(0x33172033),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// A runtime that answers nothing and replays one canned snapshot.
final class _FixtureRuntime extends SeatLayerController {
  final StreamController<EventSignal> _events =
      StreamController<EventSignal>.broadcast();
  int _revision = 0;

  @override
  Stream<EventSignal> get onBridgeEvent => _events.stream;

  @override
  Future<Object?> runBridgeCommand(String command, [Object? payload]) async =>
      null;

  void emit(Map<String, Object?> snapshot) {
    _revision += 1;
    _events.add(
      EventSignal(
        name: 'picker.snapshot',
        payload: <String, Object?>{
          'snapshot': <String, Object?>{...snapshot, 'revision': _revision},
        },
        sequence: _revision,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_events.close());
    super.dispose();
  }
}

Map<String, Object?> _snapshot({required int seats, bool venue3D = false}) {
  final selection = <Object?>[
    for (var index = 1; index <= seats; index++)
      <String, Object?>{
        'id': 'seat-d-$index',
        'label': "D-$index",
        'displayLabel': 'Row D, Seat $index',
        'sectionLabel': 'Stalls D',
        'rowLabel': 'D',
        'seatNumber': '$index',
        'categoryKey': 'stalls',
        'price': 75.0,
        'currency': 'USD',
      },
  ];
  return <String, Object?>{
    'schema': 'seatlayer.picker.snapshot/1',
    'sessionId': 'preview',
    'revision': 1,
    'event': <String, Object?>{
      'key': 'ev_preview',
      'name': 'Grand Theatre · Opening Night',
      'mode': 'test',
      'currency': 'USD',
      'venue': 'Grand Theatre',
    },
    'branding': <String, Object?>{'attributionRequired': true},
    'features': <String, Object?>{
      'bestAvailable': true,
      'venue3d': true,
      'seatView': true,
      'accessibilityFilter': true,
    },
    'catalog': <String, Object?>{
      'categories': <Object?>[
        <String, Object?>{
          'key': 'stalls',
          'label': 'Stalls',
          'color': '#635BFF',
          'priceMin': 75.0,
          'priceMax': 75.0,
          'available': 74,
          'notForSale': false,
          'tiers': <Object?>[],
        },
        <String, Object?>{
          'key': 'circle',
          'label': 'Grand Circle',
          'color': '#22A06B',
          'priceMin': 45.0,
          'priceMax': 45.0,
          'available': 120,
          'notForSale': false,
          'tiers': <Object?>[],
        },
        <String, Object?>{
          'key': 'box',
          'label': 'Boxes',
          'color': '#E5A100',
          'priceMin': 180.0,
          'priceMax': 180.0,
          'available': 8,
          'notForSale': false,
          'tiers': <Object?>[],
        },
      ],
      'zones': <Object?>[],
      'sections': <Object?>[
        <String, Object?>{
          'id': 'stalls-d',
          'label': 'Stalls D',
          'color': '#635BFF',
          'seatsLeft': 74,
        },
        <String, Object?>{
          'id': 'circle-a',
          'label': 'Grand Circle A',
          'color': '#22A06B',
          'seatsLeft': 41,
        },
      ],
      'gaAreas': <Object?>[],
      'bestAvailableZones': <Object?>[
        <String, Object?>{'id': 'stalls', 'label': 'Stalls'},
        <String, Object?>{'id': 'circle', 'label': 'Grand Circle'},
      ],
    },
    'map': <String, Object?>{
      'rung': 'seats',
      'viewMode': 'flat',
      'buyerView': venue3D ? 'venue3d' : 'map',
      'view3dNavigationMode': 'orbit',
      if (venue3D) 'view3dTargetSeatId': 'seat-d-2',
      'colorblindSafe': false,
      'hideLimitedView': false,
      'canZoomIn': true,
      'canZoomOut': true,
      'categoryFilter': <Object?>[],
      'accessibilityFilter': <Object?>[],
      'floors': <Object?>[],
      'focusedSectionId': 'stalls-d',
      'focusedSection': <String, Object?>{
        'id': 'stalls-d',
        'label': 'Stalls D',
        'color': '#635BFF',
        'seatsLeft': 74,
      },
    },
    'selection': <String, Object?>{
      'seats': selection,
      'validity': <String, Object?>{
        'isValid': true,
        'count': seats,
        'required': 0,
        'remaining': 0,
      },
      'maxSelection': 10,
    },
    'cart': <String, Object?>{
      'items': <Object?>[
        for (var index = 1; index <= seats; index++)
          <String, Object?>{
            'lineKey': 'seat:D-$index',
            'label': 'D-$index',
            'displayLabel': 'Row D, Seat $index',
            'objectId': 'seat-d-$index',
            'objectType': 'seat',
            'categoryKey': 'stalls',
            'unitPrice': 75.0,
            'currency': 'USD',
            'quantity': 1,
          },
      ],
      'quantity': seats,
      'total': seats * 75.0,
      'currency': 'USD',
    },
    'hold': <String, Object?>{
      'active': seats > 0,
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 14, seconds: 59))
          .millisecondsSinceEpoch
          .toDouble(),
      'ownership': 'picker',
    },
    'access': <String, Object?>{'configured': false, 'status': 'public'},
  };
}
