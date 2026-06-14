# Preserve Current Fallbacks Without a Device Model

Status: Planned

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

To be recorded after implementation:

- SDK-free checker and Java 8/API 22 Gradle gates.
- Repository-root and external-directory `make check`.
- Isolated normalization, ordering, source-list, documentation, and plan
  mutations.

## Risks

- Devices without model metadata no longer receive the HTC-specific shortcut,
  but continue through the same generic source list.
- No physical device or vendor-specific `/sys` source is exercised locally.
