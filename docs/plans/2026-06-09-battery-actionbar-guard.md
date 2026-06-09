---
title: Battery ActionBar Guard
type: reliability
status: completed
date: 2026-06-09
---

# Battery ActionBar Guard

## Problem Frame

`MainActivity.onCreate` dereferenced `getActionBar()` twice before rendering
the battery screen. A legacy theme or future UI adjustment that removes the
platform action bar would crash startup before any battery data is displayed.

## Scope Boundaries

- Preserve the current title-hiding and battery icon behavior when an action bar
  is present.
- Do not change layouts, themes, battery reads, receiver lifecycle, Gradle, or
  SDK versions in this pass.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Guard ActionBar Configuration

Files:

- Modify `app/src/main/java/garethpaul/com/chargeme/MainActivity.java`

Approach:

- Add a small `configureActionBar()` helper.
- Read `getActionBar()` once into a local `ActionBar`.
- Return early when no action bar is available.
- Apply the existing hidden-title and battery icon settings only when safe.

### U2: Extend Static Baseline Checks

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Assert that the helper and null guard stay present.
- Assert that direct `getActionBar().set...` dereferences do not return.
- Keep existing receiver lifecycle and battery formatting contracts unchanged.

### U3: Document The Startup Guard

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that action-bar presentation is optional and guarded.
- Keep larger theme or UI modernization separate from this startup reliability
  pass.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
