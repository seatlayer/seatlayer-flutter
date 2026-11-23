/// What a run page reports, typed. Every value the page may add to later is
/// open: an unknown kind or mode keeps its raw string instead of failing.
library;

import 'package:flutter/foundation.dart';

import '../json.dart';
import '../picker/picker_models.dart';
import '../season/season_models.dart';

/// Same seat for every performance, or a choice per performance.
@immutable
class SeatLayerRunSelectionMode {
  const SeatLayerRunSelectionMode(this.raw);

  final String raw;

  static const sameSeat = SeatLayerRunSelectionMode('same_seat');
  static const perPerformance = SeatLayerRunSelectionMode('per_performance');

  @override
  bool operator ==(Object other) =>
      other is SeatLayerRunSelectionMode && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}

/// One performance of the run, in its order.
@immutable
class SeatLayerRunPerformance {
  const SeatLayerRunPerformance({
    required this.position,
    required this.eventKey,
    required this.name,
    this.startsAt,
    this.startsAtLabel,
    this.salesState,
  });

  final int position;
  final String eventKey;
  final String name;
  final DateTime? startsAt;

  /// The start ready to print as it is, in the performance's zone and the
  /// page's language: `Sat 15 Aug · 15:00`. Null when the page cannot draw it.
  final String? startsAtLabel;
  final String? salesState;

  static SeatLayerRunPerformance? fromJson(Object? value) {
    final position = jInt(jGet(value, 'position'));
    final eventKey = jStr(jGet(value, 'eventKey'));
    final name = jStr(jGet(value, 'name'));
    if (position == null || eventKey == null || name == null) return null;
    return SeatLayerRunPerformance(
      position: position,
      eventKey: eventKey,
      name: name,
      startsAt: _epoch(jGet(value, 'startsAt')),
      startsAtLabel: jStr(jGet(value, 'startsAtLabel')),
      salesState: jStr(jGet(value, 'salesState')),
    );
  }
}

/// The run the page shows: its name for the app's header, and its
/// performances.
@immutable
class SeatLayerRunDescriptor {
  const SeatLayerRunDescriptor({
    required this.key,
    required this.name,
    required this.performances,
    this.state,
    this.mode,
    this.currency,
    this.venue,
    this.json = const <String, Object?>{},
  });

  final String key;
  final String name;
  final List<SeatLayerRunPerformance> performances;

  /// `active`, `closing`, `closed` or `archived`.
  final String? state;

  /// `live` or `test`.
  final String? mode;
  final String? currency;
  final String? venue;

  /// The whole descriptor as the page sent it.
  final Map<String, Object?> json;

  static SeatLayerRunDescriptor? fromJson(Object? value) {
    final json = jObj(value);
    final key = jStr(json?['key']);
    final name = jStr(json?['name']);
    if (json == null || key == null || name == null) return null;
    return SeatLayerRunDescriptor(
      key: key,
      name: name,
      performances:
          jListOf(json['performances'], SeatLayerRunPerformance.fromJson),
      state: jStr(json['state']),
      mode: jStr(json['mode']),
      currency: jStr(json['currency']),
      venue: jStr(json['venue']),
      json: Map<String, Object?>.unmodifiable(json),
    );
  }
}

/// What the page tells the buyer.
@immutable
class SeatLayerRunStatusKind {
  const SeatLayerRunStatusKind(this.raw);

  final String raw;

  static const idle = SeatLayerRunStatusKind('idle');
  static const pending = SeatLayerRunStatusKind('pending');
  static const recoveryFailed = SeatLayerRunStatusKind('recovery_failed');
  static const salesClosed = SeatLayerRunStatusKind('sales_closed');
  static const revisionChanged = SeatLayerRunStatusKind('revision_changed');
  static const sessionEnded = SeatLayerRunStatusKind('session_ended');

  @override
  bool operator ==(Object other) =>
      other is SeatLayerRunStatusKind && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}

/// The page's status line: a kind to decide on, and the sentence the buyer
/// reads (decide on [kind], never on [message]).
@immutable
class SeatLayerRunStatus {
  const SeatLayerRunStatus({
    required this.kind,
    required this.message,
    this.reference,
    this.branding,
  });

  final SeatLayerRunStatusKind kind;
  final String message;

  /// On [SeatLayerRunStatusKind.recoveryFailed]: the short reference to quote
  /// to support.
  final String? reference;

  /// From a page that sends it: the club's brand, under the event's field
  /// names.
  final SeatLayerPickerBranding? branding;

  static SeatLayerRunStatus? fromJson(Object? value) {
    final kind = jStr(jGet(value, 'kind'));
    if (kind == null) return null;
    final branding = jObj(jGet(value, 'branding'));
    return SeatLayerRunStatus(
      kind: SeatLayerRunStatusKind(kind),
      message: jStr(jGet(value, 'message')) ?? '',
      reference: jStr(jGet(value, 'reference')),
      branding:
          branding == null ? null : SeatLayerPickerBranding.fromJson(branding),
    );
  }
}

/// A run hold, handed to your checkout. It carries no price: your server
/// prices it and books it by [operationId].
@immutable
class SeatLayerRunHandoff {
  const SeatLayerRunHandoff({
    required this.operationId,
    required this.holdId,
    required this.expiresAt,
    required this.performanceKeys,
    required this.seatLabels,
    required this.booked,
    required this.json,
    this.selectionMode,
  });

  /// The `pghop_` id the hold was made under. Book by it, and de-duplicate a
  /// second Continue by it.
  final String operationId;
  final String holdId;
  final DateTime expiresAt;

  /// The performances the hold covers.
  final List<String> performanceKeys;

  /// The seats the buyer chose.
  final List<String> seatLabels;
  final SeatLayerRunSelectionMode? selectionMode;

  /// The page learned the operation was booked.
  final bool booked;

  /// The whole handoff as the page sent it (allocations, the run), to forward
  /// to your server unchanged.
  final Map<String, Object?> json;

  static SeatLayerRunHandoff? fromJson(Object? value) {
    final json = jObj(value);
    final operationId = jStr(json?['operationId']);
    final holdId = jStr(json?['holdId']);
    final expiresAt = _epoch(json?['expiresAt']);
    if (json == null ||
        operationId == null ||
        holdId == null ||
        expiresAt == null) {
      return null;
    }
    final mode = jStr(json['selectionMode']);
    return SeatLayerRunHandoff(
      operationId: operationId,
      holdId: holdId,
      expiresAt: expiresAt,
      performanceKeys: jListOf(json['performanceKeys'], jStr),
      seatLabels: jListOf(json['seatLabels'], jStr),
      selectionMode: mode == null ? null : SeatLayerRunSelectionMode(mode),
      booked: jStr(json['bookingState']) == 'booked',
      json: Map<String, Object?>.unmodifiable(json),
    );
  }
}

/// What `markBooked` found: the Season's words.
typedef SeatLayerRunBookedStatus = SeatLayerSeasonBookedStatus;

DateTime? _epoch(Object? value) {
  final ms = jDouble(value);
  if (ms == null || !ms.isFinite) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms.round());
}
