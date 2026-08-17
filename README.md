# SeatLayer for Flutter

[![CI](https://github.com/seatlayer/seatlayer-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/seatlayer/seatlayer-flutter/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/seatlayer.svg)](https://pub.dev/packages/seatlayer)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.19-02569B.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.4-0175C2.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/license-MIT-111827.svg)](LICENSE)

The official Flutter SDK for embedding interactive SeatLayer reserved-seating
maps on iOS and Android. It includes selection, holds, best available, general
admission, floors, accessibility controls, and a typed event bridge.

[Package on pub.dev](https://pub.dev/packages/seatlayer) ·
[Developer docs](https://docs.seatlayer.io/buyer-sdk/mobile/) ·
[Live demo](https://app.seatlayer.io/demo/play) ·
[Website](https://seatlayer.io/developers/) ·
[Native Android](https://github.com/seatlayer/seatlayer-android) ·
[React Native](https://github.com/seatlayer/seatlayer-react-native) ·
[AI Toolkit](https://github.com/seatlayer/seatlayer-ai-toolkit)

> **Public preview:** `0.1.x` is the first public Flutter line. Validate it with
> a test event and physical iOS/Android devices before production rollout.

## Install

```bash
flutter pub add seatlayer
```

Or add it to `pubspec.yaml`:

```yaml
dependencies:
  seatlayer: ^0.1.2
```

Then import the public library:

```dart
import 'package:seatlayer/seatlayer.dart';
```

## Quick start

Create one controller for the lifetime of the view. Give the map a definite
height or place it full-screen.

```dart
final controller = SeatLayerController();

@override
Widget build(BuildContext context) {
  return SizedBox(
    height: 640,
    child: SeatLayerView(
      controller: controller,
      configuration: SeatLayerConfiguration(
        event: 'ev_your_event_key',
        currency: 'USD',
      ),
      onReady: (info) {
        debugPrint(
          'SeatLayer ready: protocol=${info.protocolRevision} '
          'mode=${info.mode.raw}',
        );
      },
    ),
  );
}

@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

Drive buyer actions through the controller:

```dart
try {
  final hold = await controller.bestAvailable(4);
  if (hold != null) {
    beginCheckoutOnYourServer(hold.holdId);
  }
} on SeatLayerError catch (error) {
  // Handle sold_out, not_enough_together, expired holds, and other
  // recoverable inventory outcomes in the buyer UI.
  showSeatError(error.code, error.message);
}
```

Subscribe to strongly typed event streams:

```dart
controller.onSelectionChanged.listen(updateSelectedSeats);
controller.onHold.listen(persistHold);
controller.onHoldExpired.listen(returnBuyerToMap);
controller.onError.listen(reportSeatLayerError);
```

## Security boundary

The Flutter app **selects and holds** inventory. Your trusted backend **inspects
and books** the hold after payment or order validation.

- Never ship a SeatLayer secret key in the app binary or WebView.
- Send only the `holdId` and your normal checkout context to your backend.
- Calculate the charge from server-inspected hold items, not app input.
- Reuse your stable order id as `bookingRef` for safe booking retries.

Read [how the integration works](https://docs.seatlayer.io/start/how-it-works/)
before connecting checkout.

## How it works

The SDK hosts a vendored `seatlayer-js@0.59.0` buyer bundle (sha256 `89bc29fb…`) inside
`webview_flutter` and communicates over SeatLayer's versioned bridge protocol.
The UI can start without downloading SDK JavaScript; live chart and inventory
data still come from the configured SeatLayer API.

The public contract matches the Web and iOS SDKs:

- commands return `Future` values and throw typed `SeatLayerError` failures;
- events arrive through typed Dart streams;
- protocol negotiation fails clearly when an app update is required; and
- unknown future enum values and events remain forward-compatible.

## Commands

`hold` · `resumeHold` · `extendHold` · `release` · `releaseLabels` ·
`bestAvailable` · `holdGA` · `setSeatTier` · `getSelection` ·
`getCurrentHold` · `getGAAreas` · `getFloors` · `setFloor` ·
`setColorblindSafe` · `zoomIn` · `zoomOut` · `zoomToFit` · `destroy`

## Event streams

`onReady` · `onSelectionChanged` · `onHold` · `onHoldRestored` ·
`onHoldExpired` · `onError` · `onHint` · `onGAClick` · `onSeatHover` ·
`onDeckTap` · `onUnknownEvent`

## Layout requirement

Do not place the seat map inside `ListView`, `SingleChildScrollView`, or another
gesture-driven scrolling surface. The canvas owns pan and pinch gestures for map
navigation. Use a fixed-height `SizedBox`, an `Expanded` child with a resolved
height, or a full-screen route.

## Run the example

```bash
cd example
flutter run
```

The example uses the SDK's offline fixture to exercise the real bridge and
renderer without a live event key. For an end-to-end integration, provide a test
event and keep the default API origin.

## Related resources

- [Mobile SDK guide](https://docs.seatlayer.io/buyer-sdk/mobile/)
- [Buyer SDK installation](https://docs.seatlayer.io/buyer-sdk/install/)
- [Holds and checkout](https://docs.seatlayer.io/buyer-sdk/holds-and-checkout/)
- [Complete checkout example](https://docs.seatlayer.io/examples/complete-checkout/)
- [JavaScript and React SDKs](https://github.com/seatlayer/seatlayer-sdk)
- [SeatLayer iOS SDK](https://github.com/seatlayer/seatlayer-ios)
- [Agent-readable documentation](https://docs.seatlayer.io/llms.txt)

## SeatLayer SDK ecosystem

| Surface | Package or source |
| --- | --- |
| JavaScript | [`@seatlayer/js`](https://www.npmjs.com/package/@seatlayer/js) |
| React | [`@seatlayer/react`](https://www.npmjs.com/package/@seatlayer/react) |
| React Native | [`@seatlayer/react-native`](https://www.npmjs.com/package/@seatlayer/react-native) |
| iOS | [`seatlayer-ios`](https://github.com/seatlayer/seatlayer-ios) |
| Android | [`seatlayer-android`](https://github.com/seatlayer/seatlayer-android) |
| Server SDKs | [Node.js, Python, PHP, Ruby, .NET, Java, and Go](https://docs.seatlayer.io/server-sdk/install/) |

## Development

```bash
flutter pub get
flutter analyze
flutter test
dart pub publish --dry-run
```

## License

MIT © SeatLayer
