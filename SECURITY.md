# Security Policy

## Supported Versions

The supported security scope for `android-battery-level` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: Get the Android Battery Level. 

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/android-battery-level` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be an Android mobile application or sample. The active security scope is the code and documentation on the default branch.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- Dependency manifests detected: build.gradle, gradle.properties. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.
- Pinned, read-only GitHub Actions runs the guarded `make check` baseline;
  review workflow, Gradle, and checker changes as part of the supply-chain
  surface.
- The baseline pins and verifies the wrapper JAR and Gradle distribution checksums.
  An uncached build still depends on HTTPS access to Gradle's distribution
  service, so these integrity controls do not provide offline reproducibility.
- Hosted checkout credentials are not persisted. CODEOWNERS assigns itself,
  the workflow, Makefile, and baseline checker to the repository owner;
  repository rules should require that approval.
- `check.yml` remains the only approved workflow until another workflow
  receives an explicit least-privilege security contract.
- Battery intent helper paths should tolerate unavailable contexts or broadcasts
  and display fallback values without crashing the local diagnostic UI.
- Generic battery reader failure logs preserve read and parse categories without
  including exception messages, kernel paths, malformed values, or stack traces.
- Unavailable charging-source data remains `Unknown` instead of being reported
  as a confirmed unplugged state.
- Battery technology labels are trimmed before display so whitespace-only
  system values retain the `Unknown` fallback instead of rendering blank.

## Mobile Privacy Notes

If this project requests device permissions such as location, camera, microphone, contacts, Bluetooth, health data, or local storage access, reports should describe the permission involved and whether sensitive data can be accessed, persisted, or transmitted unexpectedly. Please avoid testing against real third-party user data or accounts you do not control.

The checked-in manifest keeps local battery diagnostic state out of Android
backups by default.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

The checked-in wrapper uses a generated Gradle 8.14.5 bootstrap while retaining
the legacy Gradle 2.2.1 runtime required by Android Gradle Plugin 1.1.0. Review
changes to `gradlew`, `gradlew.bat`, `gradle-wrapper.jar`, and
`gradle-wrapper.properties` together. The SDK-free baseline rejects drift from
Gradle's published wrapper JAR and distribution SHA-256 values.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
