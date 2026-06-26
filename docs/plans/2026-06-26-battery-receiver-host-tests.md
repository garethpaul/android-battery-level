# Battery Receiver Host Tests

Status: Completed

## Context

The activity already registers its context receiver in `onResume` and
unregisters it in `onPause`, matching Android's documented smallest useful
lifecycle scope. The dependency-free host suite covers telemetry and sysfs
boundaries, but it does not execute the receiver adapter that connects Android
broadcast delivery to the activity listener.

## Design

- Add minimal host-only `android.content` stubs needed to compile the receiver.
- Execute `mBatInfoReceiver.onReceive` in the existing Java host suite.
- Verify a non-null battery intent is forwarded exactly once and by identity.
- Verify a null intent is ignored and a missing listener remains safe.
- Keep the production receiver and activity lifecycle behavior unchanged.
- Add a mutation that removes the null-intent guard so the new coverage proves
  it protects a real receiver boundary.

## Test First

Add receiver expectations and compile the production receiver before adding the
required Android host stubs. The host suite must fail to compile, establishing
that the receiver path was not previously executable in the SDK-free tests.

## Verification Plan

- Run the host suite and receiver mutation directly.
- Run the source baseline, full mutation suite, and mutation-runner gate.
- Run `make lint`, `test`, `build`, `verify`, and `check` from checkout and an
  external working directory.
- Run shell syntax checks and `git diff --check`.
- Use hosted Android lint/tests/build and CodeQL as exact-head authority when no
  local Android SDK is configured.

## Scope Boundaries

- No receiver registration scope, activity lifecycle, battery formatting,
  current-source probing, UI, resource, manifest, logging, backup, dependency,
  SDK, or network behavior change.
- Host stubs model only the types required to execute the receiver adapter.

## Verification Completed

- Red-first `scripts/test-battery-host.sh` failed because the Android receiver
  types were absent, then passed with 45 assertions after adding the host stubs.
- `scripts/test-battery-mutations.sh` rejected all thirteen mutations,
  including removal of the receiver null-intent guard.
- `scripts/check-baseline.sh` and the mutation-runner infrastructure gate
  passed.
- `/usr/bin/make lint`, `test`, `build`, `verify`, and `check` passed from the
  checkout and through the absolute Makefile path from `/tmp`.
- Shell syntax checks and `git diff --check` passed.
- No local Android SDK was configured, so Gradle lint, tests, and debug assembly
  explicitly skipped; hosted exact-head checks remain authoritative.
