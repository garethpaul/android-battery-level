# Code-Point Vendor-Label Length

status: completed

## Goal

Apply the 80-character vendor-label bound to Unicode code points rather than
UTF-16 storage units.

## Work

- Add a code-point counter to the existing normalization scan.
- Accept exactly 80 visible supplementary characters and reject 81.
- Add a hostile code-point-length mutation and maintained guidance.

## Verification

- The red-first host test rejected an 80-symbol supplementary label as `Unknown`.
- The focused host suite and hostile code-point-length mutation pass after implementation.
- The focused host suite passed 49 assertions and all 15 hostile mutations were rejected.
- Mutation-gate infrastructure regressions passed.
- All Make aliases plus repository-root and external-directory `make check`, shell syntax, and `git diff --check` passed.
- SDK-backed Gradle steps were skipped because the Android SDK is not configured; hosted Android validation remains required.

Implementation head `9206583f458087393371eac8f80fba7e4ba9a5e1` passed hosted
Android check run `28271138791` and CodeQL run `28271138020`, including Actions
and Java/Kotlin analysis. Codex review stopped before analysis with OpenAI HTTP
401; immutable manual review found no actionable issues. The final
evidence-only head must repeat hosted validation.

## Scope

No display copy, battery telemetry values, intent handling, current-source
probing, logging, Android components, permissions, or network behavior changed.
