import 'dart:async';

import '../seat_layer_error.dart';
import 'bridge_protocol.dart';
import 'envelope.dart';

/// The native→web send path. Implemented by [SeatLayerView]'s State over
/// `WebViewController.runJavaScript`; tests substitute a double, which is what
/// keeps the whole correlation/timeout layer testable without a WebView.
abstract interface class BridgeChannel {
  /// Push one envelope to the web side. Should never throw.
  Future<void> send(Envelope envelope);
}

/// What the client hands back to its owner.
sealed class BridgeSignal {
  const BridgeSignal();
}

/// The bundle opened the handshake. Payload is the raw `hello`.
final class HelloSignal extends BridgeSignal {
  const HelloSignal(this.payload);
  final Object? payload;
}

/// An `evt` that survived stale-sequence filtering.
final class EventSignal extends BridgeSignal {
  const EventSignal({
    required this.name,
    required this.payload,
    required this.sequence,
  });
  final String name;
  final Object? payload;
  final int sequence;
}

/// An inbound frame this build could not act on. Surfaced rather than swallowed
/// so integrators can see a bundle running ahead of the app.
final class UnhandledSignal extends BridgeSignal {
  const UnhandledSignal(this.envelope);
  final Envelope envelope;
}

class _Pending {
  _Pending({
    required this.command,
    required this.order,
    required this.completer,
    required this.timer,
  });

  final String command;

  /// Issue order — the pending command with the highest order is the most
  /// recently sent, which is the one an out-of-band `error` belongs to.
  final int order;
  final Completer<Object?> completer;
  final Timer timer;
}

/// Correlation, timeout and event ordering for the bridge.
///
/// Invariants it enforces on the native side:
///   - one `cmd` resolves exactly once, by `id`;
///   - a command with no reply fails with `sl_timeout` after [timeout];
///   - a LATE reply for an already-timed-out id is dropped, never delivered;
///   - an `evt` whose `n` is not greater than the highest `n` already applied
///     FOR THAT `t` is dropped as stale.
class BridgeClient {
  BridgeClient({
    BridgeChannel? channel,
    this.timeout = defaultTimeout,
    Set<String>? failableCommands,
    Set<String>? commandErrorEvents,
  })  : _channel = channel,
        failableCommands = failableCommands ?? defaultFailableCommands,
        commandErrorEvents = commandErrorEvents ?? defaultCommandErrorEvents;

  /// Default native-side command deadline.
  static const Duration defaultTimeout = Duration(seconds: 15);

  /// Commands whose failure the web bundle reports OUT OF BAND.
  ///
  /// The bundle's `SeatingChart` catches an API error inside these mutating
  /// commands, hands it to `onError`, and resolves the command with a null
  /// hold. On the wire that is an uncorrelated `error` event immediately
  /// followed by a `res` carrying `{ hold: null }` — so a naive client returns
  /// `null` from `await` and the real failure only shows up on the stream. For
  /// exactly these commands, an `error` event that lands while one is in flight
  /// is that command's failure, and must throw from its call. Getters and view
  /// commands are deliberately absent: an error during one of those is genuinely
  /// out of band and belongs on the stream.
  static const Set<String> defaultFailableCommands = {
    'hold', 'holdGA', 'bestAvailable', 'resumeHold', 'extendHold',
    'release', 'releaseLabels',
  };

  /// Event types the bundle uses to report a command failure out of band.
  static const Set<String> defaultCommandErrorEvents = {'error'};

  final Duration timeout;
  final Set<String> failableCommands;
  final Set<String> commandErrorEvents;

  BridgeChannel? _channel;
  final Map<String, _Pending> _pending = {};

  /// Highest applied sequence per event type — the stale-event filter.
  final Map<String, int> _lastSequence = {};
  int _nextId = 0;
  bool _closed = false;
  void Function(BridgeSignal)? _signalHandler;

  void attach(BridgeChannel channel) => _channel = channel;

  void onSignal(void Function(BridgeSignal) handler) => _signalHandler = handler;

  // MARK: - Outbound

  /// Send a `cmd` and await its single `res`/`err`.
  Future<Object?> command(String name, {Object? payload}) {
    if (_closed) return Future.error(const SeatLayerError.destroyed());
    final channel = _channel;
    if (channel == null) {
      return Future.error(const SeatLayerError.transport('no channel attached'));
    }

    _nextId += 1;
    final id = 'n$_nextId';
    final order = _nextId;
    final completer = Completer<Object?>();

    // Register the pending entry BEFORE sending: a synchronous reply must never
    // arrive to an empty pending table.
    final timer = Timer(timeout, () => _expire(id));
    _pending[id] = _Pending(
      command: name,
      order: order,
      completer: completer,
      timer: timer,
    );
    // Fire-and-forget; a throw inside send must not escape here.
    unawaited(
      channel
          .send(Envelope(kind: EnvelopeKind.cmd, type: name, id: id, payload: payload))
          .catchError((_) {}),
    );
    return completer.future;
  }

  /// Send the handshake reply. Fire-and-forget: the bundle answers with the
  /// `sys.ready` / `sys.incompatible` event, not with a correlated reply.
  Future<void> sendInit(Object? payload) async {
    if (_closed) return;
    final channel = _channel;
    if (channel == null) return;
    await channel.send(
      Envelope(kind: EnvelopeKind.init, type: 'init', payload: payload),
    );
  }

  void _expire(String id) {
    final entry = _pending.remove(id);
    if (entry == null) return;
    entry.timer.cancel();
    entry.completer.completeError(SeatLayerError.timeout(entry.command, timeout));
  }

  // MARK: - Inbound

  /// Route one inbound frame. Never throws: a malformed or unfamiliar frame is
  /// dropped, because a decode failure must not take the seat map down.
  ///
  /// The kind singletons are const, so identity comparison suffices. `init` and
  /// `cmd` are native→web kinds — an inbound one is noise; an `unknown` kind is
  /// a bundle newer than this build. Both surface as [UnhandledSignal].
  void ingest(Envelope envelope) {
    if (_closed) return;

    final kind = envelope.kind;
    if (kind == EnvelopeKind.res) {
      _resolveSuccess(envelope);
    } else if (kind == EnvelopeKind.err) {
      _resolveFailure(envelope);
    } else if (kind == EnvelopeKind.evt) {
      _ingestEvent(envelope);
    } else if (kind == EnvelopeKind.hello) {
      _signalHandler?.call(HelloSignal(envelope.payload));
    } else {
      _signalHandler?.call(UnhandledSignal(envelope));
    }
  }

  void _ingestEvent(Envelope envelope) {
    // A command whose failure the bundle reports out of band: the `error` event
    // lands HERE, synchronously, immediately before the command's own
    // `res { hold: null }`. Turn it back into that command's failure so `await`
    // throws instead of returning null — and do it before the trailing `res`,
    // which then finds no pending entry and is dropped. Because the command is
    // failed here and NOT forwarded as an event, the stream does not also see
    // it: one failure, one report.
    if (commandErrorEvents.contains(envelope.type)) {
      final entry = _mostRecentFailablePending();
      if (entry != null) {
        _pending.remove(entry.key);
        entry.value.timer.cancel();
        entry.value.completer.completeError(
          SeatLayerError.bridge(BridgeErrorPayload.fromJson(envelope.payload)),
        );
        return;
      }
    }

    // A missing `n` cannot be ordered; treat it as fresh rather than dropping a
    // real event. (Uses the smallest int as the "always fresh" sentinel.)
    final sequence = envelope.sequence ?? _minInt;
    final seen = _lastSequence[envelope.type];
    if (seen != null && sequence <= seen) {
      return; // stale — a newer snapshot of this event type already applied.
    }
    _lastSequence[envelope.type] = sequence;
    _signalHandler?.call(EventSignal(
      name: envelope.type,
      payload: envelope.payload,
      sequence: sequence,
    ));
  }

  static const int _minInt = -9223372036854775808;

  /// Deliver a reply to its correlation, if that correlation is still open. A
  /// reply for an unknown id — the late reply to a timed-out command, or a
  /// duplicate — is dropped.
  void _resolveSuccess(Envelope envelope) {
    final entry = _takePending(envelope.id);
    entry?.completer.complete(envelope.payload ?? const <String, Object?>{});
  }

  void _resolveFailure(Envelope envelope) {
    final entry = _takePending(envelope.id);
    entry?.completer.completeError(
      SeatLayerError.bridge(BridgeErrorPayload.fromJson(envelope.payload)),
    );
  }

  _Pending? _takePending(String? id) {
    if (id == null) return null;
    final entry = _pending.remove(id);
    entry?.timer.cancel();
    return entry;
  }

  /// The in-flight command an out-of-band `error` event should be attributed to:
  /// the most recently issued command from the failable set. `null` when no such
  /// command is open, in which case the error is genuinely out of band.
  MapEntry<String, _Pending>? _mostRecentFailablePending() {
    MapEntry<String, _Pending>? best;
    for (final entry in _pending.entries) {
      if (!failableCommands.contains(entry.value.command)) continue;
      if (best == null || entry.value.order > best.value.order) best = entry;
    }
    return best;
  }

  // MARK: - Teardown

  /// Fail every open command and stop accepting frames. Idempotent.
  void close([SeatLayerError error = const SeatLayerError.destroyed()]) {
    if (_closed) return;
    _closed = true;
    final open = List.of(_pending.values);
    _pending.clear();
    for (final entry in open) {
      entry.timer.cancel();
      if (!entry.completer.isCompleted) entry.completer.completeError(error);
    }
    _signalHandler = null;
    _channel = null;
  }

  // MARK: - Introspection (tests)

  int get openCommandCount => _pending.length;
  int? highestSequenceFor(String type) => _lastSequence[type];
  bool get isClosed => _closed;
}
