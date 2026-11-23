# SeatLayer Flutter seat map example

A runnable reserved-seating seat picker for the official
[`seatlayer`](https://pub.dev/packages/seatlayer) Flutter package on iOS and
Android. See the [main Flutter SDK README](../README.md) for installation,
customization, and the full seat-map API.

## Run the picker

The app opens on a home screen with the three pickers: **Event**, **Season**
and **Run**. Each opens when its key is passed; without one, its button names
the define to pass rather than quietly showing something else. Pass all three
to try every picker from one build.

```bash
flutter pub get
flutter run \
  --dart-define=SEATLAYER_EVENT=ev_your_test_event \
  --dart-define=SEATLAYER_PUBLIC_KEY=pk_test_your_public_key \
  --dart-define=SEATLAYER_SEASON=sea_your_test_season \
  --dart-define=SEATLAYER_RUN=pg_your_test_run
```

The event picker's ✕ goes back to the home screen; the Season and Run pages
open their picker straight away and keep an Open button and a back arrow.

Optional defines:

| Define | Effect |
| --- | --- |
| `SEATLAYER_API_BASE` | Points the session at another API origin. |
| `SEATLAYER_THEME_MODE` | `auto` (default), `light` or `dark`. |
| `SEATLAYER_LOCALE` | A language such as `de` or `ar`: the map and the native chrome both use it, and a right-to-left language mirrors the chrome. Omit it to follow the device. |
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
