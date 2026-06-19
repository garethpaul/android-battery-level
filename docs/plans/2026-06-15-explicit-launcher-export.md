---
title: ChargeMe Explicit Launcher Export Boundary
type: security
status: completed
date: 2026-06-15
---

# ChargeMe Explicit Launcher Export Boundary

## Problem Frame

ChargeMe's `.MainActivity` owns the app's sole `MAIN`/`LAUNCHER` intent filter
but omits `android:exported`. Legacy Android infers the activity is externally
reachable. That leaves the component boundary implicit to maintainers and
security tooling and prevents a future Android 12 target upgrade without a
manifest correction.

## Priorities

1. P0: Preserve launcher behavior while explicitly declaring the existing
   external boundary.
2. P1: Add a location-independent structural checker contract that couples one
   true exported declaration to `.MainActivity` and its launcher filter.
3. P1: Synchronize durable guidance and completed validation evidence without
   changing battery collection or UI behavior.

## Requirements

- Declare `android:exported="true"` only on `.MainActivity`.
- Preserve the application metadata, backup policy, launcher filter, activity
  label/icon/theme, permissions, battery reader lifecycle, and display output.
- Reject missing, false, duplicate, unrelated, or filter-detached declarations.
- Keep repository and external-directory verification equivalent.
- Record SDK-backed validation separately from emulator, device, and live
  battery-event scenarios.

## Implementation Units

### 1. Make launcher reachability explicit

**File:** `app/src/main/AndroidManifest.xml`

Add the explicit true attribute to the existing launcher activity only.

### 2. Enforce launcher ownership

**File:** `scripts/check-baseline.sh`

Count exported occurrences and require the sole declaration in the named
activity block that also contains the `MAIN` action and `LAUNCHER` category.

### 3. Synchronize maintained guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document the intentional boundary and exact validation evidence.

## Verification

- Run POSIX syntax and the focused baseline checker.
- Run repository and external-directory `make check` with Java 8 and the
  configured Android SDK.
- Reject isolated missing, false, unrelated, filter-detached, same-line
  duplicate, missing-guidance, and incomplete-plan mutations.
- Audit generated artifacts, the exact diff, file modes, whitespace, conflict
  markers, dependency/workflow drift, and credential-shaped additions.

## Risks And Mitigations

- **Launch regression:** bind the declaration to the existing activity name and
  both filter entries in the portable checker.
- **Overexposure:** allow exactly one exported attribute and reject application
  or unrelated component declarations.
- **Legacy build:** retain all Gradle, Android plugin, SDK, and dependency
  versions in this narrow manifest change.
- **Stacked delivery:** base the PR on the device-name fallback branch and
  preserve base-first merge ordering.

## Out Of Scope

- Gradle, Android plugin, target/compile SDK, or dependency upgrades.
- New activities, services, receivers, providers, deep links, or permissions.
- Battery reader lifecycle, device identity fallback, voltage calculations,
  layouts, strings, or presentation behavior.

## Completion Evidence

- POSIX syntax and the focused battery baseline checker passed.
- repository and external-directory `make check` passed under Java 8 with the
  configured Android SDK; lint, debug/release unit execution, and debug
  assembly succeeded. Android lint retained one pre-existing non-fatal issue
  in each build variant.
- Seven isolated hostile mutations were rejected for missing, false,
  application-owned, filter-detached, same-line duplicate, missing-guidance,
  and incomplete-plan variants.
- The exact eight-path diff, generated-artifact cleanup, file modes,
  whitespace, conflict markers, dependency/workflow drift, and
  credential-shaped additions were audited before commit.
- No emulator, physical-device, or live battery-event scenario was executed.
