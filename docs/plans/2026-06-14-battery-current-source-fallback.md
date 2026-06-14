# Battery Current Source Fallback

Status: In Progress

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
