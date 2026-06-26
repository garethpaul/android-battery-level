# Combining-Mark-Only Battery Labels Design

## Evidence

- Battery labels require at least one visible code point, but the current
  helper counts general Unicode combining marks as visible content.
- A string containing only a combining acute accent has no base glyph and can
  render blank or as an implementation-dependent dotted placeholder.
- Legitimate decomposed text must remain accepted when a visible base character
  precedes its combining mark.

## Decision

Treat Unicode non-spacing, combining-spacing, and enclosing marks as
non-base content for the visibility test. Continue allowing those marks in a
label once another code point establishes visible base content.

## Validation

- Add a red host assertion for a combining-mark-only label.
- Preserve a decomposed accented label in the same focused test.
- Add a hostile mutation that restores combining marks as visible bases.
- Run the portable, mutation, baseline, hosted Android, and CodeQL gates.

## Boundaries

- Do not normalize or rewrite accepted labels.
- Do not change length, control, format, whitespace, device-name, or telemetry
  policies.
