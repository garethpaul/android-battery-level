# Android Battery Level CI Baseline

## Status: Completed

## Context

`android-battery-level` has an SDK-free battery receiver and resource baseline
plus guarded Gradle gates behind `make check`. The repository needs the same
wrapper to run in GitHub Actions so battery display, lifecycle, and privacy
contracts are checked before review.

## Objectives

- Run the existing `make check` wrapper in GitHub Actions.
- Keep the CI job useful even when a legacy Android SDK is unavailable.
- Make the workflow presence part of the SDK-free baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned checkout to an immutable revision, limited permissions to repository
  reads, and bounded the job to five minutes.
- Reused the existing guarded Makefile targets, which run SDK-free checks and
  skip Gradle work when the Android SDK is absent.
- Removed the maintainer-specific default SDK path and cleared ambient hosted
  SDK variables so CI cannot accidentally invoke the unsupported Gradle path.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed plan.
- Disabled persisted checkout credentials and replaced partial string matching
  with a canonical single-workflow contract.
- Added self-protecting CODEOWNERS coverage for the workflow, Makefile, and
  baseline checker; repository rules remain responsible for requiring owner
  approval.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Add Android SDK-backed CI after migrating Gradle 2.2.1, Android Gradle Plugin
  1.2.3, JCenter, and the API 22 build baseline.
