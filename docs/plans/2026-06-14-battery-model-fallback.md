# Preserve Current Fallbacks Without a Device Model

Status: Completed

## Context

`CurrentReader.getValue()` lowercases `Build.MODEL` before probing any battery
current source. If the platform model string is unavailable, that dereference
throws before the reader can try generic `/sys` locations, and battery status
rendering can fail instead of displaying `Unknown` current.

## Scope

- Normalize a null device model to an empty lowercase string.
- Skip only the model-specific HTC shortcut when model metadata is absent.
- Preserve the complete generic source order, unit conversions, reader cleanup,
  and `null` fallback.
- Add mutation-sensitive portable contracts and maintenance documentation.

## Implementation Units

### 1. Normalize model metadata

Files:

- `app/src/main/java/garethpaul/com/chargeme/CurrentReader.java`

Read `Build.MODEL` once, map null to an empty string, and lowercase non-null
values with `Locale.US` before the existing model-specific test.

### 2. Protect fallback ordering

Files:

- `scripts/check-baseline.sh`
- `docs/plans/2026-06-14-battery-model-fallback.md`

Require null normalization before lowercase conversion and before the HTC
branch, retain all generic sources, and require completed verification evidence.

### 3. Document degraded behavior

Files:

- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`

Record that missing model metadata does not block generic current probes and
still degrades to `Unknown` when no source can be read.

## Verification

- `sh -n scripts/check-baseline.sh` passed.
- With Amazon Corretto 8 and the Android API 22 SDK,
  `./gradlew lint test assembleDebug --no-daemon` passed. Lint retained the
  existing `OldTargetApi` warning for target SDK 22; debug and release unit-test
  tasks and debug assembly completed successfully.
- Repository-root `make check` passed with the API 22 SDK configured, and an
  external-directory invocation passed with SDK variables unset to exercise
  the portable source-contract path.
- Eight isolated mutations were rejected for nullable normalization, ordering,
  locale selection, generic-source preservation, documentation, and completed
  plan evidence.

## Risks

- Devices without model metadata no longer receive the HTC-specific shortcut,
  but continue through the same generic source list.
- No physical device or vendor-specific `/sys` source is exercised locally.
