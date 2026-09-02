/// Quantity prompts: a table's guests, and a general-admission run.
///
/// Both are the same object — a sheet rising from the bottom of the picker
/// with one number in it — because they ask the buyer the same question. The
/// stepper is the whole interface: a keyboard for a number between two and
/// eight is a keyboard nobody needed.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// How many guests will sit at one table.
class SeatLayerPickerTablePrompt extends StatefulWidget {
  /// Creates the table prompt.
  const SeatLayerPickerTablePrompt({
    super.key,
    required this.table,
    this.onConfirm,
    this.onCancel,
  });

  /// The table the buyer tapped.
  final SelectedSeat table;

  /// Replaces the default "commit the quantity" action.
  final FutureOr<void> Function(SelectedSeat table)? onConfirm;

  /// Replaces the default "give the table back" action.
  final FutureOr<void> Function(SelectedSeat table)? onCancel;

  @override
  State<SeatLayerPickerTablePrompt> createState() =>
      _SeatLayerPickerTablePromptState();
}

class _SeatLayerPickerTablePromptState
    extends State<SeatLayerPickerTablePrompt> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.table.quantity ?? widget.table.minOccupancy ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (SeatLayerPickerScope.optionsOf(context).readOnly) {
      return const SizedBox.shrink();
    }
    final strings = SeatLayerPickerScope.stringsOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final min = widget.table.minOccupancy ?? 1;
    final max = widget.table.maxOccupancy ?? widget.table.capacity ?? min;
    // A table already in the cart is being changed, not chosen: the button
    // says which of those two the press will do.
    final inCart = widget.table.quantity != null;
    return _PromptSheet(
      title: widget.table.buyerFacingLabel,
      subtitle: strings.chooseGuestsCopy,
      children: <Widget>[
        _StepperLabel(text: strings.numberOfGuests, theme: theme),
        _PromptStepper(
          value: _quantity,
          canDecrease: _quantity > min,
          canIncrease: _quantity < max,
          decreaseLabel: strings.fewerGuests,
          increaseLabel: strings.moreGuests,
          onChanged: (next) => setState(() => _quantity = next),
        ),
        if (max > min)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              strings.chooseMinMaxGuests(min, max),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 11,
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
        _PromptActions(
          dismissLabel: strings.removeWord,
          confirmLabel: inCart ? strings.updateTable : strings.selectTable,
          onDismiss: () => ignorePickerAction(() async {
            if (widget.onCancel != null) {
              await widget.onCancel!(widget.table);
            } else {
              await controller.removeObject(widget.table.label);
            }
          }()),
          onConfirm: controller.state.isBusy
              ? null
              : () => ignorePickerAction(() async {
                    await controller.setTableQuantity(
                      label: widget.table.label,
                      quantity: _quantity,
                    );
                    await widget.onConfirm?.call(widget.table);
                  }()),
        ),
      ],
    );
  }
}

/// How many places to take in one standing area.
class SeatLayerPickerGeneralAdmissionPrompt extends StatefulWidget {
  /// Creates the standing-area prompt.
  const SeatLayerPickerGeneralAdmissionPrompt({
    super.key,
    this.area,
    this.onConfirmed,
    this.onCancel,
  });

  /// The area to ask about, or null to read the controller's candidate.
  final GAArea? area;

  /// Called once the quantity is committed.
  final FutureOr<void> Function(GAArea area)? onConfirmed;

  /// Called when the buyer backs out.
  final VoidCallback? onCancel;

  @override
  State<SeatLayerPickerGeneralAdmissionPrompt> createState() =>
      _SeatLayerPickerGeneralAdmissionPromptState();
}

class _SeatLayerPickerGeneralAdmissionPromptState
    extends State<SeatLayerPickerGeneralAdmissionPrompt> {
  int _quantity = 1;
  String? _tierId;

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    if (SeatLayerPickerScope.optionsOf(context).readOnly) {
      return const SizedBox.shrink();
    }
    final strings = SeatLayerPickerScope.stringsOf(context);
    final theme = seatLayerPickerThemeOf(context);
    final area = widget.area ?? controller.state.generalAdmissionCandidate;
    if (area == null) return const SizedBox.shrink();
    _tierId ??= area.tiers?.firstOrNull?.id;
    final selectedCount = controller.state.snapshot?.ticketCount ?? 0;
    final remainingCap =
        (controller.state.snapshot?.maxSelection ?? 10) - selectedCount;
    final max = [area.available ?? remainingCap, remainingCap]
        .where((value) => value > 0)
        .fold<int>(remainingCap, (a, b) => a < b ? a : b);
    return _PromptSheet(
      title: area.label ?? strings.generalAdmission,
      subtitle: strings.placesAvailable(area.available ?? 0),
      children: <Widget>[
        if (area.tiers?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _tierId,
              items: area.tiers!
                  .map(
                    (tier) => DropdownMenuItem<String>(
                      value: tier.id,
                      child: Text(
                        '${tier.name} · '
                        '${pickerMoney(context, tier.price, area.currency ?? 'USD')}',
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (tierId) => setState(() => _tierId = tierId),
            ),
          ),
        _StepperLabel(text: strings.chooseTickets, theme: theme),
        _PromptStepper(
          value: _quantity,
          canDecrease: _quantity > 1,
          canIncrease: _quantity < max,
          decreaseLabel: strings.fewerTickets,
          increaseLabel: strings.moreTickets,
          onChanged: (next) => setState(() => _quantity = next),
        ),
        _PromptActions(
          dismissLabel: strings.cancel,
          confirmLabel: strings.addTickets,
          onDismiss: () {
            controller.dismissGeneralAdmissionCandidate();
            widget.onCancel?.call();
          },
          onConfirm: max < 1 ||
                  controller.state.isBusy ||
                  !controller.state.canMutateInventory
              ? null
              : () => ignorePickerAction(() async {
                    await controller.setGeneralAdmissionQuantity(
                      areaId: area.id,
                      quantitiesByTier: <String?, int>{_tierId: _quantity},
                    );
                    await widget.onConfirmed?.call(area);
                  }()),
        ),
      ],
    );
  }
}

/// The label over a stepper: what the number counts.
class _StepperLabel extends StatelessWidget {
  const _StepperLabel({required this.text, required this.theme});

  final String text;
  final SeatLayerResolvedPickerTheme theme;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: theme.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            fontFamily: theme.fontFamily,
          ),
        ),
      );
}

/// One number between two 48 pt buttons.
class _PromptStepper extends StatelessWidget {
  const _PromptStepper({
    required this.value,
    required this.canDecrease,
    required this.canIncrease,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.onChanged,
  });

  final int value;
  final bool canDecrease;
  final bool canIncrease;
  final String decreaseLabel;
  final String increaseLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: <Widget>[
            _StepperButton(
              icon: Icons.remove_rounded,
              semanticsLabel: decreaseLabel,
              onPressed: canDecrease ? () => onChanged(value - 1) : null,
            ),
            Expanded(
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              semanticsLabel: increaseLabel,
              onPressed: canIncrease ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          color: pickerAlpha(theme.divider, .34),
          child: Icon(
            icon,
            size: 22,
            color: onPressed == null
                ? pickerAlpha(theme.mutedText, .5)
                : theme.text,
          ),
        ),
      ),
    );
  }
}

/// The way out and the way on, side by side and thumb-sized.
class _PromptActions extends StatelessWidget {
  const _PromptActions({
    required this.dismissLabel,
    required this.confirmLabel,
    required this.onDismiss,
    required this.onConfirm,
  });

  final String dismissLabel;
  final String confirmLabel;
  final VoidCallback onDismiss;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 17),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.mutedText,
                side: BorderSide(color: theme.divider),
                minimumSize: const Size(0, 48),
                shape: shape,
              ),
              onPressed: onDismiss,
              child: Text(
                dismissLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: theme.onAccent,
                minimumSize: const Size(0, 48),
                shape: shape,
              ),
              onPressed: onConfirm,
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The sheet both prompts rise in.
class _PromptSheet extends StatelessWidget {
  const _PromptSheet({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          color: theme.surface,
          elevation: SeatLayerElevationTokens.sheet,
          // Rising from the edge it came from: square at the bottom, rounded
          // at the top, the way every sheet on a phone arrives.
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 22,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.mutedText,
                      fontSize: 13,
                      height: 1.45,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
