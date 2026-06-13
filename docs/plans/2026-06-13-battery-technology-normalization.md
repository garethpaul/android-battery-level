# Normalize Battery Technology Display

status: completed

## Context

Android supplies the battery technology label as an optional string. The
current display helper accepts whitespace-only values and preserves surrounding
device whitespace, which can render a blank or visibly padded Technology row.

## Requirements

- R1. Missing battery intents and missing technology values must continue to
  display `Unknown`.
- R2. Technology values must be trimmed before display.
- R3. Values that are empty after trimming must display `Unknown`.
- R4. State, health, charging source, level, current, temperature, voltage,
  model, icon, and receiver lifecycle behavior must remain unchanged.
- R5. The SDK-free checker must isolate the technology helper and reject
  removal of normalization, fallback, or normalized return behavior.

## Scope Boundaries

- Do not change battery broadcast registration or lifecycle handling.
- Do not change Android, Gradle, SDK, dependency, or workflow configuration.
- Do not add device-specific technology mappings.

## Verification

- `make check`
- External-working-directory `make check`
- `git diff --check`
- Focused hostile mutations for trim removal, raw-value checks and returns,
  whitespace fallback removal, stale plan status, and missing verification
  evidence.
- Exact-base artifact and credential-shaped added-line inspection.
- Exact-head hosted Android validation after push.

## Work Completed

- Trimmed the optional Android battery technology value once before display.
- Returned `Unknown` for missing values and values empty after normalization.
- Added method-local source contracts without changing any other battery field,
  lifecycle path, dependency, project metadata, or workflow.
- Updated the user, security, vision, and change documentation.

## Verification Completed

- `make check` and external-working-directory baseline execution passed.
- Gradle lint, tests, and build truthfully skipped because no Android SDK is
  configured on this host.
- `git diff --check` passed.
- Six focused hostile mutations were rejected: trim removal, raw-value length
  checking, raw-value return, whitespace fallback removal, stale plan status,
  and missing verification evidence.
- Exact-base generated-artifact and credential-shaped added-line scans passed.
- Hosted Android validation is recorded separately after push; this plan claims
  only the completed local SDK-free verification.
