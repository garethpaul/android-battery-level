# Battery Receiver Temperature Guard

Date: 2026-06-09
Status: Completed

## Problem

The registered battery receiver assumed every `onReceive` call included a
non-null intent before reading `BatteryManager.EXTRA_TEMPERATURE`. Its
temperature helper also divided the raw tenths-of-a-degree value as an integer
before casting, so values such as `225` became `22.0` instead of `22.5`.

## Scope

- Keep the existing receiver registration lifecycle unchanged.
- Preserve the simple raw-temperature storage model.
- Avoid broader UI, Gradle, or SDK modernization.
- Keep verification available through the SDK-free baseline check.

## Work Completed

- Added a null-intent guard to `mBatInfoReceiver.onReceive`.
- Preserved the last known receiver temperature when the temperature extra is
  missing from a broadcast.
- Changed receiver temperature conversion to divide by `10.0f` so tenths are
  retained.
- Extended the baseline check and documentation for the receiver temperature
  guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
