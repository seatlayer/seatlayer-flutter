/// SeatLayer Flutter SDK.
///
/// Embed an interactive SeatLayer seat map by placing a [SeatLayerView] and
/// driving it through a [SeatLayerController]. The widget hosts the immutable,
/// version-pinned mobile runtime in a WebView and speaks the shared bridge —
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
export 'src/picker/picker_builders.dart';
export 'src/picker/picker_haptics.dart' show PickerHapticCue;
export 'src/picker/picker_models.dart';
export 'src/picker/picker_confirm_card.dart';
export 'src/picker/picker_dock_bar.dart';
export 'src/picker/picker_layout.dart';
export 'src/picker/picker_motion.dart';
export 'src/picker/picker_options.dart';
export 'src/picker/picker_strings.dart';
export 'src/picker/seat_layer_picker.dart';
export 'src/picker/seat_layer_picker_components.dart';
export 'src/picker/seat_layer_picker_controller.dart';
export 'src/picker/seat_layer_picker_presentation.dart';
export 'src/picker/seat_layer_picker_scope.dart';
export 'src/picker/seat_layer_picker_theme.dart';
export 'src/seat_layer_configuration.dart';
export 'src/seat_layer_controller.dart';
export 'src/seat_layer_error.dart';
export 'src/seat_layer_view.dart';
