# Battery Telemetry Boundary Review

Status: Completed

## Scope

Deep-review the maintained PR #2-#14 stack and the overlapping PR #1 for
receiver ownership, sticky battery intents, telemetry units and ranges, sysfs
fallbacks, vendor labels, component exports, and UI fail-closed behavior.

## Findings

- Linux power-supply `current_now` files use microamps, but three reviewed
  paths were displayed without conversion, producing values 1000 times too
  large. The original 2015 implementation introduced the path-specific unit
  table; later remediation commits carried it forward.
- The first parseable current source won even when its value was outside a
  defensible milliamp range, preventing fallback to a later valid source.
- Temperature, voltage, and current accepted extreme integers and rendered
  them as plausible telemetry.
- Manufacturer, model, and battery technology strings accepted control and
  bidirectional format characters that could visually spoof or split local UI
  labels.
- Activity creation and resume both called setup. Registration ownership
  prevented two receivers, but the activity performed a redundant sticky
  lookup and retained a duplicate temperature cache in the receiver.
- Receiver unregistration could crash if framework registration state no
  longer matched the local flag.

## Fix

- Centralize level, temperature, voltage, current, and vendor-label policy in
  dependency-free `BatteryTelemetry` code.
- Convert every standardized `current_now` source from microamps to milliamps,
  preserve reviewed source order, and continue after implausible readings.
- Render the sticky intent returned by receiver registration, remove duplicate
  receiver temperature state, and make unregistration idempotent and
  fail-closed.
- Keep the sole launcher activity explicitly exported; add no new components,
  services, receivers, permissions, analytics, or network paths.

## Evidence

- RED: the initial host compile failed because no telemetry policy seam
  existed; source-unit and hostile-label expectations were therefore absent.
- GREEN: 32 dependency-free host assertions cover units, ranges, source
  fallback, parsing, level clamping, and vendor labels.
- Six hostile mutations are rejected for current units/ranges, label format
  controls, voltage/temperature ranges, and percentage clamping.
- Android instrumentation adds receiver forwarding and telemetry boundary
  assertions.
- `make check` passes locally. The local machine has no configured Android SDK,
  so Gradle lint, instrumentation compilation, and APK assembly require the
  canonical hosted Java 8/API 22/build-tools 24.0.3 gate.

## Residual Risk

No physical device, emulator battery controls, vendor kernel sysfs files,
thermal edge cases, multi-cell battery, or OEM metadata was exercised. The
wide safety bounds reject corrupt values rather than certify sensor accuracy.
Device model and battery telemetry remain local UI data and are not logged or
transmitted.
