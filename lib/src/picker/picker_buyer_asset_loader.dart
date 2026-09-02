import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../payloads.dart';
import '../seat_layer_configuration.dart';
import 'seat_layer_picker_controller.dart';

/// How the bytes for one event-scoped image are actually fetched.
///
/// Injected so tests never open a socket, and so a host with its own HTTP
/// stack (a proxy, a pinned client, an offline cache) can supply one.
typedef SeatLayerAssetFetch = Future<Uint8List> Function(
  Uri uri,
  Map<String, String> headers,
);

/// The default API origin, matching the runtime's own.
const String _defaultApiBase = 'https://api.seatlayer.io';

/// How many decoded references the loader keeps.
const int _cacheEntries = 12;

/// How long the default transport may take before the card gives up on the
/// photograph.
///
/// Without this a stalled connection would leave the strip on its loading
/// gradient for as long as the card is up, and the buyer would never get the
/// plain rail the miss path promises. An injected fetch owns its own timeout:
/// a timer here would outlive the widget tests that hand in a fetch that never
/// answers on purpose.
const Duration _fetchTimeout = Duration(seconds: 15);

/// How long before a bearer's stated expiry it stops being used.
const Duration _tokenSafetyMargin = Duration(seconds: 30);

/// `/pub/events/{key}/assets/{asset}`, and nothing else.
final RegExp _reference =
    RegExp(r'^/pub/events/([^/]+)/assets/([a-zA-Z0-9._-]+)$');

/// Fetches the buyer-scoped images the native chrome draws itself.
///
/// A seat-view thumbnail is NOT an `Image.network` URL. On a private event the
/// same path answers 401 without the buyer's bearer, and putting that bearer
/// in an `Image.network` header set would leak it into Flutter's shared image
/// cache key. This mirrors the web transport instead — `GET {apiBase}{path}`
/// with `Authorization: Bearer …` and no cookies — and keeps the bytes in its
/// own small cache.
///
/// Every failure resolves to null. "No photograph" is an ordinary state of the
/// confirm card, and a thrown error there would take down a card the buyer is
/// answering.
class SeatLayerBuyerAssetLoader {
  /// Creates a loader bound to one event.
  SeatLayerBuyerAssetLoader({
    required this.eventKey,
    String? apiBase,
    BuyerAccessToken? token,
    BuyerAccessTokenProvider? tokenProvider,
    SeatLayerAssetFetch? fetch,
  })  : apiBase = _trimTrailingSlash(apiBase ?? _defaultApiBase),
        _token = token,
        _tokenProvider = tokenProvider,
        _fetch = fetch ?? _httpFetch;

  /// A loader built from what the host configured the picker with.
  factory SeatLayerBuyerAssetLoader.fromConfiguration(
    SeatLayerConfiguration configuration, {
    SeatLayerAssetFetch? fetch,
  }) =>
      SeatLayerBuyerAssetLoader(
        eventKey: configuration.event,
        apiBase: configuration.apiBase,
        token: configuration.buyerAccessToken,
        tokenProvider: configuration.buyerAccessTokenProvider,
        fetch: fetch,
      );

  /// The event every reference has to belong to.
  final String eventKey;

  /// The API origin the reference is resolved against.
  final String apiBase;

  final BuyerAccessTokenProvider? _tokenProvider;
  final SeatLayerAssetFetch _fetch;

  BuyerAccessToken? _token;
  final Map<String, Uint8List> _bytes = <String, Uint8List>{};
  final Map<String, Future<Uint8List?>> _inFlight =
      <String, Future<Uint8List?>>{};

  /// The bytes for [reference], or null when there is no photograph to show.
  ///
  /// Null covers every reason at once — a reference this event does not own, a
  /// 403 or 404, no bearer, a dead network — because the card does the same
  /// thing for all of them.
  Future<Uint8List?> load(String reference) {
    final cached = _bytes[reference];
    if (cached != null) {
      // Reading an entry makes it the most recent one.
      _bytes
        ..remove(reference)
        ..[reference] = cached;
      return Future<Uint8List?>.value(cached);
    }
    // One request per reference however many cards ask for it: two seats in
    // the same row can share a photograph, and a scrubbing buyer can reopen
    // the same card before the first fetch has landed.
    final running = _inFlight[reference];
    if (running != null) return running;
    final future = _load(reference).whenComplete(() {
      _inFlight.remove(reference);
    });
    _inFlight[reference] = future;
    return future;
  }

  /// Forget [reference], so the next open fetches it again.
  void evict(String reference) => _bytes.remove(reference);

  /// Forget everything. Called when the picker session ends.
  void clear() {
    _bytes.clear();
    _inFlight.clear();
    _token = null;
  }

  Future<Uint8List?> _load(String reference) async {
    final uri = resolve(reference);
    if (uri == null) return null;
    final authorization = await _authorization();
    if (authorization == null) return null;
    try {
      final bytes = await _fetch(uri, <String, String>{
        'Authorization': authorization,
      });
      _remember(reference, bytes);
      return bytes;
    } on Object {
      // Deliberately opaque: the failure may carry the request that carried
      // the bearer, and nothing here is allowed to log or rethrow it.
      return null;
    }
  }

  /// The absolute URL [reference] names, or null when it is not this event's.
  ///
  /// The runtime already applies this predicate before emitting the field; it
  /// is applied again here because a reference that reached this side wrong is
  /// a request that must not be made, not a request that fails.
  Uri? resolve(String reference) {
    final match = _reference.firstMatch(reference);
    if (match == null) return null;
    if (Uri.decodeComponent(match.group(1)!) != eventKey) return null;
    return Uri.parse('$apiBase$reference');
  }

  void _remember(String reference, Uint8List bytes) {
    _bytes[reference] = bytes;
    while (_bytes.length > _cacheEntries) {
      _bytes.remove(_bytes.keys.first);
    }
  }

  /// The `Authorization` header value, or null when this event needs none of
  /// the sort the host can supply.
  Future<String?> _authorization() async {
    final held = _token;
    if (held != null && !_expiring(held)) return 'Bearer ${held.token}';
    final provider = _tokenProvider;
    if (provider == null) {
      // A one-shot token that has already expired is not refreshable, and a
      // public event has no token at all. Both are "no photograph".
      return held == null ? null : 'Bearer ${held.token}';
    }
    try {
      final fresh = await provider(
        const BuyerAccessRequestContext(reason: BuyerAccessRefreshReason.asset),
      );
      _token = fresh;
      return 'Bearer ${fresh.token}';
    } on Object {
      return null;
    }
  }

  static bool _expiring(BuyerAccessToken token) {
    final expiresAt = token.expiresAt;
    if (expiresAt == null || !expiresAt.isFinite) return false;
    final deadline =
        DateTime.fromMillisecondsSinceEpoch(expiresAt.round(), isUtc: true)
            .subtract(_tokenSafetyMargin);
    return !DateTime.now().toUtc().isBefore(deadline);
  }

  static String _trimTrailingSlash(String base) =>
      base.endsWith('/') ? base.substring(0, base.length - 1) : base;
}

/// The default transport: `dart:io`, so the package gains no dependency.
Future<Uint8List> _httpFetch(Uri uri, Map<String, String> headers) =>
    _httpGet(uri, headers).timeout(_fetchTimeout);

Future<Uint8List> _httpGet(Uri uri, Map<String, String> headers) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    headers.forEach(request.headers.set);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Drained rather than left open: an abandoned response holds its socket.
      await response.drain<void>();
      throw const _AssetUnavailable();
    }
    final chunks = await response.toList();
    final total = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final bytes = Uint8List(total);
    var offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
  } finally {
    client.close(force: true);
  }
}

/// Carries no status, no URL and no headers — see [SeatLayerBuyerAssetLoader].
class _AssetUnavailable implements Exception {
  const _AssetUnavailable();
}

/// The loader bound to one controller, keyed weakly so a disposed controller
/// takes its loader with it.
final Expando<SeatLayerBuyerAssetLoader> _bound =
    Expando<SeatLayerBuyerAssetLoader>('seatlayer.assetLoader');

/// Reaching the buyer-scoped image transport from the controller.
///
/// An extension rather than a field on [SeatLayerPickerController] because
/// that file is at the package's line cap, and because the configuration the
/// loader needs — `apiBase`, the event key, the bearer — is owned by the
/// scope, not by the controller. The scope binds one here on attach and clears
/// it on dispose.
extension SeatLayerPickerAssetLoader on SeatLayerPickerController {
  /// The transport for this session's buyer-scoped images.
  ///
  /// Never null: a controller with no scope above it gets an inert loader that
  /// resolves every reference to null, so the confirm card's code path is the
  /// same whether or not a session is attached.
  SeatLayerBuyerAssetLoader get assetLoader =>
      _bound[this] ??= SeatLayerBuyerAssetLoader(eventKey: '');

  /// Whether the runtime reports authored seat-view photographs, the distance
  /// to the stage and the seat's confidence disclosure.
  ///
  /// Read off the handshake rather than off the snapshot: `snapshot.features`
  /// says which features the EVENT has, and this says whether the bundle
  /// speaks the fields at all. A runtime that predates them simply omits
  /// them, and the card is then the card it was before this existed.
  ///
  /// On the extension for the same reason the loader is — the controller's own
  /// file is at the package's line cap.
  bool get supportsSeatViewThumbnails {
    final bundle = mapController.bundleInfo;
    return bundle != null &&
        bundle.supportsCapability(seatLayerSeatViewThumbnailCapability);
  }

  /// Install a loader built by the caller. A host supplying its own HTTP
  /// stack, and every widget test, comes in here.
  set assetLoader(SeatLayerBuyerAssetLoader loader) {
    final existing = _bound[this];
    if (identical(existing, loader)) return;
    existing?.clear();
    _bound[this] = loader;
  }

  /// Bind the loader for [configuration]. Called by the picker scope.
  void bindAssetLoader(
    SeatLayerConfiguration configuration, {
    SeatLayerAssetFetch? fetch,
  }) {
    final existing = _bound[this];
    if (existing != null &&
        existing.eventKey == configuration.event &&
        fetch == null) {
      return;
    }
    existing?.clear();
    _bound[this] = SeatLayerBuyerAssetLoader.fromConfiguration(
      configuration,
      fetch: fetch,
    );
  }

  /// Drop the cached bytes and the cached bearer. Called by the picker scope
  /// when the session ends.
  void clearAssetLoader() => _bound[this]?.clear();
}
