import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/src/picker/picker_connection.dart';

void main() {
  test('reads the four states and ignores one it does not know', () {
    expect(SeatLayerConnectionState.fromJson('live'),
        SeatLayerConnectionState.live);
    expect(SeatLayerConnectionState.fromJson('reconnecting'),
        SeatLayerConnectionState.reconnecting);
    expect(SeatLayerConnectionState.fromJson('polling'),
        SeatLayerConnectionState.polling);
    expect(SeatLayerConnectionState.fromJson('offline'),
        SeatLayerConnectionState.offline);
    expect(SeatLayerConnectionState.fromJson('satellite'), isNull);
    expect(SeatLayerConnectionState.fromJson(null), isNull);
  });

  test('a blink of the network says nothing', () {
    fakeAsync((time) {
      final watch = SeatLayerConnectionWatch();
      watch.heard(SeatLayerConnectionState.offline);
      time.elapse(const Duration(seconds: 2));
      watch.heard(SeatLayerConnectionState.live);
      watch.seatsRead();
      time.elapse(const Duration(seconds: 5));
      expect(watch.value, SeatLayerConnectionShown.none);
      watch.dispose();
    });
  });

  test('offline after three seconds, then Updating, then Back online once '
      'the seats are read, for two and a half seconds', () {
    fakeAsync((time) {
      final watch = SeatLayerConnectionWatch();
      final seen = <SeatLayerConnectionShown>[];
      watch.addListener(() => seen.add(watch.value));

      watch.heard(SeatLayerConnectionState.offline);
      time.elapse(const Duration(milliseconds: 2999));
      expect(watch.value, SeatLayerConnectionShown.none);
      time.elapse(const Duration(milliseconds: 1));
      expect(watch.value, SeatLayerConnectionShown.offline);

      watch.heard(SeatLayerConnectionState.reconnecting);
      expect(watch.value, SeatLayerConnectionShown.updating);
      watch.heard(SeatLayerConnectionState.live);
      // Not back until the seats have been read again.
      expect(watch.value, SeatLayerConnectionShown.updating);
      watch.seatsRead();
      expect(watch.value, SeatLayerConnectionShown.back);
      time.elapse(const Duration(milliseconds: 2500));
      expect(watch.value, SeatLayerConnectionShown.none);

      expect(seen, [
        SeatLayerConnectionShown.offline,
        SeatLayerConnectionShown.updating,
        SeatLayerConnectionShown.back,
        SeatLayerConnectionShown.none,
      ]);
      watch.dispose();
    });
  });

  test('a line that only retries says Updating after ten seconds and goes '
      'without Back online', () {
    fakeAsync((time) {
      final watch = SeatLayerConnectionWatch();
      watch.heard(SeatLayerConnectionState.reconnecting);
      time.elapse(const Duration(seconds: 9));
      expect(watch.value, SeatLayerConnectionShown.none);
      time.elapse(const Duration(seconds: 1));
      expect(watch.value, SeatLayerConnectionShown.updating);
      watch.heard(SeatLayerConnectionState.live);
      watch.seatsRead();
      expect(watch.value, SeatLayerConnectionShown.none);
      watch.dispose();
    });
  });

  test('seats by poll after an outage count as back', () {
    fakeAsync((time) {
      final watch = SeatLayerConnectionWatch();
      watch.heard(SeatLayerConnectionState.offline);
      time.elapse(const Duration(seconds: 3));
      watch.heard(SeatLayerConnectionState.polling);
      watch.seatsRead();
      expect(watch.value, SeatLayerConnectionShown.back);
      watch.dispose();
    });
  });

  test('losing the line again during an outage says offline at once', () {
    fakeAsync((time) {
      final watch = SeatLayerConnectionWatch();
      watch.heard(SeatLayerConnectionState.offline);
      time.elapse(const Duration(seconds: 3));
      watch.heard(SeatLayerConnectionState.reconnecting);
      watch.heard(SeatLayerConnectionState.offline);
      expect(watch.value, SeatLayerConnectionShown.offline);
      watch.dispose();
    });
  });

  test('a new page forgets the old one', () {
    fakeAsync((time) {
      final watch = SeatLayerConnectionWatch();
      watch.heard(SeatLayerConnectionState.offline);
      time.elapse(const Duration(seconds: 3));
      watch.reset();
      expect(watch.value, SeatLayerConnectionShown.none);
      expect(watch.state, isNull);
      watch.heard(SeatLayerConnectionState.live);
      watch.seatsRead();
      expect(watch.value, SeatLayerConnectionShown.none);
      watch.dispose();
    });
  });
}
