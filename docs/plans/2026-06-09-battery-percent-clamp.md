# Battery Percent Clamp

status: completed

## Context

`batteryLevelPercent` normalized Android's raw battery level against the
reported scale, but it returned the normalized value directly. Malformed or
vendor-specific broadcasts with out-of-range raw values could produce display
percentages outside the expected 0 through 100 range before icon threshold
selection.

## Objectives

- Preserve the existing fallback of `-1` for missing or invalid level/scale
  extras.
- Clamp valid normalized percentages to the 0 through 100 display range.
- Extend the SDK-free baseline guard and docs so percentage display stays
  bounded.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`
