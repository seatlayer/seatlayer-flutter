import 'package:flutter/widgets.dart';

import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';

/// Builds a replacement for one part of the default picker composition.
typedef SeatLayerPickerPartBuilder = Widget Function(
  BuildContext context,
  SeatLayerPickerPartContext part,
);

/// What a part builder is given: the live state, the controller, and the
/// widget the drop-in would have rendered.
class SeatLayerPickerPartContext {
  /// Creates a part context. Constructed by the picker, not by hosts.
  const SeatLayerPickerPartContext({
    required this.state,
    required this.controller,
    required this.defaultChild,
  });

  /// The most recent picker state.
  final SeatLayerPickerState state;

  /// The session driver, for actions the replacement needs to perform.
  final SeatLayerPickerController controller;

  /// What the default composition would have rendered here.
  ///
  /// Wrap it to decorate a part, or ignore it to replace one outright.
  final Widget defaultChild;
}

/// Optional replacements for non-mandatory parts of the adaptive picker.
///
/// The complete layout, test-mode marker and required SeatLayer attribution do
/// not have builder slots, so a custom builder cannot suppress compliance
/// chrome. Their appearance remains configurable through the picker theme.
class SeatLayerPickerBuilders {
  /// Creates a builder set; every slot is optional.
  const SeatLayerPickerBuilders({
    this.header,
    this.priceRail,
    this.legend,
    this.sectionNavigator,
    this.dockBar,
    this.accessibilityFilters,
    this.map,
    this.mapControls,
    this.bestAvailable,
    this.seatConfirmation,
    this.confirmCard,
    this.generalAdmissionPrompt,
    this.tablePrompt,
    this.selectionTray,
    this.cartSheet,
    this.venue3D,
    this.holdCountdown,
    this.actionError,
    this.checkoutBar,
    this.loading,
    this.error,
    this.empty,
  });

  /// Replaces the header.
  final SeatLayerPickerPartBuilder? header;

  /// Replaces the price legend. Alias of [legend]; prefer [legend].
  final SeatLayerPickerPartBuilder? priceRail;

  /// Replaces the price legend.
  final SeatLayerPickerPartBuilder? legend;

  /// Replaces the wide layout's section chip list.
  final SeatLayerPickerPartBuilder? sectionNavigator;

  /// Replaces the phone's rung-2 dock bar.
  final SeatLayerPickerPartBuilder? dockBar;

  /// Replaces the accessibility filter control.
  final SeatLayerPickerPartBuilder? accessibilityFilters;

  /// Replaces the drawn map surface.
  final SeatLayerPickerPartBuilder? map;

  /// Replaces the map corner controls.
  final SeatLayerPickerPartBuilder? mapControls;

  /// Replaces the best-available finder.
  final SeatLayerPickerPartBuilder? bestAvailable;

  /// Replaces the wide layout's seat confirmation.
  final SeatLayerPickerPartBuilder? seatConfirmation;

  /// Replaces the phone's seat confirm card.
  final SeatLayerPickerPartBuilder? confirmCard;

  /// Replaces the general-admission quantity prompt.
  final SeatLayerPickerPartBuilder? generalAdmissionPrompt;

  /// Replaces the table quantity prompt.
  final SeatLayerPickerPartBuilder? tablePrompt;

  /// Replaces the ticket list inside the cart.
  final SeatLayerPickerPartBuilder? selectionTray;

  /// Replaces the phone's cart sheet.
  final SeatLayerPickerPartBuilder? cartSheet;

  /// Replaces the chrome drawn over the immersive 3D scene.
  final SeatLayerPickerPartBuilder? venue3D;

  /// Replaces the hold countdown.
  final SeatLayerPickerPartBuilder? holdCountdown;

  /// Replaces the inline action error bar.
  final SeatLayerPickerPartBuilder? actionError;

  /// Replaces the checkout call to action.
  final SeatLayerPickerPartBuilder? checkoutBar;

  /// Replaces the loading view.
  final SeatLayerPickerPartBuilder? loading;

  /// Replaces the load-failure view.
  final SeatLayerPickerPartBuilder? error;

  /// Replaces the no-inventory view.
  final SeatLayerPickerPartBuilder? empty;
}
