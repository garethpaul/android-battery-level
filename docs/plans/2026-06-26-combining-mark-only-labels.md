# Combining-Mark-Only Battery Labels Implementation Plan

**Status:** Completed

**Goal:** Reject battery metadata labels that contain combining marks but no visible base character.

**Architecture:** Extend the existing code-point visibility predicate with Unicode mark categories while preserving the original string when any visible base character is present.

**Tech Stack:** Java 7, dependency-free host tests, POSIX shell, GNU Make

## Tasks

1. Add red mark-only and decomposed-accent host cases.
2. Extend the focused visibility predicate minimally.
3. Add baseline and hostile mutation coverage.
4. Synchronize maintained guidance and changelog.
5. Run local and hosted exact-head verification.

## Verification Results

- The host suite failed red-first because a combining acute accent alone was
  returned as a label instead of `Unknown`.
- The host suite passes with 47 assertions after Unicode mark categories became
  non-base content; decomposed `Cafe\u0301` remains unchanged.
- All 14 hostile mutations were rejected, including removal of the general
  non-spacing-mark guard.
- Repository and external-Makefile `make check`, mutation-runner regressions,
  shell syntax, and whitespace checks passed.
- No local Android SDK was configured, so Gradle lint, tests, and debug assembly
  skipped pending hosted exact-head verification.
- No physical-device vendor metadata rendering was exercised locally.
