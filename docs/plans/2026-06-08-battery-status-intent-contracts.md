---
title: Battery Status Intent Contracts
status: completed
date: 2026-06-08
origin: user-requested continuous engineering quality loop
execution: code
---

# Battery Status Intent Contracts

## Problem Frame

The app reads the sticky `ACTION_BATTERY_CHANGED` broadcast in several places
and assumes it is always available. It also displays `EXTRA_LEVEL` directly
without normalizing against `EXTRA_SCALE`.

## Scope Boundaries

- Preserve the simple battery status UI.
- Do not add analytics, network reporting, or background telemetry.
- Do not migrate Gradle, SDK levels, or UI structure in this pass.

## Implementation Units

### U1: Static Battery Contracts

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Require a centralized sticky battery status helper.
- Require null-guarded battery status reads.
- Require level normalization with `BatteryManager.EXTRA_SCALE`.

### U2: Battery Status Guard

Files:

- Modify `app/src/main/java/garethpaul/com/chargeme/MainActivity.java`
- Modify `README.md`
- Modify `CHANGES.md`

Approach:

- Use a helper for sticky battery status reads.
- Return clear fallback values when status is unavailable.
- Display level as a percentage when scale is present.
- Keep low and medium battery icon thresholds contiguous.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
