# Battery Reader Log Redaction

Status: Completed

## Context

The legacy kernel battery-current readers log exception messages, throwable
stacks, and one raw `printStackTrace()`. Read and parse failures can therefore
copy device-specific `/sys` paths or malformed sensor contents into logcat even
though the UI already handles missing current data as `Unknown`.

## Requirements

- **R1:** Replace exception-derived reader logs with stable generic read and
  parse categories.
- **R2:** Remove throwable logging, `getMessage()`, and `printStackTrace()` from
  all battery text readers.
- **R3:** Preserve exact path probing, field-prefix validation, sign conversion,
  nullable failure returns, and `Unknown` UI behavior.
- **R4:** Extend the SDK-free checker to require exact log counts and reject
  additive exception-derived logging.
- **R5:** Update repository privacy guidance and completed verification.

## Implementation Units

### U1: Redact Reader Failures

**Files:** `BattAttrTextReader.java`, `OneLineReader.java`, `SMemTextReader.java`

Use fixed messages for read failures and invalid numeric values. Do not pass
caught exceptions or derived strings to Android logging.

### U2: Enforce The Boundary

**File:** `scripts/check-baseline.sh`

Require the reviewed fixed-message counts across the three readers and reject
throwable overloads, exception messages, stack conversion, raw stack printing,
and extra log calls.

### U3: Document And Verify

**Files:** `README.md`, `SECURITY.md`, `CHANGES.md`, this plan

Document that battery reader failures retain categories without exposing kernel
paths or malformed sensor values.

## Test Scenarios

- Restoring a throwable argument or `getMessage()` fails the checker.
- Restoring `printStackTrace()` fails the checker.
- Adding an extra reader log fails the checker.
- Removing any fixed read or parse category fails the checker.
- Existing Android lint, tests, assembly, display, lifecycle, and reader
  contracts remain green.

## Scope Boundaries

- Do not change probed paths, model matching, prefixes, parsing, units, return
  values, Android permissions, dependencies, SDK, Gradle, or UI behavior.
- Do not claim device logcat behavior without a compatible device or emulator.

## Verification

- The SDK-free checker failed before implementation because the reviewed fixed
  categories were absent and exception-derived logging remained.
- Seven hostile mutations were rejected: restoring a throwable log, restoring
  `getMessage()`, restoring `printStackTrace()`, adding an extra reader log,
  removing a fixed category, removing security guidance, and removing this
  canonical plan.
- SDK-backed `make check` passed with Amazon Corretto 8 and
  `/home/gjones/android-sdk`, including lint, debug/release unit-test tasks,
  Java compilation, and debug APK assembly. Lint retained the single documented
  `OldTargetApi` compatibility warning.
- External-directory `make check`, workflow YAML parsing, shell syntax, secret
  scanning, and `git diff --check` passed.
- Device-specific current sensor failures and logcat output remain platform
  validation boundaries.
