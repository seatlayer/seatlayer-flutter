# SeatLayer Flutter Picker — Architecture

Where the seam is between your app and SeatLayer: what the SDK owns, what you
own, the Dart surface between them, and the rules that govern selection, holds
and checkout. Written for an integrator who wants to know the shape of the
thing before building on it.

Last updated: 2026-09-05

## 1. Two supported levels

1. `SeatLayerPicker` — the complete buyer journey. It owns loading, event
   identity, price and accessibility controls, section navigation, seat
   confirmation, tier and general-admission selection, best available, the
   selection tray, holds, expiry, conflict recovery and the checkout handoff.
2. `SeatLayerView` with `SeatLayerController` — the raw seat map, retained for
   applications that deliberately own their entire buyer UI.

The default `SeatLayerPicker` layout is composed from the same public widgets
available to custom integrations. Every default and custom component consumes
one `SeatLayerPickerController` and one immutable `SeatLayerPickerState`. You
may replace or rearrange presentation freely; you never have to reproduce
inventory, validation, hold or conflict logic to do it.

That boundary is SDK-owned. A consuming application should not be carrying
picker spacing, duplicate-chrome, section-focus or best-available workarounds.
It supplies configuration, optional theme tokens and the checkout callback.

## 2. Layers

```text
Your Flutter application
  |
  +-- SeatLayerPicker ------------------------------- turnkey UI
  |     +-- SeatLayerPickerAdaptiveLayout
  |     +-- the public picker widgets
  |
  +-- SeatLayerPickerScope + the public widgets ----- your own layout
  |
  +-- SeatLayerView + SeatLayerController ----------- raw map API
        |
        v
  SeatLayerPickerController + SeatLayerPickerState
        |
        v
  The SeatLayer venue map
    +-- chart and live inventory
    +-- selection and validation
    +-- categories, prices, tiers, GA and tables
    +-- section focus and map intent
    +-- holds, restore, expiry and conflict recovery
    +-- the typed checkout handoff
        |
        v
  The SeatLayer API and live inventory
```

**One canonical business session.** Selection rules, live conflicts, category
metadata, best-available behaviour, hold replacement, expiry and the checkout
handoff are canonical SeatLayer behaviour. Dart owns Flutter presentation and
app lifecycle — never a second implementation of inventory policy.

**The venue map owns the venue; Flutter owns the chrome.** Seats, labels,
section shells, the immersive 3D scene and the seat-view panorama are drawn by
the venue map. Everything else — header, price rail, floor strip, section dock,
confirm card, cart sheet, checkout button, the captions over 3D and the
panorama — is a Flutter widget. The map draws no furniture of its own, so there
is never a second tooltip, a second test badge or a duplicate button under a
native one.

## 3. State and actions

`SeatLayerPickerController` exposes a synchronous, immutable state through a
`ValueListenable<SeatLayerPickerState>`, plus typed asynchronous actions.

The state carries:

```text
phase and the action currently in flight
ready info, event mode and available capabilities
event identity, organizer theme and sales state
currency, categories, prices, tiers and availability
active category/accessibility filters and limited-view preference
floors, current floor, section focus and map rung
buyer view (map / venue 3D), 3D target seat and navigation mode
committed selection, table occupancy and selection validity
general-admission prompt candidate
active-hold status, owner and server expiry — never the hold id
recoverable error and access state
checkout handoff state
```

Actions cover selection (`selectObjects`, `deselectObjects`, `setSeatTier`,
`clearSelection`, `setMaxSelection`, `bestAvailable`), quantity prompts
(`setGeneralAdmissionQuantity`, `setTableQuantity`), filtering
(`setCategoryFilter`, `setAccessibilityFilter`, `setLimitedViewHidden`),
navigation (`focusSection`, `overview`, `setRung`, `setFloor`, `setViewMode`,
`setBuyerView`, `showSeatIn3D`, `openSeatView`, `set3DNavigationMode`,
`zoomIn`, `zoomOut`, `zoomToFit`, `setMapInteractionEnabled`) and inventory
(`resumeHold`, `extendHold`, `checkout`, `rejectCheckoutHandoff`,
`releasePickerOwnedHold`, `close`, `destroy`, `retry`, `synchronize`).

Two questions about one seat are reported separately from the snapshot, because
neither is a change to the selection: `seatAwaitingConfirmation` is a seat the
buyer has tapped but not yet taken, and `seatAwaitingRemoval` is a seat already
in the cart that they have tapped a SECOND time. The second arrives as the
bridge event `seat.retap` (payload `{ seat }`, the seat still selected, no
`selection.changed` with it) so the chrome can ask before the seat goes, rather
than the seat disappearing under the finger. `dismissSeatRemoval()` puts that
question away without answering it; `markSeatAnswered(label)` answers either.
A seat being asked about for removal stays in `confirmedCartLines`,
`confirmedTicketCount` and `confirmedCartTotal` — it is still in the cart until
the buyer says otherwise.

State arrives as whole replacements, never partial patches: the picker reads
one snapshot at a time and drops stale ones. Actions that can change inventory
ownership are serialized, so repeated checkout taps cannot create parallel hold
requests, and a mutating action does not complete until the resulting state has
been applied or a typed timeout is raised.

Controls whose underlying feature is unavailable are absent rather than
decorative — the picker fails closed instead of showing a button that quietly
does nothing.

## 4. Checkout handoff

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

Each line item carries a stable booking label, an optional buyer-facing label,
object identity and type, category, selected tier, unit price, currency and
quantity.

The handoff is enough to start your checkout, but it is not payment authority.
`total` is a display convenience. Your trusted backend inspects the hold and
calculates the charge from server data before payment and booking.

## 5. Hold ownership and close

Hold ownership is a state machine, not a UI convention.

```text
no hold
  | hold / best available succeeds
  v
picker-owned hold
  | checkout handoff delivered
  v
host-owned hold
```

1. Manual selection stays unheld until the buyer continues.
2. Best Available returns an already-created, picker-owned hold.
3. `checkout()` validates and either reuses an exact active hold or creates
   one; concurrent calls share one Future rather than sending duplicates.
4. Before handoff, the close button, system back and route pop all take the
   same acknowledged close path exactly once. A host owning an inline
   controller must `await controller.close()` before removing it — a
   synchronous `dispose` cannot guarantee an awaited release.
5. If close happens while a hold request is in flight, close waits for it, and
   a hold that succeeds late is released before close completes.
6. Delivering `onCheckout`, or returning a non-null page/modal result,
   atomically transfers ownership to the host.
7. If a turnkey `onCheckout` throws, the picker rejects that exact handoff
   before surfacing your original error. Custom flows call
   `rejectCheckoutHandoff(handoff)` themselves.
8. After transfer, disposal never releases the hold. Only an exact handoff
   rejection or your trusted checkout path resolves it.
9. Hold expiry clears selection and hold state and returns the buyer to a
   recoverable selection experience.
10. Removing a held cart line partially releases it and keeps the same hold
    while other lines remain; the last line clears picker ownership.
11. Changing table quantity replaces held occupancy atomically rather than
    exposing a release/re-hold race.
12. Process termination cannot guarantee cleanup. The server TTL is the final
    safety boundary.

## 6. Lifecycle

- One session is mounted for the controller's lifetime. Responsive changes and
  inline/full-screen expansion do not recreate it.
- An externally supplied controller is bound to one event and rejects an event
  change. An internally owned scope creates a fresh controller for a different
  event.
- Do not use an in-place event or key swap as a close mechanism. Present
  through `SeatLayerPickerPage` / `showSeatLayerPicker`, or supply a controller
  and await `close()` before removing the old scope.
- Pending callbacks never update a disposed widget.
- Backgrounding does not pause the server hold clock; foreground resume
  refreshes authoritative hold and inventory state.
- A caller-supplied initial hold is verified with `resumeHold` before it is
  ever painted as owned.
- `close()` is acknowledged abandonment. `dispose` closes Dart subscriptions
  and is not a substitute for an awaited close when a session may own a hold.

## 7. Responsive layout

Layout is decided from parent constraints through `LayoutBuilder`, not the
device model or the global window width. Compact is a column — header, map,
dock, and a peek cart sheet that expands to content height. Regular and wide
place the same parts side by side. In both, the map keeps a clear rectangle:
your own chrome declares its insets rather than covering the seats.

**Section interaction invariant.** Tapping a section focuses it; tapping a seat
selects it. The two never race, and the back ladder walks seat card → section →
overview → dismiss rather than leaving on the buyer's first try out.

**Gesture invariant.** The map owns pan, pinch and camera animation. Do not
nest the picker in a gesture-driven scroll view, do not wrap it in an app-level
drag or scale recognizer, and do not forward raw touch coordinates to it.

**One touch, one surface.** The map is a platform view: on iOS an embedded
`WKWebView` inside the engine's touch-intercepting view, which holds each touch
until Flutter's gesture arena says who won it. Awarded to the map, the touch is
released to the web view; awarded elsewhere, it is swallowed. Resolved by
nobody — which is what happens when the map's render object was never
hit-tested — UIKit hands it to the web view anyway. That is why a native
control drawn over the map used to fire in Flutter *and* pick a seat
underneath, and why hiding the map with an `IgnorePointer` does not help: being
absent from the hit test is exactly the leaking state.

The rule this SDK holds to, and the rule any custom layout must hold to:

- Native chrome standing on the map goes in `SeatLayerMapChromeStack`, whose
  first child is the map. It hit-tests chrome first, as `Stack` does, and then
  always gives the map its turn too, so the platform view is in the arena for
  every touch inside the map band and always learns the verdict.
- The map surface reads that stack's `SeatLayerMapChromeScope` and installs a
  recognizer that stays eager — claiming on pointer down, which is what its
  latency-free pan and pinch depend on — except where the same hit test landed
  on chrome, where it resigns instead.
- Chrome over the map must **compete** for the pointer: a button, an `InkWell`,
  a `GestureDetector`. A bare `Listener` observes pointers without entering the
  arena, so nothing would claim the sequence and the map would win it.
- The runtime-side `picker.setInteractionEnabled` guard stays for the surfaces
  that take the whole map — the seat card and the loading and error states —
  and is still the right call around any native overlay a host mounts over a
  `SeatLayerPickerMap` in its own composition.

None of this depends on the `webview_flutter_wkwebview` version. The behaviour
lives in the Flutter engine's `FlutterTouchInterceptingView` and in
`RenderUiKitView`'s arena wiring, and the plugin only passes
`gestureRecognizers` through to `UiKitView`. A host pinning
`webview_flutter_wkwebview: 3.17.0` gets the same fix as one on the current
release.

## 8. Theme, localization and accessibility

`themeMode` resolves in one order: your `themeMode` → your app's theme → the
device. Either reading is live: the Flutter chrome and the drawn map repaint
together with no reload, no lost selection and no moved camera. A `.light()` or
`.dark()` preset pins one side deliberately.

Every buyer-facing string is overridable, and
`SeatLayerPickerStrings.forLocale` resolves the shipped translations by
language — and by script for Chinese — falling back to the English default for
an untranslated locale.

Accessibility gates are semantics on every control, dynamic safe areas,
container breakpoints, and a colourblind-safe mode in which state never relies
on hue alone.

## 9. Security invariants

- Never place a SeatLayer secret in Dart or in the app binary.
- Buyer-access tokens stay in memory. They never enter URLs, picker snapshots,
  logs, analytics or crash messages.
- Register the SDK's renderer origin on the publishable key you use. For
  private, login-gated, presale, partner or channel inventory, drop `publicKey`
  and mint a short-lived, origin-bound buyer session from your own backend.
- Checkout exposes only the opaque hold id and buyer display data.
- SDK diagnostics redact the hold id. It reaches your checkout callback or
  result and the explicit hold-resume APIs, and nowhere else.
- Your backend inspects the hold, computes the amount and books with an
  idempotent order reference.
- Losing buyer access never silently releases an owned hold, and never widens
  private inventory to public scope.
- Analytics omit credentials, payment data and unnecessary buyer identity.
