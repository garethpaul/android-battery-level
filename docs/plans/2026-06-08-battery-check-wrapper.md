---
title: Battery Check Wrapper
type: chore
status: completed
date: 2026-06-08
---

# Battery Check Wrapper

## Summary

Expose the battery app's SDK-free source check and SDK-backed Gradle gates
through the shared root `make check` command.

## Requirements

- R1. Preserve `scripts/check-baseline.sh` as the first verification step.
- R2. Run Gradle lint, tests, and debug assembly when `ANDROID_HOME` points to
  an installed Android SDK.
- R3. Keep SDK-missing behavior explicit rather than failing before source
  checks can run.
- R4. Document the wrapper in README and CHANGES.

## Verification

- `make check`
- `git diff --check`
