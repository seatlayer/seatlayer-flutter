# SeatLayer Flutter SDK

Embed an interactive SeatLayer seat map in a Flutter app. The SDK hosts the
vendored SeatLayer web widget inside a `webview_flutter` WebView and drives it
over the shared, versioned **bridge protocol** — the same wire contract the web
and iOS SDKs implement, so all three read as one product.

This is a faithful Dart port of the proven iOS SDK. Nothing is fetched from the
network at startup: the widget bundle (`assets/seatlayer.js`, `seatlayer-js@0.26.0`)
ships inside the package.

## Install

```yaml
dependencies:
  seatlayer_flutter:
    path: ../flutter   # or a git/pub reference
```

## Use

```dart
final controller = SeatLayerController();

// In your widget tree — give the map a DEFINITE size (see the constraint below).
SeatLayerView(
  controller: controller,
  configuration: SeatLayerConfiguration(
    event: 'ev_your_event_key',
    apiBase: 'https://api.seatlayer.io',
    currency: 'USD',
  ),
  onReady: (info) {
    // Proof the handshake completed. Badge `info.mode == EventMode.test`.
    debugPrint('ready: protocol=${info.protocolRevision} mode=${info.mode.raw}');
  },
);

// Commands return Futures; a conflict throws a typed SeatLayerError.
try {
  final result = await controller.bestAvailable(4);
  print(result?.labels);
} on SeatLayerError catch (e) {
  // e.code is 'sold_out' / 'not_enough_together' / … on the awaited call —
  // not only on the onError stream.
}

// Events are Streams.
controller.onSelectionChanged.listen((seats) => setState(...));
controller.onHold.listen((hold) => ...);

// Always dispose.
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### Commands

`hold`, `resumeHold`, `extendHold`, `release`, `releaseLabels`, `bestAvailable`,
`holdGA`, `setSeatTier`, `getSelection`, `getCurrentHold`, `getGAAreas`,
`getFloors`, `setFloor`, `setColorblindSafe`, `zoomIn`, `zoomOut`, `zoomToFit`,
`destroy`.

### Event streams

`onReady`, `onSelectionChanged`, `onHold`, `onHoldRestored`, `onHoldExpired`,
`onError`, `onHint`, `onGAClick`, `onSeatHover`, `onDeckTap`, `onUnknownEvent`,
`onCheckout` (reserved; not emitted by the v1 bundle).

## Known constraint (v0.1)

The map must be a **fixed-height or full-screen** box. Do NOT place it inside a
scrolling container (`ListView`, `SingleChildScrollView`, …). The canvas
consumes pan and pinch to drive its own zoom; an enclosing scroll view and the
map would fight over every gesture. An `EagerGestureRecognizer` is installed so
the map wins those gestures.

## Forward compatibility

The web bundle is updated independently of your app. Every bridged enum (seat
status, event mode, transport, object type, envelope kind) is a **sealed class
with an `Unknown(raw)` variant**, and every payload decoder ignores fields it
does not recognise. An app compiled today keeps working when a bundle a year
from now ships a new enum value — it surfaces as `…Unknown` / `onUnknownEvent`
rather than throwing.

If the app's protocol range and the bundle's do not overlap, the load fails with
a typed `IncompatibleFailure` (`error.requiresAppUpdate == true`) — the one
failure a retry cannot fix.

## Running the example

```bash
cd example
flutter run
```

The example loads the SDK's **offline fixture** (`assets/demo.html`): it drives
the REAL bridge runtime against a stub chart rendered by the bundle's own
renderer, so it works with no network and no live event key. Point
`SeatLayerConfiguration.apiBase` at the API and pass a live `event` for a real
integration (leave `assetPath` at its default).

## Development

```bash
flutter analyze   # clean
flutter test      # bridge/envelope/negotiation/unknown-enum unit tests
```
