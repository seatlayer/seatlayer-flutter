/// The wide layout's seat confirmation, and the two ways to look at a seat.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_ticket_tiers.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

class SeatLayerPickerSeatConfirmation extends StatefulWidget {
  const SeatLayerPickerSeatConfirmation({
    super.key,
    this.seat,
    this.onConfirm,
    this.onCancel,
    this.onViewFromSeat,
    this.onShow3D,
    this.showSeatView = true,
    this.show3D = true,
  });

  final SelectedSeat? seat;
  final FutureOr<void> Function(SelectedSeat seat)? onConfirm;
  final FutureOr<void> Function(SelectedSeat seat)? onCancel;

  /// Optional replacement for the SDK seat-view action.
  ///
  /// When omitted, the component opens SeatLayer's authored/chart-derived
  /// seat-view surface whenever the negotiated runtime supports it.
  final FutureOr<void> Function(SelectedSeat seat)? onViewFromSeat;

  /// Optional replacement for the SDK's real venue-3D action.
  ///
  /// When omitted, the component enters the negotiated venue scene and flies
  /// to the candidate seat. Unsupported actions remain absent.
  final FutureOr<void> Function(SelectedSeat seat)? onShow3D;

  /// Whether the capability-gated view-from-seat action may be shown.
  final bool showSeatView;

  /// Whether the capability-gated real venue-3D action may be shown.
  final bool show3D;

  @override
  State<SeatLayerPickerSeatConfirmation> createState() =>
      _SeatLayerPickerSeatConfirmationState();
}

class _SeatLayerPickerSeatConfirmationState
    extends State<SeatLayerPickerSeatConfirmation> {
  String? _tierId;
  String? _dismissedLabel;

  @override
  void didUpdateWidget(covariant SeatLayerPickerSeatConfirmation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seat?.label != widget.seat?.label) {
      _tierId = widget.seat?.tierId;
      _dismissedLabel = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (SeatLayerPickerScope.optionsOf(context).readOnly) {
      return const SizedBox.shrink();
    }
    final seat = widget.seat ?? controller.state.selection.lastOrNull;
    final immersiveUp = controller.seatView?.hasContent == true ||
        (controller.state.snapshot?.map.isVenue3D ?? false);
    if (seat == null || immersiveUp || seat.label == _dismissedLabel) {
      return const SizedBox.shrink();
    }
    _tierId ??= seat.tierId ?? seat.tiers?.firstOrNull?.id;
    final theme = seatLayerPickerThemeOf(context);
    final category = controller.state.categories
        .where((item) => item.key == seat.categoryKey)
        .firstOrNull;
    final categoryColor = pickerColor(category?.color) ?? theme.accent;
    final categoryLabel = category?.label ?? seat.categoryKey ?? 'Ticket';
    final identity = <({String key, String value})>[
      if (seat.sectionLabel?.trim().isNotEmpty == true)
        (key: 'Section', value: seat.sectionLabel!.trim()),
      if (seat.rowLabel?.trim().isNotEmpty == true)
        (
          key: seat.displayType?.trim().isNotEmpty == true
              ? seat.displayType!.trim()
              : seat.rowType?.trim().isNotEmpty == true
                  ? seat.rowType!.trim()
                  : 'Row',
          value: seat.rowLabel!.trim(),
        ),
      (
        key: seat.objectType == ObjectType.booth ? 'Place' : 'Seat',
        value: seat.seatNumber?.trim().isNotEmpty == true
            ? seat.seatNumber!.trim()
            : seat.buyerFacingLabel,
      ),
    ];
    final limitedView = seat.commercial?.restrictedView == true ||
        seat.commercial?.obstructedView == true;
    final wheelchair = seat.wheelchairSpaceType != null ||
        (seat.accessibility ?? const <String>[])
            .any((item) => item.toLowerCase().contains('wheelchair'));
    final tiers = seat.tiers ?? const <CategoryTier>[];
    final selectedPrice = seatLayerPickerSelectedPrice(seat, _tierId);
    final selectedCurrency = seatLayerPickerSelectedCurrency(seat, _tierId);
    final maxHeight = MediaQuery.sizeOf(context).height * .72;
    final capabilities =
        controller.state.snapshot?.capabilities ?? const <String>{};
    final viewFromSeat = widget.showSeatView
        ? widget.onViewFromSeat ??
            (capabilities.contains('seatView') ? controller.openSeatView : null)
        : null;
    final show3D = widget.show3D
        ? widget.onShow3D ??
            (capabilities.contains('venue3d') ? controller.showSeatIn3D : null)
        : null;
    final inspectionActions = <Widget>[
      if (viewFromSeat != null)
        SeatLayerPickerSeatViewButton(
          seat: seat,
          onPressed: (candidate) => _inspect(candidate, viewFromSeat),
        ),
      if (show3D != null)
        SeatLayerPickerSeat3DButton(
          seat: seat,
          onPressed: (candidate) => _inspect(candidate, show3D),
        ),
    ];

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 430, maxHeight: maxHeight),
          child: Material(
            color: theme.surface,
            elevation: 18,
            shadowColor: pickerAlpha(Colors.black, .26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(theme.radius + 6),
              side: BorderSide(color: pickerAlpha(theme.divider, .9)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0;
                            index < identity.length;
                            index++) ...[
                          Expanded(
                            flex: index == 0 && identity.length == 3 ? 5 : 4,
                            child: _SeatIdentityField(
                              label: identity[index].key,
                              value: identity[index].value,
                            ),
                          ),
                          if (index != identity.length - 1)
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: theme.divider,
                            ),
                        ],
                      ],
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        pickerAlpha(categoryColor, .10),
                        theme.surface,
                      ),
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: pickerAlpha(categoryColor, .16),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: pickerAlpha(theme.text, .28),
                                width: 1.5,
                              ),
                            ),
                            child: const SizedBox.square(dimension: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 16,
                                fontWeight: seatLayerBoldWeight(
                                    context, FontWeight.w800),
                              ),
                            ),
                          ),
                          if (selectedPrice != null)
                            Text(
                              pickerMoney(
                                context,
                                selectedPrice,
                                selectedCurrency,
                              ),
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 19,
                                fontWeight: seatLayerBoldWeight(
                                    context, FontWeight.w900),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (tiers.length > 1) ...[
                          Text(
                            'Ticket type',
                            style: TextStyle(
                              color: theme.mutedText,
                              fontSize: 12,
                              fontWeight:
                                  seatLayerBoldWeight(context, FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 7),
                          for (final tier in tiers)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: SeatLayerPickerSeatTierChoice(
                                tier: tier,
                                currency: seat.currency ?? 'USD',
                                selected: _tierId == tier.id,
                                enabled: !controller.state.isBusy,
                                onTap: () => setState(() => _tierId = tier.id),
                              ),
                            ),
                        ] else if (tiers.firstOrNull?.buyerMessage != null) ...[
                          Text(
                            tiers.first.buyerMessage!,
                            style: TextStyle(color: theme.mutedText),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (limitedView)
                          _SeatNotice(
                            icon: Icons.visibility_off_outlined,
                            color: theme.warning,
                            title: 'View information',
                            message: seat.commercial?.note ??
                                'This seat may have a limited or obstructed view.',
                          ),
                        if (wheelchair)
                          _SeatNotice(
                            icon: Icons.accessible_rounded,
                            color: theme.accent,
                            title: 'Accessible place',
                            message: seat.wheelchairSpaceType == 'no-seat'
                                ? 'Wheelchair space without a fixed chair.'
                                : 'Wheelchair-accessible seating.',
                          ),
                        if (inspectionActions.isNotEmpty) ...[
                          _SeatInspectionActions(children: inspectionActions),
                          const SizedBox(height: 14),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  foregroundColor: theme.text,
                                  disabledForegroundColor:
                                      pickerAlpha(theme.mutedText, .5),
                                  backgroundColor: Color.alphaBlend(
                                    pickerAlpha(theme.text, .035),
                                    theme.surface,
                                  ),
                                  overlayColor: pickerAlpha(theme.text, .055),
                                  side: BorderSide(color: theme.divider),
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: seatLayerBoldWeight(
                                        context, FontWeight.w800),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      theme.buttonRadius,
                                    ),
                                  ),
                                ),
                                onPressed: controller.state.isBusy
                                    ? null
                                    : () => _cancel(controller, seat),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  backgroundColor: theme.accent,
                                  foregroundColor: theme.onAccent,
                                  disabledBackgroundColor: Color.alphaBlend(
                                    pickerAlpha(theme.mutedText, .16),
                                    theme.surface,
                                  ),
                                  disabledForegroundColor:
                                      pickerAlpha(theme.mutedText, .58),
                                  elevation: 0,
                                  overlayColor:
                                      pickerAlpha(theme.onAccent, .12),
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: seatLayerBoldWeight(
                                        context, FontWeight.w800),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      theme.buttonRadius,
                                    ),
                                  ),
                                ),
                                onPressed: controller.state.isBusy
                                    ? null
                                    : () => _confirm(controller, seat),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Select'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(
    SeatLayerPickerController controller,
    SelectedSeat seat,
  ) async {
    try {
      if (_tierId != null && _tierId != seat.tierId) {
        await controller.setSeatTier(seat.id, _tierId);
      }
      await widget.onConfirm?.call(seat);
      if (mounted) setState(() => _dismissedLabel = seat.label);
    } catch (_) {
      // The controller keeps the typed failure in picker state for native UI.
    }
  }

  Future<void> _cancel(
    SeatLayerPickerController controller,
    SelectedSeat seat,
  ) async {
    try {
      if (widget.onCancel != null) {
        await widget.onCancel!(seat);
      } else {
        await controller.removeObject(seat.label);
      }
      if (mounted) setState(() => _dismissedLabel = seat.label);
    } catch (_) {
      // The controller keeps the typed failure in picker state for native UI.
    }
  }

  Future<void> _inspect(
    SelectedSeat seat,
    FutureOr<void> Function(SelectedSeat seat) action,
  ) async {
    try {
      await action(seat);
    } catch (_) {
      // Controller-backed actions already publish a typed picker error. A
      // custom action can render its own failure while this card stays put.
    }
  }
}

class _SeatInspectionActions extends StatelessWidget {
  const _SeatInspectionActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (children.length == 1) return children.single;
          if (constraints.maxWidth < 330) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index != children.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          }
          return Row(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                Expanded(child: children[index]),
                if (index != children.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      );
}

/// A reusable view-from-seat action.
///
/// Without [onPressed], it calls the SDK controller and hides itself unless the
/// runtime advertises an authored or honest chart-derived seat view.
class SeatLayerPickerSeatViewButton extends StatelessWidget {
  const SeatLayerPickerSeatViewButton({
    super.key,
    required this.seat,
    this.onPressed,
  });

  final SelectedSeat seat;
  final FutureOr<void> Function(SelectedSeat seat)? onPressed;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final controller = SeatLayerPickerScope.controllerOf(context);
    final action = onPressed ??
        (state.snapshot?.capabilities.contains('seatView') == true
            ? controller.openSeatView
            : null);
    if (action == null) return const SizedBox.shrink();
    return OutlinedButton.icon(
      style: _seatInspectionButtonStyle(context, theme),
      onPressed: state.isBusy ? null : () => action(seat),
      icon: const Icon(Icons.visibility_outlined),
      label: const Text('View from here'),
    );
  }
}

/// A reusable venue-3D action.
///
/// Without [onPressed], it flies to [seat] through the SDK controller and hides
/// itself when the negotiated runtime cannot render real venue 3D.
class SeatLayerPickerSeat3DButton extends StatelessWidget {
  const SeatLayerPickerSeat3DButton({
    super.key,
    required this.seat,
    this.onPressed,
  });

  final SelectedSeat seat;
  final FutureOr<void> Function(SelectedSeat seat)? onPressed;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final controller = SeatLayerPickerScope.controllerOf(context);
    final action = onPressed ??
        (state.snapshot?.capabilities.contains('venue3d') == true
            ? controller.showSeatIn3D
            : null);
    if (action == null) return const SizedBox.shrink();
    final alreadyIn3D = state.snapshot?.map.isVenue3D ?? false;
    return OutlinedButton.icon(
      style: _seatInspectionButtonStyle(context, theme),
      onPressed: state.isBusy ? null : () => action(seat),
      icon: Icon(
        alreadyIn3D
            ? Icons.airline_seat_recline_normal_rounded
            : Icons.view_in_ar_outlined,
      ),
      label: Text(alreadyIn3D ? 'View from this seat' : 'See it in 3D'),
    );
  }
}

ButtonStyle _seatInspectionButtonStyle(
  BuildContext context,
  SeatLayerResolvedPickerTheme theme,
) =>
    OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      foregroundColor: theme.text,
      disabledForegroundColor: pickerAlpha(theme.mutedText, .5),
      backgroundColor: Color.alphaBlend(
        pickerAlpha(theme.accent, .055),
        theme.surface,
      ),
      overlayColor: pickerAlpha(theme.accent, .08),
      side: BorderSide(color: pickerAlpha(theme.accent, .18)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: TextStyle(
        fontSize: 13,
        fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.buttonRadius),
      ),
    );

class _SeatIdentityField extends StatelessWidget {
  const _SeatIdentityField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w900),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.text,
              fontSize: 17,
              height: 1.05,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatNotice extends StatelessWidget {
  const _SeatNotice({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pickerAlpha(color, .10),
          borderRadius: BorderRadius.circular(theme.radius),
          border: Border.all(color: pickerAlpha(color, .35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.text,
                        fontWeight:
                            seatLayerBoldWeight(context, FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}

// ignore: unused_element
