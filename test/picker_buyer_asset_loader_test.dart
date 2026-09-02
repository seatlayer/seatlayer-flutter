import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

/// A fetch that records what it was asked for and answers [bytes].
class _RecordingFetch {
  _RecordingFetch({this.fail = false});

  final bool fail;
  final List<(Uri, Map<String, String>)> calls =
      <(Uri, Map<String, String>)>[];

  Future<Uint8List> call(Uri uri, Map<String, String> headers) async {
    calls.add((uri, headers));
    if (fail) throw StateError('403');
    return Uint8List.fromList(<int>[1, 2, 3]);
  }
}

const String _reference = '/pub/events/ev_test/assets/seat-a-1.jpg';

void main() {
  test('the request carries the bearer and the event-scoped path', () async {
    final fetch = _RecordingFetch();
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      apiBase: 'https://api.example.test',
      token: const BuyerAccessToken(token: 'buyer-bearer'),
      fetch: fetch.call,
    );

    expect(await loader.load(_reference), isNotNull);
    expect(fetch.calls, hasLength(1));
    expect(
      fetch.calls.single.$1.toString(),
      'https://api.example.test$_reference',
    );
    expect(fetch.calls.single.$2['Authorization'], 'Bearer buyer-bearer');
  });

  test('a reference for another event never leaves the device', () async {
    final fetch = _RecordingFetch();
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'buyer-bearer'),
      fetch: fetch.call,
    );

    expect(
      await loader.load('/pub/events/ev_other/assets/seat-a-1.jpg'),
      isNull,
    );
    expect(fetch.calls, isEmpty);
  });

  test('an asset name outside the runtime predicate is refused', () async {
    final fetch = _RecordingFetch();
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'buyer-bearer'),
      fetch: fetch.call,
    );

    expect(await loader.load('/pub/events/ev_test/assets/../secret'), isNull);
    expect(await loader.load('/pub/events/ev_test/assets/a b.jpg'), isNull);
    expect(await loader.load('https://elsewhere.test/photo.jpg'), isNull);
    expect(fetch.calls, isEmpty);
  });

  test('the bearer is asked for once and then reused', () async {
    final fetch = _RecordingFetch();
    var asked = 0;
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      tokenProvider: (context) {
        asked += 1;
        expect(context.reason, BuyerAccessRefreshReason.asset);
        return const BuyerAccessToken(token: 'fresh');
      },
      fetch: fetch.call,
    );

    await loader.load(_reference);
    await loader.load('/pub/events/ev_test/assets/seat-a-2.jpg');
    expect(asked, 1);
    expect(fetch.calls, hasLength(2));
  });

  test('a refused fetch resolves to no photograph, never to a throw', () async {
    final fetch = _RecordingFetch(fail: true);
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'buyer-bearer'),
      fetch: fetch.call,
    );

    expect(await loader.load(_reference), isNull);
    expect(fetch.calls, hasLength(1));
  });

  test('with no bearer at all nothing is requested', () async {
    final fetch = _RecordingFetch();
    final loader =
        SeatLayerBuyerAssetLoader(eventKey: 'ev_test', fetch: fetch.call);

    expect(await loader.load(_reference), isNull);
    expect(fetch.calls, isEmpty);
  });

  test('a second read of one reference is the cache, and clear forgets it',
      () async {
    final fetch = _RecordingFetch();
    // A provider rather than a one-shot bearer: `clear` drops the cached
    // credential with the cached bytes, which is the point of it.
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      tokenProvider: (_) => const BuyerAccessToken(token: 'buyer-bearer'),
      fetch: fetch.call,
    );

    await loader.load(_reference);
    await loader.load(_reference);
    expect(fetch.calls, hasLength(1));

    loader.clear();
    await loader.load(_reference);
    expect(fetch.calls, hasLength(2));

    loader.evict(_reference);
    await loader.load(_reference);
    expect(fetch.calls, hasLength(3));
  });

  test('two readers of one reference share one request', () async {
    final fetch = _RecordingFetch();
    final loader = SeatLayerBuyerAssetLoader(
      eventKey: 'ev_test',
      token: const BuyerAccessToken(token: 'buyer-bearer'),
      fetch: fetch.call,
    );

    final both = await Future.wait(<Future<Uint8List?>>[
      loader.load(_reference),
      loader.load(_reference),
    ]);
    expect(both.first, isNotNull);
    expect(both.last, isNotNull);
    expect(fetch.calls, hasLength(1));
  });
}
