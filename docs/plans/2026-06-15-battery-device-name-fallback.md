# Battery Device Name Fallback

Status: Planned

## Summary

Keep battery status rendering alive when Android device manufacturer or model
metadata is null, blank, or partially unavailable, and display a stable
`Unknown` fallback when no usable identity remains.

## Problem Frame

`MainActivity.getDeviceName` calls `model.startsWith(manufacturer)` before
checking either `Build` field. A vendor image with missing metadata can crash the
entire battery screen while otherwise valid battery readings are available.
Whitespace-only metadata can also produce an empty or misleading device label.

## Requirements

- **R1:** Normalize nullable manufacturer and model values before comparison or
  capitalization.
- **R2:** Return `Unknown` when both normalized values are empty.
- **R3:** Return the available value when only manufacturer or model is usable.
- **R4:** Avoid repeating the manufacturer when the model already begins with
  it, using a case-insensitive comparison.
- **R5:** Preserve existing battery, current, voltage, temperature, receiver,
  and lifecycle behavior.
- **R6:** Add fail-closed contracts and documentation for all fallback branches.

## Key Technical Decisions

- Normalize with the existing `capitalize` helper after trimming, keeping the
  legacy Java/API baseline and avoiding a new abstraction.
- Use `Locale.US` only for the comparison form; display the trimmed original
  metadata rather than lowercasing the rendered label.
- Keep the fallback entirely inside `getDeviceName` so battery intent parsing
  and current-source model normalization remain independent.

## Implementation Units

### U1: Normalize device identity before rendering

**Goal:** Prevent missing device metadata from aborting battery UI rendering.

**Requirements:** R1, R2, R3, R4, R5

**Dependencies:** None

**Files:**

- `app/src/main/java/garethpaul/com/chargeme/MainActivity.java`
- `scripts/check-baseline.sh`

**Approach:** Trim nullable manufacturer/model values, branch explicitly for
both-empty and one-value cases, and compare normalized values case-insensitively
before composing a two-part label.

**Test scenarios:**

- Null or blank manufacturer plus null or blank model returns `Unknown`.
- A model with no manufacturer returns the capitalized model.
- A manufacturer with no model returns the capitalized manufacturer.
- A model already prefixed by manufacturer in different casing is not repeated.
- Distinct manufacturer and model values render as one normalized label.

**Verification:** Portable source contracts enforce normalization before
comparison and every fallback branch; Android compilation proves API support.

### U2: Record the display fallback boundary

**Goal:** Keep maintained guidance aligned with the null-safe device label.

**Requirements:** R6

**Dependencies:** U1

**Files:**

- `README.md`
- `SECURITY.md`
- `CHANGES.md`
- `docs/plans/2026-06-15-battery-device-name-fallback.md`

**Approach:** Document that unavailable identity metadata degrades to the
available component or `Unknown` without hiding other battery readings.

**Test scenarios:** Documentation and completed-plan mutations are rejected.

**Verification:** Guidance, changelog, and completed evidence agree without
claiming physical-device metadata coverage.

## Scope Boundaries

- Do not change kernel current-source selection or Build metadata ownership.
- Do not modernize Gradle, target SDK, layouts, or localization in this slice.
- Do not merge or close stacked pull requests without owner authorization.

## Risks And Dependencies

- Static contracts and compilation cannot prove vendor-specific Build metadata;
  physical-device rows remain explicit in `DEVICE_VERIFICATION.md`.
- Case-insensitive prefix matching must not alter the displayed casing.

## Acceptance Examples

- **AE1:** Manufacturer is null and model is `Pixel 8`: the label is `Pixel 8`
  and the rest of the battery screen still renders.
- **AE2:** Manufacturer and model are blank: the label is `Unknown`.
- **AE3:** Manufacturer is `Google` and model is `google Pixel 8`: the label is
  `Google Pixel 8`, not `Google Google Pixel 8`.
