part of 'seat_layer_picker_controller.dart';

/// The standing area the buyer is being asked about, and the places they take.
///
/// A mixin for the same reason as [_PickerSeatAnswers]: the controller file is
/// at its line cap.
mixin _PickerStandingPlaces
    on ValueNotifier<SeatLayerPickerState>, PickerFailureLog {
  SeatLayerPickerOptions get _options;

  SeatLayerPickerController get _controller;

  Future<void> setGeneralAdmissionQuantity({
    required String areaId,
    required Map<String?, int> quantitiesByTier,
  }) {
    final requested = quantitiesByTier.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);
    if (requested.isEmpty ||
        quantitiesByTier.values.any((quantity) => quantity < 0)) {
      return Future<void>.error(
        ArgumentError.value(quantitiesByTier, 'quantitiesByTier'),
      );
    }
    final rejected = _controller._rejectReadOnly<void>('picker.holdGA');
    if (rejected != null) return rejected;
    return _controller._serialize(() async {
      value = value.withBusy(SeatLayerPickerBusyAction.creatingHold);
      try {
        for (final entry in requested) {
          final result = await _controller.mapController
              .runBridgeCommand('picker.holdGA', <String, Object?>{
            'areaId': areaId,
            'qty': entry.value,
            if (entry.key != null) 'tierId': entry.key,
            if (_options.holdTtl != null)
              'ttlMs': _options.holdTtl!.inMilliseconds,
          });
          _controller._applySnapshotFromResult(result);
          final revision = jInt(jGet(result, 'revision'));
          if (revision != null) await _controller._awaitRevision(revision);
          // The page's refusal: it took no places and gives no error.
          if (jBool(jGet(result, 'held')) == false) {
            throw const SeatLayerError.bridge(
              BridgeErrorPayload(
                code: 'hold_unavailable',
                message: 'The standing places could not be held.',
              ),
            );
          }
        }
        value = value.withGeneralAdmissionCandidate(null);
      } catch (error) {
        value = failed(error, 'picker.holdGA');
        rethrow;
      }
    });
  }

  void dismissGeneralAdmissionCandidate() {
    value = value.withGeneralAdmissionCandidate(null);
  }
}
