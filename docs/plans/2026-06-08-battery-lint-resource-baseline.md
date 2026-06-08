---
title: Battery Lint Resource Baseline
type: chore
status: completed
date: 2026-06-08
---

# Battery Lint Resource Baseline

## Summary

Clean the remaining Android lint findings in the legacy battery UI while
preserving the existing screen behavior and adding source checks for the
resource baseline.

## Requirements

- R1. Keep the receiver lifecycle guard intact.
- R2. Move static UI text into string resources.
- R3. Replace hardcoded left/right layout attributes with start/end attributes.
- R4. Move active bitmap assets to `drawable-nodpi` and remove unused starter
  images.
- R5. Document only the narrow lint suppressions needed by the old Android
  toolchain.
- R6. Verify with the SDK-free baseline check, Android lint, unit tests, and
  debug assembly.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
