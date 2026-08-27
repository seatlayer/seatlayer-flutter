# Changelog

## 0.3.0-dev.5 (unreleased)

Phone parity round. The native chrome is rebuilt against the web picker's
measured phone layout, and the package is prepared for a stable 0.3.0.

**Theme**

- `SeatLayerPicker(themeMode:)` with `SeatLayerThemeMode.auto | light | dark`.
  `auto` follows `MediaQuery.platformBrightness` live. The resolved side is
  folded into the init config as `theme: { mode }` and every later change
  travels as `picker.setThemeMode`, so a light/dark flip repaints the chrome
  and the drawn map without reloading the runtime or losing the selection.
- The light and dark presets now match the web picker's ground tokens: white
  chrome over a recessed `#e9edf4` map in light, `#0f1522`/`#1a2234` in dark.
- `SeatLayerPickerCallbacks.onThemeResolved` reports the resolved side.

**Phone chrome**

- New `SeatLayerDockBar`: the focused section, its remaining seats, prev/next
  and an explicit way back to the overview, docked under the map at rung 2.
- A native rung ladder. `PopScope` walks seat card → section → overview →
  dismiss, so Android predictive back and the iOS edge swipe both behave.
- New `SeatLayerConfirmCard`: one identity line, a photo strip carrying the
  view-from-seat and 3D pills, and a 40-point action row. 89 points without the
  strip, 158 with it.
- New `SeatLayerCartSheet`: a 50-point peek and an expanded height that follows
  its own content, capped at three fifths of the screen. The sheet never opens
  itself.
- New `SeatLayerCartList`: one 40-point line per ticket, with consecutive seats
  in the same row and price folding into a run (`Gallery · A · 1–6  6 × €25`).
  Removal is immediate with a four-second undo.
- New `SeatLayerBestSeatsForm`: two selects on one row, a stepper and one
  action. No card, no title, no helper paragraph.
- `SeatLayerPickerHeader` is one 56-point line and owns the hold countdown.
- `SeatLayerPriceLegend` replaces the price rail: dot-and-price chips that
  scroll sideways over the map's top-left corner.
- `SeatLayerPickerMapControls` puts accessibility, fit-to-screen and a
  segmented Map/3D control in the corners on a phone. The zoom pair and the
  colourblind toggle are off by default there — pinch already zooms, and the
  colourblind palette moved inside the accessibility sheet.
- New `SeatLayerVenue3D`: caption chip, seat stepper, `Open venue 360°`,
  recentre and `‹ Back to venue` over the immersive scene, in dark tokens
  whatever the picker's own mode is.

**Motion and haptics**

- `SeatLayerPickerMotion`: one duration table every animation spends, and every
  one of them collapses under `MediaQuery.disableAnimations`.
- `PickerHapticCue.holdExpired` fires `heavyImpact` from the runtime's own
  expiry signal.

**Customisation**

- `SeatLayerPickerStrings` makes every buyer-facing string an override.
- `SeatLayerPickerLayout` makes every size in the spec a default rather than a
  constant.
- New builder slots: `dockBar`, `confirmCard`, `cartSheet`, `venue3D`,
  `legend`. New chrome switches for the dock bar, confirm card, 3D chrome and
  hold pill.
- New callbacks: `onSectionFocused`, `onSeatSelected`, `onSeatRemoved`,
  `onSeatViewOpened`, `onContinue`, `onThemeResolved`.

**Package**

- `lib/seatlayer.dart` exports explicit `show` lists. Anything not listed is an
  implementation detail.
- The 1.18 MB offline fixture (`seatlayer.js`, `demo.html`, `index.html`) moved
  to `example/assets/` and out of the published archive. Production has always
  loaded the immutable hosted page.
- The example app opens on the live picker; the raw protocol-1 fixture is now
  `example/lib/offline_fixture_demo.dart`.
- Files split by concern, with a 1,500-line guard (`tool/check_file_sizes.dart`)
  and a test that runs it.
- Goldens in light and dark at 390×844 for every rebuilt widget.

**Breaking, within the 0.3 prerelease line**

- `SeatLayerPickerMobileTicketPanel`, `SeatLayerPickerTicketCard`,
  `SeatLayerPickerBestAvailable`, `SeatLayerPickerMobilePanelSafeArea` and the
  deprecated `seatLayerBundledWebVersion` are removed.
- `SeatLayerPickerSelectionTray`, `SeatLayerPickerBestAvailablePanel` and
  `SeatLayerPickerPriceRail` remain as deprecated typedefs until 0.4.

## 0.3.0-dev.4

- Pins the hosted runtime to `seatlayer-js@0.70.0`. Views load
  `https://cdn.seatlayer.io/seatlayer-js@0.70.0/mobile.html`, which advertises
  protocol `1..2` and every capability `SeatLayerBridgeProfile.picker()`
  requires, so the picker handshake still agrees on protocol 2.
- The offline demo/test fixture stays on `seatlayer-js@0.68.0`. It is a
  byte-verified vendored artifact, not a version string, and re-vendoring it is
  a separate change from moving production onto a new hosted runtime.

## 0.3.0-dev.3 (unreleased)

- Retains the hosted `seatlayer-js@0.68.1` runtime and vendors the combined
  public-bootstrap/mobile-picker fixture built from runtime commit
  `d71db683520bf6c7034208e10806d59ddd7c5c0d` (sha256
  `cadcfaea8ebda2dbef175be4462673c64ba6fe79e5e856c9b466941088a5056b`).
- Adds a machine-readable runtime provenance record and a byte-level test that
  verifies public `/bootstrap` plus all required picker, 3D, and seat-view
  capabilities.
- Documents `publicKey` for public Platform events while retaining the async
  buyer-access provider for private, presale, partner, and channel inventory.

## 0.3.0-dev.2

- Corrects the published README and install guidance after the successful
  `0.3.0-dev.1` prerelease release. Runtime and Dart behavior are unchanged.

## 0.3.0-dev.1

- Pins production views to the verified `seatlayer-js@0.68.1` mobile runtime,
  including native interaction blocking, responsive section drill-down,
  smoother WebKit pan/pinch gestures and the negotiated 3D control bridge.
- Keeps the mobile multi-ticket sheet at a stable responsive height, scrolls
  ticket rows internally and pins the total, checkout and attribution region.
- Adds complete light and dark picker/map theme presets for turnkey and custom
  component compositions.
- Adds the adaptive turnkey picker and public component kit.
- Matches the web mobile checkout strip across empty, selected and held states.
- Rebuilds seat confirmation around authored Section / Row / Seat identity,
  category color, price, ticket choices and accessibility/view disclosures.
- Replaces the horizontal chip cart with reusable vertical ticket cards.
- Keeps the compact attribution at the visual bottom without stacking the full
  gesture inset beneath it, and releases its height when branding hides it.
- Adds explicit callback-gated seat-view and venue-3D action widgets; unsupported
  actions remain hidden until the bridge advertises a real capability.
- Documents the web-to-mobile parity ledger and cross-SDK replication order.

## 0.2.2

- Documentation only. Refreshes the README, adds frequently asked questions,
  and clarifies link text. No Dart API, runtime, or behaviour changes.

## 0.2.1

- Updates the production hosted mobile runtime and explicit offline fixture to
  the verified, promotable `seatlayer-js@0.67.14` release.
- Improves package discovery around Flutter seat maps, seating charts, seat
  pickers, and reserved-seating integrations without changing the public Dart
  API.
- Adds a real iOS Simulator capture, a focused integration FAQ, and descriptive
  links to the Flutter documentation, pub.dev package, SeatLayer website, and
  clearly labelled browser buyer demo.

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
