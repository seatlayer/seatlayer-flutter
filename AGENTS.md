# SeatLayer Flutter public-repository rules

This repository is the public SeatLayer Flutter SDK.

## Public-repository hygiene — hard rule

- Commit only product source, tests, build/release automation, public examples,
  package metadata, and customer-facing integration, API, migration, or
  security documentation.
- Never commit planning documents, handovers, implementation audits or reviews,
  cross-SDK comparison matrices, manual QA journals, evidence bundles, dated
  progress reports, before/rejected captures, credentials, non-public hosts,
  private repository references, or developer-machine paths.
- Public product media belongs in `doc/media/`; regression images belong only
  in automated test-fixture locations. Do not use the Git repository as an
  evidence archive.
- Record verification in CI and release checks, not in tracked screenshots or
  narrative proof documents.
- Run `bash scripts/check-public-repository.sh` before committing or pushing.

## The design files are the other SDKs' source

The buyer picker in this package is the reference implementation. The iOS,
Android and React Native SDKs are built from `design/tokens.json` and
`design/picker-spec.md` alone, without reading Dart. So any change to picker
behaviour, layout, copy, motion, haptics or numbers updates the token file and
the specification **in the same change** as the code — a number that lives only
in a widget has already diverged from three other platforms, and a state or
string the spec does not describe will not exist on them at all. Fix
`design/components.md` in the same pass whenever a name, slot or entry there
goes stale.

Preserve bridge negotiation, command correlation, stale-event filtering,
unknown-value tolerance, origin restrictions, and the server-side booking
boundary. Keep secrets and booking credentials off the device.
