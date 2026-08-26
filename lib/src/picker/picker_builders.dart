import 'package:flutter/widgets.dart';

import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

typedef SeatLayerPickerPartBuilder = Widget Function(
  BuildContext context,
  SeatLayerPickerPartContext part,
);

class SeatLayerPickerPartContext {
  const SeatLayerPickerPartContext({
    required this.state,
    required this.controller,
    required this.defaultChild,
  });

  final SeatLayerPickerState state;
  final SeatLayerPickerController controller;
  final Widget defaultChild;
}

/// Optional replacements for non-mandatory parts of the adaptive picker.
///
/// The complete layout, test-mode marker and required SeatLayer attribution do
/// not have builder slots, so a custom builder cannot suppress compliance
/// chrome. Their appearance remains configurable through the picker theme.
class SeatLayerPickerBuilders {
  const SeatLayerPickerBuilders({
    this.header,
    this.priceRail,
    this.sectionNavigator,
    this.accessibilityFilters,
    this.map,
    this.mapControls,
    this.bestAvailable,
    this.seatConfirmation,
    this.generalAdmissionPrompt,
    this.tablePrompt,
    this.selectionTray,
    this.holdCountdown,
    this.actionError,
    this.checkoutBar,
    this.loading,
    this.error,
    this.empty,
  });

  final SeatLayerPickerPartBuilder? header;
  final SeatLayerPickerPartBuilder? priceRail;
  final SeatLayerPickerPartBuilder? sectionNavigator;
  final SeatLayerPickerPartBuilder? accessibilityFilters;
  final SeatLayerPickerPartBuilder? map;
  final SeatLayerPickerPartBuilder? mapControls;
  final SeatLayerPickerPartBuilder? bestAvailable;
  final SeatLayerPickerPartBuilder? seatConfirmation;
  final SeatLayerPickerPartBuilder? generalAdmissionPrompt;
  final SeatLayerPickerPartBuilder? tablePrompt;
  final SeatLayerPickerPartBuilder? selectionTray;
  final SeatLayerPickerPartBuilder? holdCountdown;
  final SeatLayerPickerPartBuilder? actionError;
  final SeatLayerPickerPartBuilder? checkoutBar;
  final SeatLayerPickerPartBuilder? loading;
  final SeatLayerPickerPartBuilder? error;
  final SeatLayerPickerPartBuilder? empty;
}
