# SeatLayer picker design system

Two files describe the buyer picker's chrome completely enough to build it
again on another platform:

- **`tokens.json`** — every colour, size, radius, elevation, type step, motion
  duration, curve, haptic cue and default string, in a platform-neutral form.
  Colours are hex strings, durations are milliseconds, curves are named cubic
  béziers. Nothing Dart-specific appears in it.
- **`components.md`** — the component catalogue: for each widget, its snapshot
  inputs, its states, its anatomy in terms of the tokens above, its style
  slots, its callbacks and the bridge commands it issues.

## The Flutter package generates its defaults from tokens.json

`lib/src/picker/picker_tokens.g.dart` is generated. Do not edit it.

```bash
dart run tool/gen_tokens.dart          # regenerate after editing tokens.json
dart run tool/gen_tokens.dart --check  # fail if the generated file is stale
```

`SeatLayerPickerThemeData.light()/dark()`, `SeatLayerPickerLayout`,
`SeatLayerPickerMotion`, the haptic map and `SeatLayerPickerStrings` all read
that generated file, and `test/design_tokens_test.dart` both compares them
against the JSON and runs the `--check` guard, so the two cannot drift.

## Planned move

This directory is the first home, not the final one. `tokens.json` is due to
move to the runtime repository as
`packages/core/design/picker-tokens.json`, where the same file will feed Swift,
Kotlin and TypeScript generators alongside the Dart one. Keep it free of any
key that only Dart could consume, so that move stays a file copy.
