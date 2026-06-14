# Battery Current Source Fallback

Status: Completed

## Problem

`CurrentReader` probes several device-specific sysfs files in priority order,
but most branches return immediately when a file exists. If that file is
unreadable or contains an invalid value, its reader returns `null` and the
remaining known sources are never tried. The UI therefore reports `Unknown`
even when a later supported source contains a valid current measurement.

## Requirements

1. Preserve the existing source order, model matching, path list, units, and
   parser selection.
2. Return the first non-null reading, while continuing to later sources after
   an existing source fails to produce a value.
3. Keep `null` as the final result when no supported source yields a value.
4. Add dependency-free contracts that reject immediate nullable returns and
   protect the fallback helper and completed plan evidence.
5. Preserve existing generic logging, Android configuration, permissions,
   dependencies, workflows, and display behavior.

## Verification

- Run shell syntax and the dependency-free baseline checker.
- Run bounded local and external-working-directory `make check` gates with the
  configured Android SDK when available.
- Run focused hostile mutations for helper removal, direct nullable return,
  source-order changes, missing null guard, and stale plan evidence.
- Inspect the exact diff, ignored artifacts, conflict markers, whitespace, and
  credential-shaped added lines before committing.

## Scope Boundaries

- Do not add or remove sysfs paths or change current conversion factors.
- Do not change the current UI format or infer a value from failed reads.
- Do not claim device-specific sensor behavior without compatible hardware.
- Do not merge or close stacked pull requests without explicit authorization.

## Work Completed

- Added one guarded one-line source reader and routed all nine one-line probes
  through it without changing their order, paths, parsers, or conversions.
- Continued to each later source after a nullable read while preserving the
  first non-null result and the final `null` fallback.
- Added exact source-order, helper, non-null return, documentation, and
  completed-plan contracts to the dependency-free checker.

## Verification Results

- Shell syntax and the dependency-free baseline checker passed.
- Five focused hostile mutations were rejected: inverted helper existence
  guard, restored direct nullable return, reordered source paths, inverted
  result null guard, and stale plan status.
- Local and external-working-directory `make check`, exact diff, artifact,
  conflict-marker, whitespace, and credential-shaped added-line results are
  recorded from the final implementation audit.
- Device-specific sysfs fallback behavior remains a hardware validation
  boundary; no emulator, physical device, or production result is claimed.
