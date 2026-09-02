import 'dart:async';

import 'package:flutter/widgets.dart';

import '../payloads.dart';
import '../seat_layer_error.dart';
import 'picker_chart_load.dart';
import 'picker_models.dart';
import 'picker_strings.dart';

/// Receives the hold the buyer is handing to the host's checkout.
typedef SeatLayerCheckoutCallback = FutureOr<void> Function(
    SeatLayerCheckoutHandoff handoff);

/// Renders one amount in one currency.
typedef SeatLayerMoneyFormatter = String Function(
    double amount, String currency);

/// Host-supplied prices for one category and its tiers.
@immutable
class SeatLayerCategoryPricing {
  /// Creates a price override for one category.
  const SeatLayerCategoryPricing({
    this.base,
    this.tiers = const <String, double>{},
  });

  /// Price when the category has no tiers.
  final double? base;

  /// Price per tier id.
  final Map<String, double> tiers;
}

/// Host-supplied pricing and money formatting.
@immutable
class SeatLayerPickerPricing {
  /// Creates a pricing override.
  const SeatLayerPickerPricing({
    this.categories = const <String, SeatLayerCategoryPricing>{},
    this.formatter,
  });

  /// Price overrides keyed by category key.
  final Map<String, SeatLayerCategoryPricing> categories;

  /// How every amount in the native chrome is rendered.
  final SeatLayerMoneyFormatter? formatter;
}

/// Visibility of the turnkey picker's native chrome.
///
/// These switches affect only [SeatLayerPicker]'s default composition. Every
/// corresponding control remains available as a standalone public widget for
/// hosts that build their own layout.
///
/// The four nullable controls default to *auto*: present in the wide layout,
/// absent on the phone, where pinch-to-zoom, the accessibility sheet and the
/// dock bar already carry them. Set one explicitly to override that.
@immutable
class SeatLayerPickerChromeOptions {
  /// Creates a chrome visibility set. Defaults are the approved phone UX.
  const SeatLayerPickerChromeOptions({
    this.showHeader = true,
    this.showPriceRail = true,
    this.showFloorSelector = true,
    this.showFloorStrip = true,
    this.showMapControls = true,
    this.showOverviewControl,
    this.showZoomControls,
    this.showZoomToFitControl = true,
    this.showViewModeControl = true,
    this.showColorblindControl,
    this.showAccessibilityControl = true,
    this.showTicketPanel = true,
    this.showDockBar = true,
    this.showConfirmCard = true,
    this.showVenue3DChrome = true,
    this.showSeatViewChrome = true,
    this.showHoldPill = true,
    this.manageSystemOverlays = true,
  });

  /// Whether the header renders.
  final bool showHeader;

  /// Whether the price legend renders.
  final bool showPriceRail;

  /// Whether the floor selector renders on a multi-floor venue.
  final bool showFloorSelector;

  /// Whether the floor chip strip renders on a multi-floor venue.
  ///
  /// It draws nothing at all on a venue with fewer than two floors, so this
  /// is only for a host that wants to place the strip itself.
  final bool showFloorStrip;

  /// Whether any map corner control renders.
  final bool showMapControls;

  /// Whether the back-to-overview control renders. Auto: wide only.
  final bool? showOverviewControl;

  /// Whether the zoom in/out pair renders. Auto: wide only.
  final bool? showZoomControls;

  /// Whether the fit-to-screen control renders.
  final bool showZoomToFitControl;

  /// Whether the Map/3D control renders on a 3D-capable event.
  final bool showViewModeControl;

  /// Whether a standalone colourblind toggle renders. Auto: wide only, since
  /// the phone keeps it inside the accessibility sheet.
  final bool? showColorblindControl;

  /// Whether the accessibility filter control renders.
  final bool showAccessibilityControl;

  /// Whether the cart sheet renders.
  final bool showTicketPanel;

  /// Whether the rung-2 dock bar renders on the phone.
  final bool showDockBar;

  /// Whether tapping a seat opens the native confirm card.
  final bool showConfirmCard;

  /// Whether the seat-view/3D chrome renders over the immersive scene.
  final bool showVenue3DChrome;

  /// Whether the native caption strip over the 2D seat-view panorama renders.
  ///
  /// Turning it off does NOT give the words back to the runtime: a runtime
  /// advertising `native-seat-view-chrome-v1` was asked to suppress its own at
  /// `init`, so a host that hides this owns the disclosure itself.
  final bool showSeatViewChrome;

  /// Whether the header shows the hold countdown pill.
  final bool showHoldPill;

  /// Whether the picker dresses the device's status and navigation bars.
  ///
  /// On by default, and it is what keeps the clock, the wifi glyph and the
  /// battery legible: the surface behind those bars is the picker's, so the
  /// picker is the only thing that can know whether they need light icons or
  /// dark ones. The style follows the resolved theme mode live — including an
  /// `auto` device flip — and goes dark for the immersive 3D scene whatever
  /// side the picker is painted on.
  ///
  /// Turn it off when the host application owns the bars, for example because
  /// it presents the picker inside its own chrome and sets one style for the
  /// whole app.
  final bool manageSystemOverlays;

  /// Resolve [showOverviewControl] for a layout.
  bool overviewControlFor({required bool phone}) =>
      showOverviewControl ?? !phone;

  /// Resolve [showZoomControls] for a layout.
  bool zoomControlsFor({required bool phone}) => showZoomControls ?? !phone;

  /// Resolve [showColorblindControl] for a layout.
  bool colorblindControlFor({required bool phone}) =>
      showColorblindControl ?? !phone;
}

/// Behaviour of one picker session and its native chrome.
@immutable
class SeatLayerPickerOptions {
  /// Creates an options set; every default is the approved buyer experience.
  const SeatLayerPickerOptions({
    this.layout = SeatLayerPickerLayoutMode.adaptive,
    this.holdTtl,
    this.initialHoldId,
    this.readOnly = false,
    this.confirmSelection = true,
    this.enableBestAvailable = true,
    this.enable3D = true,
    this.enableSeatView = true,
    this.max3DSeats,
    this.hideEventDetails = false,
    this.eventName,
    this.panelInitiallyCollapsed = true,
    this.persistColorblindPreference = true,
    this.refreshOnResume = true,
    this.announceHoldLapse = true,
    this.chrome = const SeatLayerPickerChromeOptions(),
    this.languages = const <Locale>[],
    this.pricing,
    this.strings = const SeatLayerPickerStrings(),
    this.haptics = true,
  }) : assert(max3DSeats == null || max3DSeats > 0);

  /// Whether to compose the phone layout, the wide layout, or choose by width.
  final SeatLayerPickerLayoutMode layout;

  /// How long a hold this picker creates should live.
  final Duration? holdTtl;

  /// A hold previously acquired by the host application.
  ///
  /// The runtime verifies it with the server before exposing it and always
  /// treats it as host-owned. Native picker controls never release or mutate
  /// this hold.
  final String? initialHoldId;

  /// Prevent every selection, hold and checkout mutation.
  ///
  /// The runtime also disables canvas selection. Filters, navigation, view
  /// controls and safe teardown/rejection actions remain available.
  final bool readOnly;

  /// Whether a seat tap opens a confirmation step before it joins the cart.
  final bool confirmSelection;

  /// Whether the best-available finder is offered.
  final bool enableBestAvailable;

  /// Whether the real venue 3D scene may be entered.
  final bool enable3D;

  /// Whether the view-from-seat surface may be opened.
  final bool enableSeatView;

  /// Optional WebGL seat ceiling. Omit to use SeatLayer's device-aware limit.
  final int? max3DSeats;

  /// Whether to suppress the event name and venue in the header.
  final bool hideEventDetails;

  /// The event's name, shown in the header until the runtime reports its own;
  /// the runtime's name wins once it arrives.
  ///
  /// The host already knows what the buyer tapped, and a header that says
  /// "Choose your seats" for the first second and then swaps to the event's
  /// name reads as the screen loading twice.
  ///
  /// Deliberately absent from [toBridgeConfig]: the runtime is the authority
  /// on what this event is called, and this is only what the header borrows
  /// while it waits. It is not part of the runtime profile either, so
  /// changing it never reboots the map.
  final String? eventName;

  /// Whether the cart sheet starts at its peek height.
  final bool panelInitiallyCollapsed;

  /// Whether a colourblind-safe choice survives the session.
  final bool persistColorblindPreference;

  /// Re-read live availability whenever the picker comes back to the front.
  ///
  /// Covers both ways it can: the application resuming from the background,
  /// and a pushed route — a checkout screen, a sign-in — popping back to the
  /// picker. A suspended app learns nothing while it is away, so without this
  /// the buyer returns to a map that was last true minutes ago and can tap a
  /// seat somebody else already bought.
  ///
  /// The route half needs [SeatLayerPicker.routeObserver] in the host's
  /// `MaterialApp.navigatorObservers`; without it the lifecycle half still
  /// works and nothing complains. Turning this off turns off BOTH triggers,
  /// for a host that refreshes on its own schedule.
  ///
  /// It governs whether this SDK ASKS for a read — not whether it honours one
  /// the runtime volunteers. A foreground `picker.lifecycle` re-reads
  /// availability inside the runtime and the reply carries what it found, and
  /// that outcome is applied whatever this is set to. It has to be: the
  /// runtime has already cleared a hold that ran out, so throwing the answer
  /// away would leave the buyer looking at an emptied cart with no account of
  /// why. This is therefore not the switch for silence — [announceHoldLapse]
  /// is, and it leaves [SeatLayerPickerCallbacks.onHoldExpired] firing.
  ///
  /// Deliberately absent from [toBridgeConfig]: when to ask is a host-side
  /// decision about the host's own navigation, and the runtime has no view of
  /// either event.
  final bool refreshOnResume;

  /// Tell the buyer, once, when their hold has lapsed while they were away.
  ///
  /// A line in the cart sheet and a toast — never a dialog, and never anything
  /// that blocks the map. [SeatLayerPickerCallbacks.onHoldExpired] fires
  /// either way, so a host that would rather own the moment turns this off and
  /// keeps the notification.
  final bool announceHoldLapse;

  /// Which parts of the native chrome render.
  final SeatLayerPickerChromeOptions chrome;

  /// Languages offered by the runtime's own language switch.
  final List<Locale> languages;

  /// Host-supplied prices and money formatting.
  final SeatLayerPickerPricing? pricing;

  /// Buyer-facing strings for the native chrome.
  final SeatLayerPickerStrings strings;

  /// Fire haptic feedback on the moments worth feeling: a seat joining the
  /// selection, the map moving into a section, and seats actually being held.
  ///
  /// Native only, and only on a device with a motor — it is silent on desktop,
  /// on web, and wherever the platform has haptics turned off. Turn it off if
  /// your app has its own feedback vocabulary and two would collide.
  ///
  /// Deliberately absent from [toBridgeConfig]: the runtime does not vibrate
  /// anything, and telling it about a purely native preference would only
  /// invite a second implementation of the same feeling.
  final bool haptics;

  /// The subset of these options the runtime is told about at init.
  Map<String, Object?> toBridgeConfig() => <String, Object?>{
        if (holdTtl != null) 'holdTtlMs': holdTtl!.inMilliseconds,
        if (initialHoldId != null) 'initialHoldId': initialHoldId,
        'readOnly': readOnly,
        'confirmSelection': confirmSelection,
        'enableBestAvailable': enableBestAvailable,
        'enable3D': enable3D,
        'enableSeatView': enableSeatView,
        if (max3DSeats != null) 'max3DSeats': max3DSeats,
        'hideEventDetails': hideEventDetails,
        'panelCollapsed': panelInitiallyCollapsed,
        'languages': languages.map((locale) => locale.toLanguageTag()).toList(),
      };
}

/// Everything a host can be told about while the buyer is in the picker.
///
/// Every entry is optional; a picker with no callbacks at all is a complete,
/// working buyer flow.
@immutable
class SeatLayerPickerCallbacks {
  /// Creates a callback set.
  const SeatLayerPickerCallbacks({
    this.onReady,
    this.onChartLoad,
    this.onSelectionChanged,
    this.onSelectionValidityChanged,
    this.onHoldChanged,
    this.onHoldExpired,
    this.onBooked,
    this.onAccessExpired,
    this.onAccessUnavailable,
    this.onSelectedObjectUnavailable,
    this.onClosed,
    this.onError,
    this.onThemeResolved,
    this.onSectionFocused,
    this.onSeatSelected,
    this.onSeatRemoved,
    this.onSeatViewOpened,
    this.onContinue,
  });

  /// The runtime finished its handshake.
  final ValueChanged<ReadyInfo>? onReady;

  /// One chart load finished, measured from the buyer's tap.
  ///
  /// Fires once per render attempt, success or failure, and only on a runtime
  /// advertising `chart-load-trace-v1`. Nothing is logged or sent by the SDK:
  /// this is the hook for a host's own analytics. See [SeatLayerChartLoad].
  final ValueChanged<SeatLayerChartLoad>? onChartLoad;

  /// The selected seats changed.
  final ValueChanged<List<SelectedSeat>>? onSelectionChanged;

  /// The selection became valid or invalid.
  final ValueChanged<SelectionValidity>? onSelectionValidityChanged;

  /// The hold was created, replaced or released.
  final void Function(
    SeatLayerPickerHold? hold,
    SeatLayerCheckoutHandoff? handoff,
  )? onHoldChanged;

  /// The hold ran out.
  final VoidCallback? onHoldExpired;

  /// The held seats settled to booked while the picker was still up: the
  /// hold passed to the host, then vanished with no expiry announced.
  final ValueChanged<SeatLayerCheckoutHandoff>? onBooked;

  /// The buyer's access token expired.
  final ValueChanged<BuyerAccessExpiredEvent>? onAccessExpired;

  /// The buyer has no access to this event.
  final ValueChanged<BuyerAccessUnavailableEvent>? onAccessUnavailable;

  /// A selected object was taken by someone else.
  final ValueChanged<SelectedObjectUnavailableEvent>?
      onSelectedObjectUnavailable;

  /// The picker session closed.
  final ValueChanged<SeatLayerPickerCloseReason>? onClosed;

  /// A typed SeatLayer failure surfaced.
  final ValueChanged<SeatLayerError>? onError;

  /// The theme mode resolved to a side, including every later device flip.
  final ValueChanged<Brightness>? onThemeResolved;

  /// The buyer moved the map into a section, by id.
  final ValueChanged<String>? onSectionFocused;

  /// The buyer accepted a seat on the confirm card.
  final ValueChanged<SelectedSeat>? onSeatSelected;

  /// The buyer removed a ticket from the cart, by its inventory label.
  final ValueChanged<String>? onSeatRemoved;

  /// The buyer opened the seat view or the 3D scene for a seat.
  final ValueChanged<SelectedSeat>? onSeatViewOpened;

  /// The buyer pressed the checkout call to action.
  final ValueChanged<SeatLayerCheckoutHandoff>? onContinue;
}
