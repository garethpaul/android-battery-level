# Battery Backup Policy

status: completed

## Context

The app displays local battery and device diagnostic state. That state is low
risk, but the sample does not need Android's platform backup service to copy
local app state across devices or accounts.

## Objectives

- Disable Android backups in the checked-in manifest.
- Keep the SDK-free baseline guarding against backup re-enablement.
- Document the backup policy with the battery privacy notes.
- Avoid changing battery display behavior or Android build configuration.

## Work Completed

- Set `android:allowBackup="false"` in `AndroidManifest.xml`.
- Added SDK-free manifest and documentation checks.
- Updated README, VISION, SECURITY, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add a privacy note if the app ever stores historical battery samples.
- Revisit Android backup rules during a modern SDK migration.
