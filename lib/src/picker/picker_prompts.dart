/// Quantity prompts: a table's guests, and a general-admission run.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../payloads.dart';
import 'picker_internal.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPickerTablePrompt extends StatefulWidget {
  const SeatLayerPickerTablePrompt({
    super.key,
    required this.table,
    this.onConfirm,
    this.onCancel,
  });

  final SelectedSeat table;
  final FutureOr<void> Function(SelectedSeat table)? onConfirm;
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
    final min = widget.table.minOccupancy ?? 1;
    final max = widget.table.maxOccupancy ?? widget.table.capacity ?? min;
    return _PromptFrame(
      title: widget.table.buyerFacingLabel,
      subtitle: 'Choose the number of guests for this table',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _quantity > min
                    ? () => setState(() => _quantity -= 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton.filledTonal(
                onPressed: _quantity < max
                    ? () => setState(() => _quantity += 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ignorePickerAction(() async {
                    if (widget.onCancel != null) {
                      await widget.onCancel!(widget.table);
                    } else {
                      await controller.removeObject(widget.table.label);
                    }
                  }()),
                  child: const Text('Remove'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: controller.state.isBusy
                      ? null
                      : () => ignorePickerAction(() async {
                            await controller.setTableQuantity(
                              label: widget.table.label,
                              quantity: _quantity,
                            );
                            await widget.onConfirm?.call(widget.table);
                          }()),
                  child: const Text('Confirm table'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SeatLayerPickerGeneralAdmissionPrompt extends StatefulWidget {
  const SeatLayerPickerGeneralAdmissionPrompt({
    super.key,
    this.area,
    this.onConfirmed,
    this.onCancel,
  });

  final GAArea? area;
  final FutureOr<void> Function(GAArea area)? onConfirmed;
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
    final area = widget.area ?? controller.state.generalAdmissionCandidate;
    if (area == null) return const SizedBox.shrink();
    _tierId ??= area.tiers?.firstOrNull?.id;
    final selectedCount = controller.state.snapshot?.ticketCount ?? 0;
    final remainingCap =
        (controller.state.snapshot?.maxSelection ?? 10) - selectedCount;
    final max = [area.available ?? remainingCap, remainingCap]
        .where((value) => value > 0)
        .fold<int>(remainingCap, (a, b) => a < b ? a : b);
    return _PromptFrame(
      title: area.label ?? 'General admission',
      subtitle: '${area.available ?? 0} places currently available',
      child: Column(
        children: [
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
                          '${tier.name} · ${pickerMoney(context, tier.price, area.currency ?? 'USD')}',
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (tierId) => setState(() => _tierId = tierId),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity -= 1) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton.filledTonal(
                onPressed: _quantity < max
                    ? () => setState(() => _quantity += 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.dismissGeneralAdmissionCandidate();
                    widget.onCancel?.call();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: max < 1 ||
                          controller.state.isBusy ||
                          !controller.state.canMutateInventory
                      ? null
                      : () => ignorePickerAction(() async {
                            await controller.setGeneralAdmissionQuantity(
                              areaId: area.id,
                              quantitiesByTier: <String?, int>{
                                _tierId: _quantity,
                              },
                            );
                            await widget.onConfirmed?.call(area);
                          }()),
                  child: const Text('Add tickets'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromptFrame extends StatelessWidget {
  const _PromptFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: theme.surface,
            elevation: 14,
            borderRadius: BorderRadius.circular(theme.radius),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: theme.mutedText)),
                  const SizedBox(height: 14),
                  child,
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
