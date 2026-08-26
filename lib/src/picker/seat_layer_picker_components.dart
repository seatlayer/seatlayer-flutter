import 'dart:async';

import 'package:flutter/material.dart';

import '../open_enums.dart';
import '../payloads.dart';
import '../seat_layer_error.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

class SeatLayerPickerAttribution extends StatelessWidget {
  const SeatLayerPickerAttribution({
    super.key,
    this.compact = true,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    if (state.branding?.attributionRequired != true) {
      return const SizedBox.shrink();
    }
    final theme = _theme(context, state);
    return Semantics(
      label: 'Powered by SeatLayer',
      child: Opacity(
        opacity: .72,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 2 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _SeatLayerPoweredMark(),
              const SizedBox(width: 5),
              Text(
                'Powered by SeatLayer',
                style: TextStyle(
                  color: theme.text,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatLayerPoweredMark extends StatelessWidget {
  const _SeatLayerPoweredMark();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1220),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox.square(
          dimension: 16,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _SeatLayerMarkRow(width: 10),
                _SeatLayerMarkRow(width: 7),
                _SeatLayerMarkRow(width: 4),
              ],
            ),
          ),
        ),
      );
}

class _SeatLayerMarkRow extends StatelessWidget {
  const _SeatLayerMarkRow({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFCF7EE),
            borderRadius: BorderRadius.circular(2),
          ),
          child: SizedBox(width: width, height: 2),
        ),
      );
}

class SeatLayerPickerSectionNavigator extends StatelessWidget {
  const SeatLayerPickerSectionNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final state = controller.state;
    final sections = state.snapshot?.sections ?? const [];
    if (sections.isEmpty || state.snapshot?.map.rung == 'seats') {
      return const SizedBox.shrink();
    }
    final theme = _theme(context, state);
    final active = state.snapshot?.map.focusedSectionId;
    return Material(
      color: theme.surface,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          scrollDirection: Axis.horizontal,
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final section = sections[index];
            return ChoiceChip(
              selected: active == section.id,
              label: Text(section.displayLabel ?? section.label),
              onSelected: state.isBusy
                  ? null
                  : (_) => _ignoreAction(controller.focusSection(section.id)),
            );
          },
        ),
      ),
    );
  }
}

class SeatLayerPickerAccessibilityFilters extends StatelessWidget {
  const SeatLayerPickerAccessibilityFilters({
    super.key,
    this.compact = false,
  });

  final bool compact;

  static const Map<String, String> _labels = <String, String>{
    'wheelchair': 'Wheelchair',
    'companion': 'Companion',
    'semi-ambulatory': 'Semi-ambulatory',
    'designated-aisle': 'Aisle seat',
    'step-free': 'Step-free',
    'hearing': 'Hearing support',
    'cart': 'Mobility cart',
    'sign-language': 'Sign language view',
    'low-vision': 'Low vision',
    'sensory-friendly': 'Sensory-friendly',
    'plus-size': 'Plus-size seat',
    'lift-armrest': 'Lift armrest',
  };

  @override
  Widget build(BuildContext context) {
    final state = SeatLayerPickerScope.stateOf(context);
    final snapshot = state.snapshot;
    if (snapshot == null ||
        !snapshot.capabilities.contains('accessibilityFilter')) {
      return const SizedBox.shrink();
    }
    final active = snapshot.map.accessibilityFilter;
    final onPressed = state.isBusy ? null : () => _ignoreAction(_show(context));
    if (compact) {
      final theme = _theme(context, state);
      return IconButton(
        tooltip: active.isEmpty
            ? 'Accessibility and view filters'
            : '${active.length} accessibility filters active',
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: theme.surface.withAlpha(240),
          foregroundColor: active.isEmpty ? theme.text : theme.accent,
          side: BorderSide(color: theme.divider),
        ),
        onPressed: onPressed,
        icon: Badge(
          isLabelVisible: active.isNotEmpty,
          label: Text('${active.length}'),
          child: const Icon(Icons.accessible_forward_rounded, size: 18),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.accessible_forward_rounded, size: 18),
      label:
          Text(active.isEmpty ? 'Accessibility' : '${active.length} filters'),
    );
  }

  Future<void> _show(BuildContext context) async {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final initial = <String>{
      ...?controller.state.snapshot?.map.accessibilityFilter,
    };
    final initialHideLimited =
        controller.state.snapshot?.map.hideLimitedView ?? false;
    var selected = initial;
    var hideLimited = initialHideLimited;
    final result = await showModalBottomSheet<
        ({
          Set<String> types,
          bool hideLimited,
        })>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Accessibility and view',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: _labels.entries.map((entry) {
                        final on = selected.contains(entry.key);
                        return FilterChip(
                          selected: on,
                          label: Text(entry.value),
                          onSelected: (_) => setSheetState(() {
                            selected = <String>{...selected};
                            on
                                ? selected.remove(entry.key)
                                : selected.add(entry.key);
                          }),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hide limited-view seats'),
                  value: hideLimited,
                  onChanged: (value) =>
                      setSheetState(() => hideLimited = value),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    (types: selected, hideLimited: hideLimited),
                  ),
                  child: const Text('Apply filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result == null) return;
    await controller.setAccessibilityFilter(result.types);
    if (result.hideLimited != initialHideLimited) {
      await controller.setLimitedViewHidden(result.hideLimited);
    }
  }
}

class SeatLayerPickerSeatConfirmation extends StatefulWidget {
  const SeatLayerPickerSeatConfirmation({
    super.key,
    this.seat,
    this.onConfirm,
    this.onCancel,
  });

  final SelectedSeat? seat;
  final FutureOr<void> Function(SelectedSeat seat)? onConfirm;
  final FutureOr<void> Function(SelectedSeat seat)? onCancel;

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
    if (seat == null || seat.label == _dismissedLabel) {
      return const SizedBox.shrink();
    }
    _tierId ??= seat.tierId ?? seat.tiers?.firstOrNull?.id;
    final theme = _theme(context, controller.state);
    return _PromptFrame(
      title: seat.buyerFacingLabel,
      subtitle: _seatSubtitle(seat),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (seat.commercial?.restrictedView == true ||
              seat.commercial?.obstructedView == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                seat.commercial?.note ?? 'This seat may have a limited view.',
                style: TextStyle(color: theme.warning),
              ),
            ),
          if (seat.tiers?.isNotEmpty == true)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ticket type',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _tierId,
                  items: seat.tiers!
                      .map(
                        (tier) => DropdownMenuItem<String>(
                          value: tier.id,
                          child: Text(
                            '${tier.name} · ${_money(tier.price, seat.currency ?? 'USD')}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: controller.state.isBusy
                      ? null
                      : (tierId) => setState(() => _tierId = tierId),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.state.isBusy
                      ? null
                      : () => _cancel(controller, seat),
                  child: const Text('Remove'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: controller.state.isBusy
                      ? null
                      : () => _confirm(controller, seat),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
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
}

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
                  onPressed: () => _ignoreAction(() async {
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
                      : () => _ignoreAction(() async {
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
                          '${tier.name} · ${_money(tier.price, area.currency ?? 'USD')}',
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
                      : () => _ignoreAction(() async {
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

class SeatLayerPickerActionError extends StatelessWidget {
  const SeatLayerPickerActionError({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SeatLayerPickerScope.controllerOf(context);
    final error = controller.state.error;
    if (error == null || controller.state.phase != SeatLayerPickerPhase.ready) {
      return const SizedBox.shrink();
    }
    final theme = _theme(context, controller.state);
    final message = error is SeatLayerError ? error.message : '$error';
    return Material(
      color: theme.error,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 9),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Dismiss error',
              onPressed: controller.dismissError,
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
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
    final state = SeatLayerPickerScope.stateOf(context);
    final theme = _theme(context, state);
    return Align(
      alignment: Alignment.bottomCenter,
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
    );
  }
}

String _seatSubtitle(SelectedSeat seat) {
  final type = seat.displayType ??
      (seat.objectType == ObjectType.table ? 'Table' : 'Seat');
  final price = seat.price == null
      ? ''
      : ' · ${_money(seat.price!, seat.currency ?? 'USD')}';
  return '$type$price';
}

String _money(double amount, String currency) {
  final decimals = amount == amount.roundToDouble() ? 0 : 2;
  return '$currency ${amount.toStringAsFixed(decimals)}';
}

SeatLayerResolvedPickerTheme _theme(
  BuildContext context,
  SeatLayerPickerState state,
) =>
    resolveSeatLayerPickerTheme(
      context,
      state,
      SeatLayerPickerScope.themeOf(context),
    );

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}

void _ignoreAction(Future<void> action) {
  unawaited(action.catchError((Object _) {}));
}
