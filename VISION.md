## Android Battery Level Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Android Battery Level is a legacy Android app that displays battery health,
charge source, current, temperature, voltage, and device model information.

The repository is useful as a small example of reading battery broadcasts and
presenting device power state. Project setup and verification notes live in
[`README.md`](README.md).

The goal is to keep the battery-status sample buildable, accurate, and easy to
modernize without losing the original signal it demonstrates.

The current focus is:

Priority:

- Preserve the documented legacy Android build stack
- Keep broadcast receiver lifecycle handling correct
- Maintain an SDK-free baseline check for quick verification
- Keep displayed battery values clear and traceable to Android system inputs
- Keep state and technology fields populated from battery broadcast extras
- Keep battery technology labels trimmed with an `Unknown` fallback for
  whitespace-only values
- Keep unavailable charging-source data distinct from a confirmed unplugged
  state
- Keep sticky battery intent helper paths safe when broadcasts are unavailable
- Keep receiver-backed temperature reads null-safe and one-decimal accurate
- Keep visible temperature synchronized with valid live battery broadcasts
- Refresh the full battery display from each live broadcast while the activity
  remains visible
- Distinguish unavailable temperature data from a real zero-degree reading
- Keep normalized battery percentages clamped to the user-visible display range
- Keep displayed battery units converted before presentation
- Keep unavailable battery current readings clear instead of exposing raw null
  values
- Keep current text-file parsing constrained to exact field prefixes
- Keep legacy action-bar presentation optional so theme changes do not crash
  startup
- Keep local battery diagnostic state out of Android backups by default
- Keep the SDK-free `make check` baseline running in GitHub Actions
- Keep the legacy Gradle runtime isolated behind a checksum-verified generated
  wrapper

Next priorities:

- Evaluate Gradle runtime, SDK level, and Android plugin modernization together
  in a dedicated compatibility pass; wrapper bootstrap hardening is complete
- Add tests for battery formatting and lifecycle edge cases
- Review behavior across charging states and newer Android versions
- Improve UI labels without changing the sample's simple purpose

Contribution rules:

- One PR = one focused change.
- Run `scripts/check-baseline.sh` before pushing.
- Run `./gradlew tasks --no-daemon` and `./gradlew assembleDebug --no-daemon`
  when a compatible Android SDK is configured.
- Document any Android API behavior change that affects reported values.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Battery state is low-risk compared with account or location data, but device
model and power information should still be treated as local diagnostic data.
Do not add network reporting, analytics, or logging of device details without a
clear reason and explicit documentation.

## What We Will Not Merge (For Now)

- Analytics or telemetry built on battery/device information
- UI rewrites that make the sample harder to inspect
- Build migrations bundled with unrelated behavior changes
- Verification gate removals without equivalent replacement checks

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
