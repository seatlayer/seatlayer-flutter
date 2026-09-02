import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';

/// "Find me somewhere good", in one short track of controls.
///
/// The empty cart is the only place this form appears; once the buyer has
/// tickets the same feature is one icon in the sheet header. Two entry points
/// for one action is the duplication the web round removed, and it is the
/// reason there is no best-seats control on the peek bar either.
class SeatLayerBestSeatsForm extends StatefulWidget {
  /// Creates the compact best-available form.
  const SeatLayerBestSeatsForm({
    super.key,
    this.initialQuantity = 2,
    this.onFound,
  });

  /// How many seats the stepper starts at.
  final int initialQuantity;

  /// Called after a successful search, with the quantity that was requested.
  final ValueChanged<int>? onFound;

  @override
  State<SeatLayerBestSeatsForm> createState() => _SeatLayerBestSeatsFormState();
}

class _SeatLayerBestSeatsFormState extends State<SeatLayerBestSeatsForm> {
  int? _quantity;
  String? _zoneId;
  String? _categoryKey;
  bool _submitting = false;
  String? _sessionId;

  @override
  Widget build(BuildContext context) {
    final options = SeatLayerPickerScope.optionsOf(context);
    if (!options.enableBestAvailable) return const SizedBox.shrink();
    final controller = SeatLayerPickerScope.controllerOf(context);
    final snapshot = controller.state.snapshot;
    if (snapshot == null) return const SizedBox.shrink();

    _adoptSession(snapshot);
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final categories = snapshot.categories
        .where((category) => !category.notForSale)
        .toList(growable: false);
    final zones = snapshot.bestAvailableZones;
    final maximum = snapshot.maxSelection;
    final quantity = (_quantity ?? widget.initialQuantity).clamp(1, maximum);
    final enabled = controller.state.isReady &&
        !controller.state.isBusy &&
        !options.readOnly &&
        controller.state.canMutateInventory &&
        !_submitting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // One track, read top to bottom: how many, of what, where, then go.
        // The quantity and the ticket type share a line because the stepper is
        // narrow and fixed; the zone is a line of its own because its values
        // are venue names, which are the long ones.
        Row(
          children: [
            _Stepper(
              quantity: quantity,
              maximum: maximum,
              enabled: enabled,
              onChanged: (value) => setState(() => _quantity = value),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CompactSelect(
                label: strings.ticketType,
                placeholder: strings.anyTicketType,
                value: _categoryKey,
                entries: <(String, String)>[
                  for (final category in categories)
                    (category.key, category.label),
                ],
                enabled: enabled,
                onChanged: (value) => setState(() => _categoryKey = value),
              ),
            ),
          ],
        ),
        // A venue with no zones has nothing to choose between, so the row is
        // absent rather than offering a select whose only answer is "anywhere".
        if (zones.isNotEmpty) ...[
          const SizedBox(height: 8),
          _CompactSelect(
            label: strings.venueZone,
            placeholder: strings.anyVenueZone,
            value: _zoneId,
            entries: <(String, String)>[
              for (final zone in zones) (zone.id, zone.label),
            ],
            enabled: enabled,
            onChanged: (value) => setState(() => _zoneId = value),
          ),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: theme.accent,
            foregroundColor: theme.onAccent,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(theme.buttonRadius),
            ),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: theme.fontFamily,
            ),
          ),
          onPressed: enabled ? () => _submit(controller, quantity) : null,
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_rounded, size: 16),
          label: Text(
            strings.findBestSeats(quantity),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Start over when the runtime hands out a new session.
  void _adoptSession(SeatLayerPickerSnapshot snapshot) {
    if (_sessionId == snapshot.sessionId) return;
    _sessionId = snapshot.sessionId;
    _zoneId = _focusedZoneId(snapshot);
    final filter = snapshot.map.categoryFilter;
    _categoryKey = filter.length == 1 &&
            snapshot.categories.any((item) => item.key == filter.single)
        ? filter.single
        : null;
  }

  Future<void> _submit(
    SeatLayerPickerController controller,
    int quantity,
  ) async {
    setState(() => _submitting = true);
    try {
      await controller.bestAvailable(
        quantity: quantity,
        zoneId: _zoneId,
        categoryKey: _categoryKey,
      );
      widget.onFound?.call(quantity);
    } catch (_) {
      // The controller already published the typed failure for native UI.
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

/// The zone the map is already looking at, when it is one the finder accepts.
String? _focusedZoneId(SeatLayerPickerSnapshot snapshot) {
  final focusedSectionId = snapshot.map.focusedSectionId;
  if (focusedSectionId == null) return null;
  String? zoneId;
  for (final section in snapshot.sections) {
    if (section.id == focusedSectionId) {
      zoneId = section.zoneId;
      break;
    }
  }
  if (zoneId == null) return null;
  return snapshot.bestAvailableZones.any((zone) => zone.id == zoneId)
      ? zoneId
      : null;
}

class _CompactSelect extends StatelessWidget {
  const _CompactSelect({
    required this.label,
    required this.placeholder,
    required this.value,
    required this.entries,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String placeholder;
  final String? value;
  final List<(String, String)> entries;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final height = theme.layout.selectorHeight;
    return Semantics(
      label: label,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            pickerAlpha(theme.text, .03),
            theme.surface,
          ),
          borderRadius: BorderRadius.circular(theme.radius - 4),
          border: Border.all(color: theme.divider),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            isExpanded: true,
            isDense: true,
            focusColor: const Color(0x00000000),
            iconEnabledColor: theme.mutedText,
            dropdownColor: theme.surface,
            style: TextStyle(
              color: theme.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: theme.fontFamily,
            ),
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem<String?>(child: Text(placeholder)),
              for (final entry in entries)
                DropdownMenuItem<String?>(
                  value: entry.$1,
                  child: Text(entry.$2, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.maximum,
    required this.enabled,
    required this.onChanged,
  });

  final int quantity;
  final int maximum;
  final bool enabled;
  final ValueChanged<int> onChanged;

  /// The stepper's fixed width: two full-size targets and the count between.
  static const double width = 112;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Container(
      // Fixed, so the ticket-type select beside it keeps one width whether the
      // buyer is asking for two seats or twelve.
      width: width,
      height: theme.layout.selectorHeight,
      decoration: BoxDecoration(
        color: Color.alphaBlend(pickerAlpha(theme.text, .03), theme.surface),
        borderRadius: BorderRadius.circular(theme.radius - 4),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        children: [
          _StepIcon(
            icon: Icons.remove_rounded,
            tooltip: strings.fewerTickets,
            onPressed:
                enabled && quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              label: strings.ticketCount(quantity),
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.w800,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
          ),
          _StepIcon(
            icon: Icons.add_rounded,
            tooltip: strings.moreTickets,
            onPressed: enabled && quantity < maximum
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 44),
      color: theme.text,
      disabledColor: pickerAlpha(theme.mutedText, .4),
      icon: Icon(icon, size: 16),
    );
  }
}
