# SeatLayer Flutter seat map example

A runnable reserved-seating chart and seat-picker example for the official
[`seatlayer`](https://pub.dev/packages/seatlayer) Flutter package on iOS and
Android.

The default screen uses the package's offline fixture. It exercises the real
SeatLayer bridge, renderer, selection, hold, and best-available commands without
requiring a live event key.

## Run

```bash
flutter pub get
flutter run
```

Choose an iOS or Android simulator or physical device. The seat map must remain
inside its fixed-height or full-screen container so it can own pan and pinch
gestures.

## Connect a SeatLayer test event

In `lib/main.dart`:

1. replace `flutter-demo-show` with your test event key;
2. remove the custom `assetPath` so the package loads its normal integration
   page; and
3. keep booking and secret-key calls in your backend.

Read the [Flutter seat-map guide](https://docs.seatlayer.io/buyer-sdk/flutter/)
and [holds and checkout guide](https://docs.seatlayer.io/buyer-sdk/holds-and-checkout/)
before connecting production checkout. You can also explore the
[SeatLayer reserved-seating platform](https://seatlayer.io/) and the
[browser buyer demo](https://app.seatlayer.io/demo/play/grand-theatre); the
browser demo demonstrates the buyer experience but is not a Flutter app.
