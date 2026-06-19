# Android Battery Device Verification

Run this matrix on the exact reviewed commit with a compatible Android SDK,
Java 8, legacy Gradle runtime, and authorized emulator or physical device.
Portable contracts do not substitute for real battery-state evidence.

## Evidence Header

Record these values without sysfs dumps, kernel paths, device identifiers,
logs, APKs, keys, or account data:

- commit SHA and pull request
- tester and UTC timestamp
- Android Studio, SDK, build tools, Java, and Gradle versions
- emulator image or physical-device model and Android version
- clean install or upgrade path
- Gradle lint, test, and assemble result

Mark every row `pass`, `fail`, `blocked`, or `not run`. Explain blocked and
unexecuted rows. Do not convert `not run` into passing evidence.

## Broadcast Display Matrix

Use approved emulator battery controls or naturally observed device states:

| Scenario | Expected result | Result | Evidence |
| --- | --- | --- | --- |
| Normal level and scale | Percent clamps to 0-100 and selects the matching icon. | not run | |
| Missing or invalid level | Display uses `Unknown` without exposing sentinels. | not run | |
| Charging on AC, USB, wireless | Source label matches the broadcast value. | not run | |
| Explicit unplugged | Source displays `On Battery`. | not run | |
| Missing plugged extra | Source remains `Unknown`, not unplugged. | not run | |
| Status and health variants | Labels match known values with `Unknown` fallback. | not run | |
| Temperature absent or invalid | Prior valid live value or `Unknown` is retained. | not run | |
| Voltage value | Millivolts display as one-decimal volts. | not run | |
| Technology whitespace | Label normalizes to `Unknown`. | not run | |
| Extreme temperature or voltage | Display uses `Unknown`, not a plausible-looking extreme. | not run | |
| Control or bidi vendor label | Model or technology displays `Unknown`. | not run | |

## Current And Reader Matrix

Current-source behavior may require physical devices with reviewed legacy power
supply files; emulator results alone are insufficient.

| Scenario | Expected result | Result | Evidence |
| --- | --- | --- | --- |
| First source valid | Current displays from the first reviewed source. | not run | |
| Earlier source invalid | Reader continues to a later valid source. | not run | |
| Standard `current_now` source | Microamps convert to milliamps exactly once. | not run | |
| Earlier source implausible | Reader continues to a later plausible source. | not run | |
| All sources unavailable | Current displays `Unknown`. | not run | |
| Read or parse failure | Generic category is logged without path or value. | not run | |
| Close failure | Generic close category is logged after the read attempt. | not run | |
| Repeated refresh | Reader descriptors do not accumulate. | not run | |

## Lifecycle Matrix

| Scenario | Expected result | Result | Evidence |
| --- | --- | --- | --- |
| Resume activity | Receiver registers and renders the sticky snapshot. | not run | |
| Live battery broadcast | All intent-backed fields refresh from one snapshot. | not run | |
| Pause activity | Receiver unregisters without a crash or duplicate updates. | not run | |
| Rotate during updates | Recreated activity has one active receiver. | not run | |
| Missing sticky broadcast | Every display helper fails closed to `Unknown`. | not run | |

Sanitized evidence must not contain sysfs paths, malformed sensor values, stack
traces, serial numbers, model-specific identifiers, or full diagnostic dumps.

## Completion

Record unresolved failures and protected evidence links outside git. A runtime
claim requires all applicable rows to pass on the exact commit. This repository
currently records every battery device and current-source row as unexecuted.
