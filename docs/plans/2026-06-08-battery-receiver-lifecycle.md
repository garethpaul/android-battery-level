---
title: Battery Receiver Lifecycle Baseline
type: fix
status: completed
date: 2026-06-08
---

# Battery Receiver Lifecycle Baseline

## Summary

Fix the battery app's broadcast receiver lifecycle so activity transitions do not repeatedly register receivers without unregistering them. Add an SDK-free source check and documentation for the legacy Android verification path.

---

## Problem Frame

`MainActivity.setup()` currently registers `mBatInfoReceiver`, and the activity calls `setup()` from `onCreate`, `onResume`, `onPause`, and `onStop`. That means pause and stop transitions can register more receivers instead of releasing the existing one. Gradle starts locally but cannot configure the Android plugin without an Android SDK path.

---

## Requirements

- R1. The activity must register the battery receiver at most once while active.
- R2. The activity must unregister the battery receiver during pause/stop lifecycle transitions.
- R3. Existing battery UI refresh behavior in `setup()` must remain available during create/resume.
- R4. The repository must include a source check that runs without Android SDK configuration.
- R5. README documentation must explain the legacy Android toolchain and verification commands.
- R6. Verification results must distinguish source-check success from missing Android SDK configuration.

---

## Key Technical Decisions

- **Track receiver registration state:** A boolean guard avoids duplicate `registerReceiver` calls and makes unregistering idempotent.
- **Keep sticky battery reads in `setup()`:** The existing UI code reads `ACTION_BATTERY_CHANGED` via `registerReceiver(null, filter)`, so the fix should not rewrite UI refresh logic.
- **Use build-tools 24.0.3 with compile SDK 22:** The original build-tools 22.0.1 `aapt` binary is 32-bit and fails on this host while loading `libz.so.1`; build-tools 24.0.3 provides a 64-bit `aapt` while preserving the legacy Android Gradle Plugin.
- **Use SDK-free source checks:** Shell checks can guard the lifecycle regression before Android SDK setup is available.
- **Avoid toolchain migration in this pass:** Gradle, Android Gradle Plugin, SDK levels, and runtime permission behavior need a separate Android-capable pass.

---

## Scope Boundaries

- This pass does not change battery display thresholds, strings, icons, or current-reading logic.
- This pass does not migrate Gradle, Android Gradle Plugin, or SDK levels.
- This pass does not add emulator or instrumentation tests.
- This pass does not change runtime permission behavior.

---

## Implementation Units

### U1. Fix Receiver Registration Lifecycle

- **Goal:** Prevent duplicate receiver registration and release the receiver when the activity pauses or stops.
- **Files:** `app/src/main/java/garethpaul/com/chargeme/MainActivity.java`
- **Patterns:** Add `registerBatteryReceiver()` and `unregisterBatteryReceiver()` helpers; call registration from `setup()` and unregistration from lifecycle exit paths.
- **Test Scenarios:**
  - `setup()` calls a guarded receiver registration helper.
  - `onPause()` and `onStop()` call the unregister helper instead of `setup()`.
  - The helper checks registration state before unregistering.
- **Verification:** `scripts/check-baseline.sh`

### U2. Add SDK-Free Source Check

- **Goal:** Provide a repeatable quality gate before Android SDK setup.
- **Files:** `scripts/check-baseline.sh`
- **Patterns:** POSIX shell, repo-root detection, fail-fast messages.
- **Test Scenarios:**
  - The script fails if `onPause()` or `onStop()` call `setup()`.
  - The script verifies registration and unregistration helpers exist.
  - The script verifies receiver registration state is tracked.
  - The script verifies build-tools 24.0.3 is documented and pinned.
- **Verification:** `scripts/check-baseline.sh`

### U3. Document Restore and Verification

- **Goal:** Make the repo usable for future Android maintainers.
- **Files:** `README.md`
- **Patterns:** Short setup and verification sections with Android SDK prerequisites.
- **Test Scenarios:**
  - README lists `scripts/check-baseline.sh`.
  - README lists `./gradlew tasks --no-daemon` and `./gradlew assembleDebug --no-daemon`.
  - README documents that Android SDK configuration is required for Gradle verification.
- **Verification:** Manual README review

---

## Risks & Dependencies

- Gradle verification requires `ANDROID_HOME` or `local.properties` pointing to a compatible Android SDK with build-tools 24.0.3.
- The app targets SDK 22; runtime permission and modern battery API behavior should be handled separately.
- The current source has no unit-testable battery presenter or formatter layer, so deeper behavior coverage needs refactoring or instrumentation tests.

---

## Sources / Research

- `app/src/main/java/garethpaul/com/chargeme/MainActivity.java` calls `setup()` from create, resume, pause, and stop while `setup()` registers a receiver.
- `app/src/main/java/garethpaul/com/chargeme/mBatInfoReceiver.java` defines the receiver being registered.
- `app/build.gradle` originally used build-tools 22.0.1, whose 32-bit `aapt` fails on this host while loading `libz.so.1`.
