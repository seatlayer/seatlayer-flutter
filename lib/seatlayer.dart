/// SeatLayer Flutter SDK.
///
/// Embed an interactive SeatLayer seat map by placing a [SeatLayerView] and
/// driving it through a [SeatLayerController]. The widget hosts the vendored
/// web bundle in a WebView and speaks the shared, versioned bridge protocol —
/// the same contract the iOS and web SDKs implement.
library seatlayer;

export 'src/bridge/bridge_client.dart'
    show BridgeChannel, BridgeSignal, HelloSignal, EventSignal, UnhandledSignal;
export 'src/bridge/bridge_protocol.dart'
    show
        ProtocolRange,
        Negotiation,
        NegotiationAgreed,
        NegotiationIncompatible,
        negotiate,
        seatLayerProtocolMin,
        seatLayerProtocolMax,
        BridgeErrorCode,
        BridgeErrorPayload,
        HoldConflict;
export 'src/bridge/envelope.dart'
    show Envelope, EnvelopeKind, EnvelopeKindUnknown;
export 'src/open_enums.dart';
export 'src/payloads.dart';
export 'src/seat_layer_configuration.dart';
export 'src/seat_layer_controller.dart';
export 'src/seat_layer_error.dart';
export 'src/seat_layer_view.dart';
