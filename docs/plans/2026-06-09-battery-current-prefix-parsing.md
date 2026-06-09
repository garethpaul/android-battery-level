# Battery Current Prefix Parsing

status: completed

## Goal

Keep legacy battery current text-file readers from parsing unrelated fields
whose names merely contain a current-field token.

## Context

`SMemTextReader` and `BattAttrTextReader` read device-specific power-supply
text files. The previous parsing used substring checks before slicing values,
which could accept a longer or unrelated key and then parse the wrong portion
of the line. These files come from device kernels, so the parser should be
strict about the field prefix it accepts.

## Requirements

- Require the exact `I_MBAT: ` prefix before parsing `SMemTextReader` values.
- Require exact configured charge and discharge field prefixes before parsing
  `BattAttrTextReader` values.
- Trim parsed numeric text before `Long.parseLong`.
- Keep unsupported or malformed current readings returning `null`.
- Preserve existing display fallback behavior that renders `Unknown`.

## Changes

- Switched current reader field checks from substring matches to
  `startsWith(...)` prefix checks.
- Trimmed matched line values before numeric parsing.
- Added SDK-free baseline checks that reject the loose substring matching.
- Updated README, VISION, and CHANGES with the parser contract.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
