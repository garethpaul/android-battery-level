# Unicode-Visible Battery Labels

Status: Completed

## Context

Manufacturer, model, and technology values are local Android/vendor metadata.
The shared normalizer trimmed ASCII whitespace and rejected control or format
UTF-16 code units, but it treated Unicode separators, CGJ, variation selectors,
and supplementary format characters as visible. Those values could render a
blank or misleading row instead of the documented `Unknown` fallback.

## Design

- Traverse the bounded label with `codePointAt` and `Character.charCount` so
  supplementary format characters reach the existing fail-closed policy.
- Continue rejecting any ISO control or Unicode format code point.
- Track visible content separately from Unicode whitespace, separators, CGJ,
  Mongolian variation selectors, standard variation selectors, and
  supplementary variation selectors.
- Return `Unknown` when no visible base code point remains.
- Preserve visible labels containing variation selectors and the existing
  device-name fallback/rejection behavior.

## Test First

Eight focused host expectations were added before implementation and range
completion. The old code failed under `LC_ALL=C` on a
non-breaking-space/em-space-only label. The same suite also covers CGJ-only,
both variation-selector ranges, supplementary format-only, visible
variation-marked text, and invalid manufacturer fail-closed behavior.

## Verification Plan

- Run the host suite under `C` and `C.UTF-8`.
- Run the source baseline, twelve-case mutation suite, and mutation-runner gate.
- Run `make lint`, `test`, `build`, `verify`, and `check` from checkout and an
  external working directory.
- Run shell syntax checks and `git diff --check`.
- Use hosted Android lint/tests/build and CodeQL as exact-head authority when no
  local Android SDK is configured.

## Scope Boundaries

- No battery numeric value, current-source probing, receiver lifecycle, UI
  layout, resource, logging, backup, manifest, dependency, SDK, or network
  change.
- The policy remains bounded rather than attempting full Unicode rendering or
  grapheme analysis.

## Verification Completed

- Red-first `LC_ALL=C scripts/test-battery-host.sh` failed on Unicode
  separator-only input and then passed with 41 assertions after implementation.
- The host suite passed under both `C` and `C.UTF-8` locales.
- `scripts/check-baseline.sh`, the twelve-case mutation suite, and the
  mutation-runner infrastructure gate passed.
- `/usr/bin/make lint`, `test`, `build`, `verify`, and `check` passed under both
  locales.
- All five Make targets passed from `/tmp` through the absolute repository
  Makefile path.
- `sh -n` passed for all canonical shell gates and `git diff --check` passed.
- No local Android SDK was configured, so Gradle lint, tests, and debug assembly
  explicitly skipped; hosted exact-head checks remain authoritative.
