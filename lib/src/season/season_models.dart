/// What a Season page reports, typed. Every value the page may add to later is
/// open: an unknown kind or status keeps its raw string instead of failing.
library;

import 'package:flutter/foundation.dart';

import '../json.dart';
import '../picker/picker_models.dart';

/// What the Season page is doing, as its status line says.
@immutable
class SeatLayerSeasonStatusKind {
  const SeatLayerSeasonStatusKind(this.raw);

  final String raw;

  static const loading = SeatLayerSeasonStatusKind('loading');
  static const ready = SeatLayerSeasonStatusKind('ready');
  static const pending = SeatLayerSeasonStatusKind('pending');
  static const held = SeatLayerSeasonStatusKind('held');
  static const booked = SeatLayerSeasonStatusKind('booked');
  static const released = SeatLayerSeasonStatusKind('released');
  static const renewalIntent = SeatLayerSeasonStatusKind('renewal_intent');
  static const partialTerminal = SeatLayerSeasonStatusKind('partial_terminal');
  static const failed = SeatLayerSeasonStatusKind('failed');

  @override
  bool operator ==(Object other) =>
      other is SeatLayerSeasonStatusKind && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}

/// One date the Season's package covers, in its order.
@immutable
class SeatLayerSeasonDate {
  const SeatLayerSeasonDate({
    required this.position,
    required this.eventKey,
    required this.name,
    this.startsAt,
    this.startsAtLabel,
    this.past = false,
    this.cancelled = false,
  });

  final int position;
  final String eventKey;
  final String name;

  /// Null while the date has no start yet.
  final DateTime? startsAt;

  /// The start ready to print as it is, in the Season's zone and the page's
  /// language: `Sat 15 Aug · 15:00`. Null when the page cannot draw it.
  final String? startsAtLabel;

  /// No longer part of what a new hold takes.
  final bool past;

  /// Taken off sale.
  final bool cancelled;

  static SeatLayerSeasonDate? fromJson(Object? value) {
    final position = jInt(jGet(value, 'position'));
    final eventKey = jStr(jGet(value, 'eventKey'));
    final name = jStr(jGet(value, 'name'));
    if (position == null || eventKey == null || name == null) return null;
    return SeatLayerSeasonDate(
      position: position,
      eventKey: eventKey,
      name: name,
      startsAt: _epoch(jGet(value, 'startsAt')),
      startsAtLabel: jStr(jGet(value, 'startsAtLabel')),
      past: jBool(jGet(value, 'past')) ?? false,
      cancelled: jBool(jGet(value, 'cancelled')) ?? false,
    );
  }
}

/// The page's status line: a kind to decide on, and the sentence the buyer
/// sees and hears (decide on [kind], never on [message]).
@immutable
class SeatLayerSeasonStatus {
  const SeatLayerSeasonStatus({
    required this.kind,
    required this.message,
    this.operationId,
    this.dates,
    this.seasonName,
    this.branding,
  });

  final SeatLayerSeasonStatusKind kind;
  final String message;
  final String? operationId;

  /// On [SeatLayerSeasonStatusKind.ready] only: the package's dates.
  final List<SeatLayerSeasonDate>? dates;

  /// Once the Season is read, from a page that sends it: the Season's name,
  /// for the app's header.
  final String? seasonName;

  /// Once the Season is read, from a page that sends it: the club's brand,
  /// under the event's field names.
  final SeatLayerPickerBranding? branding;

  static SeatLayerSeasonStatus? fromJson(Object? value) {
    final kind = jStr(jGet(value, 'kind'));
    if (kind == null) return null;
    final dates = jList(jGet(value, 'dates'));
    final branding = jObj(jGet(value, 'branding'));
    return SeatLayerSeasonStatus(
      kind: SeatLayerSeasonStatusKind(kind),
      message: jStr(jGet(value, 'message')) ?? '',
      operationId: jStr(jGet(value, 'operationId')),
      dates:
          dates == null ? null : jListOf(dates, SeatLayerSeasonDate.fromJson),
      seasonName: jStr(jGet(jGet(value, 'season'), 'name')),
      branding:
          branding == null ? null : SeatLayerPickerBranding.fromJson(branding),
    );
  }
}

/// A Season hold, handed to your checkout. Your server books it by
/// [operationId] and charges at its own prices.
@immutable
class SeatLayerSeasonHandoff {
  const SeatLayerSeasonHandoff({
    required this.seasonKey,
    required this.planActivationId,
    required this.operationId,
    required this.holdId,
    required this.expiresAt,
    required this.json,
  });

  final String seasonKey;
  final String planActivationId;

  /// The caller-stable `sop_` id the hold was made under. Book by it, and
  /// de-duplicate a second Continue by it.
  final String operationId;
  final String holdId;
  final DateTime expiresAt;

  /// The whole handoff as the page sent it (allocations, seats and their
  /// price types, policy), to forward to your server unchanged.
  final Map<String, Object?> json;

  static SeatLayerSeasonHandoff? fromJson(Object? value) {
    final json = jObj(value);
    final seasonKey = jStr(json?['seasonKey']);
    final planActivationId = jStr(json?['planActivationId']);
    final operationId = jStr(json?['operationId']);
    final holdId = jStr(json?['holdId']);
    final expiresAt = _epoch(json?['expiresAt']);
    if (json == null ||
        seasonKey == null ||
        planActivationId == null ||
        operationId == null ||
        holdId == null ||
        expiresAt == null) {
      return null;
    }
    return SeatLayerSeasonHandoff(
      seasonKey: seasonKey,
      planActivationId: planActivationId,
      operationId: operationId,
      holdId: holdId,
      expiresAt: expiresAt,
      json: Map<String, Object?>.unmodifiable(json),
    );
  }
}

/// The held order as the page prices it.
@immutable
class SeatLayerSeasonHeldOrder {
  const SeatLayerSeasonHeldOrder({
    required this.operationId,
    required this.expiresAt,
    required this.currency,
    required this.seats,
    this.totalMinor,
  });

  final String operationId;
  final DateTime expiresAt;
  final String currency;

  /// Each held seat as the page sent it.
  final List<Object?> seats;

  /// The total in minor units, or null when the page cannot price it.
  final int? totalMinor;

  static SeatLayerSeasonHeldOrder? fromJson(Object? value) {
    final operationId = jStr(jGet(value, 'operationId'));
    final expiresAt = _epoch(jGet(value, 'expiresAt'));
    final currency = jStr(jGet(value, 'currency'));
    if (operationId == null || expiresAt == null || currency == null) {
      return null;
    }
    return SeatLayerSeasonHeldOrder(
      operationId: operationId,
      expiresAt: expiresAt,
      currency: currency,
      seats: List<Object?>.unmodifiable(jList(jGet(value, 'seats')) ?? []),
      totalMinor: jInt(jGet(value, 'totalMinor')),
    );
  }
}

/// How a close the app asked for ended.
@immutable
class SeatLayerSeasonCloseOutcome {
  const SeatLayerSeasonCloseOutcome(this.raw);

  final String raw;

  /// Nothing was held: close the screen.
  static const closed = SeatLayerSeasonCloseOutcome('closed');

  /// The buyer released the seats: close the screen.
  static const released = SeatLayerSeasonCloseOutcome('released');

  /// The buyer kept the seats: they stay held until the hold runs out.
  static const kept = SeatLayerSeasonCloseOutcome('kept');

  /// Asked again while the question was up: stay.
  static const stayed = SeatLayerSeasonCloseOutcome('stayed');

  /// The buyer chose Release, but the server had booked the hold: close as
  /// after a purchase.
  static const booked = SeatLayerSeasonCloseOutcome('booked');

  /// Whether the screen should close on this outcome.
  bool get closes => this != stayed;

  @override
  bool operator ==(Object other) =>
      other is SeatLayerSeasonCloseOutcome && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}

/// What `markBooked` found.
@immutable
class SeatLayerSeasonBookedStatus {
  const SeatLayerSeasonBookedStatus(this.raw);

  final String raw;

  /// Booked now.
  static const booked = SeatLayerSeasonBookedStatus('booked');

  /// This page saw it booked before.
  static const alreadyBooked = SeatLayerSeasonBookedStatus('already_booked');

  /// Held here but not booked on the server yet: send again once it is.
  static const pending = SeatLayerSeasonBookedStatus('pending');

  /// Nothing is held here, and the server has not booked the named operation.
  static const nothingHeld = SeatLayerSeasonBookedStatus('nothing_held');

  /// The page holds another operation, and the server has not booked the
  /// named one.
  static const differentHold = SeatLayerSeasonBookedStatus('different_hold');

  @override
  bool operator ==(Object other) =>
      other is SeatLayerSeasonBookedStatus && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}

DateTime? _epoch(Object? value) {
  final ms = jDouble(value);
  if (ms == null || !ms.isFinite) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms.round());
}
