# Picker component catalogue

The SeatLayer buyer picker, described so a Swift, Kotlin or React Native
engineer can build it without reading Dart. Names here are the Dart API's
names, deliberately: the four SDKs should agree on what things are called.

Every token reference (`size.dockBarHeight`, `color.dark.surface`,
`motion.duration.sheet`) resolves in [`tokens.json`](./tokens.json).

This file is the catalogue: what each component is called, what it reads, and
which slot restyles it. [`picker-spec.md`](./picker-spec.md) is the full
specification — every state, every animation, every string and every capability,
in buyer order. Where the two disagree, the spec is newer.

## Corner radius: which surfaces are pills

**Decision, 2026-08-28, restated after the web-parity round.** Actions carry
`radius.button`, which is what the web picker's own buttons measure. Material's
default stadium button is therefore wrong for this design, and every action that
is not listed as a pill below overrides it.

`radius.button` is its own role, not a fraction of `radius.base`: a brand that
rounds its cards to 20 pt must not thereby grow pill buttons, and the
organizer's branding radius is never inherited by it. `radius.control` is the
same value under its own name, for the form controls that are not actions —
the best-seats selects and stepper.

**True pills** (`radius.pill` / `radius.chip`, 999):

- the hold countdown pill and the sales-closed pill in the header, and the
  header's close ring
- the price-legend chips, including `All prices`
- the Map | 3D segmented control, track and segments
- the test-mode chip
- the floor rail's track and its floor chips
- the dock's `‹ ›` steps and its `‹ Venue` way out
- the seat card's photo-strip pills — `View from here` and `3D` — and the
  flight chip that leaves the card
- every piece of 3D chrome: the back pill, the deck's nav chips, the caption
- the seat-view caption strip
- a toast's action, the access panel's action, and the booked overlay's seat
  list and `Back to map`

**`radius.button`:**  the seat card's `Cancel` and `✓ Add seat`, its
`See it in 3D` action and its decision-row `3D` square, its 3D inspection
chips and its tier rows; the sheet's `Hold seats & checkout`; the
accessibility sheet's rows and `Apply filters`; `Try again`; the prompts'
action pairs.

**`radius.peekButton` (11):** the collapsed bar's two doors — `Continue ·
total` and `✦ Find seats`. They were true pills; a rounded rectangle at the
full `size.minimumHitTarget` reads as the primary action each of them is.

**`radius.control`:** the best-seats selects, its stepper and its action.

Round icon controls — the map buttons, the 3D seat stepper — are circles and
are unaffected. The cart plate rounds to `radius.base × radius.smallRatio`; the
seat card to `radius.confirmCard`; the sheet to `radius.sheet`.

Dart: `SeatLayerPickerThemeData(buttonRadius:)` moves every `radius.button`
action at once, and the per-element slots — `primaryButtonStyle`,
`secondaryButtonStyle`, `continueButtonStyle`, `iconButtonStyle`, `chipShape` —
and each widget's `style:` parameter still win over it.

## Shared model

Every component reads one **picker snapshot** and calls back into a
**controller**. No component fetches anything itself.

Snapshot fields the catalogue refers to:

| Field | Meaning |
| --- | --- |
| `event` | name, venue, currency, branding, test mode |
| `map.rung` | `venue` (overview) or `seats` (a section is focused) |
| `map.focusedSectionId` | the focused section, or null |
| `map.isVenue3D` | whether the immersive scene is up |
| `map.categoryFilter` | the active price-chip filter |
| `sections[]` | `id`, `label`, `displayLabel`, `color`, `seatsLeft`, `priceMin`, `priceMax`, `zoneId` |
| `categories[]` | `key`, `label`, `color`, `priceMin` |
| `selection[]` | `SelectedSeat`: `label`, `sectionLabel`, `rowLabel`, `seatNumber`, `price`, `currency`, `objectType`, `tiers`, `screenPoint` |
| `cart` | `lines[]`, `ticketCount`, `cartTotal` |
| `hold` | `holdId`, `expiresAt`, `owner` |
| `access` | why access is limited, where it is — paused, revoked, expired, unverified |
| `capabilities` | which optional features are available — venue 3D, seat view, best available |
| `branding.attributionRequired` | whether the attribution line must render |

Two rules bind every component:

1. **The venue map owns the venue; native owns the chrome.** Everything in
   this catalogue is drawn natively, on top of the map.
2. **A row name may already contain its section.** Print
   `rowLabel` with the section prefix removed (Dart: `pickerRowLabel`), or the
   card reads `Stalls D · Row Stalls D C`.

## Layout

Measured off the picker's own container, never the device: phone below
`size.phoneBreakpoint`, wide at or above `size.wideBreakpoint`. The phone
composition is a column:

```
Header                                     size.headerHeight
PriceLegend band                           size.topRailHeight
┌ map surface (WebView) ──────────────────────────────────┐
│  TestModeBadge (top-left)   ViewModeControl (top-right) │
│  FloorStrip (left rail)                                 │
│  corner controls: accessibility ◦ zoom column           │
│  toast · extend prompt (bottom centre)                  │
│  ConfirmCard / Venue3D chrome / status overlay          │
│  DockBar                                size.dockBarHeight│
└─────────────────────────────────────────────────────────┘
CartSheet peek                             size.peekHeight
```

The prices keep a band of their own between the header and the map: floated on
the map's top edge, the last chip was clipped under the Map/3D control and seat
numbers read through the gaps on a busy chart. The Map/3D control keeps the
map's top-right corner on the line below, where the test badge sits at the other
end.

The header, the rail and the sheet are rows of the same column, so the map
surface begins and ends where they do. Everything else in the diagram stands on
the map and is reported to the runtime as viewport insets — see
[`picker-spec.md`](./picker-spec.md) §2.3.

---

## Header

**Name** `SeatLayerPickerHeader` · **Style slot** `headerStyle` · **Instance
override** `style:`

- **Inputs** `event.name`, `event.venue`, `branding.logo`, `hold`.
- **States** compact (phone, one line) / full (wide, two lines); with and
  without a hold.
- **Anatomy** `size.headerHeight` tall, ground `color.*.surface`, elevation
  `elevation.header`. Left: brand tile `size.headerLogoSize`. Centre: event
  name, `type.headerTitle`, ellipsized. Right: the HoldPill, then the dismiss
  control.
- **Callbacks** `onClose`.
- **Commands** none.

## PriceLegend

**Name** `SeatLayerPriceLegend` · **Style slots** `legendChipStyle`,
`chipShape` · **Instance override** `style:`

- **Inputs** `categories[]`, `map.categoryFilter`, `event.currency`.
- **States** chip idle / selected / sold out; empty (the band is not drawn);
  not drawn at all while the immersive scene is up. The band takes the map
  chrome's palette, so it darkens with the scene.
- **Anatomy** a band of `size.topRailHeight` on `color.*.surface` with a
  hairline beneath, holding one horizontally scrolling row. Each chip:
  `size.legendChipHeight` of ink inside a `size.minimumHitTarget` reach, a dot
  of `size.legendChipDotSize`, then the amount, `type.legendChip`. Idle ground
  is `color.*.background` with a hairline; selected is the accent with
  `color.*.onAccent` and a ring on the dot. `All prices` is pinned first and
  never scrolls away. On the light theme the dot is the category colour mixed
  into the surface under a full-strength ring of it.
- **Callbacks** none.
- **Commands** `picker.setCategoryFilter { keys, focus }` — the first tap
  filters and drills in, the second clears.

## MapControls

**Name** `SeatLayerPickerMapControls` · **Style slot** `iconButtonStyle`

- **Inputs** `map.isVenue3D`, `map.focusedSectionId`, `capabilities`.
- **States** phone corners / wide rail; the map-only controls stand down while
  the immersive scene is up.
- **Anatomy** round controls `size.mapControlSize`, except the accessibility
  control at `size.accessibilityControlSize` (`size.minimumHitTarget`).
  Bottom-left accessibility, bottom-right fit; both lift by
  `size.dockBarHeight` while the dock is up. The accessible-section stepper
  sits beside the accessibility control, `size.accessStepGap` from it.
- **Commands** `picker.zoomToFit`, `picker.setAccessibilityFilters`,
  `picker.setColorblindSafe`, `picker.setBuyerView`.
- **Note** `SeatLayerPickerViewModeControl` (the Map/3D segmented control) is a
  member of this stack on wide layouts only; on a phone the top rail owns it.

## DockBar

**Name** `SeatLayerDockBar` · **Style slot** `dockBarStyle` · **Instance
override** `style:`

- **Inputs** `sections[]` (with `accessibleFree`), `map.focusedSectionId`,
  `map.rung`, `map.accessibilityFilter`.
- **States** hidden at rung `venue`; visible at rung `seats`; step controls
  disabled at the ends of `sections[]` (never wrapping around).
- **Anatomy** edge-to-edge, `size.dockBarHeight` plus the bottom safe area,
  elevation `elevation.dockBar`. Left: a 10 pt dot in the section's colour, the
  section name (`type.dockSection`, ellipsizes) and `N left`
  (`type.dockCount`, never ellipsizes; omitted when `seatsLeft` is unknown),
  followed by ` · ♿ N` under an active filter on `section-access-counts-v1`
  where this section was counted — absent counts stay silent, never `♿ 0`.
  Right: `‹ ›` section steps, then `‹ Venue`.
- **Motion** slides in over `motion.duration.dock`; the name cross-fades over
  `motion.duration.crossfade` when the focus changes.
- **Callbacks** `onSectionChanged(id)`, `onOverview`.
- **Commands** `picker.focusSection { id }`, `picker.overview`.

## ConfirmCard

**Name** `SeatLayerConfirmCard` · **Style slots** `confirmCardStyle`,
`primaryButtonStyle`, `secondaryButtonStyle`, `pillStyle` · **Instance
override** `style:`

- **Inputs** the newest unconfirmed `SelectedSeat`, `capabilities`
  (`seatView`, `venue3d`), and — on `seat-view-thumbnail-v1` — the seat's
  `seatViewThumb`, `sightlineMetres` and `seatViewConfidence`.
- **States** with a photo (loading, arrived, never arrived), without one (no
  strip at all, and the 3D square in the decision row), 3D-only, with a sight
  line, with tiers, with notices; the confidence teaser or its passport chip
  inside 3D; resting or hugging the seat; committing.
- **Anatomy** `size.confirmCardMaxWidth`, capped at the map width less
  `2 × size.confirmCardGutter`, radius `radius.confirmCard`, elevation
  `elevation.confirmCard`.
  1. Identity grid, `size.confirmIdentityHeight`: section, row and seat as
     three EQUAL centred cells, hairline-divided, keys at
     `size.confirmIdentityKeyFontSize` and values at
     `size.confirmIdentityValueFontSize`. Only a section longer than
     `size.confirmSectionShortMax` drops to
     `size.confirmIdentityLongSectionFontSize` and wraps to two lines.
  2. Category band, `size.confirmBandHeight`: the category colour itself, full
     bleed, no dot and no rail, with its ink chosen per colour (white where
     white clears 3:1, otherwise `#0B0F19`). The name at
     `size.confirmBandNameFontSize`, `N left` at
     `size.confirmBandLeftFontSize` in that ink at 78 %, the price at
     `size.confirmBandPriceFontSize`.
  3. Photo strip, `size.confirmPhotoHeight`, only where the seat names an
     authored photograph, carrying the `View from here` and `3D` pills and, in
     its trailing top corner, the sight line (`strings.sightline`,
     `size.confirmSightFont` / `confirmSightPadX` / `confirmSightPadY`). With
     no photograph the slot is not drawn at all — no rail, no caption — and a
     photograph that never arrives collapses it away over
     `motion.duration.thumbOut`.
  3a. Confidence teaser, 3D card only and only where the seat carries one:
     `size.confidenceTeaser*`, headline over `modeledTarget ?? reality`, with
     `strings.passport` in the readable accent at the trailing edge. Where a
     host can open the passport it is instead a chip on the inspection row.
  3b. Inspection row, 3D card only: one line of
     `size.confirmInspectChipHeight` chips —
     `strings.passport` (with an accent dot) and `strings.viewFromHere`
     (spoken as `strings.viewFromThisSeat`) — at
     `size.confirmInspectChipFontSize`.
  4. Tiers (`size.confirmTierHeight`) and notices, where the seat has them.
  5. Actions, `size.confirmActionHeight`: with no photo strip a 44 × 44 ghost
     square carrying a cube and `strings.venue3D` at
     `size.confirm3dSquareFontSize` opens the row, then `Cancel` at 34 % of the
     whole row and `✓ Add seat` at the rest, each in its own box at
     `radius.button` inside the card's gutter.
- **Placement** rests `size.confirmCardRestInset` above the map's foot; hugs
  the seat at `size.confirmCardSeatGap` when it would otherwise cover it. Full
  rule and constants: `picker-spec.md` §3.8.2.
- **Motion** the map dims to ink behind it (`SeatLayerPickerStyles.scrimColor`);
  the card springs in from the seat's side with `motion.curve.spring` over
  `motion.duration.cardEnter`. `Add seat` invites once, breathes until touched,
  and on the press sweeps, ticks and says `Added`. The seat counts on the press;
  only the card's departure waits.
- **Callbacks** `onConfirm`, `onCancel`, `onViewFromSeat`, `onShow3D`,
  `onSeatConfidence` (the teaser is a button only where a host takes it).
- **Commands** `picker.openSeatView`, `picker.showSeatIn3D`,
  `picker.deselect` on cancel.

## CartSheet

**Name** `SeatLayerCartSheet` · **Style slots** `sheetStyle`,
`continueButtonStyle` · **Instance overrides** `style:`,
`continueButtonStyle:`

- **Inputs** `cart`, `hold`, `capabilities.bestAvailable`, `event.currency`.
- **States** peek empty, peek with tickets, expanded empty (the best-seats
  form), expanded with tickets.
- **Anatomy** radius `radius.sheet`, elevation `elevation.sheet`.
  - **Peek** `size.peekHeight`: a grabber, then left `N tickets`, or
    `From <min>` when empty — the sentence at `type.peekSummary` in
    `color.*.mutedText` with the AMOUNT inside it lifted to
    `type.peekFromPrice` in `color.*.text`; right the filled `Continue · total`
    button at `size.minimumHitTarget` and `radius.peekButton` and the chevron.
    With an empty cart the button is `✦ Find seats` at
    `size.findPillHeight` / `radius.peekButton` / `type.findPill`, which opens
    the sheet on the best-seats form — withheld where that form would be
    refused. The peek also
    carries the securing, checkout and closed-sales lines; see
    `picker-spec.md` §3.9.
  - **Expanded** content height, capped at
    `size.sheetMaxHeightFraction` of the screen; the empty tray is capped at
    `size.emptyTrayMaxHeight`. Header is one line, `N tickets` plus the ✦
    best-seats control and the chevron — no title and no repeated total.
  - **Footer** the full-width BookButton, then the attribution when
    `branding.attributionRequired`.
- **Rules** the sheet never opens itself; any map tap while expanded collapses
  it to peek.
- **Motion** `motion.duration.sheet`.
- **Commands** `picker.checkout` from either call to action.

## CartList

**Name** `SeatLayerCartList`

- **Inputs** `cart.lines[]` joined to `selection[]`.
- **Anatomy** one `size.denseLineHeight` line per entry:
  `● Section · Row · Seat …… price ✕` (`type.denseLine`). Consecutive entries
  sharing section, row, category and price fold into one line:
  `Section · Row · 1–6   6 × €25   €150`, tapped to open in place. An opened
  run lists its members **in seat order**, matching the range its own label
  states. A run of one is not a group and keeps its category dot. Beyond
  `size.denseVisibleLines` lines the rest collapse behind `+N more`.
- **Rules** a range is only drawn when the seat numbers really are consecutive;
  anything else lists up to three labels and then `+N`. A ticket that carries
  its own control (a table's guest count, a tier choice) never folds.
- **States** a line the buyer has asked to remove is drawn at
  `opacity.removing` with its × inert and its swipe disabled, from the press
  until the snapshot that drops it (or the failure that puts it back). Any
  cell whose words change between snapshots cross-fades over
  `motion.duration.crossfade`; the rest of the line does not move. See
  `picker-spec.md` §3.13.
- **Commands** `picker.removeCartLine { label }`, offered back for
  `motion.durationOutsideBudget.undoWindow` as an undo. It carries its own busy
  action (`removingCartLine`) because it is the one inventory mutation that
  does not put the checkout call to action down.

## BookButton

**Name** `SeatLayerBookButton` · **Style slot** `primaryButtonStyle` ·
**Instance override** `style:`

- **Inputs** `cart`, `hold`, busy state.
- **Anatomy** full width, `size.checkoutButtonHeight`, radius `radius.button`,
  `type.bookButton`. Carries its own label only — the total is already on the
  peek bar.
- **States** idle, busy (spinner), disabled with a reason. Disabled is a
  designed state — a surface-toned ground, muted ink, an inset hairline — not
  Material's own greys, which vanish on the dark scene sheet. The label ladder
  is in `picker-spec.md` §3.10.3.
- **Commands** `picker.checkout`, then `picker.rejectHandoff` if the host
  refuses the handoff, so a rejected hold is never stranded.

## Venue3D chrome

**Name** `SeatLayerVenue3D` · **Style slot** `pillStyle`

- **Inputs** the focused `SelectedSeat`, `map.isVenue3D`, `capabilities`.
- **States** live seat view / venue 360°; stepper disabled in venue mode.
- **Anatomy** one dark glass whatever the resolved mode is —
  `color.dark.immersiveGlass`, its border and ink, blurred by
  `size.immersiveGlassBlur`; captions use the deeper caption glass. Every piece
  is a pill. Top-left `‹ Back to venue` (`size.immersiveBackPillHeight`), drawn
  only while the buyer is sitting in an exact seat. Bottom: a caption chip
  naming the seat, then `‹` previous seat, `Open venue 360°`, `›` next seat, and
  recentre, as chips of `size.immersiveNavChipHeight`.
- **Motion** `motion.duration.immersive`.
- **Commands** `picker.showSeatIn3D`, `picker.openVenue360`,
  `picker.setBuyerView`, `picker.recentre3D`.

## HoldPill

**Name** rendered by `SeatLayerPickerHeader` (`showHoldPill`) · **Style slot**
`pillStyle`

- **Inputs** `hold.expiresAt`.
- **States** counting down; absent when there is no picker-owned hold — a hold
  handed to the host is the host's to display.
- **Anatomy** a true pill (`radius.pill`) with a timer glyph and `mm:ss`,
  `type.pill`.
- **Haptics** `holdCreated` on creation, `holdExpired` on expiry.

## TestModeBadge

**Name** `SeatLayerPickerTestModeIndicator`

- **Inputs** `event.mode`.
- **Rules** required chrome: it has no host switch, and exactly one may render.
  It steps below the immersive scene's own back control rather than under it.
- **Anatomy** a pill of `size.testChipHeight` at `radius.pill`, one recipe in
  both themes: warning ink on the warning colour mixed into the surface, a
  leading dot of `size.testChipDotSize`. Copy `strings.testMode`; the accessible
  name keeps `strings.testModeLong`. Amber, never the accent — an environment
  flag must not wear "buy" gold.

---

## Also in the catalogue

These carry no separate entry here because their whole description is their
specification. Names, slots and files:

| Component | Slot | Spec |
| --- | --- | --- |
| `SeatLayerFloorStrip` | `floorStripStyle` | §3.7 |
| `SeatLayerBestSeatsForm` | — | §3.11 |
| `SeatLayerPickerToast` / `…ToastQueue` / `…ToastLayer` | — | §3.12 |
| `SeatLayerPickerLoadingView` / `…ErrorView` / `…EmptyView` | — | §3.13.1–2 |
| `SeatLayerPickerAccessPanel` | — | §3.13.3 |
| `SeatLayerPickerSalesClosedStatement` / `…SalesClosedPill` | — | §3.13.4 |
| `SeatLayerPickerSoldOutOverlay` | — | §3.13.5 |
| `SeatLayerPickerExtendHoldPrompt` | — | §3.13.8 |
| `SeatLayerPickerBookedOverlay` | — | §3.13.10 |
| `SeatLayerPickerGeneralAdmissionPrompt` / `…TablePrompt` | — | §3.13.11–12 |
| `SeatLayerPickerAccessibilityFilters` | — | §3.5 |
| `SeatLayerPickerAccessibleStepper` | — | §3.4.1 |
| `SeatLayerSeatViewChrome` | `seatViewChromeStyle` | §3.15 |
| `SeatLayerPickerAttribution` | — | §3.10.3 |
| `SeatLayerCheckoutCta` (the one label resolver) | — | §3.9, §3.10.3 |
| `SeatLayerTypeScale` / `seatLayerReadingOrder` / `seatLayerBoldWeight` | — | §4.10 |
