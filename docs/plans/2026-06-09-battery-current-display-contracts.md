# Battery Current Display Contracts

## Status: Completed

## Context

`CurrentReader.getValue()` returns `null` when no supported battery current file
is present on the device. `MainActivity` previously rendered that missing value
with `String.valueOf(...)`, which showed the literal text `null` in the UI.

## Objectives

- Preserve the existing device-specific current reader behavior.
- Display missing current readings as `Unknown`, matching the voltage fallback.
- Keep the behavior covered by the SDK-free baseline checker.

## Work Completed

- Added `batteryCurrentText(Long currentValue)` in `MainActivity`.
- Routed the current `TextView` through the helper before display.
- Extended `scripts/check-baseline.sh` to reject direct
  `String.valueOf(CurrentReader.getValue())` usage and require the helper.
- Updated README, VISION, and CHANGES notes for the current display contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Gradle lint, tests, and debug assembly run when `ANDROID_HOME` points to a
compatible Android SDK.
