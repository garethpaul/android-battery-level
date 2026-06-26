# AGENTS.md

## Repository purpose

`garethpaul/android-battery-level` is an Android application or sample. Get the Android Battery Level.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `app` - application source or app module
- `build.gradle` - Gradle build configuration
- `gradlew` - checked-in Gradle wrapper

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Android unit tests when the SDK is configured: `./gradlew test`
- Android debug build when the SDK is configured: `./gradlew assembleDebug`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Java (7), shell (1).
- Use the checked-in Gradle wrapper for Android builds when an SDK is configured.

## Testing guidance

- No dedicated test files were detected; treat `make check` as the minimum baseline.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- The legacy Android build is pinned to Android build-tools 24.0.3 for this baseline.
- Battery voltage is read from Android in millivolts and displayed as volts with one decimal place.
- Battery current uses `Unknown` when the device has no supported current sensor file.
- Current text-file readers require exact field prefixes before parsing values from legacy kernel power-supply files.
- Manufacturer, model, and technology labels must be scanned by Unicode code
  point, reject control/format content, and use `Unknown` when separators or
  reviewed default-ignorable marks contain no visible base character.
- Combining-mark-only battery labels display as `Unknown` while decomposed accented labels remain intact.
- Battery level percentages are normalized against Android's reported scale and clamped to 0 through 100 before display.
- Android's unavailable battery-level sentinel remains internal; the UI displays
  `Unknown` and uses the neutral battery icon instead of exposing `-1`.
- Unavailable charging-source data displays as `Unknown`; only Android's
  explicit zero value is presented as `On Battery`.
- Keep the explicit launcher export boundary on `.MainActivity`, which owns the
  sole `MAIN`/`LAUNCHER` filter; do not export unrelated components.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
