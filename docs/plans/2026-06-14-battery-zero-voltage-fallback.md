# Treat Zero Battery Voltage as Unavailable

Status: Planned

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
