---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Modernize the Gradle Wrapper bootstrap without changing the legacy Android
build runtime. The repository will continue executing Gradle 2.2.1 with Java
8, while the wrapper verifies the downloaded distribution against Gradle's
official SHA-256 and the dependency-free baseline verifies the wrapper JAR's
published provenance.

---

## Problem Frame

The application intentionally retains Android Gradle Plugin 1.1.0 and Gradle
2.2.1 because the complete API 22 build is already characterized and green.
Its checked-in wrapper predates distribution checksum verification, however,
so a same-URL tampered or corrupted Gradle archive could execute before any
project checks run. Upgrading the build runtime directly would combine this
supply-chain fix with a much larger Android compatibility migration.

---

## Requirements

- **R1:** The wrapper must continue downloading and executing
  `gradle-2.2.1-all.zip`; Android Gradle Plugin 1.1.0, Java 8, API 22, and
  build-tools 24.0.3 remain unchanged.
- **R2:** `gradle-wrapper.properties` must pin Gradle's official SHA-256 for
  the Gradle 2.2.1 all distribution:
  `1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab`.
- **R3:** `gradlew`, `gradlew.bat`, and `gradle-wrapper.jar` must be regenerated
  from the established Gradle 8.14.5 wrapper tooling rather than manually
  edited or copied from an unknown binary.
- **R4:** The baseline checker must reject distribution URL/checksum drift,
  wrapper JAR drift, obsolete wrapper scripts, incomplete plan evidence, and
  documentation that overstates reproducibility.
- **R5:** The existing SDK-backed `make check` gate must remain green locally
  and on both canonical GitHub Actions events before tracker reconciliation.

---

## Key Technical Decisions

- **Separate wrapper bootstrap from build runtime:** use Gradle 8.14.5 to
  generate current wrapper files while retaining the Gradle 2.2.1
  distribution URL. Gradle documents that a current wrapper can execute an
  older Gradle version, avoiding an unrelated Android plugin migration.
- **Use two independent integrity checks:** runtime verification uses
  `distributionSha256Sum`; the SDK-free checker independently verifies the
  checked-in wrapper JAR against Gradle's published 8.14.5 wrapper checksum,
  `7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172`.
- **Keep the all distribution:** preserve the existing distribution type to
  avoid changing IDE/source availability as part of a security-only unit.
- **Treat exact versions as integrity metadata, not offline guarantees:** the
  docs must state that HTTPS and checksums authenticate expected bytes but the
  first build still depends on Gradle's distribution service.

---

## Scope Boundaries

### In Scope

- Regenerate the wrapper bootstrap files with official Gradle 8.14.5 tooling.
- Add the official Gradle 2.2.1 all-distribution checksum.
- Enforce wrapper files, hashes, documentation, and completed evidence in the
  existing dependency-free checker.
- Re-run the complete Java 8/API 22 Android verification gate.

### Deferred to Follow-Up Work

- Android Gradle Plugin, Gradle runtime, Android API, build-tools, support
  library, and JCenter migrations.
- Application behavior, resources, permissions, signing, and battery logic.
- Applying the same wrapper migration to the other legacy Android repositories
  before this repository's compatibility evidence is complete.

---

## Implementation Units

### U1. Verified Wrapper Bootstrap

**Goal:** Add distribution integrity verification without changing the Gradle
runtime used by the Android build.

**Requirements:** R1, R2, R3

**Dependencies:** None

**Files:**

- `gradlew`
- `gradlew.bat`
- `gradle/wrapper/gradle-wrapper.jar`
- `gradle/wrapper/gradle-wrapper.properties`

**Approach:** Generate all wrapper files from the portfolio's official Gradle
8.14.5 wrapper toolchain, then configure the generated properties to retain
`gradle-2.2.1-all.zip` and its official checksum. Verify that the wrapper JAR
matches Gradle's published 8.14.5 wrapper checksum. Its class-file major
version is 50 (Java 6), so it remains loadable by the repository's required
Java 8 runtime; verify that execution boundary before invoking project tasks.

**Patterns to follow:** The checksum-protected wrapper in
`garethpaul/TSAndroidGeocodeApp` and Gradle's documented wrapper upgrade and
verification process.

**Test scenarios:**

- With an empty temporary Gradle user home, `./gradlew --version` downloads the
  verified archive and reports Gradle 2.2.1 under Java 8.
- Replacing the distribution checksum with a wrong value causes bootstrap to
  fail before Gradle executes.
- The generated wrapper JAR SHA-256 equals Gradle's published 8.14.5 wrapper
  JAR checksum.

**Verification:** The official wrapper bootstrap launches the unchanged
Gradle 2.2.1 runtime and rejects mismatched distribution bytes.

### U2. Static Contract And Documentation

**Goal:** Make wrapper provenance and its limits durable repository contracts.

**Requirements:** R2, R3, R4

**Dependencies:** U1

**Files:**

- `scripts/check-baseline.sh`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`
- `docs/plans/2026-06-12-gradle-wrapper-verification.md`

**Approach:** Extend the existing checker to require the exact distribution
URL and checksum, exact wrapper JAR checksum, current generated script markers,
one completed plan status, and truthful verification evidence. Document the
authenticated-download boundary without claiming a modernized Android stack
or offline reproducibility.

**Patterns to follow:** Existing byte-exact workflow checks and completed-plan
evidence checks in `scripts/check-baseline.sh`.

**Test scenarios:**

- URL, distribution checksum, wrapper JAR, or wrapper script mutations are
  rejected by the SDK-free checker.
- Removing the artifact-authentication boundary from docs is rejected.
- Leaving the plan incomplete or removing a required verification result is
  rejected.

**Verification:** `make lint` passes only when all wrapper and documentation
contracts match the reviewed state.

### U3. Compatibility And Hosted Evidence

**Goal:** Prove the supply-chain hardening preserves the characterized legacy
Android build.

**Requirements:** R1, R5

**Dependencies:** U1, U2

**Files:**

- `docs/plans/2026-06-12-gradle-wrapper-verification.md`

**Approach:** Run the existing complete gate with Java 8 and the configured
Android SDK, exercise focused hostile mutations, and only then mark the plan
completed with exact local and hosted evidence. Require clean push,
pull-request, and CodeQL results at the final head.

**Test scenarios:**

- Android lint, both unit-test variants, and debug assembly pass with the
  regenerated wrapper and unchanged project build files.
- The complete gate passes from the repository root and an external working
  directory.
- The final pull request is open, clean, mergeable, and terminal-green at the
  exact local/upstream commit.

**Verification:** Local and hosted evidence proves the wrapper change does not
alter the established Android compatibility boundary.

---

## Risks And Mitigations

- **Wrapper bootstrap/runtime mismatch:** verify `./gradlew --version` under
  Java 8 before project tasks and retain the exact Gradle 2.2.1 URL.
- **Cached downloads hiding checksum behavior:** use a fresh temporary Gradle
  user home for bootstrap and negative-checksum tests.
- **Binary provenance ambiguity:** compare the checked-in JAR to Gradle's
  published wrapper checksum and enforce that hash statically.
- **Scope expansion into Android modernization:** reject changes to Gradle
  runtime, Android plugin, SDK targets, build-tools, repositories, or app code.

---

## Sources And Research

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle security best practices](https://docs.gradle.org/current/userguide/best_practices_security.html)
- [Gradle 2.2.1 all-distribution checksum](https://services.gradle.org/distributions/gradle-2.2.1-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)

---

## Work Completed

- Regenerated `gradlew`, `gradlew.bat`, `gradle-wrapper.jar`, and
  `gradle-wrapper.properties` with official Gradle 8.14.5 tooling while
  retaining the Gradle 2.2.1 all distribution.
- Added Gradle's published distribution SHA-256 and pinned the generated
  wrapper JAR and launcher hashes in the dependency-free baseline.
- Documented the authenticated-download boundary in the README, security
  policy, vision, and changelog without changing the Android build runtime or
  application behavior.

## Verification Completed

- A fresh temporary Gradle user home downloaded the checksum-protected all
  distribution and `./gradlew --version` reported Gradle 2.2.1 on Corretto
  Java 8 (`1.8.0_482`).
- A disposable wrapper copy rejected the deliberately incorrect distribution checksum
  before Gradle execution and reported the official archive checksum as the
  actual value.
- SDK-backed Gradle lint, test, and assembleDebug passed with Android API 22,
  build-tools 24.0.3, and Java 8. Lint retained only the documented
  `OldTargetApi` compatibility warning.
- SDK-backed `make check` passed from the repository root and from an external working directory
  with the same Java 8 and Android SDK configuration.
- Static hostile mutation checks rejected changes to the distribution
  checksum, wrapper JAR, generated launcher, documentation boundary, and plan
  completion evidence.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.

## Hosted Verification

- On implementation head `064cd895e2895ca962da4a5dbd49ed3a721eebac`,
  pull-request `Check` run `27439059851` passed the full Java 8/API 22 gate.
- CodeQL run `27439056892` passed both the actions and java-kotlin analyzers on
  the same implementation head.
- PR #2 was open, clean, and mergeable at that head. The workflow intentionally
  limits regular push runs to `master`, so the feature branch has no separate
  push-event `Check` run; the pull-request gate and exact-head CodeQL results
  are the pre-merge hosted evidence.
- The final evidence-only commit must rerun these same pull-request and CodeQL
  gates before tracker reconciliation.
