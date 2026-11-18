# Contributing

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter test --tags golden        # recorded and enforced on macOS
dart run tool/gen_tokens.dart     # after editing design/tokens.json
dart pub publish --dry-run
```

## Design system

The picker's colours, sizes, radii, elevations, type scale, motion table, haptic
cues and default strings live in one platform-neutral file,
[`design/tokens.json`](design/tokens.json); the catalogue describing every widget
in terms of those tokens is [`design/components.md`](design/components.md),
written so a Swift, Kotlin or React Native engineer can reproduce the design.

`lib/src/picker/picker_tokens.g.dart` is **generated** from that JSON by
`dart run tool/gen_tokens.dart` (`--check` fails if it is stale) and must not be
hand-edited. The presets, `SeatLayerPickerLayout`, `SeatLayerPickerMotion`, the
haptic map and `SeatLayerPickerStrings` all read the file, and
`design_tokens_test.dart` asserts them against it, so the two cannot drift.
