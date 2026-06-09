---
title: Battery Voltage Display Contracts
type: correctness
status: completed
date: 2026-06-09
---

# Battery Voltage Display Contracts

## Problem Frame

`BatteryManager.EXTRA_VOLTAGE` reports the battery voltage in millivolts, but
the activity currently displays the raw integer with a `V` suffix. A typical
4000 mV reading therefore appears as `4000V` instead of a readable `4.0V`.

## Scope Boundaries

- Preserve the existing battery status lookup and TextView wiring.
- Do not change receiver lifecycle, icon thresholds, Gradle, SDK, or layout
  behavior in this pass.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Add Voltage Display Formatting

Files:

- Modify `app/src/main/java/garethpaul/com/chargeme/MainActivity.java`

Approach:

- Add a small `batteryVoltageText(int millivolts)` helper.
- Return `Unknown` when the voltage extra is unavailable.
- Convert millivolts to volts and format with `Locale.US`.

### U2: Extend Static Baseline Checks

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Assert that the voltage TextView uses the formatter.
- Assert that raw `String.valueOf(getVoltage()) + "V"` display does not return.
- Assert that voltage formatting uses `Locale.US`.

### U3: Document The Contract

Files:

- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Record the voltage-unit conversion and link this plan from maintenance notes.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

Gradle verification remains dependent on a compatible Android SDK.
