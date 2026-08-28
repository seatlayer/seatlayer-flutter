# SeatLayer Flutter Seat Map SDK for Reserved Seating

[![CI](https://github.com/seatlayer/seatlayer-flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/seatlayer/seatlayer-flutter/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/seatlayer.svg)](https://pub.dev/packages/seatlayer)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.19-02569B.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.4-0175C2.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/license-MIT-111827.svg)](LICENSE)

The official SeatLayer Flutter package for adding a complete reserved-seating
buyer flow to iOS and Android apps. The turnkey picker renders live inventory,
native mobile controls, selection and validation, temporary holds, Best
Available and a typed checkout handoff. A raw map/controller API remains
available for applications that deliberately own every part of the UI.

[Flutter documentation](https://docs.seatlayer.io/buyer-sdk/flutter/) ·
[SeatLayer](https://seatlayer.io/) ·
[Web buyer demo](https://app.seatlayer.io/demo/play/grand-theatre) ·
[Android SDK](https://github.com/seatlayer/seatlayer-android) ·
[React Native SDK](https://github.com/seatlayer/seatlayer-react-native)

> **Release status:** `0.2.2` remains the published stable package.
> [`0.3.0-dev.2`](https://pub.dev/packages/seatlayer/versions/0.3.0-dev.2)
> is the published prerelease containing the `SeatLayerPicker` API described
> below. Use that exact prerelease while validating; do not point a production
> app at a moving Git branch.

## Install

Install the published picker prerelease explicitly:

```bash
flutter pub add seatlayer:0.3.0-dev.2
```

The stable `0.2.2` package remains available through `flutter pub add
seatlayer`, but does not contain this picker release. A Git commit pin is only
needed for unpublished development work:

```yaml
dependencies:
  seatlayer:
    git:
      url: https://github.com/seatlayer/seatlayer-flutter.git
      ref: <exact-40-character-commit>
```

Then import the public library:

```dart
import 'package:seatlayer/seatlayer.dart';
```

## Two ways in

```mermaid
flowchart TD
  A["SeatLayerConfiguration<br/>event + publishable key"] --> B{"How much layout<br/>do you want to own?"}
  B -->|"None"| C["SeatLayerPicker<br/>drop-in"]
  B -->|"All of it"| D["SeatLayerPickerScope"]
  D --> E["SeatLayerChart"]
  D --> F["SeatLayerPickerHeader<br/>SeatLayerPriceLegend<br/>SeatLayerDockBar"]
  D --> G["SeatLayerConfirmCard<br/>SeatLayerCartSheet<br/>SeatLayerVenue3D"]
  C --> H["onCheckout(handoff)"]
  E --> H
  F --> H
  G --> H
  H --> I["Your backend books the hold"]
```

### Recipe 1 — drop-in

One widget. The complete buyer flow, on the approved phone UX by default.

```dart
SeatLayerPicker(
  configuration: SeatLayerConfiguration(
    event: 'ev_your_event',
    publicKey: 'pk_test_your_key',
  ),
  themeMode: SeatLayerThemeMode.auto,
  onCheckout: (handoff) => bookOnYourBackend(handoff.holdId),
  onClose: () => Navigator.of(context).pop(),
)
```

### Recipe 2 — composable

Place a scope, then arrange the parts yourself. Every widget below reads its
state from the scope; none of them needs the drop-in layout.

```dart
SeatLayerPickerScope(
  configuration: configuration,
  themeMode: SeatLayerThemeMode.auto,
  child: Column(
    children: [
      SeatLayerPickerHeader(compact: true, onClose: close),
      Expanded(
        child: Stack(
          children: [
            const Positioned.fill(child: SeatLayerChart()),
            const Positioned(top: 8, left: 0, child: SeatLayerPriceLegend(compact: true)),
            const Positioned.fill(child: SeatLayerPickerMapControls(compact: true)),
            const Positioned(left: 0, right: 0, bottom: 0, child: SeatLayerDockBar()),
            const Positioned.fill(child: SeatLayerVenue3D()),
          ],
        ),
      ),
      SeatLayerCartSheet(
        expanded: expanded,
        onExpandedChanged: (value) => setState(() => expanded = value),
        onCheckout: (handoff) => bookOnYourBackend(handoff.holdId),
      ),
    ],
  ),
)
```

## Widget catalogue

| Widget | What it is | Standalone in a scope |
| --- | --- | --- |
| `SeatLayerPicker` | The drop-in buyer flow | n/a |
| `SeatLayerChart` | The drawn map (alias of `SeatLayerPickerMap`) | yes |
| `SeatLayerPickerHeader` | Event identity, hold pill, dismiss | yes |
| `SeatLayerPriceLegend` | Price chips that filter the map | yes |
| `SeatLayerDockBar` | Focused section, seats left, prev/next, Venue | yes |
| `SeatLayerFloorStrip` | Floor chips on a multi-floor venue | yes |
| `SeatLayerPickerMapControls` | Accessibility, fit, Map/3D in the corners | yes |
| `SeatLayerConfirmCard` | The phone's one-seat decision card | yes |
| `SeatLayerCartSheet` | Peek bar and content-height cart | yes |
| `SeatLayerCartList` | The dense ticket list with run folding | yes |
| `SeatLayerBestSeatsForm` | Two selects, a stepper, one action | yes |
| `SeatLayerBookButton` | The full-width checkout call to action | yes |
| `SeatLayerVenue3D` | Caption, seat stepper and exits over the 3D scene | yes |
| `SeatLayerPickerAccessibilityFilters` | Access needs and the colourblind palette | yes |
| `SeatLayerPickerTablePrompt` / `…GeneralAdmissionPrompt` | Quantity prompts | yes |
| `SeatLayerPickerScope` | The state every widget above reads | n/a |

## Design system

The picker's colours, sizes, radii, elevations, type scale, motion table,
haptic cues and default strings live in one platform-neutral file,
[`design/tokens.json`](design/tokens.json), and the component catalogue that
describes every widget in terms of those tokens lives in
[`design/components.md`](design/components.md). The catalogue is written for a
Swift, Kotlin or React Native engineer reproducing this design, and it uses the
Dart API's names throughout.

`lib/src/picker/picker_tokens.g.dart` is **generated** from the JSON and must
not be hand-edited:

```bash
dart run tool/gen_tokens.dart          # sync:tokens — regenerate
dart run tool/gen_tokens.dart --check  # fail if the generated file is stale
```

The theme presets, `SeatLayerPickerLayout`, `SeatLayerPickerMotion`, the haptic
map and `SeatLayerPickerStrings` all read that file, and
`test/design_tokens_test.dart` asserts them against the JSON as well as running
the staleness check, so the two cannot drift.

## Customisation

The zero-configuration path is the approved phone experience. Everything about
it is still yours to change.

**Hide a part.** Every piece of chrome has a switch:

```dart
options: const SeatLayerPickerOptions(
  chrome: SeatLayerPickerChromeOptions(showDockBar: false),
),
```

**Replace one part, keep the rest.** A builder receives the live state and the
widget the drop-in would have rendered:

```dart
builders: SeatLayerPickerBuilders(
  cartSheet: (context, part) => MyOwnSheet(state: part.state, fallback: part.defaultChild),
),
```

**Restyle one element, keep the widget.** Every control the picker draws has a
style slot on the theme, so a single button can change shape without replacing
the widget around it. The picker's buttons round to `radius.button` (8 pt, the
web picker's own), so turning the peek bar's `Continue` into a pill is three
lines:

```dart
theme: SeatLayerPickerThemeData.light(
  styles: SeatLayerPickerStyles(
    continueButtonStyle: FilledButton.styleFrom(shape: const StadiumBorder()),
  ),
),
```

Every button moves together through `buttonRadius`, which is its own role
rather than a fraction of `radius`: `SeatLayerPickerThemeData.light(radius: 20)`
rounds the cards and sheets without growing pill actions.

The slots are `primaryButtonStyle`, `secondaryButtonStyle`,
`continueButtonStyle`, `iconButtonStyle`, `chipShape`, `legendChipStyle`,
`dockBarStyle`, `confirmCardStyle`, `sheetStyle`, `headerStyle` and
`pillStyle`. Button slots take a Material `ButtonStyle`; surface slots take a
`SeatLayerSurfaceStyle` (colour, shape, elevation, padding, type). Every widget
that owns a slot also accepts a `style:` parameter, which wins over the theme
for that one instance:

```dart
SeatLayerDockBar(style: SeatLayerSurfaceStyle(shape: const RoundedRectangleBorder()))
```

**Retune the sizes.** The spec's numbers are defaults, not constants:

```dart
theme: const SeatLayerPickerThemeData.light(
  layout: SeatLayerPickerLayout(dockBarHeight: 60, sheetMaxHeightFraction: .5),
),
```

**Translate or reword anything.** Every buyer-facing string is an override:

```dart
options: SeatLayerPickerOptions(
  strings: SeatLayerPickerStrings(
    holdAndCheckout: 'Réserver et payer',
    seatsLeft: (count) => '$count restants',
  ),
),
```

**Or take the translations SeatLayer already ships.** The drawn map speaks
thirty-seven languages; `SeatLayerPickerStrings.forLocale` gives the native
chrome around it the same words, from the same reviewed dictionaries:

```dart
options: SeatLayerPickerOptions(
  strings: SeatLayerPickerStrings.forLocale(Localizations.localeOf(context)),
),
```

It resolves by language, and by script for Chinese. An untranslated locale —
and any single entry the runtime has no wording for — keeps its English
default, and the result is an ordinary `SeatLayerPickerStrings`, so you can
still override any entry on top of it.

**Hear about every action.** All callbacks are optional:

```dart
callbacks: SeatLayerPickerCallbacks(
  onSectionFocused: (id) => analytics.log('section', id),
  onSeatSelected: (seat) => analytics.log('seat', seat.label),
  onThemeResolved: (brightness) => debugPrint('picker is $brightness'),
  onContinue: (handoff) => analytics.log('checkout', handoff.holdId),
),
```

## Turnkey picker quick start

This is the default integration. `SeatLayerPicker` supplies the adaptive
layout, event identity, price and accessibility filters, section/floor/map
controls, seat-tier confirmation, GA and variable-table prompts, Best
Available, selection tray, hold countdown, attribution, one test-event badge,
recoverable action errors, authored/chart-derived seat views, real venue 3D and
the checkout CTA.

```dart
SeatLayerPicker(
  configuration: SeatLayerConfiguration(
    event: 'ev_your_event_key',
    publicKey: 'pk_test_your_public_key',
  ),
  onCheckout: (handoff) {
    openCheckout(holdId: handoff.holdId);
  },
)
```

The picker fills the bounded space provided by its parent. Use it as an
`Expanded` child or on a full page; do not put its map inside a competing
gesture-driven `ListView` or `SingleChildScrollView`.

### Multi-floor venues

A theatre stacked three levels deep drawn all at once is a picture of a
building, not a plan of one. `SeatLayerFloorStrip` is a chip row —
`All floors`, then each floor top down — placed under the price rail in the
drop-in and reported in the viewport insets with it, so the runtime keeps
framing sections clear of it.

It is entirely driven by the snapshot and **renders nothing it was not told
about**: no chrome on a venue with fewer than two floors, and no `All floors`
chip unless the runtime reports which floor mode it is in. Hide it with
`SeatLayerPickerChromeOptions(showFloorStrip: false)`, replace it through
`SeatLayerPickerBuilders(floorStrip: ...)`, restyle its chips with
`SeatLayerPickerStyles(floorStripStyle: ...)`, or place
`const SeatLayerFloorStrip()` yourself in a composed layout.

`SeatLayerPickerStrings.allFloors` is the one string with no runtime
translation yet, so it stays English until the runtime dictionaries carry one;
override it if you ship a multi-floor venue in another language.

### Prewarm from the event screen

Opening the picker costs a WebView process start and a document fetch before
the runtime has said a word — and all of it can happen while the buyer is
still reading the event page. Call `SeatLayerPicker.prewarm()` from the screen
they are already on:

```dart
class _EventPageState extends State<EventPage> {
  @override
  void initState() {
    super.initState();
    SeatLayerPicker.prewarm(); // the buyer is reading; start the page now
  }
  // …
}
```

The next `SeatLayerPicker` mounts onto that WebView instead of starting one.
No event, no buyer token and no session are involved: only the immutable
runtime page is loaded, and everything about the booking still travels at
`init` when the picker opens.

**What is kept is the WebView, not a live session.** The runtime page starts
its own clock when it loads and gives up on the host after ten seconds, so a
page the buyer left sitting is re-loaded when the picker claims it — a cache
hit — while the web content process, the expensive half, is already up. A
buyer who taps within a few seconds gets the loaded page and its `hello` too,
replayed to the bridge in order, so the handshake is exactly the one it would
have had.

It is idempotent, so calling it on every build of the event screen is fine.
An unclaimed page is thrown away after five minutes (`ttl:`), and immediately
if the platform reports memory pressure — a head start must never be what gets
your app killed. `SeatLayerPicker.cancelPrewarm()` gives it back early.

### Performance telemetry

The runtime measures its own load and hands the same beacon to you. The SDK
measures the half the page cannot see — WebView construction, process spin-up
and whatever your app did between mounting the picker and the page existing —
and gives you both in one object:

```dart
SeatLayerPicker(
  configuration: configuration,
  onCheckout: _checkout,
  callbacks: SeatLayerPickerCallbacks(
    onChartLoad: (load) {
      analytics.track('seatmap_open', <String, Object?>{
        'tapToReadyMs': load.tapToReadyMs, // the whole wait, from the tap
        'hostMs': load.hostMs,             // the part outside the page
        'bootMs': load.trace.bootMs,       // the page's whole life
        'documentMs': load.trace.documentMs,
        'renderMs': load.trace.ms,
        'outcome': load.trace.outcome,
        'bundle': load.trace.bundle,
      });
    },
  ),
)
```

`SeatLayerPickerController.onChartLoad` is the same record as a broadcast
stream, for a composed layout that drives its own controller.

`tapToReadyMs` starts when the picker was **mounted** — the frame after the
buyer's tap — and ends when the runtime reported the chart ready. It is the
same T0 whether or not the page was prewarmed, so a prewarm shows up as a
smaller number rather than as a hidden one. `hostMs` is that span less the
page's own `bootMs`: on the pilot's 3,513 ms cold open it was 2,495 ms, more
than two thirds of the wait and entirely outside the runtime.

Everything else on `load.trace` is the runtime's own beacon — the API,
availability, normalise, renderer and paint spans, seat and floor counts, the
chart's cache result and the negotiated protocol. Fields this SDK release does
not model are kept verbatim on `load.trace.raw`, so a runtime that adds one
does not need an SDK release to be readable.

It fires once per render attempt, success **or** failure, and it fires even
where the runtime's own beacon deliberately never reaches the network. It
requires a runtime advertising `chart-load-trace-v1`; an older one simply never
calls back. **The SDK logs nothing and sends nothing anywhere** — this is a
hook for your analytics, and nothing more.

Pan and pinch frames are rendered entirely inside the chart. They do not emit
full picker snapshots or rebuild Flutter chrome on every touch frame; Flutter is
notified only when a serializable state such as the active zoom rung actually
changes. The SDK also disables the platform WebView's document zoom,
overscroll/bounce and edge glow, while isolating the map in its own repaint
boundary. Hosts do not need gesture workarounds or app-specific scroll code.

On a phone, the turnkey widget deliberately follows the web picker's map-first
information hierarchy: a compact event header, one concise price rail, the map,
and a 50-logical-pixel ticket-dock control row. Its bottom spacing is calculated
from the remaining `MediaQuery` inset: gesture-style insets use a compact
clearance in both collapsed and expanded states, while larger system-navigation
bars are always kept clear. Required attribution is a small content-sized footer;
when the API hides it, it reserves no layout height. The dock expands for Best
Seats, selected tickets and checkout, and automatically opens after a new
selection. Once tickets exist, the expanded sheet keeps a stable responsive
height: only the ticket rows scroll, while the total, checkout action and
required attribution remain pinned. Adding more tickets therefore never keeps
pushing the map upward. The SDK does not add a second section rail above the map. Zoom
in/out, fit, Map/real-3D, rotate/move and colorblind-safe controls stay
available as compact floating buttons. Best Seats uses touch-friendly selector
rows that open mobile choice sheets instead of cramped desktop dropdown menus.

`SeatLayerPickerPage` leaves the bottom inset to the ticket dock, so a
full-screen integration does not append a second empty safe-area strip. For a
manual composition, `SeatLayerPickerMobileTicketPanel.bottomSafeArea` supports
`adaptive` (the default), `full`, and `none`; choose `none` only when an ancestor
already owns the bottom spacing. Choose `full` only when the host requires every
logical pixel of the reported inset to remain empty. No fixed device height or
app-specific bottom spacer is required.

The usual display controls do not require a custom layout:

```dart
SeatLayerPicker(
  configuration: configuration,
  options: const SeatLayerPickerOptions(
    enable3D: true,
    enableSeatView: true,
    max3DSeats: 30000, // optional; omit for the device-aware SDK default
    chrome: SeatLayerPickerChromeOptions(
      showHeader: true,
      showPriceRail: true,
      showZoomControls: true,
      showViewModeControl: true,
      showColorblindControl: true,
    ),
  ),
  theme: const SeatLayerPickerThemeData.light(
    accent: Color(0xFFE54558),
    onAccent: Colors.white,
    radius: 14,
  ),
  onCheckout: openCheckout,
)
```

`SeatLayerPickerChromeOptions` controls only the turnkey composition. A custom
composition can place the same public controls anywhere. Attribution is not a
host visibility switch: the API-provided `branding.attributionRequired` value
is authoritative.

Venue 3D is a real, lazy-loaded WebGL scene, not the legacy isometric canvas
projection. The base map stays interactive while the scene module loads and
the SDK crossfades into it. After the first build, the scene stays mounted but
idle while the buyer returns to the map, so repeated Map/3D comparison is
instant and never churns the mobile WebGL context. Unsupported devices keep the
complete 2D flow and do not show a dead control. `enable3D`, `enableSeatView`
and `max3DSeats` let a host disable or constrain immersive rendering without
changing its layout.
Picker cards, ticket-dock changes, cart rows and immersive surfaces use one
short motion language and honor the platform reduced-motion preference.

### One call for an app that already has a palette

If your app has a `ColorScheme`, hand it over and the whole picker is branded:

```dart
SeatLayerPicker(
  configuration: configuration,
  theme: SeatLayerPickerThemeData.of(context), // or .fromColorScheme(scheme)
  onCheckout: openCheckout,
)
```

`primary`/`onPrimary` become the accent and its ink, so `Continue`, `Select`,
`Find N best seats`, the hold pill and the Map/3D control all carry your brand;
`surface`, `onSurface`, `onSurfaceVariant`, `outlineVariant` and `error` become
the picker's grounds, ink, hairlines and failures. `.of(context)` takes your
theme's body typeface with the scheme. Every role has a named override.

**Ticket categories are deliberately left alone.** The price chips, the dock's
section dot and the seats themselves carry the organizer's categories, which
mean a price — recolouring them to your brand would make the dot disagree with
the chip it matches.

Because a scheme is a complete ground palette, this pins the picker to the side
that scheme is on — which is what you want, since it came from your theme, and
`.of(context)` therefore follows your own dark-mode switch on rebuild.

### Branding, and which constructor follows the device

**Brand with the default constructor.** It sets only the roles you name, so
every ground role still comes from `themeMode` — and `SeatLayerThemeMode.auto`
follows the device live, chrome and drawn map together:

```dart
SeatLayerPicker(
  configuration: configuration,
  themeMode: SeatLayerThemeMode.auto,
  theme: const SeatLayerPickerThemeData(accent: Color(0xFFE54558)),
  onCheckout: openCheckout,
)
```

`SeatLayerPickerThemeData.light()` and `.dark()` are complete presets, not just
white or black Flutter panels: each also sends a contrast-paired
`SeatLayerMapThemeData` to the renderer for the canvas background, row labels,
free text and the selection ring.

**A preset pins the mode.** Because it supplies a whole explicit ground
palette, and explicit roles win over the resolved mode, `themeMode: auto` with
`.light()` never goes dark — the device flip changes nothing on screen. Reach
for a preset when you *want* one fixed side, and drive it yourself if you want
both:

```dart
final pickerTheme = Theme.of(context).brightness == Brightness.dark
    ? const SeatLayerPickerThemeData.dark(accent: Color(0xFFFF5A6F))
    : const SeatLayerPickerThemeData.light(accent: Color(0xFFE54558));
```

`themeMode` is available on `SeatLayerPicker`, `SeatLayerPickerScope`,
`SeatLayerPickerPage` and `showSeatLayerPicker` alike.

**What `auto` follows, in order: your `themeMode` → your app's theme → the
device.** `auto` reads `Theme.of(context).brightness` first, so it tracks the
dark-mode switch inside your app — `MaterialApp(themeMode:)`, or a Cupertino
theme — which is the setting the buyer actually chose. Only when there is no
Material or Cupertino theme above the picker does it fall back to
`MediaQuery.platformBrightness`. Either reading is live: flip your app's theme
or the device's appearance and the chrome and the drawn map repaint together,
with no reload and no lost selection.

### The status bar is the picker's, too

The surface behind the device's status and navigation bars is the picker's, so
the picker dresses them: light glyphs on a dark picker, dark glyphs on a light
one, re-evaluated when `SeatLayerThemeMode.auto` follows a device flip, and
forced to the dark style for the immersive 3D scene whatever side the picker is
painted on. Nothing to call — it is on by default.

If your app owns the bars and sets one style for every screen, turn it off:

```dart
options: const SeatLayerPickerOptions(
  chrome: SeatLayerPickerChromeOptions(manageSystemOverlays: false),
),
```

`seatLayerPickerOverlayStyle(resolvedTheme)` is exported, so a host that opts
out can still ask the picker what the bars should look like.

The compact price rail follows the web picker: tapping one price selects that
single category and frames its seats; tapping the active price again returns to
all categories.

For public Platform inventory, register the exact hosted renderer origin
`https://cdn.seatlayer.io` on the matching `pk_test_` key. Runtime 0.70
bootstraps chart, availability, and public buyer access directly and keeps its
grant in memory; your backend is not on the chart-loading path.

For private, login-gated, presale, partner, or channel inventory, replace
`publicKey` with a provider that calls your backend and mints a short-lived
buyer session for that exact renderer origin:

```dart
final configuration = SeatLayerConfiguration(
  event: 'ev_private',
  buyerAccessTokenProvider: (request) =>
      buyerBackend.mintSeatLayerAccess(request.reason),
);
```

Never mint a buyer session with a SeatLayer secret inside the app.

This unreleased wrapper vendors a deterministic runtime fixture built from
SeatLayer runtime commit
`d71db683520bf6c7034208e10806d59ddd7c5c0d`. Its `assets/seatlayer.js`
SHA-256 is
`cadcfaea8ebda2dbef175be4462673c64ba6fe79e5e856c9b466941088a5056b`;
`assets/seatlayer.runtime.json` is the machine-readable provenance record. The
hosted production URL remains a separately deployed immutable artifact.

## Adaptive modal or full-screen picker

Use the presentation helper when seat selection starts from a ticket button:

```dart
final handoff = await showSeatLayerPicker(
  context,
  configuration: configuration,
  presentation: SeatLayerPickerPresentation.adaptive,
);

if (handoff != null) {
  openCheckout(holdId: handoff.holdId);
}
```

`adaptive` opens edge-to-edge on a compact phone and as a large constrained
dialog at 700 logical pixels or wider. Explicit
`SeatLayerPickerPresentation.fullScreen` and `.dialog` overrides are also
available. The helper returns `null` when the buyer closes it.

For an application-owned route:

```dart
SeatLayerPickerPage(
  configuration: configuration,
  onCheckout: (handoff) {
    openCheckout(holdId: handoff.holdId);
  },
)
```

The page and modal helper intercept close and system back, await picker
abandonment and release a picker-owned hold before removing the route. A hold
already handed to the host is not released.

## Build your own layout from public components

Applications can rearrange the same native components without rebuilding
inventory or hold logic:

```dart
final picker = SeatLayerPickerController();

SeatLayerPickerScope(
  controller: picker,
  configuration: configuration,
  child: Column(
    children: [
      const SeatLayerPickerPriceRail(),
      const Expanded(
        child: Stack(
          children: [
            SeatLayerPickerMap(),
            Positioned(
              top: 12,
              left: 12,
              child: SeatLayerPickerTestModeIndicator(),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: SeatLayerPickerZoomInButton(),
            ),
          ],
        ),
      ),
      const SeatLayerPickerSelectionTray(),
      const SeatLayerPickerAttribution(),
      SeatLayerPickerCheckoutBar(onCheckout: openCheckout),
    ],
  ),
)
```

Dispose a caller-created controller yourself. Before deliberately removing an
externally controlled inline picker, await `picker.close()` so a picker-owned
hold is acknowledged as released:

```dart
await picker.close();
picker.dispose();
```

Custom controls use typed picker-v2 methods rather than raw bridge strings:

```dart
await picker.selectObjects(['A-12', 'A-13']);
await picker.deselectCategories(['restricted-view']);
await picker.setSelectableObjects(['A-12', 'A-13', 'A-14']);
await picker.setMaxSelection(4);
await picker.resumeHold(restoredHoldId); // restored as host-owned
await picker.setBuyerView(SeatLayerBuyerView.venue3D);
await picker.showSeatIn3D(seat); // enter or retarget without remounting
await picker.openSeatView(seat); // authored 360° or chart-derived preview
await picker.set3DNavigationMode(SeatLayer3DNavigationMode.move);

// Required when custom native chrome covers the embedded map.
await picker.setMapInteractionEnabled(false);
try {
  await showMyNativeSeatPrompt();
} finally {
  await picker.setMapInteractionEnabled(true);
}
```

The public `0.3.0-dev` component baseline exports:

- `SeatLayerPickerAdaptiveLayout`
- `SeatLayerPickerMap`
- `SeatLayerPickerHeader`
- `SeatLayerPickerAttribution`
- `SeatLayerPickerTestModeIndicator`
- `SeatLayerPickerPriceRail`
- `SeatLayerPickerSectionNavigator`
- `SeatLayerPickerAccessibilityFilters`
- `SeatLayerPickerFloorSelector`
- `SeatLayerPickerMapControls`
- `SeatLayerPickerOverviewButton`
- `SeatLayerPickerZoomInButton`
- `SeatLayerPickerZoomOutButton`
- `SeatLayerPickerZoomToFitButton`
- `SeatLayerPickerViewModeButton`
- `SeatLayerPicker3DNavigationModeButton`
- `SeatLayerPickerColorblindButton`
- `SeatLayerPickerBestAvailable`
- `SeatLayerPickerBestAvailablePanel`
- `SeatLayerPickerMobileTicketPanel`
- `SeatLayerPickerSeatConfirmation`
- `SeatLayerPickerSeatViewButton`
- `SeatLayerPickerSeat3DButton`
- `SeatLayerPickerTablePrompt`
- `SeatLayerPickerGeneralAdmissionPrompt`
- `SeatLayerPickerSelectionTray`
- `SeatLayerPickerTicketCard`
- `SeatLayerPickerHoldCountdown`
- `SeatLayerPickerCheckoutBar`
- `SeatLayerPickerActionError`
- `SeatLayerPickerLoadingView`
- `SeatLayerPickerErrorView`
- `SeatLayerPickerEmptyView`

The default phone dock follows the web picker state hierarchy: with no
selection it shows the minimum price and the optional Best Seats accelerator;
with an unheld selection it shows ticket count, total and **Review**; with an
active hold it shows the same summary and **Continue**. Best Seats never crowds
the primary checkout path after a manual selection. The expanded cart uses
vertical `SeatLayerPickerTicketCard` rows with buyer labels, category/tier,
price, commercial warnings and a safe remove action. Ticket rows scroll inside
a stable-height viewport while Total, Continue and required attribution remain
visible. Manual layouts can set
`SeatLayerPickerMobileTicketPanel.ticketPanelHeight`; the responsive default is
still capped by `maxExpandedHeight`.

`SeatLayerPickerSeatConfirmation` consumes the authored section, row and seat
identity from the picker snapshot and self-wires View from here / See it in 3D
when the runtime advertises those capabilities. Set `showSeatView` or `show3D`
to false to hide either action, or pass `onViewFromSeat` / `onShow3D` to replace
the SDK action. The standalone `SeatLayerPickerSeatViewButton` and
`SeatLayerPickerSeat3DButton` follow the same rule: controller-backed by
default, callback-replaceable, and absent rather than decorative when the
capability is unavailable. Both inspection actions use the same neutral,
accent-tinted treatment and adapt from one row to a vertical stack in narrow
containers. The picker reserves its saturated accent for the primary Select
action; Cancel stays neutral, so host themes cannot accidentally introduce a
second competing Material color. The confirmation stays above the embedded
platform view until the immersive command confirms its destination is mounted.
The turnkey composition also sends `picker.setInteractionEnabled(false)` so
the runtime makes its own DOM inert for the whole native decision state, while
a Flutter `IgnorePointer` remains a visual-tree fallback. Both layers are
required: UIKit can hit-test WKWebView beneath composited Flutter chrome even
when the Flutter child itself ignores pointers. The originating tap therefore
cannot select a second seat underneath.

The lock applies only while native decision chrome is visible. As soon as the
prompt closes, the renderer again owns one-finger pan and two-finger pinch
inside the WebView. Do not wrap `SeatLayerPickerMap` in an app-level drag or
scale recognizer and do not stream touch coordinates over the bridge: doing so
competes with the renderer and breaks tap-versus-pan suppression. If a map can
tap but cannot pan after a prompt closes, update/fix the SeatLayer runtime; it
is not a Reference app page-level gesture concern.

Targeted parts of the turnkey layout can also be wrapped or replaced through
`SeatLayerPickerBuilders`. Every builder receives the immutable state, the
session controller and the default child. The overall adaptive layout, test
marker and required `Powered by SeatLayer` attribution deliberately have no
replacement builder: theme colors and typography remain customizable, but required native
chrome cannot be hidden by returning an empty widget. A fully manual
`SeatLayerPickerScope` composition must include both required components as the
example above does.

```dart
SeatLayerPicker(
  configuration: configuration,
  onCheckout: openCheckout,
  builders: SeatLayerPickerBuilders(
    header: (context, part) => DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black),
      child: part.defaultChild,
    ),
  ),
)
```

## Native chrome and one test-mode badge

The high-level picker negotiates protocol 2 and declares Flutter as the native
chrome owner. Its init contract sends:

```json
{
  "chrome": {
    "owner": "native",
    "seatTooltip": false,
    "testModeIndicator": false,
    "attribution": false
  }
}
```

The renderer therefore does not draw a second test badge. Flutter reads the
event mode from the atomic picker snapshot and renders exactly one
`SeatLayerPickerTestModeIndicator` plus one `Powered by SeatLayer` attribution
when `branding.attributionRequired` is true. On phones the small attribution is
in the expanded ticket-panel footer, matching the web picker; it never floats
over the map and is absent while the 50-pixel dock is collapsed. Neither item
can be replaced through `SeatLayerPickerBuilders`; both still inherit the
picker theme. A white-label entitlement may explicitly set
`attributionRequired: false`. A raw
`SeatLayerView` remains protocol 1; the host continues to own any surrounding
test-event chrome there.

## Read-only picker

Use `SeatLayerPickerOptions(readOnly: true)` to inspect a map, current
selection or restored hold without allowing inventory changes. The runtime
blocks canvas selection, while native seat/GA/table prompts, selection deletes,
Best Available and checkout are disabled. Category/accessibility filters,
section and floor navigation, view modes and zoom remain available.

The controller also enforces this boundary before sending a bridge command.
Direct selection, hold and checkout actions fail with a typed
`SeatLayerError` whose code is `read_only`, so a custom component cannot bypass
the UI guard.

## Checkout and hold security

The app selects and holds inventory. Your trusted backend inspects and books
the hold after payment or order validation.

`SeatLayerCheckoutHandoff` contains:

- opaque `holdId`;
- server expiry;
- currency;
- priced line items with object/category/tier identity; and
- a display total.

The ordinary native picker snapshot intentionally does **not** contain the
`holdId`; it exposes only whether a hold is active, its expiry and whether the
picker or host owns it. The capability crosses into Dart only at the checkout
handoff boundary.

- Never ship a SeatLayer secret in the app binary or WebView.
- Never put buyer tokens or hold ids in logs, analytics or URLs.
- Send the `holdId` only to your trusted checkout backend.
- Inspect the hold server-side and calculate the charge from server data.
- Reuse a stable host order id as the booking reference for safe retries.

Calling checkout transfers hold ownership to the host. Closing or disposing
the picker after that handoff must not release the hold. Before handoff, modal
close releases a picker-owned hold. Process termination cannot guarantee a
release, so the server TTL remains the final safety boundary.

The built-in retry path also acknowledges `picker.destroy` before replacing a
runtime that had reached Ready. A failed handshake has no live picker and
retries immediately.

If a turnkey `onCheckout` callback throws because host validation or navigation
failed, the picker automatically attempts
`picker.rejectHandoff {holdId}` before surfacing the original callback error.
The runtime releases only the exact hold most recently handed off by that
picker session; it cannot release an arbitrary resumed or host-owned hold. A
custom flow that calls `controller.checkout()` directly can perform the same
safe rollback explicitly:

```dart
final handoff = await picker.checkout();
try {
  await openCheckout(handoff);
} catch (_) {
  await picker.rejectCheckoutHandoff(handoff);
  rethrow;
}
```

`SeatLayerPickerOptions(initialHoldId: restoredHoldId)` always restores a
host-owned hold. Ownership is not caller-configurable, and picker cart controls
never alter or release that restored hold.

Continue with
[holds and secure server-side checkout](https://docs.seatlayer.io/buyer-sdk/holds-and-checkout/)
before connecting payment and booking.

## Advanced/raw seat map

Use `SeatLayerView` only when the application wants to own all buyer chrome,
selection presentation and hold orchestration. This is the stable `0.2.x`
surface and remains source-compatible in `0.3`.

```dart
class RawMap extends StatefulWidget {
  const RawMap({super.key});

  @override
  State<RawMap> createState() => _RawMapState();
}

class _RawMapState extends State<RawMap> {
  final controller = SeatLayerController();

  @override
  Widget build(BuildContext context) {
    return SeatLayerView(
      controller: controller,
      configuration: SeatLayerConfiguration(
        event: 'ev_your_event_key',
        publicKey: 'pk_test_your_public_key',
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

Raw commands include `hold`, `resumeHold`, `extendHold`, `release`,
`releaseLabels`, `bestAvailable`, `holdGA`, tier and selection controls,
floors, colorblind-safe mode, view modes and map zoom. Raw events remain
available as typed broadcast streams.

## Runtime and bridge architecture

Production views load an immutable HTTPS mobile document in
`webview_flutter`. Raw views request protocol 1. The complete picker requests
protocol 2 and fails clearly unless its runtime advertises all required
capabilities:

```text
picker-session-v2
picker-snapshot-v1
picker-actions-v1
native-picker-chrome-v1
checkout-handoff-v1
checkout-handoff-reject-v1
hold-ownership-v1
cart-line-remove-v1
table-quantity-v1
```

With the default `enable3D: true` and `enableSeatView: true`, the picker also
requires `venue-3d-v1`, `venue-3d-controls-v1` and `seat-view-v1`. Disabling an
optional feature removes its bridge requirement. This fails closed against an
old hosted runtime instead of showing a control that silently changes only the
2D projection or does nothing.

Picker state uses complete `seatlayer.picker.snapshot/1` replacements with a
session id and monotonically increasing revision. Dart ignores stale revisions
and serializes inventory-changing actions, including repeated checkout taps.
Private buyer tokens remain memory-only and never enter snapshots.

See [the mobile picker architecture and rollout](doc/mobile-picker-architecture-and-rollout.md)
for the exact bridge schema, commands, ownership rules and validation gates.

## Run the example

Without configuration, the example keeps the existing offline raw protocol-v1
fixture:

```bash
cd example
flutter run
```

Supply a controlled event to exercise the high-level picker:

```bash
flutter run --dart-define=SEATLAYER_EVENT=ev_your_test_event \
  --dart-define=SEATLAYER_PUBLIC_KEY=pk_test_your_public_key
```

During hosted-runtime development, override only the picker document being
validated:

```bash
flutter run \
  --dart-define=SEATLAYER_EVENT=ev_your_test_event \
  --dart-define=SEATLAYER_RUNTIME_URL=https://cdn.example/mobile.html
```

A runtime that is not published yet can be served from the host machine and
named the same way, which is how a bridge change is proved against a real app
before it ships:

```bash
# in the runtime checkout, after its CDN build
python3 -m http.server 8181 --directory cdn/dist/seatlayer-js@<version>

flutter run \
  --dart-define=SEATLAYER_EVENT=ev_your_test_event \
  --dart-define=SEATLAYER_RUNTIME_URL=http://localhost:8181/mobile.html
```

An iOS simulator and an Android emulator both reach the host machine's server.
The API answers according to the publishable key's registered origins, so the
local origin has to be registered on the key as well.

Omitting `SEATLAYER_RUNTIME_URL` uses the package's immutable runtime pin. A
development runtime must use an allowed origin for private buyer access; an
origin-bound token minted for `https://cdn.seatlayer.io` cannot be replayed on
an unrelated preview domain.

## Release path

The `0.3.0-dev.2` prerelease has completed this path:

1. push reviewed source changes to the Flutter GitHub branch;
2. pin an exact commit in the Reference app development app;
3. validate public/private access, section focus, reserved seats, Best
   Available, holds, expiry and close behavior on iOS and Android;
4. complete one safe hold → payment → server booking journey;
5. publish and revalidate the `0.3.0-dev.2` prerelease; and
6. publish stable `0.3.0` only after the documented exit gates pass.

The remaining cross-SDK work is to freeze the JSON fixtures and reproduce the
proven contract in React Native, iOS and Android SDKs.

## Platform support

The package declares iOS and Android support. It does not currently claim
Flutter web, macOS, Windows or Linux support.

## Development

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/gen_tokens.dart   # sync:tokens, after editing design/tokens.json
dart pub publish --dry-run
```

Verification must remain proportional to the changed behavior. Live checkout
and buyer credentials belong only in protected, manually dispatched end-to-end
validation.

## License

MIT © SeatLayer
