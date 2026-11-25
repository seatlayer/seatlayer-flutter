import 'dart:async';

import 'package:flutter/widgets.dart';

import 'bridge/bridge_session.dart';

/// Answers a page the system ended, once the app is in front.
///
/// Behind another app the new page would be ended as well.
final class SeatLayerPageKeeper {
  SeatLayerPageKeeper(this.answer);

  final VoidCallback answer;

  StreamSubscription<void>? _subscription;
  bool _lost = false;

  void watch(SeatLayerBridgeSession session) {
    unwatch();
    _subscription = session.onPageLost.listen((_) {
      _lost = true;
      if (_inFront(WidgetsBinding.instance.lifecycleState)) _answer();
    });
  }

  void unwatch() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _lost = false;
  }

  /// The app moved. Whether this was the moment to answer a lost page.
  bool appMoved(AppLifecycleState state) {
    if (!_lost || !_inFront(state)) return false;
    _answer();
    return true;
  }

  void _answer() {
    _lost = false;
    answer();
  }

  static bool _inFront(AppLifecycleState? state) =>
      state == null || state == AppLifecycleState.resumed;
}
