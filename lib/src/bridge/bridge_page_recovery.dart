/// Counts the pages the system ended, so a page that cannot stay up ends in the
/// failure view with its Try again, not in a reload that never stops.
final class SeatLayerPageRecovery {
  SeatLayerPageRecovery({DateTime Function() now = DateTime.now}) : _now = now;

  /// Two pages lost inside this window are replaced; a third is not.
  static const Duration window = Duration(minutes: 1);
  static const int limit = 2;

  final DateTime Function() _now;
  final List<DateTime> _recent = <DateTime>[];

  /// Whether this loss may be answered with a new page.
  bool lost() {
    final now = _now();
    _recent
      ..removeWhere((at) => now.difference(at) >= window)
      ..add(now);
    return _recent.length <= limit;
  }

  /// The buyer asked for the page again: the count starts over.
  void reset() => _recent.clear();
}
