# Battery Intent Null Guards

Date: 2026-06-09
Status: Completed

## Problem

Battery display helpers depended on Android's sticky battery broadcast helper
always receiving a valid `Context`, and the technology helper assumed it always
received a non-null battery intent. Stale callers or unavailable broadcasts
could crash before existing `Unknown` display fallbacks were reached.

## Scope

- Return `null` from `batteryStatusIntent` when no context is available.
- Return `Unknown` from `batteryTechnologyText` when no battery intent is
  available.
- Keep existing state, health, plugged, percentage, temperature, voltage, and
  current display behavior unchanged.
- Extend the SDK-free baseline for the helper boundaries.

## Verification

- Red: `make lint` failed on the missing battery intent helper context guard.
- Green: `make lint` passes after adding the null guards.
- Full gate: `make check`.
