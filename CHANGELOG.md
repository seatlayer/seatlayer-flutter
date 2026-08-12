# Changelog

## 0.1.2

- Updated the vendored buyer runtime to `seatlayer-js@0.48.1` (sha256
  `b459b0b6…`) for the current responsive picker, access-token, checkout, and
  duplicate-title behavior.
- Corrected the runtime SDK version constant and README dependency version.

## 0.1.1

- Re-vendored the buyer bundle at `seatlayer-js@0.35.0` (sha256 `814657ba…`),
  up from 0.26.0. 0.1.0 shipped a renderer nine releases behind the published
  web SDK.

## 0.1.0

- First public SeatLayer Flutter SDK release.
- Added the `SeatLayerView` and `SeatLayerController` buyer integration.
- Added typed commands, event streams, errors, and protocol negotiation.
- Added iOS and Android support through `webview_flutter`.
- Vendored and versioned the SeatLayer buyer bundle for deterministic startup.
- Added an offline example and bridge contract test suite.
