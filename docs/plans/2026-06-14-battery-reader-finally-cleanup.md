# Battery Reader Finally Cleanup

Status: Completed

## Problem

`OneLineReader`, `SMemTextReader`, and `BattAttrTextReader` close their readers
only at the end of the successful `try` path. An exception while reading or
walking a battery attribute file bypasses those close calls. Repeated live
battery refreshes can therefore retain file descriptors after device-specific
sysfs failures.

## Requirements

1. Close each constructed `BufferedReader` from a `finally` block.
2. Guard nullable readers and keep close failures generic and path-free.
3. Preserve every source path, parser, unit conversion, field prefix, fallback
   decision, return value, and existing read/parse failure category.
4. Avoid try-with-resources or build-language changes in the legacy Java
   toolchain.
5. Add dependency-free contracts and hostile mutations for exception-safe
   cleanup, generic logs, documentation, and completed plan evidence.

## Implementation

- Retain a nullable reader variable outside each `try` block.
- Remove success-only close calls and close the reader in `finally`.
- Extend the canonical checker and project/security guidance.

## Verification

- The focused portable checker and shell syntax checks passed.
- Bounded Java 8/API 22 `make check` passed debug/release Java compilation,
  Android lint with the one documented legacy warning, debug/release unit-test
  tasks, and debug APK assembly.
- Seven hostile mutations were rejected: removing a reader `finally`, removing
  a null guard, removing a close call, restoring subordinate-stream closure,
  exposing close exception details, removing README guidance, and reopening
  this plan.
- Final verification includes external-directory execution, exact diff,
  whitespace, generated-artifact, and changed-line credential audits.
- Device-specific sysfs exception behavior was not exercised on compatible
  hardware.

## Scope Boundaries

- Do not change battery source discovery, parsing, values, UI rendering,
  dependencies, SDK levels, Gradle, workflows, or permissions.
- Do not claim device-specific sysfs behavior without compatible hardware.
- Do not merge or close any pull request without explicit owner authorization.
