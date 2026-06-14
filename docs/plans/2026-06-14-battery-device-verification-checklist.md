# Battery Device Verification Checklist

Status: In Progress

## Problem

Portable contracts cover battery-intent parsing, live refresh, unavailable
states, current-source fallback, normalization, and reader cleanup, but no
checklist defines emulator/device evidence for real battery inputs.

## Requirements

1. Add an exact-commit matrix for build, battery fields, unavailable values,
   live broadcasts, current sources, lifecycle, and privacy behavior.
2. Require sanitized toolchain, emulator/device, result, and log evidence.
3. Keep repository checks separate from unexecuted Android battery scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not modernize Gradle, target SDK, Android APIs, or dependencies.
- Do not add dumps, sysfs contents, device identifiers, APKs, logs, or keys.
- Do not claim emulator or physical-device execution from portable checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded repository validation.
