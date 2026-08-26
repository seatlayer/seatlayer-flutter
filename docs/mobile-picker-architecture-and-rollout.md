# SeatLayer Mobile Buyer Picker — Architecture and Rollout

Status: implementation baseline

Target Flutter release: `0.3.0`

Initial implementation branch: `codex/flutter-picker-0.3`

Last updated: 2026-08-26

## 1. Decision

SeatLayer will add a complete, responsive buyer picker to the Flutter SDK while
preserving the current low-level seat-map API.

The mobile product will expose two supported integration levels:

1. `SeatLayerPicker` — the batteries-included buyer journey. It owns loading,
   event identity, price and accessibility controls, section navigation, seat
   confirmation, tier and general-admission selection, best available, the
   selection tray, holds, expiry, conflict recovery and checkout handoff.
2. `SeatLayerView` — the existing raw map plus `SeatLayerController`, retained
   for applications that deliberately own their complete buyer UI.

The default `SeatLayerPicker` layout will be composed from the same public
Flutter widgets available to custom integrations. All default and custom
components will consume one `SeatLayerPickerController` and one immutable
`SeatLayerPickerState`. Applications may replace or rearrange presentation,
but they must not have to reproduce inventory, validation, hold or conflict
logic.

Popup, embedded and full-screen modes are presentations of the same picker
session. Changing presentation must not reload the event, clear an unheld
selection, create a second hold or duplicate buyer chrome.

## 2. Why this is needed

Flutter `0.2.2` wraps the web `SeatingChart` contract. It exposes a WebView,
configuration, controller commands and event streams, but it is not the same
surface as the complete web `SeatPicker`.

As a result, every current Flutter integrator must independently build:

- loading and retry states;
- event identity and close behavior;
- price and category presentation;
- map controls and section navigation;
- selection confirmation and ticket tiers;
- general-admission and grouped-table prompts;
- best available;
- selection summary and validation guidance;
- hold creation, countdown, restore, expiry and release;
- checkout handoff and abandoned-hold cleanup; and
- accessibility, safe-area and responsive behavior.

The DesiPass development app made this gap visible. Its SeatLayer screen grew
into a large application-specific wrapper, showed a duplicate test indicator,
and needed a tap-detection/zoom workaround because the mobile bridge did not
expose section focus. These are SDK responsibilities, not work every ticketing
app should repeat.

## 3. Goals

- A complete integration in approximately ten lines of Dart.
- Inline, adaptive modal and full-screen route presentations.
- One session and hold owner across all presentations.
- A public component kit for applications that want their own layout.
- Behavioral parity with the web buyer picker where the mobile platform
  supports the feature.
- Container-responsive layouts rather than device-name checks.
- Correct section-tap navigation and usable mobile seat targets.
- Typed, server-authoritative checkout handoff.
- Explicit hold ownership and release-exactly-once behavior.
- Backward compatibility for `SeatLayerView`, `SeatLayerController` and
  `SeatLayerConfiguration`.
- A versioned bridge contract that can be implemented consistently by Flutter,
  iOS, Android and React Native.
- A documented GitHub, prerelease, end-to-end validation and stable-release
  workflow.

## 4. Non-goals for Flutter 0.3

- Booking inventory with a SeatLayer secret from the app.
- Trusting client-rendered prices for payment.
- Replacing an application's payment or order flow.
- Forcing existing raw `SeatLayerView` integrations into the new buyer UI.
- Making hosted browser payment UI a release blocker.
- Requiring venue 3D or panorama on devices that cannot support it.
- Pixel-identical web and Flutter chrome. The behavior and information
  hierarchy must match; controls should remain native and accessible.
- Shipping every native SDK simultaneously. Flutter proves the public contract
  first; the same bridge fixtures and semantics are then ported.

## 5. Architecture

```text
Flutter application
  |
  +-- SeatLayerPicker -------------------------------- turnkey UI
  |     +-- SeatLayerPickerAdaptiveLayout
  |     +-- public picker components
  |
  +-- SeatLayerPickerScope + public components ------- custom UI
  |
  +-- SeatLayerView + SeatLayerController ------------ raw map API
        |
        v
SeatLayer mobile bridge v2
        |
        v
Shared buyer picker session
  +-- chart and live inventory
  +-- selection and validation
  +-- categories, prices, tiers, GA and tables
  +-- section focus and map intent
  +-- holds, restore, expiry and conflict recovery
  +-- typed checkout handoff
        |
        v
SeatLayer API and realtime inventory
```

### 5.1 One canonical business session

Selection rules, live conflicts, category metadata, best-available behavior,
hold replacement, expiry and checkout handoff remain canonical SeatLayer
runtime behavior. Dart owns Flutter presentation and app lifecycle, not a
second implementation of inventory policy.

The web `SeatPicker` and mobile bridge should converge on a DOM-independent
buyer-session model. The web DOM layer and Flutter component layer render that
model through platform-specific adapters.

### 5.2 Pre-release acceleration

An early `0.3.0-dev` build may host the complete web `SeatPicker` inside the
WebView behind the final `SeatLayerPicker` Dart API. This is an internal beta
adapter for fast DesiPass validation, not a separate public contract.

The stable component contract still requires a picker-session bridge so custom
Flutter components can consume the same authoritative state. No app-facing API
should depend on whether the current internal presentation adapter is web or
Flutter.

## 6. Target Dart API

The snippets in this section are the public contract to compile-test during
implementation. Small naming adjustments are allowed only before the first
public prerelease.

### 6.1 Turnkey embedded picker

```dart
SeatLayerPicker(
  configuration: SeatLayerConfiguration(
    event: eventKey,
    buyerAccessTokenProvider: mintBuyerAccess,
  ),
  onCheckout: (handoff) {
    openCheckout(holdId: handoff.holdId);
  },
)
```

The picker fills a bounded parent. Like the current map, it must not be placed
inside a competing gesture-driven scroll/zoom surface.

### 6.2 Adaptive modal

```dart
final handoff = await showSeatLayerPicker(
  context: context,
  configuration: configuration,
  presentation: SeatLayerPickerPresentation.adaptive,
);

if (handoff != null) {
  openCheckout(holdId: handoff.holdId);
}
```

Presentation values:

```dart
SeatLayerPickerPresentation.adaptive
SeatLayerPickerPresentation.dialog
SeatLayerPickerPresentation.fullScreen
```

`adaptive` is full-screen on compact phones and a large constrained dialog on
larger devices.

### 6.3 Route-owned picker

```dart
SeatLayerPickerPage(
  configuration: configuration,
  onCheckout: (handoff) {
    openCheckout(holdId: handoff.holdId);
  },
)
```

The page is edge-to-edge and safe-area aware. `showSeatLayerPicker` sets
`popOnCheckout` internally and returns the handoff as its route result; an
application-owned page normally handles the callback itself.

### 6.4 Custom composition

```dart
final picker = SeatLayerPickerController();

SeatLayerPickerScope(
  controller: picker,
  configuration: configuration,
  child: const Column(
    children: [
      SeatLayerPickerPriceRail(),
      Expanded(
        child: Stack(
          children: [
            SeatLayerPickerMap(),
            SeatLayerPickerMapControls(),
          ],
        ),
      ),
      SeatLayerPickerSelectionTray(),
      SeatLayerPickerCheckoutBar(onCheckout: openCheckout),
    ],
  ),
)
```

An internally created controller is disposed by `SeatLayerPicker`. A
caller-supplied controller is never disposed by the widget. One controller may
not be attached to simultaneous maps.

### 6.5 Picker options

Network, event, buyer-access and raw selection configuration remain in
`SeatLayerConfiguration`. Buyer-flow-only options live in an additive
`SeatLayerPickerOptions` value:

```dart
SeatLayerPickerOptions(
  holdTtl: const Duration(minutes: 10),
  initialHoldId: restoredHoldId,
  readOnly: false,
  confirmSelection: true,
  enableBestAvailable: true,
  enable3D: true,
  enableSeatView: true,
  hideEventDetails: false,
  panelInitiallyCollapsed: false,
  persistColorblindPreference: true,
  languages: const [Locale('en'), Locale('de')],
)
```

The current baseline does not silently persist a hold capability. A host that
wants restoration persists the handoff itself and supplies `initialHoldId` on
the next picker session. A host-supplied id is always host-owned because the
host acquired and persisted it; ownership is intentionally not a public option.

## 7. Public Flutter component kit

The initial public kit consists of:

- `SeatLayerPickerAdaptiveLayout`
- `SeatLayerPickerMap`
- `SeatLayerPickerHeader`
- `SeatLayerPickerAttribution`
- `SeatLayerPickerTestModeIndicator`
- `SeatLayerPickerMapControls`
- `SeatLayerPickerPriceRail`
- `SeatLayerPickerAccessibilityFilters`
- `SeatLayerPickerFloorSelector`
- `SeatLayerPickerSectionNavigator`
- `SeatLayerPickerBestAvailable`
- `SeatLayerPickerSelectionTray`
- `SeatLayerPickerHoldCountdown`
- `SeatLayerPickerCheckoutBar`
- `SeatLayerPickerSeatConfirmation`
- `SeatLayerPickerGeneralAdmissionPrompt`
- `SeatLayerPickerTablePrompt`
- `SeatLayerPickerActionError`
- `SeatLayerPickerLoadingView`
- `SeatLayerPickerErrorView`
- `SeatLayerPickerEmptyView`

Every component reads the nearest `SeatLayerPickerScope`. Components with
meaningful standalone use may also accept an explicit controller. They remain
stateless with respect to inventory and holds.

Applications can replace components through normal composition or targeted
builders. The targeted builder slots cover header, price rail, section
navigator, accessibility filters, map, map controls, Best Available,
seat/GA/table prompts, selection tray, hold countdown, action errors, checkout
bar, loading, error and empty. The adaptive layout, test-mode marker and
required attribution have no replacement builder, so returning an empty custom
widget cannot suppress required native chrome. Theme tokens still customize
their appearance. A fully manual `SeatLayerPickerScope` composition must place
the test marker and attribution components itself.

## 8. Picker state and actions

`SeatLayerPickerController` exposes a synchronous immutable state through a
`ValueListenable<SeatLayerPickerState>` and typed asynchronous actions. The
state carries both `sessionId` and `revision`: revision is monotonic only within
one runtime session, while a WebView/runtime reload creates a new session id.

The state includes:

```text
sessionId and revision
phase and current busy action
ready info, event mode and capabilities
event identity, organizer theme and sales state
currency, categories, prices, tiers and availability
active category/accessibility filters and limited-view preference
floors, current floor, section focus, map rung and projection
committed selection, table occupancy and selection validity
general-admission prompt candidate
token-free active-hold status, owner and server expiry
recoverable error/access state
checkout handoff state
```

Implemented controller actions:

```text
retry / synchronize
setSeatTier / removeObject / clearSelection
selectObjects / deselectObjects
selectCategories / deselectCategories
setSelectableObjects / setMaxSelection
bestAvailable
setGeneralAdmissionQuantity / dismissGeneralAdmissionCandidate
setTableQuantity
setCategoryFilter / setAccessibilityFilter / setLimitedViewHidden
focusSection / overview / setRung
setFloor / setViewMode
zoomIn / zoomOut / zoomToFit / setColorblindSafe
resumeHold / extendHold / checkout / rejectCheckoutHandoff
releasePickerOwnedHold
setLifecycle / close / destroy / dismissError
```

Actions are serialized where inventory ownership can change. Repeated checkout
taps must not create parallel hold requests. A mutating command response names
the resulting revision; Dart does not complete the public action until that
revision has been applied or a typed timeout is raised.

## 9. Mobile bridge v2

### 9.1 Envelope and negotiation

- The existing bridge envelope remains `sl: 1`; protocol v2 changes semantic
  capabilities and payloads, not the transport envelope.
- Flutter advertises protocol support `1..2`.
- The existing raw surface continues to operate with protocol v1.
- The complete/native picker requests protocol `2..2` and requires the exact
  versioned capability set below.
- Optional controls are gated by capabilities and commands.
- Incompatible required payload semantics use protocol v2 rather than changing
  the meaning of an existing v1 field.
- Unknown fields, events and open-enum values remain forward-compatible.

The implemented picker profile requires these exact capability strings:

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

`native-access-provider` is additionally required when
`buyerAccessTokenProvider` or `buyerAccessToken` is configured. Existing
`selection-controls` and `selection-validity` capabilities remain conditional
requirements when the raw selection-policy fields are configured. Optional
buyer controls are advertised in the snapshot's `features` object and are
hidden when their feature is absent.

### 9.2 Initialisation

The v2 init payload adds an explicit surface, required capabilities and chrome
owner. Presentation (`embedded`, `dialog`, `fullscreen`) remains Flutter-only
and is deliberately absent from the bridge:

```json
{
  "surface": {
    "kind": "picker",
    "stateContract": 1,
    "chromeOwner": "native"
  },
  "requirements": {
    "capabilities": [
      "picker-session-v2",
      "picker-snapshot-v1",
      "picker-actions-v1",
      "native-picker-chrome-v1",
      "checkout-handoff-v1",
      "checkout-handoff-reject-v1",
      "hold-ownership-v1",
      "cart-line-remove-v1",
      "table-quantity-v1"
    ]
  },
  "chrome": {
    "owner": "native",
    "seatTooltip": false,
    "testModeIndicator": false,
    "attribution": false
  }
}
```

`owner: native` assigns surrounding buyer chrome to Flutter. The renderer hides
its seat tooltip, test indicator and attribution, while Flutter renders the
corresponding native component from snapshot state. In particular, a test
event produces exactly one `SeatLayerPickerTestModeIndicator`, not one badge in
the WebView and another above it. Attribution remains entitlement-driven by
`branding.attributionRequired`; moving its owner does not waive it.

### 9.3 Atomic snapshot

`sys.ready` carries the initial snapshot. The runtime then emits a complete
replacement `picker.snapshot` after every meaningful state transition. The
snapshot intentionally excludes chart geometry and per-seat live inventory;
those remain within the rendered map:

```json
{
  "schema": "seatlayer.picker.snapshot/1",
  "sessionId": "ps_01",
  "revision": 42,
  "event": {
    "key": "ev_xxx",
    "name": "Event name",
    "mode": "test",
    "currency": "EUR",
    "venue": "Venue",
    "startsAt": 1789756200000,
    "timezone": "Europe/Berlin",
    "locale": "de",
    "posterUrl": null,
    "salesClosed": false
  },
  "branding": {
    "brandName": "Organizer",
    "logoUrl": null,
    "attributionRequired": true,
    "tokens": {}
  },
  "features": {
    "bestAvailable": true,
    "accessibilityFilter": true,
    "floors": true
  },
  "catalog": {
    "categories": [],
    "zones": [],
    "sections": [],
    "gaAreas": [],
    "bestAvailableZones": []
  },
  "map": {
    "rung": "sections",
    "viewMode": "flat",
    "activeFloorId": null,
    "focusedSectionId": null,
    "focusedSection": null,
    "colorblindSafe": false,
    "hideLimitedView": false,
    "canZoomIn": true,
    "canZoomOut": true,
    "categoryFilter": [],
    "accessibilityFilter": [],
    "floors": []
  },
  "selection": {
    "seats": [],
    "validity": null,
    "maxSelection": 10
  },
  "cart": {
    "items": [],
    "quantity": 0,
    "total": 0,
    "currency": "EUR"
  },
  "hold": {
    "active": false,
    "expiresAt": null,
    "ownership": null
  },
  "access": {
    "configured": false,
    "status": "public",
    "reason": null
  }
}
```

Each `cart.items` entry uses the same stable line shape returned later in the
handoff:

```json
{
  "lineKey": "seat:A-1:adult",
  "label": "A-1",
  "displayLabel": "Row A, Seat 1",
  "displayType": "Seat",
  "objectId": "seat-a-1",
  "objectType": "seat",
  "categoryKey": "standard",
  "tierId": "adult",
  "unitPrice": 25,
  "currency": "EUR",
  "quantity": 1
}
```

`selection.seats` carries the corresponding selection identity and display
metadata, with optional tier/commercial attributes, accessibility values and
table occupancy fields (`bookingMode`, `quantity`, `capacity`,
`minOccupancy`, `maxOccupancy`). Unknown extra fields remain forward-compatible.

Dart drops snapshots older than the highest applied revision for the current
session id and resets the watermark only when `sessionId` changes. A detected
gap is repaired with `picker.getSnapshot`. `hold` is deliberately token-free:
it contains only active state, server expiry and `picker`/`host` ownership. The
opaque `holdId` appears only in `SeatLayerCheckoutHandoff`. Buyer-access tokens
never enter a snapshot, command error, log or analytics event.

### 9.4 Commands and events

The implemented protocol-v2 command table and payload names are:

```text
picker.getSnapshot              no payload
picker.selectObjects            { objects: string[] }
picker.deselectObjects          { objects: string[] }
picker.clearSelection           no payload
picker.selectCategories         { categoryKeys: string[] }
picker.deselectCategories       { categoryKeys: string[] }
picker.removeCartLine           { label }
picker.setSeatTier              { seatId, tierId }
picker.setSelectableObjects     { objects: string[] | null }
picker.setMaxSelection          { maxSelection }
picker.setCategoryFilter        { categoryKeys: string[] | null }
picker.setLimitedViewFilter     { on }
picker.setAccessibilityFilter   { types: string[] | null }
picker.focusSection             { sectionId }
picker.overview                 no payload
picker.setRung                  { rung }
picker.setFloor                 { floorId }
picker.setColorblindSafe        { on }
picker.setViewMode              { mode }
picker.zoomIn                   no payload
picker.zoomOut                  no payload
picker.zoomToFit                no payload
picker.bestAvailable            { qty, categoryKey?, zoneId?, preferPremium, ttlMs? }
picker.holdGA                   { areaId, qty, tierId?, ttlMs? }
picker.setTableQuantity         { label, quantity, ttlMs? }
picker.resumeHold               { holdId }
picker.extendHold               { ttlMs? }
picker.continue                 { ttlMs? }
picker.rejectHandoff            { holdId }
picker.abort                    no payload
picker.lifecycle                { state: "foreground" | "background" }
picker.destroy                  no payload
```

Every mutating command returns the resulting `revision` and may include the
complete `snapshot`. Dart waits until that revision is applied; after two
seconds it calls `picker.getSnapshot` and fails with a typed decoding error if
the runtime still cannot produce the revision. Runtime commands are also
serialized in arrival order, preventing an asynchronous table replacement from
racing `picker.continue` even when a native caller issues both rapidly.

`setCategoryFilter(<String>{})` sends `categoryKeys: null`, which means clear
the filter; an empty array is not used as a second, ambiguous clear encoding.
The selection wrappers expose typed Dart results/state while preserving these
wire results:

```text
picker.selectObjects / picker.selectCategories -> { seats, revision }
picker.resumeHold -> { restored, expiresAt, revision }
picker.destroy -> { destroyed: true, released, revision }
```

Three inventory-sensitive commands have stricter response contracts:

```text
picker.removeCartLine { label }
  -> { removed, source: "selection" | "hold" | "none", holdActive, revision }

picker.setTableQuantity { label, quantity, ttlMs? }
  -> { updated: true, source: "selection" | "hold", expiresAt, revision }

picker.rejectHandoff { holdId }
  -> { released: true, revision }
```

Removing a held line uses the server partial-release operation; removing the
last line clears picker ownership. Changing a held table quantity uses an
atomic server replacement. Neither command may mutate a host-owned hold.
Relevant typed runtime errors are:

```text
hold_owned_by_host
cart_line_release_failed
table_quantity_rejected
hold_state_incomplete
handoff_not_owned
```

`picker.rejectHandoff` succeeds only when its id matches the exact active hold
returned by this runtime session's most recent successful `picker.continue`.
It cannot release a merely resumed host hold or an arbitrary id. A server
release failure preserves both the tracked handoff and host ownership so the
same id can be retried safely.

### 9.5 Read-only enforcement

`readOnly: true` forces the web chart's selectable-object policy to an empty
set and Dart rejects inventory-changing controller calls locally with a typed
`SeatLayerError(code: "read_only")`. Native seat/GA/table prompts, cart-line
deletes, Best Available and checkout are disabled. The runtime independently
returns `read_only` if a custom or stale host still sends one of these commands:

```text
picker.selectObjects / picker.deselectObjects / picker.clearSelection
picker.selectCategories / picker.deselectCategories / picker.setSeatTier
picker.removeCartLine / picker.setTableQuantity
picker.setSelectableObjects / picker.setMaxSelection
picker.holdGA / picker.bestAvailable / picker.resumeHold
picker.extendHold / picker.continue
```

Read-only still permits snapshot sync, category/accessibility/limited-view
filters, section/rung/floor/view navigation, colorblind mode, zoom, lifecycle,
abort, exact handoff rejection and destroy. These operations either change only
presentation or safely release inventory already owned by this picker session.

The state event surface is deliberately small:

```text
sys.ready          initial snapshot in payload.snapshot
picker.snapshot
```

`picker.continue` validates, creates or reuses a hold, returns the stable
checkout handoff and atomically transfers ownership to the host.
`picker.abort` is idempotent and acknowledged only after a picker-owned hold is
released or confirmed absent. Every v2 command failure is returned through its
correlated error envelope; it must not use the legacy out-of-band error followed
by an apparently successful null result.

Legacy selection/hold events continue for `surface.kind == chart`. The picker
controller uses the atomic snapshot stream for state and retains the existing
typed buyer-access, `ga.click`, hold-expiry and error signals where they carry a
distinct interaction or lifecycle notification.

## 10. Checkout handoff

The Flutter result mirrors the stable web handoff semantics:

```dart
class SeatLayerCheckoutHandoff {
  final String holdId;
  final double expiresAt;
  final String currency;
  final List<SeatLayerCheckoutLineItem> lineItems;
  final double total;

  DateTime get expiryDate =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt.round());
}
```

Each line item includes stable booking label, optional buyer-facing label,
object identity/type, category, selected tier, unit price, currency and
quantity.

The handoff is sufficient to start the host checkout, but it is not payment
authority. `total` is a display convenience. The trusted backend inspects the
hold and calculates the charge from server data before payment and booking.

## 11. Hold ownership and close semantics

Hold ownership is a state-machine contract, not a UI convention.

```text
no hold
  | hold / best available succeeds
  v
SDK-owned hold
  | checkout handoff delivered
  v
host-owned hold
```

Rules:

1. Manual selection remains unheld until the buyer continues.
2. Best Available returns an already-created SDK-owned hold.
3. `checkout` (`picker.continue`) validates and either reuses an exact active
   hold or creates one; concurrent calls share one Future and do not send
   duplicate hold requests.
4. Before handoff, the page and modal close button, system back and route pop
   call the acknowledged `close`/`picker.abort` path exactly once. A host that
   owns an inline controller must await `controller.close()` before deliberately
   removing it; synchronous Dart `dispose` cannot guarantee an awaited network
   release.
5. If close occurs while a hold request is in flight, close waits for the
   request. A successful late hold is released before close completes.
6. Delivering `onCheckout` or returning a non-null modal/page result atomically
   transfers ownership to the host.
7. If the turnkey `onCheckout` callback fails, Flutter best-effort calls
   `picker.rejectHandoff` with that exact handoff before preserving and
   surfacing the original callback error. Custom flows call
   `rejectCheckoutHandoff(handoff)` explicitly.
8. After transfer, widget disposal never releases the hold. Only exact handoff
   rejection or the trusted checkout/booking path may resolve it.
9. Hold expiry clears selection/hold state as defined by the server and returns
   the buyer to a recoverable selection experience.
10. `picker.removeCartLine` uses the server partial-release operation for a held
   line and updates the same hold when lines remain. The last line clears picker
   ownership.
11. `picker.setTableQuantity` atomically replaces held table occupancy rather
    than exposing a release/re-hold race.
12. App termination cannot guarantee cleanup; the server TTL remains the final
    safety boundary.

## 12. Lifecycle

- The WebView and picker session are mounted once for the controller lifetime.
- Responsive changes and inline/full-screen expansion do not recreate the
  session.
- An externally supplied controller is bound to one event and rejects an event
  change. An internally owned scope creates a fresh controller for a different
  event; hosts must use the acknowledged close path before replacing a session
  that may own a hold.
- A `SeatLayerView` picker configuration or controller replacement first makes
  a best-effort acknowledged `picker.destroy` call against the old controller,
  then detaches its correlations and boots the replacement. Raw protocol-v1
  views keep their existing direct-detach behavior.
- A synchronous removal of an internally owned `SeatLayerPickerScope` cannot
  itself await a network release. Do not use an in-place event/key swap as a
  close mechanism: present through `SeatLayerPickerPage`/`showSeatLayerPicker`,
  or supply a controller and await `close()` before removing the old scope.
- Pending ready or command callbacks cannot update a disposed widget.
- App backgrounding does not pause the server hold clock.
- Foreground resume refreshes authoritative hold/inventory state.
- A caller-supplied initial hold is verified with `resumeHold`; it is never
  painted as owned before server verification.
- `close` performs acknowledged picker abandonment. `dispose` closes Dart
  subscriptions and its internally owned raw controller; it is not a substitute
  for an awaited close when an inline session may own a hold.

## 13. Responsive mobile experience

Layout is based on parent constraints through `LayoutBuilder`, not the device
model or global window width.

### Compact

- Map-first, edge-to-edge composition.
- Compact event header and one close action.
- Persistent horizontal price rail.
- Pinch as primary zoom gesture.
- Contextual zoom-out when deeply focused; fit remains available.
- Selection summary and primary action in a safe-area-aware peek sheet.
- Expanded sheet for selected tickets, best available, GA/table choices and
  hold details.
- Seat confirmation is a bottom card/sheet that does not make the map
  untouchable after dismissal.

### Regular and wide

- Map and ticket panel may appear side by side.
- Ticket panel can collapse, but automatically reopens when selection requires
  checkout visibility.
- Dialog presentation keeps useful margins and a bounded maximum size.

### Section interaction invariant

A clean tap on a visible section at overview must focus and frame that section.
A tap on a sufficiently usable seat target selects or opens confirmation. The
host app must never need to infer map taps and issue repeated generic zoom
commands.

## 14. Theme, localization and accessibility

### Theme

`SeatLayerPickerThemeData` is exposed as a Flutter `ThemeExtension`.

Resolution order:

```text
safe SDK defaults
  -> organizer/chart theme
  -> host Flutter theme
  -> explicit SeatLayerPickerThemeData overrides
```

It covers accent/on-accent, background, surface, primary/muted text, borders,
semantic success/warning/error colors, selected/held/sold treatments, radius,
spacing, control sizing, typography and map-theme overrides. Map contrast is
validated separately from surrounding chrome.

### Localization

- Default to `Localizations.localeOf(context)`.
- Generate Dart resources from the same canonical message keys used by web.
- Preserve per-key `messages` overrides.
- Keep map and Flutter chrome on the same resolved locale.
- Support RTL mirroring.

### Accessibility release gates

- Minimum 48 by 48 logical-pixel interactive targets.
- Semantic labels, roles, values and hints for every control.
- VoiceOver and TalkBack announcements for selection, conflicts, errors and
  hold thresholds.
- A usable non-canvas selection alternative/list for assistive technology.
- 200% text scaling without clipped identity or checkout controls.
- Reduced-motion behavior.
- Colorblind-safe state that never relies only on hue.
- Safe-area, landscape and keyboard handling.

## 15. Security invariants

- Never place a SeatLayer secret in Dart, the binary or WebView.
- Buyer-access tokens remain memory-only and are never included in URLs,
  picker snapshots, logs, analytics or crash messages.
- The native token provider continues to mint for the exact hosted renderer
  origin.
- Checkout exposes only the opaque hold capability and buyer display data.
- SDK diagnostics and analytics redact the hold id; it is delivered only to
  the host checkout callback/result and explicit hold-resume APIs.
- The backend inspects the hold, computes the amount and books with an
  idempotent host order reference.
- Losing buyer access does not silently release an already-owned hold.
- Losing buyer access never silently widens private inventory to public scope.
- Analytics omit credentials, payment data and unnecessary buyer identity.

## 16. Backward compatibility

- Existing `SeatLayerView`, `SeatLayerController` and
  `SeatLayerConfiguration` constructors retain their current defaults.
- Raw controller commands do not begin auto-holding or auto-releasing.
- Existing protocol-v1 hosted runtimes remain usable by the raw surface.
- New raw-view chrome ownership options are additive and default to current
  behavior.
- The raw and picker surfaces negotiate separate profiles even if a package
  currently points them at the same immutable runtime document. Raw requests
  protocol 1; picker requests protocol 2 and fails closed on missing
  capabilities.
- Native chrome ownership suppresses the WebView test badge/attribution and
  renders them from snapshot state, so exactly one owner is visible.
- The development source reports `0.3.0-dev.1`; publication metadata and the
  SDK diagnostic constant must be checked together before any tag or package
  publication.

## 17. DesiPass API impact

No new DesiPass booking endpoint or database change is required.

DesiPass already supplies:

- `seatEngine` and `seatEventKey`;
- `createSeatLayerBuyerAccessSession`;
- the hosted renderer origin for buyer-session minting;
- SeatLayer hold ids through the existing booking `holdToken`; and
- trusted server-side hold inspection, payment and booking.

The required product changes are in the shared SeatLayer picker session,
mobile bridge and Flutter package. DesiPass later replaces its custom picker
shell with the new SDK surface.

## 18. Implementation phases

The work spans clean branches in separate repositories because the current
developer worktrees contain unrelated active changes:

| Order | Repository | Branch | Responsibility |
| --- | --- | --- | --- |
| 1 | `seatmap` | `codex/mobile-picker-engine` | authoritative section-focus and shared picker-session behavior |
| 2 | `seatlayer-runtime` | `codex/mobile-picker-contract` | capability-negotiated hosted bridge/runtime |
| 3 | `seatlayer-flutter` | `codex/flutter-picker-0.3` | Dart state, components, presentations, examples and docs |
| 4 | `desipass_api-userapp` | `codex/seatlayer-picker-pilot` | consume an exact SDK commit and produce end-to-end evidence |
| 5 | native SDK repositories | one branch per SDK | replicate the frozen contract |

```text
seatmap PR
  -> seatlayer-runtime PR/release
    -> seatlayer-flutter PR
      -> DesiPass integration PR and E2E evidence
        -> Flutter stable release
```

The DesiPass private buyer token is bound to `https://cdn.seatlayer.io`.
Consequently, a private `embed_only` event cannot validate a runtime hosted on
an unrelated preview origin without changing its allowed origin. The additive
runtime contract must first pass local/fixture compatibility checks, then be
published as an immutable compatible hosted runtime. Flutter pins that exact
runtime version before DesiPass private-event testing.

### Phase 0 — document and branch baseline

- Commit this document on `codex/flutter-picker-0.3`.
- Push the branch to GitHub.
- Open or update a draft pull request.
- Treat subsequent contract changes as reviewed document changes.

### Phase 1 — shared runtime and bridge

- Extract or formalize the DOM-independent buyer picker session.
- Fix section-tap focus in the shared renderer and add focused device evidence.
- Add protocol v2 negotiation, snapshot schema, commands, events and chrome
  ownership.
- Add typed checkout handoff and acknowledged abandonment.
- Publish an immutable development mobile runtime.

### Phase 2 — Flutter state and lifecycle

- Add v2 payloads and open enums.
- Add `SeatLayerPickerController`, reducer and immutable state.
- Add serialized inventory actions and handoff ownership.
- Correct `SeatLayerView` configuration/disposal/late-callback lifecycle gaps
  without changing existing defaults.
- Add a fake runtime adapter for component tests.

### Phase 3 — Flutter components and adaptive layout

- Implement and export the component kit.
- Build `SeatLayerPicker` from those components.
- Add compact, regular and wide constraint-based layouts.
- Add theme, localization and semantics.

### Phase 4 — presentation helpers

- Add `SeatLayerPickerPage`.
- Add `showSeatLayerPicker` with adaptive/dialog/full-screen presentation.
- Preserve one controller/session during inline/full-screen expansion.
- Route system back, close and dismissal through acknowledged abandonment.

### Phase 5 — DesiPass migration and end-to-end validation

- Point the DesiPass development app at the pushed SDK's exact 40-character
  Git commit, never a path dependency or moving branch.
- Commit `pubspec.lock` and record both the SDK commit and hosted runtime
  version in the pilot PR.
- Replace the SeatLayer-specific custom shell with `SeatLayerPicker`.
- Retain Seats.io routing for explicit `SEATSIO` events.
- Remove duplicate test chrome and the generic repeated-zoom workaround.
- Validate selection through payment and server booking with a safe development
  event/gateway.

### Phase 6 — prerelease and stable Flutter release

- Publish `0.3.0-dev.1` after CI and simulator gates.
- Validate in DesiPass against the published prerelease, not only a path
  dependency.
- Fix findings through additional prereleases.
- Publish `0.3.0` only after the stable exit criteria below pass.
- After publication, replace the DesiPass Git dependency with
  `seatlayer: ^0.3.0` and repeat one smoke purchase. This validates package
  contents and registry resolution, not only source-repository behavior.

### Phase 7 — native SDK replication

- Freeze bridge fixtures and semantic contracts proven by Flutter.
- Implement idiomatic iOS, Android and React Native surfaces.
- Run the same scenario matrix on every SDK.
- Release each SDK independently after its platform gates pass.

## 19. GitHub workflow

- Never commit directly to `main`.
- Work on `codex/flutter-picker-0.3` until the initial PR is merged.
- Push small, reviewable commits grouped by responsibility:
  1. architecture document;
  2. bridge protocol and payload types;
  3. picker state/controller;
  4. component groups;
  5. presentations and example;
  6. documentation and release metadata.
- Keep generated or vendored runtime changes in their own commit with source
  version and integrity evidence.
- Do not force-push shared review branches.
- CI must pass on every pushed implementation commit.
- Flutter CI includes formatting, analysis, existing bridge tests, picker
  reducer/widget tests, both public quick-start compile fixtures, an Android
  debug example build, an unsigned iOS Simulator example build and
  `dart pub publish --dry-run`.
- Runtime CI verifies the pinned release manifest, promotable state and hosted
  picker document before Flutter can update its pin.
- Live buyer credentials are available only to an environment-protected,
  manually dispatched E2E job, never ordinary pull-request jobs.
- Tag prereleases and stable releases only from reviewed, reproducible commits.
- GitHub remains the handoff point: DesiPass consumes a pushed commit or
  published prerelease, never an untracked local SDK edit.

Every DesiPass QA evidence bundle records exact app, SDK and runtime commits,
redacted E2E results, iOS/Android captures, the completed acceptance matrix,
known limitations and a deterministic rollback target.

## 20. Verification strategy

Testing is targeted to credible failures introduced by this high-risk buyer and
inventory flow.

### 20.1 Contract and unit tests

- Protocol v1/v2 negotiation and missing-capability failure.
- Snapshot decoding, unknown fields and stale-revision rejection.
- Selection validity and candidate transitions.
- Best Available producing an already-active hold.
- Double checkout taps producing one hold request.
- Hold expiry and restore.
- Partial/full release.
- Close during an in-flight hold.
- Release exactly once before handoff.
- Never release after handoff.
- Access expiry/refresh/unavailable transitions.
- SDK/package version consistency.

### 20.2 Flutter widget tests

- Turnkey and custom public examples compile.
- Compact phone, large phone, tablet dialog and wide inline layouts.
- Safe-area and landscape composition.
- Light/dark and organizer/host theme layering.
- RTL and 200% text scale.
- Semantic roles, labels, focus order and live regions.
- Exactly one test-mode indicator.
- Components rebuild from state without recreating the map.

### 20.3 Runtime integration tests

- Hosted runtime handshake and initial snapshot.
- Section tap focuses the intended section.
- Overview/section/seat navigation.
- Category and accessibility filtering.
- Candidate confirmation and tier change.
- GA and grouped-table prompts.
- Hold, restore, extension, expiry and conflict recovery.
- Checkout handoff schema.
- Abandon waits for hold release.

### 20.4 Simulator/emulator matrix

- Compact and modern notched iPhone Simulators on the supported iOS runtime.
- Standard and small Android phone emulators on a supported API level.
- iPad and Android tablet emulators for adaptive dialog behavior.
- Compact portrait, large portrait and landscape.
- System back, swipe-back/dialog dismissal and app close.
- Background/foreground with and without an active hold.
- Rotation while selecting and while held.
- Slow load, offline-at-load and reconnect.
- Buyer-access token renewal.

### 20.5 Physical-device gates

- At least one supported iPhone and one supported Android phone.
- Prefer both Pixel-class and Samsung-class Android evidence when available,
  because System WebView and system-gesture behavior vary.
- Pinch, pan and section/seat tap accuracy.
- Home-indicator/navigation-bar safe areas.
- VoiceOver and TalkBack.
- Native test payment sheet and successful return to confirmation.
- Performance and memory after repeated open/close cycles.
- 2D fallback when optional 3D is unsupported or loses context.

### 20.6 DesiPass end-to-end scenarios

1. Seats.io event still uses the unchanged Seats.io flow.
2. Public SeatLayer test event loads and shows one test indicator.
3. Private/embed-only event mints and renews buyer access.
4. Section tap focuses automatically without the app zoom workaround.
5. Reserved seat selection, tier selection and removal work.
6. Best Available creates and displays one hold.
7. GA and table inventory work on representative fixtures.
8. Close before checkout releases the hold.
9. Continue hands the same hold id to DesiPass checkout.
10. App navigation after handoff does not release the hold.
11. The trusted API inspects the hold and uses its price/items.
12. A sandbox/zero-value payment completes.
13. Booking succeeds idempotently and appears in the resulting order/tickets.
14. Expired and conflicting inventory return the buyer to a recoverable state.

Use two controlled fixtures:

- a SeatLayer TEST-mode event for UI, gestures, holds and failure recovery; and
- a dedicated non-production live-mode inventory event connected to the
  payment provider's test mode for one true payment/booking journey.

A TEST event that intentionally books nothing cannot prove the final booking
and inventory gate by itself. No real customer inventory or uncontrolled live
charge is used for release validation.

## 21. Stable Flutter release exit criteria

`0.3.0` may be published only when:

- all documented public examples compile;
- existing raw API tests remain green;
- bridge v1 compatibility and v2 picker tests pass;
- compact, dialog and full-screen layouts pass targeted widget checks;
- iOS and Android simulator smoke tests pass;
- physical iPhone and Android gesture/accessibility gates pass;
- DesiPass completes the safe end-to-end hold/payment/booking scenario using a
  published prerelease;
- close/release and handoff/no-release behavior are proven;
- section tap works without application repair code;
- exactly one test indicator is shown;
- README, API reference, migration guide and example application match the
  shipped API; and
- release metadata, runtime pin and SDK version are consistent.

## 22. Cross-SDK replication contract

Flutter proves product semantics, not Flutter-specific class names.

The portable contract consists of:

- protocol negotiation and capabilities;
- picker snapshot JSON fixtures;
- state phase and action semantics;
- checkout handoff schema;
- hold ownership and close behavior;
- chrome ownership;
- responsive information hierarchy;
- accessibility requirements; and
- end-to-end scenario fixtures.

Platform APIs remain idiomatic:

| Platform | Turnkey surface | State/custom surface | Presentation helper |
| --- | --- | --- | --- |
| Flutter | `SeatLayerPicker` | controller + scope/widgets | page/show helper |
| iOS | SwiftUI/UIKit picker | observable session + views | sheet/full-screen cover |
| Android | Compose/View picker | state flow + composables | dialog/activity/navigation |
| React Native | component | hook/controller + components | modal/screen component |

No SDK releases solely because another platform is ready. Each implementation
must pass the shared contract fixtures and its own platform/device gates.

Recommended replication order after Flutter/DesiPass freezes the contract:

1. React Native — closest declarative/component model and fastest validation of
   whether the state contract is truly framework-neutral.
2. iOS — UIKit controller plus SwiftUI wrapper over one observable session.
3. Android — View surface plus Jetpack Compose wrapper over one state holder.
4. Final parity audit across all four mobile SDKs and the central documentation.

Each SDK receives its own PR, examples, CI evidence, physical-device gate and
release tag. Server SDKs do not receive UI changes unless the trusted
checkout/booking contract itself changes.

## 23. Documentation deliverables

- README quick start showing `SeatLayerPicker` first.
- “Choose the surface” comparison: turnkey picker versus raw view.
- Inline, modal and page examples.
- Custom composition guide with every public component.
- Theme and localization guide.
- Buyer-access and security guide.
- Hold lifecycle and checkout handoff guide.
- Lifecycle, back-navigation and persistence guide.
- Migration guide from Flutter `0.2.x` raw wrappers.
- DesiPass integration note replacing the temporary zoom workaround.
- Bridge v2 reference and compatibility matrix.
- Cross-SDK conformance guide.

## 24. Decisions that are intentionally settled

- Flutter is the first complete mobile picker implementation.
- `SeatLayerView` remains the low-level API.
- The default picker and custom kit share one state/hold owner.
- Checkout handoff is required for 0.3; hosted mobile payment UI is not.
- Venue 3D is capability-gated and is not allowed to break the 2D flow.
- Hold persistence is explicit; memory-only is the default.
- Adaptive modal means full-screen on compact phones.
- Business and inventory state remain canonical in the shared SeatLayer
  session; Flutter owns presentation.
- DesiPass business APIs remain unchanged unless end-to-end evidence discovers
  a concrete missing server capability.
- Flutter stable release precedes cross-SDK replication.
