# Changelog

## 0.7.3

The seat card's category band prints the category and the price, and nothing
else. The remaining count is gone from it: beside the name it said nothing a
buyer choosing one seat could act on, and on a big category it pushed the price
into the card's edge. The count still belongs to the price legend, where
categories are compared, and to the section dock. The band is a little taller
for it — name 15, price 18 — with the price kept a full
`size.confirmBandPadTrailing` clear of the card's trailing edge.

The collapsed ticket bar shows the whole of its button. Its height is now
derived from the head it holds — one number, so nothing can clip the surface
shorter than the row inside it and cut the bottom off the button the bar exists
for. The chevron leaves the collapsed bar: the whole head has always been the
tap and the swipe, and the arrow only took width from that button. It stays on
the open sheet, where it is the way back down, and while it is gone the head
itself carries the toggle's name, expanded state and tap action, so a
screen-reader buyer still has exactly one named way into the cart. `Find seats`
and `Continue` are 48 pt at `radius.peekButton` with a 16 pt label, set against
the same 12 pt inset the summary starts at.

`size.confirmBandLeftFontSize` and `SeatLayerSizeTokens.confirmBandLeftFontSize`
are removed — they measured a line the card no longer draws. `strings.seatsLeft`
stays; the dock still prints it.

The hosted runtime moves to `seatlayer-js@0.77.2`. Views load
`https://cdn.seatlayer.io/seatlayer-js@0.77.2/mobile.html`. One buyer-visible
change arrives with it and needs nothing from this SDK: on the overview, the
badge marking a section the buyer holds seats in now sits over those seats
rather than over the section's name. A name is placed to clear its neighbours,
so on a large stand it could end up a block away from a front-row pick and the
mark appeared to point at the wrong section.

## 0.7.2

Removing a ticket now answers the press rather than the server. The line fades
and its × goes inert in the same frame, the `Ticket removed` / `Undo` bar is
offered straight away, and the row comes back if the removal fails.

The sheet stays usable while that runs. `picker.removeCartLine` re-holds the
rest of the cart on the server, which takes seconds on a real event; the
checkout call to action no longer greys through it. Pressing it during a
removal is safe — inventory mutations are serialised, so the handoff is sent
after the removal, against the cart the buyer can see.

When a line's own words change — a run's range shortening, its `2 × €25` going,
the sheet's `2 tickets` becoming `1 ticket` — only that cell cross-fades, and
nothing does under reduced motion.

A busy checkout button no longer overflows its own width: `Opening secure
checkout…` beside the spinner overran the sheet's book button while the host
was answering.

New design token `opacity.removing`, and a new
`SeatLayerPickerBusyAction.removingCartLine` — the one busy action that does
not block checkout.

## 0.7.1

`SeatLayerPickerOptions.showBookedOverlay` lets a host whose checkout ends on
a confirmation of its own keep the picker's "You're all set" screen down, so
the buyer is told once. It defaults to true, which is the web picker's
behaviour; `onBooked` fires either way.

## 0.7.0

The hosted runtime moves to `seatlayer-js@0.77.1`, which brings the camera
behaviour the picker had been standing in for. Views load
`https://cdn.seatlayer.io/seatlayer-js@0.77.1/mobile.html`.

Turning an accessibility filter on now flies to the matching spaces, and best
available lands on the seats it found — both inside the runtime, under reduced
motion too. The two interim moves this package made after those commands are
gone: no `picker.overview` after a filter, no section landing after a hold.

The count on the accessibility sheet becomes a jump. Where a provision has
free spaces, its "15 free" is a button: it turns that provision on, applies the
filter, closes the sheet and frames the first section holding one. A stepper
pill then sits beside the accessibility control on the map — `♿ 2 of 6 ›` —
and walks the rest, so the tour continues where the map is visible rather than
under a sheet that covers it. Both are withheld from a runtime that does not
advertise `accessibility-focus-v1`.

The section dock says how many of the seats left where the buyer is standing
match their filter (`· ♿ 2`), from the new `sections[].accessibleFree`. A
section the runtime did not count says nothing rather than zero.

New on `SeatLayerPickerSectionSummary`: `accessibleFree`. New public types:
`SeatLayerAccessibleStep`, `SeatLayerAccessibleTour`,
`SeatLayerPickerAccessibleStepper`, and the controller's
`focusNextAccessibleSection`, `focusAccessibilityFilter`,
`supportsAccessibilityFocus` and `supportsSectionAccessCounts`.

## 0.6.3

The toast band's action pill keeps a fixed 44-point hit box. Offered loose
height it centred itself in all of it, so with the cart sheet open the
"seat removed" toast filled the map.

## 0.6.2

Every seat the buyer taps is asked about. Once a hold existed — after the
first Add seat, or after a best-available pick — the confirm card stopped
appearing and later taps went straight into the cart. The seats a hold
arrives with (a resumed session, a best-available pick) are adopted as
answered when it appears; everything tapped after that gets the card, as on
the web.

Best available lands the map on the seats it found. The runtime's own arrival
does not yet cross the bridge, so the picker frames the section of the new
seats after the hold lands; the runtime will carry the full arrival in a
coming patch.

The "seat removed" bar with Undo is the picker's own toast rather than the
host app's Material messenger, so it dismisses on the picker's dwell on every
host.

## 0.6.1

The collapsed cart bar sits below its grabber. Since the bar's buttons grew to
44 points inside a 50-point head, the grabber painted in the head's top four
points ran under the button; the head now lifts its row by `size.peekClockLift`
whenever it is collapsed, not only while the pill carries the clock, so the
bar is 58 points at rest.

Applying an accessibility filter now shows where the spaces are. The runtime
lights the sections that still hold matching spaces and steps the rest back,
but its bridge command does not fly to them the way the web's own menu does,
so a filter that names a need is followed by the venue overview. This is an
interim until the runtime carries the flight over the bridge.

## 0.6.0

The seat card is louder and shorter on phones, matching the web buyer picker.

Section, row and seat sit in three equal centred cells at one size; only a
section name longer than six characters drops to the small wrapping type, so a
numbered section like `209` reads as one line of equals with the row and the
seat. The category band is the category colour itself, full bleed, with its ink
chosen per colour — white where white clears 3:1 against the band, near-black
otherwise — so a pale category keeps its name; the dot and the leading rail are
gone. With no seat photograph the card drops the empty strip entirely and the
3D action becomes a 44 pt square at the head of the decision row, which also
means the sight line is now printed only on a photograph. Inside the 3D scene
the passport and the view from the seat share one row of compact chips instead
of stacking two full-width bars over the section the buyer just flew into.

On the collapsed cart bar the from-price prints the amount large and its word
as a small muted caption, and both `Find seats` and `Continue` become 44 pt
rounded rectangles at `radius.peekButton` with larger labels.

`SeatLayerPickerLayout.confirmRailHeight` is now inert on the SDK's own card;
it is kept as public API for hosts composing their own.

The hosted runtime moves to `seatlayer-js@0.77.0`. Views load
`https://cdn.seatlayer.io/seatlayer-js@0.77.0/mobile.html`. Nothing in this SDK
has to change for what it brings:

- **Tapping a seat in the 3D venue steps the camera in** before the card
  arrives, from farther out than about twelve metres, so the buyer sees where
  the seat is rather than being handed a card about a seat off in the distance.
  Seat labels inside a section print the number alone and row labels drop the
  section they are already under, both on a dark plate that stays readable
  against any part of the room.
- **The accessibility filter now shows where the spaces are.** Sections that
  still hold matching spaces keep their colour and carry a `♿ N` badge; the
  rest step back, so the venue itself answers "where" instead of only "which
  seats". This applies to all twelve provisions the filter can ask for. Three
  parts of the same runtime change reach the web picker only: the camera move
  onto the matching seats, the hint for a venue whose spaces are spread too
  wide to fly to, and the count-as-jump control all live on the web's own
  accessibility menu, which a native shell replaces. The SDK's accessibility
  sheet is unchanged.
- **A best-available pick frames the seats it found**, with a few rows of
  neighbours around them, instead of framing the whole stand the first seat
  happened to sit in — and it moves the camera under reduced motion too, where
  it used to stay put. Reduced motion still turns off the seat pops and the
  chip flights. A framing the engine decides on its own stops at the scale
  where the seat labels are legible rather than filling the screen with a
  handful of seats.
- **Fewer requests on load**: an unchanged event now boots on one chart read
  and one live availability read. Hosts that count requests in their own load
  telemetry should expect the lower numbers.
- The runtime's load beacon no longer carries the API's per-stage server
  timings — their names described how a chart read is built rather than
  anything a page can act on. `SeatLayerChartLoadTrace.chartBytes` and
  `.chartCache` are unchanged, but `.server`, `.r2Head`, `.cacheLookup`,
  `.r2Get` and `.transform` are now always null on this runtime. They stay on
  the type: they are nullable already, a host reading them was always meant to
  handle their absence, and an older pinned runtime still reports them.

## 0.5.0

The hosted runtime moves to 0.76.0, the first release that reports seat-view
thumbnails, sight lines and confidence summaries to the native chrome. It also
brings the runtime's own changes to the map: sold seats drawn hollow, price
band filtering that frames the matching seats, a tighter landing fit, and
status cues whose ink follows the backdrop.

The seat card can show the seat's own photograph. A runtime advertising
`seat-view-thumbnail-v1` names an authored view image on each selected seat,
how far the seat is from the stage, and what it is willing to say about how
that view was produced; the card draws all three. The photograph is fetched by
the SDK rather than by an image widget, because on a private event the image
answers only to the buyer's bearer — `SeatLayerBuyerAssetLoader` mirrors the
web transport, validates the reference against the event before making any
request, caches the bytes for the session, and treats every failure as "no
photograph" rather than as an error the buyer has to see. A photograph that
never arrives collapses the strip into the plain rail the card already had. The
distance to the stage rides the photograph as a pill, or sits above the rail as
a muted caption where there is none. Inside the 3D venue, a seat carrying
confidence evidence gets the web's passport teaser; because the passport itself
is a runtime surface the bridge cannot open, the teaser is a button only where
a host takes the new `SeatLayerPickerCallbacks.onSeatConfidence`, and is a
static information row otherwise. `SelectedSeat` gains `seatViewThumb`,
`sightlineMetres` and `seatViewConfidence`; the older `seatViewKind`, which no
runtime ever sent, now falls back to the kind on the thumbnail. Runtimes
without the capability are unchanged in every respect.

## 0.4.0

The "You're all set" screen now waits for the sale. It used to appear the
moment the hold was handed to the host's checkout, so a buyer who came back
from checkout without paying was congratulated over a hold that was still
running. It now appears only when the handed-off hold settles to booked — the
hold vanishes with no expiry announced — which is the web picker's rule; and a
new `SeatLayerPickerCallbacks.onBooked` fires once at the same moment, with the
handoff, for hosts that want to act on the sale themselves.

The picker loads once. A prewarmed runtime page is now adopted only after the
picker has been laid out, so the chart's first paint is at its final size
instead of a smaller one that re-fits in front of the buyer; and the loading
surface stays up until the runtime has framed the map inside the native chrome
(with a short backstop for a runtime that never answers), then fades out. The
loading surface itself is the venue silhouette the web picker shows rather
than a spinner. `SeatLayerPickerOptions.eventName` lets a host name the event
in the header before the runtime reports it, so the title does not swap once
the chart arrives.

Parity with the web picker's phone round: the test-event badge is a sentence
case pill with a status dot (`Test mode`); a filtered price legend leads with
an `All prices` chip that clears the filter; the confirm card draws its photo
strip only where `View from here` exists, so a 3D-only card no longer carries
an empty frame; the collapsed cart says `3 tickets` and leaves the total to
`Continue · €285` rather than stating it twice. New strings: `allPrices`,
`testModeLong`.

On a phone the price legend is a row of its own between the header and the
map, leading with `All prices`, and the Map/3D control keeps the map's
top-right corner on the line below — so the last chip is never clipped under
the control and no seat number reads through the gaps. The band takes the map
chrome's palette and darkens with the 3D scene.

The seat card is rebuilt around the question it asks: section, row and seat
as three labelled cells; the category in a tinted band with its name, how
many are left and the price; `See it in 3D` as a full-width action; `Cancel`
a third of the row and `✓ Add seat` two thirds, each in its own box inside the
card's gutter. `Add seat` invites once and breathes until the buyer touches
the card, and on the press sweeps, ticks and says `Added` — the seat counts on
the press. The card is a native moment: the map dims to ink behind it (a style
slot, `SeatLayerPickerStyles.scrimColor`) so the seat stays legible, the card
springs in from the seat's side with a light haptic cue, a swipe down or a
tap on the map gives the seat back, and `Add seat` answers with a medium cue.
On a runtime that reports the seat's screen point (`seat-screen-point-v1`)
the card sits 12 pt above the seat with a pointer on the edge facing it;
until then it rests at the foot of the map. A category running low says
`Only N left` in warning ink. Nothing moves under reduced motion, and a host
that turned haptics off feels none of it. New: `addSeat`, `added`,
`seeItIn3D`, `onlyLeft` and the eyebrow words; `cardEnter` motion token;
`confirmBandHeight` layout token; `SelectedSeat.screenPoint`.

The checkout call to action says why it is waiting: `Sales closed`, `Confirm
or cancel this seat`, `Securing your seats…`, `Opening secure checkout…`, or
what would fix a rejected selection (`Choose 1 more`, `Remove 2 tickets`,
`Adjust your selection`). One resolver, `seatLayerCheckoutCtaState`, drives
the collapsed pill, the sheet's button and the wide bar. New strings for each
reason, and `continueWord`.

The bottom cart grows full-size targets: a 56 pt peek bar with a 44 pt
`Continue`; an empty bar offers `✦ Find seats`, which opens the sheet on the
best-seats form and is withheld where the form would be refused. Held rows
wear a lock and a hairline; a row is named by its section, else its ticket
type. The best-seats form is one track — stepper and ticket type, a zone row
only where the venue has zones, a full-width button. Price chips, remove
buttons and run rows all reach 44 pt; a swipe on the peek row opens and closes
the sheet. New string: `findSeats`. The test-event badge sits in the map's top-left corner in both views, stepping down only
while the scene's `Back to venue` pill is drawn. New layout token:
`topRailHeight`. The `Powered by SeatLayer` credit is centred at the foot of
the sheet, where a phone's rounded corner cannot clip it, and keeps its ink on
the dark scene sheet.

Every phone surface now carries the web picker's own numbers, extracted from
its stylesheets: the 38 pt header on the picker's ground with a letter logo
and a 26 pt close ring; the 44 pt price rail with 24 pt chips, `All prices`
pinned first, ringed dots on the light theme and the `{min}+` rule; the
Map | 3D control; the test chip as one recipe in both themes; the seat card's
box, grid, band, strip, pills, tiers and every animation timing; the 50 pt
peek head with its grabber, pill, Find seats and chevron, the sheet's
ceilings and drag gestures, the peek's own lines for holding, checkout and
closed sales; dense 44 pt cart rows on one plate with the held wash and the
`+N more` row; the 52 pt dock with the outlined `Venue` pill; 12 pt map
corners; the 3D chrome on one dark glass; the accessibility sheet as switch
rows with free counts. The light ground is white and the surfaces the grey,
as the web's are. Every buyer-facing state the web shows exists natively:
toasts for a seat taken, a hold expired or lapsed and closed sales; the
sold-out overlay; the access panel with its own retry; the hold-extend
prompt; the booked overlay with the seat list and a way back; the closed
statement in the tray; the hold and closed pills in the header.

Above the web's floor, what only a native picker can do: the cart sheet is a
real bottom sheet with peek, content and full detents that tracks the finger,
rubber-bands and settles on a spring; a cart row swipes to remove; the seat
card comes up in the 3D venue too, with `View from this seat`; haptic cues for
section focus, a removed ticket, a secured hold and a hold's last minute, all
behind the host's haptics switch; one screen-reader reading order with live
regions where a change is news, the card as a dialog with custom actions,
text that scales with the buyer's setting, bold text honoured, and keyboard
focus that lands on `Add seat` and returns to the map. On runtime 0.75.2 the
card sits above the tapped seat with a pointer and the band prints the live
free count. `design/picker-spec.md` records every component for the other
SDKs to port from.

**Runtime pin**

The hosted runtime moves to `seatlayer-js@0.75.2`. Views load
`https://cdn.seatlayer.io/seatlayer-js@0.75.2/mobile.html`.

## 0.3.4

- Keeps API-required `Powered by SeatLayer` attribution at the bottom-right of
  the native picker chrome on compact and wide layouts. Server branding remains
  authoritative: a white-label entitlement hides it without a host-side switch.
- Adds an automated public-repository hygiene gate to prevent internal planning,
  audit evidence, machine-local paths, and credentials from entering releases.

## 0.3.3

A picker that comes back to the front now finds out what changed while it was
away. Returning from the background, or from a route pushed over it, re-reads
live availability: seats the buyer had selected and somebody else has since
bought are deselected and reported through `onSelectedObjectUnavailable`, and
the buyer's own hold is reconciled against the server rather than against an
in-app countdown that may never have fired. Nothing the buyer owns is touched —
selection, hold, cart total, camera and rung all stay exactly where they were.

A hold that lapsed while the buyer was away is now said out loud, once: a line
in the cart sheet and a toast, never a dialog, with the seats that are still
free offered back under `Select them again` — `Select it again` when exactly
one seat can be taken back, counted on what the offer would re-take rather than
on how many lapsed — which re-selects them and holds
them again, so the buyer lands back where they were rather than one step short
of it. A seat sold between the offer and the tap is a real race, and it is
reported the way every failed hold is reported, with the seats left selected and
unheld rather than claimed. `onHoldExpired` still fires, and
`SeatLayerPickerOptions(announceHoldLapse: false)` leaves the moment entirely to
the host. `SeatLayerPickerOptions(refreshOnResume: false)` stops the SDK asking
for a read of its own; an outcome the runtime volunteers on a foreground
lifecycle is still applied, because it has already released the hold and
discarding what it says would empty the buyer's cart without explaining it. The
route half needs `SeatLayerPicker.routeObserver` in
`MaterialApp.navigatorObservers`; without it the lifecycle half still works.
New: `SeatLayerPickerController.refreshAvailability()`,
`SeatLayerAvailabilityRefresh`, `SeatLayerHoldLapse`, `SeatLayerRecovery`,
`SeatLayerHoldLapseNotice`.

The hold countdown stops the moment a read finds the hold gone, even when the
snapshot in hand still describes a live one — it was read before the
reconciliation that ended it, and a clock still running over released seats is
the one thing that can leave a buyer reassured right up to a failed checkout.
`SeatLayerPickerState.hold` answers null from that moment, so any layout hung
off it goes quiet with the built-in pill.

The accessibility sheet now offers what the event actually has. On a runtime
that reports them, only the access needs this chart carries are drawn, in the
runtime's order, each with the number of matching free seats; a need whose seats
are all gone stays on the sheet and goes dark, so "this venue has none" and
"these are taken" remain different answers. Older runtimes keep the full static
list. Every name is still overridable through
`SeatLayerPickerStrings.accessNeeds`.

**Runtime pin**

The hosted runtime moves to `seatlayer-js@0.71.5`. Views load
`https://cdn.seatlayer.io/seatlayer-js@0.71.5/mobile.html`, which advertises the
`availability-refresh-v1` and `access-needs-v1` capabilities this release
consumes, and carries the matching fix for a hold whose lapse is decided by its
own expiry rather than by what the seats report.

A brand accent now carries white ink. When you hand the picker an accent
without naming an ink for it, the picker was choosing whichever of black and
white scored higher against it, and a brand red scores higher on black — so
`Continue`, `Hold seats & checkout`, the confirm card's `Select`, the header
tile, the Map/3D control and every accent pill came back with black text on a
red button. White is what a brand puts on its own colour, so white is now the
answer wherever white can be read, and black is kept for the pale accents where
black is the obvious reading anyway: a yellow, a mint, a near-white tint.
`onAccent` still names the ink outright, and a `ColorScheme` still brings its
own `onPrimary`.

Alongside it, documentation. The README, the public API documentation and the
architecture note now describe the SDK's surface, its layers and its security
boundary without narrating how the SeatLayer renderer is delivered. No API
changed: `seatLayerHostedWebVersion`, `seatLayerMobileOrigin` and
`SeatLayerConfiguration.assetPath` are all exactly as they were.

## 0.3.2

Documentation only. The package page now shows the picker in motion: an
animated walkthrough of the buyer flow and a still of a focused section
replace the older example capture.

## 0.3.1

Defects found on a phone, and the additive native-chrome contract that came out
of them: the seat-view panorama's words and the floor strip's confirmed shape.

**Runtime pin**

- The hosted runtime moves to `seatlayer-js@0.71.4`. Views load
  `https://cdn.seatlayer.io/seatlayer-js@0.71.4/mobile.html`, which advertises
  the `native-seat-view-chrome-v1` and `floor-stack-v1` capabilities this
  release consumes alongside the contract 0.3.0 already used.

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

**Callbacks**

- Adds an optional `onChartLoad` callback.

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
