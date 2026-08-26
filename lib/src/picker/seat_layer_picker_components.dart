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
        opacity: compact ? .64 : .72,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 12,
            vertical: compact ? 1 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SeatLayerPoweredMark(compact: compact),
              SizedBox(width: compact ? 4 : 5),
              Text(
                'Powered by SeatLayer',
                style: TextStyle(
                  color: theme.text,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: compact ? .1 : .2,
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
  const _SeatLayerPoweredMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dimension = compact ? 12.0 : 16.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1220),
        borderRadius: BorderRadius.circular(compact ? 3 : 4),
      ),
      child: SizedBox.square(
        dimension: dimension,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 2 : 3,
            vertical: compact ? 2.5 : 3.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SeatLayerMarkRow(width: compact ? 8 : 10),
              _SeatLayerMarkRow(width: compact ? 5.5 : 7),
              _SeatLayerMarkRow(width: compact ? 3 : 4),
            ],
          ),
        ),
      ),
    );
  }
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
    if (seat == null || seat.label == _dismissedLabel) {
      return const SizedBox.shrink();
    }
    _tierId ??= seat.tierId ?? seat.tiers?.firstOrNull?.id;
    final theme = _theme(context, controller.state);
    final category = controller.state.categories
        .where((item) => item.key == seat.categoryKey)
        .firstOrNull;
    final categoryColor = _color(category?.color) ?? theme.accent;
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

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 430, maxHeight: maxHeight),
        child: Material(
          color: theme.surface,
          elevation: 24,
          shadowColor: _alpha(Colors.black, .42),
          borderRadius: BorderRadius.circular(theme.radius + 4),
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
                      for (var index = 0; index < identity.length; index++) ...[
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
                ColoredBox(
                  color: Color.alphaBlend(
                    _alpha(categoryColor, .24),
                    theme.surface,
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
                              color: _alpha(theme.text, .28),
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (seat.price != null)
                          Text(
                            _money(
                              context,
                              seat.price!,
                              seat.currency ?? 'USD',
                            ),
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        for (final tier in tiers)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: _SeatTierChoice(
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
                      if (viewFromSeat != null) ...[
                        SeatLayerPickerSeatViewButton(
                          seat: seat,
                          onPressed: (candidate) =>
                              _inspect(candidate, viewFromSeat),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (show3D != null) ...[
                        SeatLayerPickerSeat3DButton(
                          seat: seat,
                          onPressed: (candidate) => _inspect(candidate, show3D),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: BorderSide(color: theme.divider),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(theme.radius),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(theme.radius),
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
    setState(() => _dismissedLabel = seat.label);
    try {
      await action(seat);
    } catch (_) {
      if (mounted) setState(() => _dismissedLabel = null);
      // Controller-backed actions already publish a typed picker error. A
      // custom action can render its own failure before this card returns.
    }
  }
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
    final theme = _theme(context, state);
    final controller = SeatLayerPickerScope.controllerOf(context);
    final action = onPressed ??
        (state.snapshot?.capabilities.contains('seatView') == true
            ? controller.openSeatView
            : null);
    if (action == null) return const SizedBox.shrink();
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: theme.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius),
        ),
      ),
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
    final theme = _theme(context, state);
    final controller = SeatLayerPickerScope.controllerOf(context);
    final action = onPressed ??
        (state.snapshot?.capabilities.contains('venue3d') == true
            ? controller.showSeatIn3D
            : null);
    if (action == null) return const SizedBox.shrink();
    final alreadyIn3D = state.snapshot?.map.isVenue3D ?? false;
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius),
        ),
      ),
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

class _SeatIdentityField extends StatelessWidget {
  const _SeatIdentityField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = _theme(context, SeatLayerPickerScope.stateOf(context));
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
              fontWeight: FontWeight.w900,
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
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatTierChoice extends StatelessWidget {
  const _SeatTierChoice({
    required this.tier,
    required this.currency,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final CategoryTier tier;
  final String currency;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = _theme(context, SeatLayerPickerScope.stateOf(context));
    final guidance = tier.buyerMessage ??
        (tier.restriction == 'companion'
            ? 'Requires the adjacent wheelchair place.'
            : null);
    return Material(
      color: selected ? _alpha(theme.accent, .10) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.radius),
        side: BorderSide(
          color: selected ? theme.accent : theme.divider,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.radius),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? theme.accent : theme.mutedText,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name,
                      style: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (guidance != null)
                      Text(
                        guidance,
                        style: TextStyle(
                          color: theme.mutedText,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _money(context, tier.price, tier.currency ?? currency),
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
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
    final theme = _theme(context, SeatLayerPickerScope.stateOf(context));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _alpha(color, .10),
          borderRadius: BorderRadius.circular(theme.radius),
          border: Border.all(color: _alpha(color, .35)),
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
                        fontWeight: FontWeight.w800,
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
                          '${tier.name} · ${_money(context, tier.price, area.currency ?? 'USD')}',
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

String _money(BuildContext context, double amount, String currency) {
  final formatter = SeatLayerPickerScope.optionsOf(context).pricing?.formatter;
  if (formatter != null) return formatter(amount, currency);
  const symbols = <String, String>{
    'EUR': '€',
    'USD': r'$',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'KRW': '₩',
  };
  final decimals = amount == amount.roundToDouble() ? 0 : 2;
  final value = amount.toStringAsFixed(decimals);
  final code = currency.toUpperCase();
  final symbol = symbols[code];
  return symbol == null ? '$code $value' : '$symbol$value';
}

Color? _color(String? raw) {
  if (raw == null) return null;
  final value = raw.trim().replaceFirst('#', '');
  if (value.length != 6 && value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}

Color _alpha(Color color, double opacity) =>
    color.withAlpha((opacity.clamp(0, 1) * 255).round());

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
