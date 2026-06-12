# Hosted Android Verification

## Status: Implementation Complete; Hosted Verification Pending

## Context

The canonical workflow clears Android SDK variables because the legacy Gradle
toolchain was assumed unsupported. The current PR head now passes Android
lint, both unit-test variants, and debug assembly locally with Android API 22,
build-tools 24.0.3, and Java 8.

## Goal

Run the proven complete Android gate for pull requests and default-branch
pushes instead of skipping every hosted Gradle task.

## Changes

- Install platform-tools, Android API 22, and build-tools 24.0.3 before
  selecting Java 8.
- Run the canonical `make check` target with the hosted SDK configured.
- Increase the bounded timeout for SDK installation and the complete gate.
- Keep immutable actions, read-only permissions, disabled checkout credentials,
  and the byte-exact workflow checker contract.
- Update README and CI plan evidence without suppressing the target warning.

## Verification

- Passed SDK-backed `make check` from the repository root.
- Passed the same complete gate from an external working directory.
- Confirmed lint reports exactly the documented `OldTargetApi` warning.
- Confirmed eight hostile workflow, checker, documentation, and plan-status
  mutations are rejected.
- Passed `git diff --check`.
- Exact-head pull-request workflow pending after the implementation push.

## Boundaries

- Do not change or suppress `targetSdkVersion 22` in this unit.
- Do not modernize Gradle, the Android plugin, JCenter, or battery behavior.
- Do not add credentials, signing material, permissions, or dependencies.
