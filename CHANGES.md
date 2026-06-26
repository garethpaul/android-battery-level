# Changes

## 2026-06-26 16:35 - P2 - Count vendor-label limits by Unicode code point

- Battery vendor-label length is capped at 80 Unicode code points, so supplementary characters count once instead of as two UTF-16 code units.
- Added red-first host assertions for exactly 80 and 81 supplementary-plane battery symbols.
- Preserved trimming, visible-base requirements, control/format rejection, and the existing display fallback.
- The focused host suite passed 49 assertions, all 15 hostile mutations were
  rejected, and mutation-gate infrastructure regressions passed.
- `make lint`, `make test`, `make build`, `make verify`, repository-root and
  external-directory `make check`, shell syntax, and `git diff --check` passed.
  SDK-backed Gradle steps were skipped because the Android SDK is not configured.
- Hosted Android check run `28271138791` and CodeQL run `28271138020` passed on
  implementation head `9206583f458087393371eac8f80fba7e4ba9a5e1`, including
  Actions and Java/Kotlin analysis.
- Codex review stopped before analysis with OpenAI HTTP 401; immutable manual
  review found no actionable issues.

## 2026-06-26 10:30 - P2 - Reject combining-mark-only battery labels

- Combining-mark-only battery labels display as `Unknown` while decomposed accented labels remain intact.
- Added host assertions, a hostile mutation, maintained guidance, and implementation plans for the boundary.

## 2026-06-26 02:49 - P2 - Execute receiver delivery edge cases on the host

### Summary
Extended the dependency-free Java suite through the Android broadcast receiver
adapter so null and non-null delivery boundaries are executable without an SDK.

### Work completed
- Added minimal host-only Android content stubs for `BroadcastReceiver`,
  `Context`, and `Intent`.
- Verified non-null battery intents are forwarded exactly once and by identity.
- Verified null intents are ignored and a missing listener remains safe.
- Added a thirteenth hostile mutation that removes the null-intent guard.
- Kept the documented `onResume`/`onPause` registration scope unchanged.

### Threads
- Started: receiver delivery edge-case host coverage.
- Continued: lifecycle testing roadmap — adapter boundaries now execute in the
  SDK-free suite.
- Stopped: speculative late-callback production change; official Android
  guidance supports the existing registration scope and did not establish a
  defect.

### Files changed
- `host-tests/src/android/content/` — supplies the minimal receiver compile
  surface.
- `host-tests/src/garethpaul/com/chargeme/BatteryHostTest.java` — covers receiver
  forwarding and null boundaries.
- `scripts/test-battery-host.sh` and `scripts/test-battery-mutations.sh` — compile
  the production adapter and prove its null guard.
- Roadmap, baseline, and plan documentation — record the completed test gap.

### Validation
- Red-first `scripts/test-battery-host.sh` — failed because Android receiver
  types were not host-executable, then passed with 45 assertions.
- `scripts/test-battery-mutations.sh` — thirteen mutations rejected.
- `scripts/check-baseline.sh` and mutation-runner infrastructure checks — passed.
- `make lint|test|build|verify|check` from checkout and `/tmp` — passed; local
  SDK-backed Gradle steps explicitly skipped because no Android SDK is set.
- Shell syntax and `git diff --check` — passed.
- Hosted Android, CodeQL, exact-head review, and merge evidence remains the next
  action for this cycle.

### Bugs / findings
- P2: the receiver adapter's null-delivery behavior existed only as a static
  source contract and was not executed by the dependency-free test suite.

### Blockers
- None for portable verification; local Android SDK availability is checked by
  the canonical Make gate.

### Next action
- Run full local and hosted exact-head validation, then review and merge the
  focused PR.

## 2026-06-26 02:33 - P2 - Require visible Unicode battery labels

### Summary
Hardened manufacturer, model, and battery technology normalization so Unicode
separator-only, reviewed default-ignorable-only, and supplementary format-only
values display `Unknown` instead of blank or misleading local metadata.

### Work completed
- Replaced UTF-16 `char` scanning with Java 7-compatible Unicode code-point
  traversal.
- Preserved fail-closed control and format rejection across supplementary code
  points.
- Required at least one visible base code point beyond Unicode whitespace,
  separators, CGJ, and variation-selector ranges.
- Preserved visible text carrying a variation selector.
- Expanded the dependency-free host suite and mutation gate.

### Threads
- Started: none.
- Continued: direct telemetry-boundary audit — implementation and focused
  regression coverage complete.
- Stopped: none.

### Files changed
- `app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java` — adds the
  code-point-aware visible-label policy.
- `host-tests/src/garethpaul/com/chargeme/BatteryHostTest.java` — covers Unicode
  separators, CGJ, variation selectors, supplementary format content, and
  device-name fail-closed behavior.
- `scripts/check-baseline.sh` and `scripts/test-battery-mutations.sh` — enforce
  and mutation-test the new boundary.
- Documentation and plan files — record the local-only display policy.

### Validation
- Red-first `LC_ALL=C scripts/test-battery-host.sh` — failed on Unicode
  separator-only content, then passed with 41 assertions after implementation.
- `scripts/check-baseline.sh` — passed.
- `scripts/test-battery-mutations.sh` — twelve mutations rejected.
- `C` and `C.UTF-8` host and full Make matrices — passed.
- `make lint|test|build|verify|check` from checkout and `/tmp` — passed; local
  SDK-backed Gradle steps explicitly skipped because no Android SDK is set.
- Mutation-runner infrastructure checks, shell syntax, and `git diff --check` —
  passed.
- Hosted Android, CodeQL, exact-head review, and merge evidence remains the next
  action for this cycle.

### Bugs / findings
- P2: the previous `char` loop missed supplementary format code points and
  treated Unicode separator/default-ignorable-only strings as visible labels.

### Blockers
- None for portable verification; local Android SDK availability is checked by
  the canonical Make gate.

### Next action
- Run hosted exact-head validation, then review and merge the focused PR.

## 2026-06-25

- Made the dependency-free battery host test compile its Celsius fixture with
  an explicit UTF-8 source encoding instead of inheriting the host locale.

## 2026-06-19

- Corrected standard `current_now` sysfs values from microamps to milliamps and
  preserved fallback when an earlier source is corrupt or implausible.
- Added bounded telemetry formatting and control/bidirectional-character
  rejection for local model and battery technology labels.
- Simplified battery receiver ownership to render the registration-time sticky
  intent, removed duplicate temperature state, and made unregistration safe.
- Added 32 host assertions, Android instrumentation coverage, and six hostile
  mutations. Physical-device and vendor-sysfs validation remains unexecuted.

## 2026-06-15

- Added an explicit launcher export boundary for the sole `MAIN`/`LAUNCHER`
  activity and a structural manifest contract.

## 2026-06-14

- Treated non-positive voltage readings as unavailable instead of displaying
  a misleading `0.0V` value.
- Continued probing later battery-current sysfs sources when an earlier
  existing file cannot produce a valid reading.
- Ensured missing model metadata preserves generic current probes instead of
  failing before the reviewed source list is tried.
- During display rendering, missing device identity metadata falls back to the available value or `Unknown`
  so nullable or blank Build fields cannot abort battery status rendering.
- Battery text readers close from finally blocks, including read-failure paths,
  and report close failures without path or exception details.
- Added source-order, non-null return, completed-plan, and hostile-mutation
  contracts for current-source fallback behavior.
- Added an exact-commit battery device verification matrix for broadcast values,
  charging states, current sources, reader cleanup, lifecycle, and privacy-safe
  evidence, with every runtime row explicitly unexecuted.

## 2026-06-13

- Refreshed the full battery display from each live broadcast instead of
  updating only temperature until the next activity setup cycle.
- Rendered temperature, voltage, and the other intent-backed rows from the same
  broadcast snapshot while preserving existing formatters and fallbacks.
- Trimmed battery technology labels before display and retained `Unknown` for
  values that contain only whitespace.
- Distinguished unavailable charging-source data from the explicit unplugged
  state while preserving AC, USB, and wireless labels.
- Added completed-plan, documentation, and hostile-mutation contracts for the
  plugged-state display mapping.
- Replaced exception-derived battery text-reader logs with generic battery
  reader failure logs.
- Added exact log-count, stack-redaction, documentation, and completed-plan
  contracts while preserving nullable current behavior.

## 2026-06-12

- Regenerated the Gradle wrapper bootstrap with official Gradle 8.14.5 tooling
  while retaining the legacy Gradle 2.2.1 Android build runtime.
- Pinned Gradle's published SHA-256 for the 2.2.1 all distribution and added
  SDK-free contracts for the wrapper properties, JAR, and generated launchers.
- Documented the authenticated-download boundary without claiming offline
  reproducibility or broad Android build modernization.

## 2026-06-10

- Added explicit missing/sentinel guards for receiver and displayed battery
  temperatures so unavailable data renders as `Unknown`, not `0.0 ℃`.
- Connected valid receiver temperature broadcasts to the activity display so
  the visible value no longer remains stale until resume.
- Made root checks location-independent, accepted `ANDROID_SDK_ROOT`, and
  pinned CI to Ubuntu 24.04 with superseded-run cancellation.
- Added a pinned, read-only GitHub Actions workflow that runs `make check` for
  the battery receiver and resource baseline with a bounded timeout and
  explicit SDK-free execution.
- Extended the SDK-free baseline to require the CI workflow and completed CI
  plan.
- Removed the maintainer-specific Android SDK path from the Makefile.
- Disabled persisted checkout credentials, assigned CODEOWNERS and CI policy
  files to the repository owner, and replaced substring checks with one
  canonical workflow contract.

## 2026-06-09

- Guarded the battery receiver against missing broadcast intents and preserved
  one-decimal temperature precision in receiver-backed reads.
- Guarded sticky battery intent helpers when callers or broadcast intents are
  unavailable, preserving `Unknown` display fallbacks.
- Added SDK-free baseline coverage for null-safe battery intent helpers.
- Required exact field prefixes before parsing legacy battery current text files
  so unrelated keys cannot be mistaken for current readings.
- Populated battery state and technology display fields from Android battery
  broadcast extras and added SDK-free source contracts for the mappings.
- Clamped normalized battery percentages to the 0 through 100 display range
  before icon threshold selection.
- Guarded nullable action-bar access before applying the battery icon/title
  presentation and added an SDK-free source contract for the startup path.
- Displayed missing battery current readings as `Unknown` instead of the
  literal `null` text when no supported device current file is available.
- Kept local battery diagnostic state out of Android backups by default.

## 2026-06-08

- Added `make check` as the root wrapper for battery source, lint, test, and
  debug build verification.
- Added a repository changelog and expanded the documented Android verification
  gate to include lint, tests, and debug assembly.
- Cleaned Android lint findings by moving UI text into resources, replacing
  hardcoded left/right layout attributes, and adding an accessibility label for
  the battery indicator.
- Moved active bitmap assets to `drawable-nodpi`, removed unused starter images
  and menu resources, and documented the narrow legacy lint baseline.
- Fixed battery current model matching to use `Locale.US` instead of the
  device default locale.
- Added battery status intent guards and normalized displayed battery level
  against Android's reported battery scale.
- Tightened battery icon thresholds so 30 and 31 percent no longer fall through
  to the green state.
- Converted raw battery millivolt readings into one-decimal volt display text.
