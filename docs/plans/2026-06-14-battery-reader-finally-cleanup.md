# Battery Reader Finally Cleanup

Status: Planned

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

- Run the focused portable checker first.
- Run bounded Java 8/API 22 `make check`, including lint, unit-test tasks, and
  debug assembly.
- Reject mutations that remove a `finally`, remove the null guard or close,
  restore success-only closure, expose exception details, or reopen the plan.

## Scope Boundaries

- Do not change battery source discovery, parsing, values, UI rendering,
  dependencies, SDK levels, Gradle, workflows, or permissions.
- Do not claim device-specific sysfs behavior without compatible hardware.
- Do not merge or close any pull request without explicit owner authorization.
