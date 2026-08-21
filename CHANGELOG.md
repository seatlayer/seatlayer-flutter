# Changelog

## 0.2.0

- Loads the pinned `seatlayer-js@0.66.0/mobile.html` document at
  `https://cdn.seatlayer.io`; buyer-access sessions require that exact origin.
- Separates the hosted runtime version (`0.66.0`) from the explicit offline
  demo/test fixture version (`0.59.0`).
- Adds renewable private buyer access, programmatic selection/category
  controls, exact-count validators, typed validity/access streams, view-mode
  parity, and fail-closed capability negotiation.
- Retains explicit Flutter asset loading for self-contained demos and tests.

## 0.1.3

- Updated the vendored buyer runtime to `seatlayer-js@0.59.0` (sha256
  `89bc29fb…`), pulled from the production CDN and byte-verified against the
  published release. Brings the mobile buyer round — an always-visible price
  rail, a locator that survives a filling cart, a venue overview that no longer
  covers the seats, accessibility filters that cannot be missed — plus the
  engine fixes that reach every surface: section focus frames the section
  rather than its whole zone, the price filter dims section blocks and not only
  seats, and map type is sized for the device.

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
