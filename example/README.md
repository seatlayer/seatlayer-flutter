# SeatLayer Flutter example

A runnable example for the official [`seatlayer`](https://pub.dev/packages/seatlayer)
Flutter package.

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

Read the [mobile SDK guide](https://docs.seatlayer.io/buyer-sdk/mobile/) and
[holds and checkout guide](https://docs.seatlayer.io/buyer-sdk/holds-and-checkout/)
before connecting production checkout.
