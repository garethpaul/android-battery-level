# Refresh The Full Battery Display From Broadcasts

status: planned

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
