import 'dart:async';

import 'package:flutter/widgets.dart';

import '../payloads.dart';
import '../seat_layer_error.dart';
import 'picker_models.dart';

typedef SeatLayerCheckoutCallback = FutureOr<void> Function(
    SeatLayerCheckoutHandoff handoff);

typedef SeatLayerMoneyFormatter = String Function(
    double amount, String currency);

@immutable
class SeatLayerCategoryPricing {
  const SeatLayerCategoryPricing({
    this.base,
    this.tiers = const <String, double>{},
  });

  final double? base;
  final Map<String, double> tiers;
}

@immutable
class SeatLayerPickerPricing {
  const SeatLayerPickerPricing({
    this.categories = const <String, SeatLayerCategoryPricing>{},
    this.formatter,
  });

  final Map<String, SeatLayerCategoryPricing> categories;
  final SeatLayerMoneyFormatter? formatter;
}

/// Visibility of the turnkey picker's native chrome.
///
/// These switches affect only [SeatLayerPicker]'s default composition. Every
/// corresponding control remains available as a standalone public widget for
/// hosts that build their own layout.
@immutable
class SeatLayerPickerChromeOptions {
  const SeatLayerPickerChromeOptions({
    this.showHeader = true,
    this.showPriceRail = true,
    this.showFloorSelector = true,
    this.showMapControls = true,
    this.showOverviewControl = true,
    this.showZoomControls = true,
    this.showZoomToFitControl = true,
    this.showViewModeControl = true,
    this.showColorblindControl = true,
    this.showAccessibilityControl = true,
    this.showTicketPanel = true,
  });

  final bool showHeader;
  final bool showPriceRail;
  final bool showFloorSelector;
  final bool showMapControls;
  final bool showOverviewControl;
  final bool showZoomControls;
  final bool showZoomToFitControl;
  final bool showViewModeControl;
  final bool showColorblindControl;
  final bool showAccessibilityControl;
  final bool showTicketPanel;
}

@immutable
class SeatLayerPickerOptions {
  const SeatLayerPickerOptions({
    this.layout = SeatLayerPickerLayoutMode.adaptive,
    this.holdTtl,
    this.initialHoldId,
    this.readOnly = false,
    this.confirmSelection = true,
    this.enableBestAvailable = true,
    this.enable3D = true,
    this.enableSeatView = true,
    this.hideEventDetails = false,
    this.panelInitiallyCollapsed = true,
    this.persistColorblindPreference = true,
    this.chrome = const SeatLayerPickerChromeOptions(),
    this.languages = const <Locale>[],
    this.pricing,
  });

  final SeatLayerPickerLayoutMode layout;
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
  final bool confirmSelection;
  final bool enableBestAvailable;
  final bool enable3D;
  final bool enableSeatView;
  final bool hideEventDetails;
  final bool panelInitiallyCollapsed;
  final bool persistColorblindPreference;
  final SeatLayerPickerChromeOptions chrome;
  final List<Locale> languages;
  final SeatLayerPickerPricing? pricing;

  Map<String, Object?> toBridgeConfig() => <String, Object?>{
        if (holdTtl != null) 'holdTtlMs': holdTtl!.inMilliseconds,
        if (initialHoldId != null) 'initialHoldId': initialHoldId,
        'readOnly': readOnly,
        'confirmSelection': confirmSelection,
        'enableBestAvailable': enableBestAvailable,
        'enable3D': enable3D,
        'enableSeatView': enableSeatView,
        'hideEventDetails': hideEventDetails,
        'panelCollapsed': panelInitiallyCollapsed,
        'languages': languages.map((locale) => locale.toLanguageTag()).toList(),
      };
}

@immutable
class SeatLayerPickerCallbacks {
  const SeatLayerPickerCallbacks({
    this.onReady,
    this.onSelectionChanged,
    this.onSelectionValidityChanged,
    this.onHoldChanged,
    this.onHoldExpired,
    this.onAccessExpired,
    this.onAccessUnavailable,
    this.onSelectedObjectUnavailable,
    this.onClosed,
    this.onError,
  });

  final ValueChanged<ReadyInfo>? onReady;
  final ValueChanged<List<SelectedSeat>>? onSelectionChanged;
  final ValueChanged<SelectionValidity>? onSelectionValidityChanged;
  final void Function(
    SeatLayerPickerHold? hold,
    SeatLayerCheckoutHandoff? handoff,
  )? onHoldChanged;
  final VoidCallback? onHoldExpired;
  final ValueChanged<BuyerAccessExpiredEvent>? onAccessExpired;
  final ValueChanged<BuyerAccessUnavailableEvent>? onAccessUnavailable;
  final ValueChanged<SelectedObjectUnavailableEvent>?
      onSelectedObjectUnavailable;
  final ValueChanged<SeatLayerPickerCloseReason>? onClosed;
  final ValueChanged<SeatLayerError>? onError;
}
