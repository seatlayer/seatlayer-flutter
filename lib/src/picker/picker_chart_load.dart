/// What one chart load cost, as the runtime measured it and as the SDK did.
library;

import 'package:meta/meta.dart';

import '../json.dart';
import '../payloads.dart';

/// The runtime's own chart-load beacon, handed to the host as well.
///
/// The same object the runtime posts to `POST /pub/telemetry/chart-load`. It
/// arrives once per render attempt, success or failure, and it arrives even
/// where the beacon deliberately never reaches the network — a localhost
/// harness, or an environment with no `fetch` — because a host watching its
/// own load must not be blinded by our sampling rules.
///
/// **Every field is optional.** The runtime's vocabulary grows, and a trace
/// that gained a field must not stop decoding on an older SDK; one that lost a
/// field must not turn a real load into a decode failure. What this SDK does
/// not model is kept verbatim in [raw], so a host can read a field this
/// release has never heard of without waiting for a release.
///
/// Nothing here is logged or sent anywhere by the SDK. Report it to your own
/// analytics if you want it.
@immutable
class SeatLayerChartLoadTrace {
  /// Creates a trace. Hosts read one off [SeatLayerChartLoad.trace]; this
  /// constructor exists for tests and for a host synthesising a fixture.
  const SeatLayerChartLoadTrace({
    this.raw = const <String, Object?>{},
    this.event,
    this.scope,
    this.surface,
    this.outcome,
    this.stage,
    this.ms,
    this.api,
    this.scene,
    this.panel,
    this.paint,
    this.normalize,
    this.renderer,
    this.availabilityMs,
    this.seats,
    this.floors,
    this.view,
    this.load,
    this.transport,
    this.chartBytes,
    this.chartCache,
    this.server,
    this.r2Head,
    this.cacheLookup,
    this.r2Get,
    this.transform,
    this.host,
    this.platform,
    this.bundle,
    this.protocol,
    this.chromeOwner,
    this.bootMs,
    this.documentMs,
    this.handshakeMs,
  });

  /// The whole trace exactly as it crossed the bridge, unknown fields included.
  final Map<String, Object?> raw;

  /// The event key the chart was built for.
  final String? event;

  /// What was loaded — `event`, `chart`, …
  final String? scope;

  /// Which runtime surface rendered — e.g. `seating_chart`.
  final String? surface;

  /// `success` or a failure word.
  final String? outcome;

  /// Where a failed attempt stopped; empty on a success.
  final String? stage;

  /// Milliseconds from the runtime's own `render()` to a drawn chart.
  ///
  /// Unchanged since the beacon was introduced, so a historical series keeps
  /// its meaning. It is the LAST span of a cold open, not the whole of it —
  /// see [SeatLayerChartLoad.tapToReadyMs].
  final int? ms;

  /// Milliseconds spent in the public API call.
  final int? api;

  /// Milliseconds spent building the scene.
  final int? scene;

  /// Milliseconds spent building the web panel chrome (zero for a native host).
  final int? panel;

  /// Milliseconds spent on the first paint.
  final int? paint;

  /// Milliseconds spent normalising the chart document.
  final int? normalize;

  /// Milliseconds spent inside the renderer.
  final int? renderer;

  /// Milliseconds spent resolving seat availability.
  final int? availabilityMs;

  /// How many seats the chart holds.
  final int? seats;

  /// How many floors the venue has.
  final int? floors;

  /// Which view was rendered — `map`, `venue3d`, …
  final String? view;

  /// `cold` or `warm`.
  final String? load;

  /// How the chart document was fetched — e.g. `pubapi`.
  final String? transport;

  /// Size of the fetched chart document, in bytes.
  final int? chartBytes;

  /// `hit` or `miss` on the chart document cache.
  final String? chartCache;

  /// Milliseconds the API server spent on the request.
  final int? server;

  /// Milliseconds spent on the object-store HEAD.
  final int? r2Head;

  /// Milliseconds spent on the cache lookup.
  final int? cacheLookup;

  /// Milliseconds spent on the object-store GET.
  final int? r2Get;

  /// Milliseconds spent transforming the stored chart.
  final int? transform;

  /// `web` or `webview`.
  final String? host;

  /// `web`, `flutter`, `ios`, `android`, `rn` or `unknown`. Confirm this reads
  /// `flutter`: anything else means the runtime did not recognise this shim.
  final String? platform;

  /// The runtime bundle version that drew the chart.
  final String? bundle;

  /// The negotiated bridge protocol revision.
  final int? protocol;

  /// Who drew the furniture — `native` for this SDK.
  final String? chromeOwner;

  /// Milliseconds from document start to a ready chart: the page's whole life.
  ///
  /// Measured from `performance.timeOrigin`, so it composes with a native mark
  /// directly. Everything before it — map host construction, the process spin-up
  /// and the host's own work — is outside the page and is what
  /// [SeatLayerChartLoad.hostMs] reports.
  final int? bootMs;

  /// Milliseconds from document start to the bridge `hello`: document, bundle
  /// and parse.
  final int? documentMs;

  /// Milliseconds from `hello` to `init`. Measured under 1 ms; reported so it
  /// stays there.
  final int? handshakeMs;

  /// Whether the runtime reported a successful render.
  ///
  /// A trace with no `outcome` at all is not called a failure: an older runtime
  /// that omits the field has still, by sending the trace, rendered something.
  bool get succeeded => outcome == null || outcome == 'success';

  /// Decode `p.trace`, or null when the payload is not a trace object.
  ///
  /// Schema-checked only as far as "this is a JSON object" — a bridge payload
  /// is deliberately open, and rejecting a trace for an unfamiliar field is how
  /// a host goes blind on the release that adds one.
  static SeatLayerChartLoadTrace? fromJson(Object? value) {
    final raw = jObj(value);
    if (raw == null) return null;
    return SeatLayerChartLoadTrace(
      raw: Map<String, Object?>.unmodifiable(raw),
      event: jStr(raw['event']),
      scope: jStr(raw['scope']),
      surface: jStr(raw['surface']),
      outcome: jStr(raw['outcome']),
      stage: jStr(raw['stage']),
      ms: jInt(raw['ms']),
      api: jInt(raw['api']),
      scene: jInt(raw['scene']),
      panel: jInt(raw['panel']),
      paint: jInt(raw['paint']),
      normalize: jInt(raw['normalize']),
      renderer: jInt(raw['renderer']),
      availabilityMs: jInt(raw['availabilityMs']),
      seats: jInt(raw['seats']),
      floors: jInt(raw['floors']),
      view: jStr(raw['view']),
      load: jStr(raw['load']),
      transport: jStr(raw['transport']),
      chartBytes: jInt(raw['chartBytes']),
      chartCache: jStr(raw['chartCache']),
      server: jInt(raw['server']),
      r2Head: jInt(raw['r2Head']),
      cacheLookup: jInt(raw['cacheLookup']),
      r2Get: jInt(raw['r2Get']),
      transform: jInt(raw['transform']),
      host: jStr(raw['host']),
      platform: jStr(raw['platform']),
      bundle: jStr(raw['bundle']),
      protocol: jInt(raw['protocol']),
      chromeOwner: jStr(raw['chromeOwner']),
      bootMs: jInt(raw['bootMs']),
      documentMs: jInt(raw['documentMs']),
      handshakeMs: jInt(raw['handshakeMs']),
    );
  }

  @override
  String toString() => 'SeatLayerChartLoadTrace($outcome, boot: $bootMs ms, '
      'render: $ms ms, bundle: $bundle)';
}

/// One chart load, measured from the buyer's tap rather than from the page.
///
/// The runtime can only see what happens after its own document exists, and the
/// app can only see up to the moment the runtime says it is ready. Neither half
/// is the number a buyer feels. This is both halves in one object: [trace] is
/// what the page measured, [tapToReadyMs] is what the SDK measured, and
/// [hostMs] is the difference — the map host construction and the host's own
/// work.
///
/// Nothing here is logged or transmitted by the SDK.
@immutable
class SeatLayerChartLoad {
  /// Creates a merged load record.
  const SeatLayerChartLoad({
    required this.trace,
    this.tapToReadyMs,
    this.ready,
  });

  /// What the runtime measured inside its own document.
  final SeatLayerChartLoadTrace trace;

  /// Milliseconds from the picker mounting to the chart being ready.
  ///
  /// T0 is the moment `SeatLayerPicker` (or a bare `SeatLayerPickerScope`) was
  /// mounted — the frame after the buyer's tap, and the same moment whether or
  /// not the page was prewarmed, so a prewarm's saving shows up here as a
  /// smaller number rather than as a hidden one.
  ///
  /// Null when the trace arrived before the runtime ever reported ready, which
  /// is the ordinary shape of a failed load.
  final int? tapToReadyMs;

  /// The handshake the runtime reported, when one has happened.
  ///
  /// [ReadyInfo.timeToReadyMs] is the narrower span: it starts when the view
  /// armed the handshake, not when the picker mounted.
  final ReadyInfo? ready;

  /// Milliseconds spent outside the runtime page: map host construction, the
  /// process spin-up and whatever the host did between mounting and arming.
  ///
  /// [tapToReadyMs] less the page's own [SeatLayerChartLoadTrace.bootMs]. Null
  /// when either is missing, and clamped at zero: the two clocks are started by
  /// different processes and a few milliseconds of skew must not report a
  /// negative span.
  int? get hostMs {
    final total = tapToReadyMs;
    final boot = trace.bootMs;
    if (total == null || boot == null) return null;
    final outside = total - boot;
    return outside < 0 ? 0 : outside;
  }

  @override
  String toString() => 'SeatLayerChartLoad(tapToReady: $tapToReadyMs ms, '
      'host: $hostMs ms, $trace)';
}
