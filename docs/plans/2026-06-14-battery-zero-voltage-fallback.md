# Treat Zero Battery Voltage as Unavailable

Status: Completed

## Context

The voltage formatter treats only negative millivolt values as unavailable.
Some battery broadcasts expose zero when no usable voltage reading exists, so
the app renders a misleading `0.0V` diagnostic instead of `Unknown`.

## Scope

- Treat non-positive millivolt readings as unavailable.
- Preserve one-decimal `Locale.US` formatting for positive readings.
- Preserve live-broadcast rendering and every other battery field.
- Add mutation-sensitive portable contracts and maintenance documentation.

## Verification

- Run the SDK-backed repository `make check` and the external-directory portable
  gate with SDK variables unset.
- Reject mutations that restore zero-voltage display, weaken positive formatting,
  remove documentation, or reopen this plan.
- Audit the exact diff, generated artifacts, changed-line secret patterns, and
  whitespace before commit.

## Risks

- No physical battery controller or vendor broadcast was exercised; the change
  is validated through source contracts and the pinned Android build.
- Existing stacked pull requests remain open and must not be merged or closed
  without explicit owner authorization.

## Verification Results

Completed on 2026-06-14:

- SDK-backed `make check` passed source contracts, debug and release Java
  compilation, Android lint, Gradle test tasks, and debug APK assembly under
  Amazon Corretto 8 and Android API 22. Lint retained one existing
  `OldTargetApi` warning and no errors.
- External-working-directory `make check` passed with Android SDK variables
  intentionally unset.
- Eight hostile mutations covering the non-positive guard, positive scaling,
  maintained documentation, and completed-plan status were rejected.
- Exact diff, generated-artifact, changed-line secret-pattern, and whitespace
  audits passed before commit.
- No physical device or vendor battery broadcast was exercised.
