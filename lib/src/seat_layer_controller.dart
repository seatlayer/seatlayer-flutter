import 'dart:async';

import 'package:meta/meta.dart';

import 'bridge/bridge_client.dart';
import 'bridge/bridge_profile.dart';
import 'bridge/bridge_protocol.dart';
import 'bridge/envelope.dart';
import 'open_enums.dart';
import 'payloads.dart';
import 'seat_layer_configuration.dart';
import 'seat_layer_error.dart';

/// The public, `Future`- and `Stream`-based API for a seat map.
///
/// Semantically identical to the iOS `SeatLayerView`: the same command set with
/// idiomatic Dart shapes, and iOS's delegate callbacks re-expressed as broadcast
/// [Stream]s. Hold one of these, hand it to a [SeatLayerView], and drive the
/// chart through it.
///
/// A failed command completes its returned `Future` WITH a [SeatLayerError] (it
/// does not merely surface on [onError]) — the iOS SDK's key fix. A
/// [bestAvailable] conflict throws `sold_out` / `not_enough_together` from the
/// awaited call.
class SeatLayerController {
  SeatLayerController();

  BridgeClient? _client;
  SeatLayerConfiguration? _configuration;
  SeatLayerBridgeProfile _profile = SeatLayerBridgeProfile.chart;

  ReadyInfo? _readyInfo;
  BundleInfo? _bundleInfo;
  int? _protocolRevision;

  Completer<ReadyInfo>? _readyCompleter;
  Timer? _handshakeTimer;
  bool _hasFinished = false;
  bool _disposed = false;

  final _onReady = StreamController<ReadyInfo>.broadcast();
  final _onSelectionChanged = StreamController<List<SelectedSeat>>.broadcast();
  final _onSelectionValidityChanged =
      StreamController<SelectionValidity>.broadcast();
  final _onSelectionValid = StreamController<List<SelectedSeat>>.broadcast();
  final _onSelectionInvalid = StreamController<SelectionValidity>.broadcast();
  final _onSelectionLimit = StreamController<int>.broadcast();
  final _onBuyerAccessExpired =
      StreamController<BuyerAccessExpiredEvent>.broadcast();
  final _onBuyerAccessUnavailable =
      StreamController<BuyerAccessUnavailableEvent>.broadcast();
  final _onSelectedObjectsUnavailable =
      StreamController<SelectedObjectUnavailableEvent>.broadcast();
  final _onHold = StreamController<HoldResult>.broadcast();
  final _onHoldRestored = StreamController<HoldResult>.broadcast();
  final _onHoldExpired = StreamController<void>.broadcast();
  final _onCheckout = StreamController<Object?>.broadcast();
  final _onError = StreamController<SeatLayerError>.broadcast();
  final _onHint = StreamController<String?>.broadcast();
  final _onGAClick = StreamController<GAArea>.broadcast();
  final _onSeatHover = StreamController<SeatHoverDetails?>.broadcast();
  final _onDeckTap = StreamController<String>.broadcast();
  final _onUnknownEvent = StreamController<UnknownEvent>.broadcast();
  final _onBridgeEvent = StreamController<EventSignal>.broadcast();

  // MARK: - State

  /// What `sys.ready` reported. Non-null once the chart exists.
  ReadyInfo? get readyInfo => _readyInfo;

  /// What the bundle advertised in `hello`. Populated before [readyInfo].
  BundleInfo? get bundleInfo => _bundleInfo;

  /// The negotiated protocol revision, or `null` before a successful handshake.
  int? get protocolRevision => _protocolRevision;

  bool get isReady => _readyInfo != null;

  // MARK: - Event streams

  /// The handshake completed and the chart rendered. Check `mode` —
  /// [EventMode.test] books no real inventory and must be badged.
  Stream<ReadyInfo> get onReady => _onReady.stream;

  /// The buyer's selection changed. Carries the FULL current selection.
  Stream<List<SelectedSeat>> get onSelectionChanged =>
      _onSelectionChanged.stream;

  Stream<SelectionValidity> get onSelectionValidityChanged =>
      _onSelectionValidityChanged.stream;
  Stream<List<SelectedSeat>> get onSelectionValid => _onSelectionValid.stream;
  Stream<SelectionValidity> get onSelectionInvalid =>
      _onSelectionInvalid.stream;
  Stream<int> get onSelectionLimit => _onSelectionLimit.stream;
  Stream<BuyerAccessExpiredEvent> get onBuyerAccessExpired =>
      _onBuyerAccessExpired.stream;
  Stream<BuyerAccessUnavailableEvent> get onBuyerAccessUnavailable =>
      _onBuyerAccessUnavailable.stream;
  Stream<SelectedObjectUnavailableEvent> get onSelectedObjectsUnavailable =>
      _onSelectedObjectsUnavailable.stream;

  /// A hold was created or updated.
  Stream<HoldResult> get onHold => _onHold.stream;

  /// A previously open hold was restored (app relaunch, reconnect).
  Stream<HoldResult> get onHoldRestored => _onHoldRestored.stream;

  /// The open hold expired server-side. The seats are gone; return to selection.
  Stream<void> get onHoldExpired => _onHoldExpired.stream;

  /// A checkout signal from a future bundle. The current v1 mobile bridge does
  /// not advertise this event; drive checkout from your own UI after a hold.
  Stream<Object?> get onCheckout => _onCheckout.stream;

  /// Something failed out of band. A failed COMMAND does not appear here — it
  /// throws from its `Future` instead.
  Stream<SeatLayerError> get onError => _onError.stream;

  /// A transient buyer-facing hint, or `null` to clear it.
  Stream<String?> get onHint => _onHint.stream;

  /// The buyer tapped a general-admission area — prompt for a quantity, then
  /// call [holdGA].
  Stream<GAArea> get onGAClick => _onGAClick.stream;

  /// The buyer hovered/long-pressed a seat, or `null` on hover-out. Only fires
  /// when the app draws its own seat popover.
  Stream<SeatHoverDetails?> get onSeatHover => _onSeatHover.stream;

  /// The buyer tapped a floor in a multi-floor deck.
  Stream<String> get onDeckTap => _onDeckTap.stream;

  /// An event this build does not model — a bundle newer than the app.
  Stream<UnknownEvent> get onUnknownEvent => _onUnknownEvent.stream;

  /// Every accepted bridge event, before raw-chart routing.
  ///
  /// Used by the high-level picker adapter so protocol-v2 events do not have to
  /// masquerade as unknown raw-chart events.
  @internal
  Stream<EventSignal> get onBridgeEvent => _onBridgeEvent.stream;

  // MARK: - Handshake orchestration (driven by SeatLayerView)

  /// Attach a channel, arm the handshake, and complete when `sys.ready` arrives.
  /// Called by [SeatLayerView]; not part of the app-facing API.
  @internal
  Future<ReadyInfo> beginHandshake(
    BridgeChannel channel,
    SeatLayerConfiguration configuration, {
    SeatLayerBridgeProfile profile = SeatLayerBridgeProfile.chart,
  }) {
    if (_disposed) {
      return Future<ReadyInfo>.error(const SeatLayerError.destroyed());
    }
    _configuration = configuration;
    _profile = profile;
    _hasFinished = false;
    _readyInfo = null;
    _bundleInfo = null;
    _protocolRevision = null;

    // A fresh client so a reload never inherits stale correlations or event
    // sequence watermarks from a previous chart.
    _client?.close();
    final client = BridgeClient(
      channel: channel,
      timeout: configuration.commandTimeout,
    );
    client.onSignal(_handleSignal);
    _client = client;

    final completer = Completer<ReadyInfo>();
    _readyCompleter = completer;

    _handshakeTimer?.cancel();
    _handshakeTimer = Timer(configuration.handshakeTimeout, () {
      _finishHandshake(
        SeatLayerError.handshakeTimeout(configuration.handshakeTimeout),
      );
    });

    return completer.future;
  }

  /// Feed one raw web→native frame (the `JavaScriptChannel` string) to the
  /// client. Called by [SeatLayerView].
  @internal
  void ingestRaw(Object? message) {
    final envelope = Envelope.decode(message);
    if (envelope == null) return; // not ours, or malformed — dropped.
    _client?.ingest(envelope);
  }

  /// Report a page-load / navigation failure as a transport error. Called by
  /// [SeatLayerView].
  @internal
  void failWithTransport(String detail) {
    _finishHandshake(SeatLayerError.transport(detail));
  }

  void _handleSignal(BridgeSignal signal) {
    switch (signal) {
      case HelloSignal(:final payload):
        _handleHello(payload);
      case EventSignal(:final name, :final payload):
        _onBridgeEvent.add(signal);
        _handleEvent(name, payload);
      case UnhandledSignal(:final envelope):
        _onUnknownEvent.add(
          UnknownEvent(name: envelope.type, payload: envelope.payload),
        );
    }
  }

  void _handleHello(Object? payload) {
    final info = BundleInfo.fromJson(payload);
    _bundleInfo = info;

    // Negotiate natively BEFORE replying. The web side checks too, but failing
    // here means the app never asks for a chart it could not drive, and the
    // caller gets a typed error instead of a blank view.
    final profile = _profile;
    final result = negotiate(
      native: profile.protocolRange,
      web: info.protocolRange,
    );
    switch (result) {
      case NegotiationIncompatible(:final reason):
        _finishHandshake(
          SeatLayerError.incompatible(
            native: profile.protocolRange,
            web: info.protocolRange,
            reason: reason,
          ),
        );
      case NegotiationAgreed():
        final config = _configuration;
        if (config != null) {
          final missing = profile.requiredCapabilities
              .where((capability) => !info.supportsCapability(capability))
              .toList(growable: false);
          if (missing.isNotEmpty) {
            _finishHandshake(
              SeatLayerError.incompatible(
                native: profile.protocolRange,
                web: info.protocolRange,
                reason:
                    'the bundle is missing required picker capabilities: ${missing.join(', ')}',
              ),
            );
            return;
          }
          if (config.usesPrivateAccess &&
              !info.supportsCapability('native-access-provider')) {
            _finishHandshake(
              SeatLayerError.incompatible(
                native: profile.protocolRange,
                web: info.protocolRange,
                reason: 'the bundle does not support private buyer access',
              ),
            );
            return;
          }
          if (config.usesSelectionPolicy &&
              (!info.supportsCapability('selection-controls') ||
                  !info.supportsCapability('selection-validity'))) {
            _finishHandshake(
              SeatLayerError.incompatible(
                native: profile.protocolRange,
                web: info.protocolRange,
                reason:
                    'the bundle does not support the configured selection policy',
              ),
            );
            return;
          }
          unawaited(
            _client?.sendInit(profile.initPayload(config)) ?? Future.value(),
          );
        }
    }
  }

  void _handleEvent(String name, Object? payload) {
    switch (name) {
      case 'sys.ready':
        _finishHandshake(ReadyInfo.fromJson(payload));
      case 'sys.incompatible':
        final web = ProtocolRange.from(jGetLocal(payload, 'web')) ??
            ProtocolRange.native;
        final reason = jStrLocal(jGetLocal(payload, 'message')) ??
            jStrLocal(jGetLocal(payload, 'code')) ??
            "the seat map bundle rejected this app's protocol range";
        _finishHandshake(
          SeatLayerError.incompatible(
            native: _profile.protocolRange,
            web: web,
            reason: reason,
          ),
        );
      case 'sys.error':
        _finishHandshake(
          SeatLayerError.bridge(BridgeErrorPayload.fromJson(payload)),
        );
      case 'selection.changed':
        _onSelectionChanged.add(
          _decodeList(jGetLocal(payload, 'seats'), SelectedSeat.fromJson),
        );
      case 'selection.validity.changed':
        final validity = SelectionValidity.fromJson(
          jGetLocal(payload, 'validity'),
        );
        if (validity != null) _onSelectionValidityChanged.add(validity);
      case 'selection.valid':
        _onSelectionValid.add(
          _decodeList(jGetLocal(payload, 'seats'), SelectedSeat.fromJson),
        );
      case 'selection.invalid':
        final validity = SelectionValidity.fromJson(
          jGetLocal(payload, 'validity'),
        );
        if (validity != null) _onSelectionInvalid.add(validity);
      case 'selection.limit':
        final maximum = jIntLocal(jGetLocal(payload, 'maxSelection'));
        if (maximum != null) _onSelectionLimit.add(maximum);
      case 'access.token.request':
        unawaited(_provideBuyerAccessToken(payload));
      case 'access.expired':
        final event = BuyerAccessExpiredEvent.fromJson(payload);
        if (event != null) _onBuyerAccessExpired.add(event);
      case 'access.unavailable':
        final event = BuyerAccessUnavailableEvent.fromJson(payload);
        if (event != null) _onBuyerAccessUnavailable.add(event);
      case 'selection.unavailable':
        final event = SelectedObjectUnavailableEvent.fromJson(payload);
        if (event != null) _onSelectedObjectsUnavailable.add(event);
      case 'hold.changed':
        final hold = HoldResult.fromJson(jGetLocal(payload, 'hold'));
        if (hold != null) _onHold.add(hold);
      case 'hold.restored':
        final hold = HoldResult.fromJson(jGetLocal(payload, 'hold'));
        if (hold != null) _onHoldRestored.add(hold);
      case 'hold.expired':
        _onHoldExpired.add(null);
      case 'ga.click':
        final area = GAArea.fromJson(jGetLocal(payload, 'area'));
        if (area != null) _onGAClick.add(area);
      case 'hint':
        _onHint.add(jStrLocal(jGetLocal(payload, 'message')));
      case 'error':
        _onError.add(
          SeatLayerError.bridge(BridgeErrorPayload.fromJson(payload)),
        );
      case 'seat.hover':
        final raw = jGetLocal(payload, 'details');
        _onSeatHover.add(raw == null ? null : SeatHoverDetails.fromJson(raw));
      case 'deck.tap':
        final floorId = jStrLocal(jGetLocal(payload, 'floorId'));
        if (floorId != null) _onDeckTap.add(floorId);
      case 'checkout':
        _onCheckout.add(payload);
      default:
        _onUnknownEvent.add(UnknownEvent(name: name, payload: payload));
    }
  }

  Future<void> _provideBuyerAccessToken(Object? payload) async {
    final requestId = jStrLocal(jGetLocal(payload, 'requestId'));
    if (requestId == null) return;
    final client = _client;
    if (client == null) return;
    final rawReason = jStrLocal(jGetLocal(payload, 'reason')) ?? 'initial';
    final provider = _configuration?.buyerAccessTokenProvider;

    if (provider == null) {
      try {
        await client.command(
          'access.token.unavailable',
          payload: {'requestId': requestId},
        );
      } catch (_) {}
      return;
    }

    BuyerAccessToken token;
    try {
      token = await provider(
        BuyerAccessRequestContext(
          reason: BuyerAccessRefreshReason.fromRaw(rawReason),
        ),
      );
      if (token.token.trim().isEmpty || token.expiresAt?.isFinite == false) {
        throw StateError('invalid buyer access token');
      }
    } catch (_) {
      // Provider failures are sanitized; errors and bearers never become events.
      try {
        await client.command(
          'access.token.unavailable',
          payload: {'requestId': requestId},
        );
      } catch (_) {}
      return;
    }

    try {
      await client.command(
        'access.token.provide',
        payload: {
          'requestId': requestId,
          'token': token.token,
          if (token.expiresAt != null) 'expiresAt': token.expiresAt,
        },
      );
    } catch (_) {
      // The request may have timed out or the view may have reloaded.
    }
  }

  void _finishHandshake(Object outcome) {
    if (_disposed) return;
    if (_hasFinished) {
      // A failure AFTER ready (a late sys.error / error) is a stream event, not
      // a load result.
      if (outcome is SeatLayerError) _onError.add(outcome);
      return;
    }
    _hasFinished = true;
    _handshakeTimer?.cancel();
    _handshakeTimer = null;

    final completer = _readyCompleter;
    _readyCompleter = null;

    if (outcome is ReadyInfo) {
      _readyInfo = outcome;
      _protocolRevision = outcome.protocolRevision;
      _onReady.add(outcome);
      completer?.complete(outcome);
    } else if (outcome is SeatLayerError) {
      _onError.add(outcome);
      completer?.completeError(outcome);
    }
  }

  // MARK: - Commands

  Future<Object?> _run(String command, [Object? payload]) {
    final client = _client;
    if (client == null) {
      return Future.error(const SeatLayerError.transport('no chart loaded'));
    }
    return client.command(command, payload: payload);
  }

  /// Send a correlated semantic bridge command for the high-level picker.
  @internal
  Future<Object?> runBridgeCommand(String command, [Object? payload]) =>
      _run(command, payload);

  /// Detach the current page/transport without disposing this caller-owned
  /// controller. A subsequent WebView load may attach a fresh bridge.
  @internal
  void detachTransport() {
    _handshakeTimer?.cancel();
    _handshakeTimer = null;
    final pending = _readyCompleter;
    _readyCompleter = null;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(const SeatLayerError.destroyed());
    }
    _client?.close();
    _client = null;
    _readyInfo = null;
    _bundleInfo = null;
    _protocolRevision = null;
    _hasFinished = false;
  }

  /// Hold the current selection.
  Future<HoldResult?> hold({int? ttlMs}) async {
    final result = await _run('hold', _compact({'ttlMs': ttlMs}));
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Reattach to an open hold (app relaunch, checkout resume).
  Future<HoldResult?> resumeHold(String holdId) async {
    final result = await _run('resumeHold', {'holdId': holdId});
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Push the hold's expiry out.
  Future<HoldResult?> extendHold({int? ttlMs}) async {
    final result = await _run('extendHold', _compact({'ttlMs': ttlMs}));
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Release the whole hold.
  Future<void> release() => _run('release');

  /// Release specific seats from the hold, keeping the rest.
  Future<bool> releaseLabels(List<String> labels) async {
    final result = await _run('releaseLabels', {'labels': labels});
    return jBoolLocal(jGetLocal(result, 'released')) ?? false;
  }

  /// Ask the server for the best `qty` seats and hold them. A conflict throws
  /// `sold_out` / `not_enough_together` from this call.
  Future<BestAvailableResult?> bestAvailable(
    int qty, {
    String? categoryKey,
  }) async {
    final result = await _run(
      'bestAvailable',
      _compact({'qty': qty, 'categoryKey': categoryKey}),
    );
    return BestAvailableResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Hold general-admission capacity.
  ///
  /// [setTier] mirrors the web/iOS "doubly-optional" tier: leave [setTier]
  /// `false` to not touch the tier; set it `true` with [tierId] `null` to send
  /// an explicit `null` (revert to the default tier), or with a value to select.
  Future<HoldResult?> holdGA(
    String areaId,
    int qty, {
    bool setTier = false,
    String? tierId,
    int? ttlMs,
  }) async {
    final payload = <String, Object?>{'areaId': areaId, 'qty': qty};
    if (setTier) payload['tierId'] = tierId;
    if (ttlMs != null) payload['ttlMs'] = ttlMs;
    final result = await _run('holdGA', payload);
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// Choose a ticket tier for one seat. `null` reverts to the default tier.
  Future<void> setSeatTier(String seatId, String? tierId) =>
      _run('setSeatTier', {'seatId': seatId, 'tierId': tierId});

  /// The current selection.
  Future<List<SelectedSeat>> getSelection() async {
    final result = await _run('getSelection');
    return _decodeList(jGetLocal(result, 'seats'), SelectedSeat.fromJson);
  }

  Future<List<SelectedSeat>> selectObjects(List<String> objects) async {
    final result = await _run('selectObjects', {'objects': objects});
    return _decodeList(jGetLocal(result, 'seats'), SelectedSeat.fromJson);
  }

  Future<void> deselectObjects(List<String> objects) =>
      _run('deselectObjects', {'objects': objects});

  Future<void> clearSelection() => _run('clearSelection');

  Future<List<SelectedSeat>> selectCategories(List<String> categoryKeys) async {
    final result = await _run('selectCategories', {
      'categoryKeys': categoryKeys,
    });
    return _decodeList(jGetLocal(result, 'seats'), SelectedSeat.fromJson);
  }

  Future<void> deselectCategories(List<String> categoryKeys) =>
      _run('deselectCategories', {'categoryKeys': categoryKeys});

  Future<void> setSelectableObjects(List<String>? objects) =>
      _run('setSelectableObjects', {'objects': objects});

  Future<void> setMaxSelection(int maximum) {
    if (maximum < 1) return Future.error(ArgumentError.value(maximum));
    return _run('setMaxSelection', {'maxSelection': maximum});
  }

  Future<SelectionValidity?> getSelectionValidity() async {
    final result = await _run('getSelectionValidity');
    return SelectionValidity.fromJson(jGetLocal(result, 'validity'));
  }

  Future<bool> refreshAccess() async {
    final result = await _run('refreshAccess');
    return jBoolLocal(jGetLocal(result, 'refreshed')) ?? false;
  }

  /// The open hold, if any.
  Future<HoldResult?> getCurrentHold() async {
    final result = await _run('getCurrentHold');
    return HoldResult.fromJson(jGetLocal(result, 'hold'));
  }

  /// General-admission areas and their live availability.
  Future<List<GAArea>> getGAAreas() async {
    final result = await _run('getGAAreas');
    return _decodeList(jGetLocal(result, 'areas'), GAArea.fromJson);
  }

  /// Floors of a multi-floor venue. Empty for a single-floor chart.
  Future<List<FloorInfo>> getFloors() async {
    final result = await _run('getFloors');
    return _decodeList(jGetLocal(result, 'floors'), FloorInfo.fromJson);
  }

  Future<void> setFloor(String floorId) =>
      _run('setFloor', {'floorId': floorId});

  Future<void> setColorblindSafe(bool on) =>
      _run('setColorblindSafe', {'on': on});

  Future<void> setViewMode(SeatLayerViewMode mode) =>
      _run('setViewMode', {'mode': mode.raw});

  Future<SeatLayerViewMode> getViewMode() async {
    final result = await _run('getViewMode');
    return SeatLayerViewMode.fromRaw(
      jStrLocal(jGetLocal(result, 'mode')) ?? 'flat',
    );
  }

  Future<void> zoomIn() => _run('zoomIn');
  Future<void> zoomOut() => _run('zoomOut');
  Future<void> zoomToFit() => _run('zoomToFit');

  /// Tear the chart down. Subsequent commands fail with `destroyed`.
  Future<void> destroy() async {
    try {
      await _run('destroy');
    } catch (_) {
      // Best-effort: the chart may already be gone.
    }
    detachTransport();
  }

  /// Release all resources. Call from your `State.dispose`.
  void dispose() {
    if (_disposed) return;
    detachTransport();
    _disposed = true;
    _onReady.close();
    _onSelectionChanged.close();
    _onSelectionValidityChanged.close();
    _onSelectionValid.close();
    _onSelectionInvalid.close();
    _onSelectionLimit.close();
    _onBuyerAccessExpired.close();
    _onBuyerAccessUnavailable.close();
    _onSelectedObjectsUnavailable.close();
    _onHold.close();
    _onHoldRestored.close();
    _onHoldExpired.close();
    _onCheckout.close();
    _onError.close();
    _onHint.close();
    _onGAClick.close();
    _onSeatHover.close();
    _onDeckTap.close();
    _onUnknownEvent.close();
    _onBridgeEvent.close();
  }

  List<T> _decodeList<T>(Object? value, T? Function(Object?) decode) {
    if (value is! List) return <T>[];
    final out = <T>[];
    for (final item in value) {
      final decoded = decode(item);
      if (decoded != null) out.add(decoded);
    }
    return out;
  }

  /// Drop keys whose value is null, mirroring how the web side omits absent
  /// optionals rather than sending explicit `null`.
  Map<String, Object?> _compact(Map<String, Object?> pairs) {
    final out = <String, Object?>{};
    pairs.forEach((key, value) {
      if (value != null) out[key] = value;
    });
    return out;
  }
}

// Small local JSON reads, kept private so the controller does not leak the raw
// JSON helper surface into the public library.
Object? jGetLocal(Object? v, String key) =>
    v is Map ? (v.cast<String, Object?>())[key] : null;
String? jStrLocal(Object? v) => v is String ? v : null;
bool? jBoolLocal(Object? v) => v is bool ? v : null;
int? jIntLocal(Object? v) => v is int ? v : (v is num ? v.toInt() : null);
