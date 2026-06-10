# Battery Temperature Availability

Status: Completed

## Goal

Distinguish unavailable Android battery temperature data from a real
zero-degree Celsius reading.

## Requirements

- Missing sticky-broadcast temperature extras render as `Unknown`.
- Invalid sentinel values render as `Unknown`.
- Valid tenths preserve one decimal and Celsius units.
- Receiver updates ignore missing extras and invalid sentinels.
- The SDK-free baseline enforces both display and receiver behavior.
- Root Make targets work outside the checkout and accept either Android SDK
  environment variable.
- Hosted verification uses a fixed runner and cancels superseded runs.

## Implementation

- Extract a battery-temperature intent formatter in `MainActivity`.
- Require `hasExtra`, use `Integer.MIN_VALUE` as the parse sentinel, and format
  valid values with `Locale.US`.
- Apply the same presence and sentinel checks in `mBatInfoReceiver`.
- Resolve Make paths from the Makefile location and normalize
  `ANDROID_HOME`/`ANDROID_SDK_ROOT` for the legacy Gradle wrapper.
- Pin GitHub Actions to Ubuntu 24.04 and add workflow concurrency.

## Verification

- `make check`
- `make -f /absolute/path/to/Makefile check` from outside the repository
- temperature-availability and automation mutation checks
- shell syntax checks
- `git diff --check`

The Android SDK is not available on this host, so runtime broadcast behavior
still requires verification with the legacy-compatible toolchain.
