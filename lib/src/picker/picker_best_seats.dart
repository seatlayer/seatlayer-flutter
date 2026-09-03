import 'package:flutter/material.dart';

import 'picker_internal.dart';
import 'picker_tokens.g.dart';
import 'picker_models.dart';
import 'seat_layer_picker_controller.dart';
import 'seat_layer_picker_scope.dart';
import 'seat_layer_picker_theme.dart';
import 'picker_a11y.dart';

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

    // One card, one track, read top to bottom: of what, where, then how many
    // and go. The ticket type and the zone each take a full line because
    // their values are names, which are the long ones; the stepper is narrow
    // and fixed, so it shares the last line with the action it feeds.
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Color.alphaBlend(
            pickerAlpha(theme.accent, .34),
            theme.divider,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(pickerAlpha(theme.accent, .05), theme.surface),
            Color.alphaBlend(pickerAlpha(theme.accent, .11), theme.surface),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompactSelect(
            label: strings.ticketType,
            placeholder: strings.anyTicketType,
            value: _categoryKey,
            entries: <(String, String)>[
              for (final category in categories) (category.key, category.label),
            ],
            enabled: enabled,
            onChanged: (value) => setState(() => _categoryKey = value),
          ),
          // A venue with no zones has nothing to choose between, so the row is
          // absent rather than offering a select whose only answer is
          // "anywhere".
          if (zones.isNotEmpty) ...[
            const SizedBox(height: 6),
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
          const SizedBox(height: 6),
          Row(
            children: [
              _Stepper(
                quantity: quantity,
                maximum: maximum,
                enabled: enabled,
                onChanged: (value) => setState(() => _quantity = value),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: theme.onAccent,
                    disabledBackgroundColor: theme.surface,
                    disabledForegroundColor: theme.mutedText,
                    minimumSize: Size(0, theme.layout.selectorHeight),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        SeatLayerRadiusTokens.control,
                      ),
                    ),
                    textStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  onPressed:
                      enabled ? () => _submit(controller, quantity) : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_submitting)
                        SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.onAccent,
                          ),
                        )
                      else
                        // The one flourish on the card, and the same mark the
                        // collapsed bar offers the finder under.
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1,
                            color: theme.onAccent,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _submitting
                              ? strings.findingBestSeats
                              : strings.findBestSeats(quantity),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
      final before = controller.state.selection.map((s) => s.label).toSet();
      await controller.bestAvailable(
        quantity: quantity,
        zoneId: _zoneId,
        categoryKey: _categoryKey,
      );
      widget.onFound?.call(quantity);
      // The web lands the camera on the seats it found; the bridge command
      // only makes the hold. Until the runtime carries the arrival over the
      // bridge, frame the section the new seats are in, so the buyer is not
      // left hunting for a cart line on a stand they were not looking at.
      final landing = pickerBestSeatsSectionId(controller.state, before);
      if (landing != null &&
          controller.mapController.bundleInfo
                  ?.supportsCommand('picker.focusSection') ==
              true) {
        await controller.focusSection(landing);
      }
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
    return Semantics(
      label: label,
      child: Container(
        height: seatLayerScaledExtent(
          context,
          theme.layout.bestSeatsSelectHeight,
          max: SeatLayerTypeScaleTokens.sheet,
        ),
        padding: const EdgeInsetsDirectional.only(start: 9, end: 10),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.control),
          border: Border.all(color: theme.divider),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            isExpanded: true,
            isDense: true,
            focusColor: const Color(0x00000000),
            // The widget's own chevron, sized down to the mark the web draws
            // rather than Material's full-size arrow: the control is only
            // thirty-four points tall, and the stock icon owns a third of it.
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: theme.mutedText,
            ),
            dropdownColor: theme.surface,
            style: TextStyle(
              color: theme.text,
              fontSize: 12.5,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
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

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Container(
      // Fixed, so the action beside it keeps one width whether the buyer is
      // asking for two seats or twelve.
      width: theme.layout.bestSeatsStepperWidth,
      height: seatLayerScaledExtent(
        context,
        theme.layout.selectorHeight,
        max: SeatLayerTypeScaleTokens.sheet,
      ),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.control),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepIcon(
            glyph: '−',
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
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                  fontFamily: theme.fontFamily,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ),
          ),
          _StepIcon(
            glyph: '+',
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

/// One end of the stepper: a filled square the thumb can find without
/// looking, over a target that reaches past the control's own edge.
class _StepIcon extends StatelessWidget {
  const _StepIcon({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
  });

  final String glyph;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Edge length of the drawn key.
  static const double size = 34;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final disabled = onPressed == null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: !disabled,
        label: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pickerAlpha(theme.divider, .35),
              borderRadius: BorderRadius.circular(7),
            ),
            child: ExcludeSemantics(
              child: Text(
                glyph,
                style: TextStyle(
                  color:
                      disabled ? pickerAlpha(theme.mutedText, .4) : theme.text,
                  fontSize: 14,
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The section holding the seats a best-available pick just added, or null.
///
/// Seats name their section by label, sections carry the id the focus
/// command needs; the first new seat whose label matches a section decides.
String? pickerBestSeatsSectionId(
  SeatLayerPickerState state,
  Set<String> previousLabels,
) {
  final snapshot = state.snapshot;
  if (snapshot == null) return null;
  for (final seat in state.selection) {
    if (previousLabels.contains(seat.label)) continue;
    final label = seat.sectionLabel;
    if (label == null) continue;
    for (final section in snapshot.sections) {
      if (section.label == label || section.displayLabel == label) {
        return section.id;
      }
    }
  }
  return null;
}

