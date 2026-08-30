# SeatLayer Flutter seat map example

A runnable reserved-seating seat picker for the official
[`seatlayer`](https://pub.dev/packages/seatlayer) Flutter package on iOS and
Android.

## Run the picker

The default screen is the live picker, which is the product. It needs a test
event key; pass no key and the app says so rather than quietly showing
something else.

```bash
flutter pub get
flutter run \
  --dart-define=SEATLAYER_EVENT=ev_your_test_event \
  --dart-define=SEATLAYER_PUBLIC_KEY=pk_test_your_public_key
```

Optional defines:

| Define | Effect |
| --- | --- |
| `SEATLAYER_API_BASE` | Points the session at another API origin. |
| `SEATLAYER_THEME_MODE` | `auto` (default), `light` or `dark`. |
| `SEATLAYER_RUNTIME_URL` | Load a renderer other than the package's pin — an HTTPS URL, or an `http://localhost` one served from a local build. Omit it to use the pin. |

Choose an iOS or Android simulator or physical device. The seat map must remain
inside its fixed-height or full-screen container so it can own pan and pinch
gestures.

## The other two entry points

Neither is the default; both are chosen explicitly with `-t`.

```bash
# The raw map surface, against the packaged offline fixture — no event key needed.
flutter run -t lib/offline_fixture_demo.dart

# The native chrome over a canned snapshot, for design review. The map is a
# placeholder: this is not a working picker.
flutter run -t lib/chrome_preview.dart
```

## Connect your own event

Keep booking and secret-key calls in your backend. Read the
[Flutter seat-map guide](https://docs.seatlayer.io/buyer-sdk/flutter/) and the
[holds and checkout guide](https://docs.seatlayer.io/buyer-sdk/holds-and-checkout/)
before connecting production checkout. You can also explore the
[SeatLayer SDK and API overview](https://seatlayer.io/developers/) and the
[browser buyer demo](https://app.seatlayer.io/demo/play/grand-theatre); the
browser demo demonstrates the buyer experience but is not a Flutter app.
