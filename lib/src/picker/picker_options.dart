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

@immutable
class SeatLayerPickerOptions {
  const SeatLayerPickerOptions({
    this.layout = SeatLayerPickerLayoutMode.adaptive,
    this.holdTtl,
    this.initialHoldId,
    this.initialHoldOwner = SeatLayerHoldOwner.host,
    this.readOnly = false,
    this.confirmSelection = true,
    this.enableBestAvailable = true,
    this.enable3D = true,
    this.enableSeatView = true,
    this.hideEventDetails = false,
    this.panelInitiallyCollapsed = false,
    this.persistColorblindPreference = true,
    this.languages = const <Locale>[],
    this.pricing,
  });

  final SeatLayerPickerLayoutMode layout;
  final Duration? holdTtl;
  final String? initialHoldId;
  final SeatLayerHoldOwner initialHoldOwner;
  final bool readOnly;
  final bool confirmSelection;
  final bool enableBestAvailable;
  final bool enable3D;
  final bool enableSeatView;
  final bool hideEventDetails;
  final bool panelInitiallyCollapsed;
  final bool persistColorblindPreference;
  final List<Locale> languages;
  final SeatLayerPickerPricing? pricing;

  Map<String, Object?> toBridgeConfig() => <String, Object?>{
        if (holdTtl != null) 'holdTtlMs': holdTtl!.inMilliseconds,
        if (initialHoldId != null) 'initialHoldId': initialHoldId,
        if (initialHoldId != null) 'initialHoldOwner': initialHoldOwner.name,
        'readOnly': readOnly,
        'confirmSelection': confirmSelection,
        'enableBestAvailable': enableBestAvailable,
        'enable3D': enable3D,
        'enableSeatView': enableSeatView,
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
