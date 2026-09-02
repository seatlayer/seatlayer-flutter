# SeatLayer buyer picker — implementation specification

The buyer picker is one design with four implementations. The Flutter package
in this repository is the reference: it is built entirely from
[`tokens.json`](./tokens.json), and the iOS (SwiftUI), Android (Compose) and
React Native SDKs are expected to be built from the same file plus this
document, without reading Dart.

This document is the contract. [`components.md`](./components.md) is the
catalogue of names and slots that goes with it; where the two disagree, this
document is newer. Every number, colour, duration, curve, haptic strength and
buyer-facing string cited here is a **token name**, and every token name
resolves in `tokens.json`. Literals appear only where the design deliberately
has no token — a percentage tint, a hairline, a ratio — and each of those is
called out as a fixed recipe constant.

Names in **Dart file** rows are the reference implementation's files, given so
a porting engineer can find the behaviour if a sentence here is ambiguous. They
are not part of any public contract.

---

## 1. Principles

**1.1 One snapshot model.** Every surface in the picker reads one *picker
snapshot* and calls back into one *controller*. No component fetches, computes
availability, or holds its own copy of the cart. A snapshot carries `event`,
`map`, `sections[]`, `categories[]`, `zones[]`, `selection[]`, `cart`, `hold`,
`access`, `capabilities` and `branding`. When two surfaces would disagree, they
are reading different things and one of them is wrong.

**1.2 Native chrome over a web-drawn map.** The venue itself — seats, sections,
labels, the 3D scene — is drawn by the SeatLayer runtime inside a web view. Every
other pixel in this document is drawn natively, over it or beside it. The
runtime never draws buyer chrome on a native host: a runtime advertising
`native-chrome-contract-v1` is told at `init` to suppress its own panel, rail,
dock, tray and seat-view words, and the native SDK owns them from that moment.

**1.3 The web picker's phone layout is the floor, and its numbers are the
tokens.** The design was not invented natively. Every size, weight, radius,
duration and curve in `tokens.json` was extracted from the web picker's phone
stylesheet, so a buyer who meets the product on the web and then in an app meets
one thing. A native port may not "improve" a number; it may only add what a
native platform can do that a browser cannot.

**1.4 Native adds physics, haptics and gestures on top.** The web picker
animates with fixed-duration tweens. A native picker answers a finger with a
simulation: the cart sheet and a swiped row settle from wherever the finger left
them, at the speed it left them at (`motion.physics.*`). Native also adds the
haptic vocabulary in `haptics` and platform gestures — swipe-to-open, swipe-to-
remove, swipe-down-to-dismiss. Nothing in this layer may change *what* happens,
only how it feels.

**1.5 Everything is a token or a style slot.** A host retunes the picker
without forking it. Sizes come from a layout token set, colours and type from a
theme, per-element looks from named style slots, and every buyer-facing string
from an overridable string set. A port that hard-codes a number has broken the
contract even if it looks right.

**1.6 Reduced motion is a first-class state.** When the viewer asks for less
movement, every duration in `motion.duration` collapses to zero. Motion that has
no reduced form — the fly-to-cart indicator, a staggered arrival, the seat
card's invitation — is **skipped**, not played instantly (`motion.reducedMotion`).
Sequenced work must not wait on a skipped animation: the seat card commits on
the press and departs on the same tick under reduced motion.

**1.7 44 pt is the floor.** `size.minimumHitTarget` is the smallest touch
target anywhere in the picker. Ink may be smaller — a price chip is
`size.legendChipHeight` of ink, a remove glyph is `size.denseRemoveSize` — but
the target that receives the press is never below the floor. Where ink and
target differ, the larger target is centred on the ink and must not steal
presses from a neighbour.

**1.8 Both themes, always.** `color.light` and `color.dark` are complete ground
sets. A mode owns only the ground roles; the accent, the accent ink, the font
and the host radius are the organizer's brand and are identical in both modes.
Three surfaces deliberately ignore the resolved mode and are always dark: the 3D
scene chrome (`color.dark.immersive*`), the seat card's photo-strip pills, and
the seat-view caption — each floats over imagery that can be any colour.

---

## 2. Layout and breakpoints

### 2.1 Two compositions, keyed off the container

Measure the **picker's own container width**, never the device or window:

| Composition | Rule |
| --- | --- |
| compact (phone) | container width below `size.phoneBreakpoint` |
| wide | container width at or above `size.wideBreakpoint` |

Between the two the compact composition holds. Everything in §3 describes the
compact composition unless a row says otherwise; the wide composition moves the
cart into a side pane and the Map/3D control into the corner-control stack, and
otherwise reuses the same components.

### 2.2 The compact column

```
Header                                     size.headerHeight  + top safe area
Price rail band                            size.topRailHeight          (row)
┌ map surface (runtime web view) ─────────────────────────────────────────┐
│  top-left anchor    test chip · 3D back pill                            │
│  top-right anchor   Map | 3D control                                    │
│  left-rail anchor   floor rail                                          │
│  bottom-left        accessibility control                               │
│  bottom-right       zoom column                                         │
│  bottom-centre      toast · hold-extend prompt                          │
│  seat card / prompts / status overlays                                  │
│  Section dock                             size.dockBarHeight  + safe area│
└─────────────────────────────────────────────────────────────────────────┘
Cart sheet (peek)                          size.peekHeight   + bottom safe area
```

The header, the price rail and the cart sheet are **rows of the same column**:
the map surface begins and ends where they do. Everything else in the diagram is
**stacked on the map**.

### 2.3 Viewport insets

The runtime frames a section, a floor or a fitted venue inside the rectangle it
believes it owns. Chrome that stands *on* the map must therefore be reported to
it, or a focused section lands half underneath the dock. A runtime advertising
`viewport-insets-v1` accepts a report of the bands the native chrome covers.

Reported (they stand on the map):

- the test chip, and the 3D back pill it steps below
- the Map | 3D control
- the floor rail
- the section dock, plus its lift of the bottom anchors
- the immersive scene's own top and bottom chrome

Not reported (they are rows, and the map surface already ends at their edge):

- the header
- the price rail band
- the cart sheet, at peek or open

Rules for the reporter: coalesce to at most one report per frame, never send
the same numbers twice, floor negative or non-finite sides to zero, and forget
what was sent when a runtime goes away — a fresh runtime frames against its
whole surface until it is told otherwise. Dart file:
`lib/src/picker/picker_viewport_report.dart`.

### 2.4 Safe areas

The bottom safe inset is absorbed once, by whichever surface owns the bottom
edge at that moment:

- open sheet — the sheet's own container carries it, and every height ceiling
  adds the same amount so no content box shrinks
- peek — the **head** carries it, because the collapsed sheet's last
  `size.peekHeight` is where the system gesture bar lives and the Continue pill
  must clear it
- section dock — the dock carries it, and the lift it applies to the bottom
  anchors is `size.dockBarHeight` plus the same inset

---

## 3. Components, in buyer order

Each section gives: anatomy, tokens, states, copy, motion, gestures and haptics,
accessibility semantics, the snapshot fields it reads and the capabilities that
gate them, and the reference file.

### 3.1 Header

While the collapsed cart's pill carries the hold clock, the header's hold pill
is not drawn (the web's `data-peek-clock` rule); it returns for the last
minute, when the countdown is the point. A pill carrying the clock reaches the
grabber's column, so the collapsed head grows by `size.peekClockLift` and the
bar sits below the grabber.

**Name** `SeatLayerPickerHeader` · **slot** `headerStyle` · **file**
`lib/src/picker/picker_header.dart`

**Anatomy.** A row of `size.headerHeight`, on the picker's own ground
(`color.*.background`), with a hairline of `color.*.divider` under it. Left: the
brand mark, a square of `size.headerLogoSize` at `radius.headerLogo`, filled
with the accent and carrying either the organizer's logo image (cover-fitted) or
the first letter of the brand or event name in `color.*.onAccent`. Centre: the
event name at `size.headerNameFontSize`, one line, ellipsized. Right, in order:
the hold pill, the sales-closed pill, the close ring.

The venue-and-date meta line is **not drawn** on a phone. The event name alone
is the identity.

**Close ring.** A circle of `size.headerCloseSize` at `radius.pill`, hairline
`color.*.divider`, glyph in `color.*.mutedText`; the press target is expanded to
`size.minimumHitTarget` centred on it. Copy `strings.close`.

**Hold pill.** Drawn only while the picker owns a live hold — a hold handed to
the host is the host's to display (`hold.owner`). A true pill (`radius.pill`), a
dot and `m:ss` in `type.pill`, tabular figures, with a `size.minimumHitTarget`
reach. Resting look is the accent mixed lightly into the surface with accent-
toned ink; while expiring it inverts to the full accent with `color.*.onAccent`
and its dot pulses. Copy `strings.heldFor`. It is **hidden at peek while the
Continue pill is carrying the clock** — the countdown is said once.

**Sales-closed pill.** Same pill geometry, deliberately neutral — the text
colour on a lightly text-tinted surface, never the accent. Copy
`strings.salesClosedPill`. A padlock glyph leads it.

**States.** compact / wide; with and without a hold; expiring; sales closed;
event name known from the host before the runtime reports it (the runtime's name
wins once it arrives, and the swap must not be visible as a second load).

**Motion.** Pill entrance uses `motion.duration.enter` on
`motion.curve.easeEnter`, sliding a few points from the trailing edge with a
slight scale-up. The expiring dot pulse is a slow infinite breath and is skipped
under reduced motion.

**Haptics.** `haptics.holdCreated` when a hold appears, `haptics.holdEnding`
when the countdown crosses into its final minute, `haptics.holdExpired` when it
runs out. The first snapshot of a session fires none of them
(`haptics.note`).

**Accessibility.** The header is a banner. The event name is a heading. The
countdown updates politely, not assertively — it must not interrupt a screen
reader every second; announce it on the minute and on the expiring transition.

**Snapshot.** `event.name`, `event.venue`, `event.salesClosed`, `branding.logoUrl`,
`branding.brandName`, `hold.active`, `hold.expiresAt`, `hold.owner`.

### 3.2 Price rail, chips and All prices

**Name** `SeatLayerPriceLegend` · **slots** `legendChipStyle`, `chipShape` ·
**file** `lib/src/picker/picker_legend.dart`

**Anatomy.** A band of its own between the header and the map, height
`size.topRailHeight`, on `color.*.surface` with a `color.*.divider` hairline
beneath. It is not floated over the map: on a busy chart the seat numbers read
through the gaps, and the last chip clipped under the Map/3D control. Inside it,
one horizontally scrolling row of chips.

The band takes the **map chrome's** palette, so it darkens with the 3D scene,
and it is not drawn at all while the immersive scene is up.

**Chips.** Height `size.legendChipHeight` of ink inside a
`size.minimumHitTarget` reach, `radius.chip`, ground `color.*.background`,
hairline `color.*.divider`, label at `type.legendChip` with tabular figures. A
leading dot of `size.legendChipDotSize`. Selected chips take the accent ground
and `color.*.onAccent`, and the dot gains a ring in the ink colour so the colour
key survives the inversion.

On the **light** theme the dot is drawn as the category colour mixed into the
surface with a full-strength ring of the category colour — matching how the map
tints sections on light. Dark keeps the flat dot. This is a fixed recipe, not a
token.

**Amount rule.** A single price prints as itself; equal minimum and maximum
print once; otherwise `{min}+` via `strings.fromPrice`'s sibling formatting. A
category with no configured price shows its **name** instead of an amount.

**All prices.** Always the first chip, pinned so it never scrolls away, at
`type.findPill` weight on the band's own ground. Copy `strings.allPrices`. It is
selected whenever no filter narrows the map, and pressing it clears both the
band filter and any pinned category. While the scroller has scrolled, the pinned
chip carries a halo of the band ground so chips slide *under* it rather than
through it; at rest the halo is off so the first price keeps its rounded end.

**Edge fade.** The scroller masks `size.legendRailEdgeFade` of its leading edge
once scrolled, and of its trailing edge while more chips remain. Mirrored for
right-to-left.

**Sold out.** A sold-out category keeps its chip, disabled and struck through —
removing it would silently rewrite the price ladder the buyer was reading.
An **absent** availability figure means *unknown*, never zero, and is never
struck.

**States.** idle / selected / sold out / disabled; empty (the band is not
drawn); over the immersive scene (not drawn).

**Motion.** On first reveal the chips stagger in on `motion.duration.stagger`
between children, each on `motion.curve.easeEnter`. Filtering does not re-animate
the rail.

**Accessibility.** Each chip is a toggle with a pressed state; its label is the
category name and amount, plus a sold-out suffix where it applies. The rail is
a single group named for ticket prices.

**Snapshot.** `categories[]` (`key`, `label`, `color`, `priceMin`, `priceMax`,
`available`, `notForSale`), `map.categoryFilter`, `event.currency`. Live free
counts are the runtime's `category-availability-v1` reporting; a count of zero is
treated as *not reported* rather than as sold out, because a figure the buyer
cannot trust is worse than no figure.

**Command.** `picker.setCategoryFilter { keys, focus }` — the first press
filters and drills in, the second clears.

### 3.3 Map | 3D control

**Name** `SeatLayerPickerViewModeControl` · **file**
`lib/src/picker/picker_map_controls.dart`

Built only where the event offers 3D **and** the device can render it.

**Anatomy.** A segmented track at `radius.pill` on `color.*.surface` with a
hairline and a soft shadow, height `size.viewModeControlHeight`, holding two
segments of `size.viewModeButtonMinWidth` × `size.viewModeButtonHeight` at
`size.viewModeLabelFontSize`, letter-spaced, in `color.*.mutedText`. The active
segment takes the accent ground and `color.*.onAccent`.

On a phone it lives in the map's **top-right** corner, on the line below the
price rail — the rail owns the band, the control owns the corner. On wide it
joins the corner-control stack.

**Copy.** Left `strings.mapView` (accessible name `strings.flat2dMap`); right
`strings.venue3D` (accessible name `strings.interactive3dVenueView`). The group
is named `strings.venueView`.

**Behaviour.** Prefetch the 3D bundle once on first hover, focus or press-down,
so the switch is instant. Report the control's band as a viewport inset.

**Snapshot.** `map.isVenue3D`, `capabilities` (`venue3d`, plus the runtime's
`venue-3d-v1`). **Command** `picker.setBuyerView`.

### 3.4 Test chip

**Name** `SeatLayerPickerTestModeIndicator` · **file**
`lib/src/picker/picker_status_views.dart`

Required chrome for a test event. It has no host switch, and exactly one may
render.

**Anatomy.** One recipe in both themes: height `size.testChipHeight`,
`radius.pill`, label at `size.testChipFontSize` in warning ink, ground the
warning colour mixed into the surface, hairline the warning colour at half
strength, leading dot of `size.testChipDotSize` in `color.*.warning` with a soft
halo. Amber, never the accent — an environment flag must not wear "buy" gold.

**Copy.** Sentence case `strings.testMode`; the accessible name keeps
`strings.testModeLong`; the description is `strings.testModeExplained`.

**Placement.** The map's top-left corner in both 2D and 3D, at
`size.mapAnchorInset`. It steps down by the back pill's height plus
`size.mapAnchorGap` **only while the immersive scene's back pill is actually
drawn** — not merely whenever the scene is up.

**Snapshot.** `event.mode`.

### 3.5 Map corner controls

**Name** `SeatLayerPickerMapControls` · **slot** `iconButtonStyle` · **file**
`lib/src/picker/picker_map_controls.dart`

Every floating control belongs to one of seven **anchor regions** — top-left,
top-centre, top-right, left-rail, bottom-left, bottom-centre, bottom-right —
inset `size.mapAnchorInset` from the map's edges, with `size.mapAnchorGap`
between members. Regions do not receive presses; their children do. Nothing
free-floats.

**Dock lift.** While the section dock is mounted and neither a seat card nor the
immersive scene is up, the three bottom regions lift by the dock's height plus
the bottom safe inset.

#### Accessibility control (bottom-left)

A circle of `size.accessibilityControlSize` — the full
`size.minimumHitTarget` — at `radius.pill`, ground `color.*.surface`, hairline
`color.*.divider`, ink `color.*.text`, with a soft shadow. The glyph is **drawn**,
never an emoji: a wheelchair mark where the chart authors accessible seats,
otherwise a display-options glyph. Names: `strings.accessibility`, or
`strings.displayOptions` where the chart offers no provisions.

Its sheet opens upward from the button and contains switch rows:

- one row per access need the chart actually authors, in the runtime's order,
  each with its live free count — `strings.accessFreeCount`, or
  `strings.accessNoneLeft` with the row disabled at zero. A count that is *not
  counted* shows no number and is never disabled. **A provision the venue has
  but has sold out of stays on the sheet and goes dark; a provision it never had
  is absent** — "this venue has none" and "these are taken" are different
  answers. A wheelchair row carries the note `strings.companionSeatsNote` where
  the chart has companion places.
- `strings.hideLimitedView`, only where some seat is restricted or obstructed.
- `strings.colorblindSafe`.

Row anatomy: height `size.minimumHitTarget`, padding
`size.accessRowPaddingX` / `size.accessRowPaddingY`, corner `radius.button`,
icon cell `size.accessRowIconCell`, gap `size.accessRowGap`, label at
`size.accessRowLabelFontSize`, note and count at `size.accessRowNoteFontSize`.
The switch is a track of `size.accessSwitchWidth` × `size.accessSwitchHeight`
at `radius.pill` with a knob of `size.accessSwitchKnob`; off is the muted colour
at low opacity, on is the accent. Disabled rows dim and stop responding.

Filters combine as a **union**. Turning one on moves the camera to the matching
seats. The choice survives the session where the host allows it, and is restored
only for provisions that are still free.

Opening staggers the rows on `motion.duration.stagger`; **closing is immediate**
and deliberately has no exit animation.

Capability: the per-chart need list and its counts require `access-needs-v1`;
an older runtime gets the full static list from `strings.access*`. The
colourblind row additionally requires the runtime to advertise its own
colourblind-safe support. Commands `picker.setAccessibilityFilters`,
`picker.setColorblindSafe`. File: `lib/src/picker/picker_accessibility.dart`.

#### Zoom column (bottom-right)

A column of round controls of `size.mapControlSize` at `radius.pill`, gap
`size.zoomColumnGap`, ground the surface at partial opacity over a blur,
hairline the divider at partial opacity — each inside a `size.minimumHitTarget`
target.

Phone rules:

- **zoom in is never drawn.** Pinch is the gesture.
- **zoom out** appears only once the buyer is deep — seats revealed, or a
  section focused.
- **fit** is always there. Copy `strings.fitVenue`, `strings.zoomIn`,
  `strings.zoomOut`.

So the ordinary phone column is fit alone, plus zoom-out when deep.

**Commands.** `picker.zoomToFit`, `picker.zoomIn`, `picker.zoomOut`.

An overview thumbnail (minimap) is **not built on a phone**, and neither are
level-of-detail rung pills: measured against the map's top edge they restated
what the pinch had already done and covered most of it.

### 3.6 Section dock

**Name** `SeatLayerDockBar` · **slot** `dockBarStyle` · **file**
`lib/src/picker/picker_dock_bar.dart`

**Anatomy.** On a phone this is a **full-width bar pinned to the map's bottom
edge**, never a floating pill: edge to edge, height `size.dockBarHeight` plus
the bottom safe inset, square corners, a hairline on its top edge only, opaque
`color.*.surface` (never translucent), elevation `elevation.dockBar`. On the
light theme it additionally carries a real separating shadow above and below and
a slightly stronger top line, because a light bar on a light map has no edge of
its own.

Contents, leading to trailing:

1. A dot of `size.dockDotSize` in the section's colour, inset
   `size.dockLeadingInset`.
2. The section name at `type.dockSection` / `size.dockNameFontSize`, taking the
   free space, ellipsizing.
3. The seats-left count at `type.dockCount` / `size.dockCountFontSize`, which
   **collapses before the name does** and may never be clipped.
4. Previous / next section steps, `size.dockNavWidth` × `size.dockNavHeight`,
   gap `size.dockNavGap`, glyphs at `size.dockNavIconSize`, at `radius.pill`
   with a hairline. Disabled at the ends of the section list — they never wrap
   around.
5. The labelled way out: height `size.dockBackHeight`, `radius.pill`, ground
   `color.*.surface`, hairline the accent mixed into the divider, ink the
   accent-toned text colour, chevron at `size.dockBackChevronSize`, label
   `strings.overview` at `size.dockBackFontSize`. A tinted ground was measured
   below contrast and removed; the ground is the plain surface.

**Price is deliberately absent** from the dock. The rail answers cost.

**Count fit ladder.** Measure after mount and on every resize, and degrade
**full → short → hidden**: `strings.seatsLeftInSectionOne` /
`…Other` first, then `strings.seatsLeft`, then nothing. The full count always
stays in the bar's accessible name. Where `sections[].seatsLeft` is unknown, no
count is drawn.

**States.** Hidden at the venue rung; visible when a section is focused; hidden
while a seat card owns the bottom edge; hidden in the immersive scene.

**Motion.** Slides up on `motion.duration.dock`. A pan onto a new section
**updates in place** and cross-fades the name and count on
`motion.duration.crossfade` rather than rebuilding. Departure uses
`motion.duration.exit`.

**Haptics.** `haptics.sectionFocused` when the focused section changes to a real
section. Returning to the overview fires nothing — the buyer already felt the
tap that took them there, and leaving a place is not the same news as arriving.

**Accessibility.** The bar is a group named for the focused section, carrying
the full seats-left sentence whatever the visible ladder chose. The steps are
buttons named `strings.previousSection` / `strings.nextSection`.

**Snapshot.** `sections[]` (`id`, `label`, `displayLabel`, `color`,
`dominantCategoryKey`, `seatsLeft`), `map.rung`, `map.focusedSectionId`.
Prefer `dominantCategoryKey` over a copied colour when painting the dot: the key
survives a colourblind-safe palette and a category recolour.
**Commands** `picker.focusSection { id }`, `picker.overview`.

### 3.7 Floor rail

**Name** `SeatLayerFloorStrip` · **slot** `floorStripStyle` · **file**
`lib/src/picker/picker_floor_strip.dart`

Drawn only on a multi-floor venue, and never in the immersive scene. It flows in
the **left-rail** region, starting at the map's own top edge and stepping below
the Map/3D control where that is drawn.

**Anatomy.** A track at `radius.pill` on the surface at high opacity over a
blur, hairline `color.*.divider`, padding `size.floorRailPadding`, gap
`size.floorRailGap`, horizontally scrollable. Each chip: height
`size.floorChipHeight`, padding `size.floorChipPaddingX`, label at
`size.floorChipFontSize`, `radius.pill`; idle ink `color.*.mutedText`,
selected the accent ground with `color.*.onAccent`. An info glyph of
`size.floorInfoSize` closes the track, inside a `size.minimumHitTarget` target.

`strings.allFloors` is the first chip where the runtime offers an all-floors
view.

**Capability.** `floor-stack-v1`. Without it the floor list is not offered.

**Accessibility.** A group named for floors; each chip a toggle with a pressed
state.

**Snapshot.** the runtime's floor list and the active floor.
**Command** `picker.setFloor`.

### 3.8 Seat card

**Names** `SeatLayerConfirmCard` (+ its parts and actions) · **slots**
`confirmCardStyle`, `primaryButtonStyle`, `secondaryButtonStyle`, `pillStyle`,
`scrimColor` · **files** `lib/src/picker/picker_confirm_card.dart`,
`picker_confirm_card_parts.dart`, `picker_confirm_card_actions.dart`,
`picker_confirm_card_placement.dart`

The card is the picker's one native *moment*: the map dims behind it, it springs
in from the seat's side, and it asks one question.

#### 3.8.1 Box

Width `size.confirmCardMaxWidth`, capped at the map width less
`2 × size.confirmCardGutter`. Corner `radius.confirmCard`, elevation
`elevation.confirmCard`, ground `color.*.surface`, hairline a mix of the divider
toward the text so the card has an edge on both themes.

Behind it, the map is **dimmed, never blurred** — a blurred map turns the seat
the card is asking about into colour. The wash is ink at partial opacity, and it
is a style slot (`scrimColor`); the default pales the seats and keeps the tapped
one legible. While the card is up, the rest of the chrome is *paused*: the
anchors dim and stop receiving presses, and the cart sheet dims and goes inert.
The **bottom-centre** region is the exception — it comes forward at full opacity
above the card, because it carries the toast that is the *reply* to the tap, and
it stays press-through so it can never steal Cancel or Add seat.

#### 3.8.2 Placement — rest or hug

Four constants, all tokens:

| Token | Meaning |
| --- | --- |
| `size.confirmCardRestInset` | daylight between the resting card and the map's foot |
| `size.confirmCardSeatGap` | daylight between the card and the seat it hugs |
| `size.confirmCardTopInset` | the closest the card may come to the map's top |
| `size.confirmCardClearance` | extra room below the resting card before the seat counts as covered |

The rule, with the seat's y in map-local coordinates:

```
covered = seatY >= mapHeight - restInset - cardHeight - clearance
if not covered  ->  rest:  the card sits restInset above the map's foot,
                           notch none, and points at nothing
else            ->  hug:   the card's bottom edge sits seatGap above the seat,
                           clamped so its top never rises above topInset,
                           notch on the bottom edge pointing down at the seat
```

A card that would sit *below* the seat was never in the seat's way, so it rests
instead. `topInset` and `bottomInset` passed to the rule are the bands the
picker's own chrome stands on, so the card never slides under the dock or behind
the floor rail.

The card's **growth origin** is always the tapped seat, whichever placement was
chosen.

**Capability.** The seat's screen point requires `seat-screen-point-v1`
(`selection[].screenPoint`). Until a runtime reports it the card rests, and that
is a correct state, not a degraded one.

#### 3.8.3 Anatomy, 2D

1. **Identity grid**, height `size.confirmIdentityHeight`. Three labelled cells
   — section, row, seat — divided by hairlines, with a hairline under the grid.
   The section cell is widest and may wrap to two lines; the row and seat cells
   never wrap. Eyebrows are small, letter-spaced, uppercase, in
   `color.*.mutedText`; values are `type.confirmIdentity`. Where there is no
   section the grid becomes two equal centred cells. A missing value prints an
   em dash. Copy: `strings.sectionWord`, `strings.rowWord`, `strings.seatWord`,
   `strings.placeWord` — the row eyebrow follows the object's own word (Row,
   Table, Booth). **Print the row with its section prefix stripped**, or the card
   reads `Stalls D · Row Stalls D C`.
2. **Category band**, minimum height `size.confirmBandHeight`. Ground is the
   category colour at 11 % over the surface — a *tint*, not a fill, so the ink
   stays the theme's own and no category needs a manufactured ink. A 3 pt rail
   of the full category colour runs down the leading edge, drawn under the
   padding. (11 % and 3 pt are fixed recipe constants.) Contents: a 9 pt dot in
   the category colour with a hairline ring; the category name; the seats-left
   count (`strings.seatsLeft`), which is the cell that gives way, because a
   truncated category name is a seat the buyer cannot identify; the price at the
   trailing edge in tabular figures. The count is **absent when it has not
   arrived**. `strings.onlyLeft` is available as a scarcity telling for a host
   that wants one.
3. **Photo strip**, height `size.confirmPhotoHeight`, full-bleed inside the
   card's corner, drawn **only where the seat has a real uploaded photograph**
   (`seatViewKind == 'real'`, capability `seat-view-thumbnail-v1`); a generated
   stand-in is never offered from the card, though 3D and 360° are unchanged. Over it, in
   the trailing bottom corner, a group of pills of `size.confirmPillHeight` at
   `radius.pill` on a dark plate with white ink in **both** themes: `View from
   here` (`strings.viewFromHere`) and `3D` (`strings.venue3D`, accessible name
   `strings.seeItIn3D`). A sightline caption may sit in the trailing top corner
   on the same plate. If the image never arrives the strip animates away.
4. **No-photo rail**, height `size.confirmRailHeight`, when there is no photo
   but 3D is on offer: a plain divider-tinted strip carrying the same pills, but
   flipped to theme tokens — surface ground, text ink, no plate. A 3D-only card
   never draws an empty photo frame.
5. **Tier picker**, only where the seat has more than one tier. Legend
   `strings.ticketType`; rows of `size.confirmTierHeight` at `radius.button`,
   name, note and price; the selected row takes an accent hairline, an accent
   tint and an accent rail. A single tier renders as a guidance line
   (`strings.tierCompanionGuidance` and its kin), never as a one-option choice.
   File `lib/src/picker/picker_ticket_tiers.dart`.
6. **Notices** — a premium chip (`strings.premiumSeat`) and a limited-view
   warning (`strings.restrictedView` / `strings.obstructedView`, restricted
   wins) — as their own small blocks above the actions.
7. **Actions**, height `size.confirmActionHeight`, each in its own rounded box
   at `radius.button` inside the card's gutter — not a bar fused to the card's
   bottom edge, which read as the frame rather than as things to press. Cancel
   takes about a third of the row and carries a hairline and muted ink; Add seat
   takes the rest, filled with the accent. Neither may wrap.
   Copy: `strings.cancel`; `strings.addSeat` for a seat and `strings.select` for
   a booth, table or general-admission unit. **No price on the button** — the
   price is already in the band above.

`See it in 3D` as a **full-width action** at `radius.button` is the wide
composition's form; the phone uses the strip pill.

#### 3.8.4 Motion

| Moment | Duration token | Curve | What moves |
| --- | --- | --- | --- |
| entrance | `motion.duration.cardEnter` | `motion.curve.spring` | opacity in, a small rise and scale-up, growing from the seat's direction |
| invitation — sweep | `motion.durationOutsideBudget.inviteSweep` after `motion.durationOutsideBudget.inviteDelay`, once | `motion.curve.easeEnter` | a soft band of the button's own ink sweeps across `Add seat` |
| invitation — breathe | `motion.durationOutsideBudget.inviteBreathe`, from `motion.durationOutsideBudget.inviteBreatheDelay`, repeating | ease in and out | a halo grows and fades with a ~2 % scale |
| invitation stops | — | — | on the first touch or key anywhere on the card, or focus on the button |
| press sweep | `motion.duration.pressSweep` | `motion.curve.easeEnter` | the button fills with its own ink from the leading edge |
| press tick | `motion.duration.pressSweep` | `motion.curve.easeEnter` | the check mark draws itself |
| label swap | immediate | — | `strings.addSeat` → `strings.added` |
| card exit | `motion.duration.exit` after the sweep | `motion.curve.easeExit` | opacity out, a small fall and scale-down |
| flight chip | `motion.durationOutsideBudget.confirmFlight` | `motion.curve.spring` | a small pill in the category colour carrying the seat label flies from the card to the cart summary |

**Commit-on-press ordering is fixed.** The cart, the totals and every snapshot-
derived surface update on the **press tick**. Only the card's *departure* is
sequenced behind the sweep. The button locks on the press without losing focus,
and a second press while it is committing is ignored. Under reduced motion the
invitation never starts, the sweep and tick do not play, the flight chip is not
created at all, and the card departs on the press without waiting.

The **flight target** is measured *before* the count reflows: on a phone that is
the peek summary.

While a card is up and a toast is showing, the whole bottom-centre region moves
so the message sits **above** the card — unless that would push it within a
short distance of the map's top, in which case it stays where it is.

#### 3.8.5 Gestures and haptics

- Tap outside the card, on the dimmed map, gives the seat back.
- A downward drag past a comfortable flick distance, or a fast downward flick
  however short, dismisses it. (The distance and velocity are native tuning
  constants, not tokens; the rubber-band feel comes from
  `motion.physics.rubberBand`.)
- `haptics.cardArrived` when the card lands, `haptics.seatConfirmed` on Add
  seat, `haptics.cardCancelled` on any dismissal.

#### 3.8.6 Accessibility

The card is a dialog: it names itself, it scopes the route, everything painted
before it is hidden from assistive technology, and dismissing returns focus to
the map region. The identity reads as one sentence — section, row, seat,
category, price — not as six unlabelled cells, and that sentence IS the
dialog's name. Both answers are also custom actions on the card, so a rotor can
say yes or no without hunting for the buttons.

The first focusable is `Add seat`, not `Cancel`, though `Cancel` is drawn
first: the focus lands on the answer the card exists to collect. Escape and the
platform's back gesture both give the seat back. The card's type is clamped at
`type.scaleClamp.card`, and its action row's height grows with that scale
rather than clipping the word the card exists to offer. §4.10 has the whole
picture, of which this is one surface.

**Snapshot.** the newest unconfirmed `selection[]` entry (`label`,
`sectionLabel`, `rowLabel`, `seatNumber`, `price`, `currency`, `objectType`,
`tiers`, `screenPoint`), the matching `categories[]` entry, `capabilities`
(`seatView`, `venue3d`), the event's seat-view photo.
**Commands** `picker.openSeatView`, `picker.showSeatIn3D`, `picker.deselect`.

### 3.9 Peek bar (collapsed cart)

**Name** `SeatLayerCartSheet` (peek head) · **slots** `sheetStyle`,
`continueButtonStyle` · **file** `lib/src/picker/picker_cart_sheet.dart`

**Anatomy.** Height `size.peekHeight` plus the bottom safe inset, ground
`color.*.surface`, corner `radius.sheet`, elevation `elevation.sheet`, hairline
on its top edge. A grabber of `size.sheetGrabberWidth` ×
`size.sheetGrabberHeight` at `radius.pill` sits `size.sheetGrabberInset` from
the top, centred, at reduced opacity — it overlaps into the same row rather than
taking a row of its own. Trailing, a chevron of `size.sheetToggleSize` pointing
**up** while collapsed and rotating over `motion.duration.chevron` on
`motion.curve.easeEnter` when the sheet opens.

The summary line is `type.peekSummary`, one line, ellipsized, with its
secondary half in `color.*.mutedText`.

**The Continue pill** is a true pill (`radius.pill`), height
`size.minimumHitTarget`, accent ground, `color.*.onAccent` ink,
`type.peekPill`, tabular total. It is a real button and runs the **same**
checkout action the sheet's footer button runs: from the collapsed bar the pill
*is* the way to pay. It is hidden entirely while the sheet is open, where the
footer says the same thing.

**Find seats** is the empty bar's one door: height `size.findPillHeight` of ink
inside a `size.minimumHitTarget` reach, `radius.pill`, accent-filled, a sparkle
glyph and `strings.findSeats`. Pressing it opens the sheet on the best-seats
form and moves focus to that form's action. It is withheld where the form would
be refused — a performance group, closed sales, or an existing hold.

**Every line the peek can say**, in resolution order (one resolver drives the
collapsed pill, the sheet's button and the wide bar, so they can never
disagree — `lib/src/picker/picker_checkout_cta.dart`):

| Condition | Line |
| --- | --- |
| tickets, securing | `strings.securingSeats`, no pill |
| tickets, opening checkout, prices shown | `strings.peekSecured` |
| tickets, opening checkout, prices suppressed | `strings.seatsSecuredOpeningCheckout` |
| tickets, idle | `strings.ticketCount…` + the pill — `strings.secureMore` where a hold exists and more are pending, else `strings.continueWord` — then the total, then the live `m:ss` while a hold runs |
| sales closed, nothing picked | `strings.salesClosedPill`, no pill |
| empty, a price is known | `strings.fromPrice` + Find seats |
| empty, no price | `strings.pickYourSeats` + Find seats |

The peek pill is **never rendered disabled**: the states that would disable it
render a different line instead. The footer button carries the disabled
language.

**Motion.** The count swells once on `motion.duration.bump` when it changes
while collapsed — the only feedback a buyer gets that a tap on the map reached
the cart with the sheet shut. On first reveal the bar rises last, after the map
and rail.

**Gestures.** The **whole head** is the toggle. A drag up past a small threshold
opens; a drag down past it collapses; a press with almost no movement toggles.
The gesture must not start on the dock, the chevron or the pill — and that guard
must be evaluated at press-down, before any pointer capture retargets later
events. A tap on the map collapses an open sheet back to peek.

Springs, not tweens: `motion.physics.sheetSpringMass`,
`…Stiffness`, `…Damping`, with `motion.physics.sheetFlingVelocity` as the
threshold at which a flick decides on its own and `motion.physics.rubberBand`
for over-drag.

**Accessibility.** The head is one button with an expanded state, named
`strings.expandCart` / `strings.collapseCart`. The summary is a live region that
updates politely.

**Snapshot.** `cart.ticketCount`, `cart.cartTotal`, `cart.lines[]`, `hold`,
`event.currency`, `event.salesClosed`, `capabilities.bestAvailable`.

### 3.10 Expanded sheet, cart rows and foot

#### 3.10.1 The sheet

Content-height, growing ticket by ticket, capped at:

| State | Ceiling |
| --- | --- |
| open with tickets | the lesser of `size.sheetMaxHeightFraction` of the height and `size.sheetMaxHeight`, plus the safe inset |
| open with an empty cart | the lesser of `size.emptyTrayMaxHeightFraction` and `size.emptyTrayMaxHeight`, plus the safe inset |
| a native-only full detent | `size.sheetFullHeightFraction` |
| peek | `size.peekHeight` plus the safe inset |

At peek, every child except the head is not drawn. The open head shrinks to
`size.sheetOpenHeadHeight`, its summary grows to `type.peekSummaryOpen`, and the
chevron's ink shrinks to `size.sheetToggleOpenSize` inside the same
`size.minimumHitTarget` target.

**The sheet never opens itself.** Only the buyer opens it — the grabber, the
chevron, a swipe, or `Find seats`.

#### 3.10.2 Cart rows

**Name** `SeatLayerCartList` · **file** `lib/src/picker/picker_cart_list.dart`

One plate: a column on `color.*.surface` with a hairline and corner
`radius.base × radius.smallRatio`, rows divided by hairlines rather than each
row being its own card.

Each line is `size.denseLineHeight` — not less: a remove glyph of
`size.denseRemoveSize` inside a `size.minimumHitTarget` target cannot reach the
floor in a shorter row. Contents: a category dot, then the identity at
`type.denseLine` with tabular figures — the **section** (or the seat label where
there is no section) is the only part that ellipsizes, then a muted separator,
then the row and seats, which never shrink. The category **name** is not on the
line; its colour is the dot, and the name goes to the accessible label.
Trailing: a multiplier at `type.denseMultiplier`, the amount, and the remove
control.

**Held rows** wear a wash of the accent at low strength and an accent rail on the
leading edge, and the dot becomes a **lock** — a lock is not a colour.

**Folding.** Consecutive tickets fold into one run only when held-state,
section, row, category and price all match. A run's seats print as a true
consecutive range (`1–6`) where they really are consecutive; otherwise up to
three labels and then `+N`. A ticket that carries its own control — a table's
guest count, a tier choice, an accessibility marker — is **never** folded. A run
of one is not a run and keeps its dot. An opened run lists its members **in seat
order**, matching the range its own label states, indented on a faint ground. A
run's remove control removes the whole run, and says so.

The fold chevron is `size.denseRunToggleWidth` of ink inside a full-size target
and rotates on press.

**Overflow.** Once there are `size.denseCollapseFrom` runs, everything past
`size.denseVisibleLines` collapses behind a row of `size.denseMoreRowHeight` at
`type.denseMore`, reading `strings.moreCount` ↔ `strings.showLess`.

**Motion.** A row arrives on `motion.duration.enter` with a small rise and
scale-up; a removed row collapses on `motion.duration.exit`. A swipe on a row
settles from the finger, committing past `motion.physics.swipeCommitFraction` of
its width or above `motion.physics.swipeFlingVelocity`.

**Haptics.** `haptics.ticketRemoved`.

**Undo.** A removal is offered back for
`motion.durationOutsideBudget.undoWindow` as a toast action
(`strings.undo`, `strings.seatRemoved`).

**Commands.** `picker.deselect { label }`, and the runtime's
`cart-line-remove-v1` for a line the selection cannot name.

#### 3.10.3 Foot

Order: the lapse notice if there is one, then the checkout button, then the
attribution.

**Checkout button** — `SeatLayerBookButton`, slot `primaryButtonStyle`. Full
width, height `size.checkoutButtonHeight`, corner `radius.button`,
`type.bookButton`, accent ground with `color.*.onAccent`. It carries **its own
label only**; the total is already on the peek bar. Disabled is a designed
state, not a Material grey: a surface-toned ground, muted ink, an inset hairline
— Material's own disabled colours vanish on the dark scene sheet.

Label ladder, in priority order:

1. sales closed → disabled, `strings.salesClosedCta`
2. a seat card or table prompt is open → disabled,
   `strings.confirmOrCancelSeat` / `strings.confirmTable`
3. securing → disabled, spinner, `strings.securingSeats`
4. opening checkout → disabled, spinner, `strings.openingCheckout`
5. the selection breaks the event's rules → disabled,
   `strings.chooseMore` / `strings.removeTickets…` / `strings.adjustSelection`
6. a hold exists and more are pending → `strings.secureMoreAndCheckout`
7. a hold exists, nothing pending → `strings.continueToCheckout`
8. tickets, no hold → `strings.holdAndCheckout`
9. nothing picked → disabled, `strings.selectSeats`

**Commands.** `picker.checkout`, then `picker.rejectHandoff`
(`checkout-handoff-reject-v1`) if the host refuses the handoff, so a rejected
hold is never stranded. Checkout phases run idle → holding → checkout and each
phase ends where the work ends, never on a timer.

**Attribution** — `SeatLayerPickerAttribution`, height
`size.attributionHeight`, `type.attribution`, centred at the **foot of the
sheet**, where a phone's rounded corner cannot clip it. It reads the map
chrome's palette, not the picker's, so its words survive on the dark scene
sheet. Copy `strings.poweredBy`. Drawn when `branding.attributionRequired`; a
white-label entitlement hides it server-side, with no host switch.

The total is **not** repeated in the foot, and there is no separate "secured"
strip on a phone: the head says the count and total once, the header pill is the
clock, and each held line's remove control releases one seat.

### 3.11 Best-seats form

**Name** `SeatLayerBestSeatsForm` · **file** `lib/src/picker/picker_best_seats.dart`

Shown in the sheet while the cart is empty, and hidden the moment the cart has
anything — once a phone cart has tickets it stays a cart. It is a card with an
accent-tinted gradient ground and an accent-mixed hairline.

**Row order on a phone** — one decision per row, with the DOM/semantic order
unchanged so focus order still follows the page:

1. the premium chip, only where the chart has premium seats
2. ticket type, full width
3. venue zone, full width, **only where the venue has zones**
4. the quantity stepper, leading, on the last row
5. the action, trailing, on the same row

Names take full lines; the narrow fixed-width stepper shares the last one.

**Selects** — height `size.bestSeatsSelectHeight`, corner `radius.control`,
ground `color.*.surface`, hairline `color.*.divider`, label at
`type.bestSeatsSelect`, with a drawn chevron. Copy `strings.anyTicketType`,
`strings.anyVenueZone`, and the chart's own names. Where there is exactly one
category the select is omitted and takes no row.

**Stepper** — width `size.bestSeatsStepperWidth`, height
`size.minimumHitTarget`, corner `radius.control`, hairline, with two buttons
inside it and a tabular value between. Copy `strings.fewerTickets`,
`strings.moreTickets`.

**Action** — height `size.minimumHitTarget`, corner `radius.control`, accent
ground, `type.bestSeatsGo`, with a leading sparkle. Copy
`strings.findBestSeatsOne` / `strings.findBestSeatsOther`; busy is
`strings.findingBestSeats` with a spinner, keeping the accent at slight
transparency rather than going grey. Disabled uses the same designed disabled
language as the checkout button.

**Replace-confirm face.** Where the buyer already has manual picks, the form
asks before replacing them, as an alert with a two-button row. The manual
tickets are removed **only after** a new group is secured.

**Capability.** `capabilities.bestAvailable`.

**Motion.** Each returned seat pops in on `motion.duration.pop`, staggered by
`motion.duration.stagger`.

### 3.12 Toasts

**Names** `SeatLayerPickerToast`, `…ToastQueue`, `…ToastCard`, `…ToastLayer` ·
**file** `lib/src/picker/picker_toast.dart`

**Anatomy.** One centred card in the bottom-centre region, lifted by the dock
when it is up and moved above the seat card when one is open. Ground
`color.*.surface`, hairline, corner 16 pt (a fixed recipe), ink `color.*.text`,
type at `type.peekSummary` weight, and it **wraps** — a toast is a sentence, not
a chip. With an action it becomes a row: the sentence, then a pill at
`radius.pill` on the accent.

**Tones** change only the border: neutral takes `color.*.divider`, error takes
`color.*.error` and shakes once, warning takes the accent, success takes a green.

**Motion.** Rises on `motion.duration.toast` on `motion.curve.easeEnter`, dwells
for `motion.durationOutsideBudget.toastDwell`, then leaves and resets to
neutral. One queue: a second toast replaces the first rather than stacking.

**Accessibility.** A polite live region. A toast is never the only place a
consequence is stated — anything that outlives 4 seconds also has a persistent
form (see 3.13.7).

### 3.13 Buyer-facing states

**Booked ("You're all set").** Never shown on the hand-off: a buyer on the way
to pay has not paid. It appears only when the handed-off hold settles to
booked — the hold vanishes from the snapshot with no `hold.expired` announced
first — which is the web picker's `detectBooked` rule. The expiry is read off
the bridge on the same hop as the snapshot that follows it, so the order on the
wire (expiry, then snapshot) is the order the decision sees. A host hears the
same moment once through `onBooked(handoff)`. Port note: RN / iOS / Android
must gate their success screen the same way; showing it on hand-off was the
bug DesiPass hit when a buyer backed out of checkout without paying.

Every state below is a **designed state**, not a set of disabled controls.

#### 3.13.1 Loading

`SeatLayerPickerLoadingView` — `lib/src/picker/picker_status_views.dart`.
Fills the map area on `color.*.background`. It draws the **venue silhouette**,
not a spinner: three concentric seating shells around a stage, in the accent at
low opacity, breathing slowly under a diagonal sweep, with a thin indeterminate
progress strip at the top of the map. The sentence
`strings.loading` is announced but not drawn.

Reveal sequence, once the runtime has framed the map: the loading surface fades
out over `motion.duration.exit`-scale time, a sweep passes over the shells for
`motion.durationOutsideBudget.shellSweep`, the rail chips stagger in, and the
peek bar rises last; the whole arrival is done by
`motion.durationOutsideBudget.revealDelay`. Under reduced motion the loading
surface is simply removed — no fade, no sweep, no stagger.

The load itself: adopt a prewarmed runtime page only **after** the picker has
been laid out, so the chart's first paint is at its final size; hold the loading
surface until the runtime reports that it has framed the map inside the native
chrome, with a short backstop for a runtime that never answers.
`chart-load-trace-v1` carries what the load cost, for the host's own analytics;
the SDK logs and sends nothing.

#### 3.13.2 Error

`SeatLayerPickerErrorView`. Replaces the loading content, on the same ground:
a title `strings.mapDidNotLoad`, a line `strings.checkConnection`, and an action
`strings.retry` at `radius.button` on the accent. Retry fully remounts the
picker rather than patching a half-built one.

#### 3.13.3 Access

`SeatLayerPickerAccessPanel` — `lib/src/picker/picker_states.dart`. A veiled
overlay over the whole picker: the ground at high opacity over a blur, a centred
card at `radius.base`-scale corner on `color.*.surface` with a hairline and a
deep shadow, a circular icon badge in an accent tint, a title, a body and, where
there is one, an action pill.

Four variants:

| Reason | Title | Body | Action |
| --- | --- | --- | --- |
| paused | `strings.accessPausedTitle` | `strings.accessPausedCopy` | `strings.retry` |
| revoked | `strings.accessRevokedTitle` | `strings.accessRevokedCopy` | — |
| expired (no token, provider failed) | `strings.accessExpiredTitle` | `strings.accessExpiredCopy` | `strings.reloadSeatMap` |
| unverified (default) | `strings.accessUnverifiedTitle` | `strings.accessUnverifiedCopy` | — |

All four are set as plain text and never parsed as markup. While retrying, the
icon spins and the action is disabled. Under reduced motion the card is simply
present, with no entrance.

A polite live region.

#### 3.13.4 Sales closed

Said in five places, each a different job:

- header — `strings.salesClosedPill`, neutral
- peek line — the same words, no pill
- checkout button — disabled, `strings.salesClosedCta`
- toast on any attempted action — `strings.salesClosedToast`, warning tone
- **tray statement** (`SeatLayerPickerSalesClosedStatement`) — a card on a
  neutral text-tinted ground with `strings.salesClosed`,
  `strings.salesClosedCopy`, and the event's own date line

Neutral throughout, never the accent.

#### 3.13.5 Sold out

`SeatLayerPickerSoldOutOverlay`. A veil over the map on the ground at high
opacity over a blur, centred: an uppercase letter-spaced eyebrow — the brand or
event name, falling back to `strings.soldOutEyebrow` — then a large
`strings.soldOutTitle`, then `strings.soldOutCopy` in `color.*.mutedText`.

The predicate: **every seated category's live free count is zero, there is at
least one seated category, and the chart has no general-admission areas.** It
clears live. Informational only — there is no waitlist.

#### 3.13.6 Hold pill and countdown

The clock is `m:ss`, floored at zero, ticking twice a second so a second never
appears to skip. The same tick updates the peek clock. `is-expiring` begins at
one minute remaining. The countdown **stops the moment a read finds the hold
gone**, even when the snapshot in hand still describes a live one: it was read
before the reconciliation that ended it, and a clock still running over released
seats is the one thing that can leave a buyer reassured right up to a failed
checkout.

#### 3.13.7 Hold expired, and hold lapsed

A plain expiry is `strings.holdExpired`, warning tone — but it is deferred by
one tick, because a richer telling may cancel it.

When a refresh can explain the lapse (`availability-refresh-v1`), the telling is
counted on what the offer would re-take:

| Shape | Copy | Tone | Action |
| --- | --- | --- | --- |
| all recoverable | `strings.holdLapsedStillFreeOne` / `…Other` | warning | `strings.reselectSeatsOne` / `…Other` |
| some taken | `strings.holdLapsedSomeTakenOne` / `…Other`, counted on how many are **gone** | warning | same |
| none recoverable | `strings.holdLapsedAllTakenOne` / `…Other` | error | — |

Because a toast is gone in four seconds, the same sentence is repeated as a
**persistent line in the cart sheet** on a warning-tinted ground with the same
action. The recoverable set comes from the refresh outcome, never from local
memory. A seat sold between the offer and the tap is a real race and is reported
the way every failed hold is: the seats stay selected and unheld, never claimed.
`strings.holdLapsedTitle` / `strings.holdLapsedBody` /
`strings.seatsNotRecovered` cover the fuller telling.

`haptics.holdExpired` fires from the runtime's own expiry signal, never from a
snapshot: a snapshot only shows a hold going inactive, and a buyer releasing
their seats deliberately must not feel like a loss.

#### 3.13.8 Need more time

`SeatLayerPickerExtendHoldPrompt`. A card in the bottom-centre region above the
toast: `strings.seatsHeldForNeedMoreTime` with a live `m:ss`, and a pill
`strings.addTime` → `strings.addingEllipsis`. Shown while the hold has under a
minute left and the booked overlay is not up. Success is
`strings.moreTimeAdded`; failure is `strings.couldNotAddMoreTime`, warning tone.

#### 3.13.9 Seat taken

`strings.seatJustTakenByAnother`, error tone, for one seat;
`strings.seatsJustTaken` for a bulk conflict. While a seat card is up this toast
is the *reply to the tap*: its region comes forward at full opacity above the
card, and stays press-through.

#### 3.13.10 Booked overlay

`SeatLayerPickerBookedOverlay`. Covers the whole picker on `color.*.background`:
a round accent badge that pops and draws a check; `strings.allSetTitle`; a
subtitle of the ticket count plus `strings.confirmedAndOnWay`; a scrolling list
of the seats as pills; and a way back, `strings.backToMap`, at `radius.pill`,
focused on the next frame. The copy rises in sequence behind the badge.

#### 3.13.11 General-admission prompt

`SeatLayerPickerGeneralAdmissionPrompt` — `lib/src/picker/picker_prompts.dart`.
On a phone this is a **bottom sheet** (on wide, an anchored popover), one focus
trap either way. A scrim, then a sheet with rounded top corners on
`color.*.surface`: an uppercase eyebrow, a large title, a subtitle, a close
control, then one row per area with a stepper, a total row, an optional hint,
and a full-width action pair whose bottom padding absorbs the safe inset.
Copy `strings.generalAdmission`, `strings.placesAvailable`,
`strings.addTickets`, `strings.continueWithTotal`, `strings.removeWord`.
Steppers use `strings.fewerTickets` / `strings.moreTickets`. Springs in on
`motion.duration.sheet` with `motion.curve.spring`; still under reduced motion.

#### 3.13.12 Table prompt

`SeatLayerPickerTablePrompt`. The same bottom-sheet shape. Eyebrow, title,
`strings.chooseGuestsCopy`, a summary grid, `strings.numberOfGuests` over a wide
stepper, a range caption `strings.chooseMinMaxGuests`, and the action pair
`strings.cancel` with `strings.selectTable` / `strings.updateTable`. Labels
`strings.fewerGuests` / `strings.moreGuests`. Accessible name for the whole
sheet: `strings.chooseTableGuests`. Capability `table-quantity-v1`.

### 3.14 3D chrome

**Name** `SeatLayerVenue3D` · **slot** `pillStyle` · **file**
`lib/src/picker/picker_venue_3d.dart`

**Glass recipe.** All 3D chrome wears one **dark glass** whatever the resolved
mode is, because it floats over a rendered venue:
ground `color.dark.immersiveGlass`, hairline
`color.dark.immersiveGlassBorder`, ink `color.dark.immersiveGlassInk`, blur
`size.immersiveGlassBlur`. Captions use the deeper
`color.dark.immersiveCaption`, `…Border`, `…Ink` with
`size.immersiveCaptionBlur`. A shared helper draws it once so no surface
re-mixes it.

**Back pill** — top-left, height `size.immersiveBackPillHeight`, `radius.pill`,
label at `size.immersiveBackFontSize`, chevron at `size.immersiveBackIconSize`.
Copy `strings.backToVenue`. Drawn **only while the buyer is sitting in an exact
seat** — it is the way out of a seat, not out of the scene.

**Badge stacking.** The test chip owns the same corner. It steps below the back
pill by the pill's height plus `size.mapAnchorGap`, and only while the pill is
actually drawn.

**Deck** — the bottom row: a caption chip naming the seat, then previous seat,
`strings.openVenue360`, next seat, and recentre. Chips are
`size.immersiveNavChipHeight` tall with `size.immersiveNavChipPaddingX` padding
and `size.immersiveNavChipFontSize` labels, at `radius.pill`; the close control
is `size.immersiveNavCloseSize`. Every one keeps a `size.minimumHitTarget`
reach. Copy `strings.previousSeat`, `strings.nextSeat`, `strings.recentre`.
The stepper is disabled in venue mode.

**Caption** — `size.immersiveCaptionFontSize` on the caption glass at
`radius.chip`, naming the seat.

**Nav mode** — `SeatLayerPicker3DNavigationModeButton`: a two-state control for
orbit versus pan, `strings.orbitMode` / `strings.panMode`, with the drag hints
`strings.rotateVenue` / `strings.moveVenue`.

**Motion.** The chrome settles on `motion.duration.immersive`. The recentre
control arrives with a single spin on `motion.curve.spring`.

**Capabilities.** `venue-3d-v1` for the scene, `venue-3d-controls-v1` for the
deck. Both, plus `capabilities.venue3d`, must hold.

**Commands.** `picker.showSeatIn3D`, `picker.openVenue360`,
`picker.setBuyerView`, `picker.recentre3D`.

### 3.15 Seat-view chrome

**Name** `SeatLayerSeatViewChrome` · **slot** `seatViewChromeStyle` · **file**
`lib/src/picker/picker_seat_view_chrome.dart`

The native caption strip drawn over the 2D view-from-seat panorama: the seat's
identity, `strings.viewFromYourSeat`, a disclosure badge and a drag hint, on the
caption glass at `radius.chip`.

**Capability.** `native-seat-view-chrome-v1`. A runtime advertising it is asked
at `init` to suppress its own words. Consequently, a host that hides this strip
**owns the disclosure itself** — turning the native strip off does not give the
words back to the runtime.

---

## 4. Porting checklist

Platform-neutral concerns every SDK must solve the same way.

**4.1 Tokens generator.** `tokens.json` is the input, not a reference. Generate
a typed constant set per platform at build time and read every number through
it. Never transcribe a value into a view. The generated file is checked in and
regenerated, never hand-edited. (Flutter: `lib/src/picker/picker_tokens.g.dart`.)

**4.2 Style slots.** Expose the same named slots so one element can be restyled
without replacing the widget that draws it: primary action, secondary action,
the peek Continue, icon buttons, chip shape, legend chip, floor strip, seat-view
chrome, dock bar, confirm card, sheet, header, pill, and the map scrim colour.
Each slot is *partial* — an unset field keeps the spec's value. Each element that
owns a slot also takes a per-instance override that wins over the theme.

**4.3 String overrides.** Every buyer-facing string in `strings` is overridable,
individually, without replacing the set. Counted strings need one/other forms
(and the plural categories the platform's own locale rules require). Access-need
names are overridable by need. The picker ships localized defaults; a host
override always wins.

**4.4 Reduced motion.** One accessor decides. Read the platform's own
"reduce motion" setting and route every duration through it, so a surface cannot
forget. Motion with no reduced form is skipped, and anything sequenced behind it
must run immediately instead.

**4.5 Haptics gate.** One host switch turns the whole vocabulary off, and the
platform's own setting turns it off again. Firing is best-effort and failure is
swallowed at the call site of the platform channel, not at the caller — these
calls fail asynchronously, and nothing that depends on the buyer's seats may
fail because a phone declined to buzz. Decide *which* cue in a pure policy
object, separate from the code that fires one, and honour the seeding rule: the
first snapshot of a session fires nothing.

**4.6 Safe areas.** One surface owns the bottom inset at any moment (§2.4).
Height ceilings add the inset rather than eating into content. The top inset
belongs to the header.

**4.7 Prewarm, adopt-after-layout, reveal-after-framing.** Three separate
things, in this order:

1. *Prewarm* — a host may start a runtime page ahead of time; it lives on a
   short TTL and is discarded under memory pressure.
2. *Adopt after layout* — claim the warm page only once the picker has a size.
   Adopting before layout answers the runtime's hello with an init at zero size,
   so the chart paints small and then re-fits in front of the buyer.
3. *Reveal after framing* — keep the loading surface up until the runtime
   reports it has framed the map inside the native chrome, with a short backstop
   for a runtime that never answers, then fade.

A host may also name the event before the runtime does, so the header does not
swap its title a second after opening.

**4.8 Hold ownership.** Two owners, and they behave differently:

- **picker-owned** — the native chrome shows the countdown pill, may extend it,
  and releases seats when a line is removed.
- **host-owned** — a hold handed in by the host is verified with the server and
  always treated as host-owned. Native controls never release or mutate it, and
  the countdown pill is not drawn: it is the host's to display.

The hold id itself is delivered **only** at the checkout handoff
(`checkout-handoff-v1`); ordinary snapshots never expose that booking
capability. If the host refuses the handoff, reject it
(`checkout-handoff-reject-v1`) so the hold is not stranded. Keep booking
credentials off the device. Capability `hold-ownership-v1`, and
`hold-selection-v1` for holding a named selection.

### 4.9 Known gaps waiting on runtime fields

These are designed but cannot be built until the runtime reports the data. Do
not fake them, and do not design around their absence as if it were permanent.

- **Previous-price and sold-out chips on the price rail.** The web rail strikes
  a previous price and keeps a sold-out category's chip disabled. Natively this
  needs a per-category previous price and a trustworthy free count that
  distinguishes *zero* from *not reported*; today a zero is read as unknown.
- **Held versus pending counts for `Secure more`.** `strings.secureMoreAndCheckout`
  needs how many of the buyer's tickets are already held and how many are still
  pending. Until the split is reported the label falls back to
  `strings.continueToCheckout`.
- **3D section stops.** The immersive scene's caption can name a stop, but the
  list of stops a venue offers is not in the snapshot, so the deck cannot offer
  section-to-section travel.
- **Confidence and comparison data on the 3D seat card.** The web card has a
  compare action and a confidence teaser in 3D. Neither has a snapshot field
  yet, so the native 3D card carries the 2D card's content.
- **Per-seat accessibility nodes on the map.** The venue is drawn on a canvas
  inside a web view, and a canvas exposes nothing to VoiceOver or TalkBack. The
  map is therefore ONE named region with a hint that says where the controls
  that pick a seat are (§4.10), which is honest but is not the design: a buyer
  who cannot see the screen should be able to move seat by seat through a
  section. Building that needs two things from the runtime — `seat-screen-point-v1`
  for each seat's rectangle, so a native node can be placed over it, and a
  `picker.listSeatsInView` command that answers with the seats currently drawn,
  their identity, price and state. With both, the native side can mount a real
  accessibility node per seat over the web view and hand its activation back as
  an ordinary tap. Neither exists today, and nothing may pretend they do: a
  fabricated seat list read out over a map that does not match it is worse than
  a region that says it cannot be explored.

### 4.10 Accessibility

The picker is one screen with many surfaces, and most of what a buyer who is
not looking at it needs is a property of the WHOLE screen rather than of any
one component: the order the surfaces are read in, which of them speak without
being asked, how far the type may grow, where focus goes when a surface hands
the screen back. Those are specified here, once, and every port owes all of
them. Per-component notes stay with their component in §3.

**One reading order.** Assistive technology walks the picker in the buyer's own
order — header, price rail, map, the chrome standing on the map, the section
dock, any prompt, notices, the cart — and never in paint order. The phone
composition is a column with a stack in the middle, and a stack's paint order
puts the dock between two halves of the map's chrome and the seat card after
the toast that answers it. Every surface therefore declares its place:

| Order | Surface |
| --- | --- |
| 100 | header |
| 200 | price rail, and the Map/3D control that shares its band |
| 300 | the map, and everything stacked on it |
| 400 | map chrome: floor rail, test chip, corner controls, 3D and seat-view chrome |
| 500 | section dock |
| 600 | seat card, general-admission and table prompts |
| 700 | toasts, hold prompts, buyer-facing state overlays |
| 800 | cart sheet |

Two rules make this work in practice. Sibling surfaces are either **all**
ordered or none are — a group with some ordered members falls back to geometry
for the rest, which is how the map came to be read before the prices. And the
order is declared once, at the composition root: each component is also
mountable on its own, where there is no order to join. Dart file:
`lib/src/picker/picker_a11y.dart`.

**What each surface says.**

- *Map* — one node, named `strings.venueMap` with the venue's name, and a hint
  (`strings.venueMapHint`) that says the seats are picked with the controls
  around it. See the runtime gap in §4.9: naming a region that cannot be
  explored is the honest form of a canvas, not the intended design.
- *Live regions*, and only these three: the peek summary, the section dock's
  name and seats-left, and the hold countdown. Each changes without the buyer
  touching it, and none says so any other way.
- *The hold countdown is throttled.* `m:ss` read aloud is a time of day. The
  pill announces `strings.holdMinutesLeft` at each minute mark, and
  `strings.holdSecondsLeft` for every second of the last minute, where the
  buyer is owed the count. Unchanged text is not re-announced, so the throttle
  IS the policy — a live region fed a running clock speaks once a second for a
  quarter of an hour.
- *Toasts* are announced outright as well as being live regions: a toast that
  arrives and leaves inside four seconds, inside a cross-fade, is a window a
  live region cannot be relied on to catch.
- *The seat card is a dialog*: it names itself with the identity sentence
  (section, row, seat, category, price — §3.8.6), it scopes the route, and both
  answers are custom actions on it so a rotor can say yes or no without hunting
  for the buttons. While it is up, everything painted before it — the map, its
  chrome, the dock — is hidden from assistive technology, exactly as a modal
  route hides the page under it. Toasts and the cart stay audible: the toast is
  the answer to the press, and the cart is what the seat is being added to.
- *Every control is a button* with a name, and a state where it has one:
  pressed, selected, expanded, toggled.

**Dynamic type.** Every string scales with the platform's text-size setting, to
a ceiling per surface (`type.scaleClamp` — rail, dock, peek and card at 1.3;
sheet rows and buyer-facing states at 1.6). A clamp is a statement about a
layout, not a preference: past it the surface clips, and a buyer who cannot read
a clipped price is worse off than one reading a slightly smaller one. Prompts
and dialogs have no clamp: they own the screen and they scroll.

Heights follow the type. Every fixed height around text — the rail band and its
chips, the dock bar, the collapsed cart, cart rows, the best-seats controls, the
card's action row — is `base × the surface's clamped scale`, so the box grows
with what is in it. Two consequences a port must not miss: the dock's reported
viewport band (§2.3) has to be the height it actually draws, or a focused
section lands under a dock that grew; and at the platform default of 1.0 every
one of these is unchanged, which is what keeps the goldens still.

**Focus.** The seat card's first focusable is `Add seat`, not `Cancel` — the
drawn order is the other way round, and the two orders are allowed to disagree.
Escape, and the platform's back gesture, give the seat back. When a decision
surface hands the screen back — accepted or cancelled — focus returns to the
map region rather than falling to the top of the tree, and a toast's action
returns focus to whatever had it before the press.

**Bold text.** The platform's `bold text` setting moves every weight in the
picker two steps up, clamped at 900. Flutter honours the setting in exactly one
widget, so the picker asks for itself; a port on a platform that applies it
automatically should let the platform do it rather than double it.

**Reduced motion** is §1.6 and `motion.reducedMotion`, and it is deliberately
not repeated here: one setting with two homes is a setting a surface will read
from the wrong one.

---

## 5. Capability index

| Capability | What it unlocks |
| --- | --- |
| `native-chrome-contract-v1` | the runtime suppresses its own buyer chrome; native owns header, rail, dock, tray, prompts |
| `viewport-insets-v1` | native reports the bands its chrome covers, so framing lands inside them |
| `seat-screen-point-v1` | the seat's screen point, so the seat card can hug the seat instead of resting |
| `category-availability-v1` | live per-category free counts behind the rail's strike-through, the card's `N left` and the sold-out predicate |
| `access-needs-v1` | the chart's own access needs, in the runtime's order, with live free counts |
| `availability-refresh-v1` | a re-read of live availability on resume, and the outcome that explains a lapsed hold |
| `chart-load-trace-v1` | what the load cost, handed to the host's analytics |
| `native-seat-view-chrome-v1` | the runtime suppresses its seat-view words; native draws the caption strip |
| `floor-stack-v1` | the floor list and the active floor for the floor rail |
| `venue-3d-v1`, `venue-3d-controls-v1` | the immersive scene and its deck |
| `seat-view-v1` | the 2D view-from-seat panorama |
| `table-quantity-v1` | the table guest-count prompt |
| `hold-ownership-v1`, `hold-selection-v1` | who owns a hold, and holding a named selection |
| `checkout-handoff-v1`, `checkout-handoff-reject-v1` | the hold crossing to the host, and giving it back |
| `cart-line-remove-v1` | removing a cart line the selection cannot name |

A capability the runtime does not advertise is a feature that is **not offered**,
never a feature that fails.
