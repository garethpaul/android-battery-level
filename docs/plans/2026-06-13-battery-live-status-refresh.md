# Refresh The Full Battery Display From Broadcasts

status: completed

## Context

The activity registers for `ACTION_BATTERY_CHANGED`, but the receiver forwards
only temperature. While the screen remains visible, level, icon, status,
health, charging source, voltage, current, and technology can therefore remain
stale until another activity setup cycle.

## Requirements

- R1. Forward each non-null battery broadcast intent to the activity.
- R2. Render every intent-backed battery field from that same broadcast.
- R3. Keep level scaling, unavailable sentinels, labels, icon thresholds,
  technology normalization, and current-reader behavior unchanged.
- R4. Preserve idempotent receiver registration and pause/stop unregistration.
- R5. Reject temperature-only callback regressions with method-bounded static
  contracts and focused hostile mutations.

## Scope Boundaries

- Do not change Android, Gradle, SDK, dependency, workflow, permission, or
  backup configuration.
- Do not add polling, services, persistence, or device-specific mappings.
- Do not claim emulator or physical-device broadcast behavior without those
  runtime facilities.

## Verification

- `make check`
- External-working-directory `make check`
- Focused hostile mutations for callback forwarding, full render delegation,
  same-intent temperature rendering, registration/lifecycle drift,
  documentation removal, and incomplete plan status.
- `git diff --check`, artifact, conflict-marker, and credential-shaped
  added-line inspection.
- Exact-head hosted Android validation after push.

## Work Completed

- Replaced the temperature-only receiver callback with a full battery-status
  callback while preserving the validated temperature cache.
- Centralized visible battery rendering around one supplied broadcast intent.
- Rendered temperature and voltage from the same snapshot as level, status,
  health, charging source, and technology.
- Added method-bounded static contracts and updated user, security, vision, and
  change guidance.

## Verification Completed

- `sh -n scripts/check-baseline.sh` passed.
- Local `make check` and external-working-directory `make -C` execution passed
  all SDK-free contracts. Android lint, tests, and build truthfully skipped
  because no Android SDK is configured locally.
- Nine focused hostile mutations were rejected: callback forwarding, callback
  ordering before temperature-only guards, renderer delegation, same-intent
  temperature, same-intent voltage, health rendering, lifecycle cleanup,
  README guidance, and plan-status rollback.
