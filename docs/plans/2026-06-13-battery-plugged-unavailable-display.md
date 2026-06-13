# Battery Plugged Unavailable Display

Status: Planned

## Priority

`batteryPluggedText()` currently maps every value other than AC, USB, and
wireless to `On Battery`. Android defines only the explicit value `0` as on
battery, while the app reads a missing extra as `-1`. The current fallback
therefore reports unavailable or unsupported power-source data as a real
unplugged state, contradicting the app's other `Unknown` fallbacks.

## Requirements

- **R1:** Map only `EXTRA_PLUGGED == 0` to `On Battery`.
- **R2:** Map missing, negative, and unsupported plugged values to `Unknown`.
- **R3:** Preserve AC, USB, and wireless labels and all other battery display,
  receiver, parser, lifecycle, build, and privacy behavior.
- **R4:** Add fail-closed SDK-free contracts, documentation, and hostile
  mutations for the explicit zero case and unknown fallback.
- **R5:** Record truthful local, external-directory, hosted Android, mutation,
  and device-state verification evidence.

## Implementation Units

### U1: Distinguish Unplugged From Unavailable

**File:** `app/src/main/java/garethpaul/com/chargeme/MainActivity.java`

Add an explicit zero case for `On Battery` and change the default plugged-state
label to `Unknown`.

### U2: Enforce The Display Contract

**File:** `scripts/check-baseline.sh`

Require the explicit zero case, existing charger constants, unknown default,
regression guidance, and completed plan evidence.

### U3: Document And Verify

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
`docs/plans/2026-06-13-battery-plugged-unavailable-display.md`

Document that absent or unsupported charging-source data remains unknown rather
than being presented as unplugged.

## Test Scenarios

- Values for AC, USB, wireless, and zero retain their distinct labels.
- Missing `-1`, other negative values, and unsupported positive values return
  `Unknown`.
- Removing the zero case, restoring the old default, removing a charger label,
  removing guidance, or reverting plan completion fails verification.

## Scope Boundaries

- Do not change broadcast registration, battery status/health/technology,
  level, voltage, current, temperature, icons, dependencies, or SDK versions.
- Do not claim device charging-state behavior without compatible hardware.

## Verification

Pending implementation and execution.

## Sources

- Android `BatteryManager.EXTRA_PLUGGED` API reference:
  https://developer.android.com/reference/android/os/BatteryManager#EXTRA_PLUGGED
- Android battery monitoring guide:
  https://developer.android.com/training/monitoring-device-state/battery-monitoring
