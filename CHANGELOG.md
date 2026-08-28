# Changelog

## 0.3.1

Defects found on a phone, the three the load measurements said the SDK owned,
and the additive native-chrome contract that came out of them: the chart-load
record, the seat-view panorama's words, and the floor strip's confirmed shape.

**The system bars are the picker's**

- The clock, the wifi glyph and the battery are drawn by the operating system
  on a surface the picker owns, and nothing was telling it which side that
  surface was on: a dark picker kept the platform's dark glyphs, which is
  near-black on near-black. The drop-in now annotates `SystemUiOverlayStyle`
  from the resolved palette — iOS `statusBarBrightness` names the ground,
  Android `statusBarIconBrightness` names the glyphs, and both are filled in —
  so it follows an `auto` flip live and goes dark for the immersive 3D scene
  whatever side the picker is painted on. The page's own top safe-area strip
  follows the scene palette with it, which closes a residual defect from the
  release before: a white band above a black 3D view.
- `SeatLayerPickerChromeOptions.manageSystemOverlays` (default true) opts out a
  host that owns its own bars, and `seatLayerPickerOverlayStyle` is exported so
  it can still ask what the picker would have set.

**The dock's section name keeps its letters**

- `Sponsor Ta… · 72 left` was two defects. The name sat in a `Flexible` next to
  a `Spacer`, and two flex-1 children split the free space, so the name was
  capped at half the bar and cut while there was still room to its right. And
  nothing to its right ever gave way.
- The row is planned before it is drawn. A measured ladder gives way right to
  left — `72 left` becomes `72`, then goes; the Venue button drops to its
  chevron, keeping its tooltip — and the first rung whose leftover holds the
  whole name wins. Only when the narrowest rung still cannot hold it does the
  name take a second line at 12 sp, and only then can it ellipsize. The step
  controls never give way: they are how the buyer moves. Goldens at 390 and
  320.

**One load time covering the whole open**

- The runtime's chart-load beacon now reaches the host (`evt
  telemetry.chartLoad`, capability `chart-load-trace-v1`) and is decoded whole
  into `SeatLayerChartLoadTrace` — the API, availability, normalise, renderer
  and paint spans, the seat and floor counts, the chart's cache result, and the
  three document-relative spans `documentMs` / `handshakeMs` / `bootMs`. Fields
  this release does not model are kept verbatim on `raw`, so a runtime that adds
  one is readable without an SDK release.
- It is merged with the SDK's own measurement rather than surfaced alone. The
  runtime's clock starts at its own document; the SDK's `ReadyInfo` starts when
  the view armed its handshake; neither is what the buyer felt.
  `SeatLayerChartLoad.tapToReadyMs` starts at the picker's **mount** — the frame
  after the tap — so it is the same T0 whether or not the page was prewarmed,
  and `hostMs` is that span less the page's own `bootMs`. On the reference
  app's 3,513 ms cold open that outside-the-page share was 2,495 ms.
- Reached as `SeatLayerPickerController.onChartLoad` (a broadcast stream) or
  `SeatLayerPickerCallbacks(onChartLoad:)`. Fires once per render attempt,
  success or failure. **Nothing is logged and nothing is sent anywhere** — it is
  a hook for the host's own analytics.

**The seat-view panorama's words are native**

- The 3D scene went native-clean a round ago; the 2D `View from here` fallback
  did not. It kept drawing its own header line, disclosure caption and `PREVIEW`
  badge over the picture, and on a phone all three landed under the native price
  rail — two owners drawing chrome in the same band.
- Against a runtime advertising `native-seat-view-chrome-v1` the picker adds
  `seatViewTitle`, `seatViewCaption` and `seatViewBadge` to its init suppression
  and draws `SeatLayerSeatViewChrome` instead: a caption strip and disclosure
  badge in the picker's palette, clear of the rail and the dock. The words
  arrive already localized on `evt seatView.changed` and arrive again after a
  live language switch, so nothing is re-derived here; `SeatLayerSeatView.real`
  is what separates an authored capture of the seat from one the engine drew out
  of the venue's geometry, so the badge never has to be recognised by its
  translated word.
- Composable like every other part: `SeatLayerPickerBuilders(seatViewChrome:)`,
  `SeatLayerPickerChromeOptions(showSeatViewChrome:)` and
  `SeatLayerPickerStyles(seatViewChromeStyle:)`. It takes no touch — every
  gesture over the panorama is the panorama's.
- The CLOSE button is deliberately not suppressed. It is the buyer's only way
  out of a full-screen picture, and native chrome does not reach inside the
  panorama to offer one. An older runtime is asked to suppress nothing and keeps
  drawing its own, so the disclosure is on screen exactly once either way.

**Floors read in the order the venue has them**

- The runtime confirmed the floor contract and one negative with it: there is no
  `level` field. The strip had been sorting floors top-down by it whenever every
  floor carried one, which no floor does — dead by construction, and a sort that
  would reorder half a venue the day a chart carried a partial level. Removed;
  the snapshot's order is the venue's order, stage upward.
- The "All floors" chip now needs both halves of the runtime's word: the
  `floor-stack-v1` capability and a reported `floorMode`. A chip drawn on one
  half alone would send `'all'` to a runtime with no such floor.
- `SeatLayerPickerMapState.floorLabelStyle` is read alongside, for a host
  drawing a strip of its own that wants to match the stacked view's badges.
- `SeatLayerPickerStrings.allFloors` remains the one native chrome string with
  no runtime dictionary key to take its translation from, and is now recorded as
  an ask rather than as folklore. It keeps its English wording in every locale
  until the key exists; override it for a multi-floor venue outside English.

**Prewarm**

- `SeatLayerPicker.prewarm()` loads the immutable runtime page from the screen
  the buyer is already on, so a picker opened later mounts onto a page that is
  already up. No event, no buyer token and no session: all of that still
  travels at `init`. A page with no view yet still emits its bridge `hello`, so
  the warm page installs the channel itself and buffers what it hears; the
  claiming view arms its handshake first and replays the buffer, and the bridge
  sees the same messages in the same order it would have seen live.
- Idempotent. An unclaimed page expires (default five minutes) and is dropped
  on memory pressure, blanked to `about:blank` before it is dereferenced.
  `SeatLayerPicker.cancelPrewarm()` gives it back early.
- **Measured on a reference app**, iOS Simulator, debug build. Three runs each,
  same warm app process, tap to `sys.ready`, with a ten-second dwell on the
  event screen — long enough that the prewarmed page is the re-loaded one,
  which is the ordinary case.

  | | run 1 | run 2 | run 3 | median |
  | --- | ---: | ---: | ---: | ---: |
  | without `prewarm()` | 3,182 | 3,610 | 3,262 | **3,262 ms** |
  | with `prewarm()` | 2,925 | 2,061 | 2,192 | **2,192 ms** |

  **1,070 ms off the median open, 33%.** The bridge-side span — the SDK's own
  `ReadyInfo.timeToReadyMs` — moves 2,104 ms → 1,082 ms, so the saving is where
  the diagnosis said it was: the WebView, not the runtime.

  The first version of this shipped a warm *session* rather than a warm
  WebView, and the reference app caught it: a page left for a minute
  had already emitted `sys.error {code: 'host_timeout'}`, so the picker opened
  on an error. A page past
  `seatLayerPrewarmHandshakeWindow` is re-loaded when it is claimed.

**`auto` follows the application, not only the device**

- `SeatLayerThemeMode.auto` read `MediaQuery.platformBrightness`, which is the
  device's setting and not the buyer's: an app with its own dark-mode switch
  sits in dark mode on a light phone all the time, and the picker opened white
  inside it. `auto` now asks `Theme.of(context).brightness` first — what that
  switch moves, and what a Cupertino theme reports too — and falls back to the
  device only where there is no Material or Cupertino theme to ask. Precedence:
  an explicit `themeMode`, then the host's theme, then the device. Both
  readings are live.

**One call for an app that already has a palette**

- `SeatLayerPickerThemeData.fromColorScheme(scheme)` and
  `SeatLayerPickerThemeData.of(context)` map a Material palette onto the whole
  picker: `primary`/`onPrimary` to the accent and its ink, so `Continue`,
  `Select`, `Find N best seats`, the hold pill and the Map/3D control all carry
  the brand at once; `surface`, `onSurface`, `onSurfaceVariant`,
  `outlineVariant` and `error` to the grounds, ink, hairlines and failures.
  `.of(context)` takes the theme's body typeface with the scheme.
- Ticket categories are deliberately untouched. The legend chips, the dock's
  section dot and the seats stand for prices, and a brand-coloured dot would
  disagree with the chip it is supposed to match.
- A `ColorScheme` names no recessed ground that works on both sides, so the
  page under the chrome is derived as one small step toward black. Every role
  is overridable.

**Multi-floor venues**

- `SeatLayerFloorStrip` is a chip row — `All floors`, then each floor top down
  — under the price rail on the phone and beside the map when wide, reported in
  the viewport insets with the rail so a focused section is still framed clear
  of it. Hide it with `SeatLayerPickerChromeOptions(showFloorStrip: false)`,
  replace it through `SeatLayerPickerBuilders(floorStrip:)`, restyle it with
  `SeatLayerPickerStyles(floorStripStyle:)`.
- Everything it draws comes from the snapshot, and it draws nothing it was not
  told about: no chrome below two floors, and no all-floors chip unless the
  runtime reports a `floorMode`. `SeatLayerPickerMapState.floorMode`,
  `FloorInfo.level` and `SeatLayerPickerController.showAllFloors` are the
  additive, capability-gated model behind it.
- `SeatLayerPickerStrings.allFloors` is the one string the runtime has no
  dictionary entry for and keeps English in every locale until it does.

## 0.3.0

Phone parity round. The native chrome is rebuilt against the web picker's
measured phone layout, and the package is prepared for a stable 0.3.0.

**Runtime pin**

- The hosted runtime moves to `seatlayer-js@0.71.3`. Views load
  `https://cdn.seatlayer.io/seatlayer-js@0.71.3/mobile.html`, which advertises
  protocol `1..2` plus the `native-chrome-contract-v1` and `viewport-insets-v1`
  capabilities this release consumes. The offline demo/test fixture stays on its
  byte-verified vendored `seatlayer-js@0.68.0` artifact — re-vendoring it is a
  separate change from moving production onto a new hosted runtime.

**Native chrome contract** (capability-gated at the handshake, so an app pinned
to an older hosted runtime behaves exactly as it did before)

- `SeatLayerViewportInsets` and
  `SeatLayerPickerController.setViewportInsets` report how much of the map
  surface native chrome is covering, so the runtime frames a section, the venue
  overview and a best-available result into the part the buyer can see. It is a
  framing inset, not a clip: the venue still draws and pans under the chrome.
  The drop-in reports its own rail and dock;
  `SeatLayerPickerScope.setViewportInsets` does the same for a composed layout.
  What the runtime is honouring comes back as
  `SeatLayerPickerMapState.viewportInsets`.
- `setThemeMode` takes the map's new ground alongside the mode, so a device
  appearance flip re-inks the drawn venue in place — keeping the selection, the
  focused section and the camera. Without it the boot ground pinned the canvas
  for the widget's life.
- `SeatLayerCheckoutLineItem` carries `seatId`, `sectionLabel`, `rowLabel` and
  `seatNumber`. Best Available clears the renderer selection before it holds
  and a resumed hold was never in one, so those lines had no address to render;
  they now read `Choir · A · 9–10` instead of a category and a raw label.
- `SeatLayerPickerSectionSummary.dominantCategoryKey` binds the dock's section
  dot to the category rather than to a copied hex, so it agrees with the price
  legend through a recolour or a colourblind-safe repaint.

**Design system**

- `design/tokens.json` is the single, platform-neutral source for the picker's
  palettes, sizes, radii, elevations, type scale, motion table, haptic cues and
  default strings. `dart run tool/gen_tokens.dart` generates
  `lib/src/picker/picker_tokens.g.dart` from it, the theme presets, layout,
  motion, haptics and strings read that generated file, and
  `test/design_tokens_test.dart` fails if the two ever disagree or if the
  generated file is stale. The file is written to move to the runtime
  repository and feed Swift, Kotlin and TypeScript generators next.
- `design/components.md` documents every picker widget — inputs, states,
  anatomy in tokens, style slots, callbacks and bridge commands — for the iOS,
  Android and React Native ports.

**Styling**

- Buttons are no longer pills. Every action — `Continue`, `Hold seats &
  checkout`, `Cancel`, `Select`, `Find N best seats`, `View from here`, `See it
  in 3D`, `Open venue 360°`, `Back to venue`, `Apply filters`, `Try again` —
  rounds to the new `radius.button` (8), which is what the web picker's own
  buttons measure, instead of Material's default stadium.
  `SeatLayerPickerThemeData(buttonRadius:)` moves them all at once and is its
  own role, so `radius:` still rounds cards and sheets without growing pill
  actions. The hold pill, the price-legend chips and the Map/3D segmented
  control stay true pills (`radius.pill` / `radius.chip`).
- `SeatLayerPickerStyles` adds per-element style slots to
  `SeatLayerPickerThemeData` (`primaryButtonStyle`, `secondaryButtonStyle`,
  `continueButtonStyle`, `iconButtonStyle`, `chipShape`, `legendChipStyle`,
  `dockBarStyle`, `confirmCardStyle`, `sheetStyle`, `headerStyle`,
  `pillStyle`), so one control can be restyled without replacing the widget
  that draws it. Every widget owning a slot also takes a `style:` override.

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
