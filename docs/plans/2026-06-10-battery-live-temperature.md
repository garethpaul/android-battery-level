# Battery Live Temperature Updates

Status: Completed

## Context

The registered battery receiver validated temperature broadcasts and stored the
latest value internally, but `MainActivity` never read that field. The visible
temperature therefore remained at the sticky-intent value captured during
setup even while valid battery broadcasts arrived.

## Changes

- Add a receiver listener for valid temperature values.
- Have `MainActivity` implement the listener and update the current temperature
  view through the existing formatter.
- Preserve missing-intent, missing-extra, and invalid-sentinel guards.
- Guard the view lookup so stale layouts do not crash a broadcast callback.
- Extend the SDK-free baseline with receiver-to-activity wiring contracts.

## Verification

- `make check`
- Static mutations for a removed receiver callback and detached activity
  listener
- `git diff --check`

The Android SDK is unavailable on this host, so live device broadcast behavior
still requires verification with a compatible Android toolchain.
