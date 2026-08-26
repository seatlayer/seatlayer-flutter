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

class SeatLayerPickerBuilders {
  const SeatLayerPickerBuilders({
    this.layout,
    this.header,
    this.testModeIndicator,
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
    this.attribution,
    this.actionError,
    this.checkoutBar,
    this.loading,
    this.error,
    this.empty,
  });

  final SeatLayerPickerPartBuilder? layout;
  final SeatLayerPickerPartBuilder? header;
  final SeatLayerPickerPartBuilder? testModeIndicator;
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
  final SeatLayerPickerPartBuilder? attribution;
  final SeatLayerPickerPartBuilder? actionError;
  final SeatLayerPickerPartBuilder? checkoutBar;
  final SeatLayerPickerPartBuilder? loading;
  final SeatLayerPickerPartBuilder? error;
  final SeatLayerPickerPartBuilder? empty;
}
