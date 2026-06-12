# Battery Level Unavailable Display

Status: Completed

## Context

`batteryLevelPercent` uses `-1` as an internal sentinel when Android omits the
battery level or reports an invalid scale. The battery image already treats
that value as unavailable, but the level text renders the sentinel directly as
`-1`. Users should see an explicit unavailable-data label instead of an
implementation detail.

## Changes

- Add a level display formatter that maps negative values to `Unknown`.
- Keep valid normalized battery percentages displayed as decimal text.
- Route the level view through the formatter without changing image thresholds.
- Extend the SDK-free baseline and README with the unavailable-level contract.

## Verification

- `make check`
- Static mutations for bypassing the level formatter or removing its negative
  value guard
- `git diff --check`

The Android SDK is unavailable on this host, so device rendering still requires
verification with a compatible Android toolchain.
